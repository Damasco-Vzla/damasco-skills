"""Regresiones locales: sin red, credenciales ni cambios en el HOME real."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]


class RepositoryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "repo"
        shutil.copytree(ROOT, self.root, ignore=shutil.ignore_patterns(".git", "dist", "__pycache__", ".dist-*"))
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        self.home = Path(self.temp.name) / "home"
        self.home.mkdir()
        self.bin = Path(self.temp.name) / "bin"
        self.bin.mkdir()
        # No clientes reales ni llamadas de red, incluso si existen en el runner.
        for name in ("claude", "codex", "cursor", "curl"):
            path = self.bin / name
            path.write_text("#!/bin/sh\nexit 1\n")
            path.chmod(0o755)
        self.env = dict(os.environ, HOME=str(self.home), PATH=f"{self.bin}:{os.environ['PATH']}")
        self.env.pop("PALABRAS_PROHIBIDAS", None)

    def run_script(self, name, *args, ok=True, env=None):
        result = subprocess.run(["bash", name, *args], cwd=self.root, env=env or self.env, capture_output=True, text=True)
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def skill(self):
        return self.root / "dacuotas/skills/como-vamos/SKILL.md"

    def change_description(self, value):
        path = self.skill()
        lines = path.read_text().splitlines()
        lines[2] = "description: " + value
        path.write_text("\n".join(lines) + "\n")

    def test_repository_validates(self):
        self.run_script("comprobar.sh")

    def test_duplicate_json_key_rejected(self):
        (self.root / "duplicate.json").write_text('{"name": "one", "name": "two"}')
        self.run_script("comprobar.sh", ok=False)

    def test_installer_rejects_source_symlink_before_writes(self):
        (self.skill().parent / "link.md").symlink_to(self.skill())
        self.run_script("instalar.sh", ok=False)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_installer_rejects_empty_skills_before_writes(self):
        for path in (self.root / "dacuotas/skills").iterdir():
            shutil.rmtree(path)
        self.run_script("instalar.sh", ok=False)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_duplicate_yaml_key_rejected(self):
        path = self.skill()
        path.write_text(path.read_text().replace("name: como-vamos", "name: como-vamos\nname: como-vamos"))
        self.run_script("comprobar.sh", ok=False)

    def test_quoted_yaml_name_accepted(self):
        path = self.skill()
        path.write_text(path.read_text().replace("name: como-vamos", 'name: "como-vamos"'))
        self.run_script("comprobar.sh")

    def test_yaml_description_length_inclusive(self):
        self.change_description("a" * 1024)
        self.run_script("comprobar.sh")
        self.change_description("a" * 1025)
        self.run_script("comprobar.sh", ok=False)

    def test_multiline_description_checked(self):
        self.change_description(">\n  " + "a" * 1025)
        self.run_script("comprobar.sh", ok=False)

    def test_non_string_description_rejected(self):
        self.change_description("[]")
        self.run_script("comprobar.sh", ok=False)

    def test_missing_skill_rejected(self):
        (self.root / "dacuotas/skills/vacia").mkdir()
        self.run_script("comprobar.sh", ok=False)

    def test_manifest_version_mismatch_rejected(self):
        path = self.root / "dacuotas/.claude-plugin/plugin.json"
        data = json.loads(path.read_text())
        data["version"] = "0.0.0"
        path.write_text(json.dumps(data))
        self.run_script("comprobar.sh", ok=False)

    def test_agent_mcp_dependency_mismatch_rejected(self):
        path = self.skill().parent / "agents/openai.yaml"
        path.write_text(path.read_text().replace("streamable_http", "sse"))
        self.run_script("comprobar.sh", ok=False)

    def test_mcp_endpoint_mismatch_rejected(self):
        path = self.root / "dacuotas/.mcp.json"
        data = json.loads(path.read_text())
        data["mcpServers"]["dwh-dacuotas"]["url"] = "https://invalid.example/mcp"
        path.write_text(json.dumps(data))
        self.run_script("comprobar.sh", ok=False)

    def test_sensitive_file_with_spaces_detected(self):
        (self.root / "archivo con espacios.txt").write_text("a" + "@" + "example.org")
        result = self.run_script("comprobar.sh", ok=False)
        self.assertIn("archivo con espacios.txt", result.stdout)

    def test_failed_git_scan_rejected(self):
        shutil.rmtree(self.root / ".git")
        self.run_script("comprobar.sh", ok=False)

    def test_invalid_private_regex_not_leaked(self):
        env = dict(self.env, PALABRAS_PROHIBIDAS="[patron-privado")
        result = self.run_script("comprobar.sh", ok=False, env=env)
        self.assertNotIn("[patron-privado", result.stdout + result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_symlink_rejected(self):
        (self.root / "enlace.md").symlink_to(self.skill())
        self.run_script("comprobar.sh", ok=False)

    def test_archives_are_reproducible_and_filtered(self):
        self.run_script("empaquetar.sh")
        before = {p.name: p.read_bytes() for p in (self.root / "dist").iterdir()}
        for path in (self.root / "dacuotas/skills").rglob("*"):
            os.utime(path, (1700000000, 1700000000))
        self.run_script("empaquetar.sh")
        after = {p.name: p.read_bytes() for p in (self.root / "dist").iterdir()}
        self.assertEqual(before, after)
        self.assertEqual(len(before), 6)
        for path in (self.root / "dist").glob("*.zip"):
            with zipfile.ZipFile(path) as archive:
                self.assertIn(path.stem + "/SKILL.md", archive.namelist())
                self.assertFalse(any("/agents/" in name for name in archive.namelist()))

    def test_dry_run_does_not_write_home(self):
        self.run_script("instalar.sh", "--solo-mostrar")
        self.assertEqual(list(self.home.iterdir()), [])

    def test_piped_dry_run_does_not_download(self):
        script = (self.root / "instalar.sh").read_text()
        result = subprocess.run(["bash", "-s", "--", "--solo-mostrar"], input=script, cwd=self.home, env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_install_keeps_previous_skill(self):
        target = self.home / ".agents/skills/como-vamos"
        target.mkdir(parents=True)
        (target / "local.txt").write_text("personalizado")
        self.run_script("instalar.sh")
        backups = list((target.parent / ".damasco-backups").glob("como-vamos.*/skill/local.txt"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "personalizado")
        self.assertTrue((target / "SKILL.md").is_file())

    def test_cursor_inserts_missing_server_preserving_others(self):
        target = self.home / ".cursor/mcp.json"
        target.parent.mkdir()
        original = {"mcpServers": {"otro": {"url": "https://example.org/mcp", "headers": {"X-Client": "custom"}}}}
        target.write_text(json.dumps(original))
        self.run_script("instalar.sh")
        updated = json.loads(target.read_text())
        self.assertEqual(updated["mcpServers"]["otro"], original["mcpServers"]["otro"])
        expected_url = json.loads((self.root / "dacuotas/mcp.json").read_text())["mcpServers"]["dwh-dacuotas"]["url"]
        self.assertEqual(updated["mcpServers"]["dwh-dacuotas"], {"url": expected_url})
        backup = list(target.parent.glob("mcp.json.bak.*"))
        self.assertEqual(len(backup), 1)
        self.assertEqual(json.loads(backup[0].read_text()), original)
        self.run_script("instalar.sh")
        self.assertEqual(len(list(target.parent.glob("mcp.json.bak.*"))), 1)

    def test_cursor_correct_url_is_idempotent_with_options(self):
        target = self.home / ".cursor/mcp.json"
        target.parent.mkdir()
        expected_url = json.loads((self.root / "dacuotas/mcp.json").read_text())["mcpServers"]["dwh-dacuotas"]["url"]
        original = json.dumps({"mcpServers": {"dwh-dacuotas": {"url": expected_url, "headers": {"X-Client": "custom"}}, "otro": {"url": "https://example.org/mcp"}}})
        target.write_text(original)
        for _ in range(2):
            self.run_script("instalar.sh")
            self.assertEqual(target.read_text(), original)
            self.assertEqual(list(target.parent.glob("mcp.json.bak.*")), [])

    def test_cursor_different_url_never_transfers_credentials(self):
        target = self.home / ".cursor/mcp.json"
        target.parent.mkdir()
        synthetic = "fixture-" + os.urandom(16).hex()
        for previous_url in ("https://old.example/mcp", None):
            with self.subTest(previous_url=previous_url):
                entry = {"headers": {"Authorization": "Bearer " + synthetic}, "auth": {"credential": synthetic}}
                if previous_url is not None:
                    entry["url"] = previous_url
                original = json.dumps({"mcpServers": {"dwh-dacuotas": entry, "otro": {"url": "https://example.org/mcp"}}})
                target.write_text(original)
                result = self.run_script("instalar.sh")
                self.assertIn("URL distinta o ausente", result.stdout)
                self.assertIn("Se conserva sin modificar", result.stdout)
                self.assertEqual(target.read_text(), original)
                self.assertEqual(list(target.parent.glob("mcp.json.bak.*")), [])
                self.assertNotIn(synthetic, result.stdout + result.stderr)
                self.assertNotIn("old.example", result.stdout + result.stderr)

    def test_cursor_preserves_incompatible_entry_unchanged(self):
        target = self.home / ".cursor/mcp.json"
        target.parent.mkdir()
        entries = (
            {"command": "node", "args": ["server.js"]},
            {"type": "stdio", "command": "node", "args": ["server.js"]},
            {"type": "sse", "url": "https://old.example/sse"},
        )
        for entry in entries:
            with self.subTest(entry=entry):
                original = json.dumps({"mcpServers": {"dwh-dacuotas": entry, "otro": {"url": "https://example.org/mcp"}}})
                target.write_text(original)
                result = self.run_script("instalar.sh")
                self.assertIn("incompatible con HTTP", result.stdout)
                self.assertIn("Se conserva sin modificar", result.stdout)
                self.assertEqual(target.read_text(), original)
                self.assertEqual(list(target.parent.glob("mcp.json.bak.*")), [])

    def test_invalid_cursor_json_unchanged(self):
        target = self.home / ".cursor/mcp.json"
        target.parent.mkdir()
        for text in ("not json", "[]", '{"mcpServers": []}'):
            target.write_text(text)
            self.run_script("instalar.sh", ok=False)
            self.assertEqual(target.read_text(), text)


if __name__ == "__main__":
    unittest.main()
