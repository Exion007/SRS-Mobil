// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:srs_mobile/apis/MySongs_Logic.dart';
import '../pages/recommendations.dart';
import '../pages/friends_page.dart';
import '../pages/add_remove_page.dart';
import '../pages/statisticsPage.dart';
import '../pages/home_page.dart';
import '../pages/main_page_content.dart';
import '../apis/MyFriends_Logic.dart';
import '../apis/recommendationsLogic.dart';
import '../models/friendModel.dart';
import '../models/invitationModel.dart';
import '../models/recommendationModel.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;
  List<RecommendationModel> _recommendations = [];
  List<String> allowedFriendRecommendations = [];
  List<Widget> _widgetOptions = [];

  Widget _placeholderWidget() {
    return const Center(
      child: Text('Page under construction',
          style: TextStyle(color: Colors.white, fontSize: 30.0)),
    );
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions.addAll([
      _placeholderWidget(),  //const RecommendationsPage(), // Index 0 - Recommendations page
      const AddRemovePage(),       // Index 1 - Add-Remove page
      const MainPageContent(),     // Index 2 - Home page content
      const FriendsPage(),         // Index 3 - Friends page
      const StatisticsPage(),      // Index 4 - Statistics Page
    ]);
  }

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
        _recommendations = await fetchRecommendations(RecommendationType.song) ?? [];  // Uncomment to activate recommendations
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
              bool result = await SongService().addSongInfo(
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
      backgroundColor: const Color(0xFF171717),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF171717),
        leading: IconButton(
          icon: Icon(Icons.power_settings_new_rounded, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logout successful'),
                backgroundColor: Colors.green,
              ),
            );

            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            });
          },
        ),
        title: Image.asset(
          'assets/logo_white.png',
          height: 55,
          width: 55,
        ),
        centerTitle: true,
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[600],
        currentIndex:
            _selectedIndex, // This is used to update the selected item
        onTap: _onBottomNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'Recommendations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add-Remove',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
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