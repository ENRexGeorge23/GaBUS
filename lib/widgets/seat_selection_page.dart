import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gabus_build/screens/book_from_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

import '../providers/origin_provider.dart';
import '../providers/road_provider.dart';
import '../providers/seat_selection_provider.dart';
import '../providers/selected_seat_provider.dart';
import '../bus/bus_providers/bus_provider.dart';
import '../models/general_seat_component.dart';
import '../providers/terminal_provider.dart';
import '../screens/map_picker_road_screen.dart';
import '../screens/map_picker_screen.dart';
import '../screens/terminal_bus_list_screen.dart';

class SeatSelectionPage extends StatefulWidget {
  final String busId;
  const SeatSelectionPage({Key? key, required this.busId}) : super(key: key);

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  int _selectedSeatCount = 0;
  int _availableSeats = 30;
  Timer? _transactionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SelectedSeatProvider>(context, listen: false)
          .clearSelectedSeats();
    });
    _transactionTimer = Timer(Duration(seconds: 30), _onTransactionTimeout);
  }

  void _updateSelectedSeatCount(String seatKey, bool isSelected) {
    SeatSelectionProvider seatSelectionProvider =
        Provider.of<SeatSelectionProvider>(context, listen: false);
    setState(() {
      if (isSelected) {
        _selectedSeatCount++;
        seatSelectionProvider.addSeat(seatKey);
      } else {
        _selectedSeatCount--;
        seatSelectionProvider.removeSeat(seatKey);
      }
    });
  }

  void _onTransactionTimeout() {
    SelectedSeatProvider selectedSeatProvider =
        Provider.of<SelectedSeatProvider>(context, listen: false);

    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);

    DateTime? selectedDate = busProvider.selectedDate;
    TimeOfDay? selectedTime = busProvider.selectedTime;
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String formattedTime = DateFormat('HH:mm').format(DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime!.hour,
        selectedTime.minute));

    // Update Firebase Realtime Database
    final ref = FirebaseDatabase.instance.ref();
    final busNumber = busProvider.currentBus?.busNumber;
    final date = formattedDate;
    final time = formattedTime;
    final seatNumbers = selectedSeatProvider.selectedSeats;

    for (var seatNumber in seatNumbers) {
      ref.child('buses/$busNumber/$date/$time/seats/$seatNumber').update({
        'selectedBy': '',
        'selectedSeat': false,
      });
    }
    // Show a dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Reservation Failed'),
            content: Text(
                'You did not complete the Reservation within the allotted time.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  _transactionTimer?.cancel();
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushReplacementNamed(BookFromScreen.routeName);
                },
              ),
            ],
          );
        });
  }

  void onSeatSelected(String seatKey, bool isSelected) {
    SelectedSeatProvider selectedSeatProvider =
        Provider.of<SelectedSeatProvider>(context, listen: false);

    if (isSelected) {
      selectedSeatProvider.addSelectedSeat(seatKey);
    } else {
      selectedSeatProvider.removeSelectedSeat(seatKey);
    }
  }

  void onSeatSelectedAndUpdateCount(
      String seatKey, bool isSelected, String seatTitle) {
    _updateSelectedSeatCount(seatKey, isSelected);

    // Call onSeatSelected here and pass the seatTitle and isSelected
    onSeatSelected(seatTitle, isSelected);
  }

  void updatePlaceHolderSeatComponent(bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedSeatCount++;
      } else {
        _selectedSeatCount--;
      }
    });
  }

  @override
  void dispose() {
    _transactionTimer?.cancel();
    super.dispose();
  }

  final Future<FirebaseApp> _fApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFDB),
      body: FutureBuilder(
        future: _fApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something wrong with firebase");
          } else if (snapshot.hasData) {
            return content();
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _buildSeat(String seatKey, String seatTitle, double boxHeightRatio,
      double boxWidthRatio) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    DateTime? selectedDate = busProvider.selectedDate;
    TimeOfDay? selectedTime = busProvider.selectedTime;

    _transactionTimer?.cancel();
    _transactionTimer = Timer(Duration(seconds: 30), _onTransactionTimeout);

    // Check if both date and time are not null
    if (selectedDate == null || selectedTime == null) {
      return const CircularProgressIndicator();
    }

    // Format the date and time as strings
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedTime = DateFormat('HH:mm').format(DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute));

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final databaseReference = FirebaseDatabase.instance.ref();
    final boxHeight = screenHeight * boxHeightRatio;
    final boxWidth = screenWidth * boxWidthRatio;
    return StreamBuilder(
      stream: databaseReference
          .child(
              'buses/${widget.busId}/$formattedDate/$formattedTime/seats/$seatKey')
          .onValue,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> seatData =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          bool isBooked = seatData['isBooked'] ?? false;
          String status = seatData['status'] ?? 'available';

          return GeneralSeatComponent(
            title: seatTitle,
            boxHeight: boxHeight,
            boxWidth: boxWidth,
            marginTop: 19,
            onSelected: (String seatKey, bool isSelected, {String? seatTitle}) {
              onSeatSelectedAndUpdateCount(seatKey, isSelected, seatTitle!);
            },
            seatKey: seatKey,
            isBooked: isBooked,
            status: status,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget content() {
    final databaseReference = FirebaseDatabase.instance.ref();

    final busProvider = Provider.of<BusProvider>(context, listen: false);
    DateTime? selectedDate = busProvider.selectedDate;
    TimeOfDay? selectedTime = busProvider.selectedTime;

    // Check if both date and time are not null
    if (selectedDate == null || selectedTime == null) {
      return const CircularProgressIndicator();
    }

    // Format the date and time as strings
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedTime = DateFormat('HH:mm').format(DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute));

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        bool isOnRoad = Provider.of<OnRoadProvider>(context).isOnRoad;
        bool isOnTerminal =
            Provider.of<OnTerminalProvider>(context).isOnTerminal;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Select Your Seats",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.055),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    child: StreamBuilder(
                      stream: databaseReference
                          .child(
                              'buses/${widget.busId}/$formattedDate/$formattedTime/seats')
                          .onValue,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic> seatsData =
                              Map<String, dynamic>.from(
                                  snapshot.data!.snapshot.value as Map);
                          _availableSeats = seatsData.values
                              .where(
                                  (seatData) => seatData['isBooked'] == false)
                              .length;
                          return Text(
                            '$_availableSeats Seats Available',
                            style: TextStyle(
                                color: Color(0xFF9A9696),
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04),
                          );
                        } else {
                          return const CircularProgressIndicator(
                            strokeWidth: 4.0,
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF3AA3C),
                        borderRadius: BorderRadius.circular(32)),
                    height: MediaQuery.of(context).size.height * 0.53,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollStartNotification ||
                            scrollNotification is ScrollUpdateNotification ||
                            scrollNotification is ScrollEndNotification) {
                          // Cancel the timer when scroll starts, during scroll, or when scroll ends
                          _transactionTimer?.cancel();
                          _transactionTimer = Timer(
                              Duration(seconds: 30), _onTransactionTimeout);
                        }
                        return true;
                      },
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07, // Change this line
                                    width: MediaQuery.of(context).size.width *
                                        0.20, // Change this line
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const [
                                        Text("Driver"),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("A1", "A1", 0.05, 0.12),
                                  _buildSeat("A2", "A2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("A3", "A3", 0.05, 0.12),
                                  _buildSeat("A4", "A4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("B1", "B1", 0.05, 0.12),
                                  _buildSeat("B2", "B2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("B3", "B3", 0.05, 0.12),
                                  _buildSeat("B4", "B4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("C1", "C1", 0.05, 0.12),
                                  _buildSeat("C2", "C2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("C3", "C3", 0.05, 0.12),
                                  _buildSeat("C4", "C4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("D1", "D1", 0.05, 0.12),
                                  _buildSeat("D2", "D2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("D3", "D3", 0.05, 0.12),
                                  _buildSeat("D4", "D4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("E1", "E1", 0.05, 0.12),
                                  _buildSeat("E2", "E2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("E3", "E3", 0.05, 0.12),
                                  _buildSeat("E4", "E4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("F1", "F1", 0.05, 0.12),
                                  _buildSeat("F2", "F2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("F3", "F3", 0.05, 0.12),
                                  _buildSeat("F4", "F4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("G1", "G1", 0.05, 0.12),
                                  _buildSeat("G2", "G2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("G3", "G3", 0.05, 0.12),
                                  _buildSeat("G4", "G4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("H1", "H1", 0.05, 0.12),
                                  _buildSeat("H2", "H2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("H3", "H3", 0.05, 0.12),
                                  _buildSeat("H4", "H4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("I1", "I1", 0.05, 0.12),
                                  _buildSeat("I2", "I2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("I3", "I3", 0.05, 0.12),
                                  _buildSeat("I4", "I4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildSeat("J1", "J1", 0.05, 0.12),
                                  _buildSeat("J2", "J2", 0.05, 0.12),
                                  const Spacer(),
                                  _buildSeat("J3", "J3", 0.05, 0.12),
                                  _buildSeat("J4", "J4", 0.05, 0.12),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSeat("K1", "K1", 0.05, 0.12),
                                  _buildSeat("K2", "K2", 0.05, 0.12),
                                  _buildSeat("K3", "K3", 0.05, 0.12),
                                  _buildSeat("K4", "K4", 0.05, 0.12),
                                  _buildSeat("K5", "K5", 0.05, 0.12),
                                  _buildSeat("K6", "K6", 0.05, 0.12),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Origins",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                      height:
                          10), // Add some space between Origins and the seat types
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSeatType("Available", Colors.green),
                        _buildSeatType("Selected", Colors.lightBlue),
                        _buildSeatType("Reserved", Colors.yellow),
                        _buildSeatType("Occupied", Colors.red),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Selected Seats: $_selectedSeatCount",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Access the SelectedSeatProvider
                          SeatSelectionProvider seatProvider =
                              Provider.of<SeatSelectionProvider>(context,
                                  listen: false);

                          _transactionTimer?.cancel();

                          if (_selectedSeatCount == 0) {
                            // If no seats were selected, show a Snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No seat was selected.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else if (isOnRoad) {
                            await Navigator.of(context)
                                .pushNamed(MapPickerRoadScreen.routeName);
                          } else if (isOnTerminal) {
                            // If seats were selected, navigate to the ReserveTerminalSeats screen
                            // Navigate to MapPickerScreen and wait for the user to return
                            await Navigator.of(context)
                                .pushNamed(MapPickerScreen.routeName);

                            // Update the provider when the user returns
                            final originProvider = Provider.of<OriginProvider>(
                                    context,
                                    listen: false)
                                .resetOrigin();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.3,
                              MediaQuery.of(context).size.height * 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                          ),
                        ),
                        child: Text(
                          'Select Seat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeatType(String label, Color color) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.075,
          height: MediaQuery.of(context).size.width * 0.075,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
                color: Colors.black,
                width: MediaQuery.of(context).size.width * 0.005),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.02),
        Text(
          label,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
      ],
    );
  }
}
