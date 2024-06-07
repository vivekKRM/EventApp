import 'package:event/constants/styles.dart';
import 'package:flutter/material.dart';

class Constants {
  static const MAP_REGEXP = '.* id="(.*)" title="(.*)" .* d="(.*)"';
  static const MAP_SIZE_REGEXP = '<svg.* height="(.*)" width="(.*)"';
  static const ASSETS_PATH = 'assets/images';

}




class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: kButtonColor,
        ),
        child: Text(text, style: kButtonTextStyle),
        onPressed: onPressed,
      ),
    );
  }
}


class CustomAppBarr extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final Color leadingIconColor;
  final String titleText;
  final TextStyle titleTextStyle;
  final VoidCallback? onLeadingIconPressed;

  CustomAppBarr({
    required this.backgroundColor,
    required this.leadingIconColor,
    required this.titleText,
    required this.titleTextStyle,
    this.onLeadingIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: leadingIconColor),
        onPressed: onLeadingIconPressed ?? () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        titleText,
        style: titleTextStyle,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

