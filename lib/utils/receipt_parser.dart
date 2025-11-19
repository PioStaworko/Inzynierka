// lib/utils/receipt_parser.dart

import '../models/expense_model.dart';

class ReceiptParser {
  
  static const _skipWords = [
    'SUMA', 'RAZEM', 'SPRZEDAŻ', 'OPODATKOWANA', 'PTU', 
    'RESZTA', 'DO ZAPŁATY', 'KARTA', 'GOTÓWKA', 'NIP', 
    'PARAGON', 'FISKALNY', 'NR SYS.', 'KASJER', 'DATA',
    'RABAT', 'PLN', 'WARTOSC', 'WSZYSTKIE', 'PROMOCJA',
    'KAUFLAND', 'MARKET', 'UL.', 'SP.Z', 'Z O.O.', 'BDO'
  ];

  static List<ExpenseItem> parse(String rawText) {
    final List<ExpenseItem> items = [];
    
    // 1. Wstępne czyszczenie tekstu
    // Naprawia błąd "16, 19" (spacja w cenie) oraz usuwa puste linie
    String cleanedText = rawText.replaceAllMapped(
      RegExp(r'(\d+),\s+(\d{2})'), 
      (match) => '${match.group(1)},${match.group(2)}'
    );

    final lines = cleanedText.split('\n')
        .map((e) => e.trim())
        .where((e) => e.length > 1) // Usuwa śmieci typu "t", "A"
        .toList();

    // Regex szukający ceny na końcu (np. 16,19C)
    final priceRegex = RegExp(r'(\d+[,.]\d{2})\s*[A-Z]?$');

    // Regex szukający linii "ilościowej" (np. 1SZT x..., 0,653KG x...)
    // Obsługuje "śmieci" na początku (np. "t 1SZT")
    final calculationLineRegex = RegExp(r'.*?[\d,.]+\s*(KG|SZT|L|G|kg|szt).*?[x*].*?\d+', caseSensitive: false);

    // KOLEJKA NAZW (Bufor na produkty, które czekają na swoją cenę)
    List<String> pendingNames = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // A. Czy to linia systemowa/nagłówek?
      if (_shouldSkip(line)) {
        // Jeśli trafiliśmy na linię sumy, czyścimy bufor, żeby nie łączyć nazw z nagłówka z cenami ze stopki
        if (line.toUpperCase().contains('SUMA') || line.toUpperCase().contains('PLN')) {
          pendingNames.clear();
        }
        continue;
      }

      // B. Czy to linia z CENĄ?
      final match = priceRegex.firstMatch(line);
      bool isCalculationLine = calculationLineRegex.hasMatch(line);
      
      if (match != null) {
        // Mamy cenę!
        String priceString = match.group(1)!.replaceAll(',', '.');
        double? price = double.tryParse(priceString);

        if (price != null && price > 0) {
          String name = "";

          // STRATEGIA 1: Czy mamy coś w kolejce? (Rozwiązuje problem kolumn)
          if (pendingNames.isNotEmpty && isCalculationLine) {
            // Bierzemy najstarszą nazwę z kolejki (FIFO)
            name = pendingNames.removeAt(0);
          } 
          // STRATEGIA 2: Klasyczny lookback (Nazwa w tej samej linii lub wyżej)
          else {
            if (isCalculationLine && i > 0) {
              // Jeśli to linia kalkulacyjna (np. 0,6KG x...), nazwa jest wyżej
              name = lines[i - 1];
            } else {
              // Nazwa jest w tej samej linii przed ceną
              name = line.substring(0, match.start).trim();
            }
          }

          // C. Czyszczenie finalnej nazwy
          name = _cleanName(name);

          // Walidacja i dodanie
          // Ignorujemy, jeśli nazwa to nadal resztki matematyki
          if (name.length > 2 && !_isJustMath(name) && !_shouldSkip(name)) {
            items.add(ExpenseItem()
              ..name = name
              ..rawId = name
              ..amount = price
              ..category = 'Other'
            );
            continue; // Przechodzimy do nast. linii, nie dodajemy tej linii do pendingNames
          }
        }
      }

      // D. Jeśli to nie była cena, ani śmieć -> to prawdopodobnie NAZWA PRODUKTU
      // Dodajemy do kolejki, czekając na cenę, która może pojawić się później
      if (!isCalculationLine) {
        pendingNames.add(line);
      }
    }
    return items;
  }

  static String _cleanName(String input) {
    String name = input;
    
    // Usuwa "t" na początku (artefakt OCR)
    if (name.startsWith('t ') || name.startsWith('t\t')) {
      name = name.substring(2).trim();
    }
    // Usuwa "t" na końcu
    if (name.endsWith(' t')) {
      name = name.substring(0, name.length - 2).trim();
    }
    // Usuwa literki podatkowe na końcu
    name = name.replaceAll(RegExp(r'\s[A-Z]$'), '').trim();
    
    // Usuwa matematykę z samej nazwy (jeśli została)
    name = name.replaceAll(RegExp(r'\d+\s*[x*]\s*\d+[,.]\d{2}'), '').trim();

    return name;
  }

  static bool _isJustMath(String text) {
    // Sprawdza, czy tekst to tylko liczby i jednostki (np. "1SZT")
    return RegExp(r'^[\d,.\s]+(SZT|KG|L|G)?$', caseSensitive: false).hasMatch(text);
  }

  static bool _shouldSkip(String line) {
    final upperLine = line.toUpperCase();
    if (line.length < 2) return true; // Ignoruj b. krótkie
    for (var word in _skipWords) {
      if (upperLine.contains(word)) return true;
    }
    return false;
  }
}