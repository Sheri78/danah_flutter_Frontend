// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



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
  final List<Map<String, String>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool isUploading = false;
  double uploadProgress = 0.0;


  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    final micPermission = await Permission.microphone.request();
    if (micPermission.isGranted) {
      await _recorder.openRecorder();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission is required.")),
      );
    }
  }

  Future<void> _startRecording() async {
    if (!_recorder.isRecording) {
      await _recorder.startRecorder(toFile: 'temp.wav');
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> processAudio(String filePath) async {
  try {
    setState(() {
      isUploading = true; // Start showing progress
      uploadProgress = 0.0; // Reset progress
    });

    var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/process-audio'));
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));

    // Send the request and handle response
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var data = jsonDecode(responseData.body);

      setState(() {
        _messages.add({
          "type": "voice",
          "content": filePath,
          "text": data["text"],
          "emotion": data["emotion"],
        });
        uploadProgress = 1.0; // Upload complete
      });
    } else {
      var errorResponse = await http.Response.fromStream(response);
      print("Error response: ${errorResponse.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading audio: ${errorResponse.body}")),
      );
    }
  } catch (e) {
    print("Error processing audio: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to upload audio: $e")),
    );
  } finally {
    setState(() {
      isUploading = false; // Stop showing progress
    });
  }
}



  Future<void> _stopRecording() async {
  if (_recorder.isRecording) {
    final tempPath = await _recorder.stopRecorder();
    final appDir = await getApplicationDocumentsDirectory();

    if (tempPath != null) {
      final savedPath = "${appDir.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.wav";
      await File(tempPath).copy(savedPath);
      await processAudio(savedPath); // Call the backend
    }
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
      default:
        return Colors.grey;
    }
  }

  Widget _buildMessage(Map<String, String> message) {
  final isText = message["type"] == "text";
  if (isText) {
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
  } else {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Transcription: ${message["text"] ?? ""}", style: TextStyle(fontSize: 16)),
          VoiceMessageWidget(
            filePath: message["content"]!,
            emotion: message["emotion"] ?? "neutral",
          ),
        ],
      ),
    );
  }
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text(widget.username)),
    body: Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[_messages.length - 1 - index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                  GestureDetector(
                    onLongPress: _startRecording,
                    onLongPressUp: _stopRecording,
                    child: Icon(
                      Icons.mic,
                      color: _isRecording ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isUploading)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: uploadProgress,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Uploading voice message...",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}


}

class VoiceMessageWidget extends StatefulWidget {
  final String filePath;
  final String emotion;

  const VoiceMessageWidget({super.key, required this.filePath, required this.emotion});

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setSource(DeviceFileSource(widget.filePath));
      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _duration = duration;
        });
      });
      _audioPlayer.onPositionChanged.listen((position) {
        setState(() {
          _position = position;
        });
      });
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      });
    } catch (e) {
      print("Error initializing audio player: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.blue,
            ),
            onPressed: () async {
              if (_isPlaying) {
                await _audioPlayer.pause();
              } else {
                await _audioPlayer.resume();
              }
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
