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

