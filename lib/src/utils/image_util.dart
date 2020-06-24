
import 'package:flutter/material.dart';

class ImageUtil{
  static Widget getCoinImage(String imageUrl) {
    var isNetworkUrl = imageUrl.contains("http");
    if (!isNetworkUrl) {
      return Image.asset(imageUrl);
    }
    return FadeInImage.assetNetwork(
      placeholder: 'res/drawable/img_placeholder_circle.png',
      image: imageUrl,
      fit: BoxFit.cover,
    );
  }
}