#!/bin/bash

#!/bin/bash

CONTAINER_NAME="asa_buildfront"
HISTORY_FILE="/tmp/asa_vuejs_build_history.log"
ERROR_FLAG_FILE="/tmp/asa_vuejs_error_detected.log"
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
[[ -f "$HISTORY_FILE" ]] || echo "" > "$HISTORY_FILE"

while true; do
    # Começa com logs curtos
    LOG=$(docker logs "$CONTAINER_NAME" 2>&1 | tail -n 30)

    # Verifica se houve erro
    ERROR_LINE=$(echo "$LOG" | grep "compiled with" | grep -v "successfully" | tail -n 1)
    if echo "$ERROR_LINE" | grep -q "compiled with"; then
        HAS_ERROR=1
        LOG=$(docker logs "$CONTAINER_NAME" 2>&1 | tail -n 100)
        ERROR_LINE=$(echo "$LOG" | grep "compiled with" | grep -v "successfully" | tail -n 1)
    else
        HAS_ERROR=0
    fi

    # Captura linha de compilação com sucesso
    COMPILE_LINE=$(echo "$LOG" | grep "$SUCCESS_LINE" | tail -n 1)

    if [[ -n "$COMPILE_LINE" ]]; then
        NOW=$(date +%s)
        NOW_HUMAN=$(date '+%d/%m/%Y %H:%M:%S')
        UNIQUE_COMPILE_KEY="$COMPILE_LINE - $NOW_HUMAN"
        ENTRY_HASH=$(echo "$UNIQUE_COMPILE_KEY" | md5sum | awk '{print $1}')

        # Apaga histórico antigo mas preserva último hash
        if [[ -s "$HISTORY_FILE" ]]; then
            LAST_LINE=$(tail -n 1 "$HISTORY_FILE")
            LAST_TIMESTAMP=$(echo "$LAST_LINE" | awk '{print $1}')
            AGE=$((NOW - LAST_TIMESTAMP))
            if ((AGE > 1800)); then
                rm -f "$HISTORY_FILE"
                echo "$LAST_LINE" > "$HISTORY_FILE"
            fi
        fi

        # Atualiza histórico com registros recentes
        TMP_FILE=$(mktemp)
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            TS=$(echo "$line" | awk '{print $1}')
            DIFF=$((NOW - TS))
            if ((DIFF < 1800)); then
                echo "$line" >> "$TMP_FILE"
            fi
        done < "$HISTORY_FILE"
        cp "$TMP_FILE" "$HISTORY_FILE"
        rm -f "$TMP_FILE"

        # 💥 Se erro foi detectado e ainda não notificado
        if [[ "$HAS_ERROR" == "1" ]]; then
            if [[ ! -f "$ERROR_FLAG_FILE" ]]; then
                echo "❌ Erro detectado na compilação às $NOW_HUMAN"
                echo "$ERROR_LINE"
                echo "error detected" > "$ERROR_FLAG_FILE"

                ERROR_SUMMARY=$(echo "$LOG" | grep -A 5 "Module build failed" | head -n 6)
                notify-send \
                    --icon="$ICON_PATH" \
                    "❌ Webpack com erro no container $CONTAINER_NAME" \
                    "📦 $ERROR_LINE\n🕒 $NOW_HUMAN\n\n$ERROR_SUMMARY"
            fi
        else
            # 🧹 Se erro foi resolvido, remove o flag
            [[ -f "$ERROR_FLAG_FILE" ]] && rm -f "$ERROR_FLAG_FILE"

            # ✅ Notificação de sucesso se hash ainda não registrado
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
    fi

    sleep 0.5
done
