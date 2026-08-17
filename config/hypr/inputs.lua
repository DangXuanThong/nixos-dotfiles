hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
})

hl.on("hyprland.start", function()
    hl.exec_cmd("$HOME/.config/hypr/scripts/touchpad-auto.py")
end)
hl.device({
  name = "elan079c:00-04f3:3244-touchpad",
  natural_scroll = true,
  scroll_factor = 0.4
})
hl.device({
  name = "vxe-r1se+-mouse",
  sensitivity = -0.4,
  accel_profile = "flat"
})
hl.device({
  name = "compx-vxe-r1se+-1",
  sensitivity = -0.4,
  accel_profile = "flat"
})
