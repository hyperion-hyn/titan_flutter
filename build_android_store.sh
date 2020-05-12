#!/usr/bin/env bash
flutter clean
flutter build appbundle --target-platform=android-arm,android-arm64 --release --target=lib/main_store_prod.dart #--split-per-abi