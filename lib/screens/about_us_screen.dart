import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:photo_view/photo_view.dart';
import '../common/app_layout.dart';
import '../common/size_config.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/header_widget.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});
  final double _headerHeight = 250;
  static const routeName = '/about-us';

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    SizeConfig().init(context);
    return GradientScaffold(
      body: Stack(
        children: [
          Container(
            height: _headerHeight,
            child: HeaderWidget(_headerHeight, false,
                Icons.login_rounded), //let's create a common header widget
          ),
          SizedBox(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: SizeConfig.safeBlockVertical * 10.5),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Text(
                          'GaBus Developers'.toUpperCase(),
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 5,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(AppLayout.getHeight(5)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) {
                                return Scaffold(
                                  extendBodyBehindAppBar: true,
                                  backgroundColor: Colors.black,
                                  body: Center(
                                    child: PhotoView(
                                      minScale:
                                          PhotoViewComputedScale.contained *
                                              0.8,
                                      maxScale:
                                          PhotoViewComputedScale.covered * 2,
                                      enableRotation: false,
                                      imageProvider: AssetImage(
                                        'assets/images/group_photo.png',
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/group_photo.png',
                              height: SizeConfig.blockSizeVertical * 30,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Gap(AppLayout.getHeight(45)),
                        Column(
                          children: [
                            Container(
                              height: AppLayout.getHeight(374.5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade50,
                                    Colors.orange.shade200,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.fromLTRB(10, 2.5, 10, 0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 25),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '  GaBus is the result of months of hard work and collaboration by our team of passionate developers. We understand the challenges that commuters face when booking bus tickets, which is why we created an innovative solution that streamlines the process and makes it easy for everyone.\n  Our system is designed to be user-friendly, with a clean and intuitive interface that allows users to quickly search for available routes, choose their preferred seats, and make payments securely.\n  With GaBus, commuters no longer have to worry about the hassle of long queues, unreliable schedules, or overpriced fares. Our platform offers a convenient and affordable solution that is accessible to everyone, from students to professionals and families.\n  In addition, we are constantly striving to improve our service and add new features that enhance the user experience. Our team is committed to providing exceptional customer support and ensuring that every journey is a pleasant and stress-free experience.',
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  3.8,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 358, // set the bottom position to 10% of the screen height
            right: AppLayout.getWidth(10),
            left: AppLayout.getWidth(
                10), // set the right position to 10% of the screen width
            child: Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 255, 231, 194),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/Gabus-Logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
