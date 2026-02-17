-- Stacked-tab WezTerm config.
--
-- Layout: new tabs spawn pre-split into a 70/30 vertical stack (top pane
-- active). A second keybinding produces a plain single-pane tab for when
-- you only want to spawn. The split size is declared once at the top so the
-- fraction-vs-Percent shape mismatch between pane:split and SplitPane
-- only exists in one place.
--
-- This file is the source of truth. The Home Manager-generated
-- ~/.config/wezterm/wezterm.lua should `require` it (see note at bottom)
-- or its body should be folded into the work profile's extraConfig.

local wezterm = require 'wezterm'
local act = wezterm.action

-- ---------------------------------------------------------------------------
-- Geometry: single source of truth for the bottom-pane size.
-- ---------------------------------------------------------------------------

-- pane:split takes a fraction in [0, 1]; SplitPane takes { Percent = n }.
-- Define the fraction once and derive the percent at each call site.
local BOTTOM_FRACTION = 0.30
local BOTTOM_PERCENT = math.floor(BOTTOM_FRACTION * 100 + 0.5)

-- ---------------------------------------------------------------------------
-- Tab spawning
-- ---------------------------------------------------------------------------

-- Inherit cwd from the current pane. spawn_tab does NOT inherit cwd the way
-- splits do, so pull it explicitly. Recent versions return a Url object;
-- .file_path unwraps it to a plain path.
local function current_cwd(pane)
  local cwd = pane:get_current_working_dir()
  if cwd and cwd.file_path then
    return cwd.file_path
  end
  return nil
end

-- Spawn a tab pre-split into a 70/30 vertical stack. Lands focus in the
-- TOP pane (the one you'd edit in), not the freshly-split bottom one.
local function spawn_stacked_tab(window, pane)
  local tab, first_pane = window:mux_window():spawn_tab {
    cwd = current_cwd(pane),
  }
  first_pane:split { direction = 'Bottom', size = BOTTOM_FRACTION }
  first_pane:activate()
end

-- ---------------------------------------------------------------------------
-- gui-startup: initial session layout
-- ---------------------------------------------------------------------------

-- Edit this list to reconstruct your standard set of project tabs on boot.
-- Each entry is { cwd = "...", split = true|false }.
local STARTUP_TABS = {
  { cwd = '~/work/service-a', split = true },
  -- { cwd = '~/work/service-b', split = true },
  -- { cwd = '~/notes',         split = false },  -- bare tab
}

wezterm.on('gui-startup', function()
  for i, spec in ipairs(STARTUP_TABS) do
    local tab, pane, window
    if i == 1 then
      tab, pane, window = wezterm.mux.spawn_window { cwd = spec.cwd }
    else
      tab, pane = wezterm.mux.spawn_tab { cwd = spec.cwd }
    end
    if spec.split then
      pane:split { direction = 'Bottom', size = BOTTOM_FRACTION }
      pane:activate()
    end
  end
end)

-- ---------------------------------------------------------------------------
-- GUI "+" button: stack, same as the leader-t binding
-- ---------------------------------------------------------------------------

wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
  if default_action and button == 'Left' then
    spawn_stacked_tab(window, pane)
    return false -- suppress the default plain tab
  end
end)

-- ---------------------------------------------------------------------------
-- Keybindings
-- ---------------------------------------------------------------------------

local config = {}

config.keys = {
  -- Stacked tab (the common case): leader-t
  { key = 't', mods = 'LEADER',
    action = wezterm.action_callback(spawn_stacked_tab) },

  -- Plain single-pane tab: leader-T (shifted).
  -- Inherits the pane's domain; cwd inheritance is left to the domain default.
  { key = 'T', mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain' },

  -- Retroactive split: turn a plain tab into the same 70/30 geometry.
  -- Uses { Percent = n } because SplitPane does not accept a fraction.
  { key = 's', mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Down',
      size = { Percent = BOTTOM_PERCENT },
    } },

  -- If you'd rather keep both tab styles under a key table instead of a
  -- case-sensitive pair, swap the two SpawnTab bindings above for:
  --
  --   { key = 't', mods = 'LEADER',
  --     action = act.ActivateKeyTable { name = 'tab', timeout_milliseconds = 1500 } },
  --
  -- and define:
  --
  --   config.key_tables = {
  --     tab = {
  --       { key = 't', action = wezterm.action_callback(spawn_stacked_tab) },
  --       { key = 'n', action = act.SpawnTab 'CurrentPaneDomain' },
  --       { key = 'Escape', action = 'PopKeyTable' },
  --     },
  --   },
}

-- ---------------------------------------------------------------------------
-- format-tab-title (preserved from the Home Manager profile)
-- ---------------------------------------------------------------------------

wezterm.on('format-tab-title', function(tab, tabs, panes, conf, hover, max_width)
  local title = tab.active_pane.title

  if tab.is_active then
    return title
  end

  -- Activity dot for background tabs. has_unseen_output is the real field;
  -- the previous is_activity does not exist and made wezterm log a stack
  -- traceback on every tab repaint (24 GB of logs before it was caught).
  if tab.active_pane.has_unseen_output then
    return {
      { Background = { Color = '#1a1a2e' } },
      { Foreground = { Color = '#ff6e40' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = ' \u{25cf} ' },
      'ResetAttributes',
      { Text = title .. ' ' },
    }
  end

  return title
end)

return config

-- ---------------------------------------------------------------------------
-- Integration with Home Manager
-- ---------------------------------------------------------------------------
--
-- ~/.config/wezterm/wezterm.lua is regenerated by Home Manager on every
-- `home-manager switch`, so editing it directly is futile. Two options:
--
-- 1. In the work profile's wezterm extraConfig, replace the `return {}`
--    with `return require 'extra-config'` and let HM copy this file into
--    ~/.config/wezterm/ alongside wezterm.lua. (lua takes a module path.)
--
-- 2. Or fold the body of this file (everything above `return config`)
--    into the work profile's `programs.wezterm.extraConfig` string so HM
--    emits it as wezterm.lua directly.
--
-- Option 1 keeps the Lua as a real file you can lint and version; option 2
-- keeps everything in nix but turns Lua into an escaped Nix string.