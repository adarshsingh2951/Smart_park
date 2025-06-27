class ParkingSpace {
  final String id;
  final String ownerId;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerHour;
  final int availableSpots;
  final String photoUrl;
  final String upiId; // <-- NEW FIELD
  final List<Review> reviews;

  ParkingSpace({
    required this.id,
    required this.ownerId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    required this.availableSpots,
    required this.photoUrl,
    required this.upiId, // <-- NEW FIELD
    this.reviews = const [],
  });

  factory ParkingSpace.fromMap(Map<String, dynamic> map) {
    return ParkingSpace(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      availableSpots: map['availableSpots'] ?? 0,
      photoUrl: map['photoUrl'] ?? '',
      upiId: map['upiId'] ?? '', // <-- NEW FIELD
      reviews: map['reviews'] != null && map['reviews'] is List
          ? List<Review>.from(
              (map['reviews'] as List).map((x) => Review.fromMap(Map<String, dynamic>.from(x))))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerHour': pricePerHour,
      'availableSpots': availableSpots,
      'photoUrl': photoUrl,
      'upiId': upiId, // <-- NEW FIELD
      'reviews': reviews.map((x) => x.toMap()).toList(),
    };
  }
}

// ...Review class as before...


class Review {
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
}
