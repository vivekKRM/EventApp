import 'package:event/constants/styles.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final Widget leading;
  final String titleText;
  final BuildContext context;

  CustomAppbar({
    required this.leading,
    required this.titleText,
    required this.context,
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
            InkWell(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: Image(
                width: 30,
                height: 30,
                image: AssetImage('assets/tab.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
