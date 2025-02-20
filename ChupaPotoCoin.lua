-- ChupaPotoCoin: Addon para gestionar penalizaciones en raids

local addonName, CPC = ...
CPC.frame = CreateFrame("Frame")
CPC.players = {}
CPC.history = {}
CPC.today = date("%Y-%m-%d")

local SOUND_ALERT = 8959 -- Sonido de alerta básico

-- Crear interfaz gráfica
CPC.UIFrame = CreateFrame("Frame", "CPC_UIFrame", UIParent, "BasicFrameTemplateWithInset")
CPC.UIFrame:SetSize(350, 400)
CPC.UIFrame:SetPoint("CENTER")
CPC.UIFrame.title = CPC.UIFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
CPC.UIFrame.title:SetPoint("TOP", 0, -10)
CPC.UIFrame.title:SetText("ChupaPotoCoin Tracker")
CPC.UIFrame:Hide()

-- Hacer la interfaz movible
CPC.UIFrame:SetMovable(true)
CPC.UIFrame:EnableMouse(true)
CPC.UIFrame:RegisterForDrag("LeftButton")
CPC.UIFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
CPC.UIFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Dropdown para seleccionar jugador
local playerDropdown = CreateFrame("Frame", "CPC_PlayerDropdown", CPC.UIFrame, "UIDropDownMenuTemplate")
playerDropdown:SetPoint("TOPLEFT", 10, -30)

local selectedPlayer = nil
local function UpdateDropdown()
    if IsInRaid() then
        UIDropDownMenu_Initialize(playerDropdown, function(self, level, menuList)
            for i = 1, GetNumGroupMembers() do
                local name, _, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i)
                if name then
                    UIDropDownMenu_AddButton({
                        text = name,
                        func = function()
                            selectedPlayer = name
                            UIDropDownMenu_SetText(playerDropdown, name)
                        end
                    })
                end
            end
        end)
    elseif IsInGroup() then
        UIDropDownMenu_Initialize(playerDropdown, function(self, level, menuList)
            for i = 1, GetNumGroupMembers() do
                local name = UnitName("party" .. i)
                if name then
                    UIDropDownMenu_AddButton({
                        text = name,
                        func = function()
                            selectedPlayer = name
                            UIDropDownMenu_SetText(playerDropdown, name)
                        end
                    })
                end
            end
        end)
    else
        print("No estás en una banda o grupo.")
    end
end

playerDropdown:SetScript("OnMouseDown", function()
    UpdateDropdown()
    ToggleDropDownMenu(1, nil, playerDropdown, "cursor", 0, 0)
end)

-- Botones para asignar monedas (alineados verticalmente al medio)
local assignButton1 = CreateFrame("Button", nil, CPC.UIFrame, "GameMenuButtonTemplate")
assignButton1:SetSize(120, 30)
assignButton1:SetPoint("TOP", 0, -80)
assignButton1:SetText("Asignar 1 Moneda")
assignButton1:SetScript("OnClick", function()
    if selectedPlayer then
        CPC:AddPenalty(selectedPlayer, 1)
    else
        print("Selecciona un jugador.")
    end
end)

local assignButton2 = CreateFrame("Button", nil, CPC.UIFrame, "GameMenuButtonTemplate")
assignButton2:SetSize(120, 30)
assignButton2:SetPoint("TOP", 0, -120)
assignButton2:SetText("Asignar 2 Monedas")
assignButton2:SetScript("OnClick", function()
    if selectedPlayer then
        CPC:AddPenalty(selectedPlayer, 2)
    else
        print("Selecciona un jugador.")
    end
end)

local assignButton3 = CreateFrame("Button", nil, CPC.UIFrame, "GameMenuButtonTemplate")
assignButton3:SetSize(120, 30)
assignButton3:SetPoint("TOP", 0, -160)
assignButton3:SetText("Asignar 3 Monedas")
assignButton3:SetScript("OnClick", function()
    if selectedPlayer then
        CPC:AddPenalty(selectedPlayer, 3)
    else
        print("Selecciona un jugador.")
    end
end)

-- Botón para reiniciar los puntos de hoy
local resetButton = CreateFrame("Button", nil, CPC.UIFrame, "GameMenuButtonTemplate")
resetButton:SetSize(120, 30)
resetButton:SetPoint("TOP", 0, -200)
resetButton:SetText("Reiniciar Puntos de Hoy")
resetButton:SetScript("OnClick", function()
    if selectedPlayer then
        CPC:ResetToday(selectedPlayer)
        SendChatMessage("Los puntos de hoy de " .. selectedPlayer .. " han sido reiniciados.", "RAID")
    else
        print("Selecciona un jugador.")
    end
end)

-- Crear lista de jugadores
CPC.UIList = CreateFrame("ScrollingMessageFrame", nil, CPC.UIFrame)
CPC.UIList:SetSize(320, 250)
CPC.UIList:SetPoint("TOP", 0, -240)
CPC.UIList:SetFontObject("GameFontNormal")
CPC.UIList:SetJustifyH("LEFT")
CPC.UIList:SetFading(false)
CPC.UIList:SetMaxLines(50)

local function UpdateUI()
    CPC.UIList:Clear()
    for player, count in pairs(CPC.players) do
        local historical = 0
        for _, record in ipairs(CPC.history) do
            if record.player == player then
                historical = historical + record.amount
            end
        end
        CPC.UIList:AddMessage(player .. " - Hoy: " .. count .. " - Histórico: " .. historical)
    end
end

-- Cargar datos guardados
function CPC:LoadData()
    if CPC_SavedData then
        self.history = CPC_SavedData.history or {}
        if CPC_SavedData.lastReset ~= self.today then
            self.players = {}
            CPC_SavedData.lastReset = self.today
        else
            self.players = CPC_SavedData.players or {}
        end
    else
        CPC_SavedData = {players = {}, history = {}, lastReset = self.today}
    end
end

-- Guardar datos
function CPC:SaveData()
    CPC_SavedData.players = self.players
    CPC_SavedData.history = self.history
end

-- Resetear datos de hoy
function CPC:ResetToday(player)
    if player then
        self.players[player] = nil
        print("Se han reseteado los puntos de hoy para " .. player)
    else
        self.players = {}
        print("Se han reseteado los puntos de hoy para todos los jugadores.")
    end
    self:SaveData()
    UpdateUI()
end

-- Agregar una penalización
function CPC:AddPenalty(player, amount)
    if not self.players[player] then
        self.players[player] = 0
    end
    
    self.players[player] = self.players[player] + amount
    
    -- Registrar en historial
    table.insert(self.history, {date = self.today, player = player, amount = amount})
    
    -- Notificar en banda
    SendChatMessage(player .. " ha ganado " .. amount .. " ChupaPotoCoin(s)!", "RAID_WARNING")
    PlaySound(SOUND_ALERT, "Master")
    
    -- Expulsar si llega a 6
    if self.players[player] >= 6 then
        SendChatMessage(player .. " debe abandonar la raid. Ha acumulado 6 ChupaPotoCoins!", "RAID_WARNING")
        UninviteUnit(player)
    end
    
    self:SaveData()
    UpdateUI()
end

-- Comandos
SLASH_CPC1 = "/cpc"
SlashCmdList["CPC"] = function(msg)
    local player, amount = msg:match("(%S+)%s+(%d+)")
    amount = tonumber(amount)
    if player and amount then
        CPC:AddPenalty(player, amount)
    else
        print("Uso: /cpc [jugador] [cantidad]")
    end
end

SLASH_CPCUI1 = "/cpcui"
SlashCmdList["CPCUI"] = function()
    if CPC.UIFrame:IsShown() then
        CPC.UIFrame:Hide()
    else
        UpdateDropdown()  -- Actualizar la lista de jugadores
        UpdateUI()        -- Actualizar la lista de penalizaciones
        CPC.UIFrame:Show()
    end
end

SLASH_CPCRESET1 = "/cpcreset"
SlashCmdList["CPCRESET"] = function(msg)
    if msg and msg ~= "" then
        CPC:ResetToday(msg)
    else
        CPC:ResetToday()
    end
end

-- Inicialización
CPC.frame:RegisterEvent("PLAYER_LOGIN")
CPC.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
CPC.frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        CPC:LoadData()
    elseif event == "GROUP_ROSTER_UPDATE" then
        UpdateDropdown()  -- Actualizar la lista de jugadores cuando cambia la banda
    end
end)
