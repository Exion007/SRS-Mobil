class Album {
  final String id;
  final String? userId;
  final String name;
  final String? artistId;
  final String? albumImg;
  final DateTime? releaseDate;
  final DateTime createdAt;
  final double? ratingValue;

  Album({
    required this.id,
    this.userId,
    required this.name,
    this.artistId,
    this.albumImg,
    this.releaseDate,
    required this.createdAt,
    this.ratingValue,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['_id'] as String,
      userId: json['userId']?.toString(),
      name: json['name'] as String,
      artistId: json['artistId']?.toString(),
      albumImg: json['albumImg'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : DateTime.parse(json['release_date']),
      createdAt: DateTime.parse(json['createdAt']),
      ratingValue: (json['ratingValue'] as num?)?.toDouble(),
    );
  }
}