local Conf = {
    Width = 100,
    Height = 16,
    Font = "Fonts\\FRIZQT__.TTF",
    FontSize = 12,
    Delay = 0.1
}

local PowerBarColor = PowerBarColor
local select = select
local UnitPowerType = UnitPowerType
local UnitClass = UnitClass
local UnitPower = UnitPower

local Core = CreateFrame("StatusBar", nil, UIParent)
Core:RegisterEvent("PLAYER_LOGIN")
Core:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
Core:RegisterEvent("PLAYER_REGEN_DISABLED")
Core:RegisterEvent("PLAYER_REGEN_ENABLED")

Core:SetScript(
    "OnEvent",
    function(self, event, ...)
        return self[event](self, ...)
    end
)

Core:SetMovable(false)
Core:EnableMouse(true)
Core:RegisterForDrag("LeftButton")
Core:SetScript("OnDragStart", Core.StartMoving)
Core:SetScript("OnDragStop", Core.StopMovingOrSizing)

Core:SetScript(
    "OnMouseDown",
    function(self, button)
        if button == "LeftButton" and not self.isMoving then
            self:StartMoving()
            self.isMoving = true
        end
    end
)
Core:SetScript(
    "OnMouseUp",
    function(self, button)
        if button == "LeftButton" and self.isMoving then
            self:StopMovingOrSizing()
            self.isMoving = false

            BarPositionX = Core:GetLeft()
            BarPositionY = Core:GetTop()
        end
    end
)
Core:SetScript(
    "OnHide",
    function(self)
        if (self.isMoving) then
            self:StopMovingOrSizing()
            self.isMoving = false
        end
    end
)

SLASH_LOCK1 = "/lockFRB"

SlashCmdList["LOCK"] = function()
    if Core:IsMovable() then
        Core:SetMovable(false)
        print("Position locked")
    else
        Core:SetMovable(true)
        print("Position unlocked")
    end
end

function Core:CreateEnergyBar()
    local x = 0
    local y = Conf.Height
    if BarPositionX then
        x = BarPositionX
    end
    if BarPositionY then
        y = BarPositionY
    end

    self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y - Conf.Height)
    self:SetSize(Conf.Width, Conf.Height)
    self:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    self:SetStatusBarColor(255, 255, 0)

    self.bg = self:CreateTexture(nil, "BACKGROUND")
    self.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    self.bg:SetAllPoints()
    self.bg:SetVertexColor(0, 0, 0, 1)

    self.Text = self:CreateFontString(nil, "OVERLAY")
    self.Text:SetPoint("LEFT", self, "LEFT", 2, 0)
    self.Text:SetFont(Conf.Font, Conf.FontSize, "OUTLINE")
    self.Text:SetShadowOffset(1, -1)
    self.Text:SetTextColor(1, 1, 1)
end

function Core:PLAYER_LOGIN()
    if select(2, UnitClass("player")) ~= "DRUID" then
        self:UnregisterEvent("PLAYER_LOGIN")
        return
    end
    print('FRB loaded')
    self:RegisterEvent("UNIT_MAXENERGY")
    self:CreateEnergyBar()
    Core:Hide()
    self:SetMinMaxValues(0, 100)
    self:SetScript("OnUpdate", self.OnUpdate)

    local index = GetShapeshiftForm(true)
    if index == 3 then
        Core:Show()
    end
end

function Core:UPDATE_SHAPESHIFT_FORM()
    local index = GetShapeshiftForm(true)
    if index == 3 then
        Core:Show()
    else
        Core:Hide()
    end
end

function Core:PLAYER_REGEN_DISABLED()
    local index = GetShapeshiftForm(true)
    if index == 3 then
        Core:Show()
    else
        Core:Hide()
    end
end

function Core:PLAYER_REGEN_ENABLED()
    Core:Hide()
end

local Update = 0
function Core:OnUpdate(elapsed)
    Update = Update + elapsed
    if Update > Conf.Delay then
        self:SetValue(UnitPower("player"))
        self.Text:SetText(UnitPower("player"))
        Update = 0
    end
end

function Core:UNIT_MAXENERGY(UnitID)
    if UnitID ~= "player" then
        return
    end
    self:SetMinMaxValues(0, UnitPowerMax("player"))
end
