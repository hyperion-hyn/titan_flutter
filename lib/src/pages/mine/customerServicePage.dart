import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/i18n.dart';

class CustomerServicePage extends StatelessWidget {

  final String wxID;
  CustomerServicePage(this.wxID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).contact_customer_service,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          height: 380,
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child:
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: S.of(context).wx_id));
                    Fluttertoast.showToast(msg: S.of(context).copy_wx_id_success_hint);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        S.of(context).wx_id,
                        style: TextStyle(fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.content_copy,
                          size: 16,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Image(
                image: AssetImage("res/drawable/customer_service.jpeg"),
                height: 255,
                //color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  S.of(context).sweep_qr_hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          ],
          ),
        ),
      )
    );
  }
}

