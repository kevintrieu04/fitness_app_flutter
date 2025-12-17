import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/firebase_options.dart';
import 'package:flutter/material.dart';

import '../utils/navigators/app_navigator.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.user});

  final User user;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String name = 'Anonymous';
  String level = 'Beginner';
  int tier = 1;
  int streak = 0;
  bool _hasDoneDaily = true;
  Timestamp _lastDoneDaily = Timestamp.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    final doc = await db.collection('users').doc(widget.user.uid).get();

    if (doc.exists) {
      setState(() {
        name = doc.data()!['name'];
        level = doc.data()!['level'];
        tier = doc.data()!['tier'];
        streak = doc.data()!['streak'];
        _lastDoneDaily = doc.data()!['lastDoneDaily'];
      });
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDoneDate = _lastDoneDaily.toDate();
    final lastDoneDay = DateTime(
      lastDoneDate.year,
      lastDoneDate.month,
      lastDoneDate.day,
    );

    if (lastDoneDay.isBefore(today)) {
      setState(() {
        _hasDoneDaily = false;
        if (today.difference(lastDoneDay).inDays > 1) {
          streak = 0;
        }
      });
    } else {
      setState(() {
        _hasDoneDaily = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.user.photoURL != null
                  ? NetworkImage(widget.user.photoURL!)
                  : null,
            ),
            SizedBox(height: 20),
            Text('Name: $name'),
            Text('Email: ${widget.user.email}'),
            Text('Level: $level'),
            Text('Tier: $tier'),
            Text('Streak: $streak'),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
              },
              child: Text("Log out"),
            ),
            if (!_hasDoneDaily) ...[
              SizedBox(height: 50),
              Text("You have not done the daily exercise yet!"),
              Text("Click the button below to do it!"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final results = await AppNavigator.doDailyExercise(
                    context,
                    level,
                    tier,
                  );
                  setState(() {
                    _hasDoneDaily = results[0];
                    if (results[1]) {
                      streak++;
                      if (tier < 5) {
                        tier++;
                      } else {
                        switch (level) {
                          case 'Beginner':
                            level = 'Intermediate';
                            break;
                          case 'Intermediate':
                            level = 'Advanced';
                            break;
                          default:
                            break;
                        }
                      }
                      db.collection('users').doc(widget.user.uid).update({
                        'streak': streak,
                        'level': level,
                        'tier': tier,
                        'lastDoneDaily': Timestamp.now(),
                      });
                    }
                  });
                },
                child: Text('Do Daily Exercise'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
