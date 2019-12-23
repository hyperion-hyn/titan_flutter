class SensorType {
  static const int WIFI = -1;
  static const int BLUETOOTH = -2;
  static const int GPS = -3;
  static const int GNSS = -4;
  static const int CELLULAR = -5;

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
      default:
        {
          return "UNKNOWN";
        }
    }
  }
}
