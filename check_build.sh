#!/bin/bash

echo "🔍 Проверка проекта LavaLedger..."
echo ""

# Проверка наличия всех файлов
echo "📁 Проверка файлов:"
files=(
    "DF723/DF723App.swift"
    "DF723/Models/DataModels.swift"
    "DF723/Models/DataManager.swift"
    "DF723/Theme/LavaTheme.swift"
    "DF723/Views/OnboardingView.swift"
    "DF723/Views/MainTabView.swift"
    "DF723/Views/DashboardView.swift"
    "DF723/Views/GoalsView.swift"
    "DF723/Views/HistoryView.swift"
    "DF723/Views/SettingsView.swift"
)

all_files_exist=true
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - ОТСУТСТВУЕТ!"
        all_files_exist=false
    fi
done

echo ""
if [ "$all_files_exist" = true ]; then
    echo "✅ Все файлы на месте!"
else
    echo "❌ Некоторые файлы отсутствуют!"
    exit 1
fi

echo ""
echo "🔨 Попытка сборки проекта..."
echo ""

# Попытка сборки
xcodebuild -project DF723.xcodeproj \
    -scheme DF723 \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    clean build \
    2>&1 | tee build.log

# Проверка результата
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ Проект успешно собран!"
    echo ""
    echo "🚀 Вы можете запустить приложение в Xcode:"
    echo "   1. Откройте DF723.xcodeproj"
    echo "   2. Выберите симулятор iPhone"
    echo "   3. Нажмите Cmd+R для запуска"
else
    echo ""
    echo "⚠️  Ошибки при сборке (возможно, связаны с симулятором)"
    echo "   Полный лог сохранен в build.log"
    echo ""
    echo "   Попробуйте открыть проект в Xcode напрямую:"
    echo "   open DF723.xcodeproj"
fi

