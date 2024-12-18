import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prediction/Pages/mappage.dart';
import 'package:prediction/Pages/resultpage.dart';
import 'package:prediction/Pages/settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../response.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String responseData = '';
  int _selectedIndex = 0;
  File? _latestImage; // Store the latest captured image
  final ImagePicker _picker = ImagePicker();
  LatLng? _currentLocation; // Latest location variable

  String _locationMessage = "Location not yet fetched"; // Default message

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the Provider data after the widget is built
      setState(() {
        responseData = Provider.of<ResponseDataModel>(context, listen: false).responseData;
      });
    });
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

    if (!mounted) return;  // Check if the widget is still in the widget tree

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationMessage =
      "Current location: ${position.latitude}, ${position.longitude}";
    });

    print(_locationMessage);
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _latestImage = File(pickedFile.path); // Store the latest image
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent redundant navigation.

    setState(() {
      _selectedIndex = index;
    });

    final pages = [HomePage(), MapPage(), ResultPage(responseData: responseData), SettingsPage()];
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => pages[index],
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
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
          automaticallyImplyLeading: false,
          flexibleSpace: Center(
            child: Text(
              'AgroVision',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
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
              _buildImageCard(context), // Display the latest image and location
              if (_latestImage != null)
                _displayLatestImage(_latestImage!),
              _displayLocation(_locationMessage),
              SizedBox(height: 10),

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
          Positioned(
              top: MediaQuery.of(context).size.height * 0.75,
              left: 20,
              right: 20,
              child: Center(
            child: _buildUpload(context),
          ))
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
        onTap: _onItemTapped,
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
    );
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

  // Widget to display the current location
  Widget _displayLocation(String locationMessage) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        locationMessage,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
    );
  }


  // Widget to display the latest captured image
  Widget _displayLatestImage(File image) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: FileImage(image),
          fit: BoxFit.cover,
        ),
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

Widget _buildUpload(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(20),
    child: ElevatedButton(
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['xlsx', 'xls'], // Allow Excel files
        );

        if (result != null) {
          File file = File(result.files.single.path!); // Get the selected file
          String apiUrl = "https://71b2-2401-4900-81e8-eaa1-54af-2994-d5bb-13b4.ngrok-free.app/predict"; // Replace with your API endpoint

          try {
            var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
            request.files.add(await http.MultipartFile.fromPath(
              'file', // The field name expected by the server
              file.path,
            ));

            var response = await request.send();

            String responseBody = await response.stream.bytesToString();
            print('Response Body: $responseBody');

            Provider.of<ResponseDataModel>(context, listen: false)
                .setResponseData(responseBody);

            if (response.statusCode == 200) {
              var jsonResponse = json.decode(responseBody);
              // Navigate to the ResultPage and pass the response
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(responseData: responseBody),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to upload file. Status: ${response.statusCode}")),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error uploading file: $e")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No file selected")),
          );
        }
      },

      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(40, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: double.infinity, minHeight: 80),
          alignment: Alignment.center,
          child: Text(
            'Upload & Predict',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  );
}

