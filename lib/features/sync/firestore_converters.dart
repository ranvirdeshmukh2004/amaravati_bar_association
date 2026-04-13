import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';

// Extensions to convert Drift Classes to Firestore Maps

extension MemberFirestore on Member {
  Map<String, dynamic> toFirestore() {
    return {
      'uuid': uuid,
      'firstName': firstName,
      'middleName': middleName,
      'surname': surname,
      'enrollmentNumber': registrationNumber, 
      'registrationNumber': registrationNumber,
      'address': address,
      'mobileNumber': mobileNumber,
      'email': email,
      'age': age,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'memberStatus': memberStatus,
      'bloodGroup': bloodGroup,
      'enrollmentDateAba': enrollmentDateAba?.toIso8601String(),
      'enrollmentDateBar': enrollmentDateBar?.toIso8601String(),
      'profilePhotoPath': profilePhotoPath,
      'remarks': remarks,
      'isSynced': true,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

extension SubscriptionFirestore on Subscription {
  Map<String, dynamic> toFirestore() {
    return {
      'uuid': uuid,
      'enrollmentNumber': enrollmentNumber,
      'amount': amount,
      'subscriptionDate': subscriptionDate.toIso8601String(),
      'paymentMode': paymentMode,
      'receiptNumber': receiptNumber,
      'receiptType': receiptType,
      'dailySequence': dailySequence,
      'transactionInfo': transactionInfo,
      'notes': notes,
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'isSynced': true,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      'deleted': deleted,
    };
  }
}

extension DonationFirestore on Donation {
  Map<String, dynamic> toFirestore() {
    return {
      'uuid': uuid,
      'donorName': donorName,
      'donorType': donorType,
      'amount': amount,
      'donationDate': donationDate.toIso8601String(),
      'paymentMode': paymentMode,
      'receiptNumber': receiptNumber,
      'dailySequence': dailySequence,
      'purpose': purpose,
      'transactionRef': transactionRef,
      'donorMobile': donorMobile,
      'donorEmail': donorEmail,
      'donorAddress': donorAddress,
      'organization': organization,
      'isSynced': true,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

extension PastOutstandingFirestore on PastOutstandingDue {
  Map<String, dynamic> toFirestore() {
    return {
      'uuid': uuid,
      'enrollmentNumber': enrollmentNumber,
      'amount': amount,
      'periodLabel': periodLabel,
      'type': type,
      'notes': notes,
      'isCleared': isCleared,
      'clearedAt': clearedAt?.toIso8601String(),
      'linkedPaymentId': linkedPaymentId,
      'isSynced': true,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Helpers to parse FROM Firestore
class FirestoreParsers {
  static MembersCompanion memberFromMap(Map<String, dynamic> data) {
    return MembersCompanion.insert(
      uuid: _parseString(data['uuid']),
      firstName: data['firstName'] ?? '',
      surname: data['surname'] ?? '',
      address: data['address'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      age: data['age'] is int ? data['age'] : int.tryParse(data['age'].toString()) ?? 0,
      registrationNumber: data['registrationNumber'] ?? '',
      // Optionals
      middleName: _parseString(data['middleName']),
      email: _parseString(data['email']),
      memberStatus: _parseValue(data['memberStatus'], 'Active'),
      bloodGroup: _parseString(data['bloodGroup']),
      remarks: _parseString(data['remarks']),
      profilePhotoPath: _parseString(data['profilePhotoPath']),
      enrollmentDateAba: _parseDate(data['enrollmentDateAba']),
      enrollmentDateBar: _parseDate(data['enrollmentDateBar']),
      dateOfBirth: _parseDate(data['dateOfBirth']),
      createdAt: drift.Value(_parseDate(data['createdAt']).value ?? DateTime.now()),
      lastUpdatedAt: drift.Value(_parseDate(data['lastUpdatedAt']).value ?? DateTime.now()),
      isSynced: const drift.Value(true),
      deleted: drift.Value(data['deleted'] == true),
    );
  }
  
  static SubscriptionsCompanion subscriptionFromMap(Map<String, dynamic> data) {
    return SubscriptionsCompanion.insert(
      uuid: _parseString(data['uuid']),
      enrollmentNumber: data['enrollmentNumber'] ?? '',
      amount: data['amount'] is num ? (data['amount'] as num).toDouble() : 0.0,
      subscriptionDate: _parseDate(data['subscriptionDate']).value ?? DateTime.now(),
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      address: data['address'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      paymentMode: data['paymentMode'] ?? '',
      receiptNumber: data['receiptNumber'] ?? '',
      // Optionals
      receiptType: _parseString(data['receiptType']),
      dailySequence: _parseValue(data['dailySequence'], 0),
      transactionInfo: _parseString(data['transactionInfo']),
      notes: _parseString(data['notes']),
      isSynced: const drift.Value(true),
      deleted: drift.Value(data['deleted'] == true),
      lastUpdatedAt: drift.Value(_parseDate(data['lastUpdatedAt']).value ?? DateTime.now()),
    );
  }

  static DonationsCompanion donationFromMap(Map<String, dynamic> data) {
    return DonationsCompanion.insert(
      uuid: _parseString(data['uuid']),
      donorName: data['donorName'] ?? '',
      donorType: data['donorType'] ?? '',
      amount: data['amount'] is num ? (data['amount'] as num).toDouble() : 0.0,
      donationDate: _parseDate(data['donationDate']).value ?? DateTime.now(),
      paymentMode: data['paymentMode'] ?? '',
      receiptNumber: data['receiptNumber'] ?? '',
      // Optionals
      dailySequence: _parseValue(data['dailySequence'], 0),
      purpose: _parseString(data['purpose']),
      transactionRef: _parseString(data['transactionRef']),
      donorMobile: _parseString(data['donorMobile']),
      donorEmail: _parseString(data['donorEmail']),
      donorAddress: _parseString(data['donorAddress']),
      organization: _parseString(data['organization']),
      isSynced: const drift.Value(true),
      deleted: drift.Value(data['deleted'] == true),
      lastUpdatedAt: drift.Value(_parseDate(data['lastUpdatedAt']).value ?? DateTime.now()),
      createdAt: drift.Value(_parseDate(data['createdAt']).value ?? DateTime.now()),
    );
  }

  static PastOutstandingDuesCompanion pastOutstandingFromMap(Map<String, dynamic> data) {
    return PastOutstandingDuesCompanion.insert(
      uuid: _parseString(data['uuid']),
      enrollmentNumber: data['enrollmentNumber'] ?? '',
      amount: data['amount'] is num ? (data['amount'] as num).toDouble() : 0.0,
      periodLabel: data['periodLabel'] ?? '',
      type: data['type'] ?? '',
      // Optionals
      notes: _parseString(data['notes']),
      isCleared: _parseValue(data['isCleared'], false),
      clearedAt: _parseDate(data['clearedAt']),
      linkedPaymentId: _parseValue(data['linkedPaymentId'], null),
      isSynced: const drift.Value(true),
      deleted: drift.Value(data['deleted'] == true),
      lastUpdatedAt: drift.Value(_parseDate(data['lastUpdatedAt']).value ?? DateTime.now()),
      createdAt: drift.Value(_parseDate(data['createdAt']).value ?? DateTime.now()),
    );
  }
  
  // Helpers
  static drift.Value<String?> _parseString(dynamic val) {
    return val != null ? drift.Value(val.toString()) : const drift.Value.absent();
  }
  
  static drift.Value<T> _parseValue<T>(dynamic val, T fallback) {
    return val != null ? drift.Value(val) : drift.Value(fallback);
  }
  
  static drift.Value<DateTime?> _parseDate(dynamic val) {
    if (val == null) return const drift.Value.absent();
    if (val is Timestamp) return drift.Value(val.toDate());
    if (val is String) return drift.Value(DateTime.tryParse(val));
    // Handle drift.Value wrap if accidentally passed
    if (val is drift.Value) {
       final inner = (val as drift.Value).value;
       if (inner is DateTime) return drift.Value(inner);
       if (inner == null) return const drift.Value(null);
    }
    return const drift.Value.absent();
  }
}

extension SubscriptionConfigFirestore on SubscriptionConfigData {
  Map<String, dynamic> toFirestore() {
    return {
      'uuid': uuid,
      'monthlyAmount': monthlyAmount,
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'lastUpdatedAt': FieldValue.serverTimestamp(), // Match SyncService query
      'isSynced': true,
      'deleted': deleted,
    };
  }
}

extension FirestoreConfigParser on FirestoreParsers {
  static SubscriptionConfigCompanion subscriptionConfigFromMap(Map<String, dynamic> data) {
      return SubscriptionConfigCompanion.insert(
         uuid: FirestoreParsers._parseString(data['uuid']),
         monthlyAmount: data['monthlyAmount'] is num 
             ? drift.Value((data['monthlyAmount'] as num).toDouble()) 
             : const drift.Value(100.0),
         subscriptionStartDate: FirestoreParsers._parseDate(data['subscriptionStartDate']),
         // Map remote 'lastUpdatedAt' to local 'lastUpdated'
         lastUpdated: drift.Value(FirestoreParsers._parseDate(data['lastUpdatedAt']).value ?? DateTime.now()),
         isSynced: const drift.Value(true),
         deleted: drift.Value(data['deleted'] == true),
      );
  }
}
