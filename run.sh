#!/bin/bash

echo "🚀 Запуск LavaLedger..."
echo ""

# Находим первый доступный симулятор
SIMULATOR_ID="05D5F09F-9728-43D1-B153-10E1145FF48E"

echo "📱 Используем симулятор: iPhone 15 Pro"
echo "🔨 Компиляция и запуск..."
echo ""

xcodebuild -project DF723.xcodeproj \
    -scheme DF723 \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Сборка успешна!"
    echo ""
    echo "🎉 Приложение LavaLedger готово!"
    echo ""
    echo "Теперь запустите приложение в Xcode или используйте:"
    echo "  open -a Simulator"
    echo "  xcrun simctl install booted <path-to-app>"
else
    echo ""
    echo "❌ Ошибка при сборке"
    exit 1
fi

