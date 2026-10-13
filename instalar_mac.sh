#!/bin/bash
# =============================================================================
# Instalador do V9 Flow para Mac (13/10/2026). Cola no Terminal:
#
#   curl -fsSL https://raw.githubusercontent.com/Hardyrx/v9flow-dist/main/instalar_mac.sh | bash
#
# Nao pede senha de administrador nem conta de desenvolvedor da Apple: tudo fica na pasta do usuario, e o que e'
# baixado pelo Terminal nao recebe a "quarentena" do Mac (sem aviso de "desenvolvedor nao identificado").
# Rodar de novo = atualizar/consertar. Mesmo fluxo do instalador do Windows: login de membro -> chave -> pacote cifrado.
# =============================================================================
set -u
DIST_URL="${V9F_BASE_URL:-https://raw.githubusercontent.com/Hardyrx/v9flow-dist/main}"
DESTINO="${V9F_DESTINO:-$HOME/V9Flow}"
DADOS="$HOME/Library/Application Support/V9Flow"
APP="$HOME/Applications/V9 Flow.app"
NOME="V9 Flow"
TMP="$(mktemp -d -t v9flowinst)"
AVISOS=()

azul()  { printf '\n\033[36m[%s/7] %s\033[0m\n' "$1" "$2"; }
ok()    { printf '      \033[32mOK -- %s\033[0m\n' "$1"; }
aviso() { printf '      \033[33mAVISO: %s\033[0m\n' "$1"; AVISOS+=("$1"); }
parar() { printf '\n      \033[31mPAROU: %s\033[0m\n\n' "$1"; rm -rf "$TMP"; exit 1; }
# o script chega pelo "curl | bash": o teclado e' o /dev/tty, nao a entrada padrao
pergunta() { local r; read -r -p "$1" r < /dev/tty; printf '%s' "$r"; }
segredo()  { local r; read -r -s -p "$1" r < /dev/tty; echo > /dev/tty; printf '%s' "$r"; }

[ "$(uname)" = "Darwin" ] || parar "Este instalador e' para Mac. No Windows use o Instalar-V9Flow.bat."
echo ""
echo "  ===================  Instalador do V9 Flow (Mac)  ==================="

# ---------- 1) Python (uv: sem administrador, sem Homebrew) ----------
azul 1 "Python"
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  echo "      Instalando o gerenciador de Python (uv, so para este usuario)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || parar "Nao consegui instalar o Python. Confira a internet e rode de novo."
  export PATH="$HOME/.local/bin:$PATH"
fi
command -v uv >/dev/null 2>&1 || parar "Nao consegui preparar o Python."
uv python install 3.12 >/dev/null 2>&1 || parar "Nao consegui baixar o Python 3.12. Confira a internet e rode de novo."
ok "Python 3.12 pronto."

# ---------- 2) login de membro ----------
azul 2 "Login: este programa e' so' para membros"
uv venv --python 3.12 --seed "$TMP/venv" >/dev/null 2>&1 || parar "Nao consegui preparar a verificacao de acesso."
VPY="$TMP/venv/bin/python"
"$VPY" -m pip install -q --disable-pip-version-check cryptography >/dev/null 2>&1 || parar "Nao consegui preparar a verificacao de acesso. Confira a internet."
curl -fsSL "$DIST_URL/v9flow_cofre.py" -o "$TMP/v9flow_cofre.py" || parar "Nao consegui baixar o verificador de acesso. Confira a internet."
curl -fsSL "$DIST_URL/membros.json" -o "$TMP/membros.json" || parar "Nao consegui buscar a lista de membros. Avise o administrador se a internet estiver normal."
echo ""
echo "      TERMO DE USO (resumo)"
echo "      - O acesso e' pessoal: um login por pessoa, sem emprestar nem dividir."
echo "      - E' proibido copiar, repassar ou vender o programa ou o codigo."
echo "      - O administrador pode remover o acesso em caso de uso indevido."
echo ""
ACEITE="$(pergunta '      Para aceitar, digite ACEITO e aperte Enter: ')"
[ "$(echo "$ACEITE" | tr '[:lower:]' '[:upper:]' | xargs)" = "ACEITO" ] || parar "O termo de uso nao foi aceito; instalacao cancelada."
CHAVE=""; LOGIN=""; SENHA_LIC=""
for t in 1 2 3; do
  [ "$t" -gt 1 ] && echo "      Login ou senha incorretos. Tente de novo."
  LOGIN="$(pergunta '      Login (o que o administrador cadastrou para voce): ')"
  SENHA="$(segredo '      Senha: ')"
  [ -n "$LOGIN" ] && [ -n "$SENHA" ] || continue
  CHAVE="$(printf '%s\n%s\n' "$LOGIN" "$SENHA" | "$VPY" "$TMP/v9flow_cofre.py" abrir --membros "$TMP/membros.json" 2>/dev/null | head -1 | tr -d '[:space:]')"
  if [ -n "$CHAVE" ]; then SENHA_LIC="$SENHA"; break; fi
done
SENHA=""
[ -n "$CHAVE" ] || parar "Login ou senha incorretos 3 vezes. Fale com o administrador."
ok "acesso liberado para $LOGIN."

# ---------- 3) programa ----------
azul 3 "Baixando o programa para $DESTINO"
curl -fsSL "$DIST_URL/latest.json" -o "$TMP/latest.json" || parar "Nao consegui ver a versao atual. Confira a internet."
VERSAO="$("$VPY" -c 'import json,sys;print(json.load(open(sys.argv[1]))["versao"])' "$TMP/latest.json")"
ARQ="$("$VPY" -c 'import json,sys;print(json.load(open(sys.argv[1])).get("arquivo") or "app.v9pkg")' "$TMP/latest.json")"
SHA="$("$VPY" -c 'import json,sys;print(json.load(open(sys.argv[1]))["sha256"].lower())' "$TMP/latest.json")"
ATUAL=""; [ -f "$DESTINO/VERSAO" ] && ATUAL="$(tr -d '[:space:]' < "$DESTINO/VERSAO")"
if [ -f "$DESTINO/v9flow/__main__.py" ] && [ "$ATUAL" = "$VERSAO" ]; then
  ok "ja esta na versao mais recente ($VERSAO)."
else
  if [ -d "$DESTINO" ] && [ ! -f "$DESTINO/v9flow/__main__.py" ] && [ -n "$(ls -A "$DESTINO" 2>/dev/null)" ]; then
    parar "A pasta $DESTINO ja existe e nao e' deste programa. Renomeie essa pasta e rode de novo."
  fi
  curl -fsSL "$DIST_URL/$ARQ" -o "$TMP/$ARQ" || parar "Nao consegui baixar o programa. Confira a internet."
  [ "$(shasum -a 256 "$TMP/$ARQ" | cut -d' ' -f1)" = "$SHA" ] || parar "O arquivo baixado esta corrompido. Rode de novo."
  mkdir -p "$DESTINO"
  printf '%s\n' "$CHAVE" | "$VPY" "$TMP/v9flow_cofre.py" decifrar --pacote "$TMP/$ARQ" --destino "$DESTINO" >/dev/null
  case $? in 0) ;; 4) parar "O seu acesso foi removido ou a chave foi trocada. Fale com o administrador." ;; *) parar "Nao consegui abrir o pacote do programa." ;; esac
  printf '%s\n' "$VERSAO" > "$DESTINO/VERSAO"
  ok "programa instalado (versao $VERSAO)."
fi
printf '%s\n' "$DIST_URL" > "$DESTINO/dist_url.txt"
printf '%s\n' "$LOGIN" > "$DESTINO/instalado_para.txt"          # liga a atualizacao automatica

# ---------- 4) ambiente e bibliotecas ----------
azul 4 "Ambiente proprio do V9 Flow e bibliotecas"
[ -x "$DESTINO/venv/bin/python" ] || uv venv --python 3.12 --seed "$DESTINO/venv" >/dev/null 2>&1 || parar "Nao consegui criar o ambiente do programa."
AppPy="$DESTINO/venv/bin/python"
( cd "$DESTINO" && "$AppPy" abrir.pyw --preparar ) || parar "Nao consegui instalar as bibliotecas. Confira a internet e rode de novo."
ok "bibliotecas prontas."
mkdir -p "$DADOS"
# a chave do membro fica guardada no Chaveiro do Mac: e' com ela que o programa se atualiza sozinho
if printf '%s\n' "$CHAVE" | ( cd "$DESTINO" && "$AppPy" -c 'import sys; from v9flow import plataforma; open(sys.argv[1], "wb").write(plataforma.proteger(sys.stdin.readline().strip().encode("ascii")))' "$DADOS/chave.dpapi" ); then
  ok "acesso guardado no Chaveiro do Mac (atualizacoes automaticas)."
else
  aviso "Nao consegui guardar o acesso: o programa funciona, mas para atualizar rode este comando de novo."
fi
CHAVE=""
if ( cd "$DESTINO" && printf '%s\n%s\n' "$LOGIN" "$SENHA_LIC" | "$AppPy" -m v9flow.licenca ativar >/dev/null 2>&1 ); then
  ok "licenca ativada neste Mac."
else
  aviso "A licenca nao foi ativada agora: ao abrir o V9 Flow, entre com login e senha na tela de entrada."
fi
SENHA_LIC=""

# ---------- 5) app no Launchpad / Aplicativos ----------
azul 5 "Criando o app \"$NOME\""
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cat > "$APP/Contents/MacOS/V9Flow" <<EOF
#!/bin/bash
cd "$DESTINO" && exec "$DESTINO/venv/bin/python" abrir.pyw "\$@"
EOF
chmod +x "$APP/Contents/MacOS/V9Flow"
if [ -f "$DESTINO/v9flow/ui/icone-512.png" ]; then
  ICONSET="$TMP/V9Flow.iconset"; mkdir -p "$ICONSET"
  for s in 16 32 128 256 512; do
    sips -z $s $s "$DESTINO/v9flow/ui/icone-512.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null 2>&1
  done
  iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/V9Flow.icns" >/dev/null 2>&1 || true
fi
cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>$NOME</string>
  <key>CFBundleDisplayName</key><string>$NOME</string>
  <key>CFBundleIdentifier</key><string>com.algoritmosecreto.v9flow</string>
  <key>CFBundleExecutable</key><string>V9Flow</string>
  <key>CFBundleIconFile</key><string>V9Flow</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSAO</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
</dict></plist>
EOF
touch "$APP"
ok "\"$NOME\" em Aplicativos do usuario (~/Applications) -- aparece no Launchpad e no Spotlight."

# ---------- 6) iniciar com o Mac ----------
azul 6 "Iniciar com o Mac"
PLIST="$HOME/Library/LaunchAgents/com.algoritmosecreto.v9flow.plist"
R="$(pergunta '      Abrir o V9 Flow sozinho (em segundo plano) quando ligar o Mac? (S/N, Enter = N): ')"
if [ "$R" = "s" ] || [ "$R" = "S" ]; then
  mkdir -p "$HOME/Library/LaunchAgents"
  cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.algoritmosecreto.v9flow</string>
  <key>ProgramArguments</key><array><string>$DESTINO/venv/bin/python</string><string>$DESTINO/abrir.pyw</string><string>--sem-janela</string></array>
  <key>WorkingDirectory</key><string>$DESTINO</string>
  <key>RunAtLoad</key><true/>
</dict></plist>
EOF
  ok "inicio automatico ligado (sem janela; abre a tela pelo app)."
else
  rm -f "$PLIST"; ok "sem inicio automatico."
fi

# ---------- 7) resumo ----------
azul 7 "Resumo"
printf 'Termo de uso aceito\nlogin: %s\ndata: %s\ncomputador: %s\nversao do app: %s\n' "$LOGIN" "$(date '+%Y-%m-%d %H:%M:%S')" "$(scutil --get ComputerName 2>/dev/null)" "$VERSAO" > "$DESTINO/termo_aceito.txt"
rm -rf "$TMP"
if [ ${#AVISOS[@]} -eq 0 ]; then ok "tudo certo, nenhuma pendencia."; else for a in "${AVISOS[@]}"; do echo "       - $a"; done; fi
echo ""
echo "  Para usar: abra \"$NOME\" pelo Launchpad ou Spotlight (Cmd+Espaco, digite V9 Flow)."
echo "  Na primeira vez, clique em \"Instalar\" (o navegador proprio do V9 Flow, ~200 MB) e entre na sua conta Google."
echo "  O programa se atualiza sozinho cada vez que voce abre."
echo ""
R="$(pergunta '  Abrir o programa agora? (S/N): ')"
if [ "$R" = "s" ] || [ "$R" = "S" ]; then open "$APP"; fi
