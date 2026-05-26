require("monitors")
require("inputs")
require("binds")
require("rules")
require("permissions")

hl.config({
  misc = {
    force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
  },
})

hl.config({
  xwayland = {
    enabled = true,
    force_zero_scaling = true
  }
})