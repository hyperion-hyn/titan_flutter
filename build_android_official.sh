#!/usr/bin/env bash
flutter clean
flutter build apk --release --target=lib/main_official_prod.dart --target-platform android-arm,android-arm64