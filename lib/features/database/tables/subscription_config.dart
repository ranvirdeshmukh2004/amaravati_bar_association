import 'package:drift/drift.dart';

class SubscriptionConfig extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get monthlyAmount => real().withDefault(const Constant(100.0))();
  DateTimeColumn get subscriptionStartDate => dateTime().nullable()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();
      
  // Sync Fields
  TextColumn get uuid => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}
