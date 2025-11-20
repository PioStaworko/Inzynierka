// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryNameMeta =
      const VerificationMeta('categoryName');
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
      'category_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, amount, date, categoryName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
          _categoryNameMeta,
          categoryName.isAcceptableOrUnknown(
              data['category_name']!, _categoryNameMeta));
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      categoryName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_name'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryName;
  const Expense(
      {required this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.categoryName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['category_name'] = Variable<String>(categoryName);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      date: Value(date),
      categoryName: Value(categoryName),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'categoryName': serializer.toJson<String>(categoryName),
    };
  }

  Expense copyWith(
          {int? id,
          String? title,
          double? amount,
          DateTime? date,
          String? categoryName}) =>
      Expense(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        categoryName: categoryName ?? this.categoryName,
      );
  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, amount, date, categoryName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.categoryName == this.categoryName);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<String> title;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> categoryName;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.categoryName = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required double amount,
    required DateTime date,
    required String categoryName,
  })  : title = Value(title),
        amount = Value(amount),
        date = Value(date),
        categoryName = Value(categoryName);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? categoryName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (categoryName != null) 'category_name': categoryName,
    });
  }

  ExpensesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<String>? categoryName}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }
}

class $ExpenseItemsTable extends ExpenseItems
    with TableInfo<$ExpenseItemsTable, ExpenseItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _expenseIdMeta =
      const VerificationMeta('expenseId');
  @override
  late final GeneratedColumn<int> expenseId = GeneratedColumn<int>(
      'expense_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES expenses (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawIdMeta = const VerificationMeta('rawId');
  @override
  late final GeneratedColumn<String> rawId = GeneratedColumn<String>(
      'raw_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryNameMeta =
      const VerificationMeta('categoryName');
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
      'category_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Inne'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, expenseId, name, rawId, amount, categoryName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_items';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('expense_id')) {
      context.handle(_expenseIdMeta,
          expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta));
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('raw_id')) {
      context.handle(
          _rawIdMeta, rawId.isAcceptableOrUnknown(data['raw_id']!, _rawIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
          _categoryNameMeta,
          categoryName.isAcceptableOrUnknown(
              data['category_name']!, _categoryNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      expenseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expense_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      rawId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      categoryName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_name'])!,
    );
  }

  @override
  $ExpenseItemsTable createAlias(String alias) {
    return $ExpenseItemsTable(attachedDatabase, alias);
  }
}

class ExpenseItem extends DataClass implements Insertable<ExpenseItem> {
  final int id;
  final int expenseId;
  final String name;
  final String? rawId;
  final double amount;
  final String categoryName;
  const ExpenseItem(
      {required this.id,
      required this.expenseId,
      required this.name,
      this.rawId,
      required this.amount,
      required this.categoryName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['expense_id'] = Variable<int>(expenseId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || rawId != null) {
      map['raw_id'] = Variable<String>(rawId);
    }
    map['amount'] = Variable<double>(amount);
    map['category_name'] = Variable<String>(categoryName);
    return map;
  }

  ExpenseItemsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseItemsCompanion(
      id: Value(id),
      expenseId: Value(expenseId),
      name: Value(name),
      rawId:
          rawId == null && nullToAbsent ? const Value.absent() : Value(rawId),
      amount: Value(amount),
      categoryName: Value(categoryName),
    );
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseItem(
      id: serializer.fromJson<int>(json['id']),
      expenseId: serializer.fromJson<int>(json['expenseId']),
      name: serializer.fromJson<String>(json['name']),
      rawId: serializer.fromJson<String?>(json['rawId']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'expenseId': serializer.toJson<int>(expenseId),
      'name': serializer.toJson<String>(name),
      'rawId': serializer.toJson<String?>(rawId),
      'amount': serializer.toJson<double>(amount),
      'categoryName': serializer.toJson<String>(categoryName),
    };
  }

  ExpenseItem copyWith(
          {int? id,
          int? expenseId,
          String? name,
          Value<String?> rawId = const Value.absent(),
          double? amount,
          String? categoryName}) =>
      ExpenseItem(
        id: id ?? this.id,
        expenseId: expenseId ?? this.expenseId,
        name: name ?? this.name,
        rawId: rawId.present ? rawId.value : this.rawId,
        amount: amount ?? this.amount,
        categoryName: categoryName ?? this.categoryName,
      );
  @override
  String toString() {
    return (StringBuffer('ExpenseItem(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('name: $name, ')
          ..write('rawId: $rawId, ')
          ..write('amount: $amount, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, expenseId, name, rawId, amount, categoryName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseItem &&
          other.id == this.id &&
          other.expenseId == this.expenseId &&
          other.name == this.name &&
          other.rawId == this.rawId &&
          other.amount == this.amount &&
          other.categoryName == this.categoryName);
}

class ExpenseItemsCompanion extends UpdateCompanion<ExpenseItem> {
  final Value<int> id;
  final Value<int> expenseId;
  final Value<String> name;
  final Value<String?> rawId;
  final Value<double> amount;
  final Value<String> categoryName;
  const ExpenseItemsCompanion({
    this.id = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.name = const Value.absent(),
    this.rawId = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryName = const Value.absent(),
  });
  ExpenseItemsCompanion.insert({
    this.id = const Value.absent(),
    required int expenseId,
    required String name,
    this.rawId = const Value.absent(),
    required double amount,
    this.categoryName = const Value.absent(),
  })  : expenseId = Value(expenseId),
        name = Value(name),
        amount = Value(amount);
  static Insertable<ExpenseItem> custom({
    Expression<int>? id,
    Expression<int>? expenseId,
    Expression<String>? name,
    Expression<String>? rawId,
    Expression<double>? amount,
    Expression<String>? categoryName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expenseId != null) 'expense_id': expenseId,
      if (name != null) 'name': name,
      if (rawId != null) 'raw_id': rawId,
      if (amount != null) 'amount': amount,
      if (categoryName != null) 'category_name': categoryName,
    });
  }

  ExpenseItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? expenseId,
      Value<String>? name,
      Value<String?>? rawId,
      Value<double>? amount,
      Value<String>? categoryName}) {
    return ExpenseItemsCompanion(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      name: name ?? this.name,
      rawId: rawId ?? this.rawId,
      amount: amount ?? this.amount,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<int>(expenseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rawId.present) {
      map['raw_id'] = Variable<String>(rawId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseItemsCompanion(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('name: $name, ')
          ..write('rawId: $rawId, ')
          ..write('amount: $amount, ')
          ..write('categoryName: $categoryName')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, type, colorValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String type;
  final int colorValue;
  const Category(
      {required this.id,
      required this.name,
      required this.type,
      required this.colorValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['color_value'] = Variable<int>(colorValue);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      colorValue: Value(colorValue),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'colorValue': serializer.toJson<int>(colorValue),
    };
  }

  Category copyWith({int? id, String? name, String? type, int? colorValue}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        colorValue: colorValue ?? this.colorValue,
      );
  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, colorValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.colorValue == this.colorValue);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> colorValue;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.colorValue = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    required int colorValue,
  })  : name = Value(name),
        type = Value(type),
        colorValue = Value(colorValue);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? colorValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (colorValue != null) 'color_value': colorValue,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? type,
      Value<int>? colorValue}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }
}

class $IncomesTable extends Incomes with TableInfo<$IncomesTable, Income> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, amount, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes';
  @override
  VerificationContext validateIntegrity(Insertable<Income> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Income map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Income(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $IncomesTable createAlias(String alias) {
    return $IncomesTable(attachedDatabase, alias);
  }
}

class Income extends DataClass implements Insertable<Income> {
  final int id;
  final String title;
  final double amount;
  final DateTime date;
  const Income(
      {required this.id,
      required this.title,
      required this.amount,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  IncomesCompanion toCompanion(bool nullToAbsent) {
    return IncomesCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      date: Value(date),
    );
  }

  factory Income.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Income(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  Income copyWith({int? id, String? title, double? amount, DateTime? date}) =>
      Income(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('Income(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, amount, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Income &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.date == this.date);
}

class IncomesCompanion extends UpdateCompanion<Income> {
  final Value<int> id;
  final Value<String> title;
  final Value<double> amount;
  final Value<DateTime> date;
  const IncomesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
  });
  IncomesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required double amount,
    required DateTime date,
  })  : title = Value(title),
        amount = Value(amount),
        date = Value(date);
  static Insertable<Income> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
    });
  }

  IncomesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<double>? amount,
      Value<DateTime>? date}) {
    return IncomesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $ProductMappingsTable extends ProductMappings
    with TableInfo<$ProductMappingsTable, ProductMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rawIdMeta = const VerificationMeta('rawId');
  @override
  late final GeneratedColumn<String> rawId = GeneratedColumn<String>(
      'raw_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _knownNameMeta =
      const VerificationMeta('knownName');
  @override
  late final GeneratedColumn<String> knownName = GeneratedColumn<String>(
      'known_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultCategoryMeta =
      const VerificationMeta('defaultCategory');
  @override
  late final GeneratedColumn<String> defaultCategory = GeneratedColumn<String>(
      'default_category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, rawId, knownName, defaultCategory];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_mappings';
  @override
  VerificationContext validateIntegrity(Insertable<ProductMapping> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_id')) {
      context.handle(
          _rawIdMeta, rawId.isAcceptableOrUnknown(data['raw_id']!, _rawIdMeta));
    } else if (isInserting) {
      context.missing(_rawIdMeta);
    }
    if (data.containsKey('known_name')) {
      context.handle(_knownNameMeta,
          knownName.isAcceptableOrUnknown(data['known_name']!, _knownNameMeta));
    } else if (isInserting) {
      context.missing(_knownNameMeta);
    }
    if (data.containsKey('default_category')) {
      context.handle(
          _defaultCategoryMeta,
          defaultCategory.isAcceptableOrUnknown(
              data['default_category']!, _defaultCategoryMeta));
    } else if (isInserting) {
      context.missing(_defaultCategoryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductMapping(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rawId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_id'])!,
      knownName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}known_name'])!,
      defaultCategory: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_category'])!,
    );
  }

  @override
  $ProductMappingsTable createAlias(String alias) {
    return $ProductMappingsTable(attachedDatabase, alias);
  }
}

class ProductMapping extends DataClass implements Insertable<ProductMapping> {
  final int id;
  final String rawId;
  final String knownName;
  final String defaultCategory;
  const ProductMapping(
      {required this.id,
      required this.rawId,
      required this.knownName,
      required this.defaultCategory});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_id'] = Variable<String>(rawId);
    map['known_name'] = Variable<String>(knownName);
    map['default_category'] = Variable<String>(defaultCategory);
    return map;
  }

  ProductMappingsCompanion toCompanion(bool nullToAbsent) {
    return ProductMappingsCompanion(
      id: Value(id),
      rawId: Value(rawId),
      knownName: Value(knownName),
      defaultCategory: Value(defaultCategory),
    );
  }

  factory ProductMapping.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductMapping(
      id: serializer.fromJson<int>(json['id']),
      rawId: serializer.fromJson<String>(json['rawId']),
      knownName: serializer.fromJson<String>(json['knownName']),
      defaultCategory: serializer.fromJson<String>(json['defaultCategory']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawId': serializer.toJson<String>(rawId),
      'knownName': serializer.toJson<String>(knownName),
      'defaultCategory': serializer.toJson<String>(defaultCategory),
    };
  }

  ProductMapping copyWith(
          {int? id,
          String? rawId,
          String? knownName,
          String? defaultCategory}) =>
      ProductMapping(
        id: id ?? this.id,
        rawId: rawId ?? this.rawId,
        knownName: knownName ?? this.knownName,
        defaultCategory: defaultCategory ?? this.defaultCategory,
      );
  @override
  String toString() {
    return (StringBuffer('ProductMapping(')
          ..write('id: $id, ')
          ..write('rawId: $rawId, ')
          ..write('knownName: $knownName, ')
          ..write('defaultCategory: $defaultCategory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rawId, knownName, defaultCategory);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductMapping &&
          other.id == this.id &&
          other.rawId == this.rawId &&
          other.knownName == this.knownName &&
          other.defaultCategory == this.defaultCategory);
}

class ProductMappingsCompanion extends UpdateCompanion<ProductMapping> {
  final Value<int> id;
  final Value<String> rawId;
  final Value<String> knownName;
  final Value<String> defaultCategory;
  const ProductMappingsCompanion({
    this.id = const Value.absent(),
    this.rawId = const Value.absent(),
    this.knownName = const Value.absent(),
    this.defaultCategory = const Value.absent(),
  });
  ProductMappingsCompanion.insert({
    this.id = const Value.absent(),
    required String rawId,
    required String knownName,
    required String defaultCategory,
  })  : rawId = Value(rawId),
        knownName = Value(knownName),
        defaultCategory = Value(defaultCategory);
  static Insertable<ProductMapping> custom({
    Expression<int>? id,
    Expression<String>? rawId,
    Expression<String>? knownName,
    Expression<String>? defaultCategory,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawId != null) 'raw_id': rawId,
      if (knownName != null) 'known_name': knownName,
      if (defaultCategory != null) 'default_category': defaultCategory,
    });
  }

  ProductMappingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? rawId,
      Value<String>? knownName,
      Value<String>? defaultCategory}) {
    return ProductMappingsCompanion(
      id: id ?? this.id,
      rawId: rawId ?? this.rawId,
      knownName: knownName ?? this.knownName,
      defaultCategory: defaultCategory ?? this.defaultCategory,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawId.present) {
      map['raw_id'] = Variable<String>(rawId.value);
    }
    if (knownName.present) {
      map['known_name'] = Variable<String>(knownName.value);
    }
    if (defaultCategory.present) {
      map['default_category'] = Variable<String>(defaultCategory.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductMappingsCompanion(')
          ..write('id: $id, ')
          ..write('rawId: $rawId, ')
          ..write('knownName: $knownName, ')
          ..write('defaultCategory: $defaultCategory')
          ..write(')'))
        .toString();
  }
}

class $RecurringExpensesTable extends RecurringExpenses
    with TableInfo<$RecurringExpensesTable, RecurringExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
      'next_due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, amount, category, frequency, nextDueDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_expenses';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringExpense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringExpense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      nextDueDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_due_date'])!,
    );
  }

  @override
  $RecurringExpensesTable createAlias(String alias) {
    return $RecurringExpensesTable(attachedDatabase, alias);
  }
}

class RecurringExpense extends DataClass
    implements Insertable<RecurringExpense> {
  final int id;
  final String title;
  final double amount;
  final String category;
  final String frequency;
  final DateTime nextDueDate;
  const RecurringExpense(
      {required this.id,
      required this.title,
      required this.amount,
      required this.category,
      required this.frequency,
      required this.nextDueDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    map['frequency'] = Variable<String>(frequency);
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    return map;
  }

  RecurringExpensesCompanion toCompanion(bool nullToAbsent) {
    return RecurringExpensesCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      category: Value(category),
      frequency: Value(frequency),
      nextDueDate: Value(nextDueDate),
    );
  }

  factory RecurringExpense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringExpense(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      frequency: serializer.fromJson<String>(json['frequency']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'frequency': serializer.toJson<String>(frequency),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
    };
  }

  RecurringExpense copyWith(
          {int? id,
          String? title,
          double? amount,
          String? category,
          String? frequency,
          DateTime? nextDueDate}) =>
      RecurringExpense(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        frequency: frequency ?? this.frequency,
        nextDueDate: nextDueDate ?? this.nextDueDate,
      );
  @override
  String toString() {
    return (StringBuffer('RecurringExpense(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, amount, category, frequency, nextDueDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringExpense &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.frequency == this.frequency &&
          other.nextDueDate == this.nextDueDate);
}

class RecurringExpensesCompanion extends UpdateCompanion<RecurringExpense> {
  final Value<int> id;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> category;
  final Value<String> frequency;
  final Value<DateTime> nextDueDate;
  const RecurringExpensesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
  });
  RecurringExpensesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required double amount,
    required String category,
    required String frequency,
    required DateTime nextDueDate,
  })  : title = Value(title),
        amount = Value(amount),
        category = Value(category),
        frequency = Value(frequency),
        nextDueDate = Value(nextDueDate);
  static Insertable<RecurringExpense> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? frequency,
    Expression<DateTime>? nextDueDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (frequency != null) 'frequency': frequency,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
    });
  }

  RecurringExpensesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<double>? amount,
      Value<String>? category,
      Value<String>? frequency,
      Value<DateTime>? nextDueDate}) {
    return RecurringExpensesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpensesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate')
          ..write(')'))
        .toString();
  }
}

class $RecurringIncomesTable extends RecurringIncomes
    with TableInfo<$RecurringIncomesTable, RecurringIncome> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringIncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
      'next_due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, amount, source, frequency, nextDueDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_incomes';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringIncome> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringIncome map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringIncome(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      nextDueDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_due_date'])!,
    );
  }

  @override
  $RecurringIncomesTable createAlias(String alias) {
    return $RecurringIncomesTable(attachedDatabase, alias);
  }
}

class RecurringIncome extends DataClass implements Insertable<RecurringIncome> {
  final int id;
  final String title;
  final double amount;
  final String source;
  final String frequency;
  final DateTime nextDueDate;
  const RecurringIncome(
      {required this.id,
      required this.title,
      required this.amount,
      required this.source,
      required this.frequency,
      required this.nextDueDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['source'] = Variable<String>(source);
    map['frequency'] = Variable<String>(frequency);
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    return map;
  }

  RecurringIncomesCompanion toCompanion(bool nullToAbsent) {
    return RecurringIncomesCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      source: Value(source),
      frequency: Value(frequency),
      nextDueDate: Value(nextDueDate),
    );
  }

  factory RecurringIncome.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringIncome(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      source: serializer.fromJson<String>(json['source']),
      frequency: serializer.fromJson<String>(json['frequency']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'source': serializer.toJson<String>(source),
      'frequency': serializer.toJson<String>(frequency),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
    };
  }

  RecurringIncome copyWith(
          {int? id,
          String? title,
          double? amount,
          String? source,
          String? frequency,
          DateTime? nextDueDate}) =>
      RecurringIncome(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        source: source ?? this.source,
        frequency: frequency ?? this.frequency,
        nextDueDate: nextDueDate ?? this.nextDueDate,
      );
  @override
  String toString() {
    return (StringBuffer('RecurringIncome(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('source: $source, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, amount, source, frequency, nextDueDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringIncome &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.source == this.source &&
          other.frequency == this.frequency &&
          other.nextDueDate == this.nextDueDate);
}

class RecurringIncomesCompanion extends UpdateCompanion<RecurringIncome> {
  final Value<int> id;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> source;
  final Value<String> frequency;
  final Value<DateTime> nextDueDate;
  const RecurringIncomesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.source = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
  });
  RecurringIncomesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required double amount,
    required String source,
    required String frequency,
    required DateTime nextDueDate,
  })  : title = Value(title),
        amount = Value(amount),
        source = Value(source),
        frequency = Value(frequency),
        nextDueDate = Value(nextDueDate);
  static Insertable<RecurringIncome> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? source,
    Expression<String>? frequency,
    Expression<DateTime>? nextDueDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (source != null) 'source': source,
      if (frequency != null) 'frequency': frequency,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
    });
  }

  RecurringIncomesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<double>? amount,
      Value<String>? source,
      Value<String>? frequency,
      Value<DateTime>? nextDueDate}) {
    return RecurringIncomesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringIncomesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('source: $source, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ExpenseItemsTable expenseItems = $ExpenseItemsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $IncomesTable incomes = $IncomesTable(this);
  late final $ProductMappingsTable productMappings =
      $ProductMappingsTable(this);
  late final $RecurringExpensesTable recurringExpenses =
      $RecurringExpensesTable(this);
  late final $RecurringIncomesTable recurringIncomes =
      $RecurringIncomesTable(this);
  late final ExpensesDao expensesDao = ExpensesDao(this as AppDb);
  late final IncomesDao incomesDao = IncomesDao(this as AppDb);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDb);
  late final RecurringDao recurringDao = RecurringDao(this as AppDb);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        expenses,
        expenseItems,
        categories,
        incomes,
        productMappings,
        recurringExpenses,
        recurringIncomes
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('expenses',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expense_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

mixin _$ExpensesDaoMixin on DatabaseAccessor<AppDb> {
  $ExpensesTable get expenses => attachedDatabase.expenses;
  $ExpenseItemsTable get expenseItems => attachedDatabase.expenseItems;
}
mixin _$IncomesDaoMixin on DatabaseAccessor<AppDb> {
  $IncomesTable get incomes => attachedDatabase.incomes;
}
mixin _$CategoriesDaoMixin on DatabaseAccessor<AppDb> {
  $CategoriesTable get categories => attachedDatabase.categories;
}
mixin _$RecurringDaoMixin on DatabaseAccessor<AppDb> {
  $RecurringExpensesTable get recurringExpenses =>
      attachedDatabase.recurringExpenses;
  $RecurringIncomesTable get recurringIncomes =>
      attachedDatabase.recurringIncomes;
  $ProductMappingsTable get productMappings => attachedDatabase.productMappings;
}
