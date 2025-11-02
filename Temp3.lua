-- // Services
local Plrs = cloneref(game:GetService("Players"))
local Plr = Plrs.LocalPlayer
local PGui = Plr:WaitForChild("PlayerGui")

local Services = {
	RS = cloneref(game:GetService("ReplicatedStorage")),
	TS = cloneref(game:GetService("TweenService")),
	Http = cloneref(game:GetService("HttpService")),
	Run = cloneref(game:GetService("RunService")),
	Gui = cloneref(game:GetService("GuiService")),
	Market = cloneref(game:GetService("MarketplaceService")),
	TP = cloneref(game:GetService("TeleportService")),
}

local VU = cloneref(game:GetService("VirtualUser"))
local VIM = cloneref(game:GetService("VirtualInputManager"))

local queueteleport = queue_on_teleport
local GC = getconnections or get_signal_cons

if GC then
		for i,v in pairs(GC(Plr.Idled)) do
			if v["Disable"] then
				v["Disable"](v)
			elseif v["Disconnect"] then
				v["Disconnect"](v)
			end
		end
	else
		Plr.Idled:Connect(function()
			VU:CaptureController()
			VU:ClickButton2(Vector2.new())
		end)
end

-- // Repository
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- // Variables
s, e = pcall(function()
-- // UI Setup
local Window = Library:CreateWindow({
    Title = "Akasha",
    Footer = "Anime Guardians | BUILD: 0.0.0.1",
    ToggleKeybind = Enum.KeyCode.Insert,
	Font = Enum.Font.Jura,
    ShowCustomCursor = false,
    EnableSidebarResize = true,
    SidebarMinWidth = 200,
    SidebarCompactWidth = 56,
    SidebarCollapseThreshold = 0.45,
})

Library:SetWatermarkVisibility(true)
 
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;
 
local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;
 
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;
 
    Library:SetWatermark(('Akasha | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

local Tabs = {
    Info = Window:AddTab('Information', 'info', 'About servers, user and game.'),
	Stage = Window:AddTab('Stage', 'swords', 'Stage-related features.'),
    Config = Window:AddTab('Configuration', 'cog', 'Adjust settings and preferences.')
}

local Groupboxes = {
    Info = {
        L1 = Tabs.Info:AddLeftGroupbox("User Info", "user"),
        R1 = Tabs.Info:AddRightGroupbox("Game Info", "gamepad"),
    },
    Stage = {
        L1 = Tabs.Stage:AddLeftGroupbox("General", "cog"),
        R1 = Tabs.Stage:AddRightGroupbox("Ability", "gamepad"),
    }
}

-- // Info Tab | Left 1
Groupboxes.Info.L1:AddLabel("Executor: "..identifyexecutor() or "N/A", true)

-- // Info Tab | Right 1
Groupboxes.Info.R1:AddLabel("Game Name: " .. game.Name, true)
Groupboxes.Info.R1:AddLabel("Game ID: " .. game.GameId, true)
Groupboxes.Info.R1:AddLabel("Place ID: " .. game.PlaceId, true)
Groupboxes.Info.R1:AddLabel("Job ID: " .. game.JobId, true)
Groupboxes.Info.R1:AddDivider()
local CurrentPlrs = Groupboxes.Info.R1:AddLabel("Current Players: N/A")
local MaxPlrs = Groupboxes.Info.R1:AddLabel("Max Players: " .. Plrs.MaxPlayers)

task.spawn(function()
    local maxPlayerCount = Plrs.MaxPlayers
    local function updatePlayerCount()
        local currentCount = #Plrs:GetPlayers()
        CurrentPlrs:SetText("Current Players: " .. currentCount .. "/" .. maxPlayerCount)
    end

    updatePlayerCount()
    Plrs.PlayerAdded:Connect(updatePlayerCount)
    Plrs.PlayerRemoving:Connect(updatePlayerCount)
end)

local GameSettings = workspace:WaitForChild("GameSettings")
local stageChallengeMode = GameSettings:WaitForChild("StagesChallenge"):WaitForChild("Mode")
local stageChallengeEvent = Services.RS:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("StageChallenge")
local controlEvent = Services.RS:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Control")

local isAutoStageEnabled = false
local autoStageThread = nil

local function autoStageLoop()
    while isAutoStageEnabled do
        stageChallengeEvent:FireServer("Super Faster Wave")
        if not isAutoStageEnabled then break end
        controlEvent:FireServer("Next Stage Vote")
        task.wait(0.0001)
    end
    autoStageThread = nil
end

Groupboxes.Stage.L1:AddCheckbox("NextStage", {
    Text = "Auto Next Stage",
    Default = false,
})

Toggles.NextStage:OnChanged(function(newValue)
    isAutoStageEnabled = newValue

    if isAutoStageEnabled and not autoStageThread then
        autoStageThread = task.spawn(autoStageLoop)
    end
end)



-- // Configuration Tab
local MenuGroup = Tabs.Config:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = false,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

ThemeManager:SetFolder("Akasha")
SaveManager:SetFolder("Akasha/critical-revengeance")
SaveManager:SetSubFolder("main-game")

SaveManager:BuildConfigSection(Tabs.Config)

ThemeManager:ApplyToTab(Tabs.Config)
SaveManager:LoadAutoloadConfig()

if not s then
    Library:Notify(e, 5)
    else
    Library:Notify('Akasha loaded.', 5)
end
end)
