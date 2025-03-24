# 🧠 Webpack Docker Notifier

> Notifique-se automaticamente com ícones do Webpack sempre que sua aplicação for compilada com sucesso dentro de um container Docker!

⚠️ **Este script funciona apenas em sistemas Linux com suporte a `notify-send` (ex: GNOME, Cinnamon, KDE, XFCE).**

---

## 🚀 O que é isso?

Você está cansado de compilar Vue, React ou qualquer app com Webpack no Docker e **não saber quando terminou**?

Este script Bash resolve isso com estilo:

✅ Observa os logs do seu container  
✅ Detecta quando o Webpack compila com sucesso  
✅ Exibe uma **notificação com ícone do Webpack** no seu desktop Linux  
✅ Ignora builds repetidas  
✅ Baixa automaticamente o ícone, se necessário

---

## 📦 Pré-requisitos

- Linux com suporte a `notify-send`
- Docker instalado e rodando
- Container com saída de build tipo:
  ```
  ✔ Mix: Compiled successfully in 2.38s
  webpack compiled successfully
  ```

---

## 🛠️ Como usar

1. Clone o projeto:

```bash
git clone https://github.com/MarcoOlivette/notification_webpack_docker.git
cd notification_webpack_docker
```

2. Torne o script executável:

```bash
chmod +x watch_vue_build.sh
```

3. Rode com o nome do seu container:

```bash
./watch_vue_build.sh
```

> 💡 Dica: rode isso em uma aba do terminal enquanto você executa o `docker-compose up` ou o build manualmente.

---

## 🖼 Exemplo de notificação

- Título: `🧱 Webpack finalizado no container asa_buildfront`
- Corpo: `✔ Mix: Compiled successfully in 3.25s`
- Ícone: 🌀 Webpack

---

## 🧪 Testar se `notify-send` está funcionando

```bash
notify-send "🚀 Teste de Notificação" "Se você viu isso, tá tudo certo!"
```

---

## 🔓 Licença

Sem licença. Use livremente.
```
