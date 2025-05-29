local wezterm = require 'wezterm'

return {
  color_scheme = "nord",
  font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font",
    "FiraCode Nerd Font",
  }),
  font_size = 11.0,
  enable_tab_bar = false,
  window_background_opacity = 0.90,
  window_close_confirmation = "NeverPrompt",
  hide_mouse_cursor_when_typing = true,
  adjust_window_size_when_changing_font_size = false,
}
