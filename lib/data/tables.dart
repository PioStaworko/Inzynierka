import 'package:drift/drift.dart';

// Tabela Kategorii (Słownik)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50).unique()();
  TextColumn get type => text()(); // 'expense' lub 'income'
  IntColumn get colorValue => integer()();
}

// Tabela Wydatków (Nagłówek)
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  
  // Relacja do kategorii
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
}

// Tabela Pozycji (Szczegóły paragonu)
class ExpenseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Kaskadowe usuwanie: usunięcie wydatku usuwa jego pozycje
  IntColumn get expenseId => integer().references(Expenses, #id, onDelete: KeyAction.cascade)(); 
  TextColumn get name => text()();
  RealColumn get amount => real()();
  
  // Każda pozycja może mieć własną kategorię
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
}

// Tabela Przychodów
class Incomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
}

// Tabela Mapowania Produktów (OCR Learning)
class ProductMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawId => text().unique()(); // Surowy tekst z paragonu
  TextColumn get knownName => text()();      // Ładna nazwa
  
  // Tylko ID (Normalizacja)
  IntColumn get defaultCategoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
}

// Wydatki Cykliczne (Szablony)
class RecurringExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  
  // Tylko ID (Normalizacja)
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get frequency => text()();
  DateTimeColumn get nextDueDate => dateTime()();
}

// Przychody Cykliczne (Szablony)
class RecurringIncomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get source => text()(); // Tutaj String jest OK, chyba że chcesz tabelę 'Sources'
  TextColumn get frequency => text()();
  DateTimeColumn get nextDueDate => dateTime()();
}

// Budżety
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Tylko ID (Normalizacja)
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  
  RealColumn get amountLimit => real()();
  TextColumn get period => text()(); 
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)(); 
}

// Cele Oszczędnościowe
class SavingsGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  RealColumn get targetAmount => real()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}