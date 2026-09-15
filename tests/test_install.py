"""Check installation and recovery in a temporary home directory."""

import json
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]


class InstallationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.target = Path(self.temporary.name)

    def tearDown(self):
        self.temporary.cleanup()

    def run_install(self, *args, success=True):
        result = subprocess.run(
            [str(REPO / "install.sh"), "--target", str(self.target), *args],
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def backup(self):
        return next((self.target / ".local/state/dotfiles/installs").iterdir())

    def test_complete_install_is_repeatable_and_can_be_restored(self):
        old = self.target / ".config/ashell/config.toml"
        old.parent.mkdir(parents=True)
        old.write_text("original configuration\n")
        local = self.target / ".config/hypr/local/monitor.conf"
        local.parent.mkdir(parents=True)
        local.write_text("monitor = TEST, preferred, auto, 1\n")
        self.run_install()
        self.assertFalse(old.is_symlink())
        self.run_install("--apply")
        self.assertTrue(old.is_symlink())
        self.assertEqual(local.read_text(), "monitor = TEST, preferred, auto, 1\n")
        self.assertTrue((self.target / "bin/hyprshot").is_file())
        self.assertTrue((self.target / ".config/ml4w/wallpapers/mountain.jpg").is_file())
        self.assertTrue((self.target / ".config/ml4w-hyprland-settings/hyprctl.json").is_file())
        self.assertIn("All selected files are installed", self.run_install("--apply").stdout)
        backup = self.backup()
        self.run_install("--restore", str(backup), "--apply")
        self.assertEqual(old.read_text(), "original configuration\n")
        self.assertFalse(old.is_symlink())
        self.assertTrue(local.is_file())
        self.assertFalse((self.target / "bin/hyprshot").exists())

    def test_restore_preserves_a_file_changed_after_installation(self):
        self.run_install("--apply", "--components", "hypr")
        local = self.target / ".config/hypr/local/monitor.conf"
        local.write_text("my new monitor settings\n")
        self.run_install("--restore", str(self.backup()), "--apply", success=False)
        self.assertEqual(local.read_text(), "my new monitor settings\n")

    def test_directory_conflict_does_not_change_other_files(self):
        conflict = self.target / ".config/ashell/config.toml"
        conflict.mkdir(parents=True)
        self.run_install("--apply", success=False)
        self.assertTrue(conflict.is_dir())
        self.assertFalse((self.target / ".config/hypr/hyprland.conf").exists())


if __name__ == "__main__":
    unittest.main()
