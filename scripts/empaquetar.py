"""Paquetes deterministas: orden, fechas, permisos y contenido controlados."""
import hashlib
from pathlib import Path
import shutil
import tempfile
import zipfile

root = Path(__file__).resolve().parent.parent
stage = Path(tempfile.mkdtemp(prefix=".dist-", dir=root))
try:
    skills = sorted((root / "dacuotas/skills").iterdir())
    hashes = []
    for skill in skills:
        if not skill.is_dir():
            continue
        target = stage / (skill.name + ".zip")
        with zipfile.ZipFile(target, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for path in sorted(skill.rglob("*")):
                relative = path.relative_to(skill)
                if "agents" in relative.parts or any(part.startswith(".") or part == "__pycache__" for part in relative.parts):
                    continue
                if path.is_symlink():
                    raise ValueError(f"No se admiten enlaces: {path}")
                if not path.is_file():
                    continue
                info = zipfile.ZipInfo(f"{skill.name}/{relative.as_posix()}", date_time=(1980, 1, 1, 0, 0, 0))
                info.create_system = 3
                info.external_attr = 0o100644 << 16
                info.compress_type = zipfile.ZIP_DEFLATED
                archive.writestr(info, path.read_bytes(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
        hashes.append(f"{hashlib.sha256(target.read_bytes()).hexdigest()}  {target.name}\n")
    (stage / "SHA256SUMS").write_text("".join(hashes), encoding="utf-8")
    destination = root / "dist"
    if destination.is_symlink():
        raise ValueError("dist no puede ser un enlace simbólico")
    if destination.exists():
        shutil.rmtree(destination)
    stage.rename(destination)
    for path in sorted(destination.iterdir()):
        print(path.relative_to(root))
finally:
    if stage.exists():
        shutil.rmtree(stage)
