import 'dart:io';
import 'dart:convert';
import 'AuthLogic.dart';
import '../models/userModel.dart';
import 'package:http/http.dart' as http;

class AdminLogic {

  final String baseUrl = 'http://10.0.2.2:5001/users';

  Future<List<User>> fetchUsers() async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var response = await http.get(Uri.parse('http://10.0.2.2:5001/users'), headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      var usersJson = data['users'] as List;
      
      return usersJson.map<User>((json) => User.fromJson(json)).toList();
    } else {
      print('Request failed with status: ${response.statusCode}.');
      throw Exception('Failed to load users');
    }
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("User added successfully!");
      var data = json.decode(response.body);
      print(data);
    } else {
      throw Exception('Failed to add user: ${response.body}');
    }
  }

  Future<void> deleteUser(String userId) async {

    String? token = await storage.read(key: 'token');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var response = await http.delete(
      Uri.parse('$baseUrl/$userId'),
      headers: headers
      );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("User deleted successfully!");
    } else {
      throw Exception('Failed to delete user');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    
    String? token = await storage.read(key: 'token');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var response = await http.put(
      Uri.parse('$baseUrl/$userId'),
      body: json.encode(userData),
      headers: headers
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("User updated successfully!");
      var data = json.decode(response.body);
      print(data);
    } else {
      throw Exception('Failed to update user');
    }
  }
}