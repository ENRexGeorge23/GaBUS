import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../widgets/dotted_line.dart';
import '../../widgets/receipt_widget.dart';
import '../bus_providers/bus_receipt_provider.dart';
import '../bus_widgets/bus_drawer.dart';
import '../bus_screens/bus_home_screen.dart';
import '/common/theme_helper.dart';
import '/common/size_config.dart';

class BusReceiptScreen extends StatelessWidget {
  const BusReceiptScreen({super.key});
  static const routeName = '/bus-receipt-screen';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    BusReceiptProvider busReceiptProvider =
        Provider.of<BusReceiptProvider>(context);
    BusReceipt? busReceipt = busReceiptProvider.busCurrentReceipt;
    final bookDate = busReceipt?.date;
    final formatter = DateFormat('MMM d, yyyy hh:mm a');
    final bookingDateDisplay = formatter.format(bookDate!);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Receipt',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const BusDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade500,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            height: double.infinity,
            child: Container(
              margin: const EdgeInsets.fromLTRB(5, 75, 5, 80),
              padding: const EdgeInsets.fromLTRB(0, 9, 0, 5),
              decoration: ThemeHelper().inputBoxDecorationShaddow(),
              child: ZigZagContainer(
                height: 100,
                width: double.infinity,
                borderRadius: 15,
                color: Colors.white,
                child: Center(
                  child: busReceipt != null
                      ? Column(
                          children: [
                            SizedBox(
                                height: SizeConfig.safeBlockVertical * 0.8),
                            const Text(
                              'Ticket was successfully paid!',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 70,
                            ),
                            Column(
                              children: [
                                Text(
                                  "with the amount of",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.3,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  '₱ ${busReceipt.fare}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 4.5,
                                  ),
                                ),
                                Text(
                                  "using Cash",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal * 3.3,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            SizedBox(
                                height: SizeConfig.safeBlockVertical * 0.2),
                            Container(
                              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Column(
                                children: [
                                  const DottedDivider(),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.9),
                                  const Text(
                                    'Transaction Details:',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.9),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Receipt ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        busReceipt.id.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  3.3,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Travel Date & Time',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        bookingDateDisplay,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  3.3,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.5),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Seat Number/s',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          busReceipt.seatNum.join(', '),
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    3.2,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Bus Number',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        busReceipt.busNum,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  3.3,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Plate Number',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        busReceipt.plateNum,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  3.3,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Origin',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        busReceipt.origin,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  3.3,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Destination',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 158,
                                        child: Text(
                                          busReceipt.destination,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal *
                                                    3.3,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 0.9),
                                  const DottedDivider(),
                                  SizedBox(
                                      height: SizeConfig.safeBlockVertical * 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Fare Paid',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '₱ ${busReceipt.fare}',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  4.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: SizeConfig.safeBlockVertical * 2),
                                  const DottedDivider(),
                                  Text(
                                    'Note: Please take a screenshot of this receipt and present it to the passenger',
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.safeBlockHorizontal * 2.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          SizeConfig.safeBlockVertical * 5.5),
                                  Text(
                                    'Thank you for riding with us!',
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.safeBlockHorizontal * 2.5,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 1.5),
                                    child: Image.asset(
                                      'assets/images/Gabus-Logo.png',
                                      height: 50,
                                      width: 50,
                                      //put your logo here
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const Text('No receipt available.'),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 35,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    BusHomeScreen.routeName,
                    (route) => false,
                  );
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: SizeConfig.safeBlockHorizontal * 5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
