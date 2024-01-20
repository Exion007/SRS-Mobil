import 'package:flutter/material.dart';
import '../apis/AdminLogic.dart';
import '../pages/admin_update_song_page.dart';

enum RemoveType { song, album, artist }

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
              Tab(text: 'Songs'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
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

  void _confirmRemoveItem(dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Confirm Delete'),
          titleTextStyle: const TextStyle(fontSize: 25, color: Colors.red),
          content: Text('Are you sure you want to delete this item?'),
          contentTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            side: BorderSide(color: Colors.red, width: 2.5),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.blue, fontSize: 20.0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red, fontSize: 20.0)),
              onPressed: () async {
                await _removeItem(item);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        _refreshList();
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  void _refreshList() {
    setState(() {
      _futureItems = _fetchItems();
    });
  }

  void refreshAndClearSearch() {
  _searchController.clear();
  _refreshList();
}

  List<Widget> _buildListWithSeparators(List<dynamic> items) {
    List<Widget> listItems = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final itemName = widget.type == RemoveType.song
          ? item.songName
          : widget.type == RemoveType.album
              ? item.name
              : item.artistName;

      List<Widget> trailingActions = [];

      // Add update button only for songs
      if (widget.type == RemoveType.song) {
        trailingActions.add(
          IconButton(
            icon: const Icon(Icons.arrow_upward, color: Colors.blue),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UpdateSongPage(
                  song: item,
                  onSongUpdated: refreshAndClearSearch,
                ),
              ),
            ),
          ),
        );
      }

      trailingActions.add(
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _confirmRemoveItem(item),
        ),
      );

      listItems.add(
        ListTile(
          title: Text(itemName, style: const TextStyle(color: Colors.white)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: trailingActions,
          ),
        ),
      );

      if (i < items.length - 1) {
        listItems.add(const Divider(color: Colors.green));
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
                  return items.where((item) {
                    final searchLower = value.toLowerCase();
                    if (widget.type == RemoveType.song) {
                      return item.songName.toLowerCase().contains(searchLower);
                    } else if (widget.type == RemoveType.album) {
                      return item.name.toLowerCase().contains(searchLower);
                    } else if (widget.type == RemoveType.artist) {
                      return item.artistName.toLowerCase().contains(searchLower);
                    }
                    return false;
                  }).toList();
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
                return const Center(child: Text('No items found.', style: TextStyle(color: Colors.white, fontSize: 22.0)));
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