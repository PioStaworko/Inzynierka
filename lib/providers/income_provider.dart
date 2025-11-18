import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/income_model.dart';
import '../models/recurring_income_model.dart'; // <--- Potrzebujemy tego importu, żeby widzieć szablony

class IncomeProvider extends ChangeNotifier {
  final Isar isar;
  List<Income> _incomes = [];

  IncomeProvider(this.isar) {
    // Przy starcie uruchamiamy logikę generowania i ładowania
    _initializeState();
  }

  Future<void> _initializeState() async {
    // 1. Najpierw sprawdź i wygeneruj zaległe/dzisiejsze wpływy z szablonów
    await _generateRecurringIncomes();
    
    // 2. Dopiero potem wczytaj listę do wyświetlenia
    _loadIncomes();
    notifyListeners();
  }

  // Wczytywanie listy przychodów (posortowane od najnowszych)
  void _loadIncomes() {
    _incomes = isar.incomes.where().sortByDateDesc().findAllSync();
  }

  // === GŁÓWNA LOGIKA GENEROWANIA PRZYCHODÓW ===
  Future<void> _generateRecurringIncomes() async {
    final now = DateTime.now();
    
    // Pobieramy wszystkie szablony przychodów
    final templates = await isar.recurringIncomes.where().findAll();

    final List<Income> newIncomes = [];
    final List<RecurringIncome> updatedTemplates = [];

    for (var template in templates) {
      var currentDueDate = template.nextDueDate;
      var templateToUpdate = template;

      // Pętla generująca: "Dopóki data płatności jest w przeszłości lub dzisiaj"
      while (currentDueDate.isBefore(now) || currentDueDate.isAtSameMomentAs(now)) {
        
        // 1. Stwórz konkretny przychód (Instancję)
        final newIncome = Income(
          title: template.title, // Używamy tytułu z szablonu
          amount: template.amount,
          date: currentDueDate,
        );
        newIncomes.add(newIncome);

        // 2. Oblicz następną datę (przesuń o miesiąc/tydzień itp.)
        final nextDate = templateToUpdate.nextDateAfter;
        
        // 3. Zaktualizuj szablon o nową datę
        templateToUpdate = RecurringIncome(
          title: template.title,
          amount: template.amount,
          source: template.source,
          frequency: template.frequency,
          nextDueDate: nextDate,
        )..id = template.id; // Zachowaj to samo ID szablonu

        currentDueDate = nextDate; // Przesuń pętlę
      }

      // Jeśli szablon się zmienił (data się przesunęła), dodaj do listy do zapisu
      if (templateToUpdate.id != template.id || templateToUpdate.nextDueDate != template.nextDueDate) {
        updatedTemplates.add(templateToUpdate);
      }
    }

    // Zapisz wszystko w jednej transakcji (wydajność!)
    if (newIncomes.isNotEmpty || updatedTemplates.isNotEmpty) {
      await isar.writeTxn(() async {
        if (newIncomes.isNotEmpty) {
          await isar.incomes.putAll(newIncomes); // Dodaj nowe przychody
        }
        if (updatedTemplates.isNotEmpty) {
          await isar.recurringIncomes.putAll(updatedTemplates); // Zaktualizuj daty w szablonach
        }
      });
    }
  }
  
  List<Income> get allIncomes => List.unmodifiable(_incomes);
  
  double get totalIncome {
    return _incomes.fold(0.0, (sum, item) => sum + item.amount);
  }


  Future<void> addIncome(Income income) async {
    await isar.writeTxn(() async {
      await isar.incomes.put(income);
    });
    _loadIncomes();
    notifyListeners();
  }


  Future<void> deleteIncome(int incomeId) async {
    await isar.writeTxn(() async {
      await isar.incomes.delete(incomeId);
    });
    _loadIncomes();
    notifyListeners();
  }
}