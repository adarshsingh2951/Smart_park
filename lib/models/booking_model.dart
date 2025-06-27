class Booking {
  final String id;
  final String userId;
  final String parkingSpaceId;
  final String parkingSpaceAddress;
  final DateTime startTime;
  final DateTime endTime;
  final double cost;
  final String status;

  Booking({
    required this.id,
    required this.userId,
    required this.parkingSpaceId,
    required this.parkingSpaceAddress,
    required this.startTime,
    required this.endTime,
    required this.cost,
    required this.status,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      parkingSpaceId: map['parkingSpaceId'] ?? '',
      parkingSpaceAddress: map['parkingSpaceAddress'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'parkingSpaceId': parkingSpaceId,
      'parkingSpaceAddress': parkingSpaceAddress,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'cost': cost,
      'status': status,
    };
  }
}
