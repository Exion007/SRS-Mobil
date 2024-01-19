import 'package:flutter/material.dart';
import '../models/userModel.dart';
import '../apis/AdminLogic.dart';

class UpdateUserPage extends StatefulWidget {
  final User user;

  UpdateUserPage({Key? key, required this.user}) : super(key: key);

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _email = widget.user.email;
  }

  void _updateUser() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      AdminLogic adminLogic = AdminLogic();

      Map<String, dynamic> updatedData = {
        'name': _name,
        'email': _email,
      };

      adminLogic.updateUser(widget.user.id, updatedData).then((_) {
        _showSnackBar("User information updated successfully!", Colors.green);
        Navigator.of(context).pop();
      }).catchError((error) {
        _showSnackBar("User information could not be updated!", Colors.red);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User', style: TextStyle(color: Colors.white)),
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
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18.0)),
                onSaved: (value) => _name = value!,
                cursorColor: Colors.green,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18.0)),
                cursorColor: Colors.green,
                onSaved: (value) => _email = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter an email' : null,
              ),
              _displayOnlyField("ID", widget.user.id),
              _displayOnlyField("Username", widget.user.username),
              _displayOnlyField("Role", widget.user.role),
              _displayOnlyField("Created At", widget.user.createdAt.toIso8601String()),
              _displayOnlyField("Version", widget.user.v.toString()),
              _buildFriendsList(),
              ElevatedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                onPressed: _updateUser,
                child: Text('Update User', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _displayOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(color: Colors.black, fontSize: 16)),
          SizedBox(height: 8),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Friends", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          widget.user.friends != null && widget.user.friends!.isNotEmpty
              ? Column(
                  children: widget.user.friends!
                      .map((friend) => Text(friend, style: TextStyle(fontSize: 16)))
                      .toList(),
                )
              : Text("No friends", style: TextStyle(fontSize: 16)),
          Divider(),
        ],
      ),
    );
  }
}