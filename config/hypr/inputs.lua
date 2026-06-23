hl.config({
  input = {
    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.3
    }
  }
})
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
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
