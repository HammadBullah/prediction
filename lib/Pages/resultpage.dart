import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prediction/Pages/settings.dart';
import 'package:provider/provider.dart';
import '../response.dart';
import 'homepage.dart';
import 'mappage.dart';

class ResultPage extends StatefulWidget {
  final String responseData; // Add a parameter for the response data

  ResultPage({required this.responseData}); // Constructor

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String responseData = '';
  int _selectedIndex = 2;
  String selectedYear = ''; // For holding the selected year
  List<dynamic> years = []; // For holding available years from the response

  @override
  void initState() {
    super.initState();
    _extractYears();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        responseData = Provider.of<ResponseDataModel>(context, listen: false).responseData;
      });
    });
  }

  // Extract available years from response data
  void _extractYears() {
    final List<dynamic> data = jsonDecode(widget.responseData);
    setState(() {
      years = data.map((e) => e['Actual Yield'].toString()).toList();
      selectedYear = years.isNotEmpty ? years[0] : ''; // Set default year to the first one
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

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

  // Filter the data based on selected year
  List<BarChartGroupData> _getBarChartData() {
    try {
      final List<dynamic> data = jsonDecode(widget.responseData);
      List<BarChartGroupData> barChartGroups = [];
      int index = 0;

      for (int i = 0; i < data.length; i++) {
        String year = data[i]['Actual Yield'].toString();
        if (year == selectedYear) {
          // Scale the predicted yield to 20%
          double predictedYield = data[i]['Predicted Yield'].toDouble();
          double scaledYield = predictedYield * 0.7;

          barChartGroups.add(
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: scaledYield,
                  color: Colors.green,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ),
          );
          index++;
        }
      }

      return barChartGroups;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasData = widget.responseData.isNotEmpty;

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
              'Result',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageCard(context),
            SizedBox(height: 20),
            Text(
              "Predictions vs Actual",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            hasData
                ? Column(
              children: [
                DropdownButton<String>(
                  value: selectedYear.isNotEmpty ? selectedYear : null,
                  hint: Text('Select Year'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYear = newValue!;
                    });
                  },
                  items: years.map<DropdownMenuItem<String>>((dynamic year) {
                    return DropdownMenuItem<String>(
                      value: year.toString(),
                      child: Text(year.toString()),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                // Scrollable bar chart container
                Container(
                  height: 400, // Fixed height for the container
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.5, // Adjust width for horizontal scrolling
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Group ${(value.toInt() + 1)}',
                                      style: TextStyle(fontSize: 10, color: Colors.black),
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  // Define y-axis labels
                                  if (value % 500 == 0) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(fontSize: 10, color: Colors.black),
                                    );
                                  }
                                  return Container(); // No label for other points
                                },
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.black),
                          ),
                          barGroups: _getBarChartData(),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                double predictedYield = jsonDecode(widget.responseData)[groupIndex]['Predicted Yield'].toDouble();
                                return BarTooltipItem(
                                  'Predicted Yield: ${predictedYield.toString()}',
                                  TextStyle(color: Colors.green),
                                );
                              },
                            ),
                          ),
                          maxY: 2500, // Maximum value for the y-axis
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            )
                : Container(),
          ],
        ),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage()), );
                    },
                  ),
                  _buildDashedLine(),
                  _buildButtonWithIcon(
                    label: 'Image',
                    icon: Icons.image,
                    onPressed: () {
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
}
