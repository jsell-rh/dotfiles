-- Hyprland 0.57+ Lua config.
-- Hand-converted from hyprland.conf + conf/*.conf + local/*.conf (hyprlang),
-- which Hyprland 0.57 no longer reads. Hyprland <= 0.54 ignores this file;
-- 0.55/0.56 load it instead of hyprland.conf when both exist.
-- Docs: https://wiki.hypr.land/configuring/

local HOME = os.getenv("HOME")
local mainMod = "SUPER"

------------------
---- MONITORS ---- (was local/monitor.conf)
------------------

hl.monitor({ output = "eDP-1", mode = "1920x1200", position = "5280x80", scale = "1" })
hl.monitor({ output = "desc:Microstep MSI MAG323UPF", mode = "3840x2160", position = "1440x0", scale = "1" })
hl.monitor({ output = "desc:PanaScope PX329", mode = "2560x1440@60", position = "0x0", scale = "1", transform = 1 })

-- Samsung LS34A650U, native 3440x1440@59.97 (confirmed after a replug fixed a
-- stale/incomplete EDID read that had been capping it at 1920x1080@60).
-- Stacked directly above the laptop panel and centered over it, since it is
-- wider than eDP-1 (1920x1200 at 5280,80):
--   x = 5280 + 1920/2 - 3440/2 = 4520
--   y = 80 - 1440 = -1360
hl.monitor({ output = "desc:Samsung Electric Company LS34A650U", mode = "3440x1440@59.97", position = "4520x-1360", scale = "1" })

-------------------------------
---- ENVIRONMENT VARIABLES ---- (was conf/cursor.conf, conf/environments.conf, local/environment.conf)
-------------------------------

hl.env("XCURSOR_SIZE", "24")

-- XDG Desktop Portal
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("PATH", HOME .. "/.local/bin:" .. HOME .. "/bin:/usr/local/bin:/usr/bin:/var/lib/snapd/snap/bin")

-- QT
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- GTK
hl.env("GDK_SCALE", "1")

-- Mozilla
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- OZONE
hl.env("OZONE_PLATFORM", "wayland")

-- NVIDIA https://wiki.hyprland.org/Nvidia/
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("__GL_VRR_ALLOWED", "1")
hl.env("AQ_NO_MODIFIERS", "1")
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")

-------------------
---- AUTOSTART ---- (was conf/autostart.conf, local/autostart.conf)
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("swaync")
    hl.exec_cmd("ashell")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd(HOME .. "/bin/restore-workspace-labels.sh")
    hl.exec_cmd("easyeffects")
    -- Start the monitor for scheduled backups.
    hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user start app-org.gnome.DejaDup.Monitor@autostart.service")
end)
-- Dropped: `exec = ~/.config/ml4w-hyprland-settings/hyprctl.sh`. Its
-- hyprctl.json is empty ([]), so it was a no-op.

-----------------------
---- LOOK AND FEEL ---- (was conf/general.conf, conf/decoration.conf, conf/animations.conf)
-----------------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        layout = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled = false,
            size = 3,
            passes = 1,
        },
        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-----------------
---- LAYOUTS ---- (was conf/layouts.conf)
-----------------

-- dwindle:pseudotile was removed in 0.55 (it did nothing); pseudo dispatcher still works.
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

--------------
---- MISC ---- (was conf/misc.conf)
--------------

-- misc:vfr moved to debug:vfr in 0.55 and defaults to on; dropped.
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        -- hyprland-guiutils isn't installed; skip the 15s "missing guiutils" banner.
        disable_hyprland_guiutils_check = true,
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})

---------------
---- INPUT ---- (was conf/input.conf, conf/gestures.conf)
---------------

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------
---- KEYBINDINGS ---- (was conf/binds.conf, local/binds.conf)
---------------------

local function exec(cmd, rules) return hl.dsp.exec_cmd(cmd, rules) end

-- local/binds.conf
hl.bind(mainMod .. " + S", exec(HOME .. "/code/stt/stt-toggle.sh"))
hl.bind(mainMod .. " + ESCAPE", exec(HOME .. "/bin/totp.sh"))
hl.bind(mainMod .. " + C", exec("firefox --new-window https://calendar.google.com"))
hl.bind(mainMod .. " + W", exec(HOME .. "/bin/weather.sh", { float = true }))
hl.bind(mainMod .. " + W", exec(HOME .. "/bin/lightning.sh", { float = true }))
hl.bind(mainMod .. " + G", exec("firefox --new-window https://mail.google.com"))
hl.bind(mainMod .. " + O", exec(HOME .. "/bin/dailynote"))

-- Actions
hl.bind("SHIFT + Print", exec(HOME .. "/bin/record-screen.sh")) -- Record screen
hl.bind(mainMod .. " + PERIOD", exec(HOME .. "/bin/emoji-picker.sh"))
hl.bind(mainMod .. " + RETURN", exec("kitty")) -- Open terminal
hl.bind(mainMod .. " + Q", hl.dsp.window.close()) -- Close current window
hl.bind(mainMod .. " + M", hl.dsp.exit()) -- Exit Hyprland
hl.bind(mainMod .. " + L", exec("hyprlock"))
hl.bind(mainMod .. " + F1", exec("killall ashell || ashell"))
hl.bind(mainMod .. " + D", exec("wmenu-run")) -- Run wmenu app launcher
hl.bind(mainMod .. " + E", exec("nautilus")) -- Opens the filemanager
hl.bind(mainMod .. " + T", hl.dsp.window.float()) -- Toggle between tiling and floating window
hl.bind(mainMod .. " + CTRL + p", hl.dsp.window.pin()) -- Pin floating window
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen()) -- Open the window in fullscreen
hl.bind(mainMod .. " + CTRL + RETURN", exec("rofi -show drun")) -- Open rofi
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + B", exec(HOME .. "/.config/ml4w/settings/browser.sh")) -- Opens the browser
hl.bind(mainMod .. " + SHIFT + W", exec(HOME .. "/.config/ml4w/scripts/reload-hyprpaper.sh")) -- Reload hyprpaper
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86MonBrightnessUp", exec("brightnessctl set 10%+"))
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 10%-"))
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86WLAN", exec("nmcli radio wifi toggle"))
hl.bind("XF86Refresh", exec("xdotool key F5"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move Workspaces Between Monitors
hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + comma", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + period", hl.dsp.workspace.move({ monitor = "r" }))

-- Relative Workspace Switcher
hl.bind("CTRL + ALT + right", exec(HOME .. "/bin/workspace_cycler.sh next"))
hl.bind("CTRL + ALT + left", exec(HOME .. "/bin/workspace_cycler.sh prev"))

-- Switch workspaces with mainMod + [0-9]; move window with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/MMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:274", hl.dsp.window.resize(), { mouse = true })

-- Workspace rename / screenshot
hl.bind(mainMod .. " + SHIFT + N", exec(HOME .. "/bin/rename-workspace.sh"))
hl.bind("PRINT", exec(HOME .. "/bin/hyprshot -m region"))

--------------------
---- WORKSPACES ---- (was local/workspace.conf)
--------------------

-- hyprlang had `workspace = 1, name:slack, monitor:DP-11, default:true`;
-- `name:` isn't a workspace-rule key, the Lua equivalent is default_name.
hl.workspace_rule({ workspace = "1", default_name = "slack", monitor = "DP-11", default = true })
