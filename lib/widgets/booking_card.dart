import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gabus_build/screens/home_screen.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/theme_helper.dart';
import 'column_layout.dart';
import 'layout_builder_widget.dart';
import 'thick_container.dart';

import '../common/app_layout.dart';
import '../common/size_config.dart';
import '../providers/auth_provider.dart';
import '../models/get_transactions.dart';
import '../models/user_transactions.dart';

import '../screens/authentication/users/auth_service.dart';

class BookingCard extends StatelessWidget {
  final bool? isColor;
  final AuthService _authService = AuthService();
  List<UserTransaction> transactions = [];

  BookingCard({
    super.key,
    this.isColor,
  });

  Stream<List<GetTransaction>> getTransactionsStream() {
    return _authService.getTransactionsStream();
  }

  //Function to Update The Firebase Realtie Ddatabase:
  Future<void> updateSeatStatus(String busNum, DateTime bookedDate,
      String travelDate, String seatNum) async {
    // Parse the travelDate string
    DateTime parsedDate = DateFormat("MMM dd, yyyy h:mm a").parse(travelDate);
    // Format the date part
    String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    // Format the time part without the AM/PM indicator
    String formattedTime = DateFormat("HH:mm").format(parsedDate);

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    await dbRef
        .child('buses')
        .child(busNum)
        .child(formattedDate)
        .child(formattedTime)
        .child('seats')
        .child(seatNum)
        .update({
      'isBooked': false,
      'status': 'available',
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    Future<void> processCancellation(User? user,
        CollectionReference usersCollection, var transaction) async {
      // Get the transactions collection
      var transactionsCollection =
          usersCollection.doc(user?.uid).collection('transactions');
      // Get the user's wallet collection
      var walletCollection =
          usersCollection.doc(user?.uid).collection('wallet').doc('wallet');
      // Get the allTransactions collection
      var allTransactionsCollection =
          FirebaseFirestore.instance.collection('allTransactions');
      // Get the latest transaction
      var querySnapshot = await transactionsCollection
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      // If a transaction exists, delete it and check the allTransactions collection
      if (querySnapshot.docs.isNotEmpty) {
        var latestTransaction = querySnapshot.docs.first;
        double refund = double.parse(latestTransaction['fare']) / 2;
        String formattedDate =
            DateFormat('MMM dd, yyyy h:mm a').format(DateTime.now());
        // Update the transaction
        await transactionsCollection.doc(latestTransaction.id).update({
          'fare': refund.toString(), // Update the fare to 50%
          'travelDate': formattedDate,
          'description': 'Cancelled - 50% refund issued'
        });

        // Check if the receiptId matches in the allTransactions collection
        var allTransactionsQuery = await allTransactionsCollection
            .where('receiptId', isEqualTo: latestTransaction['receiptId'])
            .get();

        if (allTransactionsQuery.docs.isNotEmpty) {
          // If a match is found, update the fare
          var matchingTransaction = allTransactionsQuery.docs.first;
          double refund = double.parse(matchingTransaction['fare']) / 2;

          await allTransactionsCollection.doc(matchingTransaction.id).update({
            'transactionDate': formattedDate,
            'fare': refund.toString(),
            'description': '50% of cancellation' // Update the fare to 50%
          });

          // Create the new transaction
          UserTransaction newTransaction = UserTransaction(
            amount: refund,
            timestamp: DateTime.now(),
          );

          // Convert the transaction to a map so it can be stored in Firestore
          Map<String, dynamic> transactionMap = newTransaction.toMap();

          // Add the transaction to the 'transactions' list in the wallet document
          await walletCollection.update({
            'transactions': FieldValue.arrayUnion([transactionMap]),
          });
          // Get the current wallet document
          DocumentSnapshot walletSnapshot = await walletCollection.get();

          // Get the current balance
          double currentBalance = walletSnapshot['balance'].toDouble();

          // Calculate the new balance
          double newBalance = currentBalance +
              refund; // Update the balance in the wallet document
          await walletCollection.update({
            'balance': newBalance,
          });

          // Update seat status for each seat in the transaction
          for (String seatNum in transaction.seatNum) {
            await updateSeatStatus(transaction.busNum, transaction.date,
                transaction.travelDate, seatNum);
          }
        }
      }
    }

    void cancelReservation(var transaction) {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      User? user =
          Provider.of<AuthProvider>(context, listen: false).getCurrentUser();

      showDialog(
        context: context,
        builder: (BuildContext alertDialogContext) {
          return AlertDialog(
            title: Text(
              "Cancel Reservation",
              style: TextStyle(
                color: const Color.fromARGB(255, 245, 147, 0),
                fontFamily: 'Inter',
                fontSize: SizeConfig.blockSizeHorizontal * 5,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Are you sure you want to cancel the reservation? Note that only 50% of the reservation fee will be refunded.",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 15),
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
            actions: <Widget>[
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(alertDialogContext).pop();
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text("Yes"),
                onPressed: () async {
                  String password = controller.text;
                  User? currentUser = FirebaseAuth.instance.currentUser;

                  if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please enter your password to cancel your reservation.')),
                    );
                    return;
                  }
                  if (currentUser != null) {
                    AuthCredential credential = EmailAuthProvider.credential(
                        email: currentUser.email!, password: password);

                    try {
                      await currentUser
                          .reauthenticateWithCredential(credential);

                      await processCancellation(
                          user, usersCollection, transaction);
                      Navigator.of(alertDialogContext).pop();
                      Navigator.of(context).pop();
                      // Navigate to WalletScreen
                      Navigator.pushReplacementNamed(
                          context, HomePageScreen.routeName);
                    } catch (e) {
                      // Show error message if reauthentication fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Incorrect password'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }

                    // Ensure processCancellation is completed before navigating to WalletScreen
                  }
                },
              ),
            ],
          );
        },
      );
    }

    bool isTravelDay(String date) {
      DateFormat dateFormat = DateFormat("MMM d, yyyy");
      DateTime travelDate = dateFormat.parse(date);
      DateTime currentDate = DateTime.now();
      return travelDate.year == currentDate.year &&
          travelDate.month == currentDate.month &&
          travelDate.day == currentDate.day;
    }

    final size = AppLayout.getSize(context);
    SizeConfig().init(context);
    return StreamBuilder<List<GetTransaction>>(
      stream: getTransactionsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SizedBox(
            height: 120,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 253, 210, 146),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Error: Could not load transactions',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 120,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 253, 210, 146),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Loading transactions...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          List<GetTransaction> bookTransactions = snapshot.data!;
          String seatNumbers = bookTransactions.first.seatNum.join(', ');

          final int maxLength = 10; // set the maximum length to 10 characters
          if (seatNumbers.length > maxLength) {
            seatNumbers = seatNumbers.substring(0, maxLength) + '...';
          }
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    titlePadding: EdgeInsets.fromLTRB(
                      AppLayout.getWidth(23),
                      AppLayout.getHeight(30),
                      AppLayout.getWidth(20),
                      AppLayout.getHeight(15),
                    ),
                    title: Text("Ticket Details",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 245, 147, 0),
                          fontFamily: 'Inter',
                          fontSize: SizeConfig.blockSizeHorizontal * 5,
                          fontWeight: FontWeight.bold,
                        )),
                    contentPadding: EdgeInsets.zero,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(22),
                            bottom: AppLayout.getHeight(20),
                          ),
                          child: Text('Payment to GaBus',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 245, 147, 0),
                                fontFamily: 'Inter',
                                fontSize: SizeConfig.blockSizeHorizontal * 4,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Travel Date",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.5,
                                    fontWeight: FontWeight.normal,
                                  )),
                              Text(
                                bookTransactions.first.travelDate,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal * 3.9,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(AppLayout.getHeight(5)),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Bus Route",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.normal,
                                  )),
                              Text(
                                bookTransactions.first.terminal,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal * 2.9,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Origin",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.normal,
                                  )),
                              SizedBox(
                                width: AppLayout.getWidth(180),
                                child: Text(
                                  bookTransactions.first.origin,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Destination",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.normal,
                                  )),
                              SizedBox(
                                width: AppLayout.getWidth(180),
                                child: Text(
                                  bookTransactions.first.destination,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Bus Number",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.normal,
                                  )),
                              Text(
                                bookTransactions.first.busNum,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal * 2.9,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Bus Plate Number",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.normal,
                                  )),
                              Text(
                                bookTransactions.first.plateNum,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal * 2.9,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Seats",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.normal,
                                  )),
                              Text(
                                bookTransactions.first.seatNum.join(', '),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal * 2.9,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(AppLayout.getHeight(10)),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Text(
                                  "Amount",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.5,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(
                                child: Text(
                                  "- ₱ ${bookTransactions.first.fare}",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.9,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(AppLayout.getHeight(10)),
                        const Divider(
                          endIndent: 1,
                          thickness: 0.7,
                          color: Colors.grey,
                        ),
                        Gap(AppLayout.getHeight(20)),
                        Container(
                          margin: EdgeInsets.only(
                            left: AppLayout.getWidth(20),
                            right: AppLayout.getWidth(20),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Receipt ID",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.5,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  bookTransactions.first.receiptId
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.9,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Gap(AppLayout.getHeight(15)),
                      ],
                    ),
                    actions: [
                      Container(
                        margin:
                            EdgeInsets.only(bottom: AppLayout.getHeight(20)),
                        child: Center(
                          child: isTravelDay(
                                  (bookTransactions.first.travelDate))
                              ? Text(
                                  "Today is your travel day and cancellation is restricted.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 245, 147, 0),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 3.2),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    cancelReservation(bookTransactions.first);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        60, 15, 60, 15),
                                    child: Text(
                                      "Cancel Reservation",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  3.0),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: SizedBox(
              width: size.width * 1.5,
              height: AppLayout.getHeight(168),
              child: Container(
                margin: EdgeInsets.only(
                  right: AppLayout.getWidth(5),
                  left: AppLayout.getWidth(5),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isColor == null
                            ? const Color.fromARGB(255, 244, 144, 45)
                            : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(21),
                          topRight: Radius.circular(21),
                        ),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(
                                  bookTransactions.first.origin
                                      .toUpperCase()
                                      .substring(0, 10),
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.2,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                              ThickContainer(
                                isColor: isColor,
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      child: LayoutBuilder(
                                        builder: (BuildContext contect,
                                            BoxConstraints constraints) {
                                          return Flex(
                                            direction: Axis.horizontal,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: List.generate(
                                              (constraints.constrainWidth() / 6)
                                                  .floor(),
                                              (index) => SizedBox(
                                                width: 3,
                                                height: 1,
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                      color: isColor == null
                                                          ? Colors.white
                                                          : Colors
                                                              .grey.shade300),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Center(
                                      child: Center(
                                        child: Icon(
                                          Icons.directions_bus_filled_sharp,
                                          color: isColor == null
                                              ? Colors.white
                                              : const Color(0xff8accf7),
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ThickContainer(isColor: isColor),
                              Expanded(child: Container()),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  bookTransactions.first.destination
                                      .toUpperCase()
                                      .substring(0, 8),
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.2,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const Gap(1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'Origin',
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 90,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    '  ₱ ${bookTransactions.first.fare}',
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 4,
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'Destination',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    //Ang tunga
                    Container(
                      color: Colors.orange.shade300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                            ),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: AppLayoutBuilderWidget(
                                sections: 6,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                            width: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(isColor == null ? 21 : 0),
                          bottomRight:
                              Radius.circular(isColor == null ? 21 : 0),
                        ),
                      ),
                      padding: const EdgeInsets.only(
                          left: 16, top: 10, right: 16, bottom: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppColumnLayout(
                                firstText: bookTransactions.first.travelDate
                                    .substring(0, 6),
                                secondText: 'Date',
                                alignment: CrossAxisAlignment.start,
                                isColor: isColor,
                              ),
                              AppColumnLayout(
                                firstText: bookTransactions.first.travelDate
                                            .substring(12, 19) ==
                                        "20"
                                    ? bookTransactions.first.travelDate
                                        .replaceRange(12, 21, "21")
                                    : bookTransactions.first.travelDate
                                                .substring(12, 19) ==
                                            "20"
                                        ? bookTransactions.first.travelDate
                                            .replaceRange(12, 21, "21")
                                        : bookTransactions.first.travelDate
                                            .substring(12),
                                secondText: "Departure Time",
                                alignment: CrossAxisAlignment.center,
                                isColor: isColor,
                              ),
                              AppColumnLayout(
                                firstText: seatNumbers,
                                secondText: "Seat #",
                                alignment: CrossAxisAlignment.end,
                                isColor: isColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return SizedBox(
            height: 120,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 253, 210, 146),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  "Loading Reservations...",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
