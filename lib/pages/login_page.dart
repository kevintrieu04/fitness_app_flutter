import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/firebase_options.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _retypedPassword = '';
  String _name = 'Anonymous';

  Future<void> _checkInfo() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    if (_isSignUp && password != _retypedPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
    } else if (_isSignUp && password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
    } else {
      try {
        if (_isSignUp) {
          await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          db.collection('users').doc(auth.currentUser!.uid).set({
            'uid': auth.currentUser!.uid,
            'name': _name,
            'email': email,
            'password': password,
            'lastDoneDaily': Timestamp.fromDate(DateTime(2017,9,7,17,30)),
            'level': 'Beginner',
            'tier' : 1,
            'streak': 0,
          });
        } else {
          await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email')),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wrong password provided for that user'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Sign Up' : 'Login')),
      body: Center(
        child: Column(
          children: [
            if (_isSignUp)
              TextField(
                decoration: const InputDecoration(hintText: 'Name'),
                onChanged: (value) {
                  _name = value;
                },
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            if (_isSignUp)
              TextField(
                decoration: const InputDecoration(hintText: 'Confirm Password'),
                obscureText: true,
                onChanged: (value) {
                  _retypedPassword = value;
                },
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _checkInfo,
              child: Text(_isSignUp ? 'Sign Up' : 'Login'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(
                _isSignUp ? 'I already have an account' : 'Create an account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
