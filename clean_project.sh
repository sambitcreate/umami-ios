#!/bin/bash

# Navigate to the project directory
cd "/Users/sambitbiswas/projects/Umami/umami ios/Umami Analytics"

# Clean the Xcode project
xcodebuild clean -project "Umami Analytics.xcodeproj" -scheme "Umami Analytics" || true

# Remove derived data for this project
rm -rf ~/Library/Developer/Xcode/DerivedData/Umami_Analytics-*

echo "Project cleaned successfully!"
