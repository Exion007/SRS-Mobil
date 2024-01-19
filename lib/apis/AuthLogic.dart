import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../pages/MainPage.dart';
import '../pages/AdminPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<void> loginRequest(
  
  // ***** LOGIN REQUEST
  BuildContext context,
  String email,
  String password
  ) async {
  var url = Uri.parse('http://10.0.2.2:5001/auth/login');
  var data = {'email': email, 'password': password};

  try {
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody != null && responseBody['token'] != null) {
        String token = responseBody['token'];
        await storage.write(key: 'token', value: token);

        await fetchAndStoreUserData(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed: No token received.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error logging in. Please check your credentials.')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Error connecting to the server. Please try again later.')),
    );
  }
}

Future<void> registerRequest(
    
    // ***** REGISTER REQUEST
    BuildContext context,
    String username,
    String email,
    String password
  ) async {
  var url = Uri.parse('http://10.0.2.2:5001/auth/register');
  var data = {
    'name': username,
    'username': username,
    'email': email,
    'password': password,
  };

  try {
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Registration successful');
      var responseBody = json.decode(response.body);
      if (responseBody != null && responseBody['token'] != null) {
        String token = responseBody['token'];
        await storage.write(key: 'token', value: token); // Store the token

        await fetchAndStoreUserData(context);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MainPage()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!')),
        );
      }
    } else {
      print('Registration failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Error registering. Please check your details and try again.')),
      );
    }
  } catch (error) {
    print('Error making the request: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Error connecting to the server. Please try again later.')),
    );
  }
}

Future<void> fetchAndStoreUserData(context) async {
  var url = Uri.parse('http://10.0.2.2:5001/auth/me');
  String? token = await storage.read(key: 'token');

  var response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body)['data'];
    await storage.write(key: 'userId', value: data['_id']);
    String role = data['role'];
    if (role == 'admin') {
      // Navigate to the AdminPage if the user is an admin
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const AdminPage()));
    } else {
      // Navigate to the MainPage for regular users
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainPage()));
    }
  } else {
    throw Exception('Failed to fetch user data');
  }
}

Future<void> forgotPasswordRequest(BuildContext context, String email) async {
  var url = Uri.parse('http://10.0.2.2:5001/auth/forgotpassword');
  var data = {'email': email};

  try {
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      if (responseBody['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['data'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send email: ${responseBody['data']}')),
        );
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password.')),
      );
    }
  } catch (error) {
    print('Error making the request: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Error connecting to the server. Please try again later.')),
    );
  }
}
