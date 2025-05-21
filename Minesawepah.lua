local cells = workspace.objects.minesweeper.CELLS
local resetButton = workspace.objects.minesweeper.INTERFACE.Reset.ClickDetector
local mistakes = 0
local maxMistakes = 2

-- Debug function
local function printColor(color)
    return string.format("R:%.1f G:%.1f B:%.1f", color.R, color.G, color.B)
end

-- Color definitions and tolerance
local COLOR_TOLERANCE = 0.1 -- Reduced and adjusted for 0-1 range
local COLORS = {
    HIDDEN = { -- Converting RGB 163,162,165 and 147,146,150 to 0-1 range
        {R = 163/255, G = 162/255, B = 165/255},
        {R = 147/255, G = 146/255, B = 150/255}
    },
    SAFE = {R = 140/255, G = 255/255, B = 134/255}, -- Known safe parts
    BLANK = {R = 1, G = 1, B = 1}, -- Revealed blank parts (255/255)
    MINE = {R = 125/255, G = 0, B = 0}, -- Revealed mine
    VICTORY = {R = 0, G = 200/255, B = 0} -- Victory state parts
}

-- Helper functions with debug
local function isColorSimilar(color1, color2)
    local diff = math.abs(color1.R - color2.R) + 
                math.abs(color1.G - color2.G) + 
                math.abs(color1.B - color2.B)
    return diff < COLOR_TOLERANCE
end

local function isHidden(part)
    if not part or not part.Color then return false end
    local color = part.Color
    for _, hiddenColor in ipairs(COLORS.HIDDEN) do
        if isColorSimilar(color, hiddenColor) then
            return true
        end
    end
    return false
end

local function isSafe(part)
    if not part or not part.Color then return false end
    return isColorSimilar(part.Color, COLORS.SAFE)
end

local function isMine(part)
    if not part or not part.Color then return false end
    return isColorSimilar(part.Color, COLORS.MINE)
end

local function clickCell(part)
    if not part then 
        print("Error: No part provided")
        return false 
    end
    
    local clickDetector = part:FindFirstChild("ClickDetector")
    if not clickDetector then 
        return false 
    end
    
    fireclickdetector(clickDetector)
    
    if isMine(part) then
        mistakes = mistakes + 1
        if mistakes > maxMistakes then
            print("Too many mistakes, resetting...")
            fireclickdetector(resetButton)
            mistakes = 0
            return false
        end
    end
    return true
end

local function solve() 
    while true do
        local changed = false
        
        -- Get fresh state of all parts each iteration
        local allParts = cells:GetChildren()     
        -- Click all safe parts first
        for _, part in ipairs(allParts) do
            if isSafe(part) then
                if clickCell(part) then
                    changed = true
                    task.wait(0.1)
                end
            end
        end
        
        -- If no safe parts, click a random hidden part
        if not changed then
            local hiddenParts = {}
            for _, part in ipairs(allParts) do
                if isHidden(part) then
                    table.insert(hiddenParts, part)
                end
            end
            
            if #hiddenParts == 0 then
                print("Game completed - no hidden parts left!")
                return
            end
            
            local randomPart = hiddenParts[math.random(#hiddenParts)]
            clickCell(randomPart)
        end
        
        task.wait(0.3)
        
        -- Double check if we need to continue
        if mistakes > maxMistakes then
            print("Too many mistakes, ending...")
            return
        end
    end
end

local function playGames()
    local gamesPlayed = 0
    
    while true do
        gamesPlayed = gamesPlayed + 1
        mistakes = 0
        solve()
        fireclickdetector(resetButton)
        task.wait(0.5)
    end
end

if cells then
    if resetButton then
        playGames() -- Call playGames instead of solve
    else
        print("Error: Reset button not found")
    end
else
    print("Error: Cells folder not found")
end
