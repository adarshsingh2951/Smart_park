import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';
import '../models/parking_space_model.dart';

class PaymentHandler {
  // Set your app's UPI ID here!
  static const String appUpiId = 'omguptanir0410@oksbi'; // <-- Replace with your real UPI ID

  /// Handles payment split: 90% to owner, 10% to app
  static Future<bool> handlePayment(BuildContext context, ParkingSpace parkingSpace, double totalAmount) async {
    final ownerAmount = (totalAmount * 0.9).toStringAsFixed(2);
    final appAmount = (totalAmount * 0.1).toStringAsFixed(2);

    final upiPay = UpiPay();

    // 1. Pay 90% to owner
    final ownerResult = await upiPay.initiateTransaction(
      amount: ownerAmount,
      app: UpiApplication.googlePay,
      receiverName: parkingSpace.address,
      receiverUpiAddress: parkingSpace.upiId,
      transactionRef: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionNote: 'Parking payment to owner',
    );

    if (ownerResult.status != UpiTransactionStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Owner payment failed or cancelled.')),
      );
      return false;
    }

    // 2. Pay 10% to app
    final appResult = await upiPay.initiateTransaction(
      amount: appAmount,
      app: UpiApplication.googlePay,
      receiverName: "ParkEasy",
      receiverUpiAddress: appUpiId,
      transactionRef: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionNote: 'ParkEasy commission',
    );

    if (appResult.status != UpiTransactionStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commission payment failed or cancelled.')),
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful!')),
    );
    return true;
  }
}
