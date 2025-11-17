// lib/models/recurring_expense_model.dart

import 'package:isar/isar.dart';

part 'recurring_expense_model.g.dart'; // Wygenerujemy to

// Enum do określenia częstotliwości
enum Frequency {
  daily,
  weekly,
  monthly,
  yearly,
}

@collection
class RecurringExpense {
  Id id = Isar.autoIncrement;

  final String title;
  final double amount;
  final String category;

  // Używamy Isar'owego @Enumerated do przechowania enuma
  @Enumerated(EnumType.name)
  final Frequency frequency;

  // To jest kluczowe: przechowujemy datę NASTĘPNEJ płatności.
  @Index()
  final DateTime nextDueDate;

  RecurringExpense({
    required this.title,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.nextDueDate,
  });

  // Metoda pomocnicza do obliczenia następnej daty na podstawie obecnej
  DateTime get nextDateAfter {
    switch (frequency) {
      case Frequency.daily:
        return nextDueDate.add(const Duration(days: 1));
      case Frequency.weekly:
        return nextDueDate.add(const Duration(days: 7));
      case Frequency.monthly:
        // To jest bezpieczniejszy sposób dodawania miesięcy
        return DateTime(nextDueDate.year, nextDueDate.month + 1, nextDueDate.day);
      case Frequency.yearly:
        return DateTime(nextDueDate.year + 1, nextDueDate.month, nextDueDate.day);
    }
  }
}