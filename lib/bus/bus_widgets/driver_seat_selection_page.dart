import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gabus_build/bus/bus_screens/bus_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '/bus/bus_screens/bus_forms_screen.dart';

import '../bus_models/driver_general_seat_component.dart';
import '../bus_screens/driver_seat_ui_screen.dart';
import '../../bus/bus_providers/bus_provider.dart';
import '../../providers/selected_seat_provider.dart';
import '../../providers/seat_selection_provider.dart';

class DriverSeatSelectionPage extends StatefulWidget {
  final String busId;
  const DriverSeatSelectionPage({Key? key, required this.busId})
      : super(key: key);

  @override
  State<DriverSeatSelectionPage> createState() =>
      _DriverSeatSelectionPageState();
}

class _DriverSeatSelectionPageState extends State<DriverSeatSelectionPage> {
  int _selectedSeatCount = 0;
  int _selectedAvailableSeatCount = 0;
  int _selectedReservedSeatCount = 0;
  final List<String> _selectedSeats = [];
  String _selectedSeatStatus = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SelectedSeatProvider>(context, listen: false)
          .clearSelectedSeats();
    });
    // _transactionTimer = Timer(Duration(seconds: 30), _onTransactionTimeout);
  }

  void _updateSelectedSeatCount(
      String seatKey, bool isSelected, String status) {
    setState(() {
      if (isSelected) {
        _selectedSeats.add(seatKey);
        if (status == "available") {
          _selectedAvailableSeatCount++;
        } else if (status == "reserved") {
          _selectedReservedSeatCount++;
        }
        _selectedSeatCount++; // Add this line
      } else {
        _selectedSeats.remove(seatKey);
        if (status == "available") {
          _selectedAvailableSeatCount--;
        } else if (status == "reserved") {
          _selectedReservedSeatCount--;
        }
        _selectedSeatCount--; // Add this line
      }
    });
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

    // _transactionTimer = Timer(Duration(seconds: 30), _onTransactionTimeout);

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

    final boxHeight = screenHeight * boxHeightRatio;
    final boxWidth = screenWidth * boxWidthRatio;

    DatabaseReference seatRef = FirebaseDatabase.instance.ref().child(
        "buses/${widget.busId}/$formattedDate/$formattedTime/seats/$seatKey");

    return StreamBuilder(
      stream: seatRef.onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData &&
            !snapshot.hasError &&
            snapshot.data!.snapshot.value != null) {
          DataSnapshot dataSnapshot = snapshot.data!.snapshot;
          Map<String, dynamic>? snapshotValue =
              Map<String, dynamic>.from(dataSnapshot.value as Map);
          bool isBooked = snapshotValue["isBooked"] ?? false;
          String status = snapshotValue["status"] ?? "available";

          return DriverGeneralSeatComponent(
            title: seatTitle,
            onClearSelectedStatus:
                DriverGeneralSeatComponent.clearSelectedStatus,
            boxHeight: boxHeight,
            boxWidth: boxWidth,
            marginTop: 19,
            onSelected: (seatKey, isSelected, status) =>
                _updateSelectedSeatCount(seatKey, isSelected, status),
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

  Future<void> _showClearSeatDialog() async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    DateTime? selectedDate = busProvider.selectedDate;
    TimeOfDay? selectedTime = busProvider.selectedTime;

    // Check if both date and time are not null
    if (selectedDate == null || selectedTime == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Missing Date/Time'),
            content: const Text(
                'Please select both date and time before proceeding.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Format the date and time as strings
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedTime = DateFormat('HH:mm').format(DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute));
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Seat Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to clear the selected seats?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () async {
                final databaseReference = FirebaseDatabase.instance.ref();
                for (String seatKey in _selectedSeats) {
                  final DataSnapshot snapshot = await databaseReference
                      .child(
                          "buses/${widget.busId}/$formattedDate/$formattedTime/seats/$seatKey")
                      .get();
                  Map<String, dynamic>? snapshotValue =
                      Map<String, dynamic>.from(snapshot.value as Map);
                  bool isBooked = snapshotValue["isBooked"] ?? false;
                  String status = snapshotValue["status"] ?? "available";
                  if (status == "reserved") {
                    await databaseReference
                        .child(
                            "buses/${widget.busId}/$formattedDate/$formattedTime/seats/$seatKey")
                        .update({
                      "isBooked": false,
                      "status": "available",
                      "selectedBy": "",
                      "selectedSeat": false
                    });
                  }
                }
                setState(() {
                  _selectedAvailableSeatCount = 0;
                  _selectedReservedSeatCount = 0;

                  _selectedSeatCount = 0;
                  _selectedSeats.clear();
                  DriverGeneralSeatComponent.clearSelectedStatus();
                });
                DriverGeneralSeatComponent.clearSelectedStatus();
                Navigator.of(context)
                    .pushReplacementNamed(DriverSeatUiScreen.routeName);
              },
            ),
          ],
        );
      },
    );
  }

  Widget content() {
    final databaseReference = FirebaseDatabase.instance.ref();
    int _availableSeats = 30;
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
                      "Select Seat",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.065),
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
                          // _transactionTimer?.cancel();
                          // _transactionTimer = Timer(
                          //     Duration(seconds: 30), _onTransactionTimeout);
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
                  const SizedBox(height: 10),
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text(
                      "Selected Seats: $_selectedSeatCount",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _selectedReservedSeatCount > 0
                          ? () async {
                              await _showClearSeatDialog();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.3,
                            MediaQuery.of(context).size.height * 0.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.02),
                        ),
                      ),
                      child: const Text('Clear Seat'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectedAvailableSeatCount > 0 &&
                            _selectedReservedSeatCount == 0
                        ? () async {
                            // Access the SelectedSeatProvider
                            SelectedSeatProvider seatProvider =
                                Provider.of<SelectedSeatProvider>(
                              context,
                              listen: false,
                            );

                            if (_selectedSeatCount == 0) {
                              // If no seats were selected, show a Snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No seat was selected.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              // _transactionTimer?.cancel();
                            } else {
                              // Update the selected seats in the provider
                              seatProvider.updateSelectedSeats(_selectedSeats);

                              // If seats were selected, navigate to the ReserveTerminalSeats screen
                              // Navigate to MapPickerScreen and wait for the user to return
                              await Navigator.of(context)
                                  .pushNamed(BusFormScreen.routeName);
                              // _transactionTimer?.cancel();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.3,
                          MediaQuery.of(context).size.height * 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.02),
                      ),
                    ),
                    child: Text(
                      'Select Seat',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
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
