#!/bin/bash
set -e
echo "=== Trading Journal Setup ==="
echo ""
echo "Step 1: Getting packages..."
flutter pub get

echo ""
echo "Step 2: Running code generation..."
dart run build_runner build --delete-conflicting-outputs

echo ""
echo "=== Setup complete! Run: flutter run ==="
