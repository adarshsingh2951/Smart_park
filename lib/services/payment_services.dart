import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';

class PaymentService {
  static final UpiPay _upiPay = UpiPay();

  // UPI apps fetch karne ke liye
  static Future<List<ApplicationMeta>> getUpiApps() async {
    return _upiPay.getInstalledUpiApplications(
      statusType: UpiApplicationDiscoveryAppStatusType.all,
    );
  }

  // Payment initiate karne ke liye
  static Future<void> makePayment({
    required BuildContext context,
    required ApplicationMeta app,
    required String amount,
    required String name,
    required String upiId,
    required String transactionNote,
  }) async {
    final txnRef = DateTime.now().millisecondsSinceEpoch.toString();

    final result = await _upiPay.initiateTransaction(
      amount: amount,
      app: app.upiApplication,
      receiverName: name,
      receiverUpiAddress: upiId,
      transactionRef: txnRef,
      transactionNote: transactionNote,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaction Status: ${result.status}')),
    );
  }
}
