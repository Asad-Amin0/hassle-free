#!/bin/bash

# 1. Install Flutter
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter stable branch..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# 2. Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Disable Analytics and Precache Web
flutter config --no-analytics
flutter precache --web

# 4. Build the project
echo "Building Flutter Web..."
cd hassle_free
flutter pub get
flutter build web --release --base-href /

# 5. Move the output to the root so Vercel can find it if needed
# (Only if you set the output directory to 'hassle_free/build/web' in Vercel)
echo "Build complete."
