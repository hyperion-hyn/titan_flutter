//library custom_radio_grouped_button;
import 'package:flutter/material.dart';

class CustomRadioButton extends StatefulWidget {
  CustomRadioButton({
    this.buttonLabels,
    this.buttonValues,
    this.fontSize = 15,
    this.autoWidth = true,
    this.radioButtonValue,
    this.buttonColor,
    this.padding = 3,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.height = 35,
    this.width = 100,
    this.horizontal = false,
    this.enableShape = false,
    this.elevation = 0,
    this.customShape,
  })  : assert(buttonLabels.length == buttonValues.length),
        assert(buttonColor != null),
        assert(selectedColor != null);

  final bool horizontal;

  final List buttonValues;

  final double height;
  final double width;
  final double padding;

  ///Only applied when in vertical mode
  final bool autoWidth;

  final List<String> buttonLabels;

  final double fontSize;

  final Function(String) radioButtonValue;

  final Color selectedColor;

  final Color selectedTextColor;
  final Color unselectedTextColor;

  final Color buttonColor;
  final ShapeBorder customShape;
  final bool enableShape;
  final double elevation;

  _CustomRadioButtonState createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  int currentSelected = 0;
  String currentSelectedLabel;

  @override
  void initState() {
    super.initState();
    currentSelectedLabel = widget.buttonLabels[0];
  }

  List<Widget> buildButtonsColumn() {
    List<Widget> buttons = [];
    for (int index = 0; index < widget.buttonLabels.length; index++) {
      var button = Padding(
        padding: EdgeInsets.all(widget.padding),
        child: Card(
          color: currentSelectedLabel == widget.buttonLabels[index]
              ? widget.selectedColor
              : widget.buttonColor,
          elevation: widget.elevation,
          shape: widget.enableShape
              ? widget.customShape == null
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    )
                  : widget.customShape
              : null,
          child: Container(
            height: widget.height,
            child: MaterialButton(
              shape: widget.enableShape
                  ? widget.customShape == null
                      ? OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        )
                      : widget.customShape
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              currentSelectedLabel == widget.buttonLabels[index]
                                  ? widget.selectedTextColor
                                  : Colors.grey,
                          width: 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
              onPressed: () {
                widget.radioButtonValue(widget.buttonValues[index]);
                setState(() {
                  currentSelected = index;
                  currentSelectedLabel = widget.buttonLabels[index];
                });
              },
              child: Text(
                widget.buttonLabels[index],
                style: TextStyle(
                  color: currentSelectedLabel == widget.buttonLabels[index]
                      ? widget.selectedTextColor != null
                          ? widget.selectedTextColor
                          : Colors.white
                      : widget.unselectedTextColor != null
                          ? widget.unselectedTextColor
                          : Colors.black,
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          ),
        ),
      );
      buttons.add(button);
    }
    return buttons;
  }

  List<Widget> buildButtonsRow() {
    List<Widget> buttons = [];
    for (int index = 0; index < widget.buttonLabels.length; index++) {
      var button = Card(
        color: currentSelectedLabel == widget.buttonLabels[index]
            ? widget.selectedColor
            : widget.buttonColor,
        elevation: widget.elevation,
        shape: widget.enableShape
            ? widget.customShape == null
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  )
                : widget.customShape
            : null,
        child: Container(
          height: widget.height,
          width: widget.autoWidth ? null : widget.width,
          constraints: BoxConstraints(maxWidth: 250),
          child: MaterialButton(
            shape: widget.enableShape
                ? widget.customShape == null
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      )
                    : widget.customShape
                : OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            currentSelectedLabel == widget.buttonLabels[index]
                                ? widget.selectedTextColor
                                : Colors.grey,
                        width: 1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
            onPressed: () {
              widget.radioButtonValue(widget.buttonValues[index]);
              setState(() {
                currentSelected = index;
                currentSelectedLabel = widget.buttonLabels[index];
              });
            },
            child: Text(
              widget.buttonLabels[index],
              style: TextStyle(
                color: currentSelectedLabel == widget.buttonLabels[index]
                    ? widget.selectedTextColor != null
                        ? widget.selectedTextColor
                        : Colors.white
                    : widget.unselectedTextColor != null
                        ? widget.unselectedTextColor
                        : Colors.black,
                fontSize: widget.fontSize,
              ),
            ),
          ),
        ),
      );
      buttons.add(button);
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.horizontal
          ? widget.height * (widget.buttonLabels.length * 1.5) +
              widget.padding * 2 * widget.buttonLabels.length
          : widget.height + widget.padding * 2,
      child: Center(
        child: widget.horizontal
            ? ListView(
                scrollDirection: Axis.vertical,
                children: buildButtonsColumn(),
              )
            : ListView(
                scrollDirection: Axis.horizontal,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buildButtonsRow(),
              ),
      ),
    );
  }
}
