import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/business/my/app_area.dart';

class SelecteAppAreaDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelecteAppAreaState();
  }
}

class _SelecteAppAreaState extends State<SelecteAppAreaDialog> {
  var selectedAppArea = AppArea.MAINLAND_CHINA_AREA.key;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: Column(
        children: <Widget>[
          Text(S.of(context).please_select_app_area),
          SizedBox(
            height: 8,
          ),
          RadioListTile(
            value: AppArea.MAINLAND_CHINA_AREA.key,
            groupValue: selectedAppArea,
            onChanged: (appArea) {
              setState(() {
                selectedAppArea = appArea;
              });
            },
            title: Text(AppArea.MAINLAND_CHINA_AREA.name),
          ),
          RadioListTile(
            value: AppArea.OTHER_AREA.key,
            groupValue: selectedAppArea,
            onChanged: (appArea) {
              setState(() {
                selectedAppArea = appArea;
              });
            },
            title: Text(AppArea.OTHER_AREA.name),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 36),
            constraints: BoxConstraints.expand(height: 48),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              disabledColor: Colors.grey[600],
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              disabledTextColor: Colors.white,
              onPressed: () async {
                appAreaChange(AppArea.APP_AREA_MAP[selectedAppArea]);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      S.of(context).confirm,
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
