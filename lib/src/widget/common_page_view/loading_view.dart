import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class LoadingView extends StatelessWidget {
  final String loadingColor;
  LoadingView(this.loadingColor);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            HexColor(loadingColor),
          ),
        ),
      ),
    );
  }
}
