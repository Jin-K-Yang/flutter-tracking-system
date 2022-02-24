class UserLocation {
  final int id;
  final String locDateTime;
  final double userLat;
  final double userLon;

  UserLocation(
      {required this.id,
      required this.locDateTime,
      required this.userLat,
      required this.userLon});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'locDateTime': locDateTime,
      'userLat': userLat,
      'userLon': userLon,
    };
  }

  @override
  String toString() {
    return '$locDateTime,$userLat,$userLon,$id';
  }
}
