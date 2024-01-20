import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../apis/AdminLogic.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60.0),
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