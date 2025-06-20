repeat wait() until getgenv().DEVICE_NAME ~= nil

if not game:IsLoaded() then repeat game.Loaded:Wait() until game:IsLoaded() end

local request = (syn and syn.request) or request or (http and http.request) or http_request or (fluxus and fluxus.request) or getgenv().request
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")

local DEVICE_NAME = getgenv().DEVICE_NAME or "Unknown Device"

-- Function to get current place info
local function getCurrentPlaceInfo()
    local placeId = game.PlaceId
    local success, placeInfo = pcall(function()
        return MarketplaceService:GetProductInfo(placeId)
    end)
    
    if not success then
        return nil, "Failed to get place info"
    end
    
    local isInGame = true
    if player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("LoadingScreen") then
        isInGame = false
    end
    
    return {
        placeId = placeId,
        placeName = placeInfo.Name,
        isInGame = isInGame
    }
end

-- Game detection system
local function detectGame()
    local placeId = tostring(game.PlaceId)
    
    local supportedGames = {
        ["4520749081"] = "kinglegacy",
        ["6381829480"] = "kinglegacy",
        ["5985232436"] = "growagarden",
        ["126884695634066"] = "growagarden"
    }
    
    return supportedGames[placeId] or "unsupported"
end

-- King Legacy System
local function KingLegacySystem()
    print("กำลังใช้งานสคริปต์ King Legacy")
    
    local targetItems = {
        ["Hydra's Tail"] = 0,
        ["Sea King's Fin"] = 0,
        ["Sea's Wraith"] = 0,
        ["Sea King's Blood"] = 0
    }
    
    local targetFruits = {
        ["Dragon"] = 0,
        ["Gate"] = 0,
        ["Dough"] = 0,
        ["Toy"] = 0,
        ["Phoenix"] = 0
    }
    
    local function scanGUI()
        local playerGui = player:WaitForChild("PlayerGui")
        
        for itemName, _ in pairs(targetItems) do
            local guiElement = playerGui:FindFirstChild(itemName, true)
            if guiElement then
                local amountLabel = guiElement:FindFirstChild("Amount") or guiElement:FindFirstChildWhichIsA("TextLabel")
                if amountLabel then
                    targetItems[itemName] = tonumber(amountLabel.Text:match("%d+")) or 0
                end
            end
        end
        
        for fruitName, _ in pairs(targetFruits) do
            local guiElement = playerGui:FindFirstChild(fruitName .. "Fruit", true)
            if guiElement then
                local amountLabel = guiElement:FindFirstChild("Amount") or guiElement:FindFirstChildWhichIsA("TextLabel")
                if amountLabel then
                    targetFruits[fruitName] = tonumber(amountLabel.Text:match("%d+")) or 0
                end
            end
        end
    end
    
    while task.wait(10) do
        pcall(scanGUI)
        
        local data = {
            apikey = getgenv().API_KEY
            device_name = DEVICE_NAME,
            player = player.Name,
            items = targetItems,
            fruits = targetFruits,
            online = true,
            script_running = true,
            timestamp = os.date("%Y-%m-%d %H:%M:%S"),
            game_type = "kinglegacy"
        }
        
        pcall(function()
            request({
                Url = "https://title.ddshop-th.com/message.php",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(data)
            })
        end)
    end
end

-- Function to find all sprinklers
local function findAllSprinklers()
    local sprinklerCounts = {}
    local totalSprinklers = 0
    local player = game:GetService("Players").LocalPlayer
    
    if not player then
        print("❌ ไม่พบผู้เล่น")
        return {}
    end

    local locations = {}
    if player:FindFirstChild("Backpack") then
        table.insert(locations, player.Backpack)
    end
    if player.Character then
        table.insert(locations, player.Character)
    end

    for _, location in ipairs(locations) do
        for _, item in ipairs(location:GetChildren()) do
            if item and item.Name then
                if string.find(string.lower(item.Name), "sprinkler") then
                    local baseName, count = string.match(item.Name, "(.+)%s*x(%d+)%s*$")
                    
                    if baseName and count then
                        count = tonumber(count) or 1
                        baseName = string.gsub(baseName, "^%s*(.-)%s*$", "%1")
                    else
                        baseName = item.Name
                        count = 1
                    end
                    
                    sprinklerCounts[baseName] = (sprinklerCounts[baseName] or 0) + count
                    totalSprinklers = totalSprinklers + count
                end
            end
        end
    end

    return sprinklerCounts
end

-- Grow a Garden System
local function GrowAGardenSystem()
    print("กำลังใช้งานสคริปต์ Grow a Garden")
    
    local leaderstats = player:WaitForChild("leaderstats")
    local money = leaderstats:WaitForChild("Sheckles")

    local honeyValue = player:WaitForChild("PlayerGui"):WaitForChild("Honey_UI")
        :WaitForChild("Frame"):WaitForChild("TextLabel1"):WaitForChild("val")

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

    local function findAllSeeds()
        local seedCounts = {}
        local locations = {player.Backpack, player.Character}
        
        for _, location in ipairs(locations) do
            if location then
                for _, item in ipairs(location:GetChildren()) do
                    if item and item.Name then
                        local seedName, countStr = string.match(item.Name, "(.+)%s%[X(%d+)%]")
                        local count = 1
                        
                        if countStr then
                            count = tonumber(countStr) or 1
                            seedName = string.gsub(seedName, "%s%[X%d+%]", "")
                        else
                            sprinklerName = item.Name
                        end
                        
                        if seedName then
                            seedName = string.match(seedName, "^%s*(.-)%s*$")
                            seedCounts[seedName] = (seedCounts[seedName] or 0) + count
                        end
                    end
                end
            end
        end
        
        return seedCounts
    end

    local function sendToServer()
        local petCounts = findAllPets()
        local petList = {}
        for name, count in pairs(petCounts) do
            table.insert(petList, string.format("%s x%d", name, count))
        end
        
        local seedCounts = findAllSeeds()
        local seedList = {}
        for name, count in pairs(seedCounts) do
            table.insert(seedList, string.format("%s x%d", name, count))
        end
        
        local sprinklerCounts = findAllSprinklers()
        local sprinklerList = {}
        for name, count in pairs(sprinklerCounts) do
            table.insert(sprinklerList, string.format("%s x%d", name, count))
        end

        local data = {
            apikey = getgenv().API_KEY
            device_name = DEVICE_NAME,
            player = player.Name,
            money = money.Value,
            honey = honeyValue.Value,
            pets = petList,
            seeds = seedList,
            sprinklers = sprinklerList,
            online = true,
            script_running = true,
            timestamp = os.date("%Y-%m-%d %H:%M:%S"),
            game_type = "growagarden"
        }

        if not request then
            warn("[ERROR] Executor นี้ไม่รองรับ request()")
            return
        end

        local success, response = pcall(function()
            return request({
                Url = "https://title.ddshop-th.com/message.php",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(data)
            })
        end)

        if success and response and response.Success then
            print("[✅] ส่งข้อมูลสำเร็จ", response.StatusCode)
        else
            warn("[❌] ส่งข้อมูลล้มเหลว", response and response.StatusCode or "No response")
        end
    end

    while task.wait(10) do
        pcall(sendToServer)
    end
end

-- Main execution
local gameType = detectGame()
print("ผลลัพธ์การตรวจสอบ:", gameType)

if gameType == "kinglegacy" then
    print("✅ เริ่มระบบ King Legacy")
    pcall(KingLegacySystem)
elseif gameType == "growagarden" then
    print("✅ เริ่มระบบ Grow a Garden")
    pcall(GrowAGardenSystem)
else
    local errorMsg = string.format([[
    ❌ เกมปัจจุบันไม่รองรับ
    Place ID ที่ตรวจพบ: %s
    สคริปต์รองรับเฉพาะ:
    - King Legacy (4520749081, 6381829480)
    - Grow a Garden (5985232436, 126884695634066)
    สคริปต์จะปิดตัวเองใน 5 วินาที
    ]], game.PlaceId)
    
    print(errorMsg)
    wait(5)
    return
end
