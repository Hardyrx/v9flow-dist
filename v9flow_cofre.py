#!/usr/bin/env python3
"""
V9 FLOW // cofre do instalador e da publicacao.

Mesmo esquema do V9 Vision (app-videos/instalador/v9_cofre.py): a lista de membros (membros.json, formato 2 do
V9 Oracle) guarda, para cada login, a chave de dados trancada com a senha dele. Um login valido abre a chave de dados;
a chave de dados abre o pacote do app (formato V9E1: nonce + AES-256-GCM sobre gzip de um zip).

Diferenca para o V9 Vision: o pacote e' montado a partir da PASTA, com uma lista do que fica fora (venv, remotion,
ferramentas de teste, analises, dados locais, o proprio instalador).

SO' QUEM COMPROU (2026-10-12): o V9 Flow tem chave de dados PROPRIA e lista PROPRIA (a membros.json do v9flow-dist).
A lista do Flow e' montada a partir da lista do Oracle, so' com os compradores escolhidos pelo administrador: cada um
recebe a chave do Flow na chave PUBLICA dele (sem precisar da senha) e continua entrando com o mesmo login e senha.
A chave do Oracle/V9 Vision nao abre o pacote do Flow, e quem nao esta na lista do Flow nao instala.

Comandos:
  abrir     --membros ARQ                     stdin: login, senha (duas linhas)  -> stdout: chave (base64)
  decifrar  --pacote ARQ --destino PASTA      stdin: chave (base64)               -> extrai o app
  guardar   --destino ARQ                     stdin: chave (base64) -> grava protegida pelo Windows (DPAPI)
  compradores --oracle ARQ --flow ARQ [--escolha "1,3,5" | --escolha =] [--trocar-chave]
                                              stdin: login, senha do administrador. Sem --escolha: so' mostra a
                                              lista numerada ([x] = ja tem o Flow). Com --escolha: grava a lista do
                                              Flow (o administrador entra sempre; "=" mantem quem ja esta).
  publicar  --app PASTA --dist PASTA --membros ARQ [--versao V]
                                              stdin: login, senha do administrador. --membros = a lista do FLOW.
  listar    --app PASTA                       mostra o que entraria no pacote (nao precisa de login)
Codigos de saida: 0 ok, 2 login ou senha incorretos, 3 arquivo ausente ou invalido, 4 pacote nao abre,
                  6 versao igual a ja publicada.
"""
import argparse, base64, ctypes, fnmatch, gzip, hashlib, io, json, os, re, sys, time, zipfile

from cryptography.exceptions import InvalidTag
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey, X25519PublicKey
from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

try:
    sys.stdin.reconfigure(encoding="utf-8-sig", errors="strict")   # o PowerShell manda UTF-8, as vezes com BOM invisivel
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

MAGIC = b"V9E1"
ITER = 600_000
ARQUIVO_PACOTE = "app.v9pkg"

# ---------------------------------------------------------------- o que NAO vai para o membro
# Pastas (em qualquer nivel): lixo de Python/git/node.
FORA_PASTAS_TODAS = {"__pycache__", ".git", "node_modules", ".pytest_cache", ".cache",
                     ".atualizacao"}   # 17/10: trava/diario da atualizacao local (atualizando.info) nunca vai pro membro
# 15/10: "harness" (motor DeepSeek/dsh, ~453 MB) NUNCA vai no pacote: instala-se sob demanda na pasta de dados da pessoa.
# Pastas da raiz: ambiente local, ferramentas de teste, Remotion (so' as ferramentas usam), o proprio instalador.
FORA_PASTAS_RAIZ = {"venv", "remotion", "ferramentas", "testes", "instalador", "logs", "dist",
                    "docs", "icaro_ensinar", "harness", ".github"}   # 18/10: os botoes de publicar pela nuvem sao so' do dono   # 15/10: prints, sons de teste e o diario do ICARO sao so' do DEV
# 16/10: o ICARO do aluno NAO herda nada do mestre: v9flow/heranca/ nunca vai no pacote (caminho relativo a' raiz).
FORA_CAMINHOS = {"v9flow/heranca"}
# Arquivos (em qualquer nivel, por padrao de nome): dados locais e lixo.
FORA_ARQUIVOS = ["config.json", "*.pyc", "*.log", "*.tmp", "*.lock", "porta_ativa.txt", "fila.json", "Thumbs.db",
                 "desktop.ini"]
# Arquivos da raiz: coisa de quem desenvolve e marcas de uma instalacao.
FORA_ARQUIVOS_RAIZ = ["ANALISE-*.md", "INSTALAR.bat", "PUBLICAR-*.bat", "instalado_para.txt", "dist_url.txt",
                      "termo_aceito.txt"]
# Sem estes o pacote nao e' um V9 Flow que abre e se atualiza.
OBRIGATORIOS = ["VERSAO", "requirements.txt", "abrir.pyw", "atualizador.py", "v9flow/__main__.py", "extensao/manifest.json",
                "licenca_publica.json", "v9flow/licenca.py"]


def arquivos_do_pacote(app):
    """Lista (caminho no disco, nome no zip) do que vai no pacote, em ordem."""
    app = os.path.abspath(app)
    itens = []
    for raiz, pastas, arqs in os.walk(app):
        rel = os.path.relpath(raiz, app)
        na_raiz = rel == "."
        pastas[:] = sorted(p for p in pastas
                           if p not in FORA_PASTAS_TODAS and not (na_raiz and p in FORA_PASTAS_RAIZ)
                           and os.path.normpath(os.path.join(rel, p)).replace(os.sep, "/") not in FORA_CAMINHOS)
        for nome in sorted(arqs):
            if any(fnmatch.fnmatch(nome, pad) for pad in FORA_ARQUIVOS):
                continue
            if na_raiz and any(fnmatch.fnmatch(nome, pad) for pad in FORA_ARQUIVOS_RAIZ):
                continue
            caminho = os.path.join(raiz, nome)
            itens.append((caminho, os.path.relpath(caminho, app).replace(os.sep, "/")))
    return itens


def montar_zip(app):
    itens = arquivos_do_pacote(app)
    nomes = {n for _, n in itens}
    faltam = [o for o in OBRIGATORIOS if o not in nomes]
    if faltam:
        raise ValueError("faltam no app: " + ", ".join(faltam))
    buf = io.BytesIO()
    manifesto = {}
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
        for caminho, nome in itens:
            z.write(caminho, nome)
            with open(caminho, "rb") as f:
                manifesto[nome] = hashlib.sha256(f.read()).hexdigest()
        # 16/10 (fase 2): o atualizador confere cada arquivo no staging contra isto ANTES de trocar a versao
        z.writestr("MANIFESTO.json", json.dumps({"arquivos": manifesto}, ensure_ascii=False, sort_keys=True))
    return buf.getvalue(), len(itens)


# ---------------------------------------------------------------- membros (igual ao v9oracle/collector/cofre.py)
def id_login(login: str) -> str:
    return hashlib.sha256(login.strip().lower().encode("utf-8")).hexdigest()


def _deriva(senha: str, salt: bytes, iteracoes: int) -> bytes:
    return hashlib.pbkdf2_hmac("sha256", senha.encode("utf-8"), salt, iteracoes, 32)


def _chave_ecies(shared: bytes, eph_pub: bytes, pub: bytes) -> bytes:
    return HKDF(algorithm=hashes.SHA256(), length=32, salt=eph_pub + pub, info=b"v9-oracle-k").derive(shared)


def abre_membro(membros: dict, login: str, senha: str):
    """Devolve a chave de dados (base64) se login e senha estiverem certos, senao None."""
    ident = id_login(login)
    e = (membros.get("membros") or {}).get(ident)
    if not e or membros.get("v") != 2:
        return None
    try:
        wrap = base64.b64decode(e["priv"])
        priv = AESGCM(_deriva(senha, base64.b64decode(e["salt"]), int(membros.get("iter", ITER)))).decrypt(
            wrap[:12], wrap[12:], ident.encode())
        k = base64.b64decode(e["k"])
        eph_pub, nonce, ct = k[:32], k[32:44], k[44:]
        pub = base64.b64decode(e["pub"])
        shared = X25519PrivateKey.from_private_bytes(priv).exchange(X25519PublicKey.from_public_bytes(eph_pub))
        chave = AESGCM(_chave_ecies(shared, eph_pub, pub)).decrypt(nonce, ct, ident.encode())
        return base64.b64encode(chave).decode()
    except Exception:
        return None


# ---------------------------------------------------------------- lista do Flow (so' compradores)
# Mesmo formato do v9oracle/collector/cofre.py (_entrega_chave, _etiqueta, troca_chave), filtrando quem entra.
def _x_pub(priv: bytes) -> bytes:
    return X25519PrivateKey.from_private_bytes(priv).public_key().public_bytes(Encoding.Raw, PublicFormat.Raw)


def _entrega_chave(chave: bytes, pub: bytes, ident: str) -> bytes:
    eph = os.urandom(32)
    eph_pub = _x_pub(eph)
    shared = X25519PrivateKey.from_private_bytes(eph).exchange(X25519PublicKey.from_public_bytes(pub))
    nonce = os.urandom(12)
    return eph_pub + nonce + AESGCM(_chave_ecies(shared, eph_pub, pub)).encrypt(nonce, chave, ident.encode())


def _etiqueta(chave: bytes, nome: str, ident: str) -> bytes:
    nonce = os.urandom(12)
    return nonce + AESGCM(chave).encrypt(nonce, nome.strip().encode("utf-8"), b"label:" + ident.encode())


def _le_etiqueta(chave_b64: str, ident: str, e: dict):
    try:
        lab = base64.b64decode(e["label"])
        return AESGCM(base64.b64decode(chave_b64)).decrypt(lab[:12], lab[12:], b"label:" + ident.encode()).decode("utf-8")
    except Exception:
        return None


# PROIBIDOS NO V9 FLOW (15/10, dono: "o Joshua nunca deverá ter acesso ao Flow, é proibido"). Vale mesmo com "todos":
# nunca entram na lista do Flow, então não instalam nem abrem o pacote. Pelo nome (etiqueta) ou pelo id do login.
PROIBIDOS_NOMES = ("joshua",)
PROIBIDOS_IDS = {hashlib.sha256(n.encode()).hexdigest() for n in PROIBIDOS_NOMES}


def proibido(ident: str, nome: str) -> bool:
    n = (nome or "").casefold()
    return ident in PROIBIDOS_IDS or any(p in n for p in PROIBIDOS_NOMES)


def lista_compradores(oracle: dict, flow, chave_oracle_b64: str) -> list:
    """[(ident, nome, ja_tem_o_flow)] de todos os membros do Oracle, em ordem de nome."""
    no_flow = set(((flow or {}).get("membros") or {}).keys())
    itens = [(ident, _le_etiqueta(chave_oracle_b64, ident, e) or "(sem nome)", ident in no_flow)
             for ident, e in (oracle.get("membros") or {}).items()]
    return sorted(itens, key=lambda x: x[1].lower())


def monta_lista_flow(oracle: dict, escolhidos: dict, chave_flow_b64: str) -> dict:
    """escolhidos = {ident: nome}. Copia do Oracle o par de chaves de cada um (salt/pub/priv: o login e a senha continuam
    os mesmos) e entrega a chave do Flow na chave publica dele."""
    chave, b = base64.b64decode(chave_flow_b64), (lambda x: base64.b64encode(x).decode())
    out = {}
    for ident, nome in escolhidos.items():
        e = oracle["membros"][ident]
        out[ident] = {"salt": e["salt"], "pub": e["pub"], "priv": e["priv"],
                      "k": b(_entrega_chave(chave, base64.b64decode(e["pub"]), ident)), "label": b(_etiqueta(chave, nome, ident))}
    return {"v": 2, "kdf": oracle.get("kdf", "PBKDF2-SHA256"), "iter": oracle.get("iter", ITER), "membros": out}


# ---------------------------------------------------------------- pacote (formato V9E1)
def fecha(chave_b64: str, dados: bytes) -> bytes:
    nonce = os.urandom(12)
    return MAGIC + nonce + AESGCM(base64.b64decode(chave_b64)).encrypt(nonce, gzip.compress(dados, 6), None)


def abre(chave_b64: str, blob: bytes) -> bytes:
    if blob[:4] != MAGIC:
        raise ValueError("arquivo nao esta no formato do pacote")
    nonce, ct = blob[4:16], blob[16:]
    try:
        return gzip.decompress(AESGCM(base64.b64decode(chave_b64)).decrypt(nonce, ct, None))
    except InvalidTag:
        raise ValueError("a chave nao abre este pacote (acesso removido ou chave trocada)")


def extrai_zip(dados: bytes, destino: str) -> int:
    """Extrai o zip recusando qualquer caminho que escape da pasta de destino."""
    destino = os.path.abspath(destino)
    with zipfile.ZipFile(io.BytesIO(dados)) as z:
        for info in z.infolist():
            alvo = os.path.abspath(os.path.join(destino, info.filename))
            if alvo != destino and not alvo.startswith(destino + os.sep):
                raise ValueError("pacote com caminho suspeito: " + info.filename)
        z.extractall(destino)
        return len(z.infolist())


# ---------------------------------------------------------------- DPAPI (chave guardada no computador do membro)
class _Blob(ctypes.Structure):
    _fields_ = [("cbData", ctypes.c_uint32), ("pbData", ctypes.POINTER(ctypes.c_char))]


def proteger_dpapi(dados: bytes) -> bytes:
    """Protege com a conta do Windows do usuario: so' ele, neste computador, consegue abrir."""
    buf = ctypes.create_string_buffer(dados, len(dados))
    entrada, saida = _Blob(len(dados), ctypes.cast(buf, ctypes.POINTER(ctypes.c_char))), _Blob()
    if not ctypes.windll.crypt32.CryptProtectData(ctypes.byref(entrada), "V9Flow", None, None, None, 0, ctypes.byref(saida)):
        raise OSError("o Windows recusou a protecao (DPAPI)")
    try:
        return ctypes.string_at(saida.pbData, saida.cbData)
    finally:
        ctypes.windll.kernel32.LocalFree(ctypes.cast(saida.pbData, ctypes.c_void_p))


# ---------------------------------------------------------------- comandos
def _ler_membros(caminho):
    try:
        with open(caminho, encoding="utf-8") as f:
            m = json.load(f)
        if m.get("v") != 2:
            raise ValueError("formato de membros nao suportado")
        return m
    except (OSError, ValueError) as e:
        print(f"ERRO: nao consegui ler {caminho} ({e})", file=sys.stderr)
        return None


def _ler_credenciais():
    login = (sys.stdin.readline() or "").rstrip("\r\n")
    senha = (sys.stdin.readline() or "").rstrip("\r\n")
    return login, senha


def cmd_abrir(a):
    membros = _ler_membros(a.membros)
    if membros is None:
        return 3
    login, senha = _ler_credenciais()
    chave = abre_membro(membros, login, senha) if login and senha else None
    if not chave:
        return 2
    print(chave)
    return 0


def cmd_decifrar(a):
    chave = (sys.stdin.readline() or "").strip()
    try:
        with open(a.pacote, "rb") as f:
            blob = f.read()
    except OSError as e:
        print(f"ERRO: nao consegui ler o pacote ({e})", file=sys.stderr)
        return 3
    try:
        n = extrai_zip(abre(chave, blob), a.destino)
    except Exception as e:
        print(f"ERRO: {e}", file=sys.stderr)
        return 4
    print(f"{n} arquivo(s) extraido(s) em {a.destino}")
    return 0


def cmd_guardar(a):
    chave = (sys.stdin.readline() or "").strip()
    try:
        base64.b64decode(chave, validate=True)
        os.makedirs(os.path.dirname(os.path.abspath(a.destino)), exist_ok=True)
        with open(a.destino, "wb") as f:
            f.write(proteger_dpapi(chave.encode("ascii")))
    except (ValueError, OSError) as e:
        print(f"ERRO: nao consegui guardar a chave ({e})", file=sys.stderr)
        return 3
    print("chave guardada")
    return 0


def cmd_listar(a):
    itens = arquivos_do_pacote(a.app)
    for _, nome in itens:
        print(nome)
    print(f"-- {len(itens)} arquivo(s)", file=sys.stderr)
    return 0


def cmd_compradores(a):
    oracle = _ler_membros(a.oracle)
    if oracle is None:
        return 3
    flow = None
    if os.path.exists(a.flow):
        flow = _ler_membros(a.flow)
        if flow is None:
            return 3
    login, senha = _ler_credenciais()
    k_oracle = abre_membro(oracle, login, senha) if login and senha else None
    if not k_oracle:
        print("ERRO: login ou senha incorretos.", file=sys.stderr)
        return 2
    k_flow = None
    if flow:
        k_flow = abre_membro(flow, login, senha)
        if not k_flow:
            print("ERRO: este login nao esta na lista do V9 Flow. So' quem ja administra o V9 Flow muda a lista.",
                  file=sys.stderr)
            return 2
        if k_flow == k_oracle:      # lista antiga, copiada inteira do Oracle: a chave do Oracle nunca abre o Flow
            k_flow = None
    itens = lista_compradores(oracle, flow, k_oracle)
    eu = id_login(login)

    if a.escolha is None:
        for n, (ident, nome, ja) in enumerate(itens, 1):
            print(f"{n:>3}. [{'x' if ja else ' '}] {nome}{'  (voce)' if ident == eu else ''}"
                  f"{'  (PROIBIDO no Flow)' if ident != eu and proibido(ident, nome) else ''}")
        return 0

    if a.escolha.strip().lower() == "todos":        # todo membro do Oracle (o padrao continua: so' quem comprou)
        idents = {i for i, _, _ in itens}
    elif a.escolha.strip() == "=":
        if not flow:
            print("ERRO: ainda nao existe lista do V9 Flow. Digite os numeros de quem comprou.", file=sys.stderr)
            return 3
        idents = {i for i, _, ja in itens if ja}
    else:
        try:
            nums = [int(x) for x in re.split(r"[,;\s]+", a.escolha.strip()) if x]
        except ValueError:
            print("ERRO: digite so' os numeros, separados por virgula (ex.: 1,3,5).", file=sys.stderr)
            return 3
        fora = [n for n in nums if not 1 <= n <= len(itens)]
        if fora:
            print(f"ERRO: numero fora da lista: {', '.join(map(str, fora))}.", file=sys.stderr)
            return 3
        idents = {itens[n - 1][0] for n in nums}
    idents.add(eu)                  # o administrador fica sempre: e' o login dele que abre a chave para publicar
    nomes = {i: n for i, n, _ in itens}
    barrados = {i for i in idents if i != eu and proibido(i, nomes.get(i, ""))}
    if barrados:
        idents -= barrados
        print(f"PROIBIDO no V9 Flow (fica fora da lista): {', '.join(sorted(nomes.get(i, i) for i in barrados))}")
    ja_tinha = {i for i, n, ja in itens if ja and proibido(i, n)}
    if ja_tinha and not a.trocar_chave:
        print("ATENCAO: alguem PROIBIDO estava na lista antiga do Flow. Rode de novo trocando a chave para cortar a copia "
              "que ele ja instalou.")

    trocou = k_flow is not None and a.trocar_chave
    if k_flow is None or a.trocar_chave:
        k_flow = base64.b64encode(os.urandom(32)).decode()
    lista = monta_lista_flow(oracle, {i: nomes[i] for i in idents}, k_flow)
    os.makedirs(os.path.dirname(os.path.abspath(a.flow)), exist_ok=True)
    with open(a.flow, "w", encoding="utf-8") as f:
        json.dump(lista, f, indent=1)

    print(f"Lista do V9 Flow: {len(idents)} pessoa(s), voce incluido.")
    for nome in sorted((nomes[i] for i in idents), key=str.lower):
        print(f"  - {nome}")
    removidos = {i for i, _, ja in itens if ja} - idents
    if removidos and not trocou:
        print(f"AVISO: {len(removidos)} pessoa(s) sairam da lista. Elas nao instalam mais, mas quem ja tinha instalado "
              "guarda a chave atual e continua recebendo as versoes novas ate voce trocar a chave.")
    if trocou:
        print("Chave do V9 Flow trocada: quem ja tinha instalado precisa rodar o instalador de novo para receber as "
              "versoes novas.")
    return 0


def cmd_publicar(a):
    membros = _ler_membros(a.membros)
    if membros is None:
        return 3
    try:
        versao = a.versao or open(os.path.join(a.app, "VERSAO"), encoding="utf-8").read().strip()
    except OSError:
        versao = ""
    if not versao:
        print("ERRO: o arquivo VERSAO do app esta vazio ou nao existe.", file=sys.stderr)
        return 3
    try:
        with open(os.path.join(a.dist, "latest.json"), encoding="utf-8") as f:
            publicada = (json.load(f) or {}).get("versao", "")
    except (OSError, ValueError):
        publicada = ""
    if publicada == versao:
        print(f"ERRO: a versao {versao} ja esta publicada. Aumente o numero no arquivo VERSAO (ex.: 0.2) e rode de novo:\n"
              "      sem versao nova, quem ja instalou nao recebe a atualizacao.", file=sys.stderr)
        return 6
    login, senha = _ler_credenciais()
    chave = abre_membro(membros, login, senha) if login and senha else None
    if not chave:
        print("ERRO: login ou senha incorretos.", file=sys.stderr)
        return 2
    try:
        zip_bytes, n = montar_zip(a.app)
    except (ValueError, OSError) as e:
        print(f"ERRO: nao consegui montar o pacote ({e})", file=sys.stderr)
        return 3
    # METODO NA NUVEM (2026-10-13): os prompts do agente e do estudio e as referencias CENA/GENIU$ vao para o Supabase
    # (instalador/conteudo_nuvem.py) e saem do pacote dos membros. Se a nuvem falhar, nada e' publicado.
    if getattr(a, "metodo_nuvem", False):
        try:
            sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
            import conteudo_nuvem as CN
            pacote = CN.montar(a.app)
            zip_bytes, k = CN.tirar_do_zip(zip_bytes, pacote)
            ok, msg = CN.publicar(pacote)
        except (Exception, SystemExit) as e:
            print(f"ERRO: nao consegui tirar o metodo do pacote ({e}). Nada foi publicado.", file=sys.stderr)
            return 7
        if not ok:
            print(msg + " Nada foi publicado.", file=sys.stderr)
            return 7
        print(msg)
        print(f"Metodo fora do pacote: {k} prompt(s) e arquivo(s) so' na nuvem.")
    blob = fecha(chave, zip_bytes)
    os.makedirs(a.dist, exist_ok=True)
    with open(os.path.join(a.dist, ARQUIVO_PACOTE), "wb") as f:
        f.write(blob)
    latest = {"versao": versao, "arquivo": ARQUIVO_PACOTE, "sha256": hashlib.sha256(blob).hexdigest(),
              "tamanho": len(blob), "publicado_em": time.strftime("%Y-%m-%d %H:%M:%S"),
              "chave_id": hashlib.sha256(base64.b64decode(chave)).hexdigest()[:12]}
    with open(os.path.join(a.dist, "latest.json"), "w", encoding="utf-8") as f:
        json.dump(latest, f, indent=1)
    destino = os.path.join(a.dist, "membros.json")
    if os.path.abspath(a.membros) != os.path.abspath(destino):   # a lista do Flow ja mora no dist: nao copia sobre si
        with open(a.membros, "rb") as o:
            dados = o.read()
        with open(destino, "wb") as d:
            d.write(dados)
    print(f"Pacote {versao}: {n} arquivo(s), {len(blob) / 1024:.0f} KB cifrado -> {a.dist}")
    return 0


# ---------------------------------------------------------------- instalar do zero POR CODIGO (16/10, sem login/senha)
# Mesmo algoritmo do app (licenca.maquina_id / licenca.codigo): o instalador mostra o codigo desta maquina, pergunta ao
# servidor de licencas (acao "codigo") e, quando o dono liberou o PC no painel, recebe dele a chave que abre o pacote.
URL_LICENCA = "https://hrvrhaxllsbgiwkliuoc.supabase.co/functions/v1/licenca"


def _guid_maquina():
    import subprocess
    try:
        if sys.platform == "win32":
            import winreg
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Cryptography", 0,
                                winreg.KEY_READ | winreg.KEY_WOW64_64KEY) as k:
                return winreg.QueryValueEx(k, "MachineGuid")[0]
        if sys.platform == "darwin":
            for cmd in (["/usr/sbin/ioreg", "-rd1", "-c", "IOPlatformExpertDevice"], ["ioreg", "-rd1", "-c", "IOPlatformExpertDevice"]):
                try:
                    r = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
                except (OSError, subprocess.SubprocessError):
                    continue
                m = re.search(r'"IOPlatformUUID"\s*=\s*"([^"]+)"', r.stdout or "")
                if m:
                    return m.group(1)
            r = subprocess.run(["/usr/sbin/sysctl", "-n", "kern.uuid"], capture_output=True, text=True, timeout=10)
            return r.stdout.strip()
    except Exception:
        pass
    return ""


def maquina_id() -> str:
    if os.environ.get("V9_MAQUINA"):
        return hashlib.sha256(os.environ["V9_MAQUINA"].encode()).hexdigest()
    guid = _guid_maquina()
    if not guid:
        import uuid
        guid = str(uuid.getnode())
    return hashlib.sha256(("v9|" + guid).encode()).hexdigest()


def codigo_maquina() -> str:
    h = maquina_id().upper()
    return "-".join(h[i:i + 4] for i in range(0, 12, 4))


def consulta_codigo(app: str, url: str, timeout: int = 20) -> dict:
    """-> {"estado", "codigo", "login_senha", "chave"?}. estado: liberado | aguardando | negado | sem_chave | sem_rede | funcao_antiga"""
    import socket
    import urllib.error
    import urllib.request
    base = {"codigo": codigo_maquina(), "login_senha": True}
    corpo = json.dumps({"acao": "codigo", "maquina": maquina_id(), "app": app, "nome_pc": socket.gethostname()}).encode()
    req = urllib.request.Request(url, data=corpo, headers={"content-type": "application/json"}, method="POST")
    erro_http = None
    try:
        try:
            with urllib.request.urlopen(req, timeout=timeout) as r:
                texto = r.read().decode("utf-8", "replace")
        except urllib.error.HTTPError as e:                  # o servidor responde 403 com JSON para "aguardando" etc.
            erro_http = e.code
            texto = e.read().decode("utf-8", "replace")
    except (urllib.error.URLError, OSError, ValueError):
        return {**base, "estado": "sem_rede"}
    try:
        j = json.loads(texto)
    except ValueError:
        # 16/10: erro HTTP sem JSON (proxy/antivirus/servidor fora) e' rede, nao a funcao antiga
        return {**base, "estado": "sem_rede" if erro_http else "funcao_antiga"}
    if not isinstance(j, dict):
        return {**base, "estado": "funcao_antiga"}
    base["login_senha"] = j.get("login_senha", True) is not False
    if j.get("ok") and j.get("licenca"):
        chave = j.get("chave_dados")
        if not chave:                                      # liberado, mas sem direito as versoes/pacote (Atualizacao desligada)
            return {**base, "estado": "sem_chave"}
        return {**base, "estado": "liberado", "chave": chave}
    m = j.get("motivo") or ""
    if m == "aguardando_liberacao":
        return {**base, "estado": "aguardando"}
    if m in ("dispositivo_bloqueado", "proibido", "vencida", "bloqueado"):
        return {**base, "estado": "negado", "motivo": m}
    return {**base, "estado": "funcao_antiga"}             # "pedido_invalido" = a funcao antiga: segue o login/senha


def cmd_codigo(a):
    r = consulta_codigo(a.app, a.url or os.environ.get("V9_LICENCA_URL") or URL_LICENCA)
    print(json.dumps(r))
    return 0


def main():
    ap = argparse.ArgumentParser(description="Cofre do instalador V9 Flow")
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("abrir"); p.add_argument("--membros", required=True); p.set_defaults(f=cmd_abrir)
    p = sub.add_parser("decifrar"); p.add_argument("--pacote", required=True); p.add_argument("--destino", required=True)
    p.set_defaults(f=cmd_decifrar)
    p = sub.add_parser("codigo"); p.add_argument("--app", default="flow"); p.add_argument("--url"); p.set_defaults(f=cmd_codigo)
    p = sub.add_parser("guardar"); p.add_argument("--destino", required=True); p.set_defaults(f=cmd_guardar)
    p = sub.add_parser("listar"); p.add_argument("--app", required=True); p.set_defaults(f=cmd_listar)
    p = sub.add_parser("compradores"); p.add_argument("--oracle", required=True); p.add_argument("--flow", required=True)
    p.add_argument("--escolha"); p.add_argument("--trocar-chave", action="store_true", dest="trocar_chave")
    p.set_defaults(f=cmd_compradores)
    p = sub.add_parser("publicar"); p.add_argument("--app", required=True); p.add_argument("--dist", required=True)
    p.add_argument("--membros", required=True); p.add_argument("--versao")
    p.add_argument("--metodo-nuvem", action="store_true", dest="metodo_nuvem")
    p.set_defaults(f=cmd_publicar)
    a = ap.parse_args()
    return a.f(a)


if __name__ == "__main__":
    sys.exit(main())
