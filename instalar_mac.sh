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
# ENCADEADO (21/10): o instalador do V9 Vision (Mac) roda este aqui mesmo, como o .bat do Windows (V9F_ENCADEADO + V9F_E_*):
# termo, login e senha vem de la' e nao pergunta de novo. Codigo de saida 3 = este Mac ainda nao foi liberado para o Flow.
ENCAD="${V9F_ENCADEADO:-}"

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
azul 2 "Acesso: este programa e' so' para membros"
uv venv --python 3.12 --seed "$TMP/venv" >/dev/null 2>&1 || parar "Nao consegui preparar a verificacao de acesso."
VPY="$TMP/venv/bin/python"
"$VPY" -m pip install -q --disable-pip-version-check cryptography >/dev/null 2>&1 || parar "Nao consegui preparar a verificacao de acesso. Confira a internet."
curl -fsSL "$DIST_URL/v9flow_cofre.py" -o "$TMP/v9flow_cofre.py" || parar "Nao consegui baixar o verificador de acesso. Confira a internet."
echo ""
echo "      TERMO DE USO (resumo)"
echo "      - O acesso e' pessoal: um login por pessoa, sem emprestar nem dividir."
echo "      - E' proibido copiar, repassar ou vender o programa ou o codigo."
echo "      - O administrador pode remover o acesso em caso de uso indevido."
echo ""
if [ -n "$ENCAD" ] && [ "${V9F_E_termo:-}" = "ACEITO" ]; then ACEITE="ACEITO"
else ACEITE="$(pergunta '      Para aceitar, digite ACEITO e aperte Enter: ')"; fi
[ "$(echo "$ACEITE" | tr '[:lower:]' '[:upper:]' | xargs)" = "ACEITO" ] || parar "O termo de uso nao foi aceito; instalacao cancelada."
CHAVE=""; LOGIN=""; SENHA_LIC=""; MODO="login"
# ---- ACESSO POR CODIGO (16/10): sem login nem senha. Mostra o codigo DESTE Mac (o mesmo do app), o suporte libera no
# painel e o servidor entrega a chave que abre o pacote. Login e senha continuam como alternativa (tecla L).
campo() { printf '%s' "$J" | "$VPY" -c 'import json,sys;print(json.load(sys.stdin).get(sys.argv[1]) or "")' "$1" 2>/dev/null; }
AVISOU=0; ESPERAS=0
# encadeado com login/senha do Vision: nao usa o codigo (igual ao .bat: so' tenta o codigo se nao encadeado ou modo=codigo)
SO_LOGIN="${V9_SO_LOGIN:-}"
if [ -n "$ENCAD" ] && [ "${V9F_E_modo:-}" != "codigo" ]; then SO_LOGIN=1; fi
while [ "$SO_LOGIN" != "1" ]; do
  J="$("$VPY" "$TMP/v9flow_cofre.py" codigo --app flow 2>/dev/null | tail -1)"
  ESTADO="$(campo estado)"; [ -n "$ESTADO" ] || ESTADO="funcao_antiga"
  CODIGO="$(campo codigo)"; LS="$(campo login_senha)"
  case "$ESTADO" in
    liberado) CHAVE="$(campo chave | tr -d '[:space:]')"; MODO="codigo"; LOGIN="Mac $CODIGO"; ok "este Mac esta liberado (codigo $CODIGO)."; break ;;
    negado) parar "Este Mac (codigo $CODIGO) nao tem acesso ao V9 Flow. Fale com o administrador." ;;
    sem_chave) parar "Este Mac (codigo $CODIGO) esta liberado, mas sem direito a instalar. Fale com o administrador." ;;
    sem_rede) echo "      Nao consegui falar com o servidor de licencas. Confira a internet."; break ;;
    aguardando) if [ -n "$ENCAD" ]; then
        echo "      O V9 Flow ainda nao foi liberado para este Mac (codigo $CODIGO). Quando for, e so' rodar o instalador de novo."
        rm -rf "$TMP"; exit 3
      fi ;;
    *) break ;;
  esac
  if [ "$AVISOU" = 0 ]; then
    AVISOU=1
    echo ""
    echo "      Codigo deste Mac:  $CODIGO"
    echo "      Mande este codigo para o suporte e espere. Confiro a cada 20 segundos se ja foi liberado."
    [ "$LS" = "True" ] && echo "      (Se voce tem login e senha, aperte a tecla L para entrar com eles.)"
  fi
  ESPERAS=$((ESPERAS+1))
  if [ -n "${V9_CODIGO_TENTATIVAS:-}" ] && [ "$ESPERAS" -gt "$V9_CODIGO_TENTATIVAS" ]; then parar "Modo de teste: o Mac nao foi liberado."; fi
  K=""; read -r -s -n 1 -t "${V9_CODIGO_INTERVALO:-20}" K < /dev/tty 2>/dev/null
  if [ "$LS" = "True" ] && { [ "$K" = "l" ] || [ "$K" = "L" ]; }; then break; fi
  echo "      ...ainda nao liberado, conferindo de novo."
done

if [ "$MODO" = "login" ]; then
  curl -fsSL "$DIST_URL/membros.json" -o "$TMP/membros.json" || parar "Nao consegui buscar a lista de membros. Avise o administrador se a internet estiver normal."
fi
for t in 1 2 3; do
  [ "$MODO" = "login" ] || break
  [ "$t" -gt 1 ] && echo "      Login ou senha incorretos. Tente de novo."
  if [ -n "$ENCAD" ] && [ "$t" = 1 ] && [ -n "${V9F_E_login:-}" ] && [ -n "${V9F_E_senha:-}" ]; then
    LOGIN="$V9F_E_login"; SENHA="$V9F_E_senha"            # vindos do Vision: so' a 1a vez (se errou, pergunta)
  else
    LOGIN="$(pergunta '      Login (o que o administrador cadastrou para voce): ')"
    SENHA="$(segredo '      Senha: ')"
  fi
  [ -n "$LOGIN" ] && [ -n "$SENHA" ] || continue
  CHAVE="$(printf '%s\n%s\n' "$LOGIN" "$SENHA" | "$VPY" "$TMP/v9flow_cofre.py" abrir --membros "$TMP/membros.json" 2>/dev/null | head -1 | tr -d '[:space:]')"
  if [ -n "$CHAVE" ]; then SENHA_LIC="$SENHA"; break; fi
done
SENHA=""; unset V9F_E_senha
[ -n "$CHAVE" ] || parar "Login ou senha incorretos 3 vezes. Fale com o administrador."
[ "$MODO" = "login" ] && ok "acesso liberado para $LOGIN."

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
# o Claude Code (agente de cenas e Estudio): no Windows vem com o V9 Vision; no Mac, aqui (instalador oficial, sem senha)
if [ -x "$HOME/.local/bin/claude" ] || command -v claude >/dev/null 2>&1; then
  ok "Claude Code ja instalado."
elif curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1 && [ -x "$HOME/.local/bin/claude" ]; then
  ok "Claude Code instalado (no app, clique em \"Entrar com o Claude\")."
else
  aviso "Nao consegui instalar o Claude Code: no app, o botao \"Entrar com o Claude\" tenta de novo."
fi
mkdir -p "$DADOS"
# a chave do membro fica guardada no Chaveiro do Mac: e' com ela que o programa se atualiza sozinho
if printf '%s\n' "$CHAVE" | ( cd "$DESTINO" && "$AppPy" -c 'import sys; from v9flow import plataforma; open(sys.argv[1], "wb").write(plataforma.proteger(sys.stdin.readline().strip().encode("ascii")))' "$DADOS/chave.dpapi" ); then
  ok "acesso guardado no Chaveiro do Mac (atualizacoes automaticas)."
else
  aviso "Nao consegui guardar o acesso: o programa funciona, mas para atualizar rode este comando de novo."
fi
CHAVE=""
if [ "$MODO" = "codigo" ]; then
  ok "licenca por codigo: o programa ativa sozinho ao abrir (este Mac ja esta liberado)."
else
RLIC="$( cd "$DESTINO" && printf '%s\n%s\n' "$LOGIN" "$SENHA_LIC" | "$AppPy" -m v9flow.licenca ativar 2>&1 )"
if [ $? -eq 0 ]; then
  ok "licenca ativada neste Mac."
else
  # mostra o motivo que o servidor deu (ex.: limite de computadores): antes o instalador escondia
  aviso "A licenca nao foi ativada agora ($(printf '%s' "$RLIC" | tail -1)). Ao abrir o V9 Flow, entre com login e senha na tela de entrada."
fi
fi
SENHA_LIC=""

# ---------- 5) app no Launchpad / Aplicativos ----------

# 18/10 (dono: "nenhum com o ícone"): no macOS novo o app do osacompile traz um Assets.car que manda no ícone; trocar só o
# applet.icns não aparece. Apaga o Assets.car, aponta o Info.plist para o applet.icns, reassina e avisa o Launchpad.
icone_no_app() {
  local a="$1"
  rm -f "$a/Contents/Resources/Assets.car"
  /usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$a/Contents/Info.plist" >/dev/null 2>&1 || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile applet" "$a/Contents/Info.plist" >/dev/null 2>&1 \
    || /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string applet" "$a/Contents/Info.plist" >/dev/null 2>&1 || true
  codesign --force --sign - "$a" >/dev/null 2>&1 && codesign --verify "$a" >/dev/null 2>&1 || aviso "O app $(basename "$a") pode nao abrir: a assinatura falhou. Rode este instalador de novo."
  touch "$a"
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$a" >/dev/null 2>&1 || true
}
azul 5 "Criando o app \"$NOME\""
# o app e' compilado pelo proprio Mac (osacompile): um .app feito a mao com script dentro deu
# "_LSOpenURLsWithCompletionHandler() failed with error -10669" no M4 (13/10)
mkdir -p "$HOME/Applications"
rm -rf "$APP"
osacompile -o "$APP" -e "do shell script \"cd '$DESTINO' && nohup '$DESTINO/venv/bin/python' abrir.pyw > '$DADOS/abrir.log' 2>&1 &\"" \
  || parar "Nao consegui criar o app no Mac (osacompile)."
if [ -f "$DESTINO/v9flow/ui/icone-mac.icns" ]; then   # 19/10: ícone colorido (fundo verde), pronto
  cp "$DESTINO/v9flow/ui/icone-mac.icns" "$APP/Contents/Resources/applet.icns"
  icone_no_app "$APP"
elif [ -f "$DESTINO/v9flow/ui/icone-512.png" ]; then
  ICONSET="$TMP/V9Flow.iconset"; mkdir -p "$ICONSET"
  for s in 16 32 128 256 512; do
    sips -z $s $s "$DESTINO/v9flow/ui/icone-512.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null 2>&1
  done
  iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/applet.icns" >/dev/null 2>&1 || true
  icone_no_app "$APP"
fi
touch "$APP"
ok "\"$NOME\" em Aplicativos do usuario (~/Applications) -- aparece no Launchpad e no Spotlight."

# ---------- 6) iniciar com o Mac ----------
azul 6 "Iniciar com o Mac"
PLIST="$HOME/Library/LaunchAgents/com.algoritmosecreto.v9flow.plist"
if [ -n "${V9F_E_iniciar:-}" ]; then R="$V9F_E_iniciar"
else R="$(pergunta '      Abrir o V9 Flow sozinho (em segundo plano) quando ligar o Mac? (S/N, Enter = N): ')"; fi
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

# ---------- opcional: motor Harness (DeepSeek) dos subagentes do ICARO ----------
# Desligado por padrao (Enter = N): sao ~453 MB e precisa do Node.js. Nunca vai no pacote do programa.
R="N"; [ -n "$ENCAD" ] || R="$(pergunta '      (Opcional) Instalar o motor Harness do ICARO? ~453 MB, precisa do Node.js. (S/N, Enter = N): ')"
if [ "$R" = "s" ] || [ "$R" = "S" ]; then
  if ! (cd "$DESTINO" && "$DESTINO/venv/bin/python" -m v9flow.dsh_motor instalar); then
    aviso "O motor Harness nao foi instalado (sem Node.js: brew install node, ou https://nodejs.org). Nao afeta o programa; da para instalar depois em Configuracoes."
  fi
fi

# ---------- 7) resumo ----------
azul 7 "Resumo"
printf 'Termo de uso aceito\nlogin: %s\ndata: %s\ncomputador: %s\nversao do app: %s\n' "$LOGIN" "$(date '+%Y-%m-%d %H:%M:%S')" "$(scutil --get ComputerName 2>/dev/null)" "$VERSAO" > "$DESTINO/termo_aceito.txt"
rm -rf "$TMP"
if [ ${#AVISOS[@]} -eq 0 ]; then ok "tudo certo, nenhuma pendencia."; else for a in "${AVISOS[@]}"; do echo "       - $a"; done; fi
echo ""
echo "  Para tirar o V9 Flow deste Mac: bash \"$DESTINO/desinstalar_mac.sh\""
echo "  Para usar: abra \"$NOME\" pelo Launchpad ou Spotlight (Cmd+Espaco, digite V9 Flow)."
echo "  Na primeira vez, clique em \"Instalar\" (o navegador proprio do V9 Flow, ~200 MB) e entre na sua conta Google."
echo "  O programa se atualiza sozinho cada vez que voce abre."
echo ""
if [ -z "$ENCAD" ]; then       # encadeado: quem decide abrir e' o instalador do Vision
  R="$(pergunta '  Abrir o programa agora? (S/N): ')"
  if [ "$R" = "s" ] || [ "$R" = "S" ]; then open "$APP"; fi
fi
