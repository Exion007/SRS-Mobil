import 'dart:async';
import 'package:flutter/material.dart';
import '../models/songModel.dart';
import '../models/albumModel.dart';
import '../models/artistModel.dart';
import '../apis/MySongs_Logic.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../apis/RatingLogic.dart';
import '../apis/AuthLogic.dart';

import 'package:flutter/material.dart';

class SeeAllPage extends StatefulWidget {
  final String title;

  const SeeAllPage({required this.title});

  @override
  _SeeAllPageState createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  late Future<List<dynamic>> items;
  final songService = SongService();

  @override
  void initState() {
    super.initState();
    switch (widget.title) {
      case 'Songs':
        items = songService.fetchSongs();
        break;
      case 'Albums':
        items = songService.fetchAlbums();
        break;
      case 'Artists':
        items = songService.fetchArtists();
        break;
      default:
        // Handle unexpected title
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  String title;
                  String subtitle;
                  String imageUrl;
                  switch (widget.title) {
                    case 'Songs':
                      title = item.songName;
                      subtitle = 'By ${item.mainArtistName}';
                      imageUrl = item
                          .albumImg; // Assuming this is the URL to the song's album image
                      break;
                    case 'Albums':
                      title = item.name;
                      subtitle =
                          'Album Rating: ${item.ratingValue ?? 'Not Rated'}';
                      imageUrl = item.albumImg; // URL to the album's image
                      break;
                    case 'Artists':
                      title = item.artistName;
                      subtitle =
                          'Artist Rating: ${item.ratingValue ?? 'Not Rated'}';
                      imageUrl = item.artistImg; // URL to the artist's image
                      break;
                    default:
                      title = 'Unknown';
                      subtitle = '';
                      imageUrl = ''; // Default image or placeholder
                  }
                  return ListTile(
                    leading: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              // If the image fails to load, you can return a placeholder widget
                              return Icon(Icons.music_note);
                            },
                          )
                        : SizedBox(
                            width: 50,
                            height: 50), // Placeholder if there's no image URL
                    title: Text(title),
                    subtitle: Text(subtitle),
                    onTap: () {
                      // Handle item tap
                    },
                  );
                },
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
