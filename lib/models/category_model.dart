// Compatibility shim: re-export Drift-generated Category and provide CategoryType alias

export '../data/app_database.dart' show Category, CategoriesCompanion;

// Older code expected an enum CategoryType — provide a simple enum-like class
enum CategoryType { expense, income }

String categoryTypeToString(CategoryType t) => t == CategoryType.expense ? 'expense' : 'income';