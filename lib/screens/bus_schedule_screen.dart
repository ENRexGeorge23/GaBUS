import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

import '../common/app_layout.dart';
import '../common/size_config.dart';

import '../providers/terminal_provider.dart';
import '../widgets/gradient_scaffold.dart';

class BusScheduleScreen extends StatefulWidget {
  static const routeName = '/bus-schedule';

  @override
  State<BusScheduleScreen> createState() => _BusScheduleScreenState();
}

class _BusScheduleScreenState extends State<BusScheduleScreen> {
  final TextEditingController _searchController = TextEditingController();

  late Future<QuerySnapshot> _busesFuture;
  late ConnectivityResult _connectivityResult;

  @override
  void initState() {
    super.initState();
    _fetchBuses();
    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult == ConnectivityResult.none) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("No Internet Connection"),
                content: Text(
                    "Please check your internet connection and try again."),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  @override
  void dispose() {
    // Dispose the focus node and text controller when the widget is disposed

    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBuses() async {
    _busesFuture = FirebaseFirestore.instance.collection('buses').get();
    setState(() {});
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          titlePadding: EdgeInsets.fromLTRB(
            AppLayout.getWidth(23),
            AppLayout.getHeight(30),
            AppLayout.getWidth(20),
            AppLayout.getHeight(15),
          ),
          title: Text("Search for a bus",
              style: TextStyle(
                color: Color.fromARGB(255, 245, 147, 0),
                fontFamily: 'Inter',
                fontSize: SizeConfig.blockSizeHorizontal * 5,
                fontWeight: FontWeight.bold,
              )),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Enter bus number, route, or time.",
              hintStyle: TextStyle(
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: AppLayout.getHeight(20)),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Provider.of<OnTerminalProvider>(context, listen: false)
                        .setOnTerminal(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 15, 60, 15),
                    child: Text(
                      "Search",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          fontSize: SizeConfig.blockSizeHorizontal * 4.5),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Set the desired radius here
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<DocumentSnapshot> _filterBuses(
      List<DocumentSnapshot> buses, String searchText) {
    if (searchText == null || searchText.trim().isEmpty) {
      return buses;
    }

    return buses.where((bus) {
      final data = bus.data() as Map<String, dynamic>;
      final String busNumber = data['busNumber'] ?? '';
      final String plateNumber = data['busPlateNumber'] ?? '';
      final String routeOne = data['routeOne'] ?? '';
      final String routeTwo = data['routeTwo'] ?? '';
      final String timeOne = data['timeOne'] ?? '';
      final String timeTwo = data['timeTwo'] ?? '';

      final searchTextLower = searchText.toLowerCase();

      return busNumber.toLowerCase().contains(searchTextLower) ||
          plateNumber.toLowerCase().contains(searchTextLower) ||
          routeOne.toLowerCase().contains(searchTextLower) ||
          routeTwo.toLowerCase().contains(searchTextLower) ||
          timeOne.toLowerCase().contains(searchTextLower) ||
          timeTwo.toLowerCase().contains(searchTextLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    SizeConfig().init(context);
    return GradientScaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Bus Schedules',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search_rounded,
            ),
            onPressed: () {
              showSearchDialog(context);
            },
          ),
        ],
      ),
      body: _busesFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<QuerySnapshot>(
              future: _busesFuture,
              builder: (context, snapshot) {
                try {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No available buses yet.'),
                    );
                  }
                  final buses = snapshot.data!.docs;
                  final filteredBuses =
                      _filterBuses(buses, _searchController.text);
                  // Sort buses by timeOne
                  buses.sort((a, b) {
                    final timeOneA = a['timeOne'] as String? ?? '';
                    final timeOneB = b['timeOne'] as String? ?? '';
                    return timeOneA.compareTo(timeOneB);
                  });

                  if (buses.isEmpty) {
                    return const Center(
                      child: Text('No available buses yet.'),
                    );
                  }

                  if (filteredBuses.isEmpty &&
                      _searchController.text.isNotEmpty) {
                    return const Center(
                      child: Text(
                        'No bus found with your search criteria.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else if (buses.isEmpty) {
                    return const Center(
                      child: Text('No available buses yet.'),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              filteredBuses.length, // Use filteredBuses here
                          itemBuilder: (context, index) {
                            // Replace buses with filteredBuses in the line below
                            final busData = filteredBuses[index].data()
                                as Map<String, dynamic>;

                            final String busNumber =
                                busData['busNumber'] ?? 'N/A';
                            final String plateNumber =
                                busData['busPlateNumber'] ?? 'N/A';
                            final String routeOne =
                                busData['routeOne'] ?? 'N/A';
                            final String routeTwo =
                                busData['routeTwo'] ?? 'N/A';
                            final String timeOne = busData['timeOne'] ?? 'N/A';
                            final String timeTwo = busData['timeTwo'] ?? 'N/A';

                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black87.withOpacity(0.3),
                                            spreadRadius: 0.5,
                                            blurRadius: 0.1,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                        // Set the background image using the gradient and decoration properties
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange.shade200,
                                            Colors.orange.shade500,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/Gabus-Logo.png'), // Replace with your image file path
                                          fit: BoxFit.fitHeight,
                                          opacity: 200,
                                        ),
                                      ),
                                      child: ListTile(
                                        title: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.numbers_rounded,
                                                  size: 16,
                                                  color: Color(0xFFFF8B00),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Bus Number: $busNumber',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal *
                                                        3.9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .featured_play_list_rounded,
                                                  size: 16,
                                                  color: Color(0xFFFF8B00),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Plate Number: $plateNumber',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal *
                                                        3.9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              color: Colors.grey.shade200,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 10, 0, 0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_month_outlined,
                                                      size: 16,
                                                      color: Color(0xFFFF8B00),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'First Route: $routeOne',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal *
                                                            2.9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              color: Colors.grey.shade200,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 2, 0, 5),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 16,
                                                      color: Color(0xFFFF8B00),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'First Schedule: $timeOne',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal *
                                                            2.9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                              height: 5,
                                              color: Colors.black,
                                              thickness: 0.3,
                                            ),
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              color: Colors.grey.shade200,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 2, 0, 0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_month_outlined,
                                                      size: 16,
                                                      color: Color(0xFFFF8B00),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Second Route: $routeTwo',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal *
                                                            2.9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              color: Colors.grey.shade200,
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 2, 0, 0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 16,
                                                      color: Color(0xFFFF8B00),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Second Schedule: $timeTwo',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal *
                                                            2.9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } catch (error) {
                  return const Center(child: Text('Error whilebuilding UI'));
                }
              },
            ),
    );
  }
}
