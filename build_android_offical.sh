#!/usr/bin/env bash
#flutter build apk --flavor=official --release --target=lib/main_official_prod.dart
flutter build apk --target-platform=android-arm,android-arm64 --release --target=lib/main_android_official_prod.dart #--split-per-abi