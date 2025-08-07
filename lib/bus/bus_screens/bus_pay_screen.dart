import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/bus/bus_screens/bus_home_screen.dart';
import 'package:gabus_build/bus/bus_screens/bus_receipt_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/app_layout.dart';
import '../../common/size_config.dart';
import '../../providers/seat_selection_provider.dart';
import '../../providers/selected_seat_provider.dart';
import '../../providers/terminal_seats_provider.dart';
import '../../widgets/gradient_scaffold.dart';
import '../bus_providers/bus_provider.dart';
import '../bus_providers/bus_receipt_provider.dart';
import '../bus_providers/passenger_details_provider.dart';

class BusPayScreen extends StatefulWidget {
  const BusPayScreen({super.key});
  static const routeName = '/bus-pay-now';
  @override
  State<BusPayScreen> createState() => _BusPayScreenState();
}

class _BusPayScreenState extends State<BusPayScreen> {
  Timer? _transactionTimer;

  @override
  void initState() {
    super.initState();
    Provider.of<TerminalSeatsProvider>(context, listen: false)
        .setIsOnBusPayScreen(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TerminalSeatsProvider terminalSeatsProvider =
          Provider.of<TerminalSeatsProvider>(context, listen: false);
      terminalSeatsProvider.generateRandomId();
      terminalSeatsProvider.getCurrentDateTime();
    });
    // _transactionTimer = Timer(Duration(minutes: 1), _onTransactionTimeout);
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
    final ref = FirebaseDatabase.instance.reference();
    final busNumber = busProvider.currentBus?.busNumber;
    final date = formattedDate;
    final time = formattedTime;
    final seatNumbers = selectedSeatProvider.selectedSeats;

    print("DIRI GASUGOD");
    print("Bus Number: $busNumber");
    print("Date: $date");
    print("Time: $time");
    print("Seat Number: ${selectedSeatProvider.selectedSeats}");

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
            title: Text('Transaction Failed'),
            content: Text(
                'You did not complete the transaction within the allotted time.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushReplacementNamed(BusHomeScreen.routeName);
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    Provider.of<TerminalSeatsProvider>(context, listen: false)
        .setIsOnBusPayScreen(false);
    super.dispose();
  }

  Future<void> _bookSeatsAndNavigate(
      BuildContext context,
      List<String> selectedSeats,
      Bus? bus,
      String formattedDate,
      String formattedTime) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    for (String seatKey in selectedSeats) {
      final DataSnapshot snapshot = await databaseReference
          .child(
              "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/$seatKey")
          .get();
      Map<String, dynamic>? snapshotValue =
          Map<String, dynamic>.from(snapshot.value as Map);
      bool isBooked = snapshotValue["isBooked"] ?? false;
      String status = snapshotValue["status"] ?? "available";
      if (!isBooked && status == "available") {
        await databaseReference
            .child(
                "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/$seatKey")
            .update({
          "isBooked": true,
          "status": "reserved",
          "selectedSeat": false,
          "selectedBy": "",
        });
      }
    }

    Navigator.of(context).pop(true);
    Navigator.of(context).pushReplacementNamed(BusReceiptScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    TerminalSeatsProvider terminalSeatsProvider =
        Provider.of<TerminalSeatsProvider>(context);
    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);
    BusReceiptProvider busReceiptProvider =
        Provider.of<BusReceiptProvider>(context, listen: false);
    SelectedSeatProvider selectedSeatProvider =
        Provider.of<SelectedSeatProvider>(context, listen: false);
    SeatSelectionProvider seatSelectionProvider =
        Provider.of<SeatSelectionProvider>(context, listen: false);
    PassengerDetailsProvider passengerDetails =
        Provider.of<PassengerDetailsProvider>(context, listen: false);
    final List<String> selectedSeats = seatSelectionProvider.selectedSeats;
    final busPlateNumber = Provider.of<BusProvider>(context, listen: false);
    DateTime dateTime = busProvider.dateTime;
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    Bus? bus = busPlateNumber.currentBus;

    Future<void> payNowButton() async {
      bool confirmPayment = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Transaction'),
            content: const Text(
              'Please confirm your transaction',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Confirm'),
                onPressed: () {
                  _bookSeatsAndNavigate(
                      context,
                      selectedSeatProvider.selectedSeats,
                      bus,
                      formattedDate,
                      formattedTime);
                },
              ),
            ],
          );
        },
      );

      if (confirmPayment == true) {
        busReceiptProvider.createBusReceipt(
          id: terminalSeatsProvider.receiptId ?? '',
          date: terminalSeatsProvider.date as DateTime,
          origin: terminalSeatsProvider.originBusStop?.title ?? '',
          destination: terminalSeatsProvider.destinationBusStop?.title ?? '',
          fare: terminalSeatsProvider.fare.toString(),
          busNum: busProvider.currentBus?.busNumber ?? '',
          plateNum: busProvider.currentBus?.busPlateNumber ?? '',
          seatNum: selectedSeatProvider.selectedSeats,
          terminal: busProvider.selectedRoute ?? '',
          travelDate: DateFormat('MMM d, yyyy h:mm a')
              .format(busProvider.selectedDate!.add(Duration(
            hours: busProvider.selectedTime!.hour,
            minutes: busProvider.selectedTime!.minute,
          ))),
        );
        final firestoreInstance = FirebaseFirestore.instance;

        // Access the new collection and create a new document with the transaction details
        await firestoreInstance
            .collection('busTransactions')
            .doc(busProvider.currentBus?.busNumber)
            .collection(passengerDetails.documentId)
            .doc(terminalSeatsProvider.receiptId ?? '')
            .set({
          'date': terminalSeatsProvider.date ?? '',
          'origin': terminalSeatsProvider.originBusStop?.title ?? '',
          'destination': terminalSeatsProvider.destinationBusStop?.title ?? '',
          'fare': terminalSeatsProvider.fare.toString(),
          'busNum': busProvider.currentBus?.busNumber ?? '',
          'plateNum': busProvider.currentBus?.busPlateNumber ?? '',
          'seatNum': selectedSeatProvider.selectedSeats,
          'terminal': busProvider.selectedRoute ?? '',
          'travelDate': terminalSeatsProvider.date ?? '',
          passengerDetails.passengerTypeField:
              passengerDetails.passengerTypeValue,
          'contactNum': passengerDetails.contactNum,
        });

        await firestoreInstance.collection('allTransactions').add({
          'busNumber': busProvider.currentBus?.busNumber,
          'transactionDate': busProvider.selectedDate,
          'receiptId': terminalSeatsProvider.receiptId,
          'fare': terminalSeatsProvider.fare.toString(),
          'route': busProvider.selectedRoute,
          'isCash': true,
        });
      }
    }

    final bookDate = terminalSeatsProvider.date;
    final formatter = DateFormat('MMM d, yyyy hh:mm a');
    final bookingDateDisplay =
        bookDate != null ? formatter.format(bookDate) : 'Date not available';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Payment Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: SizeConfig.screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade500,
                    Colors.orange.shade50,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.11,
                    ),
                    Container(
                      margin: const EdgeInsets.all(7),
                      padding: const EdgeInsets.fromLTRB(25, 5, 25, 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 0.9,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: SizeConfig.screenHeight * 0.01,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: terminalSeatsProvider.receiptId
                                          ?.toUpperCase() ??
                                      ''),
                              readOnly: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  gapPadding: 4,
                                ),
                                label: Text(
                                  'Receipt ID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIcon: Icon(
                                  Icons.receipt,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: TextEditingController(
                                text: bookingDateDisplay,
                              ),
                              readOnly: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  gapPadding: 4,
                                ),
                                label: Text(
                                  'Booking Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIcon: Icon(
                                  Icons.date_range,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: terminalSeatsProvider
                                          .originBusStop?.title ??
                                      ''),
                              readOnly: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  gapPadding: 4,
                                ),
                                label: Text(
                                  'Origin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIcon: Icon(
                                  Icons.pin_drop_outlined,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: terminalSeatsProvider
                                          .destinationBusStop?.title ??
                                      ''),
                              readOnly: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  gapPadding: 4,
                                ),
                                label: Text(
                                  'Destination',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIcon: Icon(
                                  Icons.pin_drop_outlined,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: TextEditingController(
                                text: busProvider.selectedRoute ?? '',
                              ),
                              readOnly: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  gapPadding: 4,
                                ),
                                label: Text(
                                  'Terminal Route',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIcon: Icon(
                                  Icons.fork_right_outlined,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: TextEditingController(
                                  text:
                                      '₱ ${terminalSeatsProvider.notDiscountedFare.toString()}'),
                              readOnly: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  gapPadding: 4,
                                ),
                                label: Text(
                                  'Fare',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIcon: Icon(
                                  Icons.attach_money_rounded,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0, // Adjust this value to move the button up or down
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: payNowButton,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(60, 15, 60, 15),
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                          fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30), // Set the desired radius here
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
