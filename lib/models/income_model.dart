// lib/models/income_model.dart

import 'package:isar/isar.dart';

part 'income_model.g.dart'; // Ten plik zostanie wygenerowany

@collection
class Income {
  Id id = Isar.autoIncrement;

  final String title;
  final double amount;

  @Index()
  final DateTime date;

  Income({
    required this.title,
    required this.amount,
    required this.date,
  });
}