// lib/utils/receipt_parser.dart

class ParsedItem {
  String name;
  String? rawId;
  double amount;
  String category;

  ParsedItem({
    required this.name, 
    this.rawId, 
    required this.amount, 
    this.category = 'Inne'
  });
}

class ReceiptParser {
  static const _skipWords = [
    'SUMA', 'RAZEM', 'SPRZEDAŻ', 'OPODATKOWANA', 'PTU', 
    'RESZTA', 'DO ZAPŁATY', 'KARTA', 'GOTÓWKA', 'NIP', 
    'PARAGON', 'FISKALNY', 'NR SYS.', 'KASJER', 'DATA',
    'RABAT', 'PLN', 'WARTOSC', 'WSZYSTKIE', 'PROMOCJA',
    'KAUFLAND', 'MARKET', 'UL.', 'SP.Z', 'Z O.O.', 'BDO'
  ];

  static List<ParsedItem> parse(String rawText) {
    final List<ParsedItem> items = [];
    
    String cleanedText = rawText.replaceAllMapped(
      RegExp(r'(\d+),\s+(\d{2})'), 
      (match) => '${match.group(1)},${match.group(2)}'
    );

    final lines = cleanedText.split('\n')
        .map((e) => e.trim())
        .where((e) => e.length > 1)
        .toList();

    final priceRegex = RegExp(r'(\d+[,.]\d{2})\s*[A-Z]?$');
    final calculationLineRegex = RegExp(r'.*?[\d,.]+\s*(KG|SZT|L|G|kg|szt).*?[x*].*?\d+', caseSensitive: false);

    List<String> pendingNames = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      if (_shouldSkip(line)) {
        if (line.toUpperCase().contains('SUMA') || line.toUpperCase().contains('PLN')) {
          pendingNames.clear();
        }
        continue;
      }

      final match = priceRegex.firstMatch(line);
      bool isCalculationLine = calculationLineRegex.hasMatch(line);
      
      if (match != null) {
        String priceString = match.group(1)!.replaceAll(',', '.');
        double? price = double.tryParse(priceString);

        if (price != null && price > 0) {
          String name = "";

          if (pendingNames.isNotEmpty && isCalculationLine) {
            name = pendingNames.removeAt(0);
          } else {
            if (isCalculationLine && i > 0) {
              name = lines[i - 1];
            } else {
              name = line.substring(0, match.start).trim();
            }
          }

          name = _cleanName(name);

          if (name.length > 2 && !_isJustMath(name) && !_shouldSkip(name)) {
            items.add(ParsedItem(
              name: name,
              rawId: name,
              amount: price,
            ));
            continue;
          }
        }
      }

      if (!isCalculationLine) {
        pendingNames.add(line);
      }
    }
    return items;
  }

  static String _cleanName(String input) {
    String name = input;
    if (name.startsWith('t ') || name.startsWith('t\t')) name = name.substring(2).trim();
    if (name.endsWith(' t')) name = name.substring(0, name.length - 2).trim();
    name = name.replaceAll(RegExp(r'\s[A-Z]$'), '').trim();
    name = name.replaceAll(RegExp(r'\d+\s*[x*]\s*\d+[,.]\d{2}'), '').trim();
    return name;
  }

  static bool _isJustMath(String text) {
    return RegExp(r'^[\d,.\s]+(SZT|KG|L|G)?$', caseSensitive: false).hasMatch(text);
  }

  static bool _shouldSkip(String line) {
    final upperLine = line.toUpperCase();
    if (line.length < 2) return true;
    for (var word in _skipWords) {
      if (upperLine.contains(word)) return true;
    }
    return false;
  }
}