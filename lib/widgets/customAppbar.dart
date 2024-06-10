import 'package:event/constants/styles.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final Widget leading;
  final String titleText;
  final Widget rightButton;
  final BuildContext context;

  CustomAppbar({
    required this.leading,
    required this.titleText,
    required this.context,
    required this.rightButton,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  leading,
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      titleText,
                      style: kNameTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            rightButton, // Add the right button here
          ],
        ),
      ),
    );
  }
}