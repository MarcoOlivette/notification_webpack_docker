#!/bin/bash

CONTAINER_NAME="asa_buildfront"
HISTORY_FILE="/tmp/asa_vuejs_build_history.log"
SUCCESS_LINE="✔ Mix: Compiled successfully in"
ICON_PATH="/usr/share/icons/webpack.png"
ICON_URL="https://raw.githubusercontent.com/webpack/media/master/logo/icon.png"

# Verifica se o ícone do Webpack existe
if [[ ! -f "$ICON_PATH" ]]; then
    echo "⬇️  Baixando ícone do Webpack para $ICON_PATH..."
    sudo wget -q -O "$ICON_PATH" "$ICON_URL"
    if [[ $? -ne 0 ]]; then
        echo "❌ Falha ao baixar o ícone do Webpack. Verifique a URL ou conexão."
        exit 1
    fi
fi

echo "👀 Observando builds do container: $CONTAINER_NAME"
echo "Histórico salvo em: $HISTORY_FILE"

# Garante que o arquivo de histórico existe
touch "$HISTORY_FILE"

while true; do
    LOG=$(docker logs "$CONTAINER_NAME" 2>&1 | tail -n 30)
    COMPILE_LINE=$(echo "$LOG" | grep "$SUCCESS_LINE" | tail -n 1)

    if [[ -n "$COMPILE_LINE" ]]; then
        NOW=$(date +%s)
        NOW_HUMAN=$(date '+%d/%m/%Y %H:%M:%S')
        ENTRY_HASH=$(echo "$COMPILE_LINE" | md5sum | awk '{print $1}')

        TMP_FILE=$(mktemp)
        while IFS= read -r line; do
            TS=$(echo "$line" | awk '{print $1}')
            DIFF=$((NOW - TS))
            if ((DIFF < 1800)); then
                echo "$line" >> "$TMP_FILE"
            fi
        done < "$HISTORY_FILE"
        mv "$TMP_FILE" "$HISTORY_FILE"

        if ! grep -q "$ENTRY_HASH" "$HISTORY_FILE"; then
            echo "$NOW $ENTRY_HASH" >> "$HISTORY_FILE"
            echo "✅ Nova build detectada às $NOW_HUMAN"
            echo "ℹ️ $COMPILE_LINE"

            notify-send \
                --icon="$ICON_PATH" \
                "🧱 Webpack finalizado no container $CONTAINER_NAME" \
                "📦 $COMPILE_LINE\n🕒 $NOW_HUMAN"
        fi
    fi

    sleep 0.5
done
