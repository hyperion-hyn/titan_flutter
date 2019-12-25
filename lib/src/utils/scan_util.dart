
class ScanUtils {

  // tools
  static void addValuesToList(Map values, List list, String key) {
    if (list.isEmpty) {
      list.add(values);
      return;
    }

    var _isExist = false;
    var _value = values[key] ?? "";
    for (var item in list) {
      var _oldValue = item[key] ?? "";
      if (_oldValue == _value && _value.length > 0 && _oldValue.length > 0) {
        _isExist = true;
        break;
      }
    }
    if (!_isExist) {
      list.add(values);
    }
  }

  static void appendValue(Map values, List list, String key) {
    var value = values[key] ?? "";
    value = "${key.toUpperCase()}：${value}";
    list.add(value);
  }
}