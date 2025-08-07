import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/screens/seat_ui_screen.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

import '../bus/bus_providers/bus_provider.dart';
import '../common/app_layout.dart';
import '../common/size_config.dart';

import '../providers/terminal_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/gradient_scaffold.dart';

// Add this extension to support the toDateTime method for TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

//Initialize the seats on firebase realtime database
void _initializeSeats(String busID, String date, String time) async {
  final DatabaseReference busRef = FirebaseDatabase.instance
      .ref()
      .child('buses')
      .child(busID)
      .child(date)
      .child(time)
      .child('seats');

  // Check if the path already exists
  final DataSnapshot dataSnapshot = (await busRef.once()).snapshot;
  if (dataSnapshot.exists && dataSnapshot.value != null) {
    // Path exists and has children, no need to initialize seats again
    return;
  }

  final seatRows = 'ABCDEFGHIJK';
  final seatCols = '123456';

  for (int i = 0; i < seatRows.length; i++) {
    for (int j = 0; j < (i == seatRows.length - 1 ? 6 : 4); j++) {
      final seatId = '${seatRows[i]}${seatCols[j]}';
      busRef.child(seatId).set({
        'isBooked': false,
        'status': 'available',
      });
    }
  }
}

class TerminalBusListScreen extends StatefulWidget {
  static const routeName = '/terminal-bus-list';

  @override
  State<TerminalBusListScreen> createState() => _TerminalBusListScreenState();
}

class _TerminalBusListScreenState extends State<TerminalBusListScreen> {
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

  bool _isValidDateTime(DateTime selectedDate, TimeOfDay selectedTime) {
    final currentTime = DateTime.now();
    final selectedDateTime = selectedTime.toDateTime(selectedDate);

    return selectedDateTime.isAfter(currentTime);
  }

  Future<void> _showDateTimePicker(
    BuildContext context,
    String busNumber,
    String timeOne,
    String timeTwo,
    String routeOne,
    String routeTwo,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate == null) return;

    final timeFormat = DateFormat.jm();
    final timeOptions = [
      TimeOfDay.fromDateTime(timeFormat.parse(timeOne)),
      TimeOfDay.fromDateTime(timeFormat.parse(timeTwo)),
    ];

    final selectedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Text(
                  'Select a Time',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: timeOptions.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text(
                        DateFormat.jm().format(
                          timeOptions[index].toDateTime(DateTime.now()),
                        ),
                      ),
                      subtitle: Text(
                        index == 0 ? 'Route: $routeOne' : 'Route: $routeTwo',
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop(
                          timeOptions[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedTime == null) return;
    final selectedDateTime = selectedTime.toDateTime(selectedDate);
    if (!_isValidDateTime(selectedDate, selectedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a valid date and time.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    final confirm = await _showConfirmationDialog(
      context,
      busNumber, // Pass the busNumber here
      selectedDate,
      selectedTime,
    );
    if (!confirm) return;

    await Provider.of<BusProvider>(context, listen: false)
        .setCurrentBusByBusNumber(busNumber);
    final selectedRoute =
        timeOptions.indexOf(selectedTime) == 0 ? routeOne : routeTwo;
    Provider.of<BusProvider>(context, listen: false).setSelectedBusDetails(
      selectedDate,
      selectedTime,
      selectedRoute,
    );

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const SeatUiScreen();
    }));
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String busNumber, // Add busNumber as an argument
    DateTime selectedDate,
    TimeOfDay selectedTime,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Date and Time'),
              content: Text(
                'You have selected ${DateFormat.yMMMd().format(selectedDate)} at ${DateFormat.jm().format(selectedTime.toDateTime(DateTime.now()))}. Do you want to proceed?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _initializeSeats(
                      busNumber, // Pass busNumber as an argument
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                      DateFormat('HH:mm')
                          .format(selectedTime.toDateTime(DateTime.now())),
                    );
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        ) ??
        false;
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
        title: const Text(
          'Choose a Bus',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
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

                  return Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Builder(builder: (context) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                                labelText: "Search your desired bus",
                                hintText: "Enter bus number, route, or time.",
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Colors.orange.shade600,
                                ),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 8, 0, 0)),
                          ),
                        );
                      }),
                      Gap(AppLayout.getHeight(5)),
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
                                    onTap: () async {
                                      Provider.of<OnTerminalProvider>(context,
                                              listen: false)
                                          .setOnTerminal(true);
                                      await _showDateTimePicker(
                                        context,
                                        busNumber,
                                        timeOne,
                                        timeTwo,
                                        routeOne,
                                        routeTwo,
                                      );
                                    },
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
                                            Colors.orange.shade100,
                                            Colors.orange.shade200,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/Gabus-strip.png'), // Replace with your image file path
                                          fit: BoxFit.fitHeight,
                                          opacity: 200,
                                        ),
                                      ),
                                      child: ListTile(
                                        // leading: Icon(
                                        //   Icons.directions_bus,
                                        //   color: Color(0xFFFF8B00),
                                        //   // size: 50,
                                        // ),
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
