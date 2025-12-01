import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:savings_app/data/app_database.dart';
import 'package:savings_app/providers/expenses_provider.dart';

void main() {
  late AppDb db;
  late ExpensesState state;

  setUp(() async {
    db = AppDb.test(NativeDatabase.memory());
    // Don't start listening immediately to avoid races — we'll start after inserting
    // the test data so the stream emits the current DB state.
    state = ExpensesState(ExpensesDao(db), BudgetsDao(db), CategoriesDao(db), startListening: false);
  });

  tearDown(() async {
    await db.close();
  });

  test('ExpensesState.addExpense inserts expense and notifies listeners', () async {
    final notified = Completer<void>();
    void listener() {
      if (!notified.isCompleted) notified.complete();
    }

    state.addListener(listener);

    // Insert before starting the stream so when we subscribe we'll receive the
    // current DB contents and trigger a notification.
    await state.addExpense(
      title: 'Taco',
      amount: 9.99,
      date: DateTime.now(),
      category: 'EatingOut',
      items: [],
    );

    // Now start listening — this will cause the DAO stream to emit the current rows
    // and the listener above to be invoked.
    state.start();

    // wait for the listener to be called by the DAO stream logic
    await notified.future.timeout(const Duration(seconds: 2));

    expect(state.recent.length, 1);
    final totals = state.totalsByCategory;
    expect(totals['EatingOut'], 9.99);

    state.removeListener(listener);
  });
}
