import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prediction/Pages/resultpage.dart';

import 'homepage.dart';
import 'mappage.dart';

// Dummy classes for other pages (implement these separately)


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _picker = ImagePicker();
  LatLng? _currentLocation;
  final List<LatLng> _locationHistory = []; // List to store location history
  int _selectedIndex = 3; // Keep Settings selected by default

  String _locationMessage = "Location not yet fetched";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultPage()), // Navigate to the ResultPage
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
    }
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return Future.error('Location permissions are denied.');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationMessage =
      "Current location: ${position.latitude}, ${position.longitude}";
      _locationHistory.insert(
          0, _currentLocation!); // Store new location at the top
    });

    print(_locationMessage);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        // You can store the picked image if needed
        print("Image picked: ${pickedFile.path}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Center(
            child: Text(
              'Settings',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildImageCard(context), // Keep the image card at the top
              Expanded(
                child: _buildSettingsPage(),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery
                .of(context)
                .size
                .height * 0.40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                      _getCurrentLocation();
                    },
                  ),
                  _buildDashedLine(),
                  _buildButtonWithIcon(
                    label: 'Image',
                    icon: Icons.image,
                    onPressed: () {
                      _pickImage();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    bottomNavigationBar: Container(
    margin: EdgeInsets.only(left: 16, right: 16, bottom: 20),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(50),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 20,
    blurStyle: BlurStyle.outer,
    ),
    ],
    ),
    child: BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.map_outlined),
    label: 'Map',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.image),
    label: 'Result',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.settings_applications),
    label: 'Settings',
    ),
    ],
    currentIndex: _selectedIndex,
    unselectedItemColor: Colors.grey,
    selectedItemColor: Colors.green,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    iconSize: 30,
    selectedIconTheme: IconThemeData(
    size: 40,
    ),
    onTap: _onItemTapped, // Use this function to update the selected index
    backgroundColor: Colors.transparent,
    elevation: 0,
    selectedLabelStyle: GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    ),
    unselectedLabelStyle: GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    ),
    ),
    ),
    );
  }

  Widget _buildSettingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: Icon(Icons.account_circle, color: Colors.green),
          title: Text(
              'Account Settings', style: GoogleFonts.montserrat(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to account settings
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.notifications, color: Colors.green),
          title: Text('Notification Settings',
              style: GoogleFonts.montserrat(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to notification settings
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.privacy_tip, color: Colors.green),
          title: Text(
              'Privacy Policy', style: GoogleFonts.montserrat(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to privacy policy
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.help_outline, color: Colors.green),
          title: Text(
              'Help & Support', style: GoogleFonts.montserrat(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to help and support
          },
        ),
      ],
    );
  }

  Widget _buildButtonWithIcon({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 30),
          SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return Container(
      height: 40,
      child: VerticalDivider(
        color: Colors.grey[400],
        thickness: 1.5,
      ),
    );
  }


  Widget _buildImageCard(BuildContext context) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.5, // 50% of the screen height
      width: MediaQuery
          .of(context)
          .size
          .width, // Full width
      child: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/agriculture-tractor-harvester-working-field-harvesting-sunny-day-vector-flat-illustration_939711-546.png'),
                // Replace with your image asset
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          // Text overlay
          Positioned(
            top: 100,
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
                      color: Colors.black,
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
                      color: Colors.black,
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
}