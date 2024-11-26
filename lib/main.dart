// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
FlutterSoundRecorder recorder = FlutterSoundRecorder();



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HearMeWell',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background_image.png',
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 320.0, left: 20.0), // Adjust top and left padding as needed
                  child: Image.asset(
                    'assets/images/HearMeWellLogo.jpg',
                    height: 180,
                  ),
                ),
                // Text and Button Column
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0), // Adjust alignment for the text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Name "HearMeWell"
                      Text(
                        'HearMeWell',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F80ED),
                        ),
                      ),
                      // Arabic Phrase
                      Text(
                        'لتسهيل التواصل',
                        style: TextStyle(
                          fontSize: 25,
                          color: Color(0xFF2F80ED),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                // Get Started Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 70.0, right: 20.0), // Adjust to position above the wave
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                        // Navigation logic
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)), // Dark blue border
                        ),
                        backgroundColor: Colors.transparent, // Transparent background
                        elevation: 0, // No shadow
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white, // Set the background color to white
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
   @override
    _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

    // Function to log in the use
    Future<void> _loginUser() async {
  try {
    // Capture phone number and password
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // Log the values to debug
    print("Phone number entered: $phoneNumber");
    print("Password entered: $password");

    if (phoneNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number and password.')),
      );
      return;
    }

    // Firestore query (already correct)
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone_number', isEqualTo: phoneNumber)
        .where('password', isEqualTo: password)
        .get();

    if (querySnapshot.docs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number or password.')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            username: querySnapshot.docs[0]['full_name'],
          ),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    print("Error during login: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 350), // Adjust top padding as needed

                // Login Text
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F80ED),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Phone Number TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _phoneController, // <-- Add this line to bind the controller
                    keyboardType: TextInputType.phone, // Set input type to phone
                    cursorColor: Color(0xFF2F80ED), // Set the cursor color to blue
                    style: TextStyle(
                      color: Color(0xFF2F80ED), // Set text color to blue
                      ),

                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                        color: Color(0xFF2F80ED), // Consistent label color
                      ),

                      floatingLabelStyle: TextStyle(
                        color: Color(0xFF2F80ED), // Ensure label stays blue when focused
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 112, 148, 195)), 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2F80ED)),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Password TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _passwordController,
                    cursorColor: Color(0xFF2F80ED), // Set the cursor color to blue
                    style: TextStyle(
                      color: Color(0xFF2F80ED), // Set text color to blue
                      ),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color(0xFF2F80ED), // Consistent label color
                        ),

                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF2F80ED), // Ensure label stays blue when focused
                          ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 112, 148, 195)), // Use your desired color here
                        borderRadius: BorderRadius.circular(10.0),
                        ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2F80ED)),
                        borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),

                // Forgot Password link
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to Forgot Password screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(), // Define the screen to navigate to
                          ),
                        );
                      },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF2F80ED),
                      ),
                    ),
                    
                    
                  ),
                ),
                ),
                Spacer(),

                // Login Button
                Padding(
                  padding: EdgeInsets.only(right: 18, bottom: 60),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed:  _loginUser,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),

                // Register Link
                Padding(
                  padding: EdgeInsets.only(left: 32, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'New Here?',
                        style: TextStyle(
                         color: Color.fromARGB(255, 243, 243, 243),
                         fontSize: 15,
                         //fontWeight: FontWeight.Regular,
                      ),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          // Navigate to RegisterScreen when tapped
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                            ); 
                          },

                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Color.fromARGB(255, 243, 243, 243),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final bool _isVerificationCodeCorrect = false; // Flag to show/hide new password field
  String _verificationId = "123"; // Replace with your verification logic

Future<void> sendVerificationCode() async {
    final phoneNumber = _phoneController.text.trim();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto sign-in flow; not typically used for resetting the password
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification code sent!')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }


  Future<void> verifyCodeAndUpdatePassword() async {
    
    final smsCode = _verificationCodeController.text.trim();

    try{

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
// Sign the user in and update password
      final user = await FirebaseAuth.instance.signInWithCredential(credential);

       // ignore: unnecessary_null_comparison
       if (user != null) {
        
        await user.user!.updatePassword(_verificationCodeController.text);
                if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset successful')),
        );
        Navigator.pop(context); // Navigate back to login screen
      }
    } catch (e) {
              if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 305), // Adjust top padding as needed

                // Forgot Password Text
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F80ED),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Phone Number TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _phoneController,
                    cursorColor: Color(0xFF2F80ED),
                    style: TextStyle(color: Color(0xFF2F80ED)),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: Color(0xFF2F80ED)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2F80ED)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2F80ED)),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

             // Button to send verification code
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: sendVerificationCode, // Link function here
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 3), // Adjust padding to change button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Color(0xFF2F80ED), // Set the button color
                      foregroundColor: Colors.white, // Set the text color
                    ),
                    child: Text(
                      'Send Verification Code',
                      style: TextStyle(fontSize: 10), // Adjust font size to change text size
                    ),
                  ),
                ),
                
                // Verification Code TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _verificationCodeController,
                    cursorColor: Color(0xFF2F80ED),
                    style: TextStyle(color: Color(0xFF2F80ED)),
                    decoration: InputDecoration(
                      hintText: 'Enter Verification Code sent to phone number',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 112, 148, 195)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2F80ED)),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      // Call verifyCode method when the verification code is entered
                      verifyCodeAndUpdatePassword();
                    },
                  ),
                ),
                SizedBox(height: 20),

                // New Password TextField (shown only if verification code is correct)
                if (_isVerificationCodeCorrect)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: _newPasswordController,
                      cursorColor: Color(0xFF2F80ED),
                      style: TextStyle(color: Color(0xFF2F80ED)),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(color: Color(0xFF2F80ED)),
                        floatingLabelStyle: TextStyle(color: Color(0xFF2F80ED)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ) else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: _newPasswordController,
                      cursorColor: Color(0xFF2F80ED),
                      style: TextStyle(color: Colors.grey), // Light grey color when disabled
                      obscureText: true,
                      enabled: false, // Disable input
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(color: Colors.grey), // Grey label when code is incorrect
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                Spacer(),

                // Login Button
                Padding(
                  padding: EdgeInsets.only(right: 18, bottom: 60),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add login action
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                // Register Link
                Padding(
                  padding: EdgeInsets.only(left: 32, bottom: 30),
                  child: Row(
                    children: [
                      Text(
                        'New Here?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 243, 243, 243),
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Register',
                        style: TextStyle(
                          color: Color.fromARGB(255, 243, 243, 243),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

    @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedHearingLevel;
  //String? _verificationId='123'; // Declare _verificationId here
  // Firebase instances
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> _registerUser() async {
  try {
    final email = "${_phoneController.text}@example.com";
    final password = _passwordController.text;

    // Check if the email already exists
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (signInMethods.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number is already registered. Please log in.')),
      );
      return;
    }

    // Create a Firebase Authentication user
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'full_name': _fullNameController.text,
        'phone_number': _phoneController.text,
        'level_of_hearing': selectedHearingLevel,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background_image.png', // Use your background image path
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 275), // Adjust top padding as needed

                  // Register Text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F80ED),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Full Name TextField
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: _fullNameController,
                      cursorColor: Color(0xFF2F80ED),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Color(0xFF2F80ED)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Phone Number TextField
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: _phoneController,
                      cursorColor: Color(0xFF2F80ED),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: Color(0xFF2F80ED)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Password TextField
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      cursorColor: Color(0xFF2F80ED),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Color(0xFF2F80ED)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Level of Hearing Dropdown
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Level of Hearing',
                        labelStyle: TextStyle(color: Color(0xFF2F80ED)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2F80ED)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      items: <String>[
                        'Hearing',
                        'Hard Of Hearing',
                        'Deaf'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedHearingLevel =value;
                        });
                      },
                    ),
                  ),
                  Spacer(),

                  // Register Button
                  Padding(
                    padding: EdgeInsets.only(right: 20, bottom: 20),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: BorderSide(color: Colors.white),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Login Link
                  Padding(
                    padding: EdgeInsets.only(left: 32, bottom: 45),
                    child: Row(
                      children: [
                        Text(
                          'Already Member?',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            
          ),
        ],
      ),
    );
  }
}



class ChatPage extends StatefulWidget {
  final String username;

  const ChatPage({super.key, required this.username});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final List<Map<String, String>> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  bool _isInitialized = false; // Tracks recorder/player initialization
  bool _isRecording = false; // Tracks recording state

  @override
  void initState() {
    super.initState();
    _initializeAudioComponents();
  }

  Future<void> _initializeAudioComponents() async {
    try {
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission is required.")),
        );
        return;
      }

      await _recorder.openRecorder();
      await _player.openPlayer();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print("Error initializing recorder/player: $e");
    }
  }

  Future<void> startRecording() async {
    await _recorder.startRecorder(toFile: 'audio_message.aac');
    setState(() {
      _isRecording = true;
    });
  }

  Future<String?> stopRecording() async {
    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        final originalFile = File(path);
        final wavFilePath = path.replaceAll('.aac', '.wav');
        final wavFile = File(wavFilePath);

        // Rename or convert the file to .wav
        await originalFile.rename(wavFile.path);
        print("File converted to WAV: $wavFilePath");
        return wavFile.path;
      }
    }
    return null;
  }

  Future<void> uploadAudio(String filePath) async {
    final file = File(filePath);
    final uri = Uri.parse('http://192.168.10.5:5000/process-audio');

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('audio', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Audio uploaded successfully');
    } else {
      print('Failed to upload audio');
    }
  }

  Future<void> _playRecording(String filePath) async {
    try {
      await _player.startPlayer(fromURI: filePath);
      print('Playing recording from: $filePath');
    } catch (e) {
      print('Error during playback: $e');
    }
  }

  Future<void> processAudio(String filePath) async {
    try {
      // Check if the file exists locally
      File file = File(filePath);
      if (!file.existsSync()) {
        print("File does not exist at: $filePath");
        setState(() {
          _messages.add({
            "type": "error",
            "content": "Error: File does not exist locally."
          });
        });
        return;
      }

      // Prepare and send the HTTP request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.10.5:5000/process-audio'),
      );
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var data = jsonDecode(responseData.body);

        // Check if emotion exists in the response
        if (data.containsKey("emotion")) {
          setState(() {
            _messages.add({
              "type": "voice",
              "content": filePath,
              "text": data["transcription"] ?? "",
              "emotion": data["emotion"],
            });
          });
        } else {
          setState(() {
            _messages.add({
              "type": "error",
              "content": "Error: Emotion data missing in server response."
            });
          });
        }
      } else {
        print("Server error: ${response.statusCode}");
        setState(() {
          _messages.add({
            "type": "error",
            "content": "Server Error: ${response.reasonPhrase}"
          });
        });
      }
    } catch (e) {
      print("Exception during audio processing: $e");
      setState(() {
        _messages.add({
          "type": "error",
          "content": "Exception: Failed to process audio."
        });
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          "type": "text",
          "content": _messageController.text.trim(),
        });
      });
      _messageController.clear();
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    final messageType = message["type"];
    if (messageType == "text") {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message["content"]!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (messageType == "voice") {
      final emotionColor = _getEmotionColor(message["emotion"]!);
      final emotionEmoji = _getEmotionEmoji(message["emotion"]!);

      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: emotionColor, width: 2),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transcription: ${message["text"] ?? ""}",
                style: const TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Icon(Icons.emoji_emotions, color: emotionColor),
                  const SizedBox(width: 5),
                  Text(
                    emotionEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              VoiceMessageWidget(
                filePath: message["content"]!,
                emotion: message["emotion"]!,
                playCallback: () => _playRecording(message["content"]!),
              ),
            ],
          ),
        ),
      );
    } else if (messageType == "error") {
      return Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message["content"] ?? "An error occurred",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Unknown message type",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case "happy":
        return "😊";
      case "angry":
        return "😡";
      case "sad":
        return "😢";
      case "calm":
        return "😌";
      case "disgust":
        return "🤢";
      case "fear":
        return "😱";
      case "surprise":
        return "😲";
      default:
        return "😶";
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case "happy":
        return Colors.yellow;
      case "angry":
        return Colors.red;
      case "sad":
        return Colors.blue;
      case "calm":
        return Colors.green;
      case "disgust":
        return Colors.purple;
      case "fear":
        return Colors.black;
      case "surprise":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : Colors.blue,
                  ),
                  onPressed: _isRecording ? () async {
                    final path = await stopRecording();
                    if (path != null) {
                      processAudio(path);
                    }
                  } : startRecording,
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceMessageWidget extends StatelessWidget {
  final String filePath;
  final String emotion;
  final VoidCallback playCallback;

  const VoiceMessageWidget({
    Key? key,
    required this.filePath,
    required this.emotion,
    required this.playCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: playCallback,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Text(
              'Voice Message ($emotion)',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
