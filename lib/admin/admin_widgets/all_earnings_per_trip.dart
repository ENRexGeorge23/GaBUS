import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/size_config.dart';

class AllEarningsPerTrip extends StatefulWidget {
  const AllEarningsPerTrip({Key? key}) : super(key: key);
  static const routeName = 'all-earnings-per-trip';

  @override
  _AllEarningsPerTripState createState() => _AllEarningsPerTripState();
}

class _AllEarningsPerTripState extends State<AllEarningsPerTrip> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, Map<String, Map<String, double>>>>? _earningsForRoutes;

  @override
  void initState() {
    super.initState();
    _earningsForRoutes = _calculateEarningsPerTripForCurrentDay();
  }

  Future<Map<String, Map<String, Map<String, double>>>>
      _calculateEarningsPerTripForCurrentDay() async {
    Map<String, Map<String, Map<String, double>>> earningsMap = {};

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final transactionsSnapshot = await _firestore
        .collection('allTransactions')
        .where('transactionDate', isGreaterThanOrEqualTo: startOfDay)
        .where('transactionDate', isLessThan: endOfDay)
        .get();

    for (final transactionDoc in transactionsSnapshot.docs) {
      final fare = transactionDoc.data().containsKey('fare')
          ? transactionDoc.get('fare') as String?
          : null;
      final busNumber = transactionDoc.data().containsKey('busNumber')
          ? transactionDoc.get('busNumber') as String?
          : null;
      final route = transactionDoc.data().containsKey('route')
          ? transactionDoc.get('route') as String?
          : null;

      if (fare != null && busNumber != null && route != null) {
        if (!earningsMap.containsKey(route)) {
          earningsMap[route] = {};
        }
        if (!earningsMap[route]!.containsKey(busNumber)) {
          earningsMap[route]![busNumber] = {
            'total': 0.0,
            'cash': 0.0,
            'online': 0.0,
          };
        }

        final double fareAmount = double.parse(fare);
        earningsMap[route]![busNumber]!['total'] =
            (earningsMap[route]![busNumber]!['total'] ?? 0) + fareAmount;

        if (transactionDoc.data().containsKey('isOnline') &&
            transactionDoc.get('isOnline') == true) {
          earningsMap[route]![busNumber]!['online'] =
              (earningsMap[route]![busNumber]!['online'] ?? 0) + fareAmount;
        } else if (transactionDoc.data().containsKey('isCash') &&
            transactionDoc.get('isCash') == true) {
          earningsMap[route]![busNumber]!['cash'] =
              (earningsMap[route]![busNumber]!['cash'] ?? 0) + fareAmount;
        }
      }
    }

    return earningsMap;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return FutureBuilder<Map<String, Map<String, Map<String, double>>>>(
      future: _earningsForRoutes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(
                'Loading...',
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
          final earningsMap = snapshot.data!;

          // Filter out routes with 0 earnings
          final filteredEarningsMap =
              Map.fromEntries(earningsMap.entries.where((entry) {
            return entry.value.values.any((busEarnings) {
              return busEarnings['total']! > 0;
            });
          }));

          return ListView.builder(
            itemCount: filteredEarningsMap.length,
            itemBuilder: (context, index) {
              final route = filteredEarningsMap.keys.elementAt(index);
              final earnings = filteredEarningsMap[route]!;

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
                        Icons.route,
                        size: 20,
                        color: Color(0xFFFF8B00),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Route: $route',
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
                    padding: const EdgeInsets.fromLTRB(25.0, 0, 40, 0),
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
                          'Total Earnings :  ₱  $formattedTotalEarningsSum',
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
                        color: Colors.orange.shade300,
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
                            SizedBox(
                                height: SizeConfig.blockSizeVertical * 0.5),
                            Text(
                              'Total Earnings: ₱ $formattedTotalEarnings',
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
                                  'Online Earnings: ₱  $formattedOnlineEarnings',
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
