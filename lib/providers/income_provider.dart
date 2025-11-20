import 'package:flutter/foundation.dart';
import '../data/app_database.dart';

class IncomeProvider extends ChangeNotifier {
  final IncomesDao incomesDao;
  final RecurringDao recurringDao;

  List<Income> _incomes = [];

  IncomeProvider(this.incomesDao, this.recurringDao) {
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _generateRecurringIncomes();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    _incomes = await incomesDao.getAllIncomes();
    notifyListeners();
  }

  // === LOGIKA GENEROWANIA ===
  Future<void> _generateRecurringIncomes() async {
    final now = DateTime.now();
    
    // Pobieramy szablony z bazy (RecurringDao)
    final templates = await recurringDao.getRecurringIncomes();
    
    final newIncomes = <IncomesCompanion>[];

    for (var template in templates) {
      var currentDueDate = template.nextDueDate;
      bool changed = false;

      // Pętla: dopóki data płatności jest w przeszłości lub dzisiaj
      while (currentDueDate.isBefore(now) || currentDueDate.isAtSameMomentAs(now)) {
        // Tworzymy nowy przychód (IncomesCompanion)
        newIncomes.add(IncomesCompanion.insert(
          title: template.title,
          amount: template.amount,
          date: currentDueDate,
        ));

        // Obliczamy następną datę (prosta logika miesięczna - tu można rozbudować o frequency)
        // Zakładam, że Frequency to String 'monthly', 'weekly' itd.
        if (template.frequency == 'monthly') {
           currentDueDate = DateTime(currentDueDate.year, currentDueDate.month + 1, currentDueDate.day);
        } else if (template.frequency == 'weekly') {
           currentDueDate = currentDueDate.add(const Duration(days: 7));
        } else if (template.frequency == 'daily') {
           currentDueDate = currentDueDate.add(const Duration(days: 1));
        } else if (template.frequency == 'yearly') {
           currentDueDate = DateTime(currentDueDate.year + 1, currentDueDate.month, currentDueDate.day);
        } else {
           // Fallback - domyślnie miesiąc
           currentDueDate = DateTime(currentDueDate.year, currentDueDate.month + 1, currentDueDate.day);
        }
        
        changed = true;
      }

      // Jeśli wygenerowano nowe, aktualizujemy datę w szablonie
      if (changed) {
        await recurringDao.updateRecurringIncomeDate(template.id, currentDueDate);
      }
    }

    // Zapisujemy batchowo nowe przychody
    if (newIncomes.isNotEmpty) {
      await incomesDao.addBatchIncomes(newIncomes);
      _loadIncomes();
    }
  }
  
  List<Income> get allIncomes => List.unmodifiable(_incomes);
  
  double get totalIncome {
    return _incomes.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Dodawanie pojedynczego przychodu
  Future<void> addIncome(String title, double amount, DateTime date) async {
    await incomesDao.addIncome(IncomesCompanion.insert(
      title: title,
      amount: amount,
      date: date,
    ));
    _loadIncomes();
  }

  // Usuwanie
  Future<void> deleteIncome(int incomeId) async {
    await incomesDao.deleteIncome(incomeId);
    _loadIncomes();
  }
}