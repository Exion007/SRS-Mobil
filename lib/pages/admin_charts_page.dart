import 'dart:io';
import 'dart:typed_data';
import '../apis/AdminLogic.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({Key? key}) : super(key: key);

  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  final AdminLogic _adminLogic = AdminLogic();
  Uint8List? currentChart;
  bool isLoading = false;

  void _fetchUserRegistrationChart() async {
    setState(() {
      isLoading = true;
    });
    try {
      Uint8List chartImage = await _adminLogic.fetchUserRegistrationChart();
      setState(() {
        currentChart = chartImage;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _fetchAddedSongChart() async {
    setState(() {
      isLoading = true;
    });
    try {
      Uint8List chartImage = await _adminLogic.fetchAddedSongChart();
      setState(() {
        currentChart = chartImage;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

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
              title: const Text('Share Analysis', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _shareAnalysis(currentChart, 'admin');
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            style: ButtonStyle(iconColor: MaterialStatePropertyAll(Colors.white)),
            onPressed: () => _showSharePopup(context),
            tooltip: 'Share Analysis',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                  onPressed: _fetchUserRegistrationChart,
                  child: const Text('Fetch User Registrations for Last Month', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                  onPressed: _fetchAddedSongChart,
                  child: const Text('Fetch Added Songs for Last Month', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 50),
              if (isLoading) const CircularProgressIndicator(),
              if (currentChart != null) Image.memory(currentChart!),
            ],
          ),
        ),
      ),
    );
  }
}