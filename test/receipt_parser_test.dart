import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/receipt_parser.dart';

void main() {
  group('ReceiptParser.parseFromString', () {
    test('parses single-line item with price', () {
      final raw = 'Mleko     t     1SZT  x2,50 2,50C';
      final items = ReceiptParser.parseFromString(raw);
      expect(items.length, 1);
      expect(items[0].name.toLowerCase(), contains('mleko'));
      expect(items[0].amount, 2.5);
    });

    test('parses name on previous line', () {
      final raw = 'Chleb    t     1SZT  x3,20\n3,20';
      final items = ReceiptParser.parseFromString(raw);
      expect(items.length, 1);
      expect(items[0].name.toLowerCase(), contains('chleb'));
      expect(items[0].amount, 3.2);
    });

    test('applies discount to last item', () {
      final raw = 'Czekolada    t     1SZT  x5,00 5,00\nRABAT -1,00';
      final items = ReceiptParser.parseFromString(raw);
      expect(items.length, 1);
      expect(items[0].originalPrice, 5.0);
      expect(items[0].amount, 4.0);
    });

    test('stops parsing at stop words', () {
      final raw = 'Jabłko 1,00\nBanan 2,00\nRAZEM 3,00\nŚmieci 9,99';
      final items = ReceiptParser.parseFromString(raw);
      // Should only parse Apple and Banana
      expect(items.length, 2);
      expect(items[0].name.toLowerCase(), contains('jabłko'));
      expect(items[1].name.toLowerCase(), contains('banan'));
    });

    test('applies discount correctly with various formats', () {
      final raws = [
        'Produkt A 10,00\nRABAT -2,00',
        'Produkt B 20,00\nOPUST : 5,00',
        'Produkt C 15,00\n- 3,00 \n 12,00',
      ];
      final expectedAmounts = [8.0, 15.0, 12.0];

      for (int i = 0; i < raws.length; i++) {
        final items = ReceiptParser.parseFromString(raws[i]);
        expect(items.length, 1);
        expect(items[0].amount, expectedAmounts[i]);
      }
    });

    test('strips trailing qty/price tokens like Cheetos example', () {
      final raw = 'CheetosPizza160g         t  1SZT x6.79   6,79C';
      final items = ReceiptParser.parseFromString(raw);
      expect(items.length, 1);
      // The name should be cleaned to just the product token
      expect(items[0].name, equals('CheetosPizza160g'));
      expect(items[0].amount, closeTo(6.79, 0.001));
    });
  });
}
