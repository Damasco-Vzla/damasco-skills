import json, os, re, subprocess, sys

errores = []

# 1. JSON: también rechazar claves duplicadas.
def unique_json(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("clave JSON duplicada")
        result[key] = value
    return result

for raiz, carpetas, ficheros in os.walk("."):
    carpetas[:] = [d for d in carpetas if d not in (".git", "dist", "__pycache__") and not d.startswith(".dist-")]
    for f in ficheros:
        if f.endswith(".json"):
            ruta = os.path.join(raiz, f)
            try:
                with open(ruta, encoding="utf-8") as archivo:
                    json.load(archivo, object_pairs_hook=unique_json)
            except Exception as e:
                errores.append(f"{ruta}: JSON inválido: {e}")

# 2. YAML real: no aceptar claves duplicadas ni estructuras inválidas.
try:
    import yaml
except ImportError:
    sys.exit("Falta PyYAML: python3 -m pip install -r requirements-dev.txt")

class UniqueLoader(yaml.SafeLoader):
    pass

def unique_mapping(loader, node, deep=False):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if not isinstance(key, str) or key in result:
            raise ValueError("clave YAML inválida o duplicada")
        result[key] = loader.construct_object(value_node, deep=deep)
    return result

UniqueLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)
PERMITIDOS = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
base = "dacuotas/skills"
versiones = []
for s in sorted(os.listdir(base)):
    carpeta = os.path.join(base, s)
    if not os.path.isdir(carpeta):
        continue
    ruta = os.path.join(carpeta, "SKILL.md")
    if not os.path.isfile(ruta):
        errores.append(f"{ruta}: falta SKILL.md")
        continue
    texto = open(ruta, encoding="utf-8").read()
    m = re.match(r"^---\n(.*?)\n---(?:\n|$)", texto, re.S)
    if not m:
        errores.append(f"{ruta}: sin frontmatter")
        continue
    try:
        campos = yaml.load(m.group(1), Loader=UniqueLoader)
        if not isinstance(campos, dict):
            raise ValueError("el frontmatter debe ser un mapa")
        sobran = set(campos) - PERMITIDOS
        if sobran:
            errores.append(f"{ruta}: campos no admitidos {sorted(sobran)}")
        nombre = campos.get("name")
        if nombre != s or not isinstance(nombre, str) or len(nombre) > 64 or not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", nombre):
            errores.append(f"{ruta}: name inválido o distinto de la carpeta")
        desc = campos.get("description")
        if not isinstance(desc, str) or not desc.strip() or len(desc) > 1024:
            errores.append(f"{ruta}: description debe tener entre 1 y 1024 caracteres")
        for clave in ("license", "compatibility", "allowed-tools"):
            if clave in campos and not isinstance(campos[clave], str):
                errores.append(f"{ruta}: {clave} debe ser texto")
        if len(campos.get("compatibility", "")) > 500:
            errores.append(f"{ruta}: compatibility supera 500 caracteres")
        metadata = campos.get("metadata", {})
        if not isinstance(metadata, dict) or any(not isinstance(v, str) for v in metadata.values()):
            errores.append(f"{ruta}: metadata debe ser un mapa de textos")
        else:
            versiones.append((ruta, metadata.get("version")))
    except (yaml.YAMLError, ValueError, TypeError) as exc:
        errores.append(f"{ruta}: YAML inválido ({type(exc).__name__})")

if not versiones:
    errores.append("No se encontraron skills con metadata válida")

# Los manifiestos usan dialectos distintos, pero identidad, versión y URL coinciden.
try:
    def leer(ruta):
        with open(ruta, encoding="utf-8") as f:
            return json.load(f)
    principal = leer("dacuotas/plugin.json")
    version = principal["version"]
    if not isinstance(version, str) or not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?", version):
        errores.append("dacuotas/plugin.json: versión inválida")
    for ruta in ("dacuotas/plugin.json", "dacuotas/.claude-plugin/plugin.json", "dacuotas/.cursor-plugin/plugin.json"):
        datos = leer(ruta)
        if datos.get("name") != "dacuotas" or datos.get("version") != version:
            errores.append(f"{ruta}: nombre o versión incoherentes")
    for ruta, skill_version in versiones:
        if skill_version != version:
            errores.append(f"{ruta}: metadata.version no coincide con el paquete")
    for ruta in (".agents/plugins/marketplace.json", ".claude-plugin/marketplace.json", ".cursor-plugin/marketplace.json"):
        datos = leer(ruta)
        if datos.get("name") != "damasco":
            errores.append(f"{ruta}: marketplace debe llamarse damasco")
        plugins = datos["plugins"]
        if len(plugins) != 1 or plugins[0].get("name") != "dacuotas":
            raise ValueError(f"{ruta}: debe declarar el plugin dacuotas")
        item = plugins[0]
        source = item.get("source")
        if source not in ("./dacuotas", {"source": "local", "path": "./dacuotas"}):
            errores.append(f"{ruta}: origen incoherente")
        for declarada in (item.get("version", version), datos.get("metadata", {}).get("version", version)):
            if declarada != version:
                errores.append(f"{ruta}: versión incoherente")
    urls = []
    for ruta, transporte in (("dacuotas/mcp.json", "streamable-http"), ("dacuotas/.mcp.json", "http")):
        servidor = leer(ruta)["mcpServers"]["dwh-dacuotas"]
        urls.append(servidor["url"])
        if servidor.get("type") != transporte or not servidor["url"].startswith("https://"):
            errores.append(f"{ruta}: transporte o URL inválidos")
    if len(set(urls)) != 1:
        errores.append("Los manifiestos MCP declaran URLs diferentes")
    from pathlib import Path
    for ruta in sorted(Path(base).glob("*/agents/openai.yaml")):
        try:
            with ruta.open(encoding="utf-8") as archivo:
                agente = yaml.load(archivo, Loader=UniqueLoader)
            herramientas = agente["dependencies"]["tools"]
            mcp = [t for t in herramientas if t.get("type") == "mcp" and t.get("value") == "dwh-dacuotas"]
            if len(mcp) != 1 or mcp[0].get("url") != urls[0] or mcp[0].get("transport") != "streamable_http":
                errores.append(f"{ruta}: dependencia MCP incoherente")
        except (yaml.YAMLError, ValueError, KeyError, TypeError, AttributeError):
            errores.append(f"{ruta}: YAML o dependencia MCP inválidos")
except (OSError, ValueError, KeyError, TypeError, AttributeError) as exc:
    errores.append(f"Manifiestos incoherentes ({type(exc).__name__})")

# 3. Contenido sensible, sobre los ficheros versionados o por versionar
PATRONES = [
    r"arn:aws",
    r"(?<![0-9])[0-9]{12}(?![0-9])",
    r"\bi-0[0-9a-f]{8,}\b",
    r"us-east-1_[A-Za-z0-9]+",
    r"(?i)cognito",
    r"(?i)@corporaciondamasco",
    r"damasco-prod-",
    r"\.secrets",
    r"AKIA[0-9A-Z]{16}",
    r"(?i)(password|secret|token)\s*[:=]\s*['\"][^'\"]{6,}",
    r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
]
extra = os.environ.get("PALABRAS_PROHIBIDAS", "")
PATRONES += [p.strip() for p in extra.splitlines() if p.strip()]

salida = subprocess.run(
    ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
    capture_output=True, text=True,
)
if salida.returncode:
    errores.append("No se pudo enumerar el repositorio Git; revisión sensible incompleta")
ficheros = sorted(set(filter(None, salida.stdout.split("\0"))))
compilados = []
for i, patron in enumerate(PATRONES):
    try:
        compilados.append((re.compile(patron), i))
    except re.error:
        errores.append("Expresión regular inválida en PALABRAS_PROHIBIDAS")
for ruta in ficheros:
    if os.path.islink(ruta):
        errores.append(f"{ruta}: enlaces simbólicos no admitidos")
        continue
    if ruta in ("scripts/validar.py",) or ruta.endswith((".zip", ".png")):
        continue
    try:
        lineas = open(ruta, encoding="utf-8").read().splitlines()
    except (UnicodeDecodeError, FileNotFoundError, IsADirectoryError):
        continue
    for n, linea in enumerate(lineas, 1):
        for p, indice in compilados:
            if p.search(linea):
                # El patrón privado no se imprime para no publicarlo en el log.
                cual = f"regla {indice + 1}" if indice < 11 else "(patrón privado)"
                errores.append(f"{ruta}:{n}: contenido sensible {cual}")

if errores:
    print("\n".join(errores))
    sys.exit(1)
print(f"comprobar: ok ({len(ficheros)} ficheros, {len(PATRONES)} patrones)")
