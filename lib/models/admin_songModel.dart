class Song {
  final String id;
  final String? userId;
  final String songName;
  final String mainArtistName;
  final String mainArtistId;
  final List<String>? featuringArtistNames;
  final List<String>? featuringArtistIds;
  final String albumName;
  final String albumId;
  final int? popularity;
  final int? durationMs;
  final DateTime? releaseDate;
  final String? albumImg;
  final DateTime createdAt;
  final double? ratingValue;

  Song({
    required this.id,
    this.userId,
    required this.songName,
    required this.mainArtistName,
    required this.mainArtistId,
    this.featuringArtistNames,
    this.featuringArtistIds,
    required this.albumName,
    required this.albumId,
    this.popularity,
    this.durationMs,
    this.releaseDate,
    this.albumImg,
    required this.createdAt,
    this.ratingValue,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['_id'] as String,
      userId: json['userId']?.toString(),
      songName: json['songName'] as String,
      mainArtistName: json['mainArtistName'] as String,
      mainArtistId: json['mainArtistId'] as String,
      featuringArtistNames: List<String>.from(json['featuringArtistNames'] ?? []),
      featuringArtistIds: (json['featuringArtistId'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      albumName: json['albumName'] as String,
      albumId: json['albumId'] as String,
      popularity: json['popularity'] as int?,
      durationMs: json['duration_ms'] as int?,
      releaseDate: json['release_date'] == null ? null : DateTime.parse(json['release_date']),
      albumImg: json['albumImg'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      ratingValue: (json['ratingValue'] as num?)?.toDouble(),
    );
  }
}
