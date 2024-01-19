import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/artistModel.dart';
import '../apis/statisticsLogic.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  final StatisticsLogic _statisticsLogic = StatisticsLogic();
  late TabController _tabController;

  String? selectedType = 'song';
  List<String> selectedArtists = [];
  DateTime? startDate;
  DateTime? endDate;
  Uint8List? favoritesImage;
  Uint8List? chartsImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _resetPageState();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _resetPageState() {
    setState(() {
      selectedType = 'song';
      selectedArtists = [];
      startDate = null;
      endDate = null;
      favoritesImage = null;
      chartsImage = null;
    });
  }

  void _showDatePicker(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Color(0xFF171717),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != (isStart ? startDate : endDate)) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _removeArtist(String artistName) {
    setState(() {
      selectedArtists.remove(artistName);
    });
  }

  // Method to handle sharing of analysis
  void _shareAnalysis(Uint8List? data, String analysisType) async {
    if (data != null) {

      // Setting the download directory
      Directory directory;

      // For Android
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } 
      // For iOS
      else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } 
      // For other platforms
      else {
        directory = Directory.current;
      }

      final imagePath = await File('${directory.path}/$analysisType.png').create();
      await imagePath.writeAsBytes(data);

      Share.shareFiles([imagePath.path], text: 'Check out my $analysisType analysis!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No $analysisType analysis to share.')));
    }
  }

  void _showSharePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171717),
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.white),
              title: const Text('Share Favorites Analysis', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _shareAnalysis(favoritesImage, 'favorites_analysis');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.white),
              title: const Text('Share Chart Analysis', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _shareAnalysis(chartsImage, 'chart_analysis');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF171717),
        title: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: Text("Favorites"),
              ),
            ),
            Tab(
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: Text('Charts'),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            style: ButtonStyle(iconColor: MaterialStatePropertyAll(Colors.white)),
            onPressed: () => _showSharePopup(context),
            tooltip: 'Share Analysis',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedType,
                          dropdownColor: Colors.grey[800],
                          style: const TextStyle(color: Colors.white, fontSize: 18.0),
                          items: <String>['song', 'album', 'artist']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedType = newValue;
                            });
                          },
                          underline: Container(
                            height: 2,
                            color: Colors.green,
                          ),
                          iconEnabledColor: Colors.green,
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                            onPressed: () => _showDatePicker(context, true),
                            child: const Text("Start Date", style: TextStyle(color: Colors.white)),
                          ),
                          Text(
                            startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : "Date not set",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                            onPressed: () => _showDatePicker(context, false),
                            child: const Text('End Date', style: TextStyle(color: Colors.white)),
                          ),
                          Text(
                            endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : "Date not set",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        Uint8List fetchedImage = await _statisticsLogic.songAnalysis(
                          selectedType!, 
                          startDate, 
                          endDate
                        );
                        setState(() {
                          favoritesImage = fetchedImage;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                      }
                    },
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                    child: const Text('Fetch Analysis', style: TextStyle(color: Colors.white),),
                  ),
                ),

                if (favoritesImage != null) Image.memory(favoritesImage!),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<List<Artist>>(
                  future: _statisticsLogic.fetchArtists(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return DropdownButton<String>(
                          value: null,
                          hint: Text("Select Artists", style: TextStyle(color: Colors.white),),
                          underline: Container(
                            height: 2,
                            color: Colors.green,
                          ),
                          iconEnabledColor: Colors.green,
                          dropdownColor: Colors.grey[800],
                          items: snapshot.data!.map((Artist artist) {
                            return DropdownMenuItem<String>(
                              value: artist.artistName,
                              child: Text(artist.artistName, style: TextStyle(color: Colors.white),),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedArtists.add(newValue);
                              });
                            }
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                    }
                    return CircularProgressIndicator();
                  },
                ),
                Wrap(
                  spacing: 6.0,
                  children: selectedArtists.map((artist) => Chip(
                    label: Text(artist),
                    onDeleted: () => _removeArtist(artist),
                    deleteIcon: Icon(Icons.cancel),
                  )).toList(),
                ),
                ElevatedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                  onPressed: () async {
                  if (selectedArtists.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select an artist to fetch the chart!')));
                  } else {
                    try {
                      Uint8List fetchedImage = await _statisticsLogic.fetchArtistRatingAverage(selectedArtists);
                      setState(() {
                        chartsImage = fetchedImage;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                    }
                  }
                },
                  child: Text('Fetch Artist Rating Average', style: TextStyle(color: Colors.white),),
                ),
                ElevatedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                  onPressed: () async {
                    if (selectedArtists.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select an artist to fetch the chart!')));
                    } else {
                      try {
                        Uint8List fetchedImage = await _statisticsLogic.fetchArtistsSongsCount(selectedArtists);
                        setState(() {
                          chartsImage = fetchedImage;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                      }
                    }
                  },
                  child: Text('Fetch Artist Songs Count', style: TextStyle(color: Colors.white),),
                ),
                ElevatedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                  onPressed: () async {
                    try {
                        Uint8List fetchedImage = await _statisticsLogic.fetchArtistsAverageRatingLastMonth(selectedArtists);
                        setState(() {
                          chartsImage = fetchedImage;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                    }
                  },
                  child: Text('Fetch Artist Last Month Average Rating', style: TextStyle(color: Colors.white),),
                ),
                if (chartsImage != null) Image.memory(chartsImage!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}