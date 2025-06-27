import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';
import '../models/parking_space_model.dart';

class PaymentHandler {
  static const String appUpiId = 'omguptanir0410@oksbi'; // <-- Set your UPI ID here!

  static Future<bool> handlePayment(
    BuildContext context,
    ParkingSpace parkingSpace,
    double totalAmount,
  ) async {
    final upiPay = UpiPay();
    final apps = await upiPay.getInstalledUpiApplications();

    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No UPI apps found on this device.')),
      );
      return false;
    }

    // Let user pick the app (or just use the first one)
    final ApplicationMeta upiAppMeta = apps.first;

    // 1. Pay 90% to owner
    await upiPay.initiateTransaction(
      app: upiAppMeta.upiApplication, // <-- This is the correct type!
      receiverUpiAddress: parkingSpace.upiId,
      receiverName: parkingSpace.address,
      transactionRef: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionNote: 'Parking payment to owner',
      amount: (totalAmount * 0.9).toStringAsFixed(2),
    );

    final ownerConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Owner Payment Confirmation'),
        content: Text('Did you complete the payment to owner successfully?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );

    if (ownerConfirmed != true) return false;

    // 2. Pay 10% to app
    await upiPay.initiateTransaction(
      app: upiAppMeta.upiApplication,
      receiverUpiAddress: appUpiId,
      receiverName: "ParkEasy",
      transactionRef: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionNote: 'ParkEasy commission',
      amount: (totalAmount * 0.1).toStringAsFixed(2),
    );

    final appConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Commission Payment Confirmation'),
        content: Text('Did you complete the commission payment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );

    if (appConfirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commission payment not completed.')),
      );
      return false;
    }
  }
}
