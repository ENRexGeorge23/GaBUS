import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/size_config.dart';

class PerTripEarnings extends StatefulWidget {
  const PerTripEarnings({Key? key}) : super(key: key);
  static const routeName = 'per-trip-earnings';

  @override
  _PerTripEarningsState createState() => _PerTripEarningsState();
}

class _PerTripEarningsState extends State<PerTripEarnings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<Map<DateTime, Map<String, double>>>? _earningsForDatesRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final currentDay = DateTime(now.year, now.month, now.day);
    _earningsForDatesRange = _calculateEarningsForDatesRange(currentDay);
  }

  Future<Map<DateTime, Map<String, double>>> _calculateEarningsForDatesRange(
      DateTime currentDate) async {
    Map<DateTime, Map<String, double>> earningsMap = {};

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }

    // Get the bus number of the current user
    final busDoc = await _firestore.collection('buses').doc(user.uid).get();
    final busNumber = busDoc.data()?.containsKey('busNumber') ?? false
        ? busDoc.get('busNumber') as String?
        : null;

    if (busNumber == null) {
      return earningsMap;
    }

    final currentDay = currentDate;
    final startOfDay =
        DateTime(currentDay.year, currentDay.month, currentDay.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    double dailyCsbtTotal = 0.0;
    double dailyBatoTotal = 0.0;
    double dailyCashCsbtTotal = 0.0;
    double dailyOnlineCsbtTotal = 0.0;
    double dailyCashBatoTotal = 0.0;
    double dailyOnlineBatoTotal = 0.0;

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
      final route = transactionDoc.data().containsKey('route')
          ? transactionDoc.get('route') as String?
          : null;

      // Check if the transaction is online
      bool isOnline = transactionDoc.data().containsKey('isOnline') &&
          transactionDoc.get('isOnline') == true;

      // Check if the transaction is cash
      bool isCash = transactionDoc.data().containsKey('isCash') &&
          transactionDoc.get('isCash') == true;

      if (route == "CSBT to Bato (via Oslob)" ||
          route == "CSBT to Bato (via Barili)") {
        if (isOnline) {
          dailyOnlineCsbtTotal += double.parse(fare!);
        } else if (isCash) {
          dailyCashCsbtTotal += double.parse(fare!);
        }
      } else if (route == "Bato to CSBT (via Barili)" ||
          route == "Bato to CSBT (via Oslob)") {
        if (isOnline) {
          dailyOnlineBatoTotal += double.parse(fare!);
        } else if (isCash) {
          dailyCashBatoTotal += double.parse(fare!);
        }
      }
    }
    dailyCsbtTotal = dailyCashCsbtTotal + dailyOnlineCsbtTotal;
    dailyBatoTotal = dailyCashBatoTotal + dailyOnlineBatoTotal;
    earningsMap[startOfDay] = {
      'csbtTotal': dailyCsbtTotal,
      'batoTotal': dailyBatoTotal,
      'cash': dailyCashCsbtTotal,
      'online': dailyOnlineCsbtTotal,
      'cashBato': dailyCashBatoTotal,
      'onlineBato': dailyOnlineBatoTotal,
    };
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
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(
                'Loading ...',
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
          final filteredEarningsMap = Map.fromEntries(earningsMap.entries.where(
              (entry) =>
                  (entry.value['csbtTotal']! + entry.value['batoTotal']!) > 0));
          return ListView.builder(
            itemCount: filteredEarningsMap.length,
            itemBuilder: (context, index) {
              final date = filteredEarningsMap.keys.elementAt(index);
              final earnings = filteredEarningsMap[date]!;
              final formattedDate = dateFormat.format(date);
              final formattedCsbtTotalEarnings =
                  NumberFormat("#,##0.00", "en_US")
                      .format(earnings['csbtTotal']);
              final formattedBatoTotalEarnings =
                  NumberFormat("#,##0.00", "en_US")
                      .format(earnings['batoTotal']);

              final formattedCashEarnings =
                  NumberFormat("#,##0.00", "en_US").format(earnings['cash']);
              final formattedOnlineEarnings =
                  NumberFormat("#,##0.00", "en_US").format(earnings['online']);
              final formattedCashBatoEarnings =
                  NumberFormat("#,##0.00", "en_US")
                      .format(earnings['cashBato']);
              final formattedOnlineBatoEarnings =
                  NumberFormat("#,##0.00", "en_US")
                      .format(earnings['onlineBato']);
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
                        Icons.data_exploration_sharp,
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
                            Colors.orange.shade200,
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
                                  'CSBT Total Earnings: ₱ $formattedCsbtTotalEarnings',
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
                            Colors.orange.shade200,
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
                                  'Bato Total Earnings: ₱ $formattedBatoTotalEarnings',
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
                                      'Cash Earnings: ₱ $formattedCashBatoEarnings',
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
                              color: Colors.grey.shade100,
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
                                      'Online Earnings: ₱ $formattedOnlineBatoEarnings',
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
