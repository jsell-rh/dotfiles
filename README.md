This repository contains a Hyprland desktop with the Ashell theme, Rofi,
SwayNC, Hyprlock, Hypridle, Hyprpaper, Wlogout, and desktop helper scripts.
Each component uses the GNU Stow directory layout.

The source files stay in this repository. Files in `~/.config`, `~/.local/bin`,
and `~/.local/share` link to them. Edit either path, then review and commit the
change here. Keep this checkout at a stable path.

**Install**

1. Install Python 3 and GNU Stow. On Fedora, use `sudo dnf install python3 stow`.
2. Install the programs in [packages/fedora.txt](packages/fedora.txt).
   See [packages/README.md](packages/README.md) for Ashell and version details.
3. Clone this repository to a stable directory, such as `~/code/dotfiles`.
4. Run `./install.sh` from the checkout to see the proposed file changes.
5. Run `./install.sh --apply` to install the files.
6. Set your monitor layout in `~/.config/hypr/local/monitor.conf`.
7. Run `Hyprland --verify-config --config ~/.config/hypr/hyprland.conf`.
8. Select Hyprland at the next login on a new computer.

The installer copies local examples only when the local files do not exist.
It preserves existing local settings. It backs up replaced files, then uses
atomic file replacement to create each link. It runs Stow with `--no-folding`
so that local files can stay outside the repository. It does not install
system packages, restart applications, or log you out.

The default selection installs all components. To install selected components:

```sh
./install.sh --components ashell rofi
./install.sh --components ashell rofi --apply
```

Hyprland uses `desktop-scripts`, `desktop-assets`, and `ml4w`. Install those
components with `hypr`. The full selection also supplies its startup programs'
configuration files. Stow does not install the programs themselves.

**Files and local settings**

| Directory | Contents |
| --- | --- |
| `hypr/` | Shared Hyprland, lock screen, idle, and wallpaper configuration |
| `ashell/` | Bar configuration and colors |
| `rofi/`, `swaync/`, `wlogout/` | Launcher, notifications, and power menu |
| `alacritty/` | Optional terminal configuration; Kitty is the default terminal |
| `ml4w/` | Required ML4W scripts and browser settings |
| `desktop-scripts/` | Selected desktop scripts |
| `desktop-assets/` | Required wallpapers and emoji data |
| `examples/` | Default files for a new machine |

These files remain local to each computer:

```text
~/.config/hypr/local/monitor.conf
~/.config/hypr/local/workspace.conf
~/.config/hypr/local/environment.conf
~/.config/hypr/local/binds.conf
~/.config/hypr/local/autostart.conf
~/.config/hypr/workspace-labels
~/.config/ml4w-hyprland-settings/hyprctl.json
```

The shared configuration loads each local file at a defined point. Monitor
and workspace rules come from the local files only. The examples use automatic
monitor placement, no forced GPU selection, and no personal startup commands.
Keep private settings out of the repository. Back them up separately.

The scripts have links under both `~/.local/bin` and `~/bin`. Required assets
also have links at their old ML4W and Sway paths. These links preserve the
existing commands and configuration paths during migration.

**Daily use**

1. Edit a shared file in the checkout or through its active link.
2. Check the configuration. Hyprland can reload changed files automatically.
3. Run `git diff` and review the changes.
4. Add the selected files and commit them.
5. Push when you are ready to share them.

After pulling new files or adding files to a component, run `./install.sh`,
then `./install.sh --apply`. Removing a file from Git does not remove its old
active link automatically. Remove that link after reviewing the change.

**Restore an installation**

The installer prints a backup directory under
`~/.local/state/dotfiles/installs/`. Use that exact directory:

```sh
./install.sh --restore /path/to/installation-backup
./install.sh --restore /path/to/installation-backup --apply
```

The first command shows the restore plan. The second restores replaced files
and removes links created by that installation. The restore stops if a target
file was changed after installation. Preserve that change before you continue.
Empty directories and the backup remain after a restore.

**Validation and current limits**

```sh
python3 -m unittest discover -s tests -v
Hyprland --verify-config --config ~/.config/hypr/hyprland.conf
gitleaks git . --redact
```

The migration preserves the existing Ashell configuration. That configuration
still names `ClaudeUsage`, but its custom module definition was already removed.
Ashell reports the missing module. The desktop scripts do not include a usage
monitor. Remove that name from `modules.right` if you do not use the module.

Personal weather, TOTP, speech-to-text, note, and backup commands are not part
of the shared installation. Existing personal shortcuts stay in the local
files. Those commands need their own programs and private settings. The old
workspace-label restore command also remains in the original user's local
startup file; its script was absent before this migration.

The source system used Fedora 43 and Hyprland 0.51.1. Configuration syntax can
change between releases. The configuration was checked with the installed
version. A full graphical login on a second computer has not been tested.

See [THIRD_PARTY.md](THIRD_PARTY.md) for source and asset notes.
