import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bus/bus_providers/passenger_details_provider.dart';
import '../common/app_layout.dart';
import '../common/size_config.dart';
import '../common/theme_helper.dart';

import '../providers/terminal_provider.dart';
import '../widgets/gradient_scaffold.dart';
import './receipt_screen.dart';

import '../bus/bus_providers/bus_provider.dart';
import '../providers/selected_seat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/terminal_seats_provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/seat_selection_provider.dart';
import '../providers/user_provider.dart';
import '../providers/terminal_seats_provider.dart';
import '../widgets/app_drawer.dart';
import './authentication/users/auth_service.dart';
import '../screens/terminal_bus_list_screen.dart';
import 'book_from_screen.dart';

class PayNowScreen extends StatefulWidget {
  const PayNowScreen({Key? key}) : super(key: key);
  static const routeName = '/confirm-payment';

  @override
  State<PayNowScreen> createState() => _PayNowScreenState();
}

class _PayNowScreenState extends State<PayNowScreen> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final AuthService _authService = AuthService();
  Timer? _transactionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TerminalSeatsProvider terminalSeatsProvider =
          Provider.of<TerminalSeatsProvider>(context, listen: false);
      terminalSeatsProvider.generateRandomId();
      terminalSeatsProvider.getCurrentDateTime();
    });

    _transactionTimer = Timer(Duration(seconds: 30), _onTransactionTimeout);
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
                'You did not complete the transaction within the allotted time.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  _transactionTimer?.cancel();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      BookFromScreen.routeName,
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    _transactionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final size = AppLayout.getSize(context);
    SizeConfig().init(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    TerminalSeatsProvider terminalSeatsProvider =
        Provider.of<TerminalSeatsProvider>(context);
    ReceiptProvider receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    SeatSelectionProvider seatSelectionProvider =
        Provider.of<SeatSelectionProvider>(context, listen: false);
    SelectedSeatProvider selectedSeatProvider =
        Provider.of<SelectedSeatProvider>(context, listen: false);
    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);
    PassengerDetailsProvider passengerDetails =
        Provider.of<PassengerDetailsProvider>(context, listen: false);

    DateTime dateTime = busProvider.dateTime;
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    final List<String> selectedSeats = seatSelectionProvider.selectedSeats;
    final busPlateNumber = Provider.of<BusProvider>(context, listen: false);
    Bus? bus = busPlateNumber.currentBus;

    Future<void> payNowButton() async {
      Completer<String> verificationIdCompleter = Completer<String>();
      User? user =
          Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
      double userBalance = 0;

      _transactionTimer?.cancel();
      _transactionTimer = Timer(Duration(seconds: 20), _onTransactionTimeout);

      if (user != null) {
        userBalance = await _authService.getUserBalance();
      }

      double fare = double.tryParse(terminalSeatsProvider.fare ?? '0') ?? 0;
      if (userBalance < fare) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient balance. Please add more funds.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        bool confirmPayment = await showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController controller = TextEditingController();
            return AlertDialog(
              title: Text(
                'Confirm Payment',
                style: TextStyle(
                  color: Color.fromARGB(255, 245, 147, 0),
                  fontFamily: 'Inter',
                  fontSize: SizeConfig.blockSizeHorizontal * 5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please verify your identity by inputing your current password before you can confirm the payment of ₱ ${terminalSeatsProvider.fare}',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Inter',
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Confirm Password', 'Enter your password'),
                    obscureText: true,
                    controller: controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Your Password is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    String password = controller.text;
                    User? currentUser = FirebaseAuth.instance.currentUser;

                    if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please enter your password to confirm your payment.')),
                      );
                      return;
                    }

                    if (currentUser != null) {
                      AuthCredential credential = EmailAuthProvider.credential(
                          email: currentUser.email!, password: password);

                      try {
                        await currentUser
                            .reauthenticateWithCredential(credential);
                        _transactionTimer?.cancel();
                        final databaseReference =
                            FirebaseDatabase.instance.ref();
                        for (String seatKey in selectedSeats) {
                          final DataSnapshot snapshot = await databaseReference
                              .child(
                                  "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/$seatKey")
                              .get();
                          Map<String, dynamic>? snapshotValue =
                              Map<String, dynamic>.from(snapshot.value as Map);
                          bool isBooked = snapshotValue["isBooked"] ?? false;
                          String status =
                              snapshotValue["status"] ?? "available";
                          if (!isBooked && status == "available") {
                            await databaseReference
                                .child(
                                    "buses/${bus?.busNumber}/$formattedDate/$formattedTime/seats/$seatKey")
                                .update({
                              "isBooked": true,
                              "status": "reserved",
                              "selectedBy": "",
                              "selectedSeat": false,
                            });
                          }
                        }

                        seatSelectionProvider.clearSeats();

                        Navigator.of(context).pop(true);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incorrect Password')),
                        );
                      }
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
        if (confirmPayment == true) {
          receiptProvider.createReceipt(
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
          // Get the current user
          User? user = Provider.of<AuthProvider>(context, listen: false)
              .getCurrentUser();
          if (user != null) {
            // Add the transaction details to the Firestore collection
            await usersCollection.doc(user.uid).collection('transactions').add({
              'receiptId': terminalSeatsProvider.receiptId ?? '',
              'date': terminalSeatsProvider.date,
              'origin': terminalSeatsProvider.originBusStop?.title ?? '',
              'destination':
                  terminalSeatsProvider.destinationBusStop?.title ?? '',
              'fare': terminalSeatsProvider.fare.toString(),
              'busNum': busProvider.currentBus?.busNumber ?? '',
              'plateNum': busProvider.currentBus?.busPlateNumber ?? '',
              'seatNum': selectedSeatProvider.selectedSeats,
              'travelDate': DateFormat('MMM d, yyyy h:mm a')
                  .format(busProvider.selectedDate!.add(Duration(
                hours: busProvider.selectedTime!.hour,
                minutes: busProvider.selectedTime!.minute,
              ))),
              'terminal': busProvider.selectedRoute ?? '',
            });

            await _authService.deductAmountFromWallet(fare);

            final firestoreInstance = FirebaseFirestore.instance;
            await firestoreInstance.collection('allTransactions').add({
              'busNumber': busProvider.currentBus?.busNumber,
              'transactionDate': busProvider.selectedDate,
              'receiptId': terminalSeatsProvider.receiptId,
              'fare': terminalSeatsProvider.fare.toString(),
              'route': busProvider.selectedRoute,
              'isOnline': true,
            });
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            ReceiptScreen.routeName,
            (route) => false,
          );
        }
      }
    }

    void _resetTimer() {
      _transactionTimer?.cancel();
      _transactionTimer = Timer(Duration(seconds: 30), _onTransactionTimeout);
    }

    bool isOnTerminal = Provider.of<OnTerminalProvider>(context).isOnTerminal;
    final bookDate = terminalSeatsProvider.date;
    final formatter = DateFormat('MMM d, yyyy hh:mm a');
    final bookingDateDisplay =
        bookDate != null ? formatter.format(bookDate) : 'Date not available';

    return GestureDetector(
      onTap: _resetTimer,
      child: Scaffold(
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
                                  text: isOnTerminal
                                      ? DateFormat('MMM d, yyyy h:mm a').format(
                                          busProvider.selectedDate!.add(
                                            Duration(
                                              hours: busProvider
                                                  .selectedTime!.hour,
                                              minutes: busProvider
                                                  .selectedTime!.minute,
                                            ),
                                          ),
                                        )
                                      : bookingDateDisplay,
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
                                    'Travel Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  suffixIcon: Icon(
                                    Icons.calendar_month,
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
                            userProvider.userData!['isVerified'] == true
                                ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: TextFormField(
                                      controller: TextEditingController(
                                        text:
                                            '₱ ${terminalSeatsProvider.fare.toString()}',
                                      ),
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        label: Text(
                                          'Discounted Fare',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.monetization_on,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(), // Show an empty container when isVerified is not true
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
      ),
    );
  }
}
