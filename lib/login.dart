import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:HPGM/navbar.dart';
import 'package:HPGM/splashscreen.dart';
import 'package:HPGM/Services/notifi_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

final TextEditingController usernamecontroller = TextEditingController();
final TextEditingController passwordcontroller = TextEditingController();
var mytoken = '';

Future<void> Logmein(BuildContext context) async {
  print(
      "Username: ${usernamecontroller.text}, Password: ${passwordcontroller.text}");
  var headers = {'Accept': 'application/json'};
  var request = http.MultipartRequest(
      'POST', Uri.parse('https://www.ademnea.net/api/v1/login'));
  request.fields.addAll(
      {'email': usernamecontroller.text, 'password': passwordcontroller.text});
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    String responseBody = await response.stream.bytesToString();
    Map<String, dynamic> responseData = jsonDecode(responseBody);
    String token = responseData['token'];
    saveToken(token);

    // Print success message
    // print(token);

    Fluttertoast.showToast(
        msg: "Successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);

    // Log the farmer in
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => navbar(
          token: mytoken,
        ),
      ),
    );
  } else {
    // Print "unauthorized"
    // print("Wrong credentials!");
    print(response.reasonPhrase);
    Fluttertoast.showToast(
        msg: "Wrong Credentials!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

void saveToken(String token) {
  // For simplicity, let's store it in a global variable
  mytoken = token;
}

//functions to launch the external url.
final Uri _url = Uri.parse('http://wa.me/+256755088321');

Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

// void saveToken(String token) {
//   mytoken = token;
// }

// final Uri _url = Uri.parse('http://wa.me/+256755088321');

// Future<void> _launchUrl() async {
//   if (!await launchUrl(_url)) {
//     throw Exception('Could not launch $_url');
//   }
// }

class _loginState extends State<login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown.shade100, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                SizedBox(height: 100),
                Container(
                  child: Image.asset(
                    'lib/images/log-1.png',
                    height: 200,
                    width: 200,
                  ),
                ),
                SizedBox(height: 40),
                _buildTextField(
                  controller: usernamecontroller,
                  labelText: 'Email',
                  icon: Icons.person,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: passwordcontroller,
                  labelText: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 206, 109, 40),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Logmein(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 206, 109, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Have no account?"),
                    SizedBox(width: 5),
                    TextButton(
                      onPressed: _launchUrl,
                      child: Text(
                        "contact support team to register",
                        style: TextStyle(
                          color: Color.fromARGB(255, 206, 109, 40),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Colors.brown.shade50,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(icon, color: Color.fromARGB(255, 206, 109, 40)),
          ),
        ),
        style: TextStyle(
          height: 1.5,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
