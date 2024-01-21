// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:srs_mobile/apis/AdminLogic.dart';

import '../models/friendModel.dart';
import '../models/invitationModel.dart';
import '../models/recommendationModel.dart';
import '../apis/MyFriends_Logic.dart';
import '../apis/recommendationsLogic.dart';
import '../pages/admin_music_page.dart';
import '../pages/admin_users_page.dart';
import '../pages/admin_charts_page.dart';
import '../pages/admin_friends_page.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 1;
  List<String> allowedFriendRecommendations = [];
  List<RecommendationModel> _recommendations = [];

  final List<Widget> _pageOptions = [
    const ChartsPage(),   // Index 0 - Admin Charts Page
    const UsersPage(),    // Index 1 - Admin Users Page
    const MusicPage(),    // Index 2 - Admin Music Page
    const FriendsPage(),  // Index 3 - Admin Friends Page
  ];

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showVisibilitySettings(BuildContext context) async {
    List<String> allowedFriendRecommendations = await MyFriendsLogic().fetchAllowedFriends();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          title: const Text(
            'Should friends see music recommendations?',
            style: TextStyle(color: Colors.green),
          ),
          content: SingleChildScrollView(
            child: FutureBuilder<List<Friend>>(
              future: MyFriendsLogic().fetchUserFriends(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                  return _noDataMessage('No friends yet.');
                } else {
                  List<Friend> friends = snapshot.data!;
                  return ListBody(
                    children: friends.map((Friend friend) {
                      return _VisibilitySetting(
                        username: friend.username,
                        friendId: friend.id,
                        initialValue: allowedFriendRecommendations.contains(friend.id),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showNotifications(BuildContext context) async {
    List<Invitation> invitations = [];

    try {
      invitations = await MyFriendsLogic().fetchUserInvitations() ?? [];
    } catch (e) {
      print('Error fetching invitations: $e');
    }

    if (_recommendations.isEmpty) {
      try {
        _recommendations = await fetchRecommendations(RecommendationType.friends) ?? [];  // Uncomment to activate recommendations
      } catch (e) {
        print('Error fetching recommendations: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.grey[800],
          child: ListView.separated(
            itemCount: max(invitations.length + _recommendations.length, 1),
            separatorBuilder: (_, __) => Divider(color: Colors.white),
            itemBuilder: (BuildContext context, int index) {
              if (index < invitations.length) {
                return buildInvitationTile(invitations[index], context);
              } else {
                int recommendationIndex = index - invitations.length;
                if (recommendationIndex < _recommendations.length) {
                  return buildRecommendationTile(_recommendations[recommendationIndex], context);
                }
                return SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

  Widget _noDataMessage(String message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        message,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  Widget buildInvitationTile(Invitation invitation, BuildContext context) {
    return Dismissible(
      key: Key(invitation.id),
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        await MyFriendsLogic().updateInvitationStatus(invitation.id, 'deleted');
        Navigator.pop(context);
      },
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Friend Request from ${invitation.userId}',
                style: const TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () async {
                await MyFriendsLogic().updateInvitationStatus(invitation.id, 'accepted');
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () async {
                await MyFriendsLogic().updateInvitationStatus(invitation.id, 'rejected');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecommendationTile(RecommendationModel recommendation, BuildContext context) {
    return Dismissible(
      key: Key(recommendation.songName),
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _recommendations.removeWhere((r) => r.songName == recommendation.songName);
        });
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: Image.network(
          recommendation.albumImg,
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: recommendation.songName,
                style: TextStyle(color: Colors.green, fontSize: 18.0),
              ),
              const TextSpan(text: '\n', style: TextStyle(color: Colors.white, fontSize: 18.0)),
              TextSpan(text: recommendation.mainArtistName, style: const TextStyle(color: Colors.white, fontSize: 18.0)),
            ],
          ),
        ),
        onTap: () async {
          bool confirmed = await showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                backgroundColor: Colors.grey[800],
                title: const Text('Confirm', style: TextStyle(color: Colors.blue, fontSize: 25.0),),
                titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
                content: Text('Do you want to add this song?'),
                contentTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  side: BorderSide(color: Colors.white, width: 2.5),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 20.0),),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('Add', style: TextStyle(color: Colors.green, fontSize: 20.0),),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                  ),
                ],
              );
            },
          ) ?? false;

          if (confirmed) {
            try {
              bool result = await AdminLogic().addSongInfo(
                recommendation.songName,
                recommendation.mainArtistName,
                [],
                recommendation.albumName,
              );

              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Song info added successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add song info'), backgroundColor: Colors.red),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
              );
            }

            setState(() {
              Navigator.pop(context);
              _recommendations.removeWhere((r) => r.songName == recommendation.songName);
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF171717),
        elevation: 0.0,
        centerTitle: true,
        title: Image.asset(
          'assets/logo_white.png',
          height: 55,
          width: 55,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showVisibilitySettings(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF171717),
      body: _pageOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onBottomNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Music',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
        ],
      ),
    );
  }
}

class _VisibilitySetting extends StatefulWidget {
  final String username;
  final String friendId;
  final bool initialValue;

  const _VisibilitySetting({
    required this.username,
    required this.friendId,
    required this.initialValue,
  });

  @override
  _VisibilitySettingState createState() => _VisibilitySettingState();
}

class _VisibilitySettingState extends State<_VisibilitySetting> {
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        widget.username,
        style: const TextStyle(color: Colors.white, fontSize: 20.0),
      ),
      value: _isVisible,
      onChanged: (bool value) async {
        setState(() {
          _isVisible = value;
        });

        try {
          if (_isVisible) {
            await MyFriendsLogic().allowFriendRecommendations(widget.friendId);
          } else {
            await MyFriendsLogic().disallowFriendRecommendations(widget.friendId);
          }
        } catch (e) {
          // Handle errors as needed
          print('Error: $e');
        }
      },
      activeColor: Colors.green,
    );
  }
}