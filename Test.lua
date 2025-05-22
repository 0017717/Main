local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "My Script",
    Footer = "v1.0.0",
    ToggleKeybind = Enum.KeyCode.RightControl,
    Center = true,
    AutoShow = true
})

local Tabs = {
	-- Creates a new tab titled Main
	Main = Window:AddTab("Main", "user"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local Groupbox = Tabs.Main:AddLeftGroupbox("Settings")

Groupbox:AddButton("Unload", function()
	Library:Unload()
end)

local UPN = Groupbox:AddInput("I_UPN", {
    Text = "Upgrade Name",
    Default = "Default value",
    Numeric = false,
    Finished = true,
    Placeholder = "upgrade name",
    ClearTextOnFocus = false,
    Callback = function(Value)
        print("Input updated:", Value)
    end
})

local UPUID = Groupbox:AddInput("I_UPUID", {
    Text = "Upgrade ID",
    Default = nil,
    Numeric = false,
    Finished = true,
    Placeholder = "upgrade id",
    ClearTextOnFocus = false,
    Callback = function(Value)
        print("Input updated:", Value)
    end
})


local Button = Groupbox:AddButton({
    Text = "Auto Upgrade",
    Func = function()
        while task.wait() do
            local args = {
	        Options.I_UPN.Value,
	        Options.I_UPUID.Value,
            }
        game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("upgrade"):FireServer(unpack(args))
        end
    end,
})

local function updateInputValues(upgradeName, upgradeId)
    -- Safely update values if Options exists
    if Options then
        if Options.I_UPN then Options.I_UPN:SetValue(upgradeName) end
        if Options.I_UPUID then Options.I_UPUID:SetValue(upgradeId) end
    end
end

-- Connect to remote using hookmetamethod or similar exploit-specific methods
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and self.Name == "upgrade" then
        -- Capture the values being sent
        local upgradeName = args[1]
        local upgradeId = args[2]
        updateInputValues(upgradeName, upgradeId)
    end
    
    return oldNamecall(self, ...)
end)
