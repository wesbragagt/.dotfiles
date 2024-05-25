-- IMPORTANT! brew upgrade --cask wezterm-nightly --no-quarantine --greedy-latest
-- https://wezfurlong.org/wezterm/config/lua/config/index.html
local wezterm = require 'wezterm'
local config = {}

config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

local fonts = {
  fira_code = "FiraCode Nerd Font",
  hack = "Hack Nerd Font",
  jetbrains_mono = "JetBrains Mono",
}

-- Enable/Disable ligatures
config.harfbuzz_features = { 'calt=0', 'clig=1', 'liga=1' }

-- https://wezfurlong.org/wezterm/config/lua/config/window_decorations.html
config.window_decorations = "RESIZE"

-- https://wezfurlong.org/wezterm/config/appearance.html#defining-a-color-scheme-in-your-weztermlua
config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 1
config.hide_tab_bar_if_only_one_tab = true

config.font = wezterm.font_with_fallback {
  fonts.jetbrains_mono,
  fonts.hack,
  fonts.fira_code,
}

config.font_size = 16.0
config.audible_bell = "Disabled"

return config
