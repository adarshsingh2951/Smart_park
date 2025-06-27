import 'package:flutter/material.dart';
import '../models/parking_space_model.dart';
import '../services/parking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingTimerScreen extends StatefulWidget {
  final String parkingSpaceId;
  // ...other fields as needed...

  BookingTimerScreen({required this.parkingSpaceId});

  @override
  _BookingTimerScreenState createState() => _BookingTimerScreenState();
}

class _BookingTimerScreenState extends State<BookingTimerScreen> {
  final ParkingService _parkingService = ParkingService();

  void _onEndParking() async {
    // Prompt for review
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ReviewDialog(),
    );
    if (result != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final review = Review(
          userId: user.uid,
          userName: user.displayName ?? 'Anonymous',
          rating: result['rating'],
          comment: result['comment'],
          date: DateTime.now(),
        );
        await _parkingService.addReviewToParkingSpace(widget.parkingSpaceId, review);
      }
    }
    // ...rest of end parking logic (navigate, show message, etc.)...
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // ...your timer and UI logic...
    return Scaffold(
      appBar: AppBar(title: Text('Parking Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ...timer UI...
            ElevatedButton(
              onPressed: _onEndParking,
              child: Text('End Parking & Leave Review'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewDialog extends StatefulWidget {
  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _rating = 5;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Leave a Review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 4,
            label: _rating.toString(),
            onChanged: (v) => setState(() => _rating = v),
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Comment'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'rating': _rating,
            'comment': _controller.text,
          }),
          child: Text('Submit'),
        ),
      ],
    );
  }
}
