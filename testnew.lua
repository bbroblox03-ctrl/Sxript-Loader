-- Remove trailing space from library URL
local libraryUrl = "https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/LOS.LIB.lua"
local library

local success, err = pcall(function()
    library = loadstring(game:HttpGet(libraryUrl, true))()
end)

if not success or not library then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script Error",
        Text = "Failed to load UI library: " .. tostring(err),
        Duration = 5
    })
    return
end

-- ===== SERVICES =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- ===== PLAYER & GAME DATA =====
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Game remotes
local rEvents = ReplicatedStorage:WaitForChild("rEvents")
local petShopRemote = ReplicatedStorage:WaitForChild("cPetShopRemote")
local petShopFolder = ReplicatedStorage:WaitForChild("cPetShopFolder")

-- ===== UI SETUP =====
local window = library:CreateWindow(" 🌺JOY🌺 ", "Legends of Speed")

-- ===== DATA TABLES =====
local orbTypes = {"Yellow Orb", "Orange Orb", "Blue Orb", "Red Orb", "Ethereal Orb", "Gem", "Infernal Gem"}
local cities = {"City", "Snow City", "Magma City", "Legends Highway", "Speed Jungle", "Space", "Desert"}
local collectionRates = {"x800", "x900", "x1000", "x1100", "x1200", "x1300", "x1400", "x1500", "x1600", "x1800"}

-- Complete pet list
local allPetNames = {
    "Rainbow Speed",
    "Rainbow Steps","1st Trail","Dragonfire","Hyperblast","Green Firecaster",
    "Orange Falcon","White Pheonix","Blue Firecaster","Red Pheonix",
    "Red Firecaster","Flaming Hedgehog","Yellow Squeak","Yellow Butterfly",
    "Golden Angel","Golden Pheonix","Green Golem","Orange Pegasus",
    "Dark Soul Birdie","Eternal Nebula Dragon","Hypersonic Pegasus",
    "Shadows Edge Kitty","Soul Fusion Dog","Ultimate Overdrive Bunny",
    "Swift Samurai","Golden Viking","Speedy Sensei","Maestro Dog",
    "Divine Pegasus"
}

-- ONLY BASIC PETS NOW
local petTypes = {"basic"}
local petDropdowns = {}

-- ===== SETTINGS =====
local settings = {
    primary = {active = false, orb = nil, city = nil, speed = 1000, cooldown = 0.5},
    secondary = {active = false, orb = nil, city = nil, speed = 1000, cooldown = 0.5},
    third = {active = false, orb = nil, city = nil, speed = 1000, cooldown = 0.5},
    bullMode = false,
    race = {enabled = false, mode = "Teleport", target = 100, autoFill = false},
    hoops = false,
    gifts = false,
    chests = false,
    spinWheel = false,
    rebirth = {enabled = false, cooldown = 1, target = false, targetAmount = 100, targetCooldown = 1},
    instantRebirth = {amount = 1},
    pets = {
        basic = {hatch = false, selected = nil}
    },
    walkSpeed = 50,
    jumpPower = 50,
    hipHeight = 0,
    gravity = 196.2,
    fpsCap = 120,
    pingStabilizer = false,
    connectionEnhancer = false,
    antiLag = false
}

-- ===== STATE & LOOPS =====
local loops = {
    orbFarm = {},
    race = nil,
    hoops = nil,
    gifts = nil,
    chests = nil,
    spinWheel = nil,
    rebirth = nil,
    targetRebirth = nil,
    petHatch = {},
    statUpdate = nil,
    connection = nil,
    pingStabilizer = nil,
    hoopPopupCleaner = nil
}

local uiElements = {}
local originalHoopProperties = {}
local hoopPopupGui = nil
local hoopPopupFrame = nil

-- Storage for anti-lag original properties
local originalProperties = {
    particleEffects = {},
    decals = {},
    textures = {},
    baseParts = {},
    lighting = {},
    lightingEffects = {}
}

-- ===== HOOP POPUP REMOVAL SYSTEM =====

-- Find and disable the popup GUI that shows collection numbers
function findAndDisableHoopPopups()
    -- Try common popup GUI names
    local commonNames = {"Popups", "Effects", "FloatingNumbers", "DamageNumbers", "CollectionNumbers", "GamePopups", "Numbers"}
    for _, name in ipairs(commonNames) do
        local gui = PlayerGui:FindFirstChild(name)
        if gui and gui:IsA("ScreenGui") then
            hoopPopupGui = gui
            gui.Enabled = false
            return true
        end
    end
    
    -- Search more broadly for any ScreenGui with popup-related names
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local lowerName = gui.Name:lower()
            if lowerName:find("popup") or lowerName:find("effect") or lowerName:find("float") or lowerName:find("damage") or lowerName:find("collect") then
                hoopPopupGui = gui
                gui.Enabled = false
                return true
            end
        end
    end
    
    return false
end

-- Restore popup GUI visibility
function restoreHoopPopups()
    if hoopPopupGui then
        hoopPopupGui.Enabled = true
    end
end

-- Clean up any existing popup TextLabels
function clearExistingPopups()
    if hoopPopupGui then
        for _, label in ipairs(hoopPopupGui:GetDescendants()) do
            if label:IsA("TextLabel") then
                label:Destroy()
            end
        end
    end
    
    -- Also search and destroy any floating TextLabels in PlayerGui
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Text:match("%+%d+") then
                    label:Destroy()
                end
            end
        end
    end
end

-- Continuously remove popups as they appear
function startPopupCleaner()
    if loops.hoopPopupCleaner then loops.hoopPopupCleaner:Disconnect() end
    
    loops.hoopPopupCleaner = RunService.RenderStepped:Connect(function()
        if not settings.hoops then return end
        
        pcall(function()
            -- Destroy any TextLabels that appear with "+" and numbers
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    for _, label in ipairs(gui:GetDescendants()) do
                        if label:IsA("TextLabel") and label.Text:match("%+%d+") then
                            label:Destroy()
                        end
                    end
                end
            end
        end)
    end)
end

function stopPopupCleaner()
    if loops.hoopPopupCleaner then
        loops.hoopPopupCleaner:Disconnect()
        loops.hoopPopupCleaner = nil
    end
end

-- ===== COMPREHENSIVE HOOP HIDING SYSTEM =====

-- Recursively store properties for a part and all its children
function storeHoopPartProperties(part, propertyTable)
    if not part then return end
    
    if part:IsA("BasePart") then
        propertyTable[part] = {
            Transparency = part.Transparency,
            CanCollide = part.CanCollide,
            BrickColor = part.BrickColor,
            Material = part.Material,
            Size = part.Size,
            LocalTransparencyModifier = part.LocalTransparencyModifier
        }
    elseif part:IsA("Decal") or part:IsA("Texture") then
        propertyTable[part] = {
            Transparency = part.Transparency
        }
    elseif part:IsA("ParticleEmitter") then
        propertyTable[part] = {Enabled = part.Enabled}
    end
    
    -- Recursively process children
    for _, child in ipairs(part:GetChildren()) do
        storeHoopPartProperties(child, propertyTable)
    end
end

-- Store all original hoop properties
function storeAllHoopProperties()
    pcall(function()
        local hoopFolder = workspace:FindFirstChild("Hoops")
        if hoopFolder then
            for _, hoop in ipairs(hoopFolder:GetChildren()) do
                if hoop.Name == "Hoop" then
                    storeHoopPartProperties(hoop, originalHoopProperties)
                end
            end
        end
    end)
end

-- Recursively hide a hoop and all its children
function hideHoopRecursively(hoop, playerCFrame)
    if not hoop then return end
    
    if hoop:IsA("BasePart") then
        hoop.Transparency = 1
        hoop.CanCollide = false
        hoop.LocalTransparencyModifier = 1
        hoop.CFrame = playerCFrame
        
        -- REMOVED FIRE EFFECT - no longer changing material/color
    elseif hoop:IsA("Decal") or hoop:IsA("Texture") then
        hoop.Transparency = 1
    elseif hoop:IsA("ParticleEmitter") then
        hoop.Enabled = false
    end
    
    -- Process all children recursively
    for _, child in ipairs(hoop:GetChildren()) do
        hideHoopRecursively(child, playerCFrame)
    end
end

-- Restore all original hoop properties
function restoreAllHoopProperties()
    pcall(function()
        for object, props in pairs(originalHoopProperties) do
            if object and object.Parent then
                if object:IsA("BasePart") then
                    object.Transparency = props.Transparency
                    object.CanCollide = props.CanCollide
                    object.BrickColor = props.BrickColor
                    object.Material = props.Material
                    object.LocalTransparencyModifier = props.LocalTransparencyModifier
                elseif object:IsA("Decal") or object:IsA("Texture") then
                    object.Transparency = props.Transparency
                elseif object:IsA("ParticleEmitter") then
                    object.Enabled = props.Enabled
                end
            end
        end
    end)
end

-- ===== REMOTE-BASED FARMING =====

local orbRemote = rEvents:WaitForChild("orbEvent")
local hoopRemote = rEvents:WaitForChild("hoopEvent")
local raceRemote = rEvents:WaitForChild("raceEvent")
local rebirthRemote = rEvents:WaitForChild("rebirthEvent")

local orbNameMap = {
    ["Yellow Orb"] = "Yellow Orb",
    ["Orange Orb"] = "Orange Orb", 
    ["Blue Orb"] = "Blue Orb",
    ["Red Orb"] = "Red Orb",
    ["Ethereal Orb"] = "Ethereal Orb",
    ["Gem"] = "Gem",
    ["Infernal Gem"] = "Infernal Gem"
}

local orbCollectionLoops = {
    primary = nil,
    secondary = nil,
    third = nil
}

function startOrbFarm(farmKey)
    if orbCollectionLoops[farmKey] then
        pcall(function() orbCollectionLoops[farmKey]:Disconnect() end)
        orbCollectionLoops[farmKey] = nil
    end
    
    local config = settings[farmKey]
    if not config or not config.active then return end
    
    if not config.orb or not config.city then return end
    
    orbCollectionLoops[farmKey] = RunService.Heartbeat:Connect(function()
        if not config.active then return end
        
        pcall(function()
            for i = 1, math.floor(config.speed / 200) do
                orbRemote:FireServer("collectOrb", orbNameMap[config.orb], config.city)
                wait(0.05)
            end
        end)
        
        wait(config.cooldown)
    end)
end

function stopOrbFarm(farmKey)
    if orbCollectionLoops[farmKey] then
        pcall(function() orbCollectionLoops[farmKey]:Disconnect() end)
        orbCollectionLoops[farmKey] = nil
    end
end

-- ===== HOOPS FARMING WITH POPUP REMOVAL =====
function startHoopFarm()
    if loops.hoops then
        pcall(function() loops.hoops:Disconnect() end)
        loops.hoops = nil
    end
    
    -- Store original properties on first run
    if not next(originalHoopProperties) then
        storeAllHoopProperties()
    end
    
    -- Disable popup GUI and start cleanup loop
    findAndDisableHoopPopups()
    clearExistingPopups()
    startPopupCleaner()
    
    loops.hoops = RunService.Heartbeat:Connect(function()
        if not settings.hoops then return end
        
        local success, err = pcall(function()
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local hoopFolder = workspace:FindFirstChild("Hoops")
            if not hoopFolder then return end
            
            for _, hoop in ipairs(hoopFolder:GetChildren()) do
                if hoop.Name == "Hoop" then
                    hideHoopRecursively(hoop, character.HumanoidRootPart.CFrame)
                end
            end
        end)
        
        if not success then
            warn("Hoop collection error: " .. tostring(err))
        end
        
        wait(0.1)
    end)
end

function stopHoopFarm()
    if loops.hoops then
        pcall(function() loops.hoops:Disconnect() end)
        loops.hoops = nil
    end
    
    -- Restore everything
    restoreAllHoopProperties()
    restoreHoopPopups()
    stopPopupCleaner()
end

-- ===== ANTI-LAG FUNCTION =====
function toggleAntiLag(enable)
    if enable then
        -- Store and disable particle effects
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                originalProperties.particleEffects[v] = v.Enabled
                v.Enabled = false
            end
        end
        
        -- Store and modify lighting
        local lighting = game:GetService("Lighting")
        originalProperties.lighting = {
            GlobalShadows = lighting.GlobalShadows,
            FogEnd = lighting.FogEnd,
            Brightness = lighting.Brightness
        }
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0
        
        -- Set quality level
        settings().Rendering.QualityLevel = 1
        
        -- Store and modify decals/textures and baseParts
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                originalProperties.decals[v] = v.Transparency
                v.Transparency = 1
            elseif v:IsA("BasePart") and not v:IsA("MeshPart") then
                originalProperties.baseParts[v] = {
                    Material = v.Material,
                    Reflectance = v.Reflectance
                }
                v.Material = Enum.Material.SmoothPlastic
                if v.Parent and (v.Parent:FindFirstChild("Humanoid") or v.Parent.Parent:FindFirstChild("Humanoid")) then
                    -- Skip player parts
                else
                    v.Reflectance = 0
                end
            end
        end
        
        -- Store and disable lighting effects
        local lighting = game:GetService("Lighting")
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                originalProperties.lightingEffects[v] = v.Enabled
                v.Enabled = false
            end
        end
    else
        -- Restore particle effects
        for obj, enabled in pairs(originalProperties.particleEffects) do
            if obj and obj.Parent then
                obj.Enabled = enabled
            end
        end
        
        -- Restore lighting
        local lighting = game:GetService("Lighting")
        if originalProperties.lighting.GlobalShadows ~= nil then
            lighting.GlobalShadows = originalProperties.lighting.GlobalShadows
        end
        if originalProperties.lighting.FogEnd ~= nil then
            lighting.FogEnd = originalProperties.lighting.FogEnd
        end
        if originalProperties.lighting.Brightness ~= nil then
            lighting.Brightness = originalProperties.lighting.Brightness
        end
        
        -- Restore decals/textures
        for obj, transparency in pairs(originalProperties.decals) do
            if obj and obj.Parent then
                obj.Transparency = transparency
            end
        end
        
        -- Restore baseParts
        for obj, props in pairs(originalProperties.baseParts) do
            if obj and obj.Parent then
                obj.Material = props.Material
                obj.Reflectance = props.Reflectance
            end
        end
        
        -- Restore lighting effects
        for obj, enabled in pairs(originalProperties.lightingEffects) do
            if obj and obj.Parent then
                obj.Enabled = enabled
            end
        end
        
        -- Note: QualityLevel cannot be reverted dynamically in Roblox
    end
end

-- ===== TAB CREATION =====

local Universal_Tools = window:CreateTab("Universal Tools", 96221607452840)
Universal_Tools:CreateSection("Miscellaneous")
Universal_Tools:CreateBox("Enter FPS Cap", function(value)
    settings.fpsCap = tonumber(value) or 60
    if setfpscap then setfpscap(settings.fpsCap) end
end)
Universal_Tools:CreateSection("Network Optimization")
Universal_Tools:CreateToggle("Enable Ping Stabilizer", function(state)
    settings.pingStabilizer = state
    if state then startPingStabilizer() elseif loops.pingStabilizer then loops.pingStabilizer:Disconnect(); loops.pingStabilizer = nil end
end)
Universal_Tools:CreateToggle("Connection Enhancer", function(state)
    settings.connectionEnhancer = state
    if state then startConnectionEnhancer() elseif loops.connection then loops.connection:Disconnect(); loops.connection = nil end
end)

local Auto_Farming = window:CreateTab("Auto Farming", 103858677733367)
Auto_Farming:CreateSection("Race Farming")
Auto_Farming:CreateDropdown("Racing Mode", {"Teleport", "Smooth"}, function(value)
    settings.race.mode = value
end)
Auto_Farming:CreateToggle("Auto Fill Race", function(state)
    settings.race.autoFill = state
    if state then startAutoFillRace() end
end)
Auto_Farming:CreateBox("Race Target", function(value)
    settings.race.target = tonumber(value) or 100
end)
Auto_Farming:CreateToggle("Enable Auto Racing", function(state)
    settings.race.enabled = state
    if state then startRaceFarm() else stopRaceFarm() end
end)

Auto_Farming:CreateSection("Hoop Farming")
Auto_Farming:CreateButton("Clear Hoops", function()
    clearAllHoops()
end)
Auto_Farming:CreateToggle("Auto Collect Hoops", function(state)
    settings.hoops = state
    if state then startHoopFarm() else stopHoopFarm() end
end)

for _, farmType in ipairs({"Primary", "Secondary", "Third"}) do
    local key = farmType:lower()
    Auto_Farming:CreateSection(farmType .. " Auto Farm")
    
    Auto_Farming:CreateDropdown("Orb Type", orbTypes, function(value)
        settings[key].orb = value
    end)
    
    Auto_Farming:CreateDropdown("Target City", cities, function(value)
        settings[key].city = value
    end)
    
    Auto_Farming:CreateDropdown("Collection Speed", collectionRates, function(value)
        settings[key].speed = tonumber(value:match("x(%d+)")) or 1000
    end)
    
    Auto_Farming:CreateBox("Cooldown (seconds)", function(value)
        settings[key].cooldown = tonumber(value) or 0.5
    end)
    
    Auto_Farming:CreateToggle("Enable " .. farmType .. " Farm", function(state)
        settings[key].active = state
        if state then 
            startOrbFarm(key) 
        else 
            stopOrbFarm(key) 
        end
    end)
end

Auto_Farming:CreateSection("Extra Farming Options")
Auto_Farming:CreateToggle("Auto Gifts", function(state)
    settings.gifts = state
    if state then startGiftCollection() else stopGiftCollection() end
end)
Auto_Farming:CreateToggle("Auto Claim Chests", function(state)
    settings.chests = state
    if state then startChestCollection() else stopChestCollection() end
end)
Auto_Farming:CreateToggle("Auto Spin Wheel", function(state)
    settings.spinWheel = state
    if state then startWheelSpin() else stopWheelSpin() end
end)
Auto_Farming:CreateButton("Claim All Codes", function()
    claimAllCodes()
end)

-- PET HATCHING TAB (ONLY BASIC NOW)
local Pet_Hatching = window:CreateTab("Pet Hatching", 84773625854784)

-- Only create Basic Pets section
Pet_Hatching:CreateSection("All Pets")
petDropdowns["basic"] = Pet_Hatching:CreateDropdown("Select Pet", allPetNames, function(value)
    settings.pets.basic.selected = value
end)
Pet_Hatching:CreateToggle("Auto Hatch Pet", function(state)
    settings.pets.basic.hatch = state
    if state then startPetHatching("basic") else stopPetHatching("basic") end
end)

local Teleportation = window:CreateTab("Teleportation", 140134362123695)
Teleportation:CreateSection("Main Teleports")
local mainLocations = {"City", "Snow City", "Magma City", "Legends Highway", "Speed Jungle"}
Teleportation:CreateDropdown("Select Main Location", mainLocations, function(value)
    teleportToLocation(value)
end)

Teleportation:CreateSection("Server Teleports")
local serverOptions = {"Lowest Player Count", "Server Hop", "Rejoin"}
Teleportation:CreateDropdown("Server Options", serverOptions, function(value)
    if value == "Lowest Player Count" then teleportToLowestServer()
    elseif value == "Server Hop" then serverHop()
    elseif value == "Rejoin" then rejoinServer() end
end)

local Rebirth_System = window:CreateTab("Rebirth System", 98702116897863)
Rebirth_System:CreateSection("Rebirth Farming")
Rebirth_System:CreateBox("Rebirth Cooldown (sec)", function(value)
    settings.rebirth.cooldown = tonumber(value) or 1
end)
Rebirth_System:CreateToggle("Auto Rebirth", function(state)
    settings.rebirth.enabled = state
    if state then startAutoRebirth() else stopAutoRebirth() end
end)

Rebirth_System:CreateSection("Targeted Rebirth Farming")
Rebirth_System:CreateBox("Rebirth Target Amount", function(value)
    settings.rebirth.targetAmount = tonumber(value) or 100
end)
Rebirth_System:CreateBox("Target Rebirth Cooldown (sec)", function(value)
    settings.rebirth.targetCooldown = tonumber(value) or 1
end)
Rebirth_System:CreateToggle("Targeted Auto Rebirth", function(state)
    settings.rebirth.target = state
    if state then startTargetRebirth() else stopTargetRebirth() end
end)

Rebirth_System:CreateSection("Instant Rebirth Farming")
Rebirth_System:CreateBox("Rebirths to Perform", function(value)
    settings.instantRebirth.amount = tonumber(value) or 1
end)
Rebirth_System:CreateButton("Start Rebirth", function()
    performInstantRebirth(settings.instantRebirth.amount)
end)

local Script_Settings = window:CreateTab("Settings", 139117814373418)
Script_Settings:CreateSection("General Settings")
Script_Settings:CreateToggle("Freeze Character", function(state)
    settings.freezeChar = state
    freezeCharacter(state)
end)
Script_Settings:CreateToggle("Enable Bull Mode", function(state)
    settings.bullMode = state
end)

Script_Settings:CreateSection("Performance")
Script_Settings:CreateToggle("Anti-Lag Mode", function(state)
    settings.antiLag = state
    toggleAntiLag(state)
end)

Script_Settings:CreateSection("Player Settings")
Script_Settings:CreateBox("Set Walk Speed", function(value)
    settings.walkSpeed = tonumber(value) or 50
    updatePlayerStats()
end)
Script_Settings:CreateBox("Set Jump Power", function(value)
    settings.jumpPower = tonumber(value) or 50
    updatePlayerStats()
end)
Script_Settings:CreateBox("Set Hip Height", function(value)
    settings.hipHeight = tonumber(value) or 0
    updatePlayerStats()
end)
Script_Settings:CreateBox("Set Gravity", function(value)
    settings.gravity = tonumber(value) or 196.2
    workspace.Gravity = settings.gravity
end)

-- ===== CREDITS TAB (REPLACED PLAYER STATISTICS) =====
local Credits = window:CreateTab("Credits", 133249606271733)
Credits:CreateSection("Credits")
Credits:CreateLabel("Credits to: MARKYY")

Credits:CreateButton("Discord: Click to Copy", function()
    pcall(function()
        setclipboard("https://discord.gg/WMAHNafHqZ ")
    end)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Credits",
        Text = "Discord link copied to clipboard!",
        Duration = 3
    })
end)

Credits:CreateButton("Roblox Profile: Click to Copy", function()
    pcall(function()
        setclipboard("https://www.roblox.com/users/2815154822/profile ")
    end)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Credits",
        Text = "Roblox profile link copied to clipboard!",
        Duration = 3
    })
end)

Credits:CreateButton("TikTok: Click to Copy", function()
    pcall(function()
        setclipboard("https://www.tiktok.com/@markyy_0311 ")
    end)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Credits",
        Text = "TikTok link copied to clipboard!",
        Duration = 3
    })
end)

-- ===== CORE FUNCTIONS =====

function getPetObject(petName)
    return petShopFolder:FindFirstChild(petName)
end

function startPetHatching(petType)
    if loops.petHatch[petType] then loops.petHatch[petType]:Disconnect() end
    loops.petHatch[petType] = RunService.Heartbeat:Connect(function()
        local petConfig = settings.pets[petType]
        if not petConfig or not petConfig.hatch or not petConfig.selected then return end
        local petObj = getPetObject(petConfig.selected)
        if not petObj then return end
        pcall(function()
            petShopRemote:InvokeServer(petObj)
        end)
        wait(0.5)
    end)
end

function stopPetHatching(petType)
    if loops.petHatch[petType] then
        loops.petHatch[petType]:Disconnect()
        loops.petHatch[petType] = nil
    end
end

function teleportToLocation(location)
    local cframes = {
        ["City"] = CFrame.new(-9687.19, 59.07, 3096.59),
        ["Snow City"] = CFrame.new(-9677.66, 59.07, 3783.74),
        ["Magma City"] = CFrame.new(-11053.38, 217.03, 4896.11),
        ["Legends Highway"] = CFrame.new(-13097.86, 217.03, 5904.85),
        ["Speed Jungle"] = CFrame.new(-15271.71, 398.20, 5574.44)
    }
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = cframes[location] or cframes["City"]
    end
end

function teleportToLowestServer()
    local servers = getServers(game.PlaceId)
    if #servers > 0 then
        local lowest = servers[1]
        for _, server in ipairs(servers) do
            if server.playing < lowest.playing then lowest = server end
        end
        teleportToServer(game.PlaceId, lowest.id)
    end
end

function serverHop()
    local servers = getServers(game.PlaceId)
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        teleportToServer(game.PlaceId, randomServer.id)
    end
end

function rejoinServer()
    teleportToServer(game.PlaceId, game.JobId)
end

function getServers(placeId)
    local url = "https://games.roblox.com/v1/games/       " .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and response then return response.data or {} end
    return {}
end

function teleportToServer(placeId, jobId)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId)
    end)
end

function startPingStabilizer()
    if loops.pingStabilizer then loops.pingStabilizer:Disconnect() end
    loops.pingStabilizer = RunService.Heartbeat:Connect(function()
        if not settings.pingStabilizer then return end
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        if ping > 100 then wait(0.1) end
    end)
end

function startConnectionEnhancer()
    if loops.connection then loops.connection:Disconnect() end
    loops.connection = RunService.Heartbeat:Connect(function()
        if not settings.connectionEnhancer then return end
        pcall(function()
            local networkClient = game:GetService("NetworkClient")
            networkClient:SetOutgoingKBPSLimit(999999)
            networkClient:SetIncomingKBPSLimit(999999)
            settings().Network.IncomingReplicationLag = 0
        end)
        wait(1)
    end)
end

function startRaceFarm()
    if loops.race then loops.race:Disconnect() end
    loops.race = RunService.Heartbeat:Connect(function()
        if not settings.race.enabled then return end
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then return end
        local races = leaderstats:FindFirstChild("Races")
        if not races then return end
        
        if races.Value >= settings.race.target then
            settings.race.enabled = false
            return
        end
        
        local raceTimer = game:GetService("ReplicatedStorage"):FindFirstChild("raceTimer")
        local raceStarted = game:GetService("ReplicatedStorage"):FindFirstChild("raceStarted")
        local character = LocalPlayer.Character
        
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        if settings.race.autoFill and raceTimer and raceTimer:IsA("IntValue") and raceTimer.Value <= 0 then
            wait(0.5)
            raceRemote:FireServer("joinRace")
        end
        
        if settings.race.mode == "Teleport" then
            pcall(function()
                local positions = {
                    Vector3.new(1686.07, 36.31, -5946.63),
                    Vector3.new(48.31, 36.31, -8680.45),
                    Vector3.new(1001.33, 36.31, -10986.21)
                }
                for _, pos in ipairs(positions) do
                    character:MoveTo(pos)
                    wait(0.1)
                end
            end)
        elseif settings.race.mode == "Smooth" then
            if raceTimer and raceTimer:IsA("IntValue") and raceTimer.Value <= 0 then
                wait(0.5)
                raceRemote:FireServer("joinRace")
            end
            if raceStarted and raceStarted:IsA("BoolValue") and raceStarted.Value == true then
                wait(0.5)
                pcall(function()
                    local finishParts = workspace:GetDescendants()
                    local closestPart = nil
                    local minDist = math.huge
                    for _, part in ipairs(finishParts) do
                        if part:IsA("BasePart") and part.Name == "finishPart" then
                            local dist = (character.HumanoidRootPart.Position - part.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closestPart = part
                            end
                        end
                    end
                    if closestPart then
                        character:MoveTo(closestPart.Position)
                    end
                end)
            end
        end
        wait(0.05)
    end)
end

function stopRaceFarm()
    if loops.race then
        loops.race:Disconnect()
        loops.race = nil
    end
end

function startAutoFillRace()
    spawn(function()
        while settings.race.autoFill do
            wait(0.01)
            local raceTimer = game:GetService("ReplicatedStorage"):FindFirstChild("raceTimer")
            if raceTimer and raceTimer:IsA("IntValue") and raceTimer.Value <= 0 then
                raceRemote:FireServer("joinRace")
            end
        end
    end)
end

function clearAllHoops()
    pcall(function()
        local hoops = Workspace:FindFirstChild("Hoops")
        if hoops then
            for _, hoop in ipairs(hoops:GetChildren()) do
                if hoop:IsA("BasePart") then
                    hoop:Destroy()
                end
            end
        end
    end)
end

function startGiftCollection()
    if loops.gifts then loops.gifts:Disconnect() end
    loops.gifts = RunService.Heartbeat:Connect(function()
        if not settings.gifts then return end
        pcall(function()
            rEvents.freeGiftClaimRemote:InvokeServer()
        end)
        wait(300)
    end)
end

function stopGiftCollection()
    if loops.gifts then
        loops.gifts:Disconnect()
        loops.gifts = nil
    end
end

function startChestCollection()
    if loops.chests then loops.chests:Disconnect() end
    loops.chests = RunService.Heartbeat:Connect(function()
        if not settings.chests then return end
        pcall(function()
            local chestsFolder = Workspace:FindFirstChild("Chests")
            if chestsFolder then
                for _, chest in ipairs(chestsFolder:GetChildren()) do
                    local clickDetector = chest:FindFirstChildOfClass("ClickDetector")
                    if clickDetector then
                        fireclickdetector(clickDetector)
                        wait(0.5)
                    end
                end
            end
        end)
        wait(60)
    end)
end

function stopChestCollection()
    if loops.chests then
        loops.chests:Disconnect()
        loops.chests = nil
    end
end

function startWheelSpin()
    if loops.spinWheel then loops.spinWheel:Disconnect() end
    loops.spinWheel = RunService.Heartbeat:Connect(function()
        if not settings.spinWheel then return end
        pcall(function()
            rEvents.wheelSpinRemote:InvokeServer()
        end)
        wait(3600)
    end)
end

function stopWheelSpin()
    if loops.spinWheel then
        loops.spinWheel:Disconnect()
        loops.spinWheel = nil
    end
end

function claimAllCodes()
    local codes = {"RELEASE", "SPEED", "RACE", "LEGENDS", "HOOPS", "GEMS", "UPDATE", "BOOST", "LEGEND", "FAST"}
    for _, code in ipairs(codes) do
        pcall(function()
            rEvents.codeRemote:InvokeServer(code)
        end)
    end
end

function startAutoRebirth()
    if loops.rebirth then loops.rebirth:Disconnect() end
    loops.rebirth = RunService.Heartbeat:Connect(function()
        if not settings.rebirth.enabled then return end
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then return end
        local steps = leaderstats:FindFirstChild("Steps")
        local rebirths = leaderstats:FindFirstChild("Rebirths")
        if not steps or not rebirths then return end
        local cost = getRebirthCost()
        if steps.Value >= cost then
            pcall(function()
                rebirthRemote:FireServer("rebirthRequest")
            end)
        end
        wait(settings.rebirth.cooldown)
    end)
end

function stopAutoRebirth()
    if loops.rebirth then
        loops.rebirth:Disconnect()
        loops.rebirth = nil
    end
end

function startTargetRebirth()
    if loops.targetRebirth then loops.targetRebirth:Disconnect() end
    loops.targetRebirth = RunService.Heartbeat:Connect(function()
        if not settings.rebirth.target then return end
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then return end
        local rebirths = leaderstats:FindFirstChild("Rebirths")
        local steps = leaderstats:FindFirstChild("Steps")
        if not rebirths or not steps then return end
        if rebirths.Value >= settings.rebirth.targetAmount then
            settings.rebirth.target = false
            return
        end
        local cost = getRebirthCost()
        if steps.Value >= cost then
            pcall(function()
                rebirthRemote:FireServer("rebirthRequest")
            end)
        end
        wait(settings.rebirth.targetCooldown)
    end)
end

function stopTargetRebirth()
    if loops.targetRebirth then
        loops.targetRebirth:Disconnect()
        loops.targetRebirth = nil
    end
end

function performInstantRebirth(amount)
    amount = amount or 1
    for i = 1, amount do
        pcall(function()
            rebirthRemote:FireServer("rebirthRequest")
        end)
        wait(0.5)
    end
end

function getRebirthCost()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if not leaderstats then return math.huge end
    local rebirths = leaderstats:FindFirstChild("Rebirths")
    if not rebirths then return math.huge end
    return (rebirths.Value + 1) * 1000000
end

function startPetHatching(petType)
    if loops.petHatch[petType] then loops.petHatch[petType]:Disconnect() end
    loops.petHatch[petType] = RunService.Heartbeat:Connect(function()
        local petConfig = settings.pets[petType]
        if not petConfig or not petConfig.hatch or not petConfig.selected then return end
        local petObj = getPetObject(petConfig.selected)
        if not petObj then return end
        pcall(function()
            petShopRemote:InvokeServer(petObj)
        end)
        wait(0.5)
    end)
end

function stopPetHatching(petType)
    if loops.petHatch[petType] then
        loops.petHatch[petType]:Disconnect()
        loops.petHatch[petType] = nil
    end
end

function freezeCharacter(state)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.Anchored = state
    end
end

function updatePlayerStats()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = settings.walkSpeed
        humanoid.JumpPower = settings.jumpPower
    end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, settings.hipHeight)
    end
end

-- ===== NEW ANTI-AFK SYSTEM =====
wait(0.5)

local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local bolinha = Instance.new("ImageButton")
bolinha.Parent = gui
bolinha.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bolinha.BackgroundTransparency = 1 -- 🔹 Background agora é transparente
bolinha.BorderColor3 = Color3.fromRGB(255, 0, 0)
bolinha.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=116254090053371 "
bolinha.Size = UDim2.new(0, 59, 0, 49)
bolinha.Position = UDim2.new(0.8, 0, 0.2, 0)
bolinha.Active = true
bolinha.Draggable = true
bolinha.AutoButtonColor = false
bolinha.BorderSizePixel = 0
bolinha.ScaleType = Enum.ScaleType.Fit

-- Deixa a bolinha redonda
local corner = Instance.new("UICorner", bolinha)
corner.CornerRadius = UDim.new(1, 0)

-- Status e serviços
local ativo = false

-- Função de notificação
local function notify(msg)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Anti-AFK",
		Text = msg,
		Duration = 4
	})
end

-- Clique para ativar/desativar
bolinha.MouseButton1Click:Connect(function()
	ativo = not ativo
	if ativo then
		notify("Activated ✅")
	else
		notify("Deactivated ❌")
	end
end)

-- Loop de anti-AFK
game.Players.LocalPlayer.Idled:Connect(function()
	if ativo then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)
