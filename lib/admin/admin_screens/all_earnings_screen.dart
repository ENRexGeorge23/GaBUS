import 'package:flutter/material.dart';

import '../../widgets/gradient_scaffold.dart';
import '../admin_widgets/admin_drawer.dart';
import '../admin_widgets/all_earnings_daily.dart';
import '../admin_widgets/all_earnings_monthly.dart';
import '../admin_widgets/all_earnings_per_trip.dart';

class AllEarningsScreen extends StatefulWidget {
  const AllEarningsScreen({super.key});
  static const routeName = 'all-earnings';

  @override
  State<AllEarningsScreen> createState() => _AllEarningsScreenState();
}

class _AllEarningsScreenState extends State<AllEarningsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFFFEFFDB),
        appBar: AppBar(
          title: const Text(
            'All Earnings',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondary,
            ),
            tabs: [
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.transparent,
                  ),
                  child: const Text(
                    'Per Trip',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.transparent,
                  ),
                  child: const Text('Daily'),
                ),
              ),
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.transparent,
                  ),
                  child: const Text(
                    'Monthly',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        drawer: const AdminDrawer(),
        body: const TabBarView(
          children: [
            Center(
              child: AllEarningsPerTrip(),
            ),
            Center(
              child: AllEarningsDaily(),
            ),
            Center(
              child: AllEarningsMonthly(),
            ),
          ],
        ),
      ),
    );
  }
}
