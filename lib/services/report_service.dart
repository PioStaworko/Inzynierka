import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../data/app_database.dart'; // Tu są klasy Expense, Category itp.
// import 'package:drift/drift.dart'; // Niepotrzebne tutaj, chyba że używamy typów SQL

class ReportService {
  /// Generuje raport Excel (.xlsx) dostosowany do nowej bazy danych SQL.
  static Future<String?> generateFullReport(BuildContext context) async {
    AppDb db;
    try {
      db = await AppDb.create();
    } catch (e, st) {
      debugPrint('[ReportService] Failed to open DB: $e\n$st');
      return null;
    }

    try {
      final excel = Excel.createExcel();
      
      // Usuwamy domyślny arkusz
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // --- 1. POBIERANIE DANYCH ---
      // Pobieramy wszystko na raz dla wydajności
      final allCategories = await db.categoriesDao.getAllCategories();
      // Pobieramy wydatki wraz z ich pozycjami (ExpenseWithItems)
      final expensesWithItems = await db.expensesDao.getRecentExpenses(); 
      final incomes = await db.incomesDao.getAllIncomes();
      final recurringExpenses = await db.recurringDao.getRecurringExpenses();
      final recurringIncomes = await db.recurringDao.getRecurringIncomes();

      // --- 2. MAPOWANIE KATEGORII (Kluczowy krok w SQL) ---
      // Tworzymy mapę ID -> Nazwa, aby nie robić zapytań SQL w pętli.
      // Jeśli categoryId == null lub nie istnieje, zwrócimy 'Inne'.
      final categoryNameMap = {for (var c in allCategories) c.id: c.name};

      String getCatName(int? id) {
        if (id == null) return 'Brak kategorii';
        return categoryNameMap[id] ?? 'Nieznana ($id)';
      }

      // --- 3. PRZETWARZANIE DANYCH DO STATYSTYK ---
      
      // A. Bilans miesięczny
      final Map<String, Map<String, double>> monthlyStats = {};
      
      // Przetwarzanie wydatków
      for (final entry in expensesWithItems) {
        final ex = entry.expense;
        final dateKey = "${ex.date.year}-${ex.date.month.toString().padLeft(2, '0')}";
        
        monthlyStats.putIfAbsent(dateKey, () => {'income': 0.0, 'expense': 0.0});
        monthlyStats[dateKey]!['expense'] = (monthlyStats[dateKey]!['expense'] ?? 0) + ex.amount;
      }
      
      // Przetwarzanie przychodów
      for (final inc in incomes) {
        final dateKey = "${inc.date.year}-${inc.date.month.toString().padLeft(2, '0')}";
        
        monthlyStats.putIfAbsent(dateKey, () => {'income': 0.0, 'expense': 0.0});
        monthlyStats[dateKey]!['income'] = (monthlyStats[dateKey]!['income'] ?? 0) + inc.amount;
      }

      // B. Statystyki Kategorii (do wykresu kołowego)
      final Map<String, double> categoryStats = {};
      
      for (final entry in expensesWithItems) {
        final ex = entry.expense;
        final items = entry.items;

        // Jeśli są pod-pozycje, sumujemy je wg ich kategorii
        if (items.isNotEmpty) {
          for (final item in items) {
            final catName = getCatName(item.categoryId);
            categoryStats[catName] = (categoryStats[catName] ?? 0) + item.amount;
          }
        } else {
          // Jeśli to zwykły wydatek, bierzemy kategorię nagłówka
          final catName = getCatName(ex.categoryId);
          categoryStats[catName] = (categoryStats[catName] ?? 0) + ex.amount;
        }
      }

      // --- 4. GENEROWANIE ARKUSZY ---

      // === ARKUSZ: PODSUMOWANIE ===
      final summarySheet = excel['Podsumowanie'];
      _addHeader(summarySheet, ['MIESIĘCZNY BILANS (Do wykresu słupkowego)']);
      summarySheet.appendRow(['Miesiąc', 'Przychody', 'Wydatki', 'Bilans']);
      
      final sortedMonths = monthlyStats.keys.toList()..sort(); // Sortuj od najstarszego
      
      for (final month in sortedMonths) {
        final inc = monthlyStats[month]!['income']!;
        final exp = monthlyStats[month]!['expense']!;
        summarySheet.appendRow([month, inc, exp, inc - exp]);
      }

      summarySheet.appendRow(['']); // Pusty wiersz
      _addHeader(summarySheet, ['WYDATKI WG KATEGORII (Do wykresu kołowego)']);
      summarySheet.appendRow(['Kategoria', 'Suma']);
      
      for (final entry in categoryStats.entries) {
        summarySheet.appendRow([entry.key, entry.value]);
      }

      // === ARKUSZ: WYDATKI ===
      final expSheet = excel['Wydatki'];
      _addHeader(expSheet, ['ID', 'Data', 'Tytuł', 'Kwota', 'Kategoria Główna', 'Szczegóły (Produkty)']);

      for (final entry in expensesWithItems) {
        final ex = entry.expense;
        final items = entry.items;
        
        final dateStr = ex.date.toIso8601String().split('T')[0];
        final mainCatName = getCatName(ex.categoryId);

        // Sklejamy listę produktów w jeden ciąg tekstowy dla czytelności w Excelu
        String details = "";
        if (items.isNotEmpty) {
          details = items.map((i) {
            final itemCat = getCatName(i.categoryId);
            // Format: "Mleko (5.00 zł - Jedzenie)"
            return "${i.name} (${i.amount.toStringAsFixed(2)} zł - $itemCat)";
          }).join(", ");
        }

        expSheet.appendRow([
          ex.id,
          dateStr,
          ex.title,
          ex.amount,
          mainCatName,
          details
        ]);
      }

      // === ARKUSZ: PRZYCHODY ===
      final incSheet = excel['Przychody'];
      _addHeader(incSheet, ['ID', 'Data', 'Tytuł', 'Kwota']);

      for (final inc in incomes) {
        final dateStr = inc.date.toIso8601String().split('T')[0];
        incSheet.appendRow([inc.id, dateStr, inc.title, inc.amount]);
      }

      // === ARKUSZ: CYKLICZNE ===
      final recSheet = excel['Cykliczne'];
      _addHeader(recSheet, ['Typ', 'Tytuł', 'Kwota', 'Częstotliwość', 'Następna płatność', 'Kategoria/Źródło']);

      for (final re in recurringExpenses) {
        recSheet.appendRow([
          'Wydatek',
          re.title,
          re.amount,
          re.frequency,
          re.nextDueDate.toIso8601String().split('T')[0],
          getCatName(re.categoryId) // Mapujemy ID na nazwę
        ]);
      }

      for (final ri in recurringIncomes) {
        recSheet.appendRow([
          'Przychód',
          ri.title,
          ri.amount,
          ri.frequency,
          ri.nextDueDate.toIso8601String().split('T')[0],
          ri.source // Tutaj source jest Stringiem, nie ID
        ]);
      }

      // --- 5. ZAPIS PLIKU ---
      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception('Failed to encode excel');

      final docDir = await getApplicationDocumentsDirectory();
      final reportsDir = Directory(p.join(docDir.path, 'reports'));
      if (!await reportsDir.exists()) await reportsDir.create(recursive: true);

      final now = DateTime.now();
      final filename = 'Raport_${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}_${now.hour}${now.minute}.xlsx';
      final filePath = p.join(reportsDir.path, filename);

      final outFile = File(filePath);
      await outFile.writeAsBytes(fileBytes, flush: true);

      // Próba otwarcia
      try {
        await OpenFile.open(outFile.path);
      } catch (_) {
        debugPrint("Nie udało się automatycznie otworzyć pliku");
      }

      return outFile.path;

    } catch (e, st) {
      debugPrint('[ReportService] Error: $e\n$st');
      return null;
    } finally {
      await db.close();
    }
  }

  static void _addHeader(Sheet sheet, List<String> titles) {
    sheet.appendRow(titles);
    // Tutaj można dodać stylowanie, jeśli biblioteka excel na to pozwoli w przyszłości w prosty sposób
  }
}