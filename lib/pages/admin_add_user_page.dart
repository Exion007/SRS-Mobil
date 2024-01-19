import 'package:flutter/material.dart';
import '../apis/AdminLogic.dart';

class AddUserPage extends StatefulWidget {
  AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _username;
  late String _email;
  late String _password;

  void _addUser() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      AdminLogic adminLogic = AdminLogic();

      Map<String, dynamic> userData = {
        'name': _name,
        'username': _username,
        'email': _email,
        'password': _password,
      };

      adminLogic.addUser(userData).then((_) {
        _showSnackBar("User added successfully!", Colors.green);
        Navigator.of(context).pop();
      }).catchError((error) {
        _showSnackBar("Failed to add user!", Colors.red);
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
        title: Text('Add User', style: TextStyle(color: Colors.white)),
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
              _buildTextField('Name', (value) => _name = value ?? ''),
              SizedBox(height: 10.0,),
              _buildTextField('Username', (value) => _username = value ?? ''),
              SizedBox(height: 10.0,),
              _buildTextField('Email', (value) => _email = value ?? ''),
              SizedBox(height: 10.0,),
              _buildTextField('Password', (value) => _password = value ?? '', obscureText: true, isPassword: true),
              SizedBox(height: 20.0,),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
                onPressed: _addUser,
                child: Text('Add User', style: TextStyle(color: Colors.white, fontSize: 18.0),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onSaved, {bool obscureText = false, bool isPassword = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18.0),
      ),
      obscureText: obscureText,
      onSaved: (value) => onSaved(value ?? ''),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isPassword && value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }
}