hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize"
})

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name  = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true
})

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 20,
    border_size = 3,
    col = {
      active_border = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = true,
  },
  decoration = {
    rounding = 10,
    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 0.8
    -- dim_inactive = true,
    -- dim_strength = 0.2,
  },
  animations = {
    enabled = true
  }
})

-- "Smart gaps" / "No gaps when only"
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({
  name = "no-gaps-wtv1",
  match = { float = false, workspace = "w[tv1]" },
  border_size = 0,
  rounding = 0
})
hl.window_rule({
  name = "no-gaps-f1",
  match = { float = false, workspace = "f[1]" },
  border_size = 0,
  rounding = 0
})

hl.window_rule({
  match = { class = "^Minecraft.*"},
  immediate = true,
  float = true,
})

hl.window_rule({
  match = { class = "org.vinegarhq.Sober"},
  immediate = true,
  float = true,
})

hl.window_rule({
  match = { class = "^steam_app_[0-9]+$"},
  immediate = true,
  float = true,
})
