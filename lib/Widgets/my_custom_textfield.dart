import 'package:flutter/material.dart';
import 'package:ranyacity/Config/theme.dart';

class MyTextFieldIconly extends StatefulWidget {
  const MyTextFieldIconly({
    super.key,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.margin_top,
    this.width,
    this.height,
    this.maxlines,
    this.vertical_top,
    this.vertical_top_icon,
    this.hintStyle,
  });

  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final double? margin_top;
  final double? vertical_top;
  final double? vertical_top_icon;
  final double? width;
  final double? height;
  final int? maxlines;
  final TextStyle? hintStyle;

  @override
  _MyTextFieldIconlyState createState() => _MyTextFieldIconlyState();
}

class _MyTextFieldIconlyState extends State<MyTextFieldIconly> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Check if maxLines is greater than 1 to adjust the padding
    bool isMultiline = widget.maxlines != null && widget.maxlines! > 1;

    return Container(
      margin: EdgeInsets.only(
        top: widget.margin_top ?? 70,
      ),
      height: widget.height ?? 60,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.5),
        border: Border.all(
          color: RiveAppTheme.background2.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller, // Keeps the text intact
        obscureText: widget.isPassword
            ? _obscureText
            : false, // Toggle password visibility
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
              vertical: isMultiline ? 8 : (widget.vertical_top ?? 15)),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: widget.vertical_top_icon ?? (isMultiline ? 0 : 8)),
            child: Icon(widget.icon),
          ),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ??
              TextStyle(
                fontSize: 15,
                fontFamily: "English",
              ),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          // Add a suffix icon for toggling visibility
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Toggle visibility
                    });
                  },
                )
              : null,
        ),
        maxLines: widget.maxlines ?? 1,
      ),
    );
  }
}
