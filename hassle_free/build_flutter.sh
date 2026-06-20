#!/bin/bash

# 1. Install Flutter
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter version 3.41.4..."
  git clone https://github.com/flutter/flutter.git -b 3.41.4 --depth 1
fi

# 2. Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Disable Analytics and Precache Web
flutter config --no-analytics
flutter precache --web

# 4. Build the project
echo "Building Flutter Web..."
flutter pub get
flutter build web --release --base-href /

echo "Build complete."
