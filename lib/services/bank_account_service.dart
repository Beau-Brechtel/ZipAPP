import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccountService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> connectBankAccount({
    required String accountNumber,
    required String routingNumber,
  }) async {
    // Replace with actual driver ID mechanism
    String driverId = "your_driver_id";

    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'bankAccount': {
          'accountNumber': accountNumber,
          'routingNumber': routingNumber,
        },
      });
    } catch (e) {
      throw Exception("Failed to connect bank account");
    }
  }
}
