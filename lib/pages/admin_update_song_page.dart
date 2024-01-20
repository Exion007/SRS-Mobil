import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_songModel.dart';
import '../apis/AdminLogic.dart';

class UpdateSongPage extends StatefulWidget {
  final Song song;
  final VoidCallback onSongUpdated;

  UpdateSongPage({Key? key, required this.song, required this.onSongUpdated}) : super(key: key);

  @override
  _UpdateSongPageState createState() => _UpdateSongPageState();
}

class _UpdateSongPageState extends State<UpdateSongPage> {
  final _formKey = GlobalKey<FormState>();
  late String _songName;
  late DateTime _createdAt;
  late double? _ratingValue;

  @override
  void initState() {
    super.initState();
    _songName = widget.song.songName;
    _createdAt = widget.song.createdAt;
    _ratingValue = widget.song.ratingValue;
  }

  void _updateSong() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      AdminLogic adminLogic = AdminLogic();

      Map<String, dynamic> updatedData = {
        'songName': _songName,
        'createdAt': _createdAt.toIso8601String(),
        'ratingValue': _ratingValue,
      };

      adminLogic.updateSong(widget.song.id, updatedData).then((_) {
        _showSnackBar("Song information updated successfully!", Colors.green);
        widget.onSongUpdated();
        Navigator.of(context).pop();
      }).catchError((error) {
        _showSnackBar("Song information could not be updated!", Colors.red);
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _selectReleaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _createdAt,
      firstDate: DateTime(1930),
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
            dialogBackgroundColor: Colors.grey[800],
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _createdAt) {
      setState(() {
        _createdAt = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Song', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF171717),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _songName,
                decoration: InputDecoration(labelText: 'Song Name', labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 24.0)),
                cursorColor: Colors.green,
                onSaved: (value) => _songName = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a song name' : null,
              ),
              SizedBox(height: 30.0),
              Row(
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                    onPressed: () => _selectReleaseDate(context),
                    child: const Text("Select Creation Date", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ),
                  SizedBox(width: 30),
                  Text(
                    DateFormat('yyyy-MM-dd').format(_createdAt),
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: _ratingValue?.toString(),
                decoration: const InputDecoration(
                  labelText: 'Rating Value',
                  labelStyle: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0
                  )
                ),
                cursorColor: Colors.green,
                keyboardType: TextInputType.number,
                onSaved: (value) => _ratingValue = value == "" ? null : double.tryParse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Rating value must be between 0 and 5';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _updateSong,
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                child: Text('Update Song', style: TextStyle(color: Colors.white, fontSize: 18.0)),
              ),
              SizedBox(height: 20.0),
              _displayOnlyField("songId", widget.song.id),
              _displayOnlyField("userId", widget.song.userId?.toString() ?? 'Not Available'),
              _displayOnlyField("Main Artist", widget.song.mainArtistName),
              _buildFeaturingList(),
              _displayOnlyField("Album", widget.song.albumName),
              _displayOnlyField("Popularity", widget.song.popularity?.toString() ?? 'Not Available'),
              _displayOnlyField("Duration", widget.song.durationMs?.toString() ?? 'Not Available'),
              _displayOnlyField("Release Date", widget.song.releaseDate != null ? DateFormat('yyyy-MM-dd – kk:mm').format(widget.song.releaseDate!) : 'Not Available'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _displayOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18.0)),
          Text(value, style: TextStyle(fontSize: 16.0)),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildFeaturingList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Featuring Artists", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18.0),),
          SizedBox(height: 10),
          widget.song.featuringArtistNames != null && widget.song.featuringArtistNames!.isNotEmpty
              ? Column(
                  children: widget.song.featuringArtistNames!
                      .map((friend) => Text(friend, style: TextStyle(fontSize: 16)))
                      .toList(),
                )
              : Text("No featuring artists", style: TextStyle(fontSize: 16)),
          Divider(),
        ],
      ),
    );
  }
}