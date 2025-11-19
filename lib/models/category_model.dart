// lib/models/category_model.dart

import 'package:isar/isar.dart';

part 'category_model.g.dart';

enum CategoryType {
  expense,
  income
}

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index()
  late String name; // Nazwa np. "Jedzenie"

  @Enumerated(EnumType.name)
  late CategoryType type; // Czy to wydatek czy przychód

  late int colorValue; // Kolor zapisany jako int

  Category({
    required this.name,
    required this.type,
    required this.colorValue,
  });
}