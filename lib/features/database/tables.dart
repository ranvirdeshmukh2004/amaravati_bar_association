import 'package:drift/drift.dart';

class Subscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().nullable()(); // Stable unique ID
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUpdatedAt => dateTime().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get address => text()();
  TextColumn get mobileNumber => text()();
  TextColumn get email => text().nullable()();
  TextColumn get enrollmentNumber => text()();
  RealColumn get amount => real()();
  TextColumn get paymentMode => text()(); // Cash, UPI, Cheque, Bank Transfer
  TextColumn get transactionInfo => text().nullable()(); // Reference ID
  TextColumn get notes => text().nullable()();
  DateTimeColumn get subscriptionDate => dateTime()();
  TextColumn get receiptNumber => text().unique()();
  // New columns for Standardized Receipt Numbering (v10)
  TextColumn get receiptType => text().nullable()(); // SUB, ARR, CF, etc.
  IntColumn get dailySequence => integer().withDefault(const Constant(0))();
}

class AdminSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Members extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().nullable()(); // Stable unique ID
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUpdatedAt => dateTime().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
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
  TextColumn get memberStatus => text().withDefault(const Constant('Active'))();
  TextColumn get remarks => text().nullable()();
  TextColumn get profilePhotoPath => text().nullable()(); // Added for photo integration
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

class PastOutstandingDues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().nullable()(); // Stable unique ID
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUpdatedAt => dateTime().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get enrollmentNumber => text()();
  RealColumn get amount => real()();
  TextColumn get periodLabel => text()(); // e.g., "2020-2023" or "Oct-2023"
  TextColumn get type => text()(); // Subscription, Penalty, Donation, Manual
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Clearance fields (Schema v8)
  BoolColumn get isCleared => boolean().withDefault(const Constant(false))();
  DateTimeColumn get clearedAt => dateTime().nullable()();
  IntColumn get linkedPaymentId => integer().nullable()();
}

class Donations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().nullable()(); // Stable unique ID
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUpdatedAt => dateTime().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get donorName => text()();
  TextColumn get donorType => text()(); // 'Member' or 'Non-Member'
  IntColumn get memberId => integer().nullable()(); // Link to Members table if member
  RealColumn get amount => real()();
  DateTimeColumn get donationDate => dateTime()();
  TextColumn get paymentMode => text()();
  TextColumn get transactionRef => text().nullable()();
  TextColumn get purpose => text().nullable()();
  TextColumn get receiptNumber => text().unique()();
  // New columns for Standardized Receipt Numbering (v10)
  IntColumn get dailySequence => integer().withDefault(const Constant(0))();
  
  // New columns for Non-Member Details (v13)
  TextColumn get donorMobile => text().nullable()();
  TextColumn get donorEmail => text().nullable()();
  TextColumn get donorAddress => text().nullable()();
  TextColumn get organization => text().nullable()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
