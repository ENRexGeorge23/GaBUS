import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/size_config.dart';

class BusEarningsDaily extends StatefulWidget {
  const BusEarningsDaily({Key? key}) : super(key: key);
  static const routeName = 'bus-earnings-daily';

  @override
  _BusEarningsDailyState createState() => _BusEarningsDailyState();
}

class _BusEarningsDailyState extends State<BusEarningsDaily> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<Map<DateTime, Map<String, double>>>? _earningsForDatesRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final numDays = DateTime(now.year, now.month + 1, 0).day;

    _earningsForDatesRange =
        _calculateEarningsForDatesRange(startDate, numDays);
  }

  Future<Map<DateTime, Map<String, double>>> _calculateEarningsForDatesRange(
      DateTime startDate, int numDays) async {
    Map<DateTime, Map<String, double>> earningsMap = {};

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }

    final busDoc = await _firestore.collection('buses').doc(user.uid).get();
    final busNumber = busDoc.data()?.containsKey('busNumber') ?? false
        ? busDoc.get('busNumber') as String?
        : null;

    if (busNumber == null) {
      return earningsMap;
    }

    for (int i = 0; i < numDays; i++) {
      final currentDay = startDate.add(Duration(days: i));
      final startOfDay =
          DateTime(currentDay.year, currentDay.month, currentDay.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      double dailyTotal = 0.0;
      double dailyCashTotal = 0.0;
      double dailyOnlineTotal = 0.0;

      final transactionsSnapshot = await _firestore
          .collection('allTransactions')
          .where('busNumber', isEqualTo: busNumber)
          .where('transactionDate', isGreaterThanOrEqualTo: startOfDay)
          .where('transactionDate', isLessThan: endOfDay)
          .get();

      for (final transactionDoc in transactionsSnapshot.docs) {
        final fare = transactionDoc.data().containsKey('fare')
            ? transactionDoc.get('fare') as String?
            : null;
        if (fare != null) {
          dailyTotal += double.parse(fare);
          if (transactionDoc.data().containsKey('isOnline') &&
              transactionDoc.get('isOnline') == true) {
            dailyOnlineTotal += double.parse(fare);
          } else if (transactionDoc.data().containsKey('isCash') &&
              transactionDoc.get('isCash') == true) {
            dailyCashTotal += double.parse(fare);
          }
        }
      }
      earningsMap[startOfDay] = {
        'total': dailyTotal,
        'cash': dailyCashTotal,
        'online': dailyOnlineTotal
      };
    }
    return earningsMap;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return FutureBuilder<Map<DateTime, Map<String, double>>>(
      future: _earningsForDatesRange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(
                'Loading Bus Earnings...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final dateFormat = DateFormat("MMM d, yyyy");
          final earningsMap = snapshot.data!;

          // Filter out dates with 0 earnings
          final filteredEarningsMap = Map.fromEntries(
              earningsMap.entries.where((entry) => entry.value['total']! > 0));

          return ListView.builder(
            itemCount: filteredEarningsMap.length,
            itemBuilder: (context, index) {
              final date = filteredEarningsMap.keys.elementAt(index);
              final earnings = filteredEarningsMap[date]!;
              final formattedDate = dateFormat.format(date);
              final formattedTotalEarnings =
                  NumberFormat("#,##0.00", "en_US").format(earnings['total']);
              final formattedCashEarnings =
                  NumberFormat("#,##0.00", "en_US").format(earnings['cash']);
              final formattedOnlineEarnings =
                  NumberFormat("#,##0.00", "en_US").format(earnings['online']);

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade100,
                      Colors.orange.shade300,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 16,
                        color: Color(0xFFFF8B00),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: SizeConfig.blockSizeHorizontal * 3.9,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87.withOpacity(0.3),
                            spreadRadius: 0.5,
                            blurRadius: 0.1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        // Set the background image using the gradient and decoration properties
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade500,
                            Colors.orange.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/Gabus-Logo.png'), // Replace with your image file path
                          fit: BoxFit.fitHeight,
                          opacity: 210,
                        ),
                      ),
                      child: ListTile(
                        title: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          color: Colors.grey.shade200,
                          margin: const EdgeInsets.fromLTRB(0, 2, 0, 5),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on_outlined,
                                  size: 16,
                                  color: Color(0xFFFF8B00),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Total Earnings: ₱ $formattedTotalEarnings',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              color: Colors.grey.shade200,
                              margin: const EdgeInsets.fromLTRB(0, 2, 40, 5),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 16),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.payment,
                                      size: 16,
                                      color: Color(0xFFFF8B00),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Cash Earnings: ₱ $formattedCashEarnings',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal *
                                                2.9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              color: Colors.grey.shade200,
                              margin: const EdgeInsets.fromLTRB(0, 0, 40, 2),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 16),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.payments_rounded,
                                      size: 16,
                                      color: Color(0xFFFF8B00),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Online Earnings: ₱ $formattedOnlineEarnings',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal *
                                                2.9,
                                        fontWeight: FontWeight.bold,
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
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
