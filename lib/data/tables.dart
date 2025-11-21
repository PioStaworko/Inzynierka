import 'package:drift/drift.dart';

// Tabela Kategorii
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50).unique()();
  TextColumn get type => text()(); // 'expense' lub 'income' (zapiszemy jako String)
  IntColumn get colorValue => integer()();
}

// Tabela Wydatków (Nagłówek paragonu)
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()(); // double
  DateTimeColumn get date => dateTime()();
  TextColumn get categoryName => text()(); // Prosta relacja do nazwy kategorii
}

// Tabela Pozycji na Paragonie (To co było Embedded)
class ExpenseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // KLUCZ OBCEY - Wskazuje do jakiego wydatku należy ta pozycja
  IntColumn get expenseId => integer().references(Expenses, #id, onDelete: KeyAction.cascade)(); 
  
  TextColumn get name => text()();
  TextColumn get rawId => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get categoryName => text().withDefault(const Constant('Inne'))();
}

// Tabela Przychodów
class Incomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
}

// Tabela Mapowania Produktów (Do uczenia się)
class ProductMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawId => text().unique()();
  TextColumn get knownName => text()();
  TextColumn get defaultCategory => text()();
}

// Wydatki Cykliczne (Szablony)
class RecurringExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get frequency => text()(); // np. 'monthly'
  DateTimeColumn get nextDueDate => dateTime()();
}

// Przychody Cykliczne (Szablony)
class RecurringIncomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get source => text()();
  TextColumn get frequency => text()();
  DateTimeColumn get nextDueDate => dateTime()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()(); 
  RealColumn get amountLimit => real()();
  TextColumn get period => text()(); 
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)(); 
}