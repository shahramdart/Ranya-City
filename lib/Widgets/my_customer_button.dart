import 'package:flutter/material.dart';
import 'package:ranyacity/Config/theme.dart';
class MyCustomerButton extends StatelessWidget {
  const MyCustomerButton({
    super.key,
    required this.btnName,
    required this.onTap,
    this.radius,
    this.width,
    this.height,
    this.style,
    this.backgroundButton,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.vertical,
    this.horizontal,
    this.border,
  });
  final String btnName;
  final VoidCallback onTap;
  final BorderRadius? radius;
  final double? width;
  final double? height;
  final TextStyle? style;
  final Color? backgroundButton;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final double? vertical;
  final double? horizontal;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: height ?? 60,
        width: width ?? 300,
        decoration: BoxDecoration(
          color: backgroundButton ?? RiveAppTheme.background2,
          borderRadius: radius ?? BorderRadius.circular(12),
          border: border ?? null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon == null) ...[
                Text(
                  btnName,
                  style: style ??
                      TextStyle(
                        fontSize: 24,
                        color:  Colors.white,
                        fontFamily: "kurdish",
                      ),
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      btnName,
                      style: style ??
                          TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontFamily: "kurdish",
                          ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      icon,
                      color: iconColor,
                      size: iconSize,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}