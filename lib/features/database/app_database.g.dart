// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNumberMeta = const VerificationMeta(
    'mobileNumber',
  );
  @override
  late final GeneratedColumn<String> mobileNumber = GeneratedColumn<String>(
    'mobile_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enrollmentNumberMeta = const VerificationMeta(
    'enrollmentNumber',
  );
  @override
  late final GeneratedColumn<String> enrollmentNumber = GeneratedColumn<String>(
    'enrollment_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionInfoMeta = const VerificationMeta(
    'transactionInfo',
  );
  @override
  late final GeneratedColumn<String> transactionInfo = GeneratedColumn<String>(
    'transaction_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subscriptionDateMeta = const VerificationMeta(
    'subscriptionDate',
  );
  @override
  late final GeneratedColumn<DateTime> subscriptionDate =
      GeneratedColumn<DateTime>(
        'subscription_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receiptNumberMeta = const VerificationMeta(
    'receiptNumber',
  );
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
    'receipt_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _receiptTypeMeta = const VerificationMeta(
    'receiptType',
  );
  @override
  late final GeneratedColumn<String> receiptType = GeneratedColumn<String>(
    'receipt_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailySequenceMeta = const VerificationMeta(
    'dailySequence',
  );
  @override
  late final GeneratedColumn<int> dailySequence = GeneratedColumn<int>(
    'daily_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstName,
    lastName,
    address,
    mobileNumber,
    email,
    enrollmentNumber,
    amount,
    paymentMode,
    transactionInfo,
    notes,
    subscriptionDate,
    receiptNumber,
    receiptType,
    dailySequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subscription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('mobile_number')) {
      context.handle(
        _mobileNumberMeta,
        mobileNumber.isAcceptableOrUnknown(
          data['mobile_number']!,
          _mobileNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mobileNumberMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('enrollment_number')) {
      context.handle(
        _enrollmentNumberMeta,
        enrollmentNumber.isAcceptableOrUnknown(
          data['enrollment_number']!,
          _enrollmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentNumberMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('transaction_info')) {
      context.handle(
        _transactionInfoMeta,
        transactionInfo.isAcceptableOrUnknown(
          data['transaction_info']!,
          _transactionInfoMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('subscription_date')) {
      context.handle(
        _subscriptionDateMeta,
        subscriptionDate.isAcceptableOrUnknown(
          data['subscription_date']!,
          _subscriptionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriptionDateMeta);
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
        _receiptNumberMeta,
        receiptNumber.isAcceptableOrUnknown(
          data['receipt_number']!,
          _receiptNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receiptNumberMeta);
    }
    if (data.containsKey('receipt_type')) {
      context.handle(
        _receiptTypeMeta,
        receiptType.isAcceptableOrUnknown(
          data['receipt_type']!,
          _receiptTypeMeta,
        ),
      );
    }
    if (data.containsKey('daily_sequence')) {
      context.handle(
        _dailySequenceMeta,
        dailySequence.isAcceptableOrUnknown(
          data['daily_sequence']!,
          _dailySequenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      mobileNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_number'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      enrollmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enrollment_number'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      )!,
      transactionInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_info'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      subscriptionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscription_date'],
      )!,
      receiptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_number'],
      )!,
      receiptType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_type'],
      ),
      dailySequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_sequence'],
      )!,
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String mobileNumber;
  final String? email;
  final String enrollmentNumber;
  final double amount;
  final String paymentMode;
  final String? transactionInfo;
  final String? notes;
  final DateTime subscriptionDate;
  final String receiptNumber;
  final String? receiptType;
  final int dailySequence;
  const Subscription({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.mobileNumber,
    this.email,
    required this.enrollmentNumber,
    required this.amount,
    required this.paymentMode,
    this.transactionInfo,
    this.notes,
    required this.subscriptionDate,
    required this.receiptNumber,
    this.receiptType,
    required this.dailySequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['address'] = Variable<String>(address);
    map['mobile_number'] = Variable<String>(mobileNumber);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['enrollment_number'] = Variable<String>(enrollmentNumber);
    map['amount'] = Variable<double>(amount);
    map['payment_mode'] = Variable<String>(paymentMode);
    if (!nullToAbsent || transactionInfo != null) {
      map['transaction_info'] = Variable<String>(transactionInfo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['subscription_date'] = Variable<DateTime>(subscriptionDate);
    map['receipt_number'] = Variable<String>(receiptNumber);
    if (!nullToAbsent || receiptType != null) {
      map['receipt_type'] = Variable<String>(receiptType);
    }
    map['daily_sequence'] = Variable<int>(dailySequence);
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      address: Value(address),
      mobileNumber: Value(mobileNumber),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      enrollmentNumber: Value(enrollmentNumber),
      amount: Value(amount),
      paymentMode: Value(paymentMode),
      transactionInfo: transactionInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionInfo),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      subscriptionDate: Value(subscriptionDate),
      receiptNumber: Value(receiptNumber),
      receiptType: receiptType == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptType),
      dailySequence: Value(dailySequence),
    );
  }

  factory Subscription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<int>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      address: serializer.fromJson<String>(json['address']),
      mobileNumber: serializer.fromJson<String>(json['mobileNumber']),
      email: serializer.fromJson<String?>(json['email']),
      enrollmentNumber: serializer.fromJson<String>(json['enrollmentNumber']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      transactionInfo: serializer.fromJson<String?>(json['transactionInfo']),
      notes: serializer.fromJson<String?>(json['notes']),
      subscriptionDate: serializer.fromJson<DateTime>(json['subscriptionDate']),
      receiptNumber: serializer.fromJson<String>(json['receiptNumber']),
      receiptType: serializer.fromJson<String?>(json['receiptType']),
      dailySequence: serializer.fromJson<int>(json['dailySequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'address': serializer.toJson<String>(address),
      'mobileNumber': serializer.toJson<String>(mobileNumber),
      'email': serializer.toJson<String?>(email),
      'enrollmentNumber': serializer.toJson<String>(enrollmentNumber),
      'amount': serializer.toJson<double>(amount),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'transactionInfo': serializer.toJson<String?>(transactionInfo),
      'notes': serializer.toJson<String?>(notes),
      'subscriptionDate': serializer.toJson<DateTime>(subscriptionDate),
      'receiptNumber': serializer.toJson<String>(receiptNumber),
      'receiptType': serializer.toJson<String?>(receiptType),
      'dailySequence': serializer.toJson<int>(dailySequence),
    };
  }

  Subscription copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? address,
    String? mobileNumber,
    Value<String?> email = const Value.absent(),
    String? enrollmentNumber,
    double? amount,
    String? paymentMode,
    Value<String?> transactionInfo = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? subscriptionDate,
    String? receiptNumber,
    Value<String?> receiptType = const Value.absent(),
    int? dailySequence,
  }) => Subscription(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    address: address ?? this.address,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    email: email.present ? email.value : this.email,
    enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
    amount: amount ?? this.amount,
    paymentMode: paymentMode ?? this.paymentMode,
    transactionInfo: transactionInfo.present
        ? transactionInfo.value
        : this.transactionInfo,
    notes: notes.present ? notes.value : this.notes,
    subscriptionDate: subscriptionDate ?? this.subscriptionDate,
    receiptNumber: receiptNumber ?? this.receiptNumber,
    receiptType: receiptType.present ? receiptType.value : this.receiptType,
    dailySequence: dailySequence ?? this.dailySequence,
  );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      address: data.address.present ? data.address.value : this.address,
      mobileNumber: data.mobileNumber.present
          ? data.mobileNumber.value
          : this.mobileNumber,
      email: data.email.present ? data.email.value : this.email,
      enrollmentNumber: data.enrollmentNumber.present
          ? data.enrollmentNumber.value
          : this.enrollmentNumber,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
      transactionInfo: data.transactionInfo.present
          ? data.transactionInfo.value
          : this.transactionInfo,
      notes: data.notes.present ? data.notes.value : this.notes,
      subscriptionDate: data.subscriptionDate.present
          ? data.subscriptionDate.value
          : this.subscriptionDate,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
      receiptType: data.receiptType.present
          ? data.receiptType.value
          : this.receiptType,
      dailySequence: data.dailySequence.present
          ? data.dailySequence.value
          : this.dailySequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('email: $email, ')
          ..write('enrollmentNumber: $enrollmentNumber, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('transactionInfo: $transactionInfo, ')
          ..write('notes: $notes, ')
          ..write('subscriptionDate: $subscriptionDate, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('receiptType: $receiptType, ')
          ..write('dailySequence: $dailySequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    lastName,
    address,
    mobileNumber,
    email,
    enrollmentNumber,
    amount,
    paymentMode,
    transactionInfo,
    notes,
    subscriptionDate,
    receiptNumber,
    receiptType,
    dailySequence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.address == this.address &&
          other.mobileNumber == this.mobileNumber &&
          other.email == this.email &&
          other.enrollmentNumber == this.enrollmentNumber &&
          other.amount == this.amount &&
          other.paymentMode == this.paymentMode &&
          other.transactionInfo == this.transactionInfo &&
          other.notes == this.notes &&
          other.subscriptionDate == this.subscriptionDate &&
          other.receiptNumber == this.receiptNumber &&
          other.receiptType == this.receiptType &&
          other.dailySequence == this.dailySequence);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<int> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> address;
  final Value<String> mobileNumber;
  final Value<String?> email;
  final Value<String> enrollmentNumber;
  final Value<double> amount;
  final Value<String> paymentMode;
  final Value<String?> transactionInfo;
  final Value<String?> notes;
  final Value<DateTime> subscriptionDate;
  final Value<String> receiptNumber;
  final Value<String?> receiptType;
  final Value<int> dailySequence;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.enrollmentNumber = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.transactionInfo = const Value.absent(),
    this.notes = const Value.absent(),
    this.subscriptionDate = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.receiptType = const Value.absent(),
    this.dailySequence = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    required String lastName,
    required String address,
    required String mobileNumber,
    this.email = const Value.absent(),
    required String enrollmentNumber,
    required double amount,
    required String paymentMode,
    this.transactionInfo = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime subscriptionDate,
    required String receiptNumber,
    this.receiptType = const Value.absent(),
    this.dailySequence = const Value.absent(),
  }) : firstName = Value(firstName),
       lastName = Value(lastName),
       address = Value(address),
       mobileNumber = Value(mobileNumber),
       enrollmentNumber = Value(enrollmentNumber),
       amount = Value(amount),
       paymentMode = Value(paymentMode),
       subscriptionDate = Value(subscriptionDate),
       receiptNumber = Value(receiptNumber);
  static Insertable<Subscription> custom({
    Expression<int>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? address,
    Expression<String>? mobileNumber,
    Expression<String>? email,
    Expression<String>? enrollmentNumber,
    Expression<double>? amount,
    Expression<String>? paymentMode,
    Expression<String>? transactionInfo,
    Expression<String>? notes,
    Expression<DateTime>? subscriptionDate,
    Expression<String>? receiptNumber,
    Expression<String>? receiptType,
    Expression<int>? dailySequence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (address != null) 'address': address,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (email != null) 'email': email,
      if (enrollmentNumber != null) 'enrollment_number': enrollmentNumber,
      if (amount != null) 'amount': amount,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (transactionInfo != null) 'transaction_info': transactionInfo,
      if (notes != null) 'notes': notes,
      if (subscriptionDate != null) 'subscription_date': subscriptionDate,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (receiptType != null) 'receipt_type': receiptType,
      if (dailySequence != null) 'daily_sequence': dailySequence,
    });
  }

  SubscriptionsCompanion copyWith({
    Value<int>? id,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? address,
    Value<String>? mobileNumber,
    Value<String?>? email,
    Value<String>? enrollmentNumber,
    Value<double>? amount,
    Value<String>? paymentMode,
    Value<String?>? transactionInfo,
    Value<String?>? notes,
    Value<DateTime>? subscriptionDate,
    Value<String>? receiptNumber,
    Value<String?>? receiptType,
    Value<int>? dailySequence,
  }) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      transactionInfo: transactionInfo ?? this.transactionInfo,
      notes: notes ?? this.notes,
      subscriptionDate: subscriptionDate ?? this.subscriptionDate,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      receiptType: receiptType ?? this.receiptType,
      dailySequence: dailySequence ?? this.dailySequence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (mobileNumber.present) {
      map['mobile_number'] = Variable<String>(mobileNumber.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (enrollmentNumber.present) {
      map['enrollment_number'] = Variable<String>(enrollmentNumber.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (transactionInfo.present) {
      map['transaction_info'] = Variable<String>(transactionInfo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (subscriptionDate.present) {
      map['subscription_date'] = Variable<DateTime>(subscriptionDate.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (receiptType.present) {
      map['receipt_type'] = Variable<String>(receiptType.value);
    }
    if (dailySequence.present) {
      map['daily_sequence'] = Variable<int>(dailySequence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('email: $email, ')
          ..write('enrollmentNumber: $enrollmentNumber, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('transactionInfo: $transactionInfo, ')
          ..write('notes: $notes, ')
          ..write('subscriptionDate: $subscriptionDate, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('receiptType: $receiptType, ')
          ..write('dailySequence: $dailySequence')
          ..write(')'))
        .toString();
  }
}

class $AdminSettingsTable extends AdminSettings
    with TableInfo<$AdminSettingsTable, AdminSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdminSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'admin_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdminSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AdminSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AdminSettingsTable createAlias(String alias) {
    return $AdminSettingsTable(attachedDatabase, alias);
  }
}

class AdminSetting extends DataClass implements Insertable<AdminSetting> {
  final String key;
  final String value;
  const AdminSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AdminSettingsCompanion toCompanion(bool nullToAbsent) {
    return AdminSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AdminSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AdminSetting copyWith({String? key, String? value}) =>
      AdminSetting(key: key ?? this.key, value: value ?? this.value);
  AdminSetting copyWithCompanion(AdminSettingsCompanion data) {
    return AdminSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AdminSettingsCompanion extends UpdateCompanion<AdminSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AdminSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdminSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AdminSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdminSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AdminSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdminSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bloodGroupMeta = const VerificationMeta(
    'bloodGroup',
  );
  @override
  late final GeneratedColumn<String> bloodGroup = GeneratedColumn<String>(
    'blood_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enrollmentDateAbaMeta = const VerificationMeta(
    'enrollmentDateAba',
  );
  @override
  late final GeneratedColumn<DateTime> enrollmentDateAba =
      GeneratedColumn<DateTime>(
        'enrollment_date_aba',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _enrollmentDateBarMeta = const VerificationMeta(
    'enrollmentDateBar',
  );
  @override
  late final GeneratedColumn<DateTime> enrollmentDateBar =
      GeneratedColumn<DateTime>(
        'enrollment_date_bar',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _registrationNumberMeta =
      const VerificationMeta('registrationNumber');
  @override
  late final GeneratedColumn<String> registrationNumber =
      GeneratedColumn<String>(
        'registration_number',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNumberMeta = const VerificationMeta(
    'mobileNumber',
  );
  @override
  late final GeneratedColumn<String> mobileNumber = GeneratedColumn<String>(
    'mobile_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberStatusMeta = const VerificationMeta(
    'memberStatus',
  );
  @override
  late final GeneratedColumn<String> memberStatus = GeneratedColumn<String>(
    'member_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Active'),
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profilePhotoPathMeta = const VerificationMeta(
    'profilePhotoPath',
  );
  @override
  late final GeneratedColumn<String> profilePhotoPath = GeneratedColumn<String>(
    'profile_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surname,
    firstName,
    middleName,
    age,
    dateOfBirth,
    bloodGroup,
    enrollmentDateAba,
    enrollmentDateBar,
    registrationNumber,
    address,
    mobileNumber,
    email,
    memberStatus,
    remarks,
    profilePhotoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<Member> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    } else if (isInserting) {
      context.missing(_surnameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('blood_group')) {
      context.handle(
        _bloodGroupMeta,
        bloodGroup.isAcceptableOrUnknown(data['blood_group']!, _bloodGroupMeta),
      );
    }
    if (data.containsKey('enrollment_date_aba')) {
      context.handle(
        _enrollmentDateAbaMeta,
        enrollmentDateAba.isAcceptableOrUnknown(
          data['enrollment_date_aba']!,
          _enrollmentDateAbaMeta,
        ),
      );
    }
    if (data.containsKey('enrollment_date_bar')) {
      context.handle(
        _enrollmentDateBarMeta,
        enrollmentDateBar.isAcceptableOrUnknown(
          data['enrollment_date_bar']!,
          _enrollmentDateBarMeta,
        ),
      );
    }
    if (data.containsKey('registration_number')) {
      context.handle(
        _registrationNumberMeta,
        registrationNumber.isAcceptableOrUnknown(
          data['registration_number']!,
          _registrationNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrationNumberMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('mobile_number')) {
      context.handle(
        _mobileNumberMeta,
        mobileNumber.isAcceptableOrUnknown(
          data['mobile_number']!,
          _mobileNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mobileNumberMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('member_status')) {
      context.handle(
        _memberStatusMeta,
        memberStatus.isAcceptableOrUnknown(
          data['member_status']!,
          _memberStatusMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('profile_photo_path')) {
      context.handle(
        _profilePhotoPathMeta,
        profilePhotoPath.isAcceptableOrUnknown(
          data['profile_photo_path']!,
          _profilePhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surname'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      ),
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      bloodGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_group'],
      ),
      enrollmentDateAba: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enrollment_date_aba'],
      ),
      enrollmentDateBar: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enrollment_date_bar'],
      ),
      registrationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_number'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      mobileNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_number'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      memberStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_status'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      profilePhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final int id;
  final String surname;
  final String firstName;
  final String? middleName;
  final int age;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final DateTime? enrollmentDateAba;
  final DateTime? enrollmentDateBar;
  final String registrationNumber;
  final String address;
  final String mobileNumber;
  final String? email;
  final String memberStatus;
  final String? remarks;
  final String? profilePhotoPath;
  final DateTime createdAt;
  const Member({
    required this.id,
    required this.surname,
    required this.firstName,
    this.middleName,
    required this.age,
    this.dateOfBirth,
    this.bloodGroup,
    this.enrollmentDateAba,
    this.enrollmentDateBar,
    required this.registrationNumber,
    required this.address,
    required this.mobileNumber,
    this.email,
    required this.memberStatus,
    this.remarks,
    this.profilePhotoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surname'] = Variable<String>(surname);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    map['age'] = Variable<int>(age);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || bloodGroup != null) {
      map['blood_group'] = Variable<String>(bloodGroup);
    }
    if (!nullToAbsent || enrollmentDateAba != null) {
      map['enrollment_date_aba'] = Variable<DateTime>(enrollmentDateAba);
    }
    if (!nullToAbsent || enrollmentDateBar != null) {
      map['enrollment_date_bar'] = Variable<DateTime>(enrollmentDateBar);
    }
    map['registration_number'] = Variable<String>(registrationNumber);
    map['address'] = Variable<String>(address);
    map['mobile_number'] = Variable<String>(mobileNumber);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['member_status'] = Variable<String>(memberStatus);
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || profilePhotoPath != null) {
      map['profile_photo_path'] = Variable<String>(profilePhotoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      surname: Value(surname),
      firstName: Value(firstName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      age: Value(age),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      bloodGroup: bloodGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodGroup),
      enrollmentDateAba: enrollmentDateAba == null && nullToAbsent
          ? const Value.absent()
          : Value(enrollmentDateAba),
      enrollmentDateBar: enrollmentDateBar == null && nullToAbsent
          ? const Value.absent()
          : Value(enrollmentDateBar),
      registrationNumber: Value(registrationNumber),
      address: Value(address),
      mobileNumber: Value(mobileNumber),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      memberStatus: Value(memberStatus),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      profilePhotoPath: profilePhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePhotoPath),
      createdAt: Value(createdAt),
    );
  }

  factory Member.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<int>(json['id']),
      surname: serializer.fromJson<String>(json['surname']),
      firstName: serializer.fromJson<String>(json['firstName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      age: serializer.fromJson<int>(json['age']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      bloodGroup: serializer.fromJson<String?>(json['bloodGroup']),
      enrollmentDateAba: serializer.fromJson<DateTime?>(
        json['enrollmentDateAba'],
      ),
      enrollmentDateBar: serializer.fromJson<DateTime?>(
        json['enrollmentDateBar'],
      ),
      registrationNumber: serializer.fromJson<String>(
        json['registrationNumber'],
      ),
      address: serializer.fromJson<String>(json['address']),
      mobileNumber: serializer.fromJson<String>(json['mobileNumber']),
      email: serializer.fromJson<String?>(json['email']),
      memberStatus: serializer.fromJson<String>(json['memberStatus']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      profilePhotoPath: serializer.fromJson<String?>(json['profilePhotoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surname': serializer.toJson<String>(surname),
      'firstName': serializer.toJson<String>(firstName),
      'middleName': serializer.toJson<String?>(middleName),
      'age': serializer.toJson<int>(age),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'bloodGroup': serializer.toJson<String?>(bloodGroup),
      'enrollmentDateAba': serializer.toJson<DateTime?>(enrollmentDateAba),
      'enrollmentDateBar': serializer.toJson<DateTime?>(enrollmentDateBar),
      'registrationNumber': serializer.toJson<String>(registrationNumber),
      'address': serializer.toJson<String>(address),
      'mobileNumber': serializer.toJson<String>(mobileNumber),
      'email': serializer.toJson<String?>(email),
      'memberStatus': serializer.toJson<String>(memberStatus),
      'remarks': serializer.toJson<String?>(remarks),
      'profilePhotoPath': serializer.toJson<String?>(profilePhotoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Member copyWith({
    int? id,
    String? surname,
    String? firstName,
    Value<String?> middleName = const Value.absent(),
    int? age,
    Value<DateTime?> dateOfBirth = const Value.absent(),
    Value<String?> bloodGroup = const Value.absent(),
    Value<DateTime?> enrollmentDateAba = const Value.absent(),
    Value<DateTime?> enrollmentDateBar = const Value.absent(),
    String? registrationNumber,
    String? address,
    String? mobileNumber,
    Value<String?> email = const Value.absent(),
    String? memberStatus,
    Value<String?> remarks = const Value.absent(),
    Value<String?> profilePhotoPath = const Value.absent(),
    DateTime? createdAt,
  }) => Member(
    id: id ?? this.id,
    surname: surname ?? this.surname,
    firstName: firstName ?? this.firstName,
    middleName: middleName.present ? middleName.value : this.middleName,
    age: age ?? this.age,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    bloodGroup: bloodGroup.present ? bloodGroup.value : this.bloodGroup,
    enrollmentDateAba: enrollmentDateAba.present
        ? enrollmentDateAba.value
        : this.enrollmentDateAba,
    enrollmentDateBar: enrollmentDateBar.present
        ? enrollmentDateBar.value
        : this.enrollmentDateBar,
    registrationNumber: registrationNumber ?? this.registrationNumber,
    address: address ?? this.address,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    email: email.present ? email.value : this.email,
    memberStatus: memberStatus ?? this.memberStatus,
    remarks: remarks.present ? remarks.value : this.remarks,
    profilePhotoPath: profilePhotoPath.present
        ? profilePhotoPath.value
        : this.profilePhotoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      surname: data.surname.present ? data.surname.value : this.surname,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      age: data.age.present ? data.age.value : this.age,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      bloodGroup: data.bloodGroup.present
          ? data.bloodGroup.value
          : this.bloodGroup,
      enrollmentDateAba: data.enrollmentDateAba.present
          ? data.enrollmentDateAba.value
          : this.enrollmentDateAba,
      enrollmentDateBar: data.enrollmentDateBar.present
          ? data.enrollmentDateBar.value
          : this.enrollmentDateBar,
      registrationNumber: data.registrationNumber.present
          ? data.registrationNumber.value
          : this.registrationNumber,
      address: data.address.present ? data.address.value : this.address,
      mobileNumber: data.mobileNumber.present
          ? data.mobileNumber.value
          : this.mobileNumber,
      email: data.email.present ? data.email.value : this.email,
      memberStatus: data.memberStatus.present
          ? data.memberStatus.value
          : this.memberStatus,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      profilePhotoPath: data.profilePhotoPath.present
          ? data.profilePhotoPath.value
          : this.profilePhotoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('surname: $surname, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('age: $age, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('enrollmentDateAba: $enrollmentDateAba, ')
          ..write('enrollmentDateBar: $enrollmentDateBar, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('address: $address, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('email: $email, ')
          ..write('memberStatus: $memberStatus, ')
          ..write('remarks: $remarks, ')
          ..write('profilePhotoPath: $profilePhotoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surname,
    firstName,
    middleName,
    age,
    dateOfBirth,
    bloodGroup,
    enrollmentDateAba,
    enrollmentDateBar,
    registrationNumber,
    address,
    mobileNumber,
    email,
    memberStatus,
    remarks,
    profilePhotoPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.surname == this.surname &&
          other.firstName == this.firstName &&
          other.middleName == this.middleName &&
          other.age == this.age &&
          other.dateOfBirth == this.dateOfBirth &&
          other.bloodGroup == this.bloodGroup &&
          other.enrollmentDateAba == this.enrollmentDateAba &&
          other.enrollmentDateBar == this.enrollmentDateBar &&
          other.registrationNumber == this.registrationNumber &&
          other.address == this.address &&
          other.mobileNumber == this.mobileNumber &&
          other.email == this.email &&
          other.memberStatus == this.memberStatus &&
          other.remarks == this.remarks &&
          other.profilePhotoPath == this.profilePhotoPath &&
          other.createdAt == this.createdAt);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<int> id;
  final Value<String> surname;
  final Value<String> firstName;
  final Value<String?> middleName;
  final Value<int> age;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> bloodGroup;
  final Value<DateTime?> enrollmentDateAba;
  final Value<DateTime?> enrollmentDateBar;
  final Value<String> registrationNumber;
  final Value<String> address;
  final Value<String> mobileNumber;
  final Value<String?> email;
  final Value<String> memberStatus;
  final Value<String?> remarks;
  final Value<String?> profilePhotoPath;
  final Value<DateTime> createdAt;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.surname = const Value.absent(),
    this.firstName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.age = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.enrollmentDateAba = const Value.absent(),
    this.enrollmentDateBar = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.memberStatus = const Value.absent(),
    this.remarks = const Value.absent(),
    this.profilePhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MembersCompanion.insert({
    this.id = const Value.absent(),
    required String surname,
    required String firstName,
    this.middleName = const Value.absent(),
    required int age,
    this.dateOfBirth = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.enrollmentDateAba = const Value.absent(),
    this.enrollmentDateBar = const Value.absent(),
    required String registrationNumber,
    required String address,
    required String mobileNumber,
    this.email = const Value.absent(),
    this.memberStatus = const Value.absent(),
    this.remarks = const Value.absent(),
    this.profilePhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : surname = Value(surname),
       firstName = Value(firstName),
       age = Value(age),
       registrationNumber = Value(registrationNumber),
       address = Value(address),
       mobileNumber = Value(mobileNumber);
  static Insertable<Member> custom({
    Expression<int>? id,
    Expression<String>? surname,
    Expression<String>? firstName,
    Expression<String>? middleName,
    Expression<int>? age,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? bloodGroup,
    Expression<DateTime>? enrollmentDateAba,
    Expression<DateTime>? enrollmentDateBar,
    Expression<String>? registrationNumber,
    Expression<String>? address,
    Expression<String>? mobileNumber,
    Expression<String>? email,
    Expression<String>? memberStatus,
    Expression<String>? remarks,
    Expression<String>? profilePhotoPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surname != null) 'surname': surname,
      if (firstName != null) 'first_name': firstName,
      if (middleName != null) 'middle_name': middleName,
      if (age != null) 'age': age,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (enrollmentDateAba != null) 'enrollment_date_aba': enrollmentDateAba,
      if (enrollmentDateBar != null) 'enrollment_date_bar': enrollmentDateBar,
      if (registrationNumber != null) 'registration_number': registrationNumber,
      if (address != null) 'address': address,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (email != null) 'email': email,
      if (memberStatus != null) 'member_status': memberStatus,
      if (remarks != null) 'remarks': remarks,
      if (profilePhotoPath != null) 'profile_photo_path': profilePhotoPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MembersCompanion copyWith({
    Value<int>? id,
    Value<String>? surname,
    Value<String>? firstName,
    Value<String?>? middleName,
    Value<int>? age,
    Value<DateTime?>? dateOfBirth,
    Value<String?>? bloodGroup,
    Value<DateTime?>? enrollmentDateAba,
    Value<DateTime?>? enrollmentDateBar,
    Value<String>? registrationNumber,
    Value<String>? address,
    Value<String>? mobileNumber,
    Value<String?>? email,
    Value<String>? memberStatus,
    Value<String?>? remarks,
    Value<String?>? profilePhotoPath,
    Value<DateTime>? createdAt,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      surname: surname ?? this.surname,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      enrollmentDateAba: enrollmentDateAba ?? this.enrollmentDateAba,
      enrollmentDateBar: enrollmentDateBar ?? this.enrollmentDateBar,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      address: address ?? this.address,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      memberStatus: memberStatus ?? this.memberStatus,
      remarks: remarks ?? this.remarks,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (bloodGroup.present) {
      map['blood_group'] = Variable<String>(bloodGroup.value);
    }
    if (enrollmentDateAba.present) {
      map['enrollment_date_aba'] = Variable<DateTime>(enrollmentDateAba.value);
    }
    if (enrollmentDateBar.present) {
      map['enrollment_date_bar'] = Variable<DateTime>(enrollmentDateBar.value);
    }
    if (registrationNumber.present) {
      map['registration_number'] = Variable<String>(registrationNumber.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (mobileNumber.present) {
      map['mobile_number'] = Variable<String>(mobileNumber.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (memberStatus.present) {
      map['member_status'] = Variable<String>(memberStatus.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (profilePhotoPath.present) {
      map['profile_photo_path'] = Variable<String>(profilePhotoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('surname: $surname, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('age: $age, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('enrollmentDateAba: $enrollmentDateAba, ')
          ..write('enrollmentDateBar: $enrollmentDateBar, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('address: $address, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('email: $email, ')
          ..write('memberStatus: $memberStatus, ')
          ..write('remarks: $remarks, ')
          ..write('profilePhotoPath: $profilePhotoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionConfigTable extends SubscriptionConfig
    with TableInfo<$SubscriptionConfigTable, SubscriptionConfigData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _monthlyAmountMeta = const VerificationMeta(
    'monthlyAmount',
  );
  @override
  late final GeneratedColumn<double> monthlyAmount = GeneratedColumn<double>(
    'monthly_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100.0),
  );
  static const VerificationMeta _subscriptionStartDateMeta =
      const VerificationMeta('subscriptionStartDate');
  @override
  late final GeneratedColumn<DateTime> subscriptionStartDate =
      GeneratedColumn<DateTime>(
        'subscription_start_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    monthlyAmount,
    subscriptionStartDate,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_config';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionConfigData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('monthly_amount')) {
      context.handle(
        _monthlyAmountMeta,
        monthlyAmount.isAcceptableOrUnknown(
          data['monthly_amount']!,
          _monthlyAmountMeta,
        ),
      );
    }
    if (data.containsKey('subscription_start_date')) {
      context.handle(
        _subscriptionStartDateMeta,
        subscriptionStartDate.isAcceptableOrUnknown(
          data['subscription_start_date']!,
          _subscriptionStartDateMeta,
        ),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionConfigData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionConfigData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      monthlyAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_amount'],
      )!,
      subscriptionStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscription_start_date'],
      ),
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $SubscriptionConfigTable createAlias(String alias) {
    return $SubscriptionConfigTable(attachedDatabase, alias);
  }
}

class SubscriptionConfigData extends DataClass
    implements Insertable<SubscriptionConfigData> {
  final int id;
  final double monthlyAmount;
  final DateTime? subscriptionStartDate;
  final DateTime lastUpdated;
  const SubscriptionConfigData({
    required this.id,
    required this.monthlyAmount,
    this.subscriptionStartDate,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['monthly_amount'] = Variable<double>(monthlyAmount);
    if (!nullToAbsent || subscriptionStartDate != null) {
      map['subscription_start_date'] = Variable<DateTime>(
        subscriptionStartDate,
      );
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  SubscriptionConfigCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionConfigCompanion(
      id: Value(id),
      monthlyAmount: Value(monthlyAmount),
      subscriptionStartDate: subscriptionStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionStartDate),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory SubscriptionConfigData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionConfigData(
      id: serializer.fromJson<int>(json['id']),
      monthlyAmount: serializer.fromJson<double>(json['monthlyAmount']),
      subscriptionStartDate: serializer.fromJson<DateTime?>(
        json['subscriptionStartDate'],
      ),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthlyAmount': serializer.toJson<double>(monthlyAmount),
      'subscriptionStartDate': serializer.toJson<DateTime?>(
        subscriptionStartDate,
      ),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  SubscriptionConfigData copyWith({
    int? id,
    double? monthlyAmount,
    Value<DateTime?> subscriptionStartDate = const Value.absent(),
    DateTime? lastUpdated,
  }) => SubscriptionConfigData(
    id: id ?? this.id,
    monthlyAmount: monthlyAmount ?? this.monthlyAmount,
    subscriptionStartDate: subscriptionStartDate.present
        ? subscriptionStartDate.value
        : this.subscriptionStartDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  SubscriptionConfigData copyWithCompanion(SubscriptionConfigCompanion data) {
    return SubscriptionConfigData(
      id: data.id.present ? data.id.value : this.id,
      monthlyAmount: data.monthlyAmount.present
          ? data.monthlyAmount.value
          : this.monthlyAmount,
      subscriptionStartDate: data.subscriptionStartDate.present
          ? data.subscriptionStartDate.value
          : this.subscriptionStartDate,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionConfigData(')
          ..write('id: $id, ')
          ..write('monthlyAmount: $monthlyAmount, ')
          ..write('subscriptionStartDate: $subscriptionStartDate, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, monthlyAmount, subscriptionStartDate, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionConfigData &&
          other.id == this.id &&
          other.monthlyAmount == this.monthlyAmount &&
          other.subscriptionStartDate == this.subscriptionStartDate &&
          other.lastUpdated == this.lastUpdated);
}

class SubscriptionConfigCompanion
    extends UpdateCompanion<SubscriptionConfigData> {
  final Value<int> id;
  final Value<double> monthlyAmount;
  final Value<DateTime?> subscriptionStartDate;
  final Value<DateTime> lastUpdated;
  const SubscriptionConfigCompanion({
    this.id = const Value.absent(),
    this.monthlyAmount = const Value.absent(),
    this.subscriptionStartDate = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  SubscriptionConfigCompanion.insert({
    this.id = const Value.absent(),
    this.monthlyAmount = const Value.absent(),
    this.subscriptionStartDate = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  static Insertable<SubscriptionConfigData> custom({
    Expression<int>? id,
    Expression<double>? monthlyAmount,
    Expression<DateTime>? subscriptionStartDate,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthlyAmount != null) 'monthly_amount': monthlyAmount,
      if (subscriptionStartDate != null)
        'subscription_start_date': subscriptionStartDate,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  SubscriptionConfigCompanion copyWith({
    Value<int>? id,
    Value<double>? monthlyAmount,
    Value<DateTime?>? subscriptionStartDate,
    Value<DateTime>? lastUpdated,
  }) {
    return SubscriptionConfigCompanion(
      id: id ?? this.id,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthlyAmount.present) {
      map['monthly_amount'] = Variable<double>(monthlyAmount.value);
    }
    if (subscriptionStartDate.present) {
      map['subscription_start_date'] = Variable<DateTime>(
        subscriptionStartDate.value,
      );
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionConfigCompanion(')
          ..write('id: $id, ')
          ..write('monthlyAmount: $monthlyAmount, ')
          ..write('subscriptionStartDate: $subscriptionStartDate, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $YearlySummariesTable extends YearlySummaries
    with TableInfo<$YearlySummariesTable, YearlySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YearlySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _enrollmentNumberMeta = const VerificationMeta(
    'enrollmentNumber',
  );
  @override
  late final GeneratedColumn<String> enrollmentNumber = GeneratedColumn<String>(
    'enrollment_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _financialYearMeta = const VerificationMeta(
    'financialYear',
  );
  @override
  late final GeneratedColumn<String> financialYear = GeneratedColumn<String>(
    'financial_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalExpectedMeta = const VerificationMeta(
    'totalExpected',
  );
  @override
  late final GeneratedColumn<double> totalExpected = GeneratedColumn<double>(
    'total_expected',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPaidMeta = const VerificationMeta(
    'totalPaid',
  );
  @override
  late final GeneratedColumn<double> totalPaid = GeneratedColumn<double>(
    'total_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    enrollmentNumber,
    financialYear,
    totalExpected,
    totalPaid,
    balance,
    status,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'yearly_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<YearlySummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enrollment_number')) {
      context.handle(
        _enrollmentNumberMeta,
        enrollmentNumber.isAcceptableOrUnknown(
          data['enrollment_number']!,
          _enrollmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentNumberMeta);
    }
    if (data.containsKey('financial_year')) {
      context.handle(
        _financialYearMeta,
        financialYear.isAcceptableOrUnknown(
          data['financial_year']!,
          _financialYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialYearMeta);
    }
    if (data.containsKey('total_expected')) {
      context.handle(
        _totalExpectedMeta,
        totalExpected.isAcceptableOrUnknown(
          data['total_expected']!,
          _totalExpectedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalExpectedMeta);
    }
    if (data.containsKey('total_paid')) {
      context.handle(
        _totalPaidMeta,
        totalPaid.isAcceptableOrUnknown(data['total_paid']!, _totalPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPaidMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  YearlySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YearlySummary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enrollmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enrollment_number'],
      )!,
      financialYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_year'],
      )!,
      totalExpected: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_expected'],
      )!,
      totalPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_paid'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      )!,
    );
  }

  @override
  $YearlySummariesTable createAlias(String alias) {
    return $YearlySummariesTable(attachedDatabase, alias);
  }
}

class YearlySummary extends DataClass implements Insertable<YearlySummary> {
  final int id;
  final String enrollmentNumber;
  final String financialYear;
  final double totalExpected;
  final double totalPaid;
  final double balance;
  final String status;
  final DateTime closedAt;
  const YearlySummary({
    required this.id,
    required this.enrollmentNumber,
    required this.financialYear,
    required this.totalExpected,
    required this.totalPaid,
    required this.balance,
    required this.status,
    required this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enrollment_number'] = Variable<String>(enrollmentNumber);
    map['financial_year'] = Variable<String>(financialYear);
    map['total_expected'] = Variable<double>(totalExpected);
    map['total_paid'] = Variable<double>(totalPaid);
    map['balance'] = Variable<double>(balance);
    map['status'] = Variable<String>(status);
    map['closed_at'] = Variable<DateTime>(closedAt);
    return map;
  }

  YearlySummariesCompanion toCompanion(bool nullToAbsent) {
    return YearlySummariesCompanion(
      id: Value(id),
      enrollmentNumber: Value(enrollmentNumber),
      financialYear: Value(financialYear),
      totalExpected: Value(totalExpected),
      totalPaid: Value(totalPaid),
      balance: Value(balance),
      status: Value(status),
      closedAt: Value(closedAt),
    );
  }

  factory YearlySummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YearlySummary(
      id: serializer.fromJson<int>(json['id']),
      enrollmentNumber: serializer.fromJson<String>(json['enrollmentNumber']),
      financialYear: serializer.fromJson<String>(json['financialYear']),
      totalExpected: serializer.fromJson<double>(json['totalExpected']),
      totalPaid: serializer.fromJson<double>(json['totalPaid']),
      balance: serializer.fromJson<double>(json['balance']),
      status: serializer.fromJson<String>(json['status']),
      closedAt: serializer.fromJson<DateTime>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enrollmentNumber': serializer.toJson<String>(enrollmentNumber),
      'financialYear': serializer.toJson<String>(financialYear),
      'totalExpected': serializer.toJson<double>(totalExpected),
      'totalPaid': serializer.toJson<double>(totalPaid),
      'balance': serializer.toJson<double>(balance),
      'status': serializer.toJson<String>(status),
      'closedAt': serializer.toJson<DateTime>(closedAt),
    };
  }

  YearlySummary copyWith({
    int? id,
    String? enrollmentNumber,
    String? financialYear,
    double? totalExpected,
    double? totalPaid,
    double? balance,
    String? status,
    DateTime? closedAt,
  }) => YearlySummary(
    id: id ?? this.id,
    enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
    financialYear: financialYear ?? this.financialYear,
    totalExpected: totalExpected ?? this.totalExpected,
    totalPaid: totalPaid ?? this.totalPaid,
    balance: balance ?? this.balance,
    status: status ?? this.status,
    closedAt: closedAt ?? this.closedAt,
  );
  YearlySummary copyWithCompanion(YearlySummariesCompanion data) {
    return YearlySummary(
      id: data.id.present ? data.id.value : this.id,
      enrollmentNumber: data.enrollmentNumber.present
          ? data.enrollmentNumber.value
          : this.enrollmentNumber,
      financialYear: data.financialYear.present
          ? data.financialYear.value
          : this.financialYear,
      totalExpected: data.totalExpected.present
          ? data.totalExpected.value
          : this.totalExpected,
      totalPaid: data.totalPaid.present ? data.totalPaid.value : this.totalPaid,
      balance: data.balance.present ? data.balance.value : this.balance,
      status: data.status.present ? data.status.value : this.status,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YearlySummary(')
          ..write('id: $id, ')
          ..write('enrollmentNumber: $enrollmentNumber, ')
          ..write('financialYear: $financialYear, ')
          ..write('totalExpected: $totalExpected, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('balance: $balance, ')
          ..write('status: $status, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    enrollmentNumber,
    financialYear,
    totalExpected,
    totalPaid,
    balance,
    status,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YearlySummary &&
          other.id == this.id &&
          other.enrollmentNumber == this.enrollmentNumber &&
          other.financialYear == this.financialYear &&
          other.totalExpected == this.totalExpected &&
          other.totalPaid == this.totalPaid &&
          other.balance == this.balance &&
          other.status == this.status &&
          other.closedAt == this.closedAt);
}

class YearlySummariesCompanion extends UpdateCompanion<YearlySummary> {
  final Value<int> id;
  final Value<String> enrollmentNumber;
  final Value<String> financialYear;
  final Value<double> totalExpected;
  final Value<double> totalPaid;
  final Value<double> balance;
  final Value<String> status;
  final Value<DateTime> closedAt;
  const YearlySummariesCompanion({
    this.id = const Value.absent(),
    this.enrollmentNumber = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.totalExpected = const Value.absent(),
    this.totalPaid = const Value.absent(),
    this.balance = const Value.absent(),
    this.status = const Value.absent(),
    this.closedAt = const Value.absent(),
  });
  YearlySummariesCompanion.insert({
    this.id = const Value.absent(),
    required String enrollmentNumber,
    required String financialYear,
    required double totalExpected,
    required double totalPaid,
    required double balance,
    required String status,
    this.closedAt = const Value.absent(),
  }) : enrollmentNumber = Value(enrollmentNumber),
       financialYear = Value(financialYear),
       totalExpected = Value(totalExpected),
       totalPaid = Value(totalPaid),
       balance = Value(balance),
       status = Value(status);
  static Insertable<YearlySummary> custom({
    Expression<int>? id,
    Expression<String>? enrollmentNumber,
    Expression<String>? financialYear,
    Expression<double>? totalExpected,
    Expression<double>? totalPaid,
    Expression<double>? balance,
    Expression<String>? status,
    Expression<DateTime>? closedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enrollmentNumber != null) 'enrollment_number': enrollmentNumber,
      if (financialYear != null) 'financial_year': financialYear,
      if (totalExpected != null) 'total_expected': totalExpected,
      if (totalPaid != null) 'total_paid': totalPaid,
      if (balance != null) 'balance': balance,
      if (status != null) 'status': status,
      if (closedAt != null) 'closed_at': closedAt,
    });
  }

  YearlySummariesCompanion copyWith({
    Value<int>? id,
    Value<String>? enrollmentNumber,
    Value<String>? financialYear,
    Value<double>? totalExpected,
    Value<double>? totalPaid,
    Value<double>? balance,
    Value<String>? status,
    Value<DateTime>? closedAt,
  }) {
    return YearlySummariesCompanion(
      id: id ?? this.id,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      financialYear: financialYear ?? this.financialYear,
      totalExpected: totalExpected ?? this.totalExpected,
      totalPaid: totalPaid ?? this.totalPaid,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enrollmentNumber.present) {
      map['enrollment_number'] = Variable<String>(enrollmentNumber.value);
    }
    if (financialYear.present) {
      map['financial_year'] = Variable<String>(financialYear.value);
    }
    if (totalExpected.present) {
      map['total_expected'] = Variable<double>(totalExpected.value);
    }
    if (totalPaid.present) {
      map['total_paid'] = Variable<double>(totalPaid.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YearlySummariesCompanion(')
          ..write('id: $id, ')
          ..write('enrollmentNumber: $enrollmentNumber, ')
          ..write('financialYear: $financialYear, ')
          ..write('totalExpected: $totalExpected, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('balance: $balance, ')
          ..write('status: $status, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }
}

class $PastOutstandingDuesTable extends PastOutstandingDues
    with TableInfo<$PastOutstandingDuesTable, PastOutstandingDue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PastOutstandingDuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _enrollmentNumberMeta = const VerificationMeta(
    'enrollmentNumber',
  );
  @override
  late final GeneratedColumn<String> enrollmentNumber = GeneratedColumn<String>(
    'enrollment_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodLabelMeta = const VerificationMeta(
    'periodLabel',
  );
  @override
  late final GeneratedColumn<String> periodLabel = GeneratedColumn<String>(
    'period_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isClearedMeta = const VerificationMeta(
    'isCleared',
  );
  @override
  late final GeneratedColumn<bool> isCleared = GeneratedColumn<bool>(
    'is_cleared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cleared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _clearedAtMeta = const VerificationMeta(
    'clearedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clearedAt = GeneratedColumn<DateTime>(
    'cleared_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedPaymentIdMeta = const VerificationMeta(
    'linkedPaymentId',
  );
  @override
  late final GeneratedColumn<int> linkedPaymentId = GeneratedColumn<int>(
    'linked_payment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    enrollmentNumber,
    amount,
    periodLabel,
    type,
    notes,
    createdAt,
    isCleared,
    clearedAt,
    linkedPaymentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'past_outstanding_dues';
  @override
  VerificationContext validateIntegrity(
    Insertable<PastOutstandingDue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enrollment_number')) {
      context.handle(
        _enrollmentNumberMeta,
        enrollmentNumber.isAcceptableOrUnknown(
          data['enrollment_number']!,
          _enrollmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentNumberMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period_label')) {
      context.handle(
        _periodLabelMeta,
        periodLabel.isAcceptableOrUnknown(
          data['period_label']!,
          _periodLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodLabelMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_cleared')) {
      context.handle(
        _isClearedMeta,
        isCleared.isAcceptableOrUnknown(data['is_cleared']!, _isClearedMeta),
      );
    }
    if (data.containsKey('cleared_at')) {
      context.handle(
        _clearedAtMeta,
        clearedAt.isAcceptableOrUnknown(data['cleared_at']!, _clearedAtMeta),
      );
    }
    if (data.containsKey('linked_payment_id')) {
      context.handle(
        _linkedPaymentIdMeta,
        linkedPaymentId.isAcceptableOrUnknown(
          data['linked_payment_id']!,
          _linkedPaymentIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PastOutstandingDue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PastOutstandingDue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enrollmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enrollment_number'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      periodLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_label'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isCleared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cleared'],
      )!,
      clearedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cleared_at'],
      ),
      linkedPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_payment_id'],
      ),
    );
  }

  @override
  $PastOutstandingDuesTable createAlias(String alias) {
    return $PastOutstandingDuesTable(attachedDatabase, alias);
  }
}

class PastOutstandingDue extends DataClass
    implements Insertable<PastOutstandingDue> {
  final int id;
  final String enrollmentNumber;
  final double amount;
  final String periodLabel;
  final String type;
  final String? notes;
  final DateTime createdAt;
  final bool isCleared;
  final DateTime? clearedAt;
  final int? linkedPaymentId;
  const PastOutstandingDue({
    required this.id,
    required this.enrollmentNumber,
    required this.amount,
    required this.periodLabel,
    required this.type,
    this.notes,
    required this.createdAt,
    required this.isCleared,
    this.clearedAt,
    this.linkedPaymentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enrollment_number'] = Variable<String>(enrollmentNumber);
    map['amount'] = Variable<double>(amount);
    map['period_label'] = Variable<String>(periodLabel);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_cleared'] = Variable<bool>(isCleared);
    if (!nullToAbsent || clearedAt != null) {
      map['cleared_at'] = Variable<DateTime>(clearedAt);
    }
    if (!nullToAbsent || linkedPaymentId != null) {
      map['linked_payment_id'] = Variable<int>(linkedPaymentId);
    }
    return map;
  }

  PastOutstandingDuesCompanion toCompanion(bool nullToAbsent) {
    return PastOutstandingDuesCompanion(
      id: Value(id),
      enrollmentNumber: Value(enrollmentNumber),
      amount: Value(amount),
      periodLabel: Value(periodLabel),
      type: Value(type),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      isCleared: Value(isCleared),
      clearedAt: clearedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(clearedAt),
      linkedPaymentId: linkedPaymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedPaymentId),
    );
  }

  factory PastOutstandingDue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PastOutstandingDue(
      id: serializer.fromJson<int>(json['id']),
      enrollmentNumber: serializer.fromJson<String>(json['enrollmentNumber']),
      amount: serializer.fromJson<double>(json['amount']),
      periodLabel: serializer.fromJson<String>(json['periodLabel']),
      type: serializer.fromJson<String>(json['type']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isCleared: serializer.fromJson<bool>(json['isCleared']),
      clearedAt: serializer.fromJson<DateTime?>(json['clearedAt']),
      linkedPaymentId: serializer.fromJson<int?>(json['linkedPaymentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enrollmentNumber': serializer.toJson<String>(enrollmentNumber),
      'amount': serializer.toJson<double>(amount),
      'periodLabel': serializer.toJson<String>(periodLabel),
      'type': serializer.toJson<String>(type),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isCleared': serializer.toJson<bool>(isCleared),
      'clearedAt': serializer.toJson<DateTime?>(clearedAt),
      'linkedPaymentId': serializer.toJson<int?>(linkedPaymentId),
    };
  }

  PastOutstandingDue copyWith({
    int? id,
    String? enrollmentNumber,
    double? amount,
    String? periodLabel,
    String? type,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    bool? isCleared,
    Value<DateTime?> clearedAt = const Value.absent(),
    Value<int?> linkedPaymentId = const Value.absent(),
  }) => PastOutstandingDue(
    id: id ?? this.id,
    enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
    amount: amount ?? this.amount,
    periodLabel: periodLabel ?? this.periodLabel,
    type: type ?? this.type,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    isCleared: isCleared ?? this.isCleared,
    clearedAt: clearedAt.present ? clearedAt.value : this.clearedAt,
    linkedPaymentId: linkedPaymentId.present
        ? linkedPaymentId.value
        : this.linkedPaymentId,
  );
  PastOutstandingDue copyWithCompanion(PastOutstandingDuesCompanion data) {
    return PastOutstandingDue(
      id: data.id.present ? data.id.value : this.id,
      enrollmentNumber: data.enrollmentNumber.present
          ? data.enrollmentNumber.value
          : this.enrollmentNumber,
      amount: data.amount.present ? data.amount.value : this.amount,
      periodLabel: data.periodLabel.present
          ? data.periodLabel.value
          : this.periodLabel,
      type: data.type.present ? data.type.value : this.type,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isCleared: data.isCleared.present ? data.isCleared.value : this.isCleared,
      clearedAt: data.clearedAt.present ? data.clearedAt.value : this.clearedAt,
      linkedPaymentId: data.linkedPaymentId.present
          ? data.linkedPaymentId.value
          : this.linkedPaymentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PastOutstandingDue(')
          ..write('id: $id, ')
          ..write('enrollmentNumber: $enrollmentNumber, ')
          ..write('amount: $amount, ')
          ..write('periodLabel: $periodLabel, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCleared: $isCleared, ')
          ..write('clearedAt: $clearedAt, ')
          ..write('linkedPaymentId: $linkedPaymentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    enrollmentNumber,
    amount,
    periodLabel,
    type,
    notes,
    createdAt,
    isCleared,
    clearedAt,
    linkedPaymentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PastOutstandingDue &&
          other.id == this.id &&
          other.enrollmentNumber == this.enrollmentNumber &&
          other.amount == this.amount &&
          other.periodLabel == this.periodLabel &&
          other.type == this.type &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.isCleared == this.isCleared &&
          other.clearedAt == this.clearedAt &&
          other.linkedPaymentId == this.linkedPaymentId);
}

class PastOutstandingDuesCompanion extends UpdateCompanion<PastOutstandingDue> {
  final Value<int> id;
  final Value<String> enrollmentNumber;
  final Value<double> amount;
  final Value<String> periodLabel;
  final Value<String> type;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<bool> isCleared;
  final Value<DateTime?> clearedAt;
  final Value<int?> linkedPaymentId;
  const PastOutstandingDuesCompanion({
    this.id = const Value.absent(),
    this.enrollmentNumber = const Value.absent(),
    this.amount = const Value.absent(),
    this.periodLabel = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCleared = const Value.absent(),
    this.clearedAt = const Value.absent(),
    this.linkedPaymentId = const Value.absent(),
  });
  PastOutstandingDuesCompanion.insert({
    this.id = const Value.absent(),
    required String enrollmentNumber,
    required double amount,
    required String periodLabel,
    required String type,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCleared = const Value.absent(),
    this.clearedAt = const Value.absent(),
    this.linkedPaymentId = const Value.absent(),
  }) : enrollmentNumber = Value(enrollmentNumber),
       amount = Value(amount),
       periodLabel = Value(periodLabel),
       type = Value(type);
  static Insertable<PastOutstandingDue> custom({
    Expression<int>? id,
    Expression<String>? enrollmentNumber,
    Expression<double>? amount,
    Expression<String>? periodLabel,
    Expression<String>? type,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<bool>? isCleared,
    Expression<DateTime>? clearedAt,
    Expression<int>? linkedPaymentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enrollmentNumber != null) 'enrollment_number': enrollmentNumber,
      if (amount != null) 'amount': amount,
      if (periodLabel != null) 'period_label': periodLabel,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (isCleared != null) 'is_cleared': isCleared,
      if (clearedAt != null) 'cleared_at': clearedAt,
      if (linkedPaymentId != null) 'linked_payment_id': linkedPaymentId,
    });
  }

  PastOutstandingDuesCompanion copyWith({
    Value<int>? id,
    Value<String>? enrollmentNumber,
    Value<double>? amount,
    Value<String>? periodLabel,
    Value<String>? type,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<bool>? isCleared,
    Value<DateTime?>? clearedAt,
    Value<int?>? linkedPaymentId,
  }) {
    return PastOutstandingDuesCompanion(
      id: id ?? this.id,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      amount: amount ?? this.amount,
      periodLabel: periodLabel ?? this.periodLabel,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isCleared: isCleared ?? this.isCleared,
      clearedAt: clearedAt ?? this.clearedAt,
      linkedPaymentId: linkedPaymentId ?? this.linkedPaymentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enrollmentNumber.present) {
      map['enrollment_number'] = Variable<String>(enrollmentNumber.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (periodLabel.present) {
      map['period_label'] = Variable<String>(periodLabel.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isCleared.present) {
      map['is_cleared'] = Variable<bool>(isCleared.value);
    }
    if (clearedAt.present) {
      map['cleared_at'] = Variable<DateTime>(clearedAt.value);
    }
    if (linkedPaymentId.present) {
      map['linked_payment_id'] = Variable<int>(linkedPaymentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PastOutstandingDuesCompanion(')
          ..write('id: $id, ')
          ..write('enrollmentNumber: $enrollmentNumber, ')
          ..write('amount: $amount, ')
          ..write('periodLabel: $periodLabel, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCleared: $isCleared, ')
          ..write('clearedAt: $clearedAt, ')
          ..write('linkedPaymentId: $linkedPaymentId')
          ..write(')'))
        .toString();
  }
}

class $DonationsTable extends Donations
    with TableInfo<$DonationsTable, Donation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DonationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _donorNameMeta = const VerificationMeta(
    'donorName',
  );
  @override
  late final GeneratedColumn<String> donorName = GeneratedColumn<String>(
    'donor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _donorTypeMeta = const VerificationMeta(
    'donorType',
  );
  @override
  late final GeneratedColumn<String> donorType = GeneratedColumn<String>(
    'donor_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<int> memberId = GeneratedColumn<int>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _donationDateMeta = const VerificationMeta(
    'donationDate',
  );
  @override
  late final GeneratedColumn<DateTime> donationDate = GeneratedColumn<DateTime>(
    'donation_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionRefMeta = const VerificationMeta(
    'transactionRef',
  );
  @override
  late final GeneratedColumn<String> transactionRef = GeneratedColumn<String>(
    'transaction_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptNumberMeta = const VerificationMeta(
    'receiptNumber',
  );
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
    'receipt_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dailySequenceMeta = const VerificationMeta(
    'dailySequence',
  );
  @override
  late final GeneratedColumn<int> dailySequence = GeneratedColumn<int>(
    'daily_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _donorMobileMeta = const VerificationMeta(
    'donorMobile',
  );
  @override
  late final GeneratedColumn<String> donorMobile = GeneratedColumn<String>(
    'donor_mobile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _donorEmailMeta = const VerificationMeta(
    'donorEmail',
  );
  @override
  late final GeneratedColumn<String> donorEmail = GeneratedColumn<String>(
    'donor_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _donorAddressMeta = const VerificationMeta(
    'donorAddress',
  );
  @override
  late final GeneratedColumn<String> donorAddress = GeneratedColumn<String>(
    'donor_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _organizationMeta = const VerificationMeta(
    'organization',
  );
  @override
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
    'organization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    donorName,
    donorType,
    memberId,
    amount,
    donationDate,
    paymentMode,
    transactionRef,
    purpose,
    receiptNumber,
    dailySequence,
    donorMobile,
    donorEmail,
    donorAddress,
    organization,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'donations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Donation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('donor_name')) {
      context.handle(
        _donorNameMeta,
        donorName.isAcceptableOrUnknown(data['donor_name']!, _donorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_donorNameMeta);
    }
    if (data.containsKey('donor_type')) {
      context.handle(
        _donorTypeMeta,
        donorType.isAcceptableOrUnknown(data['donor_type']!, _donorTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_donorTypeMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('donation_date')) {
      context.handle(
        _donationDateMeta,
        donationDate.isAcceptableOrUnknown(
          data['donation_date']!,
          _donationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_donationDateMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('transaction_ref')) {
      context.handle(
        _transactionRefMeta,
        transactionRef.isAcceptableOrUnknown(
          data['transaction_ref']!,
          _transactionRefMeta,
        ),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
        _receiptNumberMeta,
        receiptNumber.isAcceptableOrUnknown(
          data['receipt_number']!,
          _receiptNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receiptNumberMeta);
    }
    if (data.containsKey('daily_sequence')) {
      context.handle(
        _dailySequenceMeta,
        dailySequence.isAcceptableOrUnknown(
          data['daily_sequence']!,
          _dailySequenceMeta,
        ),
      );
    }
    if (data.containsKey('donor_mobile')) {
      context.handle(
        _donorMobileMeta,
        donorMobile.isAcceptableOrUnknown(
          data['donor_mobile']!,
          _donorMobileMeta,
        ),
      );
    }
    if (data.containsKey('donor_email')) {
      context.handle(
        _donorEmailMeta,
        donorEmail.isAcceptableOrUnknown(data['donor_email']!, _donorEmailMeta),
      );
    }
    if (data.containsKey('donor_address')) {
      context.handle(
        _donorAddressMeta,
        donorAddress.isAcceptableOrUnknown(
          data['donor_address']!,
          _donorAddressMeta,
        ),
      );
    }
    if (data.containsKey('organization')) {
      context.handle(
        _organizationMeta,
        organization.isAcceptableOrUnknown(
          data['organization']!,
          _organizationMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Donation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Donation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      donorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}donor_name'],
      )!,
      donorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}donor_type'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}member_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      donationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}donation_date'],
      )!,
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      )!,
      transactionRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_ref'],
      ),
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      receiptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_number'],
      )!,
      dailySequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_sequence'],
      )!,
      donorMobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}donor_mobile'],
      ),
      donorEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}donor_email'],
      ),
      donorAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}donor_address'],
      ),
      organization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DonationsTable createAlias(String alias) {
    return $DonationsTable(attachedDatabase, alias);
  }
}

class Donation extends DataClass implements Insertable<Donation> {
  final int id;
  final String donorName;
  final String donorType;
  final int? memberId;
  final double amount;
  final DateTime donationDate;
  final String paymentMode;
  final String? transactionRef;
  final String? purpose;
  final String receiptNumber;
  final int dailySequence;
  final String? donorMobile;
  final String? donorEmail;
  final String? donorAddress;
  final String? organization;
  final DateTime createdAt;
  const Donation({
    required this.id,
    required this.donorName,
    required this.donorType,
    this.memberId,
    required this.amount,
    required this.donationDate,
    required this.paymentMode,
    this.transactionRef,
    this.purpose,
    required this.receiptNumber,
    required this.dailySequence,
    this.donorMobile,
    this.donorEmail,
    this.donorAddress,
    this.organization,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['donor_name'] = Variable<String>(donorName);
    map['donor_type'] = Variable<String>(donorType);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<int>(memberId);
    }
    map['amount'] = Variable<double>(amount);
    map['donation_date'] = Variable<DateTime>(donationDate);
    map['payment_mode'] = Variable<String>(paymentMode);
    if (!nullToAbsent || transactionRef != null) {
      map['transaction_ref'] = Variable<String>(transactionRef);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['receipt_number'] = Variable<String>(receiptNumber);
    map['daily_sequence'] = Variable<int>(dailySequence);
    if (!nullToAbsent || donorMobile != null) {
      map['donor_mobile'] = Variable<String>(donorMobile);
    }
    if (!nullToAbsent || donorEmail != null) {
      map['donor_email'] = Variable<String>(donorEmail);
    }
    if (!nullToAbsent || donorAddress != null) {
      map['donor_address'] = Variable<String>(donorAddress);
    }
    if (!nullToAbsent || organization != null) {
      map['organization'] = Variable<String>(organization);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DonationsCompanion toCompanion(bool nullToAbsent) {
    return DonationsCompanion(
      id: Value(id),
      donorName: Value(donorName),
      donorType: Value(donorType),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      amount: Value(amount),
      donationDate: Value(donationDate),
      paymentMode: Value(paymentMode),
      transactionRef: transactionRef == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionRef),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      receiptNumber: Value(receiptNumber),
      dailySequence: Value(dailySequence),
      donorMobile: donorMobile == null && nullToAbsent
          ? const Value.absent()
          : Value(donorMobile),
      donorEmail: donorEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(donorEmail),
      donorAddress: donorAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(donorAddress),
      organization: organization == null && nullToAbsent
          ? const Value.absent()
          : Value(organization),
      createdAt: Value(createdAt),
    );
  }

  factory Donation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Donation(
      id: serializer.fromJson<int>(json['id']),
      donorName: serializer.fromJson<String>(json['donorName']),
      donorType: serializer.fromJson<String>(json['donorType']),
      memberId: serializer.fromJson<int?>(json['memberId']),
      amount: serializer.fromJson<double>(json['amount']),
      donationDate: serializer.fromJson<DateTime>(json['donationDate']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      transactionRef: serializer.fromJson<String?>(json['transactionRef']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      receiptNumber: serializer.fromJson<String>(json['receiptNumber']),
      dailySequence: serializer.fromJson<int>(json['dailySequence']),
      donorMobile: serializer.fromJson<String?>(json['donorMobile']),
      donorEmail: serializer.fromJson<String?>(json['donorEmail']),
      donorAddress: serializer.fromJson<String?>(json['donorAddress']),
      organization: serializer.fromJson<String?>(json['organization']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'donorName': serializer.toJson<String>(donorName),
      'donorType': serializer.toJson<String>(donorType),
      'memberId': serializer.toJson<int?>(memberId),
      'amount': serializer.toJson<double>(amount),
      'donationDate': serializer.toJson<DateTime>(donationDate),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'transactionRef': serializer.toJson<String?>(transactionRef),
      'purpose': serializer.toJson<String?>(purpose),
      'receiptNumber': serializer.toJson<String>(receiptNumber),
      'dailySequence': serializer.toJson<int>(dailySequence),
      'donorMobile': serializer.toJson<String?>(donorMobile),
      'donorEmail': serializer.toJson<String?>(donorEmail),
      'donorAddress': serializer.toJson<String?>(donorAddress),
      'organization': serializer.toJson<String?>(organization),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Donation copyWith({
    int? id,
    String? donorName,
    String? donorType,
    Value<int?> memberId = const Value.absent(),
    double? amount,
    DateTime? donationDate,
    String? paymentMode,
    Value<String?> transactionRef = const Value.absent(),
    Value<String?> purpose = const Value.absent(),
    String? receiptNumber,
    int? dailySequence,
    Value<String?> donorMobile = const Value.absent(),
    Value<String?> donorEmail = const Value.absent(),
    Value<String?> donorAddress = const Value.absent(),
    Value<String?> organization = const Value.absent(),
    DateTime? createdAt,
  }) => Donation(
    id: id ?? this.id,
    donorName: donorName ?? this.donorName,
    donorType: donorType ?? this.donorType,
    memberId: memberId.present ? memberId.value : this.memberId,
    amount: amount ?? this.amount,
    donationDate: donationDate ?? this.donationDate,
    paymentMode: paymentMode ?? this.paymentMode,
    transactionRef: transactionRef.present
        ? transactionRef.value
        : this.transactionRef,
    purpose: purpose.present ? purpose.value : this.purpose,
    receiptNumber: receiptNumber ?? this.receiptNumber,
    dailySequence: dailySequence ?? this.dailySequence,
    donorMobile: donorMobile.present ? donorMobile.value : this.donorMobile,
    donorEmail: donorEmail.present ? donorEmail.value : this.donorEmail,
    donorAddress: donorAddress.present ? donorAddress.value : this.donorAddress,
    organization: organization.present ? organization.value : this.organization,
    createdAt: createdAt ?? this.createdAt,
  );
  Donation copyWithCompanion(DonationsCompanion data) {
    return Donation(
      id: data.id.present ? data.id.value : this.id,
      donorName: data.donorName.present ? data.donorName.value : this.donorName,
      donorType: data.donorType.present ? data.donorType.value : this.donorType,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      amount: data.amount.present ? data.amount.value : this.amount,
      donationDate: data.donationDate.present
          ? data.donationDate.value
          : this.donationDate,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
      transactionRef: data.transactionRef.present
          ? data.transactionRef.value
          : this.transactionRef,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
      dailySequence: data.dailySequence.present
          ? data.dailySequence.value
          : this.dailySequence,
      donorMobile: data.donorMobile.present
          ? data.donorMobile.value
          : this.donorMobile,
      donorEmail: data.donorEmail.present
          ? data.donorEmail.value
          : this.donorEmail,
      donorAddress: data.donorAddress.present
          ? data.donorAddress.value
          : this.donorAddress,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Donation(')
          ..write('id: $id, ')
          ..write('donorName: $donorName, ')
          ..write('donorType: $donorType, ')
          ..write('memberId: $memberId, ')
          ..write('amount: $amount, ')
          ..write('donationDate: $donationDate, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('transactionRef: $transactionRef, ')
          ..write('purpose: $purpose, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('dailySequence: $dailySequence, ')
          ..write('donorMobile: $donorMobile, ')
          ..write('donorEmail: $donorEmail, ')
          ..write('donorAddress: $donorAddress, ')
          ..write('organization: $organization, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    donorName,
    donorType,
    memberId,
    amount,
    donationDate,
    paymentMode,
    transactionRef,
    purpose,
    receiptNumber,
    dailySequence,
    donorMobile,
    donorEmail,
    donorAddress,
    organization,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Donation &&
          other.id == this.id &&
          other.donorName == this.donorName &&
          other.donorType == this.donorType &&
          other.memberId == this.memberId &&
          other.amount == this.amount &&
          other.donationDate == this.donationDate &&
          other.paymentMode == this.paymentMode &&
          other.transactionRef == this.transactionRef &&
          other.purpose == this.purpose &&
          other.receiptNumber == this.receiptNumber &&
          other.dailySequence == this.dailySequence &&
          other.donorMobile == this.donorMobile &&
          other.donorEmail == this.donorEmail &&
          other.donorAddress == this.donorAddress &&
          other.organization == this.organization &&
          other.createdAt == this.createdAt);
}

class DonationsCompanion extends UpdateCompanion<Donation> {
  final Value<int> id;
  final Value<String> donorName;
  final Value<String> donorType;
  final Value<int?> memberId;
  final Value<double> amount;
  final Value<DateTime> donationDate;
  final Value<String> paymentMode;
  final Value<String?> transactionRef;
  final Value<String?> purpose;
  final Value<String> receiptNumber;
  final Value<int> dailySequence;
  final Value<String?> donorMobile;
  final Value<String?> donorEmail;
  final Value<String?> donorAddress;
  final Value<String?> organization;
  final Value<DateTime> createdAt;
  const DonationsCompanion({
    this.id = const Value.absent(),
    this.donorName = const Value.absent(),
    this.donorType = const Value.absent(),
    this.memberId = const Value.absent(),
    this.amount = const Value.absent(),
    this.donationDate = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.transactionRef = const Value.absent(),
    this.purpose = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.dailySequence = const Value.absent(),
    this.donorMobile = const Value.absent(),
    this.donorEmail = const Value.absent(),
    this.donorAddress = const Value.absent(),
    this.organization = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DonationsCompanion.insert({
    this.id = const Value.absent(),
    required String donorName,
    required String donorType,
    this.memberId = const Value.absent(),
    required double amount,
    required DateTime donationDate,
    required String paymentMode,
    this.transactionRef = const Value.absent(),
    this.purpose = const Value.absent(),
    required String receiptNumber,
    this.dailySequence = const Value.absent(),
    this.donorMobile = const Value.absent(),
    this.donorEmail = const Value.absent(),
    this.donorAddress = const Value.absent(),
    this.organization = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : donorName = Value(donorName),
       donorType = Value(donorType),
       amount = Value(amount),
       donationDate = Value(donationDate),
       paymentMode = Value(paymentMode),
       receiptNumber = Value(receiptNumber);
  static Insertable<Donation> custom({
    Expression<int>? id,
    Expression<String>? donorName,
    Expression<String>? donorType,
    Expression<int>? memberId,
    Expression<double>? amount,
    Expression<DateTime>? donationDate,
    Expression<String>? paymentMode,
    Expression<String>? transactionRef,
    Expression<String>? purpose,
    Expression<String>? receiptNumber,
    Expression<int>? dailySequence,
    Expression<String>? donorMobile,
    Expression<String>? donorEmail,
    Expression<String>? donorAddress,
    Expression<String>? organization,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (donorName != null) 'donor_name': donorName,
      if (donorType != null) 'donor_type': donorType,
      if (memberId != null) 'member_id': memberId,
      if (amount != null) 'amount': amount,
      if (donationDate != null) 'donation_date': donationDate,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (transactionRef != null) 'transaction_ref': transactionRef,
      if (purpose != null) 'purpose': purpose,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (dailySequence != null) 'daily_sequence': dailySequence,
      if (donorMobile != null) 'donor_mobile': donorMobile,
      if (donorEmail != null) 'donor_email': donorEmail,
      if (donorAddress != null) 'donor_address': donorAddress,
      if (organization != null) 'organization': organization,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DonationsCompanion copyWith({
    Value<int>? id,
    Value<String>? donorName,
    Value<String>? donorType,
    Value<int?>? memberId,
    Value<double>? amount,
    Value<DateTime>? donationDate,
    Value<String>? paymentMode,
    Value<String?>? transactionRef,
    Value<String?>? purpose,
    Value<String>? receiptNumber,
    Value<int>? dailySequence,
    Value<String?>? donorMobile,
    Value<String?>? donorEmail,
    Value<String?>? donorAddress,
    Value<String?>? organization,
    Value<DateTime>? createdAt,
  }) {
    return DonationsCompanion(
      id: id ?? this.id,
      donorName: donorName ?? this.donorName,
      donorType: donorType ?? this.donorType,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      donationDate: donationDate ?? this.donationDate,
      paymentMode: paymentMode ?? this.paymentMode,
      transactionRef: transactionRef ?? this.transactionRef,
      purpose: purpose ?? this.purpose,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      dailySequence: dailySequence ?? this.dailySequence,
      donorMobile: donorMobile ?? this.donorMobile,
      donorEmail: donorEmail ?? this.donorEmail,
      donorAddress: donorAddress ?? this.donorAddress,
      organization: organization ?? this.organization,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (donorName.present) {
      map['donor_name'] = Variable<String>(donorName.value);
    }
    if (donorType.present) {
      map['donor_type'] = Variable<String>(donorType.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<int>(memberId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (donationDate.present) {
      map['donation_date'] = Variable<DateTime>(donationDate.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (transactionRef.present) {
      map['transaction_ref'] = Variable<String>(transactionRef.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (dailySequence.present) {
      map['daily_sequence'] = Variable<int>(dailySequence.value);
    }
    if (donorMobile.present) {
      map['donor_mobile'] = Variable<String>(donorMobile.value);
    }
    if (donorEmail.present) {
      map['donor_email'] = Variable<String>(donorEmail.value);
    }
    if (donorAddress.present) {
      map['donor_address'] = Variable<String>(donorAddress.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DonationsCompanion(')
          ..write('id: $id, ')
          ..write('donorName: $donorName, ')
          ..write('donorType: $donorType, ')
          ..write('memberId: $memberId, ')
          ..write('amount: $amount, ')
          ..write('donationDate: $donationDate, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('transactionRef: $transactionRef, ')
          ..write('purpose: $purpose, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('dailySequence: $dailySequence, ')
          ..write('donorMobile: $donorMobile, ')
          ..write('donorEmail: $donorEmail, ')
          ..write('donorAddress: $donorAddress, ')
          ..write('organization: $organization, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $AdminSettingsTable adminSettings = $AdminSettingsTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $SubscriptionConfigTable subscriptionConfig =
      $SubscriptionConfigTable(this);
  late final $YearlySummariesTable yearlySummaries = $YearlySummariesTable(
    this,
  );
  late final $PastOutstandingDuesTable pastOutstandingDues =
      $PastOutstandingDuesTable(this);
  late final $DonationsTable donations = $DonationsTable(this);
  late final SubscriptionsDao subscriptionsDao = SubscriptionsDao(
    this as AppDatabase,
  );
  late final MembersDao membersDao = MembersDao(this as AppDatabase);
  late final SubscriptionConfigDao subscriptionConfigDao =
      SubscriptionConfigDao(this as AppDatabase);
  late final YearlySummariesDao yearlySummariesDao = YearlySummariesDao(
    this as AppDatabase,
  );
  late final PastOutstandingDao pastOutstandingDao = PastOutstandingDao(
    this as AppDatabase,
  );
  late final DonationsDao donationsDao = DonationsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subscriptions,
    adminSettings,
    members,
    subscriptionConfig,
    yearlySummaries,
    pastOutstandingDues,
    donations,
  ];
}

typedef $$SubscriptionsTableCreateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      required String firstName,
      required String lastName,
      required String address,
      required String mobileNumber,
      Value<String?> email,
      required String enrollmentNumber,
      required double amount,
      required String paymentMode,
      Value<String?> transactionInfo,
      Value<String?> notes,
      required DateTime subscriptionDate,
      required String receiptNumber,
      Value<String?> receiptType,
      Value<int> dailySequence,
    });
typedef $$SubscriptionsTableUpdateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      Value<String> firstName,
      Value<String> lastName,
      Value<String> address,
      Value<String> mobileNumber,
      Value<String?> email,
      Value<String> enrollmentNumber,
      Value<double> amount,
      Value<String> paymentMode,
      Value<String?> transactionInfo,
      Value<String?> notes,
      Value<DateTime> subscriptionDate,
      Value<String> receiptNumber,
      Value<String?> receiptType,
      Value<int> dailySequence,
    });

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionInfo => $composableBuilder(
    column: $table.transactionInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscriptionDate => $composableBuilder(
    column: $table.subscriptionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptType => $composableBuilder(
    column: $table.receiptType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailySequence => $composableBuilder(
    column: $table.dailySequence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionInfo => $composableBuilder(
    column: $table.transactionInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscriptionDate => $composableBuilder(
    column: $table.subscriptionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptType => $composableBuilder(
    column: $table.receiptType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailySequence => $composableBuilder(
    column: $table.dailySequence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionInfo => $composableBuilder(
    column: $table.transactionInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get subscriptionDate => $composableBuilder(
    column: $table.subscriptionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptType => $composableBuilder(
    column: $table.receiptType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailySequence => $composableBuilder(
    column: $table.dailySequence,
    builder: (column) => column,
  );
}

class $$SubscriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionsTable,
          Subscription,
          $$SubscriptionsTableFilterComposer,
          $$SubscriptionsTableOrderingComposer,
          $$SubscriptionsTableAnnotationComposer,
          $$SubscriptionsTableCreateCompanionBuilder,
          $$SubscriptionsTableUpdateCompanionBuilder,
          (
            Subscription,
            BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>,
          ),
          Subscription,
          PrefetchHooks Function()
        > {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> mobileNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> enrollmentNumber = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> paymentMode = const Value.absent(),
                Value<String?> transactionInfo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> subscriptionDate = const Value.absent(),
                Value<String> receiptNumber = const Value.absent(),
                Value<String?> receiptType = const Value.absent(),
                Value<int> dailySequence = const Value.absent(),
              }) => SubscriptionsCompanion(
                id: id,
                firstName: firstName,
                lastName: lastName,
                address: address,
                mobileNumber: mobileNumber,
                email: email,
                enrollmentNumber: enrollmentNumber,
                amount: amount,
                paymentMode: paymentMode,
                transactionInfo: transactionInfo,
                notes: notes,
                subscriptionDate: subscriptionDate,
                receiptNumber: receiptNumber,
                receiptType: receiptType,
                dailySequence: dailySequence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String firstName,
                required String lastName,
                required String address,
                required String mobileNumber,
                Value<String?> email = const Value.absent(),
                required String enrollmentNumber,
                required double amount,
                required String paymentMode,
                Value<String?> transactionInfo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime subscriptionDate,
                required String receiptNumber,
                Value<String?> receiptType = const Value.absent(),
                Value<int> dailySequence = const Value.absent(),
              }) => SubscriptionsCompanion.insert(
                id: id,
                firstName: firstName,
                lastName: lastName,
                address: address,
                mobileNumber: mobileNumber,
                email: email,
                enrollmentNumber: enrollmentNumber,
                amount: amount,
                paymentMode: paymentMode,
                transactionInfo: transactionInfo,
                notes: notes,
                subscriptionDate: subscriptionDate,
                receiptNumber: receiptNumber,
                receiptType: receiptType,
                dailySequence: dailySequence,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionsTable,
      Subscription,
      $$SubscriptionsTableFilterComposer,
      $$SubscriptionsTableOrderingComposer,
      $$SubscriptionsTableAnnotationComposer,
      $$SubscriptionsTableCreateCompanionBuilder,
      $$SubscriptionsTableUpdateCompanionBuilder,
      (
        Subscription,
        BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>,
      ),
      Subscription,
      PrefetchHooks Function()
    >;
typedef $$AdminSettingsTableCreateCompanionBuilder =
    AdminSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AdminSettingsTableUpdateCompanionBuilder =
    AdminSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AdminSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AdminSettingsTable> {
  $$AdminSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdminSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdminSettingsTable> {
  $$AdminSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdminSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdminSettingsTable> {
  $$AdminSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AdminSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdminSettingsTable,
          AdminSetting,
          $$AdminSettingsTableFilterComposer,
          $$AdminSettingsTableOrderingComposer,
          $$AdminSettingsTableAnnotationComposer,
          $$AdminSettingsTableCreateCompanionBuilder,
          $$AdminSettingsTableUpdateCompanionBuilder,
          (
            AdminSetting,
            BaseReferences<_$AppDatabase, $AdminSettingsTable, AdminSetting>,
          ),
          AdminSetting,
          PrefetchHooks Function()
        > {
  $$AdminSettingsTableTableManager(_$AppDatabase db, $AdminSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdminSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdminSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdminSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AdminSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AdminSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdminSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdminSettingsTable,
      AdminSetting,
      $$AdminSettingsTableFilterComposer,
      $$AdminSettingsTableOrderingComposer,
      $$AdminSettingsTableAnnotationComposer,
      $$AdminSettingsTableCreateCompanionBuilder,
      $$AdminSettingsTableUpdateCompanionBuilder,
      (
        AdminSetting,
        BaseReferences<_$AppDatabase, $AdminSettingsTable, AdminSetting>,
      ),
      AdminSetting,
      PrefetchHooks Function()
    >;
typedef $$MembersTableCreateCompanionBuilder =
    MembersCompanion Function({
      Value<int> id,
      required String surname,
      required String firstName,
      Value<String?> middleName,
      required int age,
      Value<DateTime?> dateOfBirth,
      Value<String?> bloodGroup,
      Value<DateTime?> enrollmentDateAba,
      Value<DateTime?> enrollmentDateBar,
      required String registrationNumber,
      required String address,
      required String mobileNumber,
      Value<String?> email,
      Value<String> memberStatus,
      Value<String?> remarks,
      Value<String?> profilePhotoPath,
      Value<DateTime> createdAt,
    });
typedef $$MembersTableUpdateCompanionBuilder =
    MembersCompanion Function({
      Value<int> id,
      Value<String> surname,
      Value<String> firstName,
      Value<String?> middleName,
      Value<int> age,
      Value<DateTime?> dateOfBirth,
      Value<String?> bloodGroup,
      Value<DateTime?> enrollmentDateAba,
      Value<DateTime?> enrollmentDateBar,
      Value<String> registrationNumber,
      Value<String> address,
      Value<String> mobileNumber,
      Value<String?> email,
      Value<String> memberStatus,
      Value<String?> remarks,
      Value<String?> profilePhotoPath,
      Value<DateTime> createdAt,
    });

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enrollmentDateAba => $composableBuilder(
    column: $table.enrollmentDateAba,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enrollmentDateBar => $composableBuilder(
    column: $table.enrollmentDateBar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberStatus => $composableBuilder(
    column: $table.memberStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePhotoPath => $composableBuilder(
    column: $table.profilePhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enrollmentDateAba => $composableBuilder(
    column: $table.enrollmentDateAba,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enrollmentDateBar => $composableBuilder(
    column: $table.enrollmentDateBar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberStatus => $composableBuilder(
    column: $table.memberStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePhotoPath => $composableBuilder(
    column: $table.profilePhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get enrollmentDateAba => $composableBuilder(
    column: $table.enrollmentDateAba,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get enrollmentDateBar => $composableBuilder(
    column: $table.enrollmentDateBar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get memberStatus => $composableBuilder(
    column: $table.memberStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get profilePhotoPath => $composableBuilder(
    column: $table.profilePhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          Member,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
          Member,
          PrefetchHooks Function()
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> surname = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> bloodGroup = const Value.absent(),
                Value<DateTime?> enrollmentDateAba = const Value.absent(),
                Value<DateTime?> enrollmentDateBar = const Value.absent(),
                Value<String> registrationNumber = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> mobileNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> memberStatus = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> profilePhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                surname: surname,
                firstName: firstName,
                middleName: middleName,
                age: age,
                dateOfBirth: dateOfBirth,
                bloodGroup: bloodGroup,
                enrollmentDateAba: enrollmentDateAba,
                enrollmentDateBar: enrollmentDateBar,
                registrationNumber: registrationNumber,
                address: address,
                mobileNumber: mobileNumber,
                email: email,
                memberStatus: memberStatus,
                remarks: remarks,
                profilePhotoPath: profilePhotoPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String surname,
                required String firstName,
                Value<String?> middleName = const Value.absent(),
                required int age,
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> bloodGroup = const Value.absent(),
                Value<DateTime?> enrollmentDateAba = const Value.absent(),
                Value<DateTime?> enrollmentDateBar = const Value.absent(),
                required String registrationNumber,
                required String address,
                required String mobileNumber,
                Value<String?> email = const Value.absent(),
                Value<String> memberStatus = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> profilePhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                surname: surname,
                firstName: firstName,
                middleName: middleName,
                age: age,
                dateOfBirth: dateOfBirth,
                bloodGroup: bloodGroup,
                enrollmentDateAba: enrollmentDateAba,
                enrollmentDateBar: enrollmentDateBar,
                registrationNumber: registrationNumber,
                address: address,
                mobileNumber: mobileNumber,
                email: email,
                memberStatus: memberStatus,
                remarks: remarks,
                profilePhotoPath: profilePhotoPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      Member,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
      Member,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionConfigTableCreateCompanionBuilder =
    SubscriptionConfigCompanion Function({
      Value<int> id,
      Value<double> monthlyAmount,
      Value<DateTime?> subscriptionStartDate,
      Value<DateTime> lastUpdated,
    });
typedef $$SubscriptionConfigTableUpdateCompanionBuilder =
    SubscriptionConfigCompanion Function({
      Value<int> id,
      Value<double> monthlyAmount,
      Value<DateTime?> subscriptionStartDate,
      Value<DateTime> lastUpdated,
    });

class $$SubscriptionConfigTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionConfigTable> {
  $$SubscriptionConfigTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyAmount => $composableBuilder(
    column: $table.monthlyAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscriptionStartDate => $composableBuilder(
    column: $table.subscriptionStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionConfigTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionConfigTable> {
  $$SubscriptionConfigTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyAmount => $composableBuilder(
    column: $table.monthlyAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscriptionStartDate => $composableBuilder(
    column: $table.subscriptionStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionConfigTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionConfigTable> {
  $$SubscriptionConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get monthlyAmount => $composableBuilder(
    column: $table.monthlyAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get subscriptionStartDate => $composableBuilder(
    column: $table.subscriptionStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$SubscriptionConfigTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionConfigTable,
          SubscriptionConfigData,
          $$SubscriptionConfigTableFilterComposer,
          $$SubscriptionConfigTableOrderingComposer,
          $$SubscriptionConfigTableAnnotationComposer,
          $$SubscriptionConfigTableCreateCompanionBuilder,
          $$SubscriptionConfigTableUpdateCompanionBuilder,
          (
            SubscriptionConfigData,
            BaseReferences<
              _$AppDatabase,
              $SubscriptionConfigTable,
              SubscriptionConfigData
            >,
          ),
          SubscriptionConfigData,
          PrefetchHooks Function()
        > {
  $$SubscriptionConfigTableTableManager(
    _$AppDatabase db,
    $SubscriptionConfigTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionConfigTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionConfigTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionConfigTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> monthlyAmount = const Value.absent(),
                Value<DateTime?> subscriptionStartDate = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => SubscriptionConfigCompanion(
                id: id,
                monthlyAmount: monthlyAmount,
                subscriptionStartDate: subscriptionStartDate,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> monthlyAmount = const Value.absent(),
                Value<DateTime?> subscriptionStartDate = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => SubscriptionConfigCompanion.insert(
                id: id,
                monthlyAmount: monthlyAmount,
                subscriptionStartDate: subscriptionStartDate,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionConfigTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionConfigTable,
      SubscriptionConfigData,
      $$SubscriptionConfigTableFilterComposer,
      $$SubscriptionConfigTableOrderingComposer,
      $$SubscriptionConfigTableAnnotationComposer,
      $$SubscriptionConfigTableCreateCompanionBuilder,
      $$SubscriptionConfigTableUpdateCompanionBuilder,
      (
        SubscriptionConfigData,
        BaseReferences<
          _$AppDatabase,
          $SubscriptionConfigTable,
          SubscriptionConfigData
        >,
      ),
      SubscriptionConfigData,
      PrefetchHooks Function()
    >;
typedef $$YearlySummariesTableCreateCompanionBuilder =
    YearlySummariesCompanion Function({
      Value<int> id,
      required String enrollmentNumber,
      required String financialYear,
      required double totalExpected,
      required double totalPaid,
      required double balance,
      required String status,
      Value<DateTime> closedAt,
    });
typedef $$YearlySummariesTableUpdateCompanionBuilder =
    YearlySummariesCompanion Function({
      Value<int> id,
      Value<String> enrollmentNumber,
      Value<String> financialYear,
      Value<double> totalExpected,
      Value<double> totalPaid,
      Value<double> balance,
      Value<String> status,
      Value<DateTime> closedAt,
    });

class $$YearlySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $YearlySummariesTable> {
  $$YearlySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalExpected => $composableBuilder(
    column: $table.totalExpected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPaid => $composableBuilder(
    column: $table.totalPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YearlySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $YearlySummariesTable> {
  $$YearlySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalExpected => $composableBuilder(
    column: $table.totalExpected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPaid => $composableBuilder(
    column: $table.totalPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YearlySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $YearlySummariesTable> {
  $$YearlySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get financialYear => $composableBuilder(
    column: $table.financialYear,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalExpected => $composableBuilder(
    column: $table.totalExpected,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalPaid =>
      $composableBuilder(column: $table.totalPaid, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);
}

class $$YearlySummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $YearlySummariesTable,
          YearlySummary,
          $$YearlySummariesTableFilterComposer,
          $$YearlySummariesTableOrderingComposer,
          $$YearlySummariesTableAnnotationComposer,
          $$YearlySummariesTableCreateCompanionBuilder,
          $$YearlySummariesTableUpdateCompanionBuilder,
          (
            YearlySummary,
            BaseReferences<_$AppDatabase, $YearlySummariesTable, YearlySummary>,
          ),
          YearlySummary,
          PrefetchHooks Function()
        > {
  $$YearlySummariesTableTableManager(
    _$AppDatabase db,
    $YearlySummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YearlySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YearlySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YearlySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> enrollmentNumber = const Value.absent(),
                Value<String> financialYear = const Value.absent(),
                Value<double> totalExpected = const Value.absent(),
                Value<double> totalPaid = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> closedAt = const Value.absent(),
              }) => YearlySummariesCompanion(
                id: id,
                enrollmentNumber: enrollmentNumber,
                financialYear: financialYear,
                totalExpected: totalExpected,
                totalPaid: totalPaid,
                balance: balance,
                status: status,
                closedAt: closedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String enrollmentNumber,
                required String financialYear,
                required double totalExpected,
                required double totalPaid,
                required double balance,
                required String status,
                Value<DateTime> closedAt = const Value.absent(),
              }) => YearlySummariesCompanion.insert(
                id: id,
                enrollmentNumber: enrollmentNumber,
                financialYear: financialYear,
                totalExpected: totalExpected,
                totalPaid: totalPaid,
                balance: balance,
                status: status,
                closedAt: closedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YearlySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $YearlySummariesTable,
      YearlySummary,
      $$YearlySummariesTableFilterComposer,
      $$YearlySummariesTableOrderingComposer,
      $$YearlySummariesTableAnnotationComposer,
      $$YearlySummariesTableCreateCompanionBuilder,
      $$YearlySummariesTableUpdateCompanionBuilder,
      (
        YearlySummary,
        BaseReferences<_$AppDatabase, $YearlySummariesTable, YearlySummary>,
      ),
      YearlySummary,
      PrefetchHooks Function()
    >;
typedef $$PastOutstandingDuesTableCreateCompanionBuilder =
    PastOutstandingDuesCompanion Function({
      Value<int> id,
      required String enrollmentNumber,
      required double amount,
      required String periodLabel,
      required String type,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<bool> isCleared,
      Value<DateTime?> clearedAt,
      Value<int?> linkedPaymentId,
    });
typedef $$PastOutstandingDuesTableUpdateCompanionBuilder =
    PastOutstandingDuesCompanion Function({
      Value<int> id,
      Value<String> enrollmentNumber,
      Value<double> amount,
      Value<String> periodLabel,
      Value<String> type,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<bool> isCleared,
      Value<DateTime?> clearedAt,
      Value<int?> linkedPaymentId,
    });

class $$PastOutstandingDuesTableFilterComposer
    extends Composer<_$AppDatabase, $PastOutstandingDuesTable> {
  $$PastOutstandingDuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodLabel => $composableBuilder(
    column: $table.periodLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCleared => $composableBuilder(
    column: $table.isCleared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clearedAt => $composableBuilder(
    column: $table.clearedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedPaymentId => $composableBuilder(
    column: $table.linkedPaymentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PastOutstandingDuesTableOrderingComposer
    extends Composer<_$AppDatabase, $PastOutstandingDuesTable> {
  $$PastOutstandingDuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodLabel => $composableBuilder(
    column: $table.periodLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCleared => $composableBuilder(
    column: $table.isCleared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clearedAt => $composableBuilder(
    column: $table.clearedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedPaymentId => $composableBuilder(
    column: $table.linkedPaymentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PastOutstandingDuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PastOutstandingDuesTable> {
  $$PastOutstandingDuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get enrollmentNumber => $composableBuilder(
    column: $table.enrollmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get periodLabel => $composableBuilder(
    column: $table.periodLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isCleared =>
      $composableBuilder(column: $table.isCleared, builder: (column) => column);

  GeneratedColumn<DateTime> get clearedAt =>
      $composableBuilder(column: $table.clearedAt, builder: (column) => column);

  GeneratedColumn<int> get linkedPaymentId => $composableBuilder(
    column: $table.linkedPaymentId,
    builder: (column) => column,
  );
}

class $$PastOutstandingDuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PastOutstandingDuesTable,
          PastOutstandingDue,
          $$PastOutstandingDuesTableFilterComposer,
          $$PastOutstandingDuesTableOrderingComposer,
          $$PastOutstandingDuesTableAnnotationComposer,
          $$PastOutstandingDuesTableCreateCompanionBuilder,
          $$PastOutstandingDuesTableUpdateCompanionBuilder,
          (
            PastOutstandingDue,
            BaseReferences<
              _$AppDatabase,
              $PastOutstandingDuesTable,
              PastOutstandingDue
            >,
          ),
          PastOutstandingDue,
          PrefetchHooks Function()
        > {
  $$PastOutstandingDuesTableTableManager(
    _$AppDatabase db,
    $PastOutstandingDuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PastOutstandingDuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PastOutstandingDuesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PastOutstandingDuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> enrollmentNumber = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> periodLabel = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isCleared = const Value.absent(),
                Value<DateTime?> clearedAt = const Value.absent(),
                Value<int?> linkedPaymentId = const Value.absent(),
              }) => PastOutstandingDuesCompanion(
                id: id,
                enrollmentNumber: enrollmentNumber,
                amount: amount,
                periodLabel: periodLabel,
                type: type,
                notes: notes,
                createdAt: createdAt,
                isCleared: isCleared,
                clearedAt: clearedAt,
                linkedPaymentId: linkedPaymentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String enrollmentNumber,
                required double amount,
                required String periodLabel,
                required String type,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isCleared = const Value.absent(),
                Value<DateTime?> clearedAt = const Value.absent(),
                Value<int?> linkedPaymentId = const Value.absent(),
              }) => PastOutstandingDuesCompanion.insert(
                id: id,
                enrollmentNumber: enrollmentNumber,
                amount: amount,
                periodLabel: periodLabel,
                type: type,
                notes: notes,
                createdAt: createdAt,
                isCleared: isCleared,
                clearedAt: clearedAt,
                linkedPaymentId: linkedPaymentId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PastOutstandingDuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PastOutstandingDuesTable,
      PastOutstandingDue,
      $$PastOutstandingDuesTableFilterComposer,
      $$PastOutstandingDuesTableOrderingComposer,
      $$PastOutstandingDuesTableAnnotationComposer,
      $$PastOutstandingDuesTableCreateCompanionBuilder,
      $$PastOutstandingDuesTableUpdateCompanionBuilder,
      (
        PastOutstandingDue,
        BaseReferences<
          _$AppDatabase,
          $PastOutstandingDuesTable,
          PastOutstandingDue
        >,
      ),
      PastOutstandingDue,
      PrefetchHooks Function()
    >;
typedef $$DonationsTableCreateCompanionBuilder =
    DonationsCompanion Function({
      Value<int> id,
      required String donorName,
      required String donorType,
      Value<int?> memberId,
      required double amount,
      required DateTime donationDate,
      required String paymentMode,
      Value<String?> transactionRef,
      Value<String?> purpose,
      required String receiptNumber,
      Value<int> dailySequence,
      Value<String?> donorMobile,
      Value<String?> donorEmail,
      Value<String?> donorAddress,
      Value<String?> organization,
      Value<DateTime> createdAt,
    });
typedef $$DonationsTableUpdateCompanionBuilder =
    DonationsCompanion Function({
      Value<int> id,
      Value<String> donorName,
      Value<String> donorType,
      Value<int?> memberId,
      Value<double> amount,
      Value<DateTime> donationDate,
      Value<String> paymentMode,
      Value<String?> transactionRef,
      Value<String?> purpose,
      Value<String> receiptNumber,
      Value<int> dailySequence,
      Value<String?> donorMobile,
      Value<String?> donorEmail,
      Value<String?> donorAddress,
      Value<String?> organization,
      Value<DateTime> createdAt,
    });

class $$DonationsTableFilterComposer
    extends Composer<_$AppDatabase, $DonationsTable> {
  $$DonationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get donorName => $composableBuilder(
    column: $table.donorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get donorType => $composableBuilder(
    column: $table.donorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get donationDate => $composableBuilder(
    column: $table.donationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionRef => $composableBuilder(
    column: $table.transactionRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailySequence => $composableBuilder(
    column: $table.dailySequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get donorMobile => $composableBuilder(
    column: $table.donorMobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get donorEmail => $composableBuilder(
    column: $table.donorEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get donorAddress => $composableBuilder(
    column: $table.donorAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DonationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DonationsTable> {
  $$DonationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get donorName => $composableBuilder(
    column: $table.donorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get donorType => $composableBuilder(
    column: $table.donorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get donationDate => $composableBuilder(
    column: $table.donationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionRef => $composableBuilder(
    column: $table.transactionRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailySequence => $composableBuilder(
    column: $table.dailySequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get donorMobile => $composableBuilder(
    column: $table.donorMobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get donorEmail => $composableBuilder(
    column: $table.donorEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get donorAddress => $composableBuilder(
    column: $table.donorAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DonationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DonationsTable> {
  $$DonationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get donorName =>
      $composableBuilder(column: $table.donorName, builder: (column) => column);

  GeneratedColumn<String> get donorType =>
      $composableBuilder(column: $table.donorType, builder: (column) => column);

  GeneratedColumn<int> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get donationDate => $composableBuilder(
    column: $table.donationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionRef => $composableBuilder(
    column: $table.transactionRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailySequence => $composableBuilder(
    column: $table.dailySequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get donorMobile => $composableBuilder(
    column: $table.donorMobile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get donorEmail => $composableBuilder(
    column: $table.donorEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get donorAddress => $composableBuilder(
    column: $table.donorAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DonationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DonationsTable,
          Donation,
          $$DonationsTableFilterComposer,
          $$DonationsTableOrderingComposer,
          $$DonationsTableAnnotationComposer,
          $$DonationsTableCreateCompanionBuilder,
          $$DonationsTableUpdateCompanionBuilder,
          (Donation, BaseReferences<_$AppDatabase, $DonationsTable, Donation>),
          Donation,
          PrefetchHooks Function()
        > {
  $$DonationsTableTableManager(_$AppDatabase db, $DonationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DonationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DonationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DonationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> donorName = const Value.absent(),
                Value<String> donorType = const Value.absent(),
                Value<int?> memberId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> donationDate = const Value.absent(),
                Value<String> paymentMode = const Value.absent(),
                Value<String?> transactionRef = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String> receiptNumber = const Value.absent(),
                Value<int> dailySequence = const Value.absent(),
                Value<String?> donorMobile = const Value.absent(),
                Value<String?> donorEmail = const Value.absent(),
                Value<String?> donorAddress = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DonationsCompanion(
                id: id,
                donorName: donorName,
                donorType: donorType,
                memberId: memberId,
                amount: amount,
                donationDate: donationDate,
                paymentMode: paymentMode,
                transactionRef: transactionRef,
                purpose: purpose,
                receiptNumber: receiptNumber,
                dailySequence: dailySequence,
                donorMobile: donorMobile,
                donorEmail: donorEmail,
                donorAddress: donorAddress,
                organization: organization,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String donorName,
                required String donorType,
                Value<int?> memberId = const Value.absent(),
                required double amount,
                required DateTime donationDate,
                required String paymentMode,
                Value<String?> transactionRef = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                required String receiptNumber,
                Value<int> dailySequence = const Value.absent(),
                Value<String?> donorMobile = const Value.absent(),
                Value<String?> donorEmail = const Value.absent(),
                Value<String?> donorAddress = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DonationsCompanion.insert(
                id: id,
                donorName: donorName,
                donorType: donorType,
                memberId: memberId,
                amount: amount,
                donationDate: donationDate,
                paymentMode: paymentMode,
                transactionRef: transactionRef,
                purpose: purpose,
                receiptNumber: receiptNumber,
                dailySequence: dailySequence,
                donorMobile: donorMobile,
                donorEmail: donorEmail,
                donorAddress: donorAddress,
                organization: organization,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DonationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DonationsTable,
      Donation,
      $$DonationsTableFilterComposer,
      $$DonationsTableOrderingComposer,
      $$DonationsTableAnnotationComposer,
      $$DonationsTableCreateCompanionBuilder,
      $$DonationsTableUpdateCompanionBuilder,
      (Donation, BaseReferences<_$AppDatabase, $DonationsTable, Donation>),
      Donation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$AdminSettingsTableTableManager get adminSettings =>
      $$AdminSettingsTableTableManager(_db, _db.adminSettings);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$SubscriptionConfigTableTableManager get subscriptionConfig =>
      $$SubscriptionConfigTableTableManager(_db, _db.subscriptionConfig);
  $$YearlySummariesTableTableManager get yearlySummaries =>
      $$YearlySummariesTableTableManager(_db, _db.yearlySummaries);
  $$PastOutstandingDuesTableTableManager get pastOutstandingDues =>
      $$PastOutstandingDuesTableTableManager(_db, _db.pastOutstandingDues);
  $$DonationsTableTableManager get donations =>
      $$DonationsTableTableManager(_db, _db.donations);
}
