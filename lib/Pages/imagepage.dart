import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  LatLng? _currentLocation;

  final List<Widget> _pages = [];
  final List<LatLng> _locationHistory = []; // List to store location history

  String _locationMessage = "Location not yet fetched";

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _buildHomePage(),
      _buildMap(),
      _buildImagePage(),
      Center(child: Text('Settings')),
    ]);
    _getCurrentLocation();
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
      _locationMessage = "Current location: ${position.latitude}, ${position.longitude}";
      _locationHistory.insert(0, _currentLocation!); // Store new location at the top
    });

    print(_locationMessage);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));  // Add captured image to the list
        _selectedIndex = 2;  // Automatically navigate to the ImagePage after capturing the image
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              'Prediction',
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
              _buildImageCard(context), // Space between image card and location cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ..._buildLocationCards(), // Display stored location cards
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.40,
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
              label: 'Images',
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

  Widget _buildHomePage() {
    return Center(child: Text('Welcome to the Home Page!'));
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentLocation ?? LatLng(37.7749, -122.4194),
        zoom: 10,
      ),
      markers: _currentLocation != null
          ? {Marker(markerId: MarkerId('currentLocation'), position: _currentLocation!)}
          : {},
      onMapCreated: (GoogleMapController controller) {
        // Additional map setup
      },
    );
  }

  Widget _buildImagePage() {
    return Column(
      children: [
        Expanded(child: _buildImageGrid()),
      ],
    );
  }

  Widget _buildImageGrid() {
    return _images.isEmpty
        ? Center(child: Text('No images captured yet'))
        : GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              _images[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }


  List<Widget> _buildLocationCards() {
    return _locationHistory.map((location) {
      return Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          title: Text(
            'Location: ${location.latitude}, ${location.longitude}',
            style: TextStyle(fontSize: 16),
          ),
          trailing: Icon(Icons.location_on, color: Colors.green),
        ),
      );
    }).toList();
  }

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

  Widget _buildDashedLine() {
    return Container(
      height: 40,
      width: 2,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }


  Widget _buildImageCard(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // 50% of the screen height
      width: MediaQuery.of(context).size.width, // Full width
      child: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/agriculture-tractor-harvester-working-field-harvesting-sunny-day-vector-flat-illustration_939711-546.png'), // Replace with your image asset
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