import '../apis/AdminLogic.dart';
import '../models/userModel.dart';
import '../pages/admin_add_user_page.dart';
import '../pages/admin_update_user_page.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final AdminLogic _adminLogic = AdminLogic();
  late Future<List<User>> _usersFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersFuture = _adminLogic.fetchUsers();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _usersFuture = _adminLogic.fetchUsers();
      } else {
        _usersFuture = _adminLogic.fetchUsers().then((users) {
          return users.where((user) => user.username.toLowerCase().contains(query.toLowerCase())).toList();
        });
      }
    });
  }

  void _confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Confirm Delete'),
          titleTextStyle: const TextStyle(fontSize: 25, color: Colors.red),
          content: Text('Are you sure you want to delete this user?'),
          contentTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            side: BorderSide(color: Colors.red, width: 2.5),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.blue, fontSize: 20.0),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red, fontSize: 20.0),),
              onPressed: () {
                _adminLogic.deleteUser(userId).then((_) {
                  Navigator.of(context).pop();
                  _showSnackBar("User deleted successfully", Colors.red);
                  _refreshUserList();
                }).catchError((error) {
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _refreshUserList() {
    _searchController.clear();
    setState(() {
      _usersFuture = _adminLogic.fetchUsers();
    });
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _navigateToAddUser() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddUserPage()),
    ).then((_) {
      _refreshUserList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddUser,
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white),));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<User> users = snapshot.data!;
                  users.sort((a, b) => a.username.compareTo(b.username));

                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.green),
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return ListTile(
                        title: Text(user.username, style: const TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_upward, color: Colors.blue),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => UpdateUserPage(user: users[index])),
                                ).then((_) {
                                  _refreshUserList();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _confirmDeleteUser(users[index].id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No users found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}