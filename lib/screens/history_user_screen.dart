import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/parking_service.dart';
import '../models/booking_model.dart';
import '../models/parking_space_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryUserScreen extends StatefulWidget {
  @override
  _HistoryUserScreenState createState() => _HistoryUserScreenState();
}

class _HistoryUserScreenState extends State<HistoryUserScreen>
    with SingleTickerProviderStateMixin {
  final ParkingService _parkingService = ParkingService();
  String? _userId;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle get headingStyle => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  TextStyle get subHeadingStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  TextStyle get detailTextStyle => const TextStyle(
    fontSize: 14,
    color: Colors.black87,
    height: 1.4,
  );

  TextStyle get moneyStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.green,
  );

  String formatDate(DateTime dt) {
    final day = dt.day;
    final suffix = (day >= 11 && day <= 13)
        ? 'th'
        : (day % 10 == 1)
        ? 'st'
        : (day % 10 == 2)
        ? 'nd'
        : (day % 10 == 3)
        ? 'rd'
        : 'th';
    return '${day}${suffix} ${DateFormat.MMMM().format(dt)} ${dt.year}';
  }

  String formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Container(
            height: kToolbarHeight + 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.only(top: 40),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'Parking History',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 12,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ),
          Expanded(
            child: FutureBuilder<List<Booking>>(
              future: _userId == null
                  ? Future.value([])
                  : _parkingService.getBookingsByUser(_userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No records found',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                final bookings = snapshot.data!;
                final ongoing =
                bookings.where((b) => b.status == 'active').toList();
                final past =
                bookings.where((b) => b.status == 'completed').toList();

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (ongoing.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('🟢 Ongoing Bookings', style: headingStyle),
                      ),
                      ...ongoing
                          .map((booking) => buildBookingCard(booking, false)),
                    ],
                    if (past.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('📜 Past Bookings', style: headingStyle),
                      ),
                      ...past.map((booking) => FutureBuilder<bool>(
                        future: _parkingService.hasUserReviewed(
                            booking.parkingSpaceId, _userId!),
                        builder: (context, reviewSnapshot) {
                          final hasReviewed = reviewSnapshot.data ?? false;
                          return buildBookingCard(booking, true,
                              hasReviewed: hasReviewed);
                        },
                      )),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBookingCard(Booking booking, bool isPast,
      {bool hasReviewed = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey.shade100 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isPast ? Colors.grey.shade300 : Colors.blue.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Icon(
          isPast ? Icons.history : Icons.local_parking_rounded,
          color: isPast ? Colors.deepPurple : Colors.blue.shade700,
          size: 30,
        ),
        title: Text(
          'Parked at:\n${booking.parkingSpaceAddress}',
          style: subHeadingStyle,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '🗓 ${formatDate(booking.startTime)}\n🕒 ${formatTime(booking.startTime)} → ${formatTime(booking.endTime)}\n📌 Status: ${booking.status}',
            style: detailTextStyle,
          ),
        ),
        trailing: isPast
            ? (hasReviewed
            ? const Text(
          'Reviewed',
          style: TextStyle(
              fontSize: 13,
              color: Colors.green,
              fontWeight: FontWeight.w600),
        )
            : ElevatedButton(
          onPressed: () => showReviewDialog(booking),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Add Review'),
        ))
            : Text('₹${booking.cost}', style: moneyStyle),
      ),
    );
  }

  Future<void> showReviewDialog(Booking booking) async {
    double tempRating = 3.0;
    String comment = '';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('⭐ Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rate this parking:'),
              StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: tempRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: tempRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        tempRating = value;
                      });
                    },
                  );
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Comment'),
                onChanged: (val) => comment = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, {
                'rating': tempRating,
                'comment': comment,
              }),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final user = FirebaseAuth.instance.currentUser!;
      await _parkingService.addReviewToParkingSpace(
        booking.parkingSpaceId,
        Review(
          userId: user.uid,
          userName: user.displayName ?? 'Anonymous',
          rating: result['rating'],
          comment: result['comment'],
          date: DateTime.now(),
        ),
      );
      setState(() {});
    }
  }


}
