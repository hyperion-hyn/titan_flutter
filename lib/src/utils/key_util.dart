
import 'package:flutter/material.dart';
import 'package:titan/env.dart';

class KeyUtil{

  static Key getWidgetKey(String testKey){
    if (env.buildType == BuildType.DEV) {
      return Key(testKey);
    }
    return null;
  }

}