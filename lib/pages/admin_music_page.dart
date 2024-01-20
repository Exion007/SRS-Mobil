import 'package:flutter/material.dart';
import '../pages/admin_add_song_page.dart';
import '../pages/admin_remove_song_page.dart';
import '../pages/admin_export_data_page.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF171717),
          title: const TabBar(
            labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
            labelColor: Colors.white,
            indicatorColor: Colors.green,
            tabs: [
              Tab(
                text: 'Add',
                icon: Icon(
                  Icons.add,
                  color: Colors.green,
                  size: 25.0,
                ),
              ),
              Tab(
                text: 'Remove',
                icon: Icon(
                  Icons.remove,
                  color: Colors.green,
                  size: 25.0,
                ),
              ),
              Tab(
                text: 'Export',
                icon: Icon(
                  Icons.import_export,
                  color: Colors.green,
                  size: 25.0,
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminAddSongPage(),
            AdminRemoveSongPage(),
            AdminExportDataPage(),
          ],
        ),
      ),
    );
  }
}