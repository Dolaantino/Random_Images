#!/bin/bash

echo "Установка CocoaPods..."
brew install cocoapods

echo "Установка зависимостей..."
pod deintegrate
pod install

echo "Запуск проекта..."
open RandomImages.xcworkspace

echo "Установка завершена."

