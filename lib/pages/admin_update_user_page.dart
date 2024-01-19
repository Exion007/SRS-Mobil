import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late String _username;
  late String _role;
  late DateTime _createdAt;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _username = widget.user.username;
    _role = widget.user.role;
    _createdAt = widget.user.createdAt;
  }

  void _updateUser() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      AdminLogic adminLogic = AdminLogic();

      Map<String, dynamic> updatedData = {
        'name': _name,
        'username': _username,
        'role': _role,
        'createdAt': _createdAt.toIso8601String(),
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

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _createdAt,
      firstDate: DateTime(2020),
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
                decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 24.0)),
                cursorColor: Colors.green,
                onSaved: (value) => _name = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(labelText: 'Username', labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 24.0)),
                cursorColor: Colors.green,
                onSaved: (value) => _username = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a username' : null,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: _role,
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 24.0)
                ),
                cursorColor: Colors.green,
                onSaved: (value) => _role = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a role';
                  } else if (value != 'normal' && value != 'admin') {
                    return 'Role must be either "normal" or "admin"';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                    onPressed: () => _selectDate(context),
                    child: const Text("Select Creation Date", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ),
                  SizedBox(width: 30),
                  Text(
                    DateFormat('yyyy-MM-dd').format(_createdAt),
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              _displayOnlyField("ID", widget.user.id),
              _displayOnlyField("Email", widget.user.email),
              _buildFriendsList(),
              ElevatedButton(
                onPressed: _updateUser,
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                child: Text('Update User', style: TextStyle(color: Colors.white, fontSize: 18.0)),
              ),
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

  Widget _buildFriendsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Friends", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18.0),),
          SizedBox(height: 10),
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