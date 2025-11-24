// lib/providers/savings_goals_provider.dart

import 'package:flutter/foundation.dart';
import '../data/app_database.dart';
import '../services/notification_service.dart';

class SavingsGoalsProvider extends ChangeNotifier {
  final AppDb db;
  List<GoalWithProgress> _goals = [];
  final _notified = <int, bool>{};

  SavingsGoalsProvider(this.db) {
    _init();
  }

  List<GoalWithProgress> get goals => List.unmodifiable(_goals);

  void _init() {
    // Db nasłuchuje zmian w tabelach expenses/incomes, więc ten stream
    // odpali się automatycznie, gdy dodasz nowy wydatek!
    db.watchAllGoalsStream().listen((list) {
      _goals = list;
      _checkNotifications(list);
      notifyListeners();
    });
  }

  Future<void> addGoal(String title, double target, DateTime start, DateTime end) async {
    await db.addGoalRaw(title, target, start, end);
  }

  Future<void> deleteGoal(int id) async {
    await db.deleteGoalRaw(id);
  }

  void _checkNotifications(List<GoalWithProgress> list) {
    for (final g in list) {
      final id = g.goal.id;
      final prog = g.progress; // To teraz korzysta z (incomes - spent)
      
      // Używamy savedAmount zamiast incomes
      final remaining = (g.goal.targetAmount - g.savedAmount).clamp(0.0, double.infinity);

      // Powiadamiamy tylko jeśli faktycznie mamy postęp (prog > 0)
      // Zapobiega to powiadomieniom, gdy ktoś jest na minusie
      if (g.savedAmount > 0 && prog >= 0.8 && (_notified[id] ?? false) == false) {
        NotificationService().showNotification(
          id,
          'Cel oszczędnościowy: ${g.goal.title}',
          'Zbliżasz się do celu! Uzbierano: ${g.savedAmount.toStringAsFixed(2)} zł. Brakuje: ${remaining.toStringAsFixed(2)} zł',
        );
        _notified[id] = true;
      } else if (prog < 0.8 && (_notified[id] ?? false) == true) {
        _notified[id] = false;
      }
    }
  }
}