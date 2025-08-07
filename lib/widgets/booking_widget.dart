import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'booking_card.dart';
import 'booking_card_cancelled.dart';
import 'booking_card_past_date.dart';

class BookingWidget extends StatefulWidget {
  const BookingWidget({super.key});

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Widget> getBookingCard() async {
    User? user =
        Provider.of<AuthProvider>(context, listen: false).getCurrentUser();

    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(user?.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return SizedBox(
        height: 160,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 253, 210, 146),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Text(
              "Haven't found the perfect trip yet?\nKeep looking! Your next adventure is waiting.",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    DocumentSnapshot transactionDoc = querySnapshot.docs.first;
    Map<String, dynamic> transactionData =
        transactionDoc.data() as Map<String, dynamic>;
// Get the current date
    final currentDate = DateTime.now();

// Parse the transactionData['travelDate'] string to a DateTime object
    final travelDate =
        DateFormat('MMM d, yyyy').parse(transactionData['travelDate']);

    if (transactionData.containsKey('description') &&
        transactionData['description']
            .toString()
            .toLowerCase()
            .contains('cancelled')) {
      // Display BookingCardCancelled
      return BookingCardCancelled();
    } else {
      DateTime currentDateOnly =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (travelDate.isBefore(currentDateOnly)) {
        return BookingCardPastDates();
      } else if (travelDate == currentDate) {
        // Display BookingCard
        return BookingCard();
      } else {
        return BookingCard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getBookingCard(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
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
          ); // or some other widget to show while waiting
        } else {
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
          } else {
            return snapshot.data!; // your BookingCard or BookingCardCancelled
          }
        }
      },
    );
  }
}
