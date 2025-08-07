import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../common/app_layout.dart';

import '../common/size_config.dart';

class AppColumnLayout extends StatelessWidget {
  final String firstText;
  final String secondText;
  final CrossAxisAlignment alignment;
  final bool? isColor;
  const AppColumnLayout(
      {Key? key,
      required this.firstText,
      required this.secondText,
      required this.alignment,
      this.isColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    print(isColor);
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          firstText,
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 4,
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(AppLayout.getHeight(5)),
        Text(
          secondText,
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 2.9,
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
