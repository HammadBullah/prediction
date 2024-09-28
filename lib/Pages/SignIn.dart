import 'package:flutter/material.dart';

import 'SignUp.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildGradientCard(context), // Gradient card at the top
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    _buildSocialLoginButtons(),
                    SizedBox(height: 20),
                    Text(
                      'Or use email to sign in',
                      style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 20),
                    _buildLoginForm(),
                    SizedBox(height: 20),
                    _buildFooter(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/agriculture-working-field-harvesting-sunny-day-vector-flat-illustration_939711-1178.png'),
          fit: BoxFit.cover,  // This will ensure the image covers the entire background
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7), // Optional: To darken the image
            BlendMode.darken,  // Optional: You can adjust this as needed
          ),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 8, // Blur radius
            offset: Offset(0, 4), // Offset for shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(40, 0, 0, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please enter the required information to Log In.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.green),
            ),
            prefixIcon: Icon(Icons.email, color: Colors.green),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.green),
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.green),
          ),
        ),
        SizedBox(height: 20),
        _buildGradientButton(text: 'Sign In', onPressed: () {}),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.g_mobiledata, color: Colors.black),
                label: Text(
                  'Sign in with Google',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(70),
                    side: BorderSide(width: 1, color: Colors.grey),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 70),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Don’t have an account?'),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(FadePageRoute(page: SignUpPage()));
          },
          child: Text('Sign Up',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(70),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade500, Colors.green.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(70),
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            minHeight: 70,
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}