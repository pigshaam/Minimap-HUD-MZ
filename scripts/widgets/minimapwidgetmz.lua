local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local world

local MiniMapWidgetMz = Class(Widget, function(self, IsDST, owner, modconfig)
  Widget._ctor(self, "MiniMapWidgetMz")
  self.IsDST = IsDST
  self.owner = owner -- == GetPlayer()
  self.adjustvalue = 0.225 -- The mysterious value
  self.modconfig = modconfig
  if IsDST then
    world = TheWorld
  else
    world = GetWorld()
  end
  self.minimap = world.minimap.MiniMap
  self.bg = self:AddChild(Image("images/hud.xml", "map.tex"))
  self.map = self:AddChild(Image())
  self:UpdateTexture()
  self.mapsize_orig_w, self.mapsize_orig_h = self.bg:GetSize()
  self.mapsize = {w=self.mapsize_orig_w*self.modconfig.mapscale*self.modconfig.scale_horiz, h=self.mapsize_orig_h*self.modconfig.mapscale*self.modconfig.scale_vert}
  self.mappos_gap = {x=0, y=0}
  self.mapsize_view = {w=self.mapsize.w, h=self.mapsize.h}
  self.map:SetSize(self.mapsize.w,self.mapsize.h,0)
  self.bg:SetSize(self.mapsize.w,self.mapsize.h,0)
  self.bg:SetClickable(false)
  self.tglbtn = self:AddChild(ImageButton())
  self.tglbtn:SetOnClick( function() self:ToggleOpen() end )
  self.quicksavebtn = self:AddChild(ImageButton())
  self.quicksavebtn:SetOnClick( function() self.modconfig:QuickSave() self:PositionQuickSaveButton(0,0) end )
  self.configbtn = self:AddChild(ImageButton())
  self.configbtn:SetOnClick( function() if self.modconfig:Open() then TheFrontEnd:PushScreen(self.modconfig) end end )
  self:SetOpen( true )
  self.mapscreenzoom = 1
  self.lastpos = nil
  self.lastpos_bg = nil
  self.mapcenter_gap = Point(0, 0)
  self.dirty = false
  self.hudsize = PlayerProfile:GetHUDSize()

  self:UpdateState()
  self:PositionMiniMap()
  local newmappos_x, newmappos_y = self:ResizeMapView()
  self:SetPosition(newmappos_x, newmappos_y)
  self:ResetOffset()

  self:StartUpdating()
  self:Show()
end)

function MiniMapWidgetMz:MakeDirty(dirty)
  if dirty ~= nil then
    self.dirty = dirty
  else
    self.dirty = true
  end
end

function MiniMapWidgetMz:IsDirty()
  return self.dirty
end

function MiniMapWidgetMz:PositionMiniMap()
  self.dir_vert = 0
  self.dir_horiz = 0
  self.anchor_vert = 0
  self.anchor_horiz = 0
  self.margin_dir_vert = 0
  self.margin_dir_horiz = 0
  self.y_align, self.x_align = self.modconfig.position_str:match("(%a+)_(%a+)")

  if self.x_align == "left" then
    self.dir_horiz = -1
    self.anchor_horiz = 1
    self.margin_dir_horiz = 1
  elseif self.x_align == "center" then
    self.dir_horiz = 0
    self.anchor_horiz = 0
    self.margin_dir_horiz = 0
  elseif self.x_align == "right" then
    self.dir_horiz = 1
    self.anchor_horiz = -1
    self.margin_dir_horiz = -1
  end

  if self.y_align == "top" then
    self.dir_vert = 0
    self.anchor_vert = -1
    self.margin_dir_vert = -1
  elseif self.y_align == "middle" then
    self.dir_vert = -1
    self.anchor_vert = 0
    self.margin_dir_vert = 0
  elseif self.y_align == "bottom" then
    self.dir_vert = -2
    self.anchor_vert = 1
    self.margin_dir_vert = 1
  end

  local hudscale = self.owner.HUD.controls.top_root:GetScale()
  local screenw_full, screenh_full = TheSim:GetScreenSize()
  local screenw = screenw_full/hudscale.x
  local screenh = screenh_full/hudscale.y
  local marginsizex = self.margin_dir_horiz*self.modconfig.margin_size_x
  local marginsizey = self.margin_dir_vert*self.modconfig.margin_size_y

  self:SetPosition(
    (self.anchor_horiz*self.mapsize.w)+(self.dir_horiz*(screenw/2+self.mapsize.w/2))+marginsizex,
    (self.anchor_vert*self.mapsize.h)+(self.dir_vert*screenh/2 + (-self.anchor_vert*self.mapsize.h/2))+marginsizey,
    0
  )
end

function MiniMapWidgetMz:ShowHideButtons()
  if self.open then
    if self.focus then
      if self.modconfig.tglbtn_show then
        self.tglbtn:Show()
      else
        self.tglbtn:Hide()
      end
      if self.modconfig.configbtn_show then
        self.configbtn:Show()
      else
        self.configbtn:Hide()
      end
      if self.modconfig.quicksavebtn_show and self.modconfig:IsDirty() then
        self.quicksavebtn:Show()
      else
        self.quicksavebtn:Hide()
      end
    else
      if self.modconfig.map_clickable then
        self.tglbtn:Hide()
        self.configbtn:Hide()
        self.quicksavebtn:Hide()
      else
        if self.modconfig.tglbtn_show then
          self.tglbtn:Show()
        else
          self.tglbtn:Hide()
        end
        if self.modconfig.configbtn_show then
          self.configbtn:Show()
        else
          self.configbtn:Hide()
        end
        if self.modconfig.quicksavebtn_show and self.modconfig:IsDirty() then
          self.quicksavebtn:Show()
        else
          self.quicksavebtn:Hide()
        end
      end
    end
  else
    if self.modconfig.tglbtn_show then
      self.tglbtn:Show()
    end
    self.configbtn:Hide()
    self.quicksavebtn:Hide()
  end
end

function MiniMapWidgetMz:PositionToggleButton(dx, dy)
  self.tglbtn:SetScale(self.modconfig.btn_scale,self.modconfig.btn_scale,self.modconfig.btn_scale)
  local tglbtnsize_w,tglbtnsize_h = self.tglbtn:GetSize()
  self.tglbtnsize = {w=tglbtnsize_w*self.modconfig.btn_scale, h=tglbtnsize_h*self.modconfig.btn_scale}
  self.tglbtnpos_horiz = self.tglbtnsize.w/2 + (self.mapsize_view.w - self.tglbtnsize.w/2*2)/10*self.modconfig.tglbtn_horiz_pos
  self.tglbtnpos_vert = -self.tglbtnsize.h/2 - (self.mapsize_view.h - self.tglbtnsize.h/2*2)/10*self.modconfig.tglbtn_vert_pos
  local newbuttonpos = Point(-self.mapsize_view.w/2 + self.tglbtnpos_horiz + dx, self.mapsize_view.h/2 + self.tglbtnpos_vert + dy, 0)
  self.tglbtn.o_pos = newbuttonpos
  self.tglbtn:SetPosition(newbuttonpos:Get())
  self:ShowHideButtons()
end

function MiniMapWidgetMz:PositionConfigButton(dx, dy)
  self.configbtn:SetScale(self.modconfig.btn_scale,self.modconfig.btn_scale,self.modconfig.btn_scale)
  local configbtnsize_w,configbtnsize_h = self.configbtn:GetSize()
  self.configbtnsize = {w=configbtnsize_w*self.modconfig.btn_scale, h=configbtnsize_h*self.modconfig.btn_scale}
  self.configbtnpos_horiz = self.configbtnsize.w/2 + (self.mapsize_view.w - self.configbtnsize.w/2*2)/10*self.modconfig.configbtn_horiz_pos
  self.configbtnpos_vert = -self.configbtnsize.h/2 - (self.mapsize_view.h - self.configbtnsize.h/2*2)/10*self.modconfig.configbtn_vert_pos
  local newbuttonpos = Point(-self.mapsize_view.w/2 + self.configbtnpos_horiz + dx, self.mapsize_view.h/2 + self.configbtnpos_vert + dy, 0)
  self.configbtn.o_pos = newbuttonpos
  self.configbtn:SetPosition(newbuttonpos:Get())
  self:ShowHideButtons()
end

function MiniMapWidgetMz:PositionQuickSaveButton(dx, dy)
  self.quicksavebtn:SetScale(self.modconfig.btn_scale,self.modconfig.btn_scale,self.modconfig.btn_scale)
  local quicksavebtnsize_w,quicksavebtnsize_h = self.quicksavebtn:GetSize()
  self.quicksavebtnsize = {w=quicksavebtnsize_w*self.modconfig.btn_scale, h=quicksavebtnsize_h*self.modconfig.btn_scale}
  self.quicksavebtn.text:SetFont(UIFONT)
  self.quicksavebtn.text:SetSize(40)
  self.quicksavebtn:SetTextColour(0,0.7,0,1)
  self.quicksavebtn:SetTextFocusColour(0,1,0,1)
  self.quicksavebtnpos_horiz = self.quicksavebtnsize.w/2 + (self.mapsize_view.w - self.quicksavebtnsize.w/2*2)/10*self.modconfig.quicksavebtn_horiz_pos
  self.quicksavebtnpos_vert = -self.quicksavebtnsize.h/2 - (self.mapsize_view.h - self.quicksavebtnsize.h/2*2)/10*self.modconfig.quicksavebtn_vert_pos
  local newbuttonpos = Point(-self.mapsize_view.w/2 + self.quicksavebtnpos_horiz + dx, self.mapsize_view.h/2 + self.quicksavebtnpos_vert + dy, 0)
  self.quicksavebtn.o_pos = newbuttonpos
  self.quicksavebtn:SetPosition(newbuttonpos:Get())
  self:ShowHideButtons()
end

function MiniMapWidgetMz:UpdateState()
  self.mapsize =
  {
    w=self.mapsize_orig_w*self.modconfig.mapscale*self.modconfig.scale_horiz,
    h=self.mapsize_orig_h*self.modconfig.mapscale*self.modconfig.scale_vert
  }
  self.mappos_gap = {x=0, y=0}
  self.mapsize_view = {w=self.mapsize.w, h=self.mapsize.h}
  self.map:SetSize(self.mapsize.w,self.mapsize.h,0)
  self.bg:SetSize(self.mapsize.w,self.mapsize.h,0)
  self.bg.inst.ImageWidget:SetBlendMode( self.modconfig.bg_blend_mode )
  self.map.inst.ImageWidget:SetBlendMode( self.modconfig.map_blend_mode )
  self.map:SetTint(1,1,1,self.modconfig.map_trans)
  self.map:SetClickable(self.modconfig.map_clickable)
  self.bg:SetTint(1,1,1,self.modconfig.bg_trans)
  if not self.modconfig:IsQuickSaving() then
    if self.modconfig.default_zoom < 3 then
      self.minimapzoom = 0
      self.uvscale = 1*((1-0.5^(4-self.modconfig.default_zoom))/(1-0.5)) -- Geometric progression : 1, 1.5, 1.75, 1.875, ...
    else
      self.minimapzoom = self.modconfig.default_zoom - 3
      self.uvscale = 1
    end
    self.mapcenter_gap = Point(0, 0)
  end
  self.minimap:Zoom(-1000)
  self.minimap:Zoom(self.minimapzoom)
  self.map:SetUVScale(self.uvscale, self.uvscale)
  self:PositionMiniMap()
  local newmappos_x, newmappos_y = self:ResizeMapView()
  self:SetPosition(newmappos_x, newmappos_y)
  self:ResetOffset()
  self:SetOpen(true)
end

function MiniMapWidgetMz:ResizeMapView(mappos_x, mappos_y)
  local hudscale = self.owner.HUD.controls.top_root:GetScale()
  if mappos_x == nil or mappos_y == nil then
    local mappos_now = self:GetPosition()
    mappos_x = mappos_now.x
    mappos_y = mappos_now.y
  end
  local new_mappos_x = mappos_x
  local new_mappos_y = mappos_y

  local scrn_w, scrn_h = TheSim:GetScreenSize()
  scrn_w = scrn_w / hudscale.x
  scrn_h = scrn_h / hudscale.y
  local mapsize_w = self.mapsize.w
  local mapsize_h = self.mapsize.h
  local rgap = (mappos_x + mapsize_w/2) - ( scrn_w/2) -- if over +
  local lgap = (mappos_x - mapsize_w/2) - (-scrn_w/2) -- if over -
  local tgap = (mappos_y + mapsize_h/2) - ( 0)        -- if over +
  local bgap = (mappos_y - mapsize_h/2) - (-scrn_h)   -- if over -

  local new_w = mapsize_w
  local new_h = mapsize_h
  local dx = 0
  local dy = 0
  if rgap > 0 then
    new_w = new_w - math.abs(rgap)
    dx = -math.abs(rgap)/2
  end
  if lgap < 0 then
    new_w = new_w - math.abs(lgap)
    dx = math.abs(lgap)/2
  end
  if tgap > 0 then
    new_h = new_h - math.abs(tgap)
    dy = -math.abs(tgap)/2
  end
  if bgap < 0 then
    new_h = new_h - math.abs(bgap)
    dy = math.abs(bgap)/2
  end

  local basesize_tiny = 0.125
  local basesize_tiny_margin = 1
  local mapsizeorig_w = self.mapsize_orig_w
  local mapsizeorig_h = self.mapsize_orig_h
  if new_w < mapsizeorig_w*basesize_tiny-basesize_tiny_margin then
    local limit_dx = dx / math.abs(dx) * (mapsizeorig_w*basesize_tiny - new_w)/2
    dx = dx - limit_dx
    new_mappos_x = new_mappos_x + limit_dx*2
    new_w = mapsizeorig_w*basesize_tiny
  end
  if new_h < mapsizeorig_h*basesize_tiny-basesize_tiny_margin then
    local limit_dy = dy / math.abs(dy) * (mapsizeorig_h*basesize_tiny - new_h)/2
    dy = dy - limit_dy
    new_mappos_y = new_mappos_y + limit_dy*2
    new_h = mapsizeorig_h*basesize_tiny
  end

  self.bg:SetSize(new_w, new_h)
  self.bg:SetPosition(dx, dy)
  self.mapsize_view = {w=new_w, h=new_h}
  self.mappos_gap = {x=dx, y=dy}

  self:PositionToggleButton(dx, dy)
  self:PositionConfigButton(dx, dy)
  self:PositionQuickSaveButton(dx, dy)

  if self.lastpos_bg then
    local scrn_w, scrn_h = TheSim:GetScreenSize()
    local mapscale_gap_w = self.adjustvalue*scrn_w/self.mapsize.w  /(2^(math.log((-(self.uvscale*(1-0.5))/1+1))/math.log(0.5)-1))
    local mapscale_gap_h = self.adjustvalue*scrn_h/self.mapsize.h  /(2^(math.log((-(self.uvscale*(1-0.5))/1+1))/math.log(0.5)-1))
    local location_gap_x = (dx-self.lastpos_bg.x)*mapscale_gap_w
    local location_gap_y = (dy-self.lastpos_bg.y)*mapscale_gap_h
    self.minimap:Offset(location_gap_x, location_gap_y)
    self.mapcenter_gap.x = self.mapcenter_gap.x + location_gap_x
    self.mapcenter_gap.y = self.mapcenter_gap.y + location_gap_y
  end

  self.lastpos_bg = Point(dx, dy)

  return new_mappos_x, new_mappos_y
end

function MiniMapWidgetMz:ToggleOpen()
  self:SetOpen( not self:IsOpen() )
end

function MiniMapWidgetMz:SetOpen( state )
  if state == nil then state = true end

  if state then
    self.open = true

    -- Toggle Button --
    self.tglbtn:SetText("Close Minimap")

    -- Config Button --
    self.configbtn:SetText("Configure Mod")

    -- Quick Save Button --
    self.quicksavebtn:SetText("Save Config")

    -- Show/Hide Buttons
    self:ShowHideButtons()

    self.map:Show()
    if self.modconfig.show_bg_img then
      self.bg:Show()
    else
      self.bg:Hide()
    end
  else
    self.open = false

    -- Toggle Button --
    self.tglbtn:SetText("Open Minimap")

    -- Config Button --
    self.configbtn:SetText("Configure Mod")

    -- Quick Save Button --
    self.quicksavebtn:SetText("Save Config")

    -- Show/Hide Buttons
    self:ShowHideButtons()

    self.map:Hide()
    self.bg:Hide()
  end
end

function MiniMapWidgetMz:IsOpen()
  return self.open
end

function MiniMapWidgetMz:OnControl( control, down )
  if MiniMapWidgetMz._base.OnControl(self, control, down) then return true end
  if down and control == CONTROL_MAP_ZOOM_IN then
    self:OnZoomIn()
    return true
  elseif down and control == CONTROL_MAP_ZOOM_OUT then
    self:OnZoomOut()
    return true
  end
end

function MiniMapWidgetMz:OnGainFocus()
  if self.modconfig.pause_focused then
    SetPause(true, "inv")
  end
  self:MoveToFront()
  self.bg:SetTint(1,1,1,1)
  self.map:SetTint(1,1,1,1)

  -- horrible way to stop camera zooming, but oh well
  self.camera_controllable_reset = TheCamera:IsControllable()
  TheCamera:SetControllable(false)

  self:ShowHideButtons()
end

function MiniMapWidgetMz:OnLoseFocus()
  if self.lastpos then
    local newmappos_x, newmappos_y = self:ResizeMapView()
    self:SetPosition(newmappos_x, newmappos_y)
    self.lastpos = nil
  end

  self:MoveToBack()
  self.bg:SetTint(1,1,1,self.modconfig.bg_trans)
  self.map:SetTint(1,1,1,self.modconfig.map_trans)

  -- reset to orig value
  TheCamera:SetControllable(self.camera_controllable_reset)

  self:ShowHideButtons()

  if self.modconfig.pause_focused then
    if #TheFrontEnd.screenstack < 2 then
      SetPause(false)
    end
  end
end

function MiniMapWidgetMz:SetTextureHandle(handle)
  self.map.inst.ImageWidget:SetTextureHandle( handle )
end

function MiniMapWidgetMz:OnZoomIn(  )
  if self.shown then
    if TheInput:IsKeyDown(KEY_CTRL) and not TheInput:IsKeyDown(KEY_SHIFT) and not TheInput:IsKeyDown(KEY_ALT) then
      self.mapsize.w = self.mapsize.w + 25
      self.mapsize.h = self.mapsize.h + 25 * (self.mapsize_orig_h/self.mapsize_orig_w)
      local basesize_tiny = 0.125
      local basesize_tiny_margin = 1
      if self.mapsize.w < self.mapsize_orig_w*basesize_tiny-basesize_tiny_margin then
        self.mapsize.w = self.mapsize_orig_w*basesize_tiny
      end
      if self.mapsize.h < self.mapsize_orig_h*basesize_tiny-basesize_tiny_margin then
        self.mapsize.h = self.mapsize_orig_h*basesize_tiny
      end
      self.map:SetSize(self.mapsize.w, self.mapsize.h)
      local newmappos_x, newmappos_y = self:ResizeMapView()
      self:SetPosition(newmappos_x, newmappos_y)
      self:SetOpen(self.open)
      self:SaveConfigValueMapSize(self.modconfig.mapscale)
      self:SaveConfigValueMapPos(newmappos_x, newmappos_y)
      self:MakeDirty()
    else
      local old_uvscale = self.uvscale
      if self.minimapzoom == 0 then
        self.uvscale = math.min(1.875, (2.0 + self.uvscale)/2)
      end
      self.map:SetUVScale(self.uvscale, self.uvscale)
      self.minimap:Zoom( -1 )
      self.minimapzoom = math.max(0,self.minimapzoom-1)
      if old_uvscale ~= self.uvscale then
        self.mapcenter_gap.x = self.mapcenter_gap.x / 2
        self.mapcenter_gap.y = self.mapcenter_gap.y / 2
      end
      self:ResetOffset()
    end
  end
end

function MiniMapWidgetMz:OnZoomOut( )
  if self.shown then
    if TheInput:IsKeyDown(KEY_CTRL) and not TheInput:IsKeyDown(KEY_SHIFT) and not TheInput:IsKeyDown(KEY_ALT) then
      self.mapsize.w = self.mapsize.w - 25
      self.mapsize.h = self.mapsize.h - 25 * (self.mapsize_orig_h/self.mapsize_orig_w)
      local basesize_tiny = 0.125
      local basesize_tiny_margin = 1
      if self.mapsize.w < self.mapsize_orig_w*basesize_tiny-basesize_tiny_margin then
        self.mapsize.w = self.mapsize_orig_w*basesize_tiny
      end
      if self.mapsize.h < self.mapsize_orig_h*basesize_tiny-basesize_tiny_margin then
        self.mapsize.h = self.mapsize_orig_h*basesize_tiny
      end
      self.map:SetSize(self.mapsize.w, self.mapsize.h)
      local newmappos_x, newmappos_y = self:ResizeMapView()
      self:SetPosition(newmappos_x, newmappos_y)
      self:SetOpen(self.open)
      self:SaveConfigValueMapSize(self.modconfig.mapscale)
      self:SaveConfigValueMapPos(newmappos_x, newmappos_y)
      self:MakeDirty()
    else
      local old_uvscale = self.uvscale
      local old_minimapzoom = self.minimapzoom
      local dozoom = true
      if self.minimapzoom == 0 then
        if self.uvscale - 1 > 0.05 then
          self.uvscale = math.max(1, 2*self.uvscale - 2)
          dozoom = false
        else
          self.uvscale = 1
        end
        self.map:SetUVScale(self.uvscale, self.uvscale)
      end
      if dozoom then
        self.minimap:Zoom( 1 )
        self.minimapzoom = self.minimapzoom+1
      end
      if old_uvscale ~= self.uvscale then
        self.mapcenter_gap.x = self.mapcenter_gap.x * 2
        self.mapcenter_gap.y = self.mapcenter_gap.y * 2
      end
      self:ResetOffset()
    end
  end
end

function MiniMapWidgetMz:UpdateTexture()
  local handle = self.minimap:GetTextureHandle()
  self:SetTextureHandle( handle )
end

function MiniMapWidgetMz:OnUpdate(dt)
  if not self.shown then return end
  if not self.focus then return end
  if not self.map.focus then return end

  if TheInput:IsControlPressed(CONTROL_PRIMARY) and
     TheInput:IsControlPressed(CONTROL_SECONDARY)
  then
    self.mapcenter_gap = Point(0,0)
    self:ResetOffset()
  elseif TheInput:IsControlPressed(CONTROL_PRIMARY) then

    local pos = TheInput:GetScreenPosition()

    if self.lastpos and (self.lastpos.x ~= pos.x or self.lastpos.y ~= pos.y) then
      local hudscale = self.owner.HUD.controls.top_root:GetScale()
      local scrn_w, scrn_h = TheSim:GetScreenSize()
      local mapscale_gap_w = self.adjustvalue*scrn_w/self.mapsize.w /(2^(math.log((-(self.uvscale*(1-0.5))/1+1))/math.log(0.5)-1))
      local mapscale_gap_h = self.adjustvalue*scrn_h/self.mapsize.h /(2^(math.log((-(self.uvscale*(1-0.5))/1+1))/math.log(0.5)-1))
      local scrn_dx = (pos.x - self.lastpos.x) / hudscale.x
      local scrn_dy = (pos.y - self.lastpos.y) / hudscale.y
      local location_gap_dx = mapscale_gap_w * scrn_dx
      local location_gap_dy = mapscale_gap_h * scrn_dy
      self.minimap:Offset(location_gap_dx, location_gap_dy)
      self.mapcenter_gap.x = self.mapcenter_gap.x + location_gap_dx
      self.mapcenter_gap.y = self.mapcenter_gap.y + location_gap_dy
    end

    self.lastpos = pos

  elseif TheInput:IsControlPressed(CONTROL_SECONDARY) then

    local pos = TheInput:GetScreenPosition()

    if self.lastpos and (self.lastpos.x ~= pos.x or self.lastpos.y ~= pos.y) then
      local mappos = self:GetPosition()
      local hudscale = self.owner.HUD.controls.top_root:GetScale()
      local dx = (pos.x - self.lastpos.x) / hudscale.x
      local dy = (pos.y - self.lastpos.y) / hudscale.y
      local new_x
      local new_y
      if self.mapsize.w ~= self.mapsize_view.w then
        new_x = mappos.x + dx/2
      else
        new_x = mappos.x + dx
      end
      if self.mapsize.h ~= self.mapsize_view.h then
        new_y = mappos.y + dy/2
      else
        new_y = mappos.y + dy
      end

      local mapcenter_gap_before_x = self.mapcenter_gap.x
      local mapcenter_gap_before_y = self.mapcenter_gap.y

      new_x, new_y = self:ResizeMapView(new_x, new_y)
      local scrn_w, scrn_h = TheSim:GetScreenSize()
      local mapscale_gap_w = self.adjustvalue*scrn_w/self.mapsize.w  /(2^(math.log((-(self.uvscale*(1-0.5))/1+1))/math.log(0.5)-1))
      local mapscale_gap_h = self.adjustvalue*scrn_h/self.mapsize.h  /(2^(math.log((-(self.uvscale*(1-0.5))/1+1))/math.log(0.5)-1))

      local mapcenter_gap_after_x = self.mapcenter_gap.x
      local mapcenter_gap_after_y = self.mapcenter_gap.y
      local mapcenter_gap_diff_x = (mapcenter_gap_after_x - mapcenter_gap_before_x) / mapscale_gap_w
      local mapcenter_gap_diff_y = (mapcenter_gap_after_y - mapcenter_gap_before_y) / mapscale_gap_h
      new_x = new_x - mapcenter_gap_diff_x
      new_y = new_y - mapcenter_gap_diff_y
      self.map:SetTint(1,1,1,0.5)
      self.bg:SetTint(1,1,1,0.5)
      self.mapcenter_gap.x = self.mapcenter_gap.x - mapcenter_gap_diff_x*mapscale_gap_w
      self.mapcenter_gap.y = self.mapcenter_gap.y - mapcenter_gap_diff_y*mapscale_gap_h
      self:SetPosition(new_x, new_y)
      self:SetOpen(self.open)

      self:SaveConfigValueMapSize(self.mapsize.w)
      self:SaveConfigValueMapPos(new_x, new_y)
      self:MakeDirty()
    end

    self.lastpos = pos

  else
    if self.lastpos ~= nil then
      local newmappos_x, newmappos_y = self:ResizeMapView()
      self:SetPosition(newmappos_x, newmappos_y)
      self.lastpos = nil
      if self.map.focus then
        self.map:SetTint(1,1,1,1)
        self.bg:SetTint(1,1,1,1)
      else
        self.map:SetTint(1,1,1,self.modconfig.map_trans)
        self.bg:SetTint(1,1,1,self.modconfig.bg_trans)
      end
    end
  end
end

function MiniMapWidgetMz:SaveConfigValueMapSize(w)
  self.modconfig.mapscale = w / self.mapsize_orig_w
  self.modconfig:SetModConfigDataFull("Map Size", self.modconfig.mapscale)
end

function MiniMapWidgetMz:SaveConfigValueMapPos(x, y)
  local scrn_w, scrn_h = TheSim:GetScreenSize()
  local hudscale = self.owner.HUD.controls.top_root:GetScale()
  local new_horiz_margin = (scrn_w/hudscale.x/2 - x) - self.mapsize.w/2
  local new_vert_margin = -(y + self.mapsize.h/2)
  self.modconfig.margin_size_x = new_horiz_margin
  self.modconfig.margin_size_y = new_vert_margin
  self.modconfig.position_str = "top_right"
  self.modconfig:SetModConfigDataFull("Horizontal Margin", self.modconfig.margin_size_x)
  self.modconfig:SetModConfigDataFull("Vertical Margin", self.modconfig.margin_size_y)
  self.modconfig:SetModConfigDataFull("Position", self.modconfig.position_str)
end

function MiniMapWidgetMz:Offset(dx,dy)
  self.minimap:Offset(dx,dy)
end

function MiniMapWidgetMz:OnShow()
  if not self.minimap:IsVisible() then
    self.minimap:ToggleVisibility()
  end
  self.minimap:Zoom(-1000)
  self.minimap:Zoom(self.minimapzoom)
  self.map:SetUVScale(self.uvscale, self.uvscale)
  self:ResetOffset()
end

function MiniMapWidgetMz:ResetOffset()
  self.minimap:ResetOffset()
  local scrn_w, scrn_h = TheSim:GetScreenSize()
  local mapscale_gap_w = self.adjustvalue*scrn_w/self.mapsize.w  /(2^(math.log((-(self.uvscale*(1-0.5))/1+1))/math.log(0.5)-1))
  local mapscale_gap_h = self.adjustvalue*scrn_h/self.mapsize.h  /(2^(math.log((-(self.uvscale*(1-0.5))/1+1))/math.log(0.5)-1))
  local location_gap_x = self.mappos_gap.x*mapscale_gap_w + self.mapcenter_gap.x
  local location_gap_y = self.mappos_gap.y*mapscale_gap_h + self.mapcenter_gap.y
  self.minimap:Offset(location_gap_x, location_gap_y)
end

function MiniMapWidgetMz:OnHide()
  if self.minimap:IsVisible() then
    self.minimap:ToggleVisibility()
  end
  self.minimap:Zoom(-1000)
  self.minimap:Zoom(self.mapscreenzoom)
  self.map:SetUVScale(self.uvscale, self.uvscale)
  self:ResetOffset()
end

function MiniMapWidgetMz:ToggleVisibility()
  if self:IsVisible() then
    self:Hide()
  else
    self:Show()
  end
end

return MiniMapWidgetMz
