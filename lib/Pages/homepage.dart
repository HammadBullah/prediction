import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend body behind app bar for full effect
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0), // Custom height
        child: AppBar(
          backgroundColor: Colors.transparent, // Transparent background
          elevation: 0, // No shadow
          flexibleSpace: Center(
            child: Text(
              'Prediction',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  fontSize: 24, // Adjust font size as needed
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: _buildMenuDrawer(context), // Drawer with menu
      body: Stack(
        children: [
          Column(
            children: [
              _buildImageCard(context), // Image card
              Expanded(
                child: Center(
                  child: Text(
                    'Welcome to the Home Page!',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Container hovering over the card and white background
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45, // Adjust position for hovering effect
            left: 30,
            right: 30,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white, // White background for the container
                borderRadius: BorderRadius.circular(22), // Rounded edges
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Soft shadow for hover effect
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButtonWithIcon(
                    label: 'Location',
                    icon: Icons.pin_drop_outlined,
                    onPressed: () {
                      // Handle button press
                    },
                  ),
                  _buildDashedLine(), // Dashed line between buttons
                  _buildButtonWithIcon(
                    label: 'camera',
                    icon: Icons.image,
                    onPressed: () {
                      // Handle button press
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Button with icon
  Widget _buildButtonWithIcon({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.green),
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // Dashed line widget
  Widget _buildDashedLine() {
    return Container(
      height: 40, // Height of the dashed line
      width: 2, // Thickness of the line
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.green, // Green color for the dashed line
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: List.generate(10, (index) {
          return Expanded(
            child: Container(
              color: index % 2 == 0 ? Colors.transparent : Colors.green,
            ),
          );
        }),
      ),
    );
  }

  // Image card layout with overlay text
  Widget _buildImageCard(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // 40% of the screen height
      width: MediaQuery.of(context).size.width, // Full width
      child: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/agriculture-working-field-harvesting-sunny-day-vector-flat-illustration_939711-1177.png'), // Replace with your image asset
                fit: BoxFit.cover, // Make the image cover the entire card
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          // Text overlay
          Positioned(
            top: 100, // Adjusted to be below app bar
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Name',
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // White color for contrast
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Here is the information related to your land',
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black, // Lighter white text
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Transparent drawer for the menu
  Widget _buildMenuDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1), // Semi-transparent background
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50), // Space for status bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            Divider(color: Colors.white), // Divider for sections
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle settings action
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Log Out', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle log out action
                Navigator.pop(context); // Close the drawer
                // Add log out logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy Settings page
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
