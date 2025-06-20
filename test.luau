repeat task.wait() until game:IsLoaded()

-- // Services and Core Variables
local Plrs = cloneref(game:GetService("Players"))
local Plr = Plrs.LocalPlayer or Plrs.PlayerAdded:Wait()
local PGui = Plr:WaitForChild("PlayerGui")
local RS = cloneref(game:GetService("ReplicatedStorage"))
local MS = cloneref(game:GetService("MarketplaceService"))
local Asset = MS:GetProductInfo(game.PlaceId)

-- // Game PIDs
local PIDs = { GAME = 12900046592 }

if game.PlaceId ~= PIDs.GAME then return end

-- // Wait for Game to Start (The Correct Way)
local StartButton = nil
pcall(function()
    local Bottom = PGui:WaitForChild("Bottom").Frame
    for i, v in pairs(Bottom:GetChildren()) do
        if v.Position == UDim2.fromScale(0.5, 1) then
            for a, b in pairs(v:GetChildren()) do
                if b:IsA('Frame') and b.Size == UDim2.fromScale(1, 0) and b.Size == UDim2.fromOffset(0, 56) then
                    for c, d in pairs(b:GetChildren()) do
                        if d.LayoutOrder == 1 and d:IsA('TextButton') then
                            local txt = d:FindFirstChild('TextLabel')
                            if txt and txt.Text and txt.Text == 'Start' then
                                StartButton = d
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Wait until the button is destroyed (its Parent becomes nil)
if StartButton then
    -- Using warn() is better for this than Library:Notify, since the library isn't loaded yet.
    warn("COOLSTUFF: Waiting for the round to start...")
    repeat task.wait(1) until not StartButton or not StartButton.Parent
    warn("COOLSTUFF: Round started, loading script.")
end

--// UI Lib Init (Load AFTER waiting for the game to start)
local Repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

if getgenv().script_LOADED == true then
    return Library:Notify("Script already loaded!", 5)
end
pcall(function() getgenv().script_LOADED = true end)

-- // Game Flags and Remotes (Now safe to define)
local Flags = { Auto = { Ability = { Universal = nil, Boss = nil, Special = { Bulma = { Enabled = nil, Used = false }}}, BR = { Enabled = nil }}}
local Remotes = {
    CardAction = RS.Remotes:WaitForChild("CardAction"),
    Ability = RS.Remotes:WaitForChild("Ability"),
    Auto = RS.Remotes:WaitForChild("ToggleAutoUse")
}
local Slots = Plr:WaitForChild('Slots')

-- // Tables
local AbilityList = {}
local BossRushCards = {}

-- // Functions
function fireClick(guiObject)
    if not guiObject then return false end
    pcall(function()
        for _, co in ipairs(getconnections(guiObject.InputBegan)) do
            if co.Enabled then co:Fire({UserInputType = Enum.UserInputType.MouseButton1}) end
        end
    end)
    pcall(function()
        for _, co in ipairs(getconnections(guiObject.Activated)) do
            if co.Enabled then co:Fire() end
        end
    end)
    return true
end

local blacklist = {["Auto"] = {["Ability"] = {["Special"] = {["Bulma"] = {["Used"] = true}}}}}
local function cancelThreadsInTable(tbl)
    for key, value in pairs(tbl) do
        if type(value) == 'table' then
            cancelThreadsInTable(value)
        elseif typeof(value) == 'thread' then
            task.cancel(value)
        end
    end
end

local function Refresh(path, list, typeKey, valueKey)
    if typeKey == "table" then
        table.clear(list)
        for i, v in pairs(path:GetChildren()) do
            table.insert(list, v[valueKey])
        end
    end
end

-- // Callbacks
local function autoSelectCard()
    while Toggles.BR_Toggle.Value do
        task.wait(0.25)
        local pG = PGui:FindFirstChild("Prompt")
        if pG and pG.Parent then
            local cB, hP, bCB, bCI = nil, 0, nil, nil
            for _, d in ipairs(pG:GetDescendants()) do
                if d:IsA("TextButton") then
                    if d.Position == UDim2.fromScale(0.5, 0.5) then
                        local tS = d:FindFirstChild("TextLabel") or d
                        if tS and tS.Text and tS.Text:find("Choose a card", 1, true) then cB = d end
                    else
                        local tCF = d:FindFirstChild("Frame")
                        if tCF then
                            local tL = tCF:FindFirstChildOfClass("TextLabel")
                            if tL then
                                local cN = tL.Text
                                local p = Options.CardPriorities[cN] or 0
                                if p > hP then
                                    hP, bCB = p, d
                                end
                            end
                        end
                    end
                end
            end
            if bCB and cB then
                Library:Notify("Found card: " .. bCB.Frame.TextLabel.Text .. " (Priority: " .. hP .. ")", 3)
                fireClick(bCB)
                task.wait(0.5)
                fireClick(cB)
                repeat task.wait() until not PGui:FindFirstChild("Prompt")
            end
        end
    end
end

local function AutoAbility()
    while Toggles.G_AutoAbility.Value do
        pcall(function()
            if Toggles.G_AutoAbility.Value and Options.G_AbilityList.Value then
                for unitName, isSelected in pairs(Options.G_AbilityList.Value) do
                    if isSelected then
                        local towerInstance = workspace.Towers:FindFirstChild(unitName)
                        if towerInstance then Remotes.Auto:FireServer(towerInstance, 1, true) end
                    end
                end
            end
        end)
        task.wait(3)
    end
end

local function Bulma()
    local wishMapping = {Power = 1, Time = 2, Wealth = 3}
    while Toggles.G_Special_Bulma.Value do
        if not Flags.Auto.Ability.Special.Bulma.Used then
            local bulma = workspace.Towers:FindFirstChild("Bulma")
            if bulma then
                local wishMeter = bulma:FindFirstChild("Meters") and bulma.Meters:FindFirstChild("Wish Balls")
                if wishMeter then
                    local currentValue = wishMeter:GetAttribute("Value")
                    local maxValue = wishMeter:GetAttribute("MaxValue")
                    if currentValue >= maxValue and not bulma:WaitForChild('Stunned').Value then
                        local chosenWishName = Options.G_Special_BulmaWish.Value
                        local wishNumber = wishMapping[chosenWishName]
                        if wishNumber then
                            Remotes.Ability:InvokeServer(bulma, 1)
                            task.wait(4)
                            Remotes.Ability:InvokeServer(bulma, wishNumber)
                            task.wait(2)
                            Flags.Auto.Ability.Special.Bulma.Used = true
                        end
                    end
                end
            end
        end
        if Flags.Auto.Ability.Special.Bulma.Used and PGui:FindFirstChild("EndGameUI") then
            Flags.Auto.Ability.Special.Bulma.Used = false
        end
        task.wait(1)
    end
end

-- // Import Boss Rush Cards
local s, r = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/buang5516/buanghub/refs/heads/main/ALS/BossRushCards.lua"))() end)
if s then BossRushCards = r else Library:Notify("Failed to get Boss Rush Cards data.", 5) end

-- // UI Library Setup
local Window = Library:CreateWindow({Title = "coolstuff", Footer = "mehwnei | als#broken", AutoShow = false})
local Tabs = {
    Main = Window:AddTab("oi", "cog"),
    Game = Window:AddTab('Game', 'gamepad'),
    BossRush = Window:AddTab('Boss Rush', 'skull'),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}

-- Tabs, etc.
local M_LTB = Tabs.Main:AddLeftTabbox()
T1:AddLabel("<b>User</b>")
T1:AddLabel({
    Text = "Executor: "..identifyexecutor() or "N/A",
    DoesWrap = true
})
T1:AddDivider()
T1:AddLabel("<b>Game</b>")
T1:AddLabel({
    Text = "Name: "..Asset.Name.."\nID: "..game.PlaceId.."\nPlayers: "..#Players:GetPlayers().."\nMax Players: "..Players.MaxPlayers.."",
    DoesWrap = true
})
T2:AddLabel("<b>mega upd 6/19/25</b>")
T2:AddLabel({
    Text = "- tabs<br/> automation (fuck ts)<br/>    + ability (trash ngl dont expect ts to work)<br/> +main (ts)\n<b>6/18/25</b><br/> -exist",
    DoesWrap = true
})

local teleportConnection = nil
Tabs.Main:AddLeftGroupbox('Misc', 'wrench'):AddCheckbox("Main_AutoExec", {
    Text = "Auto Execute", Default = false,
    Callback = function(Value)
        Toggles.Main_AutoExec.Value = Value
        if Value and not teleportConnection then
            teleportConnection = Plr.OnTeleport:Connect(function(State) queueteleport(getgenv().COOLSTUFF_SOURCE) end)
        elseif not Value and teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
    end
})

local BR_LTB = Tabs.BossRush:AddLeftTabbox("Settings", "wrench")
local BR_T1, BR_T2 = BR_LTB:AddTab("General"), BR_LTB:AddTab("Priorities")
Options.CardPriorities = Options.CardPriorities or {}
BR_T1:AddCheckbox("BR_Toggle", { Text = "Auto Select Card", Default = false,
    Callback = function(Value)
        Toggles.BR_Toggle.Value = Value
        if Value and not Flags.Auto.BR.Enabled then Flags.Auto.BR.Enabled = task.spawn(autoSelectCard)
        elseif not Value and Flags.Auto.BR.Enabled then task.cancel(Flags.Auto.BR.Enabled); Flags.Auto.BR.Enabled = nil end
    end
})

local cpi = {}
for _, cN in ipairs(BossRushCards) do
    cpi[cN] = BR_T2:AddInput(cN, { Text = cN, Default = Options.CardPriorities[cN] or 0, Numeric = true, AllowEmpty = false, MaxLength = 3, Placeholder = "0-100", EmptyReset = "0",
        Callback = function(v)
            local nP = tonumber(v) or 0
            if nP > 100 then nP = 100 elseif nP < 0 then nP = 0 end
            if nP == 0 then Options.CardPriorities[cN] = 0; return end
            for oC, oP in pairs(Options.CardPriorities) do
                if oC ~= cN and oP == nP then
                    Library:Notify("Priority " .. nP .. " is already used by " .. oC, 5)
                    Options.CardPriorities[cN] = 0
                    task.delay(.1, function() if cpi[cN] then cpi[cN]:SetValue(0) end end)
                    return
                end
            end
            Options.CardPriorities[cN] = nP
        end
    })
    if Options.CardPriorities[cN] == nil then Options.CardPriorities[cN] = 0 end
end

local G_LTB = Tabs.Game:AddLeftTabbox()
local G_T1, G_T2 = G_LTB:AddTab("Abilities"), G_LTB:AddTab("Special")
local ABL = G_T1:AddDropdown("G_AbilityList", { Values = AbilityList, Default = {}, Multi = true, Text = "Select Ability",
    Callback = function(Value) Options.G_AbilityList.Value = Value end
})
G_T1:AddButton({ Text = "Refresh", Func = function() Refresh(Slots, AbilityList, 'table', 'Value'); ABL:SetValues(AbilityList) end,})
G_T1:AddCheckbox("G_AutoAbility", { Text = "Auto Ability", Default = false,
    Callback = function(Value)
        Toggles.G_AutoAbility.Value = Value
        if Value and not Flags.Auto.Ability.Universal then Flags.Auto.Ability.Universal = task.spawn(AutoAbility)
        elseif not Value then
            if Flags.Auto.Ability.Universal then task.cancel(Flags.Auto.Ability.Universal); Flags.Auto.Ability.Universal = nil end
            if Options.G_AbilityList.Value then
                for unitName, isSelected in pairs(Options.G_AbilityList.Value) do
                    if isSelected then local towerInstance = workspace.Towers:FindFirstChild(unitName) if towerInstance then Remotes.Auto:FireServer(towerInstance, 1, false) end end
                end
            end
        end
    end
})
G_T2:AddDropdown("G_Special_BulmaWish", { Values = {'Power', 'Time', 'Wealth'}, Default = "Power", Multi = false, Text = "Select Wish",
    Callback = function(Value) Options.G_Special_BulmaWish.Value = Value end
})
G_T2:AddCheckbox("G_Special_Bulma", { Text = "Auto Use Bulma Wish", Default = false,
    Callback = function(Value)
        Toggles.G_Special_Bulma.Value = Value
        if Value and not Flags.Auto.Ability.Special.Bulma.Enabled then Flags.Auto.Ability.Special.Bulma.Enabled = task.spawn(Bulma)
        elseif not Value and Flags.Auto.Ability.Special.Bulma.Enabled then task.cancel(Flags.Auto.Ability.Special.Bulma.Enabled); Flags.Auto.Ability.Special.Bulma.Enabled = nil end
    end
})

local originalUnload = Library.Unload
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddButton("Unload", function()
    getgenv().script_LOADED = false
    if teleportConnection then teleportConnection:Disconnect(); teleportConnection = nil end
    cancelThreadsInTable(Flags)
    originalUnload(Library)
end)

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(v) Library.KeybindFrame.Visible = v end
})
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(v) Library.ShowCustomCursor = v end
})
MenuGroup:AddDropdown("NotificationSide", {
    Values = {"Left", "Right"},
    Default = "Right",
    Text = "Notification Side",
    Callback = function(v) Library:SetNotifySide(v) end
})
MenuGroup:AddDropdown("DPIDropdown", {
    Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"},
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(v)
        v = v:gsub("%%", "")
        local DPI = tonumber(v)
        Library:SetDPIScale(DPI)
    end
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("coolstuff")
SaveManager:SetFolder("coolstuff/als-autocard")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

if #Slots:GetChildren() > 0 then
    Refresh(Slots, AbilityList, 'table', 'Value')
    ABL:SetValues(AbilityList)
else
    local slotConnection = nil
    slotConnection = Slots.ChildAdded:Connect(function(child)
        if #Slots:GetChildren() >= 6 then
            Refresh(Slots, AbilityList, 'table', 'Value')
            ABL:SetValues(AbilityList)
            if slotConnection then
                slotConnection:Disconnect()
                slotConnection = nil
            end
        end
    end)
end

SaveManager:LoadAutoloadConfig()
