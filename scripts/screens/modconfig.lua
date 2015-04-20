require "util"
require "strings"
require "constants"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"

local PopupDialogScreen = require "screens/popupdialog"

local text_font = UIFONT

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local spinnerFont = { font = BUTTONFONT, size = 30 }

local COLS = 2
local ROWS_PER_COL = 7

local options = {}

local ModConfig = Class(Screen, function(self, IsDST)
  Screen._ctor(self, "ModConfig")

  self.IsDST = IsDST
  self.minimapwidgetmz = nil
  self.modmain_updatestate_callback = nil
  self.quicksaving = false
  if self.IsDST then
    self.CONTROL_PAGELEFT = CONTROL_SCROLLBACK
    self.CONTROL_PAGERIGHT = CONTROL_FOCUS_RIGHT
  else
    self.CONTROL_PAGELEFT = CONTROL_PAGELEFT
    self.CONTROL_PAGERIGHT = CONTROL_PAGERIGHT
  end
end)

function ModConfig:UpdateOptions()
  options = {}

  if self.configfull and type(self.configfull) == "table" then
    for i,v in ipairs(self.configfull) do
      -- Only show the option if it matches our format exactly
      if v.name and v.options and (v.saved ~= nil or v.default ~= nil) then 
        table.insert(options, {name = v.name, label = v.label, options = v.options, default = v.default, value = v.saved})
      end
    end
  end
end

function ModConfig:Open()
  if self.open then return false end

  if #TheFrontEnd.screenstack >= 2 then
    return false
  end

  Screen._ctor(self, "ModConfig")
  SetPause(true, "inv")
  self.open = true

  self.left_spinners = {}
  self.right_spinners = {}

  self:UpdateOptions()

  self.started_default = self:IsDefaultSettings()

  if nil then
  if self.bg then
    self.bg:Kill()
  end
  self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))

  if IsDLCEnabled(REIGN_OF_GIANTS) then
    self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 0.75)
  else
    self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 0.75)
  end

  self.bg:SetVRegPoint(ANCHOR_MIDDLE)
  self.bg:SetHRegPoint(ANCHOR_MIDDLE)
  self.bg:SetVAnchor(ANCHOR_MIDDLE)
  self.bg:SetHAnchor(ANCHOR_MIDDLE)
  self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
  end

  if self.root then
    self.root:Kill()
  end
  self.root = self:AddChild(Widget("ROOT"))
  self.root:SetVAnchor(ANCHOR_MIDDLE)
  self.root:SetHAnchor(ANCHOR_MIDDLE)
  self.root:SetPosition(0,0,0)
  self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

  if self.shield then
    self.shield:Kill()
  end
  self.shield = self.root:AddChild( Image( "images/globalpanels.xml", "panel.tex" ) )
  self.shield:SetPosition( 0,0,0 )
  self.shield:SetSize( 1000, 700 )
  self.shield:SetTint(1,1,1,0.6)

  local titlestr = KnownModIndex:GetModFancyName(self.modname)
  local maxtitlelength = 26
  if titlestr:len() > maxtitlelength then
    titlestr = titlestr:sub(1, maxtitlelength)
  end
  titlestr = titlestr.." "..STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX
  if self.title then
    self.title:Kill()
  end
  self.title = self.root:AddChild( Text(TITLEFONT, 50, titlestr) )
  self.title:SetPosition(0,210)
  self.title:SetColour(1,1,1,1)

  self.option_offset = 0
  if self.optionspanel then
    self.optionspanel:Kill()
  end
  self.optionspanel = self.root:AddChild(Widget("optionspanel"))
  self.optionspanel:SetPosition(0,-20)

  if self.menu then
    self.menu:Kill()
    self.applybutton:Kill()
    self.cancelbutton:Kill()
    self.resetbutton:Kill()
  end
  self.menu = self.root:AddChild(Menu(nil, 0, false))
  self.applybutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.APPLY, function() self:Apply() end, Vector3(-260, -290+30, 0))
  self.cancelbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.CANCEL, function() self:Cancel() end,  Vector3(-110, -290+30, 0))
  self.resetbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.RESETDEFAULT, function() self:ResetToDefaultValues() end,  Vector3(205, -290+30, 0))
  self.applybutton:SetScale(.9)
  self.cancelbutton:SetScale(.9)
  self.resetbutton:SetScale(.9)
  self.applybutton:SetFocusChangeDir(MOVE_RIGHT, self.cancelbutton)
  self.cancelbutton:SetFocusChangeDir(MOVE_LEFT, self.applybutton)
  self.cancelbutton:SetFocusChangeDir(MOVE_RIGHT, self.resetbutton)
  self.resetbutton:SetFocusChangeDir(MOVE_LEFT, self.cancelbutton)

  self.default_focus = self.applybutton
  if self.minimapwidgetmz then
    self.dirty = self.minimapwidgetmz:IsDirty()
  else
    self.dirty = false
  end

  if self.rightbutton then
    self.rightbutton:Kill()
  end
  self.rightbutton = self.optionspanel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
  self.rightbutton:SetPosition(440, 0, 0)
  self.rightbutton:SetScale(.9)
  self.rightbutton:SetOnClick( function() self:Scroll(ROWS_PER_COL) end)
  if #options <= ROWS_PER_COL * COLS then -- Only show the arrow if we have a ton of options
    self.rightbutton:Hide()
  end

  if self.leftbutton then
    self.leftbutton:Kill()
  end
  self.leftbutton = self.optionspanel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
  self.leftbutton:SetPosition(-440, 0, 0)
  self.leftbutton:SetScale(-.9,.9,.9)
  self.leftbutton:SetOnClick( function() self:Scroll(-ROWS_PER_COL) end)	
  self.leftbutton:Hide()

  TheInputProxy:StartMappingControls()
  self.is_mapping = false
  self.mapping_idx = nil
  self.inputhandlers = {}
  table.insert(self.inputhandlers, TheInput:AddControlMappingHandler(
    function(deviceId, controlId, inputId, hasChanged)
      self:OnControlMapped(deviceId, controlId, inputId, hasChanged)
    end
  ))

  self.optionwidgets = {}

  self:RefreshOptions()

  return true
end

function ModConfig:Close()
  TheFrontEnd:PopScreen()
  if #TheFrontEnd.screenstack < 2 then
    SetPause(false)
  end
  self.open = false
  TheInputProxy:StopMappingControls()
  for k,v in pairs(self.inputhandlers) do
    v:Remove()
  end
end

function ModConfig:MapControl(idx, name, value)
  local deviceId = 0
  local controlId = 0
  local controlIndex = controlId + 1      -- C++ control id is zero-based, we were passed a 1-based (lua) array index
  --print("Mapping control [" .. controlIndex .. "] on device [" .. deviceId .. "]")
  local loc_text = value
  local default_text = string.format("Original: %s", loc_text)
  local body_text = STRINGS.UI.CONTROLSSCREEN.CONTROL_SELECT .. "\n\n" .. default_text
  local popup = PopupDialogScreen(name, body_text, {})
  popup.text:SetFont(UIFONT)
  popup.text:SetRegionSize(480, 150)
  popup.text:SetPosition(0, -25, 0)
  popup.OnControl = function(_, control, down) self:MapControlInputHandler(control, down) end
  TheFrontEnd:PushScreen(popup)

  TheInputProxy:MapControl(deviceId, controlId)
  self.is_mapping = true
  self.mapping_idx = idx
end

local modkey_conv_tbl =
{
  [KEY_RSHIFT] = KEY_SHIFT,
  [KEY_LSHIFT] = KEY_SHIFT,
  [KEY_RCTRL] = KEY_CTRL,
  [KEY_LCTRL] = KEY_CTRL,
  [KEY_RALT] = KEY_ALT,
  [KEY_LALT] = KEY_ALT,
}

function ModConfig:GetKey(value)
  local device, numInputs, inputs = self:SplitToInputs(value)
  return inputs[numInputs]
end

function ModConfig:GetModifierKey(value)
  local device, numInputs, inputs = self:SplitToInputs(value)
  local modifier_key = {}
  for i = 1, numInputs - 1 do
    table.insert(modifier_key, inputs[i])
  end
  return modifier_key
end

function ModConfig:SplitToInputs(value)
  local device, numInputs, input1, input2, input3, input4 = value:match("(%d+)%+(%d+)%+(%d+)%+(%d+)%+(%d+)%+(%d+)")
  local inputs = {[1] = input1, [2] = input2, [3] = input3, [4] = input4}
  device = tonumber(device)
  numInputs = tonumber(numInputs)
  inputs[1] = tonumber(inputs[1])
  inputs[2] = tonumber(inputs[2])
  inputs[3] = tonumber(inputs[3])
  inputs[4] = tonumber(inputs[4])
  if not device or not numInputs or not inputs[1] or not inputs[2] or not inputs[3] or not inputs[4] or
     device ~= 1 or numInputs < 1
  then
    device = 1
    numInputs = 1
    inputs[1] = 0
    inputs[2] = 0
    inputs[3] = 0
    inputs[4] = 0
  end
  return device, numInputs, inputs
end

function ModConfig:JoinFromInputs(device, numInputs, inputs)
  local inputs_name = {[1]="",[2]="",[3]="",[4]=""}
  local new_text_value, new_value = "", tostring(device).."+"..tostring(numInputs).."+"
  local splitter = ""

  for i = 1, 4 do
    inputs[i] = modkey_conv_tbl[inputs[i]] or inputs[i]
    if STRINGS.UI.CONTROLSSCREEN.INPUTS[device] then
      inputs_name[i] = tostring(STRINGS.UI.CONTROLSSCREEN.INPUTS[device][inputs[i]])
    else
      inputs_name[i] = ""
    end
    new_value = new_value..splitter..(inputs[i] or "0")
    if i <= numInputs then
      new_text_value = new_text_value..splitter..inputs_name[i]
    end
    splitter = "+"
  end

  if inputs[1] == KEY_ESCAPE and numInputs == 1 or inputs[1] == 0 then
    new_text_value = "Disable"
    new_value = "1+1+0+0+0+0"
  elseif numInputs == 1 then
    new_text_value = "KEY "..new_text_value
  end

  return new_text_value, new_value
end

function ModConfig:OnControlMapped(deviceId, controlId, inputId, hasChanged)
  if self.is_mapping then 
    --print("Control [" .. controlId .. "] is now [" .. inputId .. "]")
    TheFrontEnd:PopScreen()
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    if hasChanged then
      for k,v in pairs(self.optionwidgets) do
        if v.root.button and v.root.button.option_idx == self.mapping_idx then
          local device, numInputs, input1, input2, input3, input4, intParam = TheInputProxy:GetLocalizedControl(deviceId, controlId, false, true)
          local new_text_value, new_value = self:JoinFromInputs(device, numInputs, {[1]=input1, [2]=input2, [3]=input3, [4]=input4})
          v.root.button:SetText(new_text_value)
          if options[self.mapping_idx].default ~= new_value then
            v.root.button:SetTextColour(1,0,0,1)
            v.root.button:SetTextFocusColour(1,0,0,1)
          else
            v.root.button:SetTextColour(0,0,1,1)
            v.root.button:SetTextFocusColour(0,0,1,1)
          end
          options[self.mapping_idx].value = new_value
        end
        local changedFromOriginal = TheInputProxy:HasMappingChanged(deviceId, controlId)
        if changedFromOriginal then
          --v.bg:Show()
        else
          --v.bg:Hide()
        end
      end
    end

    -- set the dirty flag (if something changed) if it hasn't yet been set
    if not self:IsDirty() and hasChanged then
      self:MakeDirty()
    end

    self.is_mapping = false
    self.mapping_idx = nil
  end 
end

function ModConfig:MapControlInputHandler(control, down)
--  if not down and control == CONTROL_CANCEL then
--    TheInputProxy:CancelMapping()
--    self.is_mapping = false
--    self.mapping_idx = nil
--    TheFrontEnd:PopScreen()
--  end
end

function ModConfig:IsOpen()
  return self.open == true
end

function ModConfig:IsModifiedBasicConfig()
  for i,v in pairs(self.modinfobasic.configuration_options) do
    for ii,vv in pairs(self.modinfofull.configuration_options) do
      if v.name == vv.name then
        if v.saved ~= vv.saved then
          return true
        end
      end
    end
  end
  return false
end

function ModConfig:UpdateModConfigDataFromBasicToFull()
  for i,v in pairs(self.modinfobasic.configuration_options) do
    for ii,vv in pairs(self.modinfofull.configuration_options) do
      if v.name == vv.name then
        if v.saved ~= vv.saved then
          vv.saved = v.saved
        end
      end
    end
  end
end

function ModConfig:FACTORY_RESET()
  self:ResetToDefaultBasic()
  self:ResetToDefaultFull()

  self:UpdateOptions()
  local settings = self:CollectSettings()
  self:SaveConfigurationOptions(function()
    self:MakeDirty(false)
  end, self.modname, settings)
end

function ModConfig:ResetToDefaultBasic()
  for i,v in pairs(self.modinfobasic.configuration_options) do
    v.saved = v.default
  end
end

function ModConfig:ResetToDefaultFull()
  for i,v in pairs(self.modinfofull.configuration_options) do
    v.saved = v.default
  end
end

function ModConfig:Init()
  self:GetConfigBasic()
  self:GetConfigFull()
  if self:IsModifiedBasicConfig() then
    self:UpdateModConfigDataFromBasicToFull()
  end
  self:UpdateState()
end

function ModConfig:UpdateState()
  -- Basic Options --
  self._mapscale               = self:GetModConfigDataBasic("Map Size")
  self._position_str           = self:GetModConfigDataBasic("Position")
  self._margin_size_x          = self:GetModConfigDataBasic("Horizontal Margin")
  self._margin_size_y          = self:GetModConfigDataBasic("Vertical Margin")
  self._default_zoom           = self:GetModConfigDataBasic("Default Zoom")
  self._close_when_open_chest  = self:GetModConfigDataBasic("Close when open chest")
  self._pause_focused          = self:GetModConfigDataBasic("Pause if focused")
  self._factory_reset          = self:GetModConfigDataBasic("FACTORY RESET")

  -- Full Options --
  self.mapscale                = self:GetModConfigDataFull("Map Size")
  self.position_str            = self:GetModConfigDataFull("Position")
  self.margin_size_x           = self:GetModConfigDataBasic("Horizontal Margin")
  self.margin_size_y           = self:GetModConfigDataBasic("Vertical Margin")
  self.default_zoom            = self:GetModConfigDataFull("Default Zoom")
  self.close_when_open_chest   = self:GetModConfigDataFull("Close when open chest")
  self.pause_focused           = self:GetModConfigDataFull("Pause if focused")
  self.scale_horiz             = self:GetModConfigDataFull("Horizontal Scale")
  self.scale_vert              = self:GetModConfigDataFull("Vertical Scale")
  self.show_bg_img             = self:GetModConfigDataFull("Show BG Image")
  self.map_blend_mode          = self:GetModConfigDataFull("Map Blend Mode")
  self.bg_blend_mode           = self:GetModConfigDataFull("BG Image Blend Mode")
  self.map_clickable           = self:GetModConfigDataFull("Map Clickable")
  self.map_trans               = self:GetModConfigDataFull("Map Transparency")
  self.bg_trans                = self:GetModConfigDataFull("BG Image Transparency")
  self.btn_scale               = self:GetModConfigDataFull("Button Scale")
  self.tglbtn_show             = self:GetModConfigDataFull("ToggleButton Show")
  self.tglbtn_horiz_pos        = self:GetModConfigDataFull("ToggleButton Horiz Pos")
  self.tglbtn_vert_pos         = self:GetModConfigDataFull("ToggleButton Vert Pos")
  self.configbtn_show          = self:GetModConfigDataFull("ConfigButton Show")
  self.configbtn_horiz_pos     = self:GetModConfigDataFull("ConfigButton Horiz Pos")
  self.configbtn_vert_pos      = self:GetModConfigDataFull("ConfigButton Vert Pos")
  self.quicksavebtn_show       = self:GetModConfigDataFull("QuickSaveButton Show")
  self.quicksavebtn_horiz_pos  = self:GetModConfigDataFull("QuickSaveButton Horiz Pos")
  self.quicksavebtn_vert_pos   = self:GetModConfigDataFull("QuickSaveButton Vert Pos")
  self.tglkey_raw              = self:GetModConfigDataFull("ToggleKey")
  self.tglkey                  = self:GetKey(self.tglkey_raw)
  self.tglkey_modifier         = self:GetModifierKey(self.tglkey_raw)
  self.centerresetkey_raw      = self:GetModConfigDataFull("CenterResetKey")
  self.centerresetkey          = self:GetKey(self.centerresetkey_raw)
  self.centerresetkey_modifier = self:GetModifierKey(self.centerresetkey_raw)
  self.configkey_raw           = self:GetModConfigDataFull("ConfigKey")
  self.configkey               = self:GetKey(self.configkey_raw)
  self.configkey_modifier      = self:GetModifierKey(self.configkey_raw)
  self.factory_reset           = self:GetModConfigDataFull("! FACTORY RESET !")

  -- ! FACTORY RESET !
  if self._factory_reset or self.factory_reset then
    self.factory_reset_mode = true
    self:FACTORY_RESET()
    self.factory_reset_mode = false
  end

--  print("--------BASIC")
--  for i,v in pairs(self.modinfobasic.configuration_options) do
--      print("i="..tostring(i))
--      print("v.name="..tostring(v.name))
--      print("v.saved="..tostring(v.saved))
--  end
--  print("--------FULL")
--  for i,v in pairs(self.modinfofull.configuration_options) do
--      print("i="..tostring(i))
--      print("v.name="..tostring(v.name))
--      print("v.saved="..tostring(v.saved))
--  end
end

function ModConfig:QuickSave()
  self.quicksaving = true
  self:UpdateOptions()
  local settings = self:CollectSettings()
  self:SaveConfigurationOptions(function()
    self:MakeDirty(false)
    self.minimapwidgetmz:MakeDirty(false)
  end, self.modname, settings)
  self.quicksaving = false
end

function ModConfig:IsQuickSaving()
  return self.quicksaving == true
end


function ModConfig:GetConfigBasic()
  self.modname = KnownModIndex:GetModActualName("Minimap HUD MZ")
  self.modinfobasic = self:InitializeModInfo(self.modname, "modinfo.lua")
  self.configbasic = self:LoadModConfigurationOptions(self.modname, self.modinfobasic)
end

function ModConfig:GetConfigFull()
  self.modname = KnownModIndex:GetModActualName("Minimap HUD MZ")
  self.modinfofull = self:InitializeModInfo(self.modname, "modinfofull.lua")
  self.configfull = self:LoadModConfigurationOptions(self.modname.."_FULL", self.modinfofull)
end

function ModConfig:GetModConfigDataBasic(optionname)
  local config = self.modinfobasic.configuration_options
  if config and type(config) == "table" then
    for i,v in pairs(config) do
      if v.name == optionname then
        if v.saved ~= nil then
          return v.saved 
        else 
          return v.default
        end
      end
    end
  end
  return nil
end

function ModConfig:GetModConfigDataFull(optionname)
  local config = self.modinfofull.configuration_options
  if config and type(config) == "table" then
    for i,v in pairs(config) do
      if v.name == optionname then
        if v.saved ~= nil then
          return v.saved 
        else 
          return v.default
        end
      end
    end
  end
  return nil
end

function ModConfig:SetModConfigDataFull(optionname, data)
  local config = self.modinfofull.configuration_options
  if config and type(config) == "table" then
    for i,v in pairs(config) do
      if v.name == optionname then
        v.saved = data
        self:MakeDirty()
        return true
      end
    end
  end
  return false
end

function ModConfig:InitializeModInfo(modname, modinfoname)
  local env = {}
  local fn = kleiloadlua("../mods/"..modname.."/"..modinfoname)
  local modinfo_message = ""
  if type(fn) == "string" then
    print("Error loading mod: "..ModInfoname(modname).."!\n "..fn.."\n")
    --table.insert( self.failedmods, {name=modname,error=fn} )
    env.failed = true
  elseif not fn then
    modinfo_message = modinfo_message.."No modinfo.lua, using defaults... "
    env.old = true
  else
    local status, r = RunInEnvironment(fn,env)

    if status == false then
      print("Error loading mod: "..ModInfoname(modname).."!\n "..r.."\n")
      --table.insert( self.failedmods, {name=modname,error=r} )
      env.failed = true
    elseif env.api_version == nil or env.api_version < MOD_API_VERSION then
      local old = "Mod "..modname.." was built for an older version of the game and requires updating. (api_version is version "..tostring(env.api_version)..", game is version "..MOD_API_VERSION..".)"
      modinfo_message = modinfo_message.."Old API! (mod: "..tostring(env.api_version).." game: "..MOD_API_VERSION..") "
      env.old = true
    elseif env.api_version > MOD_API_VERSION then
      local old = "api_version for "..modname.." is in the future, please set to the current version. (api_version is version "..env.api_version..", game is version "..MOD_API_VERSION..".)"
      print("Error loading mod: "..ModInfoname(modname).."!\n "..old.."\n")
      --table.insert( self.failedmods, {name=modname,error=old} )
      env.failed = true
    else
      local checkinfo = { "name", "description", "author", "version", "forumthread", "api_version", "dont_starve_compatible", "reign_of_giants_compatible", "configuration_options" }
      local missing = {}

      for i,v in ipairs(checkinfo) do
        if env[v] == nil then
          if v == "dont_starve_compatible" then
            -- Print a warning but let the mod load
            print("WARNING loading modinfo.lua: "..modname.." does not specify if it is compatible with the base game. It may not work properly.")
          elseif v == "reign_of_giants_compatible" then
            -- Print a warning but let the mod load
            print("WARNING loading modinfo.lua: "..modname.." does not specify if it is compatible with Reign of Giants. It may not work properly.")
          elseif v == "configuration_options" then
            -- Do nothing. It's perfectly fine not to have config options!
          else
            table.insert(missing, v)
          end
        end
      end

      if #missing > 0 then
        local e = "Error loading modinfo.lua. These fields are required: " .. table.concat(missing, ", ")
        print (e)
        --table.insert( self.failedmods, {name=modname,error=e} )

        env.failed = true
      else
        -- everything loaded okay!
      end
    end
  end

  env.modinfo_message = modinfo_message

  -- If modinfo hasn't been updated to specify compatibility yet, set it to true for both modes and set a flag
  if env.dont_starve_compatible == nil then
    env.dont_starve_compatible = true
    env.dont_starve_compatibility_specified = false
  end
  if env.reign_of_giants_compatible == nil then
    env.reign_of_giants_compatible = true
    env.reign_of_giants_compatibility_specified = false
  end

  return env
end

function ModConfig:HasModConfigurationOptions(modinfo)
  if modinfo and modinfo.configuration_options and type(modinfo.configuration_options) == "table" and #modinfo.configuration_options > 0 then
    return true
  end
  return false
end

-- Loads the actual file from disk
function ModConfig:LoadModConfigurationOptions(configname, modinfo)

  -- Try to find saved config settings first
  local filename = KnownModIndex:GetModConfigurationPath(configname)
  TheSim:GetPersistentString(filename,
    function(load_success, str)
      if load_success == true then
        local success, savedata = RunInSandbox(str)
        if success and string.len(str) > 0 then
          -- Carry over saved data from old versions when possible
          if self:HasModConfigurationOptions(modinfo) then
            KnownModIndex:UpdateConfigurationOptions(modinfo.configuration_options, savedata)
          else
            modinfo.configuration_options = savedata
          end
          --print ("loaded "..filename)
        else
          print ("Could not load "..filename)
        end
      else
        print ("Could not load "..filename)
      end

      -- callback()
    end)

  if modinfo and modinfo.configuration_options then
    return modinfo.configuration_options
  end
  return nil
end

function ModConfig:CollectSettings()
  local settings = nil
  for i,v in pairs(options) do
    if not settings then settings = {} end
    table.insert(settings, {name=v.name, label = v.label, options=v.options, default=v.default, saved=v.value})
  end
  return settings
end

function ModConfig:ResetToDefaultValues()
  local function reset()
    for i,v in pairs(options) do
      options[i].value = options[i].default
    end
    self:RefreshOptions()
  end

  if not self:IsDefaultSettings() then
    self:ConfirmRevert(function() 
      TheFrontEnd:PopScreen()
      self:MakeDirty()
      reset()
    end)
  end
end

function ModConfig:SaveConfigurationOptions(callback, modname, configdata)
  if PLATFORM == "PS4" or not configdata then
    return
  end

  -- Save it to disk (BASIC)
  local name_basic = KnownModIndex:GetModConfigurationPath(modname)
  local data_basic = DataDumper(configdata, nil, false)

  local cb_basic = function()
    -- do nothing
  end

  local insz, outsz = SavePersistentString(name_basic, data_basic, ENCODE_SAVES, cb_basic)

  -- Save it to disk (FULL)
  local name_full = KnownModIndex:GetModConfigurationPath(modname.."_FULL")
  local data_full = DataDumper(configdata, nil, false)

  local cb_full = function()
    callback()
    -- And reload it to make sure there's parity after it's been saved
    self.modinfobasic.configuration_options = self:LoadModConfigurationOptions(modname, self.modinfobasic)
    self.modinfofull.configuration_options = self:LoadModConfigurationOptions(modname.."_FULL", self.modinfofull)

    -- Update internal state
    self:UpdateState()
    if not self.factory_reset_mode then
      self.minimapwidgetmz:UpdateState()
      if self.modmain_updatestate_callback then
        self.modmain_updatestate_callback()
      end
    end
  end

  local insz, outsz = SavePersistentString(name_full, data_full, ENCODE_SAVES, cb_full)
end

function ModConfig:Apply()
  if self:IsDirty() then
    local settings = self:CollectSettings()
    self:SaveConfigurationOptions(function()
      self:MakeDirty(false)
      self.minimapwidgetmz:MakeDirty(false)
      self:Close()
    end, self.modname, settings)
  else
    self:MakeDirty(false)
    self.minimapwidgetmz:MakeDirty(false)
    self:Close()
  end
end

function ModConfig:ConfirmRevert(callback)
  TheFrontEnd:PushScreen(
    PopupDialogScreen( STRINGS.UI.MODSSCREEN.BACKTITLE, STRINGS.UI.MODSSCREEN.BACKBODY,
      { 
        { 
          text = STRINGS.UI.MODSSCREEN.YES, 
          cb = callback or function() TheFrontEnd:PopScreen() end
        },
        { 
          text = STRINGS.UI.MODSSCREEN.NO, 
          cb = function()
            TheFrontEnd:PopScreen()					
          end
        }
      }
    )
  )
end

function ModConfig:Cancel()
  if self:IsDirty() and not (self.started_default and self:IsDefaultSettings()) and not self.minimapwidgetmz:IsDirty() then
    self:ConfirmRevert(function()
      TheFrontEnd:PopScreen()
      self:MakeDirty(false)
      self:Cancel()
    end)
  else
    if not self.minimapwidgetmz:IsDirty() then
      self:MakeDirty(false)
    end
    self:Close()
  end
end

function ModConfig:MakeDirty(dirty)
  if dirty ~= nil then
    self.dirty = dirty
  else
    self.dirty = true
  end
end

function ModConfig:IsDefaultSettings()
  local alldefault = true
  for i,v in pairs(options) do
    if options[i].value ~= options[i].default then
      alldefault = false
      break
    end
  end
  return alldefault
end

function ModConfig:IsDirty()
  return self.dirty
end

function ModConfig:OnControl(control, down)
  if ModConfig._base.OnControl(self, control, down) then return true end

  if not down then
    if control == CONTROL_CANCEL then
      self:Cancel()
    elseif control == CONTROL_ACCEPT and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
      self:Apply() --apply changes and go back, or stay
    elseif control == self.CONTROL_PAGELEFT then
      if self.leftbutton.shown then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self:Scroll(-ROWS_PER_COL)
      end
    elseif control == self.CONTROL_PAGERIGHT then
      if self.rightbutton.shown then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self:Scroll(ROWS_PER_COL)
      end
    else
      return false
    end 

    return true
  end
end

function ModConfig:Scroll(dir)
  if (dir > 0 and (self.option_offset + ROWS_PER_COL*2) < #options) or
     (dir < 0 and self.option_offset + dir >= 0) then

       self.option_offset = self.option_offset + dir
     end

  if self.option_offset > 0 then
    self.leftbutton:Show()
  else
    self.leftbutton:Hide()
  end

  if self.option_offset + ROWS_PER_COL*2 < #options then
    self.rightbutton:Show()
  else
    self.rightbutton:Hide()
  end

  self:RefreshOptions()
end

function ModConfig:RefreshOptions()

  local focus = self:GetDeepestFocus()
  local old_column = focus and focus.column
  local old_idx = focus and focus.idx

  for k,v in pairs(self.optionwidgets) do
    v.root:Kill()
  end
  self.optionwidgets = {}

  self.left_spinners = {}
  self.right_spinners = {}

  for k = 1, ROWS_PER_COL*2 do

    local idx = self.option_offset+k

    if options[idx] then

      local opt = self.optionspanel:AddChild(Widget("option"))

      if options[idx].name == "ToggleKey" or options[idx].name == "CenterResetKey" or options[idx].name == "ConfigKey" then
        local button_height = 50
        local w = 220
        local button = opt:AddChild(ImageButton())
        button:SetFont(BUTTONFONT)
        button:SetTextSize(28)
        local value = options[idx].value or options[idx].saved or options[idx].default
        local device, numInputs, inputs = self:SplitToInputs(value)
        local new_text_value, new_value = self:JoinFromInputs(device, numInputs, inputs)
        button:SetText(new_text_value)
        if options[idx].default ~= new_value then
          button:SetTextColour(0,0,0,1)
        else
          button:SetTextColour(0,0,1,1)
        end
        local button_w, button_h = button:GetSize()
        local button_scale_w = w / button_w
        local button_scale_h = button_height / button_h
        button:SetScale(button_scale_w, button_scale_h)
        button:SetPosition(35,0,0 )
        button:SetOnClick(function()
          self:MapControl(idx, options[idx].name, new_text_value)
        end)

        local spacing = 55
        local label_width = 180 * 1/button_scale_w

        local label = button:AddChild( Text( BUTTONFONT, 30, (options[idx].label or options[idx].name) or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING ) )
        label:SetScale(1/button_scale_w, 1/button_scale_h)
        label:SetPosition( -label_width/2 - 105*1/button_scale_w, 0, 0 )
        label:SetRegionSize( label_width, 50 )
        label:SetHAlign( ANCHOR_MIDDLE )

        opt.button = button
        button.option_idx = idx

        if k <= ROWS_PER_COL then
          opt:SetPosition(-155, (ROWS_PER_COL-1)*spacing*.5 - (k-1)*spacing - 10, 0)
          table.insert(self.left_spinners, button)
          button.column = "left"
          button.idx = #self.left_spinners
        else
          opt:SetPosition(265, (ROWS_PER_COL-1)*spacing*.5 - (k-1-ROWS_PER_COL)*spacing- 10, 0)
          table.insert(self.right_spinners, button)
          button.column = "right"
          button.idx = #self.right_spinners
        end
      else
        local spin_options = {} --{{text="default"..tostring(idx), data="default"},{text="2", data="2"}, }
        for k,v in ipairs(options[idx].options) do
          table.insert(spin_options, {text=v.description, data=v.data})
        end

        local spin_height = 50
        local w = 220
        local spinner = opt:AddChild(Spinner( spin_options, w, spin_height))
        local default_value = options[idx].value
        if default_value == nil then default_value = options[idx].default end

        if options[idx].value and options[idx].default ~= options[idx].value then
          spinner:SetTextColour(0,0,0,1)
        else
          spinner:SetTextColour(0,0,1,1)
        end

        spinner.OnChanged =
        function( _, data )
          options[idx].value = data
          self:MakeDirty()
          if options[idx].default ~= data then
            spinner:SetTextColour(1,0,0,1)
          else
            spinner:SetTextColour(0,0,1,1)
          end
        end

        spinner:SetSelected(default_value)
        if spinner:GetSelectedData() ~= default_value then
          if self:IsDirty() then
            spinner:SetTextColour(1,0,0,1)
          else
            spinner:SetTextColour(0,1,0,1)
          end
          spinner:UpdateText("Customized Value")
        end
        spinner:SetPosition(35,0,0 )

        local spacing = 55
        local label_width = 180

        local label = spinner:AddChild( Text( BUTTONFONT, 30, (options[idx].label or options[idx].name) or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING ) )
        label:SetPosition( -label_width/2 - 105, 0, 0 )
        label:SetRegionSize( label_width, 50 )
        label:SetHAlign( ANCHOR_MIDDLE )

        if k <= ROWS_PER_COL then
          opt:SetPosition(-155, (ROWS_PER_COL-1)*spacing*.5 - (k-1)*spacing - 10, 0)
          table.insert(self.left_spinners, spinner)
          spinner.column = "left"
          spinner.idx = #self.left_spinners
        else
          opt:SetPosition(265, (ROWS_PER_COL-1)*spacing*.5 - (k-1-ROWS_PER_COL)*spacing- 10, 0)
          table.insert(self.right_spinners, spinner)
          spinner.column = "right"
          spinner.idx = #self.right_spinners
        end
      end

      table.insert(self.optionwidgets, {root = opt})
    end
  end

  --hook up all of the focus moves
  self:HookupFocusMoves()

  if old_column and old_idx then
    local list = old_column == "right" and self.right_spinners or self.left_spinners
    list[math.min(#list, old_idx)]:SetFocus()
  end

end

function ModConfig:HookupFocusMoves()
  local GetFirstEnabledSpinnerAbove = function(k, tbl)
    for i=k-1,1,-1 do
      if tbl[i] and tbl[i].enabled then
        return tbl[i]
      end
    end
    return nil
  end
  local GetFirstEnabledSpinnerBelow = function(k, tbl)
    for i=k+1,#tbl do
      if tbl[i] and tbl[i].enabled then
        return tbl[i]
      end
    end
    return nil
  end

  for k = 1, #self.left_spinners do
    local abovespinner = GetFirstEnabledSpinnerAbove(k, self.left_spinners)
    if abovespinner then
      self.left_spinners[k]:SetFocusChangeDir(MOVE_UP, abovespinner)
    end

    local belowspinner = GetFirstEnabledSpinnerBelow(k, self.left_spinners)
    if belowspinner	then
      self.left_spinners[k]:SetFocusChangeDir(MOVE_DOWN, belowspinner)
    else
      self.left_spinners[k]:SetFocusChangeDir(MOVE_DOWN, self.applybutton)
    end

    if self.right_spinners[k] then
      self.left_spinners[k]:SetFocusChangeDir(MOVE_RIGHT, self.right_spinners[k])
    end
  end

  for k = 1, #self.right_spinners do
    local abovespinner = GetFirstEnabledSpinnerAbove(k, self.right_spinners)
    if abovespinner then
      self.right_spinners[k]:SetFocusChangeDir(MOVE_UP, abovespinner)
    end

    local belowspinner = GetFirstEnabledSpinnerBelow(k, self.right_spinners)
    if belowspinner	then
      self.right_spinners[k]:SetFocusChangeDir(MOVE_DOWN,belowspinner)
    else
      self.right_spinners[k]:SetFocusChangeDir(MOVE_DOWN, self.resetbutton)
    end

    if self.left_spinners[k] then
      self.right_spinners[k]:SetFocusChangeDir(MOVE_LEFT, self.left_spinners[k])
    end
  end

  self.applybutton:SetFocusChangeDir(MOVE_UP, self.left_spinners[#self.left_spinners])
  self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.left_spinners[#self.left_spinners])
  self.resetbutton:SetFocusChangeDir(MOVE_UP, self.right_spinners[#self.right_spinners])
end

function ModConfig:GetHelpText()
  local t = {}
  local controller_id = TheInput:GetControllerID()

  if self:IsDirty() then
    local focus = self:GetDeepestFocus()
    if focus ~= self.applybutton and focus ~= self.cancelbutton and focus ~= self.resetbutton then
      table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.APPLY)
    end
  end
  table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

  if self.leftbutton.shown then 
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, self.CONTROL_PAGELEFT) .. " " .. STRINGS.UI.HELP.SCROLLBACK)
  end

  if self.rightbutton.shown then
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, self.CONTROL_PAGERIGHT) .. " " .. STRINGS.UI.HELP.SCROLLFWD)
  end

  return table.concat(t, "  ")
end

return ModConfig
