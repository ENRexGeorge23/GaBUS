import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gabus_build/providers/road_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/origin_provider.dart';
import '/common/theme_helper.dart';
import '/common/size_config.dart';

import '../screens/wallet_screens.dart';
import '../screens/book_from_screen.dart';

import '../providers/receipt_provider.dart';
import '../providers/terminal_seats_provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/receipt_widget.dart';
import '../widgets/dotted_line.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});
  static const routeName = '/receipt-screen';

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final GlobalKey _globalKey = GlobalKey();
  late ScreenshotController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScreenshotController();
  }

  Future<void> _saveScreenshot() async {
    try {
      // Capture a screenshot
      final Uint8List? imageData = await _controller.capture();

      // Check if image is not null
      if (imageData != null) {
        // Save the image to the device's gallery
        final result = await ImageGallerySaver.saveImage(
          imageData,
          quality: 100,
          name: 'gabus_receipt',
        );

        // Show a toast with the result
        if (result['isSuccess']) {
          Fluttertoast.showToast(msg: 'Screenshot saved to gallery');
        } else {
          Fluttertoast.showToast(msg: 'Failed to save screenshot');
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to capture screenshot');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving screenshot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ReceiptProvider receiptProvider = Provider.of<ReceiptProvider>(context);
    Receipt? receipt = receiptProvider.currentReceipt;
    bool isOnRoad = Provider.of<OnRoadProvider>(context).isOnRoad;

    final bookDate = receipt?.date;
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
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Screenshot(
            controller: _controller,
            child: Container(
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
                margin: const EdgeInsets.fromLTRB(7, 75, 7, 90),
                padding: const EdgeInsets.fromLTRB(0, 9, 0, 5),
                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                child: ZigZagContainer(
                  height: 100,
                  width: double.infinity,
                  borderRadius: 15,
                  color: Colors.white,
                  child: Center(
                    child: receipt != null
                        ? Column(
                            children: [
                              SizedBox(
                                  height: SizeConfig.safeBlockVertical * 0.8),
                              const Text(
                                'You have successfully paid for your ticket!',
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
                                    '₱ ${receipt.fare}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 4.5,
                                    ),
                                  ),
                                  Text(
                                    "using your GaBus Credits.",
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
                                          receipt.id.toUpperCase(),
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
                                          'Booked Date',
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Travel Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          isOnRoad == true
                                              ? bookingDateDisplay
                                              : receipt.travelDate.toString(),
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
                                            receipt.seatNum.join(', '),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal *
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
                                          receipt.busNum,
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
                                          receipt.plateNum,
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
                                          receipt.origin,
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
                                            receipt.destination,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal *
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
                                        height:
                                            SizeConfig.safeBlockVertical * 2),
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
                                          '₱ ${receipt.fare}',
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
                                        height:
                                            SizeConfig.safeBlockVertical * 2),
                                    const DottedDivider(),
                                    Text(
                                      'Note: Please take a screenshot of this receipt and present it to the driver.',
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.safeBlockHorizontal *
                                                2.6,
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
                                            SizeConfig.safeBlockHorizontal *
                                                2.5,
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
          ),
          Positioned(
            bottom: 65,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Provider.of<TerminalSeatsProvider>(context, listen: false)
                        .reset();
                    Provider.of<OriginProvider>(context, listen: false)
                        .resetOrigin();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      BookFromScreen.routeName,
                      (route) => false,
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        size: SizeConfig.safeBlockHorizontal * 6,
                        color: Colors.orange.shade900,
                      ),
                      SizedBox(width: SizeConfig.safeBlockVertical * .4),
                      Text(
                        'New Reservation',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade900,
                          fontSize: SizeConfig.safeBlockHorizontal * 3.7,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SizeConfig.safeBlockVertical * .4),
                GestureDetector(
                  onTap: _saveScreenshot,
                  child: Row(
                    children: [
                      Icon(
                        Icons.screenshot,
                        size: SizeConfig.safeBlockHorizontal * 6,
                        color: Colors.orange.shade900,
                      ),
                      SizedBox(width: SizeConfig.safeBlockVertical * .3),
                      Text(
                        'Download Receipt',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade900,
                          fontSize: SizeConfig.safeBlockHorizontal * 3.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 5,
            left: 20,
            right: 20,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    WalletScreen.routeName,
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(60, 9, 60, 9),
                  child: Text(
                    "Done",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        fontSize: SizeConfig.blockSizeHorizontal * 4.5),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20), // Set the desired radius here
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
