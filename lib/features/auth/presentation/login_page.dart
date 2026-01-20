import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/design_tokens.dart';
import 'auth_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.isError = false, this.errorMessage});

  final bool isError;
  final String? errorMessage;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _retypedPassword = '';
  double _currentWeight = 0.0;
  double _goalWeight = 0.0;
  String _name = 'Anonymous';

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to show the SnackBar after the build is complete.
    if (widget.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(widget.errorMessage!)));
        }
      });
    }
  }

  @override
  void didUpdateWidget(LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the widget is updated and an error is present (and wasn't before).
    if (widget.isError && !oldWidget.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(widget.errorMessage!)));
        }
      });
    }
  }

  Future<void> _checkInfo(AuthViewModel authViewModel) async {
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
      if (_isSignUp) {
        authViewModel.signUp(
          email,
          password,
          _name,
          _currentWeight,
          _goalWeight,
        );
      } else {
        authViewModel.signIn(email, password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: AppBar(
        backgroundColor: DT.bg,
        elevation: 0,
        title: Text(
          _isSignUp ? 'Sign Up' : 'Login',
          style: TextStyle(
            color: DT.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
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
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isSignUp)
              TextField(
                decoration: const InputDecoration(hintText: 'Confirm Password'),
                obscureText: true,
                onChanged: (value) {
                  _retypedPassword = value;
                },
              ),
            const SizedBox(height: 20),
            if (_isSignUp)
              TextField(
                decoration: const InputDecoration(
                  hintText: 'What is your current weight?',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _currentWeight = double.parse(value);
                },
              ),
            const SizedBox(height: 20),
            if (_isSignUp)
              TextField(
                decoration: const InputDecoration(
                  hintText: 'What is your goal weight?',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _goalWeight = double.parse(value);
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkInfo(authViewModel);
              },
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
