#!/bin/bash

echo "🧹 Очистка данных приложения LavaLedger..."
echo ""

# Находим Bundle Identifier из проекта
BUNDLE_ID="IOI.DF723"

echo "📱 Bundle ID: $BUNDLE_ID"
echo ""

# Очищаем UserDefaults для симулятора
echo "Очистка данных из симулятора..."

# Находим все симуляторы
SIMULATOR_IDS=$(xcrun simctl list devices | grep "iPhone" | grep -v "unavailable" | sed -n 's/.*(\([^)]*\)).*/\1/p')

for SIM_ID in $SIMULATOR_IDS; do
    echo "  - Симулятор: $SIM_ID"
    # Удаляем данные приложения
    xcrun simctl uninstall "$SIM_ID" "$BUNDLE_ID" 2>/dev/null
done

echo ""
echo "✅ Данные очищены!"
echo ""
echo "Теперь при запуске приложение будет абсолютно чистым:"
echo "  - Без целей"
echo "  - Без транзакций"
echo "  - Без истории"
echo "  - Показ онбординга при первом запуске"
echo ""
echo "🚀 Запустите приложение в Xcode (Cmd+R)"

