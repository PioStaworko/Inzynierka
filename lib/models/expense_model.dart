// lib/models/expense_model.dart

import 'package:isar/isar.dart';

part 'expense_model.g.dart'; // Ta linia zostanie wygenerowana

@collection // Mówi Isar, że to jest model bazy danych
class Expense {
  Id id = Isar.autoIncrement; // Klucz główny dla bazy danych

  final String title;
  final double amount;

  @Index() // Tworzy indeks dla kategorii - przyspieszy filtrowanie
  final String category;

  @Index() // Tworzy indeks dla daty
  final DateTime date;

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}