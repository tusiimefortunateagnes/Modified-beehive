import 'package:HPGM/login.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  String _typedText = '';
  bool _isTyping = true;
  int _currentIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _startTypingEffect();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTypingEffect() {
    const text =
        'Welcome to the Honey Productivity, Guide and Monitor app (HPGM), the all in one app that will help you track your hive productivity on the go!';
    const typingInterval = Duration(milliseconds: 50); // Slightly faster typing

    _typingTimer = Timer.periodic(typingInterval, (timer) {
      if (_currentIndex < text.length) {
        setState(() {
          _typedText = text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        _typingTimer?.cancel();
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with gradient overlay
          Image.asset(
            'lib/images/njuki.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App title
                  const Text(
                    'HPGM',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Typing effect
                  Expanded(
                    child: Center(
                      child: Stack(
                        children: [
                          Text(
                            _typedText,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              height: 1.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                          if (_isTyping)
                            Positioned(
                              right: -10,
                              child: _buildCursor(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Get Started button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => login()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 15.0,
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCursor() {
    return Container(
      width: 3,
      height: 24,
      color: Colors.amber,
    );
  }
}
