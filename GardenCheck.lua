local player = game:GetService("Players").LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local money = leaderstats:WaitForChild("Sheckles")

-- Create fullscreen UI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "EnhancedPetStatusUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- This ensures coverage of the top bar

-- Main background that covers absolutely everything
local fullCover = Instance.new("Frame", screenGui)
fullCover.Size = UDim2.new(1, 0, 1, 0)
fullCover.Position = UDim2.new(0, 0, 0, 0)
fullCover.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Pure black
fullCover.BorderSizePixel = 0
fullCover.ZIndex = 0

-- Content frame
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15) -- Your original color
frame.BorderSizePixel = 0
frame.ZIndex = 1

-- Number formatting function
local function formatNumber(num)
    num = tonumber(num) or 0
    if num >= 1000000000 then
        return string.format("%.1fB", num/1000000000)
    elseif num >= 1000000 then
        return string.format("%.1fM", num/1000000)
    elseif num >= 1000 then
        return string.format("%.1fk", num/1000)
    else
        return tostring(math.floor(num))
    end
end

-- Enhanced label creation with bold and larger text
local function createLabel(text, position, size, options)
    local label = Instance.new("TextLabel", frame)
    label.Text = text
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = options.textColor or Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = options.textSize or 28
    label.TextXAlignment = options.align or Enum.TextXAlignment.Left
    label.TextYAlignment = options.alignY or Enum.TextYAlignment.Top
    label.TextWrapped = options.wrap or false
    label.TextStrokeTransparency = 0.7
    label.TextStrokeColor3 = options.strokeColor or Color3.new(0, 0, 0)
    label.TextScaled = options.scale or false
    label.ZIndex = 2 -- Ensure text appears above frames
    return label
end

-- Find and count pets
local function findAllPets()
    local petCounts = {}
    local locations = {player.Backpack, player.Character}
    
    for _, location in ipairs(locations) do
        if location then
            for _, item in ipairs(location:GetChildren()) do
                if item:GetAttribute("ItemType") == "Pet" then
                    local cleanName = item.Name:gsub("%s%[.+%]", "")
                    petCounts[cleanName] = (petCounts[cleanName] or 0) + 1
                end
            end
        end
    end
    
    return petCounts
end

-- Create pet display with larger, bolder text
local function createPetDisplay(petCounts)
    if not next(petCounts) then
        return {"No Pets"}
    end
    
    local sortedPets = {}
    for name, count in pairs(petCounts) do
        table.insert(sortedPets, {name = name, count = count})
    end
    
    table.sort(sortedPets, function(a, b) 
        if a.count == b.count then
            return a.name < b.name
        end
        return a.count > b.count
    end)
    
    local columns = {
        left = {},
        middle = {},
        right = {}
    }
    
    for i, pet in ipairs(sortedPets) do
        local petText = string.format("%s [x%d]", pet.name, pet.count)
        if i % 3 == 1 then
            table.insert(columns.left, petText)
        elseif i % 3 == 2 then
            table.insert(columns.middle, petText)
        else
            table.insert(columns.right, petText)
        end
    end
    
    return {
        left = table.concat(columns.left, "\n"),
        middle = table.concat(columns.middle, "\n"),
        right = table.concat(columns.right, "\n")
    }
end

-- Update display with larger, bolder elements
local function updateDisplay()
    -- Clear old labels
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local petCounts = findAllPets()
    local formattedMoney = formatNumber(money.Value)
    local petColumns = createPetDisplay(petCounts)
    
    -- Main title (very large and bold)
    createLabel("PLAYER NAME", UDim2.new(0.05, 0, 0.02, 0), UDim2.new(0.9, 0, 0.1, 0), {
        textSize = 48,
        textColor = Color3.fromRGB(0, 200, 255),
        align = Enum.TextXAlignment.Center,
        strokeColor = Color3.fromRGB(0, 50, 100)
    })
    
    -- Player name (extra bold and large)
    createLabel(player.Name, UDim2.new(0.05, 0, 0.12, 0), UDim2.new(0.9, 0, 0.08, 0), {
        textSize = 40,
        textColor = Color3.fromRGB(255, 255, 255),
        align = Enum.TextXAlignment.Center,
        strokeColor = Color3.fromRGB(40, 40, 40)
    })
    
    -- Money display (very prominent)
    createLabel("MONEY: 💷 "..formattedMoney, UDim2.new(0.05, 0, 0.22, 0), UDim2.new(0.9, 0, 0.1, 0), {
        textSize = 46,
        textColor = Color3.fromRGB(150, 255, 150),
        align = Enum.TextXAlignment.Center,
        strokeColor = Color3.fromRGB(0, 80, 0)
    })
    
    -- Pets title (large and bold)
    createLabel("YOUR PETS", UDim2.new(0.05, 0, 0.34, 0), UDim2.new(0.9, 0, 0.06, 0), {
        textSize = 38,
        textColor = Color3.fromRGB(255, 200, 100),
        align = Enum.TextXAlignment.Center,
        strokeColor = Color3.fromRGB(100, 50, 0)
    })
    
    -- Pet columns with larger text and better spacing
    createLabel(petColumns.left, UDim2.new(0.1, 0, 0.42, 0), UDim2.new(0.25, 0, 0.5, 0), {
        textSize = 32,
        wrap = true,
        textColor = Color3.fromRGB(220, 240, 255),
        strokeColor = Color3.fromRGB(0, 30, 60)
    })
    
    createLabel(petColumns.middle, UDim2.new(0.375, 0, 0.42, 0), UDim2.new(0.25, 0, 0.5, 0), {
        textSize = 32,
        wrap = true,
        textColor = Color3.fromRGB(240, 220, 255),
        strokeColor = Color3.fromRGB(60, 0, 60)
    })
    
    createLabel(petColumns.right, UDim2.new(0.65, 0, 0.42, 0), UDim2.new(0.25, 0, 0.5, 0), {
        textSize = 32,
        wrap = true,
        textColor = Color3.fromRGB(255, 240, 200),
        strokeColor = Color3.fromRGB(80, 40, 0)
    })
    
    -- Toggle instruction
    createLabel("[Press P to toggle display]", UDim2.new(0.6, 0, 0.94, 0), UDim2.new(0.35, 0, 0.05, 0), {
        textSize = 24,
        textColor = Color3.fromRGB(200, 200, 200),
        align = Enum.TextXAlignment.Right,
        strokeColor = Color3.fromRGB(40, 40, 40)
    })
end

-- Toggle with P key
local uis = game:GetService("UserInputService")
local isVisible = true

uis.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.P and not gameProcessed then
        isVisible = not isVisible
        frame.Visible = isVisible
        fullCover.Visible = isVisible
    end
end)

-- Track changes and update every 3 seconds
money:GetPropertyChangedSignal("Value"):Connect(updateDisplay)

-- Initial setup
updateDisplay()

while true do
    updateDisplay()
    wait(3)
end