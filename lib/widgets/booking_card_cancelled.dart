import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import '../common/app_layout.dart';
import '../models/user_transactions.dart';
import '/common/size_config.dart';

import 'column_layout.dart';
import 'layout_builder_widget.dart';
import 'thick_container.dart';

import '../models/get_transactions.dart';

import '/screens/authentication/users/auth_service.dart';

class BookingCardCancelled extends StatelessWidget {
  final bool? isColor;
  final AuthService _authService = AuthService();
  List<UserTransaction> transactions = [];

  BookingCardCancelled({super.key, this.isColor});

  Stream<List<GetTransaction>> getTransactionsStream() {
    return _authService.getTransactionsStream();
  }

  @override
  Widget build(BuildContext context) {
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

        if (snapshot.data == null || snapshot.data!.isEmpty) {
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

        if (snapshot.hasData) {
          List<GetTransaction> bookTransactions = snapshot.data!;
          String seatNumbers = bookTransactions.first.seatNum.join(', ');

          const int maxLength = 10; // set the maximum length to 10 characters
          if (seatNumbers.length > maxLength) {
            seatNumbers = '${seatNumbers.substring(0, maxLength)}...';
          }
          return SizedBox(
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
                                                        : Colors.grey.shade300),
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
                                  fontSize: SizeConfig.blockSizeHorizontal * 3,
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
                                  fontSize: SizeConfig.blockSizeHorizontal * 3,
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
                        bottomRight: Radius.circular(isColor == null ? 21 : 0),
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
                              firstText: 'Cancelled Reservation',
                              secondText:
                                  'Details of the cancelled reservation.',
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
