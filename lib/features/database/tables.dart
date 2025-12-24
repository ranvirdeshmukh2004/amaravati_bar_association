import 'package:drift/drift.dart';

class Subscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get address => text()();
  TextColumn get mobileNumber => text()();
  TextColumn get email => text().nullable()();
  TextColumn get enrollmentNumber => text()();
  RealColumn get amount => real()();
  TextColumn get paymentMode => text()(); // Cash, UPI, Cheque, Bank Transfer
  TextColumn get transactionInfo => text().nullable()(); // Reference ID
  DateTimeColumn get subscriptionDate => dateTime()();
  TextColumn get receiptNumber => text().unique()();
}

class AdminSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Members extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get surname => text()();
  TextColumn get firstName => text()();
  TextColumn get middleName => text().nullable()();
  IntColumn get age => integer()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get bloodGroup => text().nullable()();
  DateTimeColumn get enrollmentDateAba => dateTime().nullable()();
  DateTimeColumn get enrollmentDateBar => dateTime().nullable()();
  TextColumn get registrationNumber => text().unique()();
  TextColumn get address => text()();
  TextColumn get mobileNumber => text()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class YearlySummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get enrollmentNumber => text()();
  TextColumn get financialYear => text()(); // e.g., "2024-2025"
  RealColumn get totalExpected => real()();
  RealColumn get totalPaid => real()();
  RealColumn get balance => real()();
  TextColumn get status => text()(); // "Paid" or "Due"
  DateTimeColumn get closedAt => dateTime().withDefault(currentDateAndTime)();
}
