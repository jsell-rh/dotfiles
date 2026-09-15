Use Fedora's package manager for the programs in `fedora.txt`. Package
availability depends on the enabled repositories. The installer does not add
repositories or install packages. `alacritty` and `xdotool` are optional for
the terminal configuration and the X11 refresh shortcut. EasyEffects is an
optional personal startup program.

Ashell was installed outside RPM on the source computer. The local source
checkout reports version 0.5.0 at commit
`affda427db95ca71ed368789688963894bae73d3`. This does not prove the version of
the installed binary. Use the matching source and configuration schema when
you reproduce this desktop. See the [Ashell source](https://github.com/MalpenZibo/ashell)
and its [installation instructions](https://malpenzibo.github.io/ashell/docs/next/installation).
The current upstream configuration can differ from this configuration.

Versions read from the source system's RPM database:

| Program | Version |
| --- | --- |
| Hyprland | 0.51.1 |
| Hyprpaper | 0.7.6 |
| Hypridle | 0.1.7 |
| Hyprlock | 0.9.2 |
| SwayNC | 0.12.6 |
| Rofi | 2.0.0 |
| Wlogout | 1.2.2 |
| Kitty | 0.43.1 |
| Wmenu | 0.2.0 |

GNU Stow 2.4.1 was used for the migration and installer tests.

Some configuration files name Fira fonts. The source computer used Noto Sans
as a fallback and Font Awesome 4 for icons. The package list records those
fonts so that a new installation can use the same fallback. Font files are
not included in the repository.
