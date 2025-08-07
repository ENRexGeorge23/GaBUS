import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/size_config.dart';

class AllEarningsMonthly extends StatefulWidget {
  const AllEarningsMonthly({Key? key}) : super(key: key);
  static const routeName = 'all-earnings-monthly';

  @override
  _AllEarningsMonthlyState createState() => _AllEarningsMonthlyState();
}

class _AllEarningsMonthlyState extends State<AllEarningsMonthly> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<DateTime, Map<String, Map<String, double>>>>?
      _earningsForMonthsRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1);
    const numMonths = 12;

    _earningsForMonthsRange =
        _calculateEarningsForMonthsRange(startDate, numMonths);
  }

  Future<Map<DateTime, Map<String, Map<String, double>>>>
      _calculateEarningsForMonthsRange(
          DateTime startDate, int numMonths) async {
    Map<DateTime, Map<String, Map<String, double>>> earningsMap = {};

    for (int i = 0; i < numMonths; i++) {
      final currentMonth = startDate.month + i;
      final startOfMonth = DateTime(startDate.year, currentMonth, 1);
      final endOfMonth = DateTime(startDate.year, currentMonth + 1, 0)
          .add(const Duration(days: 1));

      final transactionsSnapshot = await _firestore
          .collection('allTransactions')
          .where('transactionDate', isGreaterThanOrEqualTo: startOfMonth)
          .where('transactionDate', isLessThan: endOfMonth)
          .get();

      Map<String, Map<String, double>> monthlyEarnings = {};

      for (final transactionDoc in transactionsSnapshot.docs) {
        final fare = transactionDoc.data().containsKey('fare')
            ? transactionDoc.get('fare') as String?
            : null;
        final busNumber = transactionDoc.data().containsKey('busNumber')
            ? transactionDoc.get('busNumber') as String?
            : null;

        if (fare != null && busNumber != null) {
          if (!monthlyEarnings.containsKey(busNumber)) {
            monthlyEarnings[busNumber] = {
              'total': 0.0,
              'cash': 0.0,
              'online': 0.0,
            };
          }

          final double fareAmount = double.parse(fare);
          monthlyEarnings[busNumber]!['total'] =
              (monthlyEarnings[busNumber]!['total'] ?? 0) + fareAmount;

          if (transactionDoc.data().containsKey('isOnline') &&
              transactionDoc.get('isOnline') == true) {
            monthlyEarnings[busNumber]!['online'] =
                (monthlyEarnings[busNumber]!['online'] ?? 0) + fareAmount;
          } else if (transactionDoc.data().containsKey('isCash') &&
              transactionDoc.get('isCash') == true) {
            monthlyEarnings[busNumber]!['cash'] =
                (monthlyEarnings[busNumber]!['cash'] ?? 0) + fareAmount;
          }
        }
      }

      earningsMap[startOfMonth] = monthlyEarnings;
    }
    return earningsMap;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return FutureBuilder<Map<DateTime, Map<String, Map<String, double>>>>(
      future: _earningsForMonthsRange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(
                'Loading Monthly Earnings...',
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
          final dateFormat = DateFormat("MMM yyyy");
          final earningsMap = snapshot.data!;

          return ListView.builder(
            itemCount: earningsMap.length,
            itemBuilder: (context, index) {
              final date = earningsMap.keys.elementAt(index);
              final earnings = earningsMap[date]!;
              final formattedDate = dateFormat.format(date);

              // Compute the sum of all total earnings for each bus
              double totalEarningsSum = 0;
              for (var earning in earnings.values) {
                totalEarningsSum += earning['total']!;
              }
              final formattedTotalEarningsSum =
                  NumberFormat("#,##0.00", "en_US").format(totalEarningsSum);

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
                        Icons.calendar_month_outlined,
                        size: 20,
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
                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(25.0, 0, 2, 0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: Text(
                          'Total Monthly Earnings:  ₱ $formattedTotalEarningsSum',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: SizeConfig.blockSizeHorizontal * 3.4,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  children: earnings.entries.map((entry) {
                    final busNumber = entry.key;
                    final busEarnings = entry.value;
                    final formattedTotalEarnings =
                        NumberFormat("#,##0.00", "en_US")
                            .format(busEarnings['total']);
                    final formattedCashEarnings =
                        NumberFormat("#,##0.00", "en_US")
                            .format(busEarnings['cash']);
                    final formattedOnlineEarnings =
                        NumberFormat("#,##0.00", "en_US")
                            .format(busEarnings['online']);

                    return Container(
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
                            Colors.orange.shade300,
                            Colors.orange.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/Gabus-strip.png'), // Replace with your image file path
                          fit: BoxFit.fitHeight,
                          opacity: 240,
                        ),
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bus Number: $busNumber',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: SizeConfig.blockSizeHorizontal * 4.2,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: SizeConfig.blockSizeVertical * .5),
                            Text(
                              'Monthly Bus Earnings: ₱ $formattedTotalEarnings',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.grey.shade200,
                          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash Earnings: ₱ $formattedCashEarnings',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Online Earnings: ₱ $formattedOnlineEarnings',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 2.9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        }
      },
    );
  }
}
