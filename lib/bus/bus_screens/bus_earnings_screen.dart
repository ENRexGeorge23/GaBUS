import 'package:flutter/material.dart';

import '../bus_widgets/bus_drawer.dart';
import '../bus_widgets/bus_earnings_daily.dart';
import '../../widgets/gradient_scaffold.dart';
import '../bus_widgets/per_trip_earnings.dart';

class BusEarningsScreen extends StatefulWidget {
  const BusEarningsScreen({Key? key}) : super(key: key);
  static const routeName = 'bus-earnings';

  @override
  State<BusEarningsScreen> createState() => _BusEarningsScreenState();
}

class _BusEarningsScreenState extends State<BusEarningsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GradientScaffold(
        appBar: AppBar(
          title: const Text(
            'Bus Earnings',
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
              borderRadius: BorderRadius.circular(30),
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
                  child: const Text('Per Trip'),
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
            ],
          ),
        ),
        drawer: const BusDrawer(),
        body: const TabBarView(
          children: [
            Center(
              child: PerTripEarnings(),
            ),
            Center(
              child: BusEarningsDaily(),
            ),
          ],
        ),
      ),
    );
  }
}
