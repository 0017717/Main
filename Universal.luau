if not game:IsLoaded() then game.Loaded:Wait() end

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local human = char:WaitForChild("Humanoid")
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
local tweenService = game:GetService('TweenService')

UserInputService = game:GetService("UserInputService")
local IsOnMobile = table.find({
	Enum.Platform.IOS,
	Enum.Platform.Android
}, UserInputService:GetPlatform())

getgenv().Image = "rbxassetid://7229442422"; -- put a asset id in here to make it work
getgenv().ToggleUI = "Insert" -- This where you can Toggle the Fluent ui library

task.spawn(function()
    if not getgenv().LoadedMobileUI == true then getgenv().LoadedMobileUI = true
        local OpenUI = Instance.new("ScreenGui");
        local ImageButton = Instance.new("ImageButton");
        local UICorner = Instance.new("UICorner");
        OpenUI.Name = "OpenUI";
        OpenUI.Parent = game:GetService("CoreGui");
        OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        ImageButton.Parent = OpenUI;
        ImageButton.BackgroundColor3 = Color3.fromRGB(105,105,105);
        ImageButton.BackgroundTransparency = 0.8
        ImageButton.Position = UDim2.new(0.9,0,0.1,0);
        ImageButton.Size = UDim2.new(0,50,0,50);
        ImageButton.Image = getgenv().Image;
        ImageButton.Draggable = true;
        ImageButton.Transparency = 1;
        UICorner.CornerRadius = UDim.new(0,200);
        UICorner.Parent = ImageButton;
        ImageButton.MouseButton1Click:Connect(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true,getgenv().ToggleUI,false,game);
        end)
    end
end)

local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = 'Sodium',
    SubTitle = "EXTRA | IN-DEV",
    TabWidth = 80,
    Size = UDim2.fromOffset(830, 525),
    Resize = true, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
    MinSize = Vector2.new(370, 280),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Monokai Classic",
    MinimizeKey = Enum.KeyCode.Insert -- Used when theres no MinimizeKeybind
}

local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "phosphor-users-bold"
    },
    Humanoid = Window:CreateTab{
        Title = "Humanoid",
        Icon = "phosphor-user-gear-bold"
    },
    Misc = Window:CreateTab{
        Title = "Misc",
        Icon = "phosphor-user-gear-bold"
    },
    Debug = Window:CreateTab{
        Title = "Debug",
        Icon = "phosphor-wrench-bold"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}

local Options = Library.Options

--//
local Status = {
    Misc = {
        DisableRender3D = false,
    },
    HumanoidModify = {
        WS = {
            Enabled = false,
            Value = 16,
        },
        JP = {
            Enabled = false,
            Value = 50,
        },
        JH = {
            Enabled = false,
            Value = 7.2,
        },
    }
}

--// Tab Features
do
    local DR3D = Tabs.Misc:CreateToggle("DR3D",
        {Title = "Disable 3D Render",
            Default = false
        })

    local WSS = Tabs.Humanoid:CreateSlider("WSS", {
        Title = "Walkspeed Value",
        Description = "Modify character's walkspeed",
        Default = Status.HumanoidModify.WS.Value,
        Min = 0,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
        end
    })

    local WS = Tabs.Humanoid:CreateToggle("WS",
        {Title = "Walkspeed Enabled",
            Default = false
        })

    local JPS = Tabs.Humanoid:CreateSlider("JPS", {
        Title = "Jumppower Value",
        Description = "Modify character's jumppower",
        Default = Status.HumanoidModify.JP.Value,
        Min = 0,
        Max = 500,
        Rounding = 1,
        Callback = function(Value)
        end
    })

    local JP = Tabs.Humanoid:CreateToggle("JP",
        {Title = "Jumppower Enabled",
            Default = false
        })
    
        local JHS = Tabs.Humanoid:CreateSlider("JHS", {
            Title = "Jumpheight Value",
            Description = "Modify character's jumpheight (Alternative jumppower if jumppower modify not working)",
            Default = Status.HumanoidModify.JH.Value,
            Min = 0,
            Max = 720,
            Rounding = 1,
            Callback = function(Value)
            end
        })
    
        local JH = Tabs.Humanoid:CreateToggle("JH",
            {Title = "Jumpheight Enabled",
                Default = false
            })

            local IY = Tabs.Debug:CreateButton{
                Title = "IY",
                Description = "Run Infinite Yield.",
            Callback = function()   
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            end
            }

            local Dex = Tabs.Debug:CreateButton{
                Title = "Dex",
                Description = "Run Dex Explorer.",
            Callback = function()   
                if IsOnMobile then
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/Dex/Mobile%20Dex%20Explorer.txt"))()
                else
                    Window:Dialog{
                        Title = "Dex Explorer",
                        Content = "Choose a version you want to run.",
                        Buttons = {
                            {
                                Title = "V2",
                                Callback = function()
                                    loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Dex%20Explorer.txt"))()
                                end
                            },
                            {
                                Title = "V3",
                                Callback = function()
                                    loadstring(game:HttpGet("https://raw.githubusercontent.com/0017717/bk/refs/heads/main/odex"))()
                                end
                            },
                            {
                                Title = "V3 New",
                                Callback = function()
                                    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
                                end
                            },
                            {
                                Title = "Babyhamsta's V3",
                                Callback = function()
                                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", true))()
                                end
                            },
                        }
                    }
                end
            end
            }
            local HS = Tabs.Debug:CreateButton{
                Title = "HTTPSpy",
                Description = "Run HTTP Spy.",
            Callback = function()   
                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Httpspy/main/httpspy.txt"))()
            end
            }
            local REGUI = Tabs.Debug:CreateButton{
                Title = "RemoteEvent",
                Description = "Run RemoteEvent trigger GUI.",
            Callback = function()   
                Window:Dialog{
                    Title = "RemoteEvent",
                    Content = "Choose a type you want to run.",
                    Buttons = {
                        {
                            Title = "FireServer",
                            Callback = function()
                                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameremotefireserver.lua"))()
                            end
                        },
                        {
                            Title = "InvokeClient",
                            Callback = function()
                                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameremoteinvokeclient.lua"))()
                            end
                        },
                        {
                            Title = "InvokeServer",
                            Callback = function()
                                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameinvokeserver.lua"))()
                            end
                        },
                        {
                            Title = "All",
                            Callback = function()
                                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameremotefireserver.lua"))()
                                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameremoteinvokeclient.lua"))()
                                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameinvokeserver.lua"))()
                            end
                        },
                    }
                }
            end
        }
            local SPV = Tabs.Debug:CreateButton{
                Title = "Dimension Viewer",
                Description = "View related places of current place.",
            Callback = function()   
                loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/subplaceviewer.txt"))()
            end
            }
            

    --// Callbacks
    DR3D:OnChanged(
        function()
            Status.Misc.DisableRender3D = Options.DR3D.Value
        end
    )
    WS:OnChanged(
        function()
            Status.HumanoidModify.WS.Enabled = Options.WS.Value
        end
    )
    JP:OnChanged(
        function()
            Status.HumanoidModify.JP.Enabled = Options.JP.Value
        end
    )
    JH:OnChanged(
        function()
            Status.HumanoidModify.JH.Enabled = Options.JH.Value
        end
    )


--// Functions
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    while task.wait() do
        if Status.Misc.DisableRender3D then
    game:GetService("RunService"):Set3dRenderingEnabled(false)
        else
    game:GetService("RunService"):Set3dRenderingEnabled(true)     
        end
    end
end
)

    task.spawn(function()
        while task.wait() do
            if Status.HumanoidModify.WS.Enabled then
                human.WalkSpeed = Options.WSS.Value
            end
        end
    end
    )
    task.spawn(function()
        while task.wait() do
            if Status.HumanoidModify.JP.Enabled then
                human.JumpPower = Options.JPS.Value
            end
        end
    end
    )
    task.spawn(function()
        while task.wait() do
            if Status.HumanoidModify.JH.Enabled then
                human.JumpHeight = Options.JHS.Value
                human.UseJumpPower = false
            else
                human.UseJumpPower = true
            end
        end
    end
    )
    
end


SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes{}

InterfaceManager:SetFolder("Sodium")
SaveManager:SetFolder("Sodium/gtg")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Library:Notify{
    Title = "Sodium",
    Content = "The script has been loaded.",
    Duration = 5
}

SaveManager:LoadAutoloadConfig()
