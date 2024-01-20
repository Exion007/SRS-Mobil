import 'package:flutter/material.dart';
import '../apis/AdminLogic.dart';
import '../pages/admin_update_music_page.dart';

class AdminRemoveSongPage extends StatelessWidget {
  const AdminRemoveSongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF171717),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF171717),
          title: const TabBar(
            labelStyle: TextStyle(color: Colors.white),
            labelColor: Colors.white,
            indicatorColor: Colors.green,
            tabs: [
              Tab(
                text: 'Songs',
              ),
              Tab(
                text: 'Albums',
              ),
              Tab(
                text: 'Artists',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RemoveSongList(type: RemoveType.song),
            RemoveSongList(type: RemoveType.album),
            RemoveSongList(type: RemoveType.artist),
          ],
        ),
      ),
    );
  }
}

class RemoveSongList extends StatefulWidget {
  final RemoveType type;

  const RemoveSongList({super.key, required this.type});

  @override
  _RemoveSongListState createState() => _RemoveSongListState();
}

class _RemoveSongListState extends State<RemoveSongList> {
  late Future<List<dynamic>> _futureItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureItems = _fetchItems();
  }

  Future<List<dynamic>> _fetchItems() async {
    try {
      switch (widget.type) {
        case RemoveType.song:
          var songs = await AdminLogic().fetchSongs();
          songs.sort((a, b) => a.songName.compareTo(b.songName));
          return songs;
        case RemoveType.album:
          var albums = await AdminLogic().fetchAlbums();
          albums.sort((a, b) => a.name.compareTo(b.name));
          return albums;
        case RemoveType.artist:
          var artists = await AdminLogic().fetchArtists();
          artists.sort((a, b) => a.artistName.compareTo(b.artistName));
          return artists;
      }
    } catch (e) {
      print('Error fetching items: $e');
      throw Exception('Failed to load items');
    }
  }

  Future<void> _removeItem(dynamic item) async {
    try {
      bool itemRemoved = false;
      switch (widget.type) {
        case RemoveType.song:
          await AdminLogic().removeSong(item.id);
          itemRemoved = true;
          break;
        case RemoveType.album:
          await AdminLogic().removeAlbum(item.id);
          itemRemoved = true;
          break;
        case RemoveType.artist:
          await AdminLogic().removeArtist(item.id);
          itemRemoved = true;
          break;
      }

      if (itemRemoved) {
      _searchController.clear();
    }

    } catch (e) {
      print('Error removing item: $e');
      // Handle error as needed
    }
  }

  List<Widget> _buildListWithSeparators(List<dynamic> items) {
    List<Widget> listItems = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final itemName = widget.type == RemoveType.song
          ? item.songName
          : widget.type == RemoveType.album
              ? item.name
              : widget.type == RemoveType.artist
                  ? item.artistName
                  : '';

      listItems.add(
        ListTile(
          title: Text(
            itemName,
            style: const TextStyle(color: Colors.white,),
          ),
          onTap: () async {
            bool removeConfirmed = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.grey[800],
                  title: const Text('Confirmation'),
                  titleTextStyle: const TextStyle(fontSize: 25, color: Colors.red),
                  content: Text('Are you sure you want to remove $itemName?'),
                  contentTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    side: BorderSide(color: Colors.red, width: 2.5),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Cancel removal
                      },
                      child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 20.0),),
                    ),
                    TextButton(
                      onPressed: () {
                        _removeItem(item);
                        Navigator.of(context).pop(true); // Confirm removal
                      },
                      child: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 20.0),),
                    ),
                  ],
                );
              },
            );

            if (removeConfirmed == true) {
              await _removeItem(item);
              setState(() {
                _futureItems = _fetchItems();
              });
            }
          },
        ),
      );

      if (i < items.length - 1) {
        listItems.add(const Divider(color: Colors.green,));
      }
    }
    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                _futureItems = _fetchItems().then((items) {
                  return items.where((item) =>
                      (widget.type == RemoveType.song && item.songName.toLowerCase().contains(value.toLowerCase())) ||
                      (widget.type == RemoveType.album && item.name.toLowerCase().contains(value.toLowerCase())) ||
                      (widget.type == RemoveType.artist && item.artistName.toLowerCase().contains(value.toLowerCase())))
                      .toList();
                });
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futureItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No items found.', style: TextStyle(color: Colors.white, fontSize: 22.0),));
              } else {
                List<dynamic> items = snapshot.data!;
                return ListView(
                  children: _buildListWithSeparators(items),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

enum RemoveType {
  song,
  album,
  artist,
}