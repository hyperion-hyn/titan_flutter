import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

class LoadingPanel extends StatelessWidget {
  final ScrollController scrollController;

  LoadingPanel({this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
      decoration: BoxDecoration(
//        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FailPanel extends StatelessWidget {
  final String message;
  final bool showCloseBtn;
  final ScrollController scrollController;

  final Function onClose;

  FailPanel({this.message, this.showCloseBtn, this.scrollController, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
//        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: NeverScrollableScrollPhysics(),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(message ?? 'search fault'),
              ),
            ),
            if (showCloseBtn == true)
              Positioned(
                right: 8,
                top: 4,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  highlightColor: Colors.transparent,
                  child: Ink(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffececec),
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
