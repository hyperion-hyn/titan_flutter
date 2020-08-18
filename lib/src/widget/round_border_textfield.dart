import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/global_data/echarts/world.dart';

typedef RoundBorderTextFieldOnChanged = void Function(String text);

class RoundBorderTextField extends StatefulWidget {
  final TextInputType textInputType;
  final Function validator;
  final TextEditingController textEditingController;
  final String hint;
  final RoundBorderTextFieldOnChanged onChanged;
  final Widget suffixIcon;

  RoundBorderTextField({
    this.textInputType,
    this.validator,
    this.textEditingController,
    this.hint,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<StatefulWidget> createState() {
    return _RoundBorderTextFieldState();
  }
}

class _RoundBorderTextFieldState extends State<RoundBorderTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.textEditingController,
      keyboardType: widget.textInputType,
      decoration: InputDecoration(
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor: HexColor('#FFF2F2F2'),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: HexColor('#FF999999'),
          fontSize: 13,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: HexColor('#FFF2F2F2'),
            width: 0.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: HexColor('#FFF2F2F2'),
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: HexColor('#FFF2F2F2'),
            width: 0.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(fontSize: 13),
      onChanged: (text) {
        widget.onChanged(text);
      },
    );
  }
}
