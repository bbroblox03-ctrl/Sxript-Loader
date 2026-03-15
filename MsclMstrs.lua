local TARGET_SIZE = UDim2.fromOffset(450, 340)
local targetFrame
local isOpen = false
local preloaded = false

task.spawn(function()
    while not targetFrame do
        local screenGui = CoreGui:FindFirstChild("ScreenGui")
        if screenGui then
            for _, v in ipairs(screenGui:GetChildren()) do
                if v:IsA("Frame") and v.Size == TARGET_SIZE then
                    targetFrame = v
                    targetFrame.Visible = true
                    task.wait()
                    targetFrame.Visible = false
                    preloaded = true
                    break
                end
            end
        end
        task.wait(0.25)
    end
end)


local LIB_URL = "https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KyypieUI.lua"
local ok, Library = pcall(function()
    local source = game:HttpGet(LIB_URL)
    return loadstring(source)()
end)

if not ok then
    error("Failed to load UI library: " .. tostring(Library))
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local userId = player.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

game:GetService("StarterGui"):SetCore("SendNotification",{  
    Title = "KYYY MSCLMSTRS",     
    Text = "Welcome!",
    Icon = "",
    Duration = 5,
})

wait(4)

game:GetService("StarterGui"):SetCore("SendNotification",{  
    Title = "Hello 🖕",     
    Text = player.Name,
    Icon = content,
    Duration = 4,
})

wait(3)

-- NEW WINDOW STRUCTURE
local Window = Library:CreateWindow({
    Title = "KYY - Muscle Masters",
    SubTitle = "FREE",
    Size = UDim2.fromOffset(450, 340),
    TabWidth = 110,
    Theme = "Combat",
    Acrylic = false,
})

-- NEW TABS STRUCTURE
local Home        = Window:AddTab({ Title = "Main",          Icon = "home" })
local farmingTab  = Window:AddTab({ Title = "Farming",       Icon = "leaf" })
local Killer      = Window:AddTab({ Title = "Killer",          Icon = "flag" })
local Shop        = Window:AddTab({ Title = "Egg Shop",      Icon = "gem" })
local Misc        = Window:AddTab({ Title = "Miscellaneous", Icon = "menu" })
local Settings    = Window:AddTab({ Title = "Credits",       Icon = "info" })

local Options = Library.Options

-- ===========================================================
--  PERFORMANCE & CONNECTION OPTIMIZATION SYSTEM
-- ===========================================================
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local NetworkClient = game:GetService("NetworkClient")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

-- FPS Boost Variables
local FpsBoostEnabled = false
local OriginalSettings = {}
local OptimizationConnection = nil

-- Connection Enhancer Variables
local ConnectionEnhancerEnabled = false
local PingOptimizerThread = nil

-- Anti Lag Variables
local AntiLagEnabled = false
local LagPreventionConnection = nil

-- Save original settings
local function SaveOriginalSettings()
    OriginalSettings = {
        ShadowSoftness = Lighting.ShadowSoftness,
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        Technology = Lighting.Technology,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
    }
end

SaveOriginalSettings()

-- ===========================================================
--  FPS BOOST SYSTEM
-- ===========================================================
local function EnableFpsBoost()
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Brightness = 1
    Lighting.FogStart = 0
    Lighting.FogEnd = 999999
    
    pcall(function()
        Lighting.Technology = Enum.Technology.Compatibility
    end)
    
    Workspace.StreamingEnabled = true
    
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            v.Enabled = false
        end
    end
    
    local function OptimizePart(part)
        if part:IsA("BasePart") then
            part.CastShadow = false
            if part:IsA("MeshPart") then
                part.RenderFidelity = Enum.RenderFidelity.Performance
                part.CollisionFidelity = Enum.CollisionFidelity.Box
            end
        end
    end
    
    for _, part in pairs(Workspace:GetDescendants()) do
        pcall(function()
            OptimizePart(part)
        end)
    end
    
    OptimizationConnection = Workspace.DescendantAdded:Connect(function(descendant)
        pcall(function()
            OptimizePart(descendant)
        end)
    end)
    
    local function OptimizeCharacter(character)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
                part.Material = Enum.Material.Plastic
            end
        end
    end
    
    if player.Character then
        OptimizeCharacter(player.Character)
    end
    
    player.CharacterAdded:Connect(function(char)
        if FpsBoostEnabled then
            task.wait(1)
            OptimizeCharacter(char)
        end
    end)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            OptimizeCharacter(plr.Character)
        end
    end
    
    local success, UserGameSettings = pcall(function()
        return UserSettings():GetService("UserGameSettings")
    end)
    
    if success then
        UserGameSettings.MasterVolume = math.min(UserGameSettings.MasterVolume, 0.5)
        UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end
    
end

local function DisableFpsBoost()
    for setting, value in pairs(OriginalSettings) do
        pcall(function()
            Lighting[setting] = value
        end)
    end
    
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            v.Enabled = true
        end
    end
    
    if OptimizationConnection then
        OptimizationConnection:Disconnect()
        OptimizationConnection = nil
    end
    
end

-- ===========================================================
--  CONNECTION ENHANCER SYSTEM - FIXED
-- ===========================================================
local function EnableConnectionEnhancer()
    ConnectionEnhancerEnabled = true
    
    -- Safely apply network settings with pcall
    pcall(function()
        settings().Network.IncomingReplicationLag = 0
        settings().Network.PhysicsSendRate = 60
        settings().Network.PhysicsReceiveRate = 60
    end)
    
    pcall(function()
        game:GetService("NetworkClient"):SetOutgoingKBPSLimit(0)
    end)
    
    -- Define optimization function outside the loop
    local function OptimizeNetwork()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                if obj:IsA("Part") and obj.Anchored then
                    pcall(function()
                        obj:SetNetworkOwner(nil)
                    end)
                end
            end
        end
    end
    
    -- Run once immediately
    pcall(OptimizeNetwork)
    
    -- Start the optimization loop in a separate thread
    PingOptimizerThread = task.spawn(function()
        while ConnectionEnhancerEnabled do
            -- Random garbage collection
            if math.random(1, 10) == 1 then
                pcall(function()
                    collectgarbage("collect")
                end)
            end
            
            -- Optimize network ownership
            pcall(OptimizeNetwork)
            
            task.wait(5)
        end
    end)
end

local function DisableConnectionEnhancer()
    ConnectionEnhancerEnabled = false
    
    -- Wait a bit for the thread to stop naturally
    task.wait(0.1)
    
    PingOptimizerThread = nil
    
    -- Reset network settings
    pcall(function()
        settings().Network.PhysicsSendRate = 30
        settings().Network.PhysicsReceiveRate = 30
    end)
end

-- ===========================================================
--  ANTI LAG SYSTEM
-- ===========================================================
local function EnableAntiLag()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    
    local function ReduceEffects()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            elseif v:IsA("Sound") then
                v.Volume = math.min(v.Volume, 0.3)
            end
        end
    end
    
    ReduceEffects()
    
    LagPreventionConnection = Workspace.DescendantAdded:Connect(function(descendant)
        if AntiLagEnabled then
            task.wait()
            pcall(function()
                if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
                    descendant.Enabled = false
                elseif descendant:IsA("Sound") then
                    descendant.Volume = math.min(descendant.Volume, 0.3)
                end
            end)
        end
    end)
    
    local function OptimizeHumanoid(humanoid)
        humanoid.AutoRotate = false
        pcall(function()
            humanoid.AutoJumpEnabled = false
        end)
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                OptimizeHumanoid(hum)
            end
        end
    end
    
end

local function DisableAntiLag()
    AntiLagEnabled = false
    
    if LagPreventionConnection then
        LagPreventionConnection:Disconnect()
        LagPreventionConnection = nil
    end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = true
        end
    end
    
end

-- ===========================================================
--  TAB MAIN (Home) - Performance Toggles
-- ===========================================================

Home:AddSection("Performance Optimization")

local FpsToggle = Home:AddToggle("FpsBoost", { Title = "FPS Boost", Default = false })
FpsToggle:OnChanged(function()
    FpsBoostEnabled = Options.FpsBoost.Value
    if FpsBoostEnabled then
        EnableFpsBoost()
    else
        DisableFpsBoost()
    end
end)

local ConnectionToggle = Home:AddToggle("ConnectionEnhancer", { Title = "Connection Enhancer", Default = false })
ConnectionToggle:OnChanged(function()
    local value = Options.ConnectionEnhancer.Value
    if value then
        EnableConnectionEnhancer()
    else
        DisableConnectionEnhancer()
    end
end)

local AntiLagToggle = Home:AddToggle("AntiLag", { Title = "Anti Lag", Default = false })
AntiLagToggle:OnChanged(function()
    AntiLagEnabled = Options.AntiLag.Value
    if AntiLagEnabled then
        EnableAntiLag()
    else
        DisableAntiLag()
    end
end)


-- ===========================================================
--  TAB FARMING (farmingTab) - FIXED AUTO FARM
-- ===========================================================

local PlayersService = game:GetService("Players")
local localPlayer = PlayersService.LocalPlayer
local leaderstats = localPlayer:WaitForChild("leaderstats")
local rebirths = leaderstats:WaitForChild("Rebirths")

local AutoFarmEnabled = false
local runningThreads = {}
local rng = Random.new()

local function stopAll()
    AutoFarmEnabled = false
    for _, t in ipairs(runningThreads) do
        if t then task.cancel(t) end
    end
    table.clear(runningThreads)
end

local function GetPrompts(MachinesFolder, positions)
    local EPSILON = 2.0
    local prompts = {}
    
    for _, obj in ipairs(MachinesFolder:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local pos = obj.Position
            for _, target in ipairs(positions) do
                if (pos - target).Magnitude < EPSILON then
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("ProximityPrompt") then
                            table.insert(prompts, child)
                            break
                        end
                    end
                end
            end
        end
    end
    return prompts
end

local function RunScriptBelow10()
    local TARGET_POSITIONS = {
        Vector3.new(-120.774185, 5.02033472, -56.9413261),
        Vector3.new(-94.2546463, 5.02033472, -35.0815392)
    }
    
    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MachineRemote = ReplicatedStorage:WaitForChild("RemotesEvent"):WaitForChild("MachineActiveEvent")
    
    local prompts = GetPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then 
        return 
    end

    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local prompt = prompts[rng:NextInteger(1, #prompts)]
                if prompt and prompt.Enabled and prompt.Parent then
                    local machinePart = prompt.Parent
                    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(machinePart.Position + Vector3.new(0, 3, 0))
                    task.wait(0.1)
                    fireproximityprompt(prompt)
                end
            end
            task.wait(0.3)
        end
    end))
    
    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            if localPlayer.Character then
                pcall(function()
                    MachineRemote:FireServer()
                end)
            end
            task.wait(0.1)
        end
    end))
end

local function RunScriptAboveOrEqual10()
    local TARGET_POSITIONS = {
        Vector3.new(2747.89795, 7.65916204, 105.534966),
        Vector3.new(2747.89795, 7.65916204, 126.657951),
        Vector3.new(2743.69092, 11.6664858, 233.435394),
        Vector3.new(2743.69092, 11.6664858, 258.496918),
    }
    
    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MachineRemote = ReplicatedStorage:WaitForChild("RemotesEvent"):WaitForChild("MachineActiveEvent")
    
    local prompts = GetPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then 
        return 
    end

    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local prompt = prompts[rng:NextInteger(1, #prompts)]
                if prompt and prompt.Enabled and prompt.Parent then
                    local machinePart = prompt.Parent
                    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(machinePart.Position + Vector3.new(0, 3, 0))
                    task.wait(0.1)
                    fireproximityprompt(prompt)
                end
            end
            task.wait(0.3)
        end
    end))
    
    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            if localPlayer.Character then
                pcall(function()
                    MachineRemote:FireServer()
                end)
            end
            task.wait(0.05)
        end
    end))
end

local AutoFarmToggle = farmingTab:AddToggle("AutoFarm", { Title = "Auto Farm", Default = false })
AutoFarmToggle:OnChanged(function()
    local Value = Options.AutoFarm.Value
    if Value then
        stopAll()
        AutoFarmEnabled = true
        if rebirths.Value < 10 then
            RunScriptBelow10()
        else
            RunScriptAboveOrEqual10()
        end
    else
        stopAll()
    end
end)

local LockPositionEnabled = false
local LockPositionConnection = nil
local LockedCFrame = nil

local function EnableLockPosition()
    if not localPlayer.Character then return end
    local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    LockedCFrame = hrp.CFrame
    
    LockPositionConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if LockPositionEnabled and localPlayer.Character and LockedCFrame then
            local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = LockedCFrame
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

local function DisableLockPosition()
    if LockPositionConnection then
        LockPositionConnection:Disconnect()
        LockPositionConnection = nil
    end
    LockedCFrame = nil
end

local LockPositionToggle = farmingTab:AddToggle("LockPosition", { Title = "Lock Position", Default = false })
LockPositionToggle:OnChanged(function()
    LockPositionEnabled = Options.LockPosition.Value
    if LockPositionEnabled then
        EnableLockPosition()
    else
        DisableLockPosition()
    end
end)

-- Update locked position when character moves (optional - can be disabled)
localPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if LockPositionEnabled then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            LockedCFrame = hrp.CFrame
        end
    end
end)

local AutoGlitchEnabled = false
local glitchThreads = {}
local rng2 = Random.new()

local function stopAllGlitch()
    AutoGlitchEnabled = false
    for _, t in ipairs(glitchThreads) do
        if t then task.cancel(t) end
    end
    table.clear(glitchThreads)
end

local function CollectPrompts(folder, positions)
    local EPSILON = 2.0
    local prompts = {}
    
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local pos = obj.Position
            for _, targetPos in ipairs(positions) do
                if (pos - targetPos).Magnitude < EPSILON then
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("ProximityPrompt") then
                            table.insert(prompts, child)
                            break
                        end
                    end
                end
            end
        end
    end
    return prompts
end

local function RunGlitchBelow10()
    local TARGET_POSITIONS = {
        Vector3.new(-41.5637741, 3.47935009, 44.4185333),
        Vector3.new(-24.1162872, 3.47935009, 44.4185333),
    }
    
    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MachineRemote = ReplicatedStorage:WaitForChild("RemotesEvent"):WaitForChild("MachineActiveEvent")
    
    local prompts = CollectPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then 
        return 
    end

    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local prompt = prompts[rng2:NextInteger(1, #prompts)]
                if prompt and prompt.Enabled and prompt.Parent then
                    local machinePart = prompt.Parent
                    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(machinePart.Position + Vector3.new(0, 3, 0))
                    task.wait(0.1)
                    fireproximityprompt(prompt)
                end
            end
            task.wait(0.3)
        end
    end))
    
    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            if localPlayer.Character then
                pcall(function()
                    MachineRemote:FireServer()
                end)
            end
            task.wait(0.1)
        end
    end))
end

local function RunGlitchAbove10()
    local TARGET_POSITIONS = {
        Vector3.new(2712.48022, 3.71804452, 299.783295),
        Vector3.new(2691.11182, 3.71804452, 299.783295),
        Vector3.new(2613.02808, 4.78257084, 289.732025),
        Vector3.new(2584.5542, 4.78257084, 289.732025),
    }
    
    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MachineRemote = ReplicatedStorage:WaitForChild("RemotesEvent"):WaitForChild("MachineActiveEvent")
    
    local prompts = CollectPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then 
        return 
    end

    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local prompt = prompts[rng2:NextInteger(1, #prompts)]
                if prompt and prompt.Enabled and prompt.Parent then
                    local machinePart = prompt.Parent
                    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(machinePart.Position + Vector3.new(0, 3, 0))
                    task.wait(0.1)
                    fireproximityprompt(prompt)
                end
            end
            task.wait(0.3)
        end
    end))
    
    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            if localPlayer.Character then
                pcall(function()
                    MachineRemote:FireServer()
                end)
            end
            task.wait(0.05)
        end
    end))
end

local AutoGlitchToggle = farmingTab:AddToggle("AutoGlitch", { Title = "Auto Glitch", Default = false })
AutoGlitchToggle:OnChanged(function()
    local Value = Options.AutoGlitch.Value
    if Value then
        stopAllGlitch()
        AutoGlitchEnabled = true
        if rebirths.Value <= 10 then
            RunGlitchBelow10()
        else
            RunGlitchAbove10()
        end
    else
        stopAllGlitch()
    end
end)

-- ===========================================================
-- AUTO REBIRTH (in Rebirths Tab)
-- ===========================================================
local AutoRebirth = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoRebirthToggle = farmingTab:AddToggle("AutoRebirth", { Title = "Auto Rebirth", Default = false })
AutoRebirthToggle:OnChanged(function()
    AutoRebirth = Options.AutoRebirth.Value
end)

task.spawn(function()
    while true do
        if AutoRebirth then
            pcall(function()
                ReplicatedStorage
                    :WaitForChild("RemotesEvent")
                    :WaitForChild("RebirthEvent")
                    :FireServer()
            end)
        end
        task.wait(0.5)
    end
end)

-- ===========================================================
--  TAB RACE (Killer) - Kill features
-- ===========================================================
local playerService = game:GetService("Players")
local localPly = playerService.LocalPlayer

local runningKill = false
local whitelist = {}
local selectedPlayerName = nil

local function EquipTool(toolName)
    local backpack = localPly:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(toolName)
        if tool and localPly.Character and not localPly.Character:FindFirstChild(toolName) then
            local humanoid = localPly.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:EquipTool(tool) end
        end
    end
end

local function TeleportToTarget()
    if not selectedPlayerName then return end
    local target = playerService:FindFirstChild(selectedPlayerName)
    if not target or whitelist[target.Name] then return end
    if not target.Character or not localPly.Character then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = localPly.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end
    myHRP.CFrame = targetHRP.CFrame
end

local function AutoKillOne()
    while runningKill do
        TeleportToTarget()
        EquipTool("Punch")
        local combat = localPly.Character and localPly.Character:FindFirstChild("Punch")
        if combat then
            combat:Activate()
        end
        task.wait(0.05)
    end
end

local function GetPlayerList()
    local list = {}
    for _, plr in ipairs(playerService:GetPlayers()) do
        if plr ~= localPly then
            table.insert(list, plr.Name)
        end
    end
    return list
end

local PlayerDropdown = Killer:AddDropdown("SelectPlayer", {
    Title = "Select Player",
    Values = GetPlayerList(),
    Multi = false,
    Default = 1,
})

PlayerDropdown:OnChanged(function(Value)
    selectedPlayerName = Value
end)

local function RefreshPlayerDropdown()
    PlayerDropdown:SetValues(GetPlayerList())
end

task.wait()
RefreshPlayerDropdown()

playerService.PlayerAdded:Connect(function()
    task.wait(0.1)
    RefreshPlayerDropdown()
end)

playerService.PlayerRemoving:Connect(function(plr)
    task.wait()
    RefreshPlayerDropdown()
    if selectedPlayerName == plr.Name then
        selectedPlayerName = nil
    end
end)

-- Toggle Kill Player
local KillPlayerToggle = Killer:AddToggle("KillPlayer", { Title = "Kill Player", Default = false })
KillPlayerToggle:OnChanged(function()
    runningKill = Options.KillPlayer.Value
    if runningKill then
        task.spawn(AutoKillOne)
    end
end)

-- Auto-restart saat respawn (Kill Player)
localPly.CharacterAdded:Connect(function()
    task.wait(1)
    if Options.KillPlayer.Value then
        runningKill = true
        task.spawn(AutoKillOne)
    end
end)

-- ===========================================================
-- AUTO KILL ALL (in Race Tab)
-- ===========================================================
local runningKillAll = false

local function EquipToolAll(toolName)
    local backpack = localPly:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(toolName)
        if tool and localPly.Character and not localPly.Character:FindFirstChild(toolName) then
            local humanoid = localPly.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
        end
    end
end

local function TeleportKillTargets()
    for _, plr in ipairs(playerService:GetPlayers()) do
        if runningKillAll
        and plr ~= localPly
        and not whitelist[plr.Name]
        and plr.Character
        and plr.Character:FindFirstChild("HumanoidRootPart")
        and localPly.Character
        and localPly.Character:FindFirstChild("HumanoidRootPart") then

            local startTime = tick()

            while tick() - startTime < 0.5 and runningKillAll do
                local myHRP = localPly.Character.HumanoidRootPart
                local targetHRP = plr.Character.HumanoidRootPart
                myHRP.CFrame = targetHRP.CFrame
                EquipToolAll("Punch")
                local combat = localPly.Character:FindFirstChild("Punch")
                if combat then
                    combat:Activate()
                end
                task.wait(0.05)
            end

        end
    end
end

local function AutoKillAll()
    while runningKillAll do
        TeleportKillTargets()
        task.wait(0.1)
    end
end

local AutoKillToggle = Killer:AddToggle("AutoKill", { Title = "Auto Kill All", Default = false })
AutoKillToggle:OnChanged(function()
    runningKillAll = Options.AutoKill.Value
    if runningKillAll then
        task.spawn(AutoKillAll)
    end
end)

-- Auto-restart saat respawn (Auto Kill All)
localPly.CharacterAdded:Connect(function()
    task.wait(1)
    if Options.AutoKill.Value then
        runningKillAll = true
        task.spawn(AutoKillAll)
    end
end)

-- ===========================================================
--  TAB LOCATIONS (TeleportTab) - Teleport features
-- ===========================================================

-- ===========================================================
--  TAB CRYSTALS (Shop) - EGG TYPE SELECTION ONLY
-- ===========================================================

local SelectedEggType = "legendary"
local ToggleEggsEnabled = false
local AutoEquipEnabled = false

local OpenPetRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("RemotesEvent")
    :WaitForChild("OpenPetEvent")

-- Egg type mapping
local EggTypes = {
    Common    = "common",
    Rare      = "rare",
    Epic      = "epic",
    Legendary = "legendary",
    Mythic    = "mythic"
}

-- Egg Selection Dropdown
local EggsDropdown = Shop:AddDropdown("SelectEgg", {
    Title = "Select Egg Type",
    Values = {"Common", "Rare", "Epic", "Legendary", "Mythic"},
    Multi = false,
    Default = 4, -- Default to Legendary
})

EggsDropdown:OnChanged(function(Value)
    SelectedEggType = EggTypes[Value]
end)

-- Auto Open Eggs Toggle
local AutoEggsToggle = Shop:AddToggle("AutoEggs", { Title = "Auto Open Eggs", Default = false })
AutoEggsToggle:OnChanged(function()
    ToggleEggsEnabled = Options.AutoEggs.Value
    
    if ToggleEggsEnabled then
        task.spawn(function()
            while ToggleEggsEnabled do
                local success, err = pcall(function()
                    OpenPetRemote:FireServer(SelectedEggType)
                end)
                
                if not success then
                    warn("Auto Egg Error: " .. tostring(err))
                end
                
                task.wait(0.3)
            end
        end)
    end
end)

-- INSTANT HATCH
local RemotesEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent")
local OpenPetEvent = RemotesEvent:WaitForChild("OpenPetEvent")

local instantHatchEnabled = false
local hatchLoop = nil
local hatchConnection = nil

local function disableConnections()
    pcall(function()
        for _, v in pairs(getconnections(OpenPetEvent.OnClientEvent)) do
            v:Disable()
        end
    end)
end

local function enableConnections()
    pcall(function()
        for _, v in pairs(getconnections(OpenPetEvent.OnClientEvent)) do
            v:Enable()
        end
    end)
end

local function enableInstantHatch()
    disableConnections()

    hatchLoop = task.spawn(function()
        while instantHatchEnabled do
            task.wait(1)
            if instantHatchEnabled then
                disableConnections()
            end
        end
    end)

    hatchConnection = OpenPetEvent.OnClientEvent:Connect(function(petName, eggModel)
        if not instantHatchEnabled then return end
        if not petName or not eggModel then return end
        pcall(function()
            if eggModel and eggModel:IsA("BasePart") then
                eggModel.Transparency = 1
            end
        end)
    end)

    print("Instant Hatch: ENABLED")
end

local function disableInstantHatch()
    instantHatchEnabled = false
    
    if hatchLoop then
        task.cancel(hatchLoop)
        hatchLoop = nil
    end

    if hatchConnection then
        hatchConnection:Disconnect()
        hatchConnection = nil
    end

    enableConnections()

    print("Instant Hatch: DISABLED")
end

-- Create the Instant Hatch Toggle in Shop Tab
local InstantHatchToggle = Shop:AddToggle("InstantHatch", {
    Title = "Instant Hatch",
    Description = "Skip egg hatching animation",
    Default = false
})

InstantHatchToggle:OnChanged(function(Value)
    instantHatchEnabled = Value
    if instantHatchEnabled then
        enableInstantHatch()
    else
        disableInstantHatch()
    end
end)

-- AUTO SELL PETS TOGGLE
Shop:AddButton({
    Title = "Auto Sell",
    Description = "Open Sell Pets UI",
    Callback = function()
        print("open sell pets Ui")
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/bbroblox03-ctrl/Sxript-Loader/refs/heads/main/asdasd"))()
    end
})

-- AUTO SPIN
local AutoSpin = false

local AutoSpinToggle = Misc:AddToggle("AutoSpin", { Title = "Auto Spin", Default = false })
AutoSpinToggle:OnChanged(function()
    AutoSpin = Options.AutoSpin.Value
    if AutoSpin then
        task.spawn(function()
            while AutoSpin do
                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("RemotesEvent")
                        :WaitForChild("SpinFunction")
                        :InvokeServer()
                end)
                task.wait(0.5)
            end
        end)
    end
end)

local autoEatConnection = nil

local AutoEatChocolateToggle = Misc:AddToggle("AutoEatChocolate", { Title = "Auto Eat Chocolate", Default = false })
AutoEatChocolateToggle:OnChanged(function()
    AutoEatChocolate = Options.AutoEatChocolate.Value        
    if AutoEatChocolate then
        task.spawn(function()
            while AutoEatChocolate do
                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("RemotesEvent")
                        :WaitForChild("ChocolateEatEvent")
                        :FireServer()                      
                end)
                task.wait(0.5) -- 0.1 second delay between eats
            end
         end)
     end
end)

-- ANTI AFK
local VirtualUser = game:GetService("VirtualUser")
local AntiAFKConnection = nil

local function EnableAntiAFK()
    if AntiAFKConnection then return end
    AntiAFKConnection = localPly.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

local function DisableAntiAFK()
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
end

local AntiAFKToggle = Misc:AddButton({
    Title = "Anti AFK",
    Description = "Prevents being kicked for AFK",
    Callback = function()
        local VirtualUser = game:GetService("VirtualUser")
        
        local gui = Instance.new("ScreenGui")
        gui.Parent = player.PlayerGui
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(0, 200, 0, 50)
        textLabel.Position = UDim2.new(0.5, -100, 0, -50)
        textLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 20
        textLabel.BackgroundTransparency = 1
        textLabel.TextTransparency = 1
        textLabel.Text = "ANTI AFK"
        textLabel.Parent = gui
        
        local timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(0, 200, 0, 30)
        timerLabel.Position = UDim2.new(0.5, -100, 0, -20)
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.Font = Enum.Font.GothamBold
        timerLabel.TextSize = 18
        timerLabel.BackgroundTransparency = 1
        timerLabel.TextTransparency = 1
        timerLabel.Text = "00:00:00"
        timerLabel.Parent = gui
        
        local startTime = tick()
        
        task.spawn(function()
            while true do
                local elapsed = tick() - startTime
                local hours = math.floor(elapsed / 3600)
                local minutes = math.floor((elapsed % 3600) / 60)
                local seconds = math.floor(elapsed % 60)
                timerLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                task.wait(1)
            end
        end)
        
        task.spawn(function()
            while true do
                for i = 0, 1, 0.01 do
                    textLabel.TextTransparency = 1 - i
                    timerLabel.TextTransparency = 1 - i
                    task.wait(0.015)
                end
                task.wait(1.5)
                for i = 0, 1, 0.01 do
                    textLabel.TextTransparency = i
                    timerLabel.TextTransparency = i
                    task.wait(0.015)
                end
                task.wait(0.8)
            end
        end)
        
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            print("AFK prevention completed!")
        end)
    end
})

local creditsSection = Settings:AddSection("Markyy   -    💪🤨👈")


creditsSection:AddButton({
    Title = "TikTok",
    Description = "Follow Me!     👈",
    Callback = function()
        setclipboard('https://www.tiktok.com/@markyy_0311?is_from_webapp=1&sender_device=pc    ')
    end
})

creditsSection:AddButton({
    Title = "Roblox Profile",
    Description = "Visit the creator's profile     👈",
    Callback = function()
        setclipboard("https://www.roblox.com/users/2815154822/profile    ")
    end
})

Window:SelectTab(1)
print("KYYYY HUB Loaded Successfully!")
