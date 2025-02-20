-- ChupaPotoCoin: Addon para gestionar penalizaciones en raids

local addonName, CPC = ...
CPC.frame = CreateFrame("Frame")
CPC.players = {}
CPC.history = {}
CPC.today = date("%Y-%m-%d")

local SOUND_ALERT = 8959 -- Sonido de alerta básico

-- Crear interfaz gráfica
CPC.UIFrame = CreateFrame("Frame", "CPC_UIFrame", UIParent, "BasicFrameTemplateWithInset")
CPC.UIFrame:SetSize(350, 500)
CPC.UIFrame:SetPoint("CENTER")
CPC.UIFrame.title = CPC.UIFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
CPC.UIFrame.title:SetPoint("TOP", 0, -6)
CPC.UIFrame.title:SetText("ChupaPotoCoin ")
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
playerDropdown:SetSize(150, 32)  -- Ajustar el tamaño del menú desplegable

-- Ajustar la posición de la flecha de despliegue
_G[playerDropdown:GetName() .. "Button"]:SetPoint("RIGHT", playerDropdown, "RIGHT", -10, 0)

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
assignButton1:SetSize(150, 30)
assignButton1:SetPoint("TOP", 0, -80)
assignButton1:SetText("1 ChuPaPotoCoin")
assignButton1:SetScript("OnClick", function()
    if selectedPlayer then
        CPC:AddPenalty(selectedPlayer, 1)
    else
        print("Selecciona un jugador.")
    end
end)

local assignButton2 = CreateFrame("Button", nil, CPC.UIFrame, "GameMenuButtonTemplate")
assignButton2:SetSize(150, 30)
assignButton2:SetPoint("TOP", 0, -120)
assignButton2:SetText("2 ChupaPotoCoins")
assignButton2:SetScript("OnClick", function()
    if selectedPlayer then
        CPC:AddPenalty(selectedPlayer, 2)
    else
        print("Selecciona un jugador.")
    end
end)

local assignButton3 = CreateFrame("Button", nil, CPC.UIFrame, "GameMenuButtonTemplate")
assignButton3:SetSize(150, 30)
assignButton3:SetPoint("TOP", 0, -160)
assignButton3:SetText("3 ChuPaPotoCoins")
assignButton3:SetScript("OnClick", function()
    if selectedPlayer then
        CPC:AddPenalty(selectedPlayer, 3)
    else
        print("Selecciona un jugador.")
    end
end)

-- Botón para reiniciar los puntos de hoy
local resetButton = CreateFrame("Button", nil, CPC.UIFrame, "GameMenuButtonTemplate")
resetButton:SetSize(150, 30)
resetButton:SetPoint("TOP", 0, -200)
resetButton:SetText("Reiniciar Puntos de Hoy")
resetButton:SetScript("OnClick", function()
    if selectedPlayer then
        -- Mostrar un mensaje de confirmación
        StaticPopupDialogs["CPC_CONFIRM_RESET"] = {
            text = "¿Estás seguro de que deseas reiniciar los puntos de hoy de " .. selectedPlayer .. "?",
            button1 = "Sí",
            button2 = "No",
            OnAccept = function()
                CPC:ResetToday(selectedPlayer)
                SendChatMessage("Los puntos de hoy de " .. selectedPlayer .. " han sido reiniciados.", "RAID")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,  -- Evitar conflictos con otros diálogos
        }
        StaticPopup_Show("CPC_CONFIRM_RESET")
    else
        print("Selecciona un jugador.")
    end
end)
-- Crear ScrollFrame para la lista de jugadores
CPC.ScrollFrame = CreateFrame("ScrollFrame", nil, CPC.UIFrame, "UIPanelScrollFrameTemplate")
CPC.ScrollFrame:SetSize(285, 250)
CPC.ScrollFrame:SetPoint("TOP", 0, -240)

-- Crear un Frame para contener los textos dentro del ScrollFrame
CPC.ScrollFrame.Content = CreateFrame("Frame", nil, CPC.ScrollFrame)
CPC.ScrollFrame.Content:SetSize(320, 250)
CPC.ScrollFrame:SetScrollChild(CPC.ScrollFrame.Content)

-- Inicializar la tabla de líneas
CPC.ScrollFrame.Content.lines = {}

-- Función para actualizar la lista de jugadores
local function UpdateUI()
    -- Limpiar el contenido anterior
    for i = 1, #CPC.ScrollFrame.Content.lines do
        CPC.ScrollFrame.Content.lines[i]:Hide()
    end

    local offset = 0
    for player, count in pairs(CPC.players) do
        local historical = 0
        for _, record in ipairs(CPC.history) do
            if record.player == player then
                historical = historical + record.amount
            end
        end

        -- Crear o reutilizar una línea de texto
        local line = CPC.ScrollFrame.Content.lines[offset + 1]
        if not line then
            line = CPC.ScrollFrame.Content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            line:SetPoint("TOPLEFT", 10, -20 * offset)
            CPC.ScrollFrame.Content.lines[offset + 1] = line
        end

        -- Establecer el texto de la línea
        line:SetText(player .. " - Hoy: " .. count .. " - Histórico: " .. historical)
        line:Show()

        offset = offset + 1
    end

    -- Ajustar el tamaño del contenido del ScrollFrame
    CPC.ScrollFrame.Content:SetHeight(20 * offset)
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
    
    -- Calcular puntos restantes
    local puntosRestantes = 6 - self.players[player]
    
    -- Construir el mensaje
    local mensaje = player .. " ha ganado " .. amount .. " ChupaPotoCoin(s). "
    if self.players[player] >= 6 then
        mensaje = mensaje .. "¡Debe abandonar la raid! Ha acumulado 6 ChupaPotoCoins."
    else
        mensaje = mensaje .. "Le quedan " .. puntosRestantes .. " puntos antes de ser expulsado."
    end
    
    -- Notificar en banda
    SendChatMessage(mensaje, "RAID_WARNING")
    PlaySound(SOUND_ALERT, "Master")
    
    -- Expulsar si alcanza o supera los 6 puntos
    if self.players[player] >= 6 then
        UninviteUnit(player)
    end
    
    self:SaveData()
    UpdateUI()
end

-- Comandos
SLASH_CPC1 = "/cpc"
SlashCmdList["CPC"] = function(msg)
    -- Verificar si el mensaje es "/cpc reset all"
    if msg:lower() == "reset all" then
        -- Mostrar un mensaje de confirmación
        StaticPopupDialogs["CPC_CONFIRM_RESET_ALL"] = {
            text = "¿Estás seguro de que deseas reiniciar TODOS los puntos y el historial?",
            button1 = "Sí",
            button2 = "No",
            OnAccept = function()
                CPC.players = {}  -- Reiniciar puntos de hoy
                CPC.history = {}  -- Borrar historial
                CPC_SavedData.players = {}
                CPC_SavedData.history = {}
                print("Todos los puntos y el historial han sido reiniciados.")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,  -- Evitar conflictos con otros diálogos
        }
        StaticPopup_Show("CPC_CONFIRM_RESET_ALL")
        return
    end

    -- Verificar si el mensaje es "/cpc help"
    if msg:lower() == "help" then
        print("Comandos disponibles:")
        print("|cff00ff00/cpc [jugador] [cantidad]|r: Asignar monedas a un jugador.")
        print("|cff00ff00/cpcui|r: Mostrar/ocultar la interfaz.")
        print("|cff00ff00/cpcreset [jugador]|r: Reiniciar los puntos de hoy de un jugador.")
        print("|cff00ff00/cpc reset all|r: Reiniciar TODOS los puntos y el historial.")
        print("|cff00ff00/cpc help|r: Mostrar esta lista de comandos.")
        return
    end

    -- Si no es un comando especial, intentar asignar monedas
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
