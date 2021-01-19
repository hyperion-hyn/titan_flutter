import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

typedef RoundBorderTextFieldOnChanged = void Function(String text);

class RoundBorderTextField extends StatefulWidget {
  final TextInputType keyboardType;
  final Function validator;
  final TextEditingController controller;
  final String hintText;
  final RoundBorderTextFieldOnChanged onChanged;
  final Widget suffixIcon;
  final Widget suffix;
  final FocusNode focusNode;
  final String suffixText;
  final TextStyle suffixStyle;
  final bool isDense;
  final Color bgColor;
  final int maxLength;
  final List<TextInputFormatter> inputFormatters;
  final String errorText;

  RoundBorderTextField({
    this.keyboardType,
    this.validator,
    this.controller,
    this.hintText,
    this.onChanged,
    this.suffixIcon,
    this.focusNode,
    this.suffix,
    this.suffixText,
    this.suffixStyle,
    this.isDense = true,
    this.bgColor,
    this.maxLength,
    this.inputFormatters,
    this.errorText,
  });

  @override
  State<StatefulWidget> createState() {
    return _RoundBorderTextFieldState();
  }
}

class _RoundBorderTextFieldState extends State<RoundBorderTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        focusNode: widget.focusNode,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          counterText: "",
          isDense: widget.isDense,
          suffixIcon: widget.suffixIcon,
          suffix: widget.suffix,
          suffixText: widget.suffixText,
          suffixStyle: widget.suffixStyle,
          filled: true,
          fillColor: widget.bgColor != null ? widget.bgColor : HexColor('#FFF2F2F2'),
          hintText: widget.hintText,
          errorText: widget.errorText,
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
              color: HexColor('#FF4C3B'),
              width: 0.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(fontSize: 13),
        onChanged: (text) {
          widget.onChanged(text);
        },
      ),
    );
  }
}
