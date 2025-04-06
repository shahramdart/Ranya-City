import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'dart:ui';

import 'package:ranyacity/Config/theme.dart';

class MyCustomDropDown extends StatelessWidget {
  const MyCustomDropDown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
    this.width,
    this.height,
    this.dy,
    this.dx,
    this.menuItemHeight,
    this.menuItemwidth,
  });

  final String? value;
  final Function(String?) onChanged;
  final List<DropdownMenuItem<String>> items;
  final double? width;
  final double? height;
  final double? dy;
  final double? dx;
  final double? menuItemHeight;
  final double? menuItemwidth;

  @override
  Widget build(BuildContext context) {
    final bool isValidValue = items.any((item) => item.value == value);
    return DropdownButton2<String>(
      value: isValidValue ? value : null,
      onChanged: onChanged,
      underline: Container(),
      buttonStyleData: ButtonStyleData(
        height: height ?? 60,
        width: width ?? MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white.withOpacity(0.5),
          border: Border.all(
            color: RiveAppTheme.background2.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
        padding: EdgeInsets.only(left: 14, right: 14),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          IconlyLight.arrow_down,
        ),
        iconSize: 14,
        iconEnabledColor: Colors.black,
        iconDisabledColor: Colors.grey,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: menuItemHeight ?? 200,
        width: menuItemwidth ?? MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        offset: Offset(dx ?? 0, dy ?? 0),
        scrollbarTheme: ScrollbarThemeData(
          radius: Radius.circular(40),
          thickness: MaterialStateProperty.all<double>(6),
          thumbVisibility: MaterialStateProperty.all<bool>(true),
        ),
      ),
      items: items,
    );
  }
}
