
----------------------------------------
-- Do the stuff
----------------------------------------

local require = GLOBAL.require

local function AddMiniMap( inst )

  -- for some reason, without this the game would crash without an error when calling controls.top_root:AddChild
  -- too lazy to track down the cause, so just using this workaround
  inst:DoTaskInTime( 0, function() 

    -- add the minimap widget and set its position
    local MiniMapWidgetMz = require "widgets/minimapwidgetmz"
    local ModConfig = require "screens/modconfig"

    local controls = inst.HUD.controls

    local modconfig = ModConfig()
    modconfig:Init()

    local minimapwidgetmz = controls.top_root:AddChild( MiniMapWidgetMz( inst, modconfig ) )
    modconfig.minimapwidgetmz = minimapwidgetmz

    local screensize = {TheSim:GetScreenSize()}
    local OnUpdate_base = controls.OnUpdate
    controls.OnUpdate = function(self, dt)
      OnUpdate_base(self, dt)
      local curscreensize = {TheSim:GetScreenSize()}
      if curscreensize[1] ~= screensize[1] or curscreensize[2] ~= screensize[2] then
        minimapwidgetmz:PositionMiniMap()
        minimapwidgetmz:ResizeMapView()
        minimapwidgetmz.lastoffset = Point(0, 0)
        minimapwidgetmz:ResetOffset()
        screensize = curscreensize
      end
    end

  -- show and hide the minimap whenever the map gets toggled
    local ToggleMap_base = controls.ToggleMap
    controls.ToggleMap = function( self )
      local wasvisible = minimapwidgetmz:IsVisible()

      if wasvisible then
        minimapwidgetmz:Hide()
      end

      ToggleMap_base( self )

      if not wasvisible then
        minimapwidgetmz:Show()
      end
    end

    -- HUD Size changes and re-position minimap
    local SetHUDSize_base = controls.SetHUDSize
    controls.SetHUDSize = function( self )
      SetHUDSize_base( self )
      minimapwidgetmz:PositionMiniMap()
      local adjust_x, adjust_y = minimapwidgetmz:ResizeMapView()
      minimapwidgetmz:SetPosition(adjust_x, adjust_y)
      minimapwidgetmz.mapcenter_gap = Point(0,0)
      minimapwidgetmz:ResetOffset()
    end

    -- special case: ToggleMap gets bypassed when the map gets hidden while on the map screen
    local MapScreen = require "screens/mapscreen"

    MapScreen_OnControl_base = MapScreen.OnControl
    MapScreen.OnControl = function( self, control, down )
      local ret = MapScreen_OnControl_base(self, control, down)

      if ret and control == GLOBAL.CONTROL_MAP then
        minimapwidgetmz:Show()
      end

      return ret
    end

    -- keep track of zooming while on the map screen
    local MapWidget = require "widgets/mapwidget"

    MapWidget_OnZoomIn_base = MapWidget.OnZoomIn
    MapWidget.OnZoomIn = function(self)
      MapWidget_OnZoomIn_base( self )
      if self.shown then
        minimapwidgetmz.mapscreenzoom = math.max(0,minimapwidgetmz.mapscreenzoom-1)
      end
    end

    MapWidget_OnZoomOut_base = MapWidget.OnZoomOut
    MapWidget.OnZoomOut = function(self)
      MapWidget_OnZoomOut_base( self )
      if self.shown then
        minimapwidgetmz.mapscreenzoom = minimapwidgetmz.mapscreenzoom+1
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
          if IsModifierKeyDown(modconfig.tglkey_modifier) then
            minimapwidgetmz:ToggleOpen()
          end
        end))
      end

      if modconfig.centerresetkey ~= 0 then
        table.insert(key_handlers, GLOBAL.TheInput:AddKeyUpHandler(modconfig.centerresetkey, function()
          if IsModifierKeyDown(modconfig.centerresetkey_modifier) then
            minimapwidgetmz.lastoffset = Point(0,0)
            minimapwidgetmz:ResetOffset()
          end
        end))
      end

      if modconfig.configkey ~= 0 then
        table.insert(key_handlers, GLOBAL.TheInput:AddKeyUpHandler(modconfig.configkey, function()
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
    local act_rummage_fn_base = GLOBAL.ACTIONS.RUMMAGE.fn
    local is_temporary_close = nil

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
            if minimapwidgetmz:IsOpen() then
              if modconfig.close_when_open_chest then
                minimapwidgetmz:SetOpen(false)
              end
              is_temporary_close = true
            end
          else
            if is_temporary_close then
              if modconfig.close_when_open_chest then
                minimapwidgetmz:SetOpen(true)
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
            if minimapwidgetmz:IsOpen() then
              if modconfig.close_when_open_chest then
                minimapwidgetmz:SetOpen(false)
              end
              is_temporary_close = true
            end
          else
            if is_temporary_close then
              if modconfig.close_when_open_chest then
                minimapwidgetmz:SetOpen(true)
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
              minimapwidgetmz:SetOpen(true)
            end
            is_temporary_close = nil
          end
          target_item = nil
        end
      end
    end)

  end)

end

AddSimPostInit( AddMiniMap )
