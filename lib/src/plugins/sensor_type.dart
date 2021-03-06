import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';

import '../global.dart';

class SensorType {
  static const int WIFI = -1;
  static const int BLUETOOTH = -2;
  static const int GPS = -3;
  static const int GNSS = -4;
  static const int CELLULAR = -5;
  static const int POI = -6;

  static String getScanImageName(int type) {
    var _imageName = "wifi";

    switch (type) {
      case WIFI:
        _imageName = "wifi";
        break;

      case CELLULAR:
        _imageName = "basestation";
        break;

      case BLUETOOTH:
        _imageName = "bluetooth";
        break;

      case GPS:
        _imageName = "gps";
        break;
    }

    return _imageName;
  }

  static String getScanName(BuildContext context, int type) {
    var name = "";

    switch (type) {
      case WIFI:
        name = S.of(context).scan_name_wifi;
        break;

      case CELLULAR:
        name = S.of(context).scan_name_cellular;
        break;

      case BLUETOOTH:
        name = S.of(context).scan_name_bluetooth;
        break;

      case GPS:
        name = S.of(context).scan_name_gps;
        break;

      case GNSS:
//        name = S.of(globalContext).scan_name_start;
        name = '';
        break;

      case POI:
        name = "POI";
        break;
    }

    return name;
  }

  static String getTypeString(int type) {
    switch (type) {
      case WIFI:
        {
          return "WIFI";
        }
      case BLUETOOTH:
        {
          return "BLUETOOTH";
        }
      case GPS:
        {
          return "GPS";
        }
      case GNSS:
        {
          return "GNSS";
        }
      case CELLULAR:
        {
          return "CELLULAR";
        }
      case POI:
        {
          return "POI";
        }
      default:
        {
          return "UNKNOWN";
        }
    }
  }
}
