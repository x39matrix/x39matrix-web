# SCREENCAST 90 SEGUNDOS — Guion + ffmpeg sin dependencias propietarias

**Objetivo:** un vídeo viral de 90s mostrando el protocolo soberano funcionando end-to-end. Postear en HN, X (Twitter), DFINITY forum, Mastodon, Nostr.

---

## 🎬 GUION POR SEGUNDOS

| Segundos | Pantalla | Voz/Texto |
|---|---|---|
| 0-5 | Terminal vacía sobre fondo negro | (silencio + parpadeo de cursor) |
| 5-10 | `cat .x39_motto.txt` muestra los 7 axiomas en cascada | (texto en pantalla, sin voz) |
| 10-20 | `./verify/verify_all.sh` corriendo, líneas verdes apareciendo | "10 layers · 0 trust · 0 servers" |
| 20-35 | Browser abre `https://x39matrix.org/verify-web/` | Drag .pdf → 3 semáforos verdes |
| 35-45 | Terminal: `ots verify pdf.ots` muestra BTC block confirmation | "anchored to Bitcoin block 824567" |
| 45-60 | `cargo test --release` con todos los tests verdes en cascada | "reproducible · post-quantum" |
| 60-75 | `git log --show-signature` con todos los commits PGP-signed | "every commit signed · every release anchored" |
| 75-85 | URL final: `github.com/x39matrix/x39matrix` con star count | "verifiable in 10 minutes by anyone" |
| 85-90 | Logo final: `X-39MATRIX :: SOVEREIGN` | (fade out) |

---

## 🛠️ COMANDOS PARA GRABAR EN TU UBUNTU

### 1. Instalar herramientas (todas FOSS, sin proprietary)

```bash
sudo apt update
sudo apt install -y ffmpeg asciinema agg pulseaudio-utils
# agg = asciinema-agg, convierte cast a GIF
# Alternativa: peek (GIF recorder GUI)
sudo apt install -y peek
```

### 2. Preparar entorno terminal cypherpunk

```bash
# Tema verde sobre negro permanente
cat >> ~/.bashrc <<'EOF'
export PS1='\[\e[32m\][x39]\$\[\e[0m\] '
export TERM=xterm-256color
EOF

# Asegurar tipografía mono ancha
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 14'

# Resolución 1920x1080 para grabación
xrandr --output $(xrandr | grep " connected" | head -1 | cut -d' ' -f1) --mode 1920x1080
```

### 3. Crear los assets del screencast

```bash
mkdir -p ~/x39matrix/screencast && cd ~/x39matrix/screencast

# Motto
cat > .x39_motto.txt <<'EOF'
╔═══════════════════════════════════════════════════════════╗
║ X-39MATRIX :: 7 SOVEREIGN AXIOMS                          ║
╠═══════════════════════════════════════════════════════════╣
║ 1. Every signature verifiable without trusting issuer     ║
║ 2. Every timestamp anchored to proof-of-work              ║
║ 3. Every key post-quantum or irrelevant                   ║
║ 4. Every build bit-for-bit reproducible                   ║
║ 5. Every disclosure selective by the subject              ║
║ 6. Every protocol auditable without privileged access     ║
║ 7. All sovereignty individual before collective           ║
╚═══════════════════════════════════════════════════════════╝
EOF
```

### 4. Grabación: 3 pistas paralelas

**Pista 1: Terminal (asciinema → GIF)**

```bash
cd ~/x39matrix/screencast
asciinema rec -t "X-39MATRIX Sovereign Verification" --idle-time-limit 1.5 x39_terminal.cast

# Dentro de la grabación ejecuta en orden, con pausas dramáticas:
clear
cat .x39_motto.txt
sleep 3
cd ~/x39matrix/x39matrix
./verify/verify_all.sh
sleep 2
cd x39_zk_verifier
cargo test --release --features i_understand_this_is_pre_alpha 2>&1 | head -30
sleep 2
cd ..
git log --show-signature -n 5 2>&1 | head -40
sleep 3
# CTRL+D para terminar grabación

# Convertir a GIF
agg --theme monokai --font-size 18 --cols 100 --rows 30 \
    x39_terminal.cast x39_terminal.gif

# O a MP4 para mejor compresión:
agg --theme monokai --font-size 18 x39_terminal.cast - | \
    ffmpeg -i - -c:v libx264 -pix_fmt yuv420p -crf 23 x39_terminal.mp4
```

**Pista 2: Browser (peek o ffmpeg + xdotool)**

```bash
# Opción A: Peek (más fácil)
peek &
# Configura ventana sobre el browser, graba en MP4

# Opción B: ffmpeg directo (más profesional)
firefox https://x39matrix.org/verify-web/ &
sleep 3
# Identifica ventana
WINDOW_ID=$(xdotool search --name "Firefox" | head -1)
xdotool getwindowgeometry $WINDOW_ID

# Graba área específica (ajusta coords según getwindowgeometry)
ffmpeg -y -f x11grab -framerate 30 -video_size 1280x720 -i :0.0+200,100 \
       -c:v libx264 -preset ultrafast -pix_fmt yuv420p \
       -t 25 x39_browser.mp4
```

**Pista 3: Música ambient cypherpunk (opcional, royalty-free)**

```bash
# Descarga track desde Free Music Archive (CC0)
curl -L "https://freemusicarchive.org/file/Lee_Rosevere_Looking_Back.mp3" -o ambient.mp3

# O usa beepy (FOSS retro beeps)
# pip install beepy
# python -c "from beepy import beep; beep(1)"
```

### 5. Composición final del vídeo de 90s

```bash
cd ~/x39matrix/screencast

# Concatenar pistas con transitions
cat > concat.txt <<'EOF'
file 'x39_terminal.mp4'
file 'x39_browser.mp4'
file 'x39_terminal.mp4'
EOF

ffmpeg -y -f concat -safe 0 -i concat.txt \
       -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p \
       -t 90 x39_screencast_raw.mp4

# Añadir overlay de texto cypherpunk en momentos clave
ffmpeg -y -i x39_screencast_raw.mp4 \
  -vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf:\
       text='10 layers · 0 trust · 0 servers':\
       fontcolor=0x00ff41:fontsize=42:x=(w-text_w)/2:y=h-150:\
       enable='between(t,10,20)',\
       drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf:\
       text='anchored to Bitcoin · verifiable in 10 min':\
       fontcolor=0x00ff41:fontsize=42:x=(w-text_w)/2:y=h-150:\
       enable='between(t,35,45)',\
       drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf:\
       text='X-39MATRIX :: SOVEREIGN':\
       fontcolor=0x00ff41:fontsize=72:x=(w-text_w)/2:y=(h-text_h)/2:\
       enable='between(t,85,90)'" \
  -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p \
  x39_screencast_final.mp4

# Verificar duración exacta
ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 x39_screencast_final.mp4
# Debe dar ~90 segundos

# Hash + firma + ancla soberana
sha256sum x39_screencast_final.mp4 > x39_screencast_final.mp4.sha256
gpg --detach-sign --armor x39_screencast_final.mp4
ots stamp x39_screencast_final.mp4
```

### 6. Publicación

```bash
# Subir a tu propio dominio (soberanía total)
scp x39_screencast_final.mp4* user@x39matrix.org:/var/www/html/screencast/

# O a IPFS (descentralizado)
ipfs add -r --cid-version=1 x39_screencast_final.mp4
# Pinear el CID a Pinata via web

# Mirror en peertube (FOSS)
# (sube manualmente via web a una instancia que confíes)
```

---

## 📣 TEXTOS PARA POSTEAR (copy-paste)

### Hacker News (Show HN)

```
Show HN: X-39MATRIX – 10-layer sovereign post-quantum protocol on Bitcoin/ICP

After 18 months of solo cypherpunk dev, I'm releasing X-39MATRIX:
a 10-layer protocol combining ML-DSA-87 + SLH-DSA + threshold-ECDSA + 
zk-STARK + OpenTimestamps anchored to Bitcoin.

Every artifact is reproducible bit-for-bit. Every commit is PGP-signed.
Every release is anchored to Bitcoin via OTS. Every layer is verifiable
by anyone in <10 minutes without trusting me.

90-second demo: <URL>
Repo: https://github.com/x39matrix/x39matrix
Whitepaper (draft): <URL>

Currently pre-alpha. Looking for co-maintainers, audit feedback, and
NLnet/OpenSats grant feedback. AGPL-3.0.
```

### X (Twitter)

```
X-39MATRIX :: sovereign verification, no servers

✅ post-quantum (ML-DSA-87 + SLH-DSA)
✅ threshold-ECDSA on ICP
✅ zk-STARK selective disclosure
✅ Bitcoin OTS anchoring
✅ reproducible builds
✅ PGP-signed history

90s demo ↓
[video]

github.com/x39matrix/x39matrix
```

### Mastodon / Nostr

```
Released: X-39MATRIX, a 10-layer sovereign protocol.

No KYC. No cloud. No custody. No tokens.
Just post-quantum crypto + Bitcoin anchoring + reproducible builds.

90s demo: <URL>
Source: github.com/x39matrix/x39matrix
License: AGPL-3.0

#cypherpunk #postquantum #bitcoin #sovereignty
```

---

## ⚠️ NOTAS

- Si tu Ubuntu no tiene GUI (servidor headless), usa solo asciinema → agg → MP4 sin pista de browser. Sigue siendo viralizable.
- No grabes tu desktop completo: configura ventanas exactas con coordenadas conocidas.
- Audio opcional: si decides poner narración, hazlo TÚ con tu voz. Nunca AI-voice (los cypherpunks lo detectan).
- Subtítulos: añade `.srt` en ES + EN + JA + ZH + AR (i18n consistente con el proyecto). Plantilla:

```srt
1
00:00:05,000 --> 00:00:10,000
X-39MATRIX :: 10 Sovereign Axioms

2
00:00:10,000 --> 00:00:20,000
10 layers · 0 trust · 0 servers
```

— EOF —
