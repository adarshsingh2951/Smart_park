import 'package:firebase_database/firebase_database.dart';
import '../models/parking_space_model.dart';
import '../models/booking_model.dart';

class ParkingService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Get all parking spaces
  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    final ref = _db.child('parking_spaces');
    final snapshot = await ref.get();
    if (!snapshot.exists) return [];
    final spaces = <ParkingSpace>[];
    for (final child in snapshot.children) {
      final map = Map<String, dynamic>.from(child.value as Map);
      map['id'] = child.key ?? '';
      spaces.add(ParkingSpace.fromMap(map));
    }
    return spaces;
  }

  // Get parking spaces by owner (one-time fetch)
  Future<List<ParkingSpace>> getParkingSpacesByOwner(String ownerId) async {
    final ref = _db.child('parking_spaces');
    final snapshot = await ref.orderByChild('ownerId').equalTo(ownerId).get();
    if (!snapshot.exists) return [];
    final spaces = <ParkingSpace>[];
    for (final child in snapshot.children) {
      final map = Map<String, dynamic>.from(child.value as Map);
      map['id'] = child.key ?? '';
      spaces.add(ParkingSpace.fromMap(map));
    }
    return spaces;
  }

  // Real-time updates for owner's parking spaces
  Stream<List<ParkingSpace>> getParkingSpacesByOwnerStream(String ownerId) {
    final ref = _db.child('parking_spaces').orderByChild('ownerId').equalTo(ownerId);
    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value);
        map['id'] = e.key;
        return ParkingSpace.fromMap(map);
      }).toList();
    });
  }


  // Get bookings by user
  Future<List<Booking>> getBookingsByUser(String userId) async {
    final ref = _db.child('bookings');
    final snapshot = await ref.orderByChild('userId').equalTo(userId).get();
    if (!snapshot.exists) return [];
    final bookings = <Booking>[];
    for (final child in snapshot.children) {
      final map = Map<String, dynamic>.from(child.value as Map);
      bookings.add(Booking.fromMap(map));
    }
    return bookings;
  }

  // Add a booking
  Future<void> addBooking(Booking booking) async {
    final newRef = _db.child('bookings').push();
    await newRef.set(booking.toMap());
  }

  // Add a parking space (with UPI ID)
  Future<String?> addParkingSpace({
    required String ownerId,
    required String address,
    required double pricePerHour,
    required int availableSpots,
    required double latitude,
    required double longitude,
    required String upiId,
  }) async {
    final newRef = _db.child('parking_spaces').push();
    await newRef.set({
      'id': newRef.key,
      'ownerId': ownerId,
      'address': address,
      'pricePerHour': pricePerHour,
      'availableSpots': availableSpots,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': '',
      'upiId': upiId,
      'reviews': [],
    });
    return newRef.key;
  }

  // Update parking space (price, slots, upiId, etc.)
  Future<void> updateParkingSpace(
    String parkingSpaceId, {
    double? pricePerHour,
    int? availableSpots,
    String? upiId,
  }) async {
    final updates = <String, dynamic>{};
    if (pricePerHour != null) updates['pricePerHour'] = pricePerHour;
    if (availableSpots != null) updates['availableSpots'] = availableSpots;
    if (upiId != null) updates['upiId'] = upiId;
    await _db.child('parking_spaces/$parkingSpaceId').update(updates);
  }

  // Delete parking space
  Future<void> deleteParkingSpace(String parkingSpaceId) async {
    await _db.child('parking_spaces/$parkingSpaceId').remove();
  }

  // Mark booking as completed
  Future<void> completeBooking(String bookingId) async {
    await _db.child('bookings/$bookingId').update({'status': 'completed'});
  }

  // Fetch reviews for a parking space
  Future<List<Review>> getReviewsForParkingSpace(String parkingSpaceId) async {
    final ref = _db.child('parking_spaces/$parkingSpaceId/reviews');
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      print("🌟 No reviews found for $parkingSpaceId");
      return [];
    }

    final reviews = <Review>[];
    for (final child in snapshot.children) {
      final data = Map<String, dynamic>.from(child.value as Map<dynamic, dynamic>);
      print("🙏 Loaded review: $data");
      reviews.add(Review.fromMap(data));
    }

    return reviews;
  }


  // Add a review to a parking space
  Future<void> addReviewToParkingSpace(String parkingSpaceId, Review review) async {
    final ref = _db.child('parking_spaces/$parkingSpaceId/reviews').push();
    await ref.set(review.toMap());
    final ref2 = _db.child('parking_spaces/$parkingSpaceId/reviews');
    final snapshot = await ref2.get();
    if (!snapshot.exists) {
      print("🌟 No reviews found for $parkingSpaceId");
    }
    else{
      print("✅");
    }
  }

  // Check if user has already reviewed this parking space
  Future<bool> hasUserReviewed(String parkingSpaceId, String userId) async {
    final ref = _db.child('parking_spaces/$parkingSpaceId/reviews');
    final snapshot = await ref.get();
    if (!snapshot.exists) return false;
    for (final child in snapshot.children) {
      final review = Review.fromMap(Map<String, dynamic>.from(child.value as Map));
      if (review.userId == userId) return true;
    }
    return false;
  }
}
