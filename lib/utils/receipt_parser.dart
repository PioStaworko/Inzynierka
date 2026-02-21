import 'dart:math';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ParsedItem {
  String name;
  String? rawId;
  double amount;
  String category;
  double? originalPrice;

  ParsedItem({
    required this.name, 
    this.rawId, 
    required this.amount, 
    this.originalPrice,
    this.category = 'Inne'
  });
}

class ReceiptParser {
  // Słowa, które definitywnie kończą sekcję produktów
  static const _stopWords = [
    'SUMA', 'RAZEM', 'SPRZEDAŻ OPODATKOWANA', 'DO ZAPŁATY', 'PODSUMOWANIE'
  ];

  // Słowa do ignorowania, ale które nie przerywają parsowania
  static const _ignoreWords = [
    'PTU', 'KARTA', 'GOTÓWKA', 'NIP', 'PARAGON', 'FISKALNY', 
    'NR SYS.', 'KASJER', 'DATA', 'PLN', 'WARTOSC', 'RESZTA',
    'KAUFLAND', 'MARKET', 'SP.Z', 'Z O.O.', 'BDO'
  ];

  static List<ParsedItem> parse(RecognizedText recognizedText) {
    // 1. Sortowanie i grupowanie linii (Twoja sprawdzona metoda)
    final rawText = _reconstructTextByCoordinates(recognizedText);
    return parseFromString(rawText);
  }


  /// Parse text directly from a raw (reconstructed) text string.
  ///
  /// Useful for unit tests where creating ML Kit `RecognizedText` is inconvenient.
  static List<ParsedItem> parseFromString(String rawText) {
    // 2. Czyszczenie "polskich" liczb (spacja w środku: 12, 99 -> 12,99)
    String cleanedText = rawText.replaceAllMapped(
      RegExp(r'(\d+),\s+(\d{2})'), 
      (match) => '${match.group(1)},${match.group(2)}'
    );

    final lines = cleanedText.split('\n')
        .map((e) => e.trim())
        .where((e) => e.length > 1)
        .toList();
    // Regexy
    final priceRegex = RegExp(r'(\d+[,.]\d{2})\s*[A-Z]?$'); // Cena na końcu
    final discountRegex = RegExp(r'(RABAT|OPUST|-)\s*[:]*\s*(\d+[,.]\d{2})', caseSensitive: false); 
    
    // Bufor nazw (gdy nazwa jest w linii nad ceną)
    List<String> pendingNames = [];
    List<ParsedItem> items = [];

    bool parsingFinished = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      String upperLine = line.toUpperCase();

      // A. SPRAWDZENIE KOŃCA PARAGONU
      // Jeśli trafimy na "SUMA", kończymy analizę, żeby nie łapać śmieci ze stopki
      for (var stopWord in _stopWords) {
        if (upperLine.contains(stopWord)) {
          parsingFinished = true;
          break;
        }
      }
      if (parsingFinished) break;

      // B. CZY TO LINIA Z RABATEM? (np. "Rabat -2.50" lub "- 2.50")
      // Logika dla Biedronki: Często linia rabatu jest POD produktem
      final discountMatch = discountRegex.firstMatch(line);
      if (discountMatch != null && items.isNotEmpty) {
        // Mamy rabat, aplikujemy go do OSTATNIEGO produktu
        String priceStr = discountMatch.group(2)!.replaceAll(',', '.');
        double discount = double.tryParse(priceStr) ?? 0.0;
        
        if (discount > 0) {
          var lastItem = items.last;
          // Jeśli jeszcze nie zapisaliśmy ceny oryginalnej, robimy to teraz
          lastItem.originalPrice ??= lastItem.amount;
          
          // Odejmujemy rabat
          // Uwaga: czasem OCR czyta "-" jako myślnik, czasem jako nic, więc odejmujemy bezwzględnie
          lastItem.amount = (lastItem.amount - discount);
          if (lastItem.amount < 0) lastItem.amount = 0;
        }
        continue; // Przechodzimy dalej
      }

      // C. CZY TO LINIA Z CENĄ?
      final priceMatch = priceRegex.firstMatch(line);
      
      if (priceMatch != null) {
        // Znalazłem cenę!
        String priceStr = priceMatch.group(1)!.replaceAll(',', '.');
        double price = double.tryParse(priceStr) ?? 0.0;

        // --- LOGIKA AKTUALIZACJI CENY (Dla Biedronki) ---
        // Czasem jest tak:
        // Linia 1: Produkt A ... 10.00 (Dodano produkt za 10.00)
        // Linia 2: ... (jakiś tekst rabatowy)
        // Linia 3: ... 8.00 (To jest właściwa cena po rabacie!)
        
        // Jeśli ta linia NIE MA NAZWY (jest krótka lub same liczby) 
        // I mamy już produkt na liście 
        // I ta cena jest mniejsza niż cena ostatniego produktu
        // -> To prawdopodobnie jest "Cena po rabacie" w osobnej linii.
        if (items.isNotEmpty && _isPriceOnlyLine(line)) {
           var lastItem = items.last;
           if (price < lastItem.amount) {
             lastItem.originalPrice = lastItem.amount;
             lastItem.amount = price;
             continue; // Zaktualizowaliśmy, idziemy dalej
           }
        }

        // --- LOGIKA NOWEGO PRODUKTU ---
        String name = "";

        // 1. Sprawdzamy bufor (nazwa była wyżej)
        //    Dodatkowy warunek: linia musi wyglądać na kalkulacyjną (np. "2 x 5.00") 
        //    LUB po prostu nazwa czekała.
        if (pendingNames.isNotEmpty) {
          name = pendingNames.removeAt(0);
        } 
        // 2. Nazwa jest w tej samej linii
        else {
          name = line.substring(0, priceMatch.start).trim();
        }

        name = _cleanName(name);

        // Walidacja i dodanie
        if (_isValidName(name)) {
          items.add(ParsedItem(
            name: name,
            rawId: name,
            amount: price,
          ));
        }
      } 
      // D. LINIA BEZ CENY -> Prawdopodobnie nazwa produktu (do bufora)
      else {
        // Ignorujemy śmieci systemowe
        if (!_shouldIgnore(line)) {
          pendingNames.add(line);
        }
      }
    }

    return items;
  }

  // --- METODY POMOCNICZE ---

  static bool _isValidName(String name) {
    if (name.length < 2) return false;
    // Jeśli nazwa to same cyfry lub znaki specjalne -> odrzuć
    if (double.tryParse(name) != null) return false;
    // Jeśli nazwa zawiera słowa systemowe -> odrzuć
    if (_shouldIgnore(name)) return false;
    return true;
  }

  static bool _shouldIgnore(String line) {
    final upper = line.toUpperCase();
    for (var word in _ignoreWords) {
      if (upper.contains(word)) return true;
    }
    return false;
  }

  static bool _isPriceOnlyLine(String line) {
    // Sprawdza, czy linia zawiera prawie wyłącznie cyfry i symbole "x", "szt", "kg"
    // Usuwamy cenę na końcu i patrzymy co zostało
    final priceRegex = RegExp(r'(\d+[,.]\d{2})\s*[A-Z]?$');
    final match = priceRegex.firstMatch(line);
    if (match == null) return false;
    
    String content = line.substring(0, match.start).trim();
    if (content.isEmpty) return true; // Pusta reszta = sama cena
    
    // Jeśli reszta to np. "1 x" albo "t" -> uznajemy za linię samej ceny
    if (content.length < 3) return true;
    
    // Jeśli reszta to "12.99" (inna liczba) -> też linia liczbowa
    if (double.tryParse(content) != null) return true;

    return false;
  }

  static String _cleanName(String input) {
    String name = input;
    // Artefakty OCR "t"
    if (name.startsWith('t ') || name.startsWith('t\t')) name = name.substring(2);
    if (name.endsWith(' t')) name = name.substring(0, name.length - 2);
    
    // Usuwanie liter podatkowych
    name = name.replaceAll(RegExp(r'\s[A-Z]$'), '');
    
    // Usuwanie matematyki (ilość x cena) z nazwy
    name = name.replaceAll(RegExp(r'\d+\s*[,.]?\d*\s*[x*]\s*\d+[,.]\d{2}'), '');

    // Dodatkowo obetnij trailing tokeny typu: "t", "1SZT", "SZT", "x6.79", liczby
    name = _stripTrailingQtyTokens(name);

    return name.trim();
  }

  static String _stripTrailingQtyTokens(String input) {
    var parts = input.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return input.trim();

    // Patterns indicating quantity/marker/price fragments
    final pureNumber = RegExp(r'^\d+[.,]?\d*$');
    final qtyWithSzt = RegExp(r'^\d+\s*(?:SZT|szt)$', caseSensitive: false);
    final sztSuffix = RegExp(r'^\d+(?:SZT|szt)$', caseSensitive: false);
    final xWithNumber = RegExp(r'^[x×*]\s*\d+[.,]?\d*$');
    final numberWithX = RegExp(r'^\d+[.,]?\d*\s*[x×*]\s*\d+[.,]?\d*');
    final singleLetter = RegExp(r'^[A-Z]$', caseSensitive: false);
    final numberWithTrailingLetter = RegExp(r'^\d+[.,]?\d*[A-Z]$', caseSensitive: false);
    final sztOnly = RegExp(r'^(?:SZT|szt)$', caseSensitive: false);

    // Remove trailing tokens that look like quantities/markers/prices
    while (parts.isNotEmpty) {
      final tok = parts.last;
      final t = tok.replaceAll(RegExp(r'[,:]'), ''); // normalize

      if (pureNumber.hasMatch(t) ||
          qtyWithSzt.hasMatch(t) ||
          sztSuffix.hasMatch(t) ||
          xWithNumber.hasMatch(t) ||
          numberWithX.hasMatch(t) ||
          numberWithTrailingLetter.hasMatch(t) ||
          singleLetter.hasMatch(t) ||
          sztOnly.hasMatch(t) ||
          // cases like '1SZT' without space
          RegExp(r'^\d+SZT$', caseSensitive: false).hasMatch(t)) {
        parts.removeLast();
        continue;
      }

      // also drop tokens that are all uppercase and short (like 'C', 'T', 'KG')
      if (t.length <= 3 && RegExp(r'^[A-ZĄĘÓĆŁŃŚŻŹ]+\d*$', caseSensitive: false).hasMatch(t)) {
        parts.removeLast();
        continue;
      }

      break;
    }

    return parts.join(' ');
  }

  // Twoja sprawdzona metoda sortowania linii
  static String _reconstructTextByCoordinates(RecognizedText text) {
    List<TextLine> allLines = [];
    for (var block in text.blocks) {
      allLines.addAll(block.lines);
    }

    // 1. Sortujemy po górnej krawędzi (top)
    allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    if (allLines.isEmpty) return "";

    List<List<TextLine>> rows = [];
    
    for (var line in allLines) {
      bool placed = false;
      
      // 2. Próbujemy dopasować linię do istniejącego wiersza
      for (var row in rows) {
        // Bierzemy reprezentanta wiersza (np. pierwszy element)
        var refLine = row.first;
        
        // Obliczamy nakładanie się w pionie (Vertical Overlap)
        double top1 = line.boundingBox.top;
        double bottom1 = line.boundingBox.bottom;
        double top2 = refLine.boundingBox.top;
        double bottom2 = refLine.boundingBox.bottom;
        
        // Max z górnych krawędzi, Min z dolnych krawędzi
        double overlapTop = max(top1, top2);
        double overlapBottom = min(bottom1, bottom2);
        double overlapHeight = max(0, overlapBottom - overlapTop);
        
        // Wysokość mniejszego elementu
        double minHeight = min(line.boundingBox.height, refLine.boundingBox.height);
        
        // JEŚLI nakładają się na więcej niż 50% wysokości mniejszego elementu -> to ten sam wiersz
        if (overlapHeight > (minHeight * 0.5)) {
          row.add(line);
          placed = true;
          break;
        }
      }
      
      // Jeśli nie pasuje do żadnego wiersza -> stwórz nowy
      if (!placed) {
        rows.add([line]);
      }
    }

    // 3. Sortujemy wiersze od góry do dołu (dla pewności)
    rows.sort((a, b) => a.first.boundingBox.top.compareTo(b.first.boundingBox.top));

    List<String> finalOutput = [];
    for (var row in rows) {
      // 4. Wewnątrz wiersza sortujemy od lewej do prawej
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      
      // 5. Łączymy teksty. Dodajemy duży odstęp, żeby łatwiej było debugować.
      finalOutput.add(row.map((e) => e.text).join("   ")); 
    }

    return finalOutput.join('\n');
  }
}