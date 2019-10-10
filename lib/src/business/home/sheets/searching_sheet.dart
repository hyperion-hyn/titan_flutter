import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchingBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: SizedBox(
        height: 32,
        width: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }
}
