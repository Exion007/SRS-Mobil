class Artist {
  final String id;
  final String? userId;
  final String artistName;
  final String? artistImg;
  final DateTime createdAt;
  final double? ratingValue;

  Artist({
    required this.id,
    this.userId,
    required this.artistName,
    this.artistImg,
    required this.createdAt,
    this.ratingValue,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['_id'] as String,
      userId: json['userId']?.toString(),
      artistName: json['artistName'] as String,
      artistImg: json['artistImg'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      ratingValue: (json['ratingValue'] as num?)?.toDouble(),
    );
  }
}