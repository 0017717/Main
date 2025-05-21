local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false -- Forces AddToggle to AddCheckbox
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)

local Window =
    Library:CreateWindow(
    {
        Title = "EUT Fucker",
        Footer = "DETECTED",
        Icon = nil,
        NotifySide = "Right",
        ShowCustomCursor = false,
        AutoShow = true
    }
)

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Puzzle = Window:AddTab("Puzzle", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}

local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local char = plr.Character
local hum = char.Humanoid

plr.PlayerScripts:WaitForChild('idler'):Destroy()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("remotes")
local cardRemote = remotes:WaitForChild("card")

local function toBinary(number)
    if number == 0 then
        return "0"
    end
    local binary = ""
    while number > 0 do
        binary = tostring(number % 2) .. binary
        number = math.floor(number / 2)
    end
    return binary
end

-- Function to count the number of "1"s in a binary string
local function countOnes(binaryString)
    local count = 0
    for char in binaryString:gmatch("1") do
        count = count + 1
    end
    return count
end

-- Get the Buttons container.
local buttonsContainer = workspace.objects.puzzle.Screen.SurfaceGui.ScreenFrame.Buttons

-- Check if buttonsContainer is nil
if not buttonsContainer then
    print("Error: Buttons container not found at workspace.objects.puzzle.Screen.SurfaceGui.ScreenFrame.Buttons")
    return
end

local buttons = buttonsContainer:GetChildren()

local symbolToNumber = {
    ["!"] = "1",
    ["@"] = "2",
    ["#"] = "3",
    ["$"] = "4",
    ["%"] = "5",
    ["^"] = "6",
    ["&"] = "7",
    ["*"] = "8",
    ["("] = "9",
    [")"] = "0"
}

local function getHsvSum(r_val, g_val, b_val)
    local r, g, b = r_val / 255, g_val / 255, b_val / 255
    local cmax, cmin = math.max(r, g, b), math.min(r, g, b)
    local delta = cmax - cmin
    local h, s, v

    -- Hue calculation
    if delta == 0 then
        h = 0
    elseif cmax == r then
        h = (60 * (((g - b) / delta)))
        if g < b then h = h + 360 end -- Ensure positive before potential modulo issues if any (Python's % handles negatives differently)
                                     -- The Python example uses `(value + 360) % 360` which is robust
        h = (60 * ((g - b) / delta) + 360) % 360 -- Using the Python script's exact logic for H
    elseif cmax == g then
        h = (60 * ((b - r) / delta) + 120) % 360
    else -- cmax == b
        h = (60 * ((r - g) / delta) + 240) % 360
    end

    -- Saturation calculation
    if cmax == 0 then
        s = 0
    else
        s = (delta / cmax) * 100
    end

    -- Value calculation
    v = cmax * 100

    return h + s + v
end

local MangoFolder = workspace.objects.mangotree.mangoes

local Automation = Tabs.Main:AddLeftGroupbox("Automation")
local RightGroupbox = Tabs.Main:AddRightGroupbox("Information")

local T_AXP = Automation:AddCheckbox("AutoXP",{
        Text = "Auto XP",
        Default = false,
        Callback = function(Value)
            Toggles.AutoXP.Value = Value
        end})

local T_ACC = Automation:AddCheckbox("AutoCC",{
        Text = "Auto Cube Click",
        Default = false,
        Callback = function(Value)
            Toggles.AutoCC.Value = Value
        end})

local T_ACM = Automation:AddCheckbox("AutoCM",{
        Text = "Auto Collect Mangoes",
        Default = false,
        Callback = function(Value)
            Toggles.AutoCM.Value = Value
        end})
        
local T_AR = Automation:AddCheckbox("AutoRoll",{
        Text = "Auto Roll ATM",
        Default = false,
        Callback = function(Value)
            Toggles.AutoRoll.Value = Value
        end})

local T_AMS = Automation:AddCheckbox("AutoMS",{
        Text = "Auto Max Studs",
        Default = false,
        Callback = function(Value)
            Toggles.AutoRoll.Value = Value
        end})

local Holder = Tabs.Puzzle:AddLeftGroupbox("Harry's Puzzle")

local Binary = Holder:AddButton({
    Text = "De-Binary Puzzle",
    Func = function()
for _, child in ipairs(buttons) do
    if child:IsA("Frame") then -- Correctly handle Frames
        for _, grandchild in ipairs(child:GetChildren()) do
            if grandchild:IsA("TextButton") then
                local number = tonumber(grandchild.Text)
                if number then
                    local binary = toBinary(number)
                    local onesCount = countOnes(binary)
                    grandchild.Text = tostring(onesCount) -- Update TextButton's text
                else
                    print("Warning: TextButton with non-numeric text: " .. grandchild.Name)
                end
            end
        end
    end
end
    end
})

local Symbol = Holder:AddButton({
    Text = "Decode Symbol Puzzle",
    Func = function()
local buttonDataList = {} -- To store {button, value, originalText, intermediateString}
-- Iterate through each child of the mainContainer (expected to be 'Frame' instances)
for _, subFrame in ipairs(buttons) do
    if subFrame:IsA("Frame") then -- Assuming each button is in its own 'Frame'
        local textButton = subFrame:FindFirstChildOfClass("TextButton")

        if textButton then
            local originalSymbolText = textButton.Text
            local numberStringChars = {} -- To build the string with digits and preserved chars

            -- Step 1: Convert symbols to digits, preserve other characters
            for i = 1, #originalSymbolText do
                local char = string.sub(originalSymbolText, i, i)
                local replacement = symbolToNumber[char]
                if replacement then
                    table.insert(numberStringChars, replacement) -- Add mapped digit
                else
                    table.insert(numberStringChars, char) -- Preserve original char (e.g., space, or unmapped letter)
                end
            end
            local stringWithDigitsAndPreservedChars = table.concat(numberStringChars)

            -- Step 2: Remove all non-digit characters to get a pure number string
            -- Example: "35 9410" becomes "359410"
            local pureDigitString = string.gsub(stringWithDigitsAndPreservedChars, "%D", "") -- %D matches any non-digit

            local numericValue
            if #pureDigitString > 0 then
                numericValue = tonumber(pureDigitString)
            else
                -- If after removing non-digits, the string is empty (e.g., original was just spaces or non-mapped letters)
                -- Assign a very large value so it sorts last.
                print("Warning: Button " .. textButton:GetFullName() .. " (Original: '" .. originalSymbolText .. "') resulted in an empty digit string. Assigning a high value for sorting.")
                numericValue = math.huge
            end

            if numericValue then
                table.insert(buttonDataList, {
                    button = textButton,
                    value = numericValue,
                    originalText = originalSymbolText,
                    intermediateString = stringWithDigitsAndPreservedChars -- for debugging
                })
                -- For verbose logging during processing:
                -- print(string.format("  Processed '%s': Original='%s' -> Intermediate='%s' -> PureDigits='%s' -> Value=%s",
                --    textButton.Name, originalSymbolText, stringWithDigitsAndPreservedChars, pureDigitString, tostring(numericValue)))
            else
                -- This case should be rare if pureDigitString is not empty, but good to have a fallback.
                print("Error: Could not convert '" .. pureDigitString .. "' (from original '" .. originalSymbolText .. "') to a number for button " .. textButton:GetFullName() .. ". Assigning high value.")
                table.insert(buttonDataList, {
                    button = textButton,
                    value = math.huge, -- Sort problematic ones last
                    originalText = originalSymbolText,
                    intermediateString = stringWithDigitsAndPreservedChars
                })
            end
        else
            print("Warning: No TextButton found in sub-Frame: " .. subFrame:GetFullName())
        end
    end
end

if #buttonDataList == 0 then
    print("Error: No button data was processed. Check paths and ensure TextButtons exist within the Frames.")
    return
end

-- Step 3: Sort the list by the calculated numeric value (lowest first)
table.sort(buttonDataList, function(a, b)
    -- Handle math.huge correctly if present
    if a.value == math.huge and b.value == math.huge then return false end -- Maintain relative order for multiple math.huge
    if a.value == math.huge then return false end -- 'a' is effectively largest
    if b.value == math.huge then return true end  -- 'b' is effectively largest
    return a.value < b.value
end)

-- Step 4: Update the TextButton text with the order number (1, 2, ..., 25)
print("-----------------------------------------------------")
print("Assigning order numbers to TextButtons...")
for i, data in ipairs(buttonDataList) do
    if data.button then
        data.button.Text = tostring(i)
        print(string.format("  Order %d: Button %s (Original: '%s', Calculated Value: %s) -> Text set to '%s'",
            i, data.button.Name, data.originalText, tostring(data.value), tostring(i)))
    end
end
    end
})

local HSV = Holder:AddButton({
    Text = "Reveal HSV Puzzle",
    Func = function()
local buttonDataList = {}

-- Iterate through each Frame that holds a button and its label
for _, itemFrame in ipairs(buttons) do
    if itemFrame:IsA("Frame") and itemFrame.Name == "Frame" then -- Ensure it's one of the 25 'Frame' instances
        local textButton = itemFrame:FindFirstChildOfClass("TextButton")
        local textLabel = itemFrame:FindFirstChildOfClass("TextLabel")

        if textButton and textLabel then
            local rgbString = textLabel.Text
            -- Parse the RGB string "R G B"
            local rStr, gStr, bStr = string.match(rgbString, "(%d+)%s+(%d+)%s+(%d+)")

            if rStr and gStr and bStr then
                local r, g, b = tonumber(rStr), tonumber(gStr), tonumber(bStr)
                if r and g and b then -- Check if conversion was successful
                    local hsvSum = getHsvSum(r, g, b)
                    table.insert(buttonDataList, {
                        button = textButton,
                        sum = hsvSum,
                        originalRgb = rgbString -- For debugging if needed
                    })
                    -- print("Processed button: RGB=" .. rgbString .. ", HSV Sum=" .. hsvSum)
                else
                    print("Warning: Could not convert RGB values to numbers for: " .. rgbString .. " in " .. itemFrame:GetFullName())
                end
            else
                print("Warning: Could not parse RGB string: " .. rgbString .. " in " .. itemFrame:GetFullName())
            end
        else
            if not textButton then print("Warning: Missing TextButton in " .. itemFrame:GetFullName()) end
            if not textLabel then print("Warning: Missing TextLabel in " .. itemFrame:GetFullName()) end
        end
    end
end

if #buttonDataList == 0 then
    print("Error: No button data was processed. Check paths and instance names.")
    return
end

-- Sort the list by HSV sum (lowest first)
table.sort(buttonDataList, function(a, b)
    return a.sum < b.sum
end)

-- Update the TextButton text with the order number
for i, data in ipairs(buttonDataList) do
    if data.button then
        data.button.Text = tostring(i)
        -- print("Set button " .. data.button:GetFullName() .. " (RGB: " .. data.originalRgb .. ", Sum: " .. data.sum .. ") to order: " .. i)
    end
end
    end
})

local Holder = Tabs.Puzzle:AddRightGroupbox("Minesweeper")

local T_AMP = Holder:AddCheckbox("AutoMP",{
        Text = "Auto Minesweeper Point", 
        Default = false,
        Callback = function(Value)
            Toggles.AutoMP.Value = Value
        end})

-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

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
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

task.spawn(function()
        while task.wait() do
            if Toggles.AutoXP.Value then
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("click_xp"):FireServer()
            end
        end
    end)

task.spawn(function()
        while task.wait() do
            if Toggles.AutoCC.Value then
                workspace:WaitForChild("objects"):WaitForChild("leveling_center_extension"):WaitForChild("model"):WaitForChild("Cube"):WaitForChild("Click"):FireServer()
            end
        end
    end)

task.spawn(function()
        while task.wait() do
            if Toggles.AutoCM.Value then
                for i, v in pairs(MangoFolder:GetChildren()) do
                    firetouchinterest(char.HumanoidRootPart, v, 0)
                    firetouchinterest(char.HumanoidRootPart, v, 1)
                end
            end
        end
    end)

task.spawn(function()
        while task.wait() do
            if Toggles.AutoRoll.Value then
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("gamble"):InvokeServer()
            end
        end
    end)

task.spawn(function()
        while task.wait() do
            if Toggles.AutoMS.Value then
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("bonus"):WaitForChild("maxout"):FireServer()
            end
        end
    end)

task.spawn(function()
        while task.wait() do
            if Toggles.AutoMP.Value then
                local args = {
	"minesweeper",
	"more_mspts",
	"max"
}
remotes:WaitForChild("upgboard"):FireServer(unpack(args))
            end
        end
    end)


Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
