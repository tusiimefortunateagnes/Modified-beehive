import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:HPGM/Services/notifi_service.dart';
import 'package:HPGM/components/pop_up.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Keep your existing HomeData class as is

class Home extends StatefulWidget {
  final String token;
  final bool notify;

  const Home({Key? key, required this.token, required this.notify})
      : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class HomeData {
  final int farms;
  final int hives;
  final String apiaryName;
  final double averageHoneyPercentage;
  final double averageWeight;
  final double daysToEndSeason;
  final double percentage_time_left;
  // final double averageTemperatureLast7Days;
  // final String supplementaryApiaryName;

  HomeData({
    required this.farms,
    required this.hives,
    required this.apiaryName,
    required this.averageHoneyPercentage,
    required this.averageWeight,
    required this.daysToEndSeason,
    required this.percentage_time_left,
    // required this.averageTemperatureLast7Days,
    // required this.supplementaryApiaryName,
  });

  factory HomeData.fromJson(
      Map<String, dynamic> countJson,
      Map<String, dynamic> productiveJson,
      Map<String, dynamic> seasonJson,
      Map<String, dynamic> supplementData
      //List<dynamic> supplementData

      ) {
    return HomeData(
      farms: countJson['total_farms'],
      hives: countJson['total_hives'],
      apiaryName: productiveJson['most_productive_farm']['name'],
      averageHoneyPercentage:
          productiveJson['average_honey_percentage'].toDouble(),
      averageWeight: productiveJson['average_weight'].toDouble(),
      daysToEndSeason: seasonJson['time_until_harvest']['days'].toDouble(),
      percentage_time_left:
          seasonJson['time_until_harvest']['percentage_time_left'].toDouble(),
      // averageTemperatureLast7Days: supplementData[7].toDouble(),
      // supplementaryApiaryName: supplementData[2],
    );
  }
}

class _HomeState extends State<Home> {
  HomeData? homeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
    startPeriodicTemperatureCheck();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String sendToken = "Bearer ${widget.token}";

      var headers = {
        'Accept': 'application/json',
        'Authorization': sendToken,
      };

      // Concurrent requests
      var responses = await Future.wait([
        http.get(Uri.parse('https://www.ademnea.net/api/v1/farms/count'),
            headers: headers),
        http.get(
            Uri.parse('https://www.ademnea.net/api/v1/farms/most-productive'),
            headers: headers),
        http.get(
            Uri.parse(
                'https://www.ademnea.net/api/v1/farms/time-until-harvest'),
            headers: headers),
        http.get(
            Uri.parse(
                'https://www.ademnea.net/api/v1/farms/supplementary-feeding'),
            headers: headers),
      ]);

      if (responses[0].statusCode == 200 &&
          responses[1].statusCode == 200 &&
          responses[2].statusCode == 200 &&
          responses[3].statusCode == 200) {
        Map<String, dynamic> countData = jsonDecode(responses[0].body);
        Map<String, dynamic> productiveData = jsonDecode(responses[1].body);
        Map<String, dynamic> seasonData = jsonDecode(responses[2].body);
        Map<String, dynamic> supplementData = jsonDecode(responses[2].body);
        List<dynamic> supplementDat = jsonDecode(responses[3].body);

        // print('.........................................');
        // print(supplementDat);
        // print('.........................................');

        setState(() {
          homeData = HomeData.fromJson(
              countData, productiveData, seasonData, supplementData);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle error
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  Timer? _timer;

  // Add this variable

  void startPeriodicTemperatureCheck() {
    _checkNotifications();
    _timer = Timer.periodic(const Duration(minutes: 60), (timer) {
      _checkNotifications();
    });
  }

  Future<void> _checkNotifications() async {
    try {
      bool shouldTriggerNotification = widget.notify;
      double daystoseason = homeData?.daysToEndSeason ?? 0.0;

      if (daystoseason <= 10 && !shouldTriggerNotification) {
        NotificationService().showNotification(
          id: 1,
          title: 'Honey harvest season',
          body:
              'The Honey harvest season is here, check your hives and harvest the honey.',
        );
        // Set the flag to true once notification is triggered
      }

      //double avgtemp = homeData?.averageTemperatureLast7Days ?? 0.0;
      //  String apiaryName = homeData?.supplementaryApiaryName ?? '';

      // the if statement to check for the apiary temperatures.
      String myname = '${homeData?.apiaryName ?? 'prototype'}';

      print(myname);

      if (40 >= 30 && !shouldTriggerNotification) {
        NotificationService().showNotification(
          id: 2,
          title: "Supplementary Feeding",
          body:
              '$myname temperature soaring above 30°C!, please check it out. supplementary feeding may be required.',
        );
        // Set the flag to true once notification is triggered
      }
    } catch (error) {
      print('Error fetching temperature: $error');
    }
  }
  // Keep your existing getData(), startPeriodicTemperatureCheck(), _checkNotifications(), and dispose() methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF3E0),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: SvgPicture.asset(
                      'assets/honeycomb.svg',
                      width: 200,
                      color: Color(0xFFFFD54F).withOpacity(0.3),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Apiary Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildOverviewCards(),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Most Productive Apiary',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildProductiveApiaryCard(),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Apiaries Requiring Supplementary Feeding',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildSupplementaryFeedingCard(),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Honey Harvest Season',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildHarvestSeasonIndicator(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFFA000),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Beekeeper!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Manage your apiaries with ease',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 25,
            child: Icon(Icons.person, color: Color(0xFFFFA000)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoCard('Apiaries', '${homeData?.farms ?? 0}', Icons.house),
        _buildInfoCard('Hives', '${homeData?.hives ?? 0}', Icons.hive),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Color(0xFFFFA000)),
          SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Color(0xFF5D4037).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductiveApiaryCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            homeData?.apiaryName ?? 'Prototype apiary',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProductivityInfo('Honey Level',
                  '${homeData?.averageHoneyPercentage.toStringAsFixed(2) ?? '--'}%'),
              _buildProductivityInfo('Weight',
                  '${homeData?.averageWeight.toStringAsFixed(1) ?? '--'} Kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSupplementaryFeedingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[800]),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '${homeData?.apiaryName ?? '--'} at 32.2°C',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestSeasonIndicator() {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber[100],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: (homeData?.percentage_time_left ?? 0) / 100,
              strokeWidth: 30,
              backgroundColor: Colors.amber[50]!,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  homeData?.daysToEndSeason != null &&
                          homeData!.daysToEndSeason <= 10
                      ? "In Season"
                      : "${homeData?.daysToEndSeason.toStringAsFixed(0) ?? '--'}",
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                Text(
                  "days to harvest",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBottomNavBar() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(vertical: 10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(30),
  //         topRight: Radius.circular(30),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 10,
  //           offset: Offset(0, -5),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildNavItem(Icons.home, 'Home', true),
  //         _buildNavItem(Icons.bar_chart, 'Reports', false),
  //         _buildNavItem(Icons.notifications, 'Alerts', false),
  //         _buildNavItem(Icons.settings, 'Settings', false),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Color(0xFFFFA000) : Colors.grey,
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isActive ? Color(0xFFFFA000) : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
