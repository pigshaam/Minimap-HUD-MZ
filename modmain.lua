local require = GLOBAL.require
require "mods"
local IsDST = GLOBAL.MOD_API_VERSION == 10

local function GetPlayer()
  local player
  if IsDST then
    player = GLOBAL.ThePlayer
  else
    player = GLOBAL.GetPlayer()
  end
  return player
end

local function GetWorld()
  local world
  if IsDST then
    world = GLOBAL.TheWorld
  else
    world = GLOBAL.GetWorld()
  end
  return world
end

----------------------------------------
-- Do the stuff
----------------------------------------

local function AddMiniMapMz_main( inst )

  -- for some reason, without this the game would crash without an error when calling controls.top_root:AddChild
  -- too lazy to track down the cause, so just using this workaround
  inst:DoTaskInTime( 0, function(inst) 

    -- add the minimap widget and set its position
    local MiniMapWidgetMz = require "widgets/minimapwidgetmz"
    local ModConfig = require "screens/modconfig"

    local controls = inst.HUD.controls

    local modconfig = ModConfig(IsDST)
    modconfig:Init()

    controls.minimapwidgetmz = controls.top_root:AddChild( MiniMapWidgetMz( IsDST, inst, GetPlayer, GetWorld, modconfig ) )
    modconfig.minimapwidgetmz = controls.minimapwidgetmz

    local screensize = {TheSim:GetScreenSize()}
    local OnUpdate_base = controls.OnUpdate
    controls.OnUpdate = function(self, dt)
      OnUpdate_base(self, dt)
      local curscreensize = {TheSim:GetScreenSize()}
      if curscreensize[1] ~= screensize[1] or curscreensize[2] ~= screensize[2] then
        controls.minimapwidgetmz:PositionMiniMap()
        controls.minimapwidgetmz:ResizeMapView()
        controls.minimapwidgetmz.mapcenter_gap = Point(0,0)
        controls.minimapwidgetmz:ResetOffset()
        screensize = curscreensize
      end
    end

    -- show and hide the minimap whenever the map gets toggled
    local ToggleMap_base = controls.ToggleMap
    controls.ToggleMap = function( self )
      local wasvisible = controls.minimapwidgetmz:IsVisible()

      if wasvisible then
        controls.minimapwidgetmz:Hide()
      end

      ToggleMap_base( self )

      if not wasvisible then
        controls.minimapwidgetmz:Show()
      end
    end

    -- HUD Size changes and re-position minimap
    local lasthudsize = nil
    local SetHUDSize_base = controls.SetHUDSize
    controls.SetHUDSize = function( self )
      SetHUDSize_base( self )
      scale = GLOBAL.TheFrontEnd:GetHUDScale()
      if lasthudsize ~= scale then
        controls.minimapwidgetmz:PositionMiniMap()
        local adjust_x, adjust_y = controls.minimapwidgetmz:ResizeMapView()
        controls.minimapwidgetmz:SetPosition(adjust_x, adjust_y)
        controls.minimapwidgetmz.mapcenter_gap = Point(0,0)
        controls.minimapwidgetmz:ResetOffset()
        lasthudsize = scale
      end
    end

    -- special case: ToggleMap gets bypassed when the map gets hidden while on the map screen
--    local MapScreen = require "screens/mapscreen"

--    MapScreen_OnControl_base = MapScreen.OnControl
--    MapScreen.OnControl = function( self, control, down )
--      local ret = MapScreen_OnControl_base(self, control, down)

--      if ret and control == GLOBAL.CONTROL_MAP then
--        controls.minimapwidgetmz:Show()
--      end

--      return ret
--    end

    -- keep track of zooming while on the map screen
    local MapWidget = require "widgets/mapwidget"

    MapWidget_OnZoomIn_base = MapWidget.OnZoomIn
    MapWidget.OnZoomIn = function(self)
      MapWidget_OnZoomIn_base( self )
      if self.shown then
        controls.minimapwidgetmz.mapscreenzoom = math.max(0,controls.minimapwidgetmz.mapscreenzoom-1)
      end
    end

    MapWidget_OnZoomOut_base = MapWidget.OnZoomOut
    MapWidget.OnZoomOut = function(self)
      MapWidget_OnZoomOut_base( self )
      if self.shown then
        controls.minimapwidgetmz.mapscreenzoom = controls.minimapwidgetmz.mapscreenzoom+1
      end
    end

    local key_handlers = {}

    function UpdateState()

      for k, v in pairs(key_handlers) do
        v:Remove()
      end

      local function IsModifierKeyDown(modifierkey)
        local isshiftdown = GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT)
        local isctrldown = GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_CTRL)
        local isaltdown = GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_ALT)
        local downstate = {[GLOBAL.KEY_SHIFT] = isshiftdown, [GLOBAL.KEY_CTRL] = isctrldown, [GLOBAL.KEY_ALT] = isaltdown}
        for k, v in pairs(modifierkey) do
          if downstate[v] ~= true then
            return false
          end
          downstate[v] = nil
        end
        for k, v in pairs(downstate) do
          if v == true then
            return false
          end
        end
        return true
      end

      if modconfig.tglkey ~= 0 then
        table.insert(key_handlers, GLOBAL.TheInput:AddKeyUpHandler(modconfig.tglkey, function()
          if #TheFrontEnd.screenstack >= 2 then
            return
          end
          if IsModifierKeyDown(modconfig.tglkey_modifier) then
            controls.minimapwidgetmz:ToggleOpen()
          end
        end))
      end

      if modconfig.centerresetkey ~= 0 then
        table.insert(key_handlers, GLOBAL.TheInput:AddKeyUpHandler(modconfig.centerresetkey, function()
          if #TheFrontEnd.screenstack >= 2 then
            return
          end
          if IsModifierKeyDown(modconfig.centerresetkey_modifier) then
            controls.minimapwidgetmz.mapcenter_gap = Point(0,0)
            controls.minimapwidgetmz:ResetOffset()
          end
        end))
      end

      if modconfig.configkey ~= 0 then
        table.insert(key_handlers, GLOBAL.TheInput:AddKeyUpHandler(modconfig.configkey, function()
          if #TheFrontEnd.screenstack >= 2 then
            return
          end
          if IsModifierKeyDown(modconfig.configkey_modifier) then
            if modconfig:Open() then
              TheFrontEnd:PushScreen(modconfig)
            end
          end
        end))
      end

    end

    modconfig.modmain_updatestate_callback = UpdateState

    UpdateState()

    local target_item = nil
    local is_temporary_close = nil
    local act_rummage_fn_base = GLOBAL.ACTIONS.RUMMAGE.fn
    GLOBAL.ACTIONS.RUMMAGE.fn = function(act)
      local ret = act_rummage_fn_base(act)
      local targ = act.target or act.invobject
      if act.doer.HUD and targ.components.container then
        if not targ.components.equippable and
           targ.components.container.type ~= "cooker" and
           targ.components.container.type ~= "pack"
        then
          target_item = targ.components.container
          if targ.components.container:IsOpen() then
            if controls.minimapwidgetmz:IsOpen() then
              if modconfig.close_when_open_chest then
                controls.minimapwidgetmz:SetOpen(false)
              end
              is_temporary_close = true
            end
          else
            if is_temporary_close then
              if modconfig.close_when_open_chest then
                controls.minimapwidgetmz:SetOpen(true)
              end
              is_temporary_close = nil
            end
            target_item = nil
          end
        end
      end

      return ret
    end

    local act_store_fn_base = GLOBAL.ACTIONS.STORE.fn
    GLOBAL.ACTIONS.STORE.fn = function(act)
      local ret = act_store_fn_base(act)
      local targ = act.target or act.invobject
      if act.doer.HUD and targ.components.container then
        if not targ.components.equippable and
           targ.components.container.type ~= "cooker" and
           targ.components.container.type ~= "pack"
        then
          target_item = targ.components.container
          if targ.components.container:IsOpen() then
            if controls.minimapwidgetmz:IsOpen() then
              if modconfig.close_when_open_chest then
                controls.minimapwidgetmz:SetOpen(false)
              end
              is_temporary_close = true
            end
          else
            if is_temporary_close then
              if modconfig.close_when_open_chest then
                controls.minimapwidgetmz:SetOpen(true)
              end
              is_temporary_close = nil
            end
            target_item = nil
          end
        end
      end

      return ret
    end

    GLOBAL.TheInput:AddGeneralControlHandler(function()
      if target_item then
        if target_item:IsOpen() then
          -- do nothing.
        else
          if is_temporary_close then
            if modconfig.close_when_open_chest then
              controls.minimapwidgetmz:SetOpen(true)
            end
            is_temporary_close = nil
          end
          target_item = nil
        end
      end
    end)

  end)

end

AddPlayerPostInit( AddMiniMapMz_main )

-- special case: ToggleMap gets bypassed when the map gets hidden while on the map screen
local function AddMiniMapMz_MapScreen( inst )
  local MapScreen = require "screens/mapscreen"
  local mapscreen_oncontrol_base = MapScreen.OnControl
  MapScreen.OnControl = function(self, control, down)
    ret = mapscreen_oncontrol_base(self, control, down)
    if ret and not down and (control == GLOBAL.CONTROL_MAP or control == GLOBAL.CONTROL_CANCEL) then
      local controls = GetPlayer().HUD.controls
      if controls.minimapwidgetmz then
        controls.minimapwidgetmz:Show()
      end
    end
    return ret
  end
end

AddClassPostConstruct("screens/mapscreen", AddMiniMapMz_MapScreen)
