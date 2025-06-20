repeat task.wait() until game:IsLoaded()

-- // Variables
local PIDs = {
    W1 = 12886143095,
    W2 = 18583778121,
    GAME = 12900046592,
    AFK = 14368918515,
}

-- // Services
local queueteleport = queue_on_teleport

local Plrs = cloneref(game:GetService("Players"))
local Plr = Plrs.LocalPlayer or Plrs.PlayerAdded:Wait()
local PGui = Plr:WaitForChild("PlayerGui")

local RS = cloneref(game:GetService("ReplicatedStorage"))
local MS = cloneref(game:GetService("MarketplaceService"))
local Asset = MS:GetProductInfo(game.PlaceId)

--// UI Lib Init
local Repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

if getgenv().script_LOADED == true then
    return Library:Notify("Script already loaded!", 5)
end

if game.PlaceId ~= PIDs.GAME then
    return
end

pcall(function() getgenv().script_LOADED = true end)

-- // Game Flags
local Flags = {
    Auto = {
       Ability = {
        Universal = nil,
        Boss = nil,
        Special = {
            Bulma = {
                Enabled = nil,
                Used = false
            }
        }
       },
       BR = {
        Enabled = nil,
       }
    }
}

-- // PIDs.Game Varibles
local PATH = RS.Remotes
local Remotes = {
    CardAction = PATH.CardAction,
    Ability = PATH.Ability,
    Auto = PATH.ToggleAutoUse
}

-- // Tables
local AbilityList = {}
local BossRushCards = {}

-- // Functions
    -- // Holder
function fireClick(guiObject)
    if not guiObject then return false end
    if not getconnections then
        Library:Notify("Executor does not support required function!", 5)
        return false
    end
    pcall(function()
        local c = getconnections(guiObject.InputBegan)
        for _, co in ipairs(c) do
            if co.Enabled then
                co:Fire({UserInputType = Enum.UserInputType.MouseButton1})
            end
        end
    end)
    pcall(function()
        local c = getconnections(guiObject.Activated)
        if #c > 0 then
            for _, co in ipairs(c) do
                if co.Enabled then
                    co:Fire()
                end
            end
            return true
        end
    end)
    return false
end

local blacklist = {
    ["Auto"] = {
        ["Ability"] = {
            ["Special"] = {
                ["Bulma"] = {
                    ["Used"] = true
                }
            }
        }
    }
}

local function cancelThreadsInTable(tbl, currentPath, blacklistedPath)
    currentPath = currentPath or {} -- Initialize current path for tracking
    blacklistedPath = blacklistedPath or blacklist -- Pass the blacklist down

    for key, value in pairs(tbl) do
        local newPath = table.clone(currentPath)
        table.insert(newPath, key)
        local isBlacklisted = false
        local currentBlacklistCheck = blacklistedPath
        for i, pathPart in ipairs(newPath) do
            if type(currentBlacklistCheck) == 'table' and currentBlacklistCheck[pathPart] then
                currentBlacklistCheck = currentBlacklistCheck[pathPart]
                if i == #newPath and currentBlacklistCheck == true then
                    isBlacklisted = true
                    break
                end
            else
                break
            end
        end

        if isBlacklisted then
            return
        else
            if type(value) == 'table' then
                cancelThreadsInTable(value, newPath, blacklistedPath)
            elseif typeof(value) == 'thread' or (typeof(value) == 'Instance' and value:IsA('Thread')) then
              --  print("Attempting to cancel:", table.concat(newPath, "."))
                pcall(task.cancel, value)
            end
        end
    end
end
    -- // Local
local function Refresh(PATH, name, types, children)
    if types == "table" then
        for i, v in pairs(PATH) do
            table.insert(name, v[children])
        end
    end
end

local Bottom = PGui:WaitForChild("Bottom").Frame
local StartButton = nil

for i,v in pairs(Bottom:GetChildren()) do
    if v.Position == UDim2.fromScale(0.5, 1) then
        for a,b in pairs(v:GetChildren()) do
            if b:IsA('Frame') and b.Size == UDim2.fromScale(1,0) and b.Size == UDim2.fromOffset(0,56) then
                for c,d in pairs(b:GetChildren()) do
                    if d.LayoutOrder == 1 and d:IsA('TextButton') then
                local txt = d:FindFirstChild('TextLabel')
                if txt and txt.Text and txt.Text:find("Start",1,true) then
                    StartButton = d
                end
                end
            end
        end
    end
end
    -- // Callbacks
        -- // Boss Rush
local function autoSelectCard()
    while Toggles.cselect.Value do
        task.wait(0.25)
        local pG = PGui:FindFirstChild("Prompt")
        if pG and pG.Parent then
            local cB, hP, bCB, bCI = nil, 0, nil, nil
            for _,d in ipairs(pG:GetDescendants()) do
                if d:IsA("TextButton") then
                    if d.Position == UDim2.fromScale(0.5,0.5) then
                        local tS = d:FindFirstChild("TextLabel") or d
                        if tS and tS.Text and tS.Text:find("Choose a card",1,true) then cB = d end
                    else
                        local tCF = d:FindFirstChild("Frame")
                        if tCF then
                            local tL = tCF:FindFirstChildOfClass("TextLabel")
                            if tL then
                                local cN = tL.Text
                                local p = Options.CardPriorities[cN] or 0
                                if p > hP then
                                    hP = p
                                    bCB = d
                                    local pX = d.Position.X.Scale
                                    if math.abs(pX - 0.125) < 0.05 then bCI = 1
                                    elseif math.abs(pX - 0.375) < 0.05 then bCI = 2
                                    elseif math.abs(pX - 0.625) < 0.05 then bCI = 3
                                    elseif math.abs(pX - 0.875) < 0.05 then bCI = 4 end
                                end
                            end
                        end
                    end
                end
            end
            if bCB and cB and bCI then
                local tS = cB:FindFirstChildOfClass("TextLabel") or cB
                local iT = tS.Text
                Library:Notify("Found card: "..bCB.Frame.TextLabel.Text.." (Priority: "..hP..")",3)
                fireClick(bCB)
                local sT = tick()
                local wR = false
                while tick() - sT < 2 do
                    local cTS = cB:FindFirstChildOfClass("TextLabel") or cB
                    if cTS.Text ~= iT and cTS.Text ~= "" then wR = true; break end
                    task.wait()
                end
                if wR then fireClick(cB) end
                repeat task.wait() until not PlayerGui:FindFirstChild("Prompt")
            end
        end
    end
end

-- // Ability
    -- // Universal
local function AutoAbility()
    while Toggles.G_AutoAbility.Value do
        pcall(function()
            if Toggles.G_AutoAbility.Value and Options.G_AbilityList.Value then
                for unitName, isSelected in pairs(Options.G_AbilityList.Value) do
                    if isSelected then
                        local towerInstance = workspace.Towers:FindFirstChild(unitName)
                        if towerInstance then
                            Remotes.Auto:FireServer(towerInstance, 1, true)
                        end
                    end
                end
            end
        task.wait(3)
    Flags.Auto.Ability.Universal = nil
    end)
    end
end
    -- // Boss
    -- // Special
        -- Bulma
local function Bulma()
    local wishMapping = {Power = 1, Time = 2, Wealth = 3}
     if Toggles.Game_Ability_AutoBulma.Value and not Flags.Auto.Ability.Special.Bulma.Used and not StartButton then
                local bulma = workspace.Towers:FindFirstChild("Bulma")
                if bulma then
                    local wishMeter = bulma:FindFirstChild("Meters") and bulma.Meters:FindFirstChild("Wish Balls")
                    if wishMeter then
                        local currentValue = wishMeter:GetAttribute("Value")
                        local maxValue = wishMeter:GetAttribute("MaxValue")
                        if currentValue and maxValue and maxValue > 0 and currentValue >= maxValue and bulma:WaitForChild('Stunned').Value == false then
                            local chosenWishName = Options.Game_Ability_Bulma.Value
                            local wishNumber = wishMapping[chosenWishName]
                            if wishNumber then
                                Remotes.Ability:InvokeServer(bulma, 1)
                                task.wait(4)
                                Remotes.Ability:InvokeServer(bulma, wishNumber)
                            --    Library:Notify("Used Bulma's wish for: "..chosenWishName,5)
                                Flags.Auto.Ability.Special.Bulma.Used = true
                            end
                        end
                    end
                end
            end

            if Flags.Auto.Ability.Special.Bulma.Used and PlayerGui:FindFirstChild("EndGameUI") then
                Flags.Auto.Ability.Special.Bulma.Used = false
            end
end

    -- // Import
local s, r = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/buang5516/buanghub/refs/heads/main/ALS/BossRushCards.lua"))()
end)

if s then
    BossRushCards = r
else
    Library:Notify("Failed to get Boss Rush Cards data.", 5)
end

    -- // UI Library
local Window = Library:CreateWindow({
    Title = "coolstuff",
    Footer = "mehwnei | als#broken",
    AutoShow = false
})

local Tabs = {
    Main = Window:AddTab("oi", "cog"),
    Game = Window:AddTab('Game', 'gamepad'),
    BossRush = Window:AddTab('Boss Rush', 'skull'),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}

-- // Main
    -- // Box
local M_LTB = Tabs.Main:AddLeftTabbox()
local T1 = M_LTB:AddTab("User")
local T2 = M_LTB:AddTab("Updates")

local M_LGB = Tabs.Main:AddLeftGroupbox('Misc', 'wrench')
    -- // Init
T1:AddLabel("<b>User</b>")
T1:AddLabel({
    Text = "Executor: "..identifyexecutor() or "N/A",
    DoesWrap = true
})
T1:AddDivider()
T1:AddLabel("<b>Game</b>")
T1:AddLabel({
    Text = "Name: "..Asset.Name.."\nID: "..game.PlaceId.."\nPlayers: "..#Plrs:GetPlayers().."\nMax Players: "..Plrs.MaxPlayers.."",
    DoesWrap = true
})
T2:AddLabel("<b>mega upd 6/19/25</b>")
T2:AddLabel({
    Text = "- tabs<br/> automation (fuck ts)<br/>    + ability (trash ngl dont expect ts to work)<br/> +main (ts)\n<b>6/18/25</b><br/> -exist",
    DoesWrap = true
})

local hasTP = nil

M_LGB:AddCheckbox("Main_AutoExec", {
    Text = "Auto Execute",
    Default = false,
    Callback = function(Value)
        Toggles.Main_AutoExec.Value = Value
        if Value then
            if not hasTP then
                hasTP = Plr.OnTeleport:Connect(function(State)
                    queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/gix314/coolstuff/refs/heads/main/als-autocard.luau'))()")
                end)
            end
        else
            if hasTP then
                hasTP:Disconnect()
                hasTP = nil
            end
        end
    end
})

-- // Boss Rush
    -- // Box
local BR_LTB = Tabs.BossRush:AddLeftTabbox("Settings", "wrench")
local BR_T1 = BR_LTB:AddTab("General")
local BR_T2 = BR_LTB:AddTab("Priorities")

Options.CardPriorities = Options.CardPriorities or {}

BR_T1:AddCheckbox("BR_Toggle", {
    Text = "Auto Select Card",
    Default = false,
    Callback = function(Value)
        Toggles.BR_Toggle.Value = Value
        if Value then
            if not Flags.Auto.BR.Enabled then
                Flags.Auto.BR.Enabled = task.spawn(autoSelectCard)
            end
        else
            if Flags.Auto.BR.Enabled then
                task.cancel(Flags.Auto.BR.Enabled)
                Flags.Auto.BR.Enabled = nil
            end
        end
    end
})

local cpi = {}
for _, cN in ipairs(BossRushCards) do
    cpi[cN] = BR_T2:AddInput(cN, {
        Text = cN,
        Default = Options.CardPriorities[cN] or 0,
        Numeric = true,
        AllowEmpty = false,
        MaxLength = 3,
        Placeholder = "0-100",
        EmptyReset = "0",
        Callback = function(v)
            local nP = tonumber(v) or 0
            if nP > 100 then nP = 100 end
            if nP < 0 then nP = 0 end
            if nP == 0 then
                Options.CardPriorities[cN] = 0
                return
            end
            local iD, dCN = false, ""
            for oC, oP in pairs(Options.CardPriorities) do
                if oC ~= cN and oP == nP then
                    iD, dCN = true, oC
                    break
                end
            end
            if iD then
                Library:Notify("Priority "..nP.." is already used by "..dCN,5)
                Options.CardPriorities[cN] = 0
                task.delay(.1, function()
                    if cpi[cN] then
                        cpi[cN]:SetValue(0)
                    end
                end)
            else
                Options.CardPriorities[cN] = nP
            end
        end
    })
    if Options.CardPriorities[cN] == nil then
        Options.CardPriorities[cN] = 0
    end
end

-- // Game
    -- // Box
local G_LTB = Tabs.Game:AddLeftTabbox()
local G_T1 = G_LTB:AddTab("Abilities")
local G_T2 = G_LTB:AddTab("Special")

local ABL = G_T1:AddDropdown("G_AbilityList", {
    Values = AbilityList,
    Default = {},
    Multi = true,
    Text = "Select Ability",
    Callback = function(Value) Options.G_AbilityList.Value = Value end
})

G_T1:AddButton({
    Text = "Refresh",
    Func = function()
    local AbilityList = {}
    Refresh(Plr.Slots, AbilityList, 'table', 'Value')
    ABL:SetValues(AbilityList)
    end,
})

G_T1:AddCheckbox("G_AutoAbility", {
    Text = "Auto Ability",
    Default = false,
    Callback = function(Value)
        Toggles.G_AutoAbility.Value = Value
        if Value then
            if not Flags.Auto.Ability.Universal then Flags.Auto.Ability.Universal = task.spawn(AutoAbility) end
        else
            if Options.G_AbilityList.Value then
                for unitName, isSelected in pairs(Options.G_AbilityList.Value) do
                    if isSelected then
                        local towerInstance = workspace.Towers:FindFirstChild(unitName)
                        if towerInstance then Remotes.Auto:FireServer(towerInstance, 1, false) end
                    end
                end
            end
            if not Flags.Auto.Ability.Universal then
                task.cancel(Flags.Auto.Ability.Universal)
            end
        end
    end
})

G_T2:AddDropdown("G_Special_BulmaWish", {
    Values = {'Time', 'Wealth', 'Power'},
    Default = "Time",
    Multi = false,
    Text = "Select Wish",
    Callback = function(Value) Options.G_Special_BulmaWish.Value = Value end
})

G_T2:AddCheckbox("G_Special_Bulma", {
    Text = "Auto Use Bulma Wish",
    Default = false,
    Callback = function(Value)
        Toggles.G_Special_Bulma.Value = Value
        if Value then
            if not Flags.Auto.Ability.Special.Bulma.Enabled then Flags.Auto.Ability.Special.Bulma.Enabled = task.spawn(Bulma) end
        elseif Flags.Auto.Ability.Special.Bulma.Enabled then
            task.cancel(Flags.Auto.Ability.Special.Bulma.Enabled)
            Flags.Auto.Ability.Special.Bulma.Enabled = nil
        end
    end
})

-- // UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
local originalUnload = Library.Unload

MenuGroup:AddButton("Unload", function()
    getgenv().script_LOADED = false
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
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

if not StartButton then
Refresh(Plr:WaitForChild('Slots'), AbilityList, 'table' ,'Value')
ABL:SetValues(AbilityList)
end

SaveManager:LoadAutoloadConfig()
