local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isRunning = false
local serverSwapEnabled = true
local joinedServers = {}
local failedGames = {}
local currentTargetPlayer = nil
local usersProcessed = 0
local maxUsersPerGame = 3
local followConnection = nil
local messageVariations = {}
local discordVanity = "/husband"

local startSpamming = nil
local stopSpamming = nil

local function generateAdvancedMessageVariations(baseMessage)
    local variations = {}
    
    for i = 1, 8 do
        local variation = baseMessage:lower()
        table.insert(variations, variation)
    end
    
    return variations
end

local function initializeMessageVariations()
    local baseMessages = {
        "ageplayer heaven in {vanity}",
        "cnc and ageplay in vc {vanity}",
        "find your little girl {vanity}",
        "rich dadas in {vanity}",
        "tight pinkcat in {vanity}",
        "ageplayers are in {vanity} >.<",
        "#1 com {vanity}",
        "com stages in {vanity}"
    }
    
    messageVariations = {}
    
    for _, msg in ipairs(baseMessages) do
        local processedMsg = msg:gsub("{vanity}", discordVanity)
        local variations = generateAdvancedMessageVariations(processedMsg)
        for _, variation in ipairs(variations) do
            table.insert(messageVariations, variation)
        end
    end
    
    local directMessages = {
        "add xyz33 for a present:)",
        "add xyz33 for promos like this",
        "add xyz33 blue",
        "dm xyz33 for roles in {vanity}",
        "your all harmless {vanity}",
        "xyz33 has your nitro",
        "xyz33 ifu hvae pinkcat >,,<"
    }
    
    for _, msg in ipairs(directMessages) do
        local processedMsg = msg:gsub("{vanity}", discordVanity)
        local variations = generateAdvancedMessageVariations(processedMsg)
        for _, variation in ipairs(variations) do
            table.insert(messageVariations, variation)
        end
    end
end

local function saveScriptData()
    local data = {
        joinedServers = joinedServers,
        failedGames = failedGames,
        usersProcessed = usersProcessed,
        timestamp = tick(),
        wasRunning = isRunning,
        serverSwapEnabled = serverSwapEnabled,
        discordVanity = discordVanity
    }
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if not success then
        warn("Failed to encode data for saving: " .. tostring(encoded))
        return false
    end
    
    local saveSuccess, saveError = pcall(function()
        local fileFunc = writefile or (syn and syn.writefile) or (fluxus and fluxus.writefile)
        if fileFunc then
            fileFunc("spammer_data.json", encoded)
            print("Data saved successfully - Vanity: " .. tostring(discordVanity) .. ", Running: " .. tostring(isRunning))
            return true
        else
            warn("writefile function not available")
            return false
        end
    end)
    
    if not saveSuccess then
        warn("Failed to save data: " .. tostring(saveError))
        return false
    end
    
    return true
end

local function createModernUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpammerUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 700, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Vanity Spammer"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -70)
    contentFrame.Position = UDim2.new(0, 10, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local leftSection = Instance.new("Frame")
    leftSection.Name = "LeftSection"
    leftSection.Size = UDim2.new(0.48, 0, 1, 0)
    leftSection.Position = UDim2.new(0, 0, 0, 0)
    leftSection.BackgroundTransparency = 1
    leftSection.Parent = contentFrame

    local vanityLabel = Instance.new("TextLabel")
    vanityLabel.Name = "VanityLabel"
    vanityLabel.Size = UDim2.new(1, 0, 0, 25)
    vanityLabel.Position = UDim2.new(0, 0, 0, 0)
    vanityLabel.BackgroundTransparency = 1
    vanityLabel.Text = "Discord Vanity URL:"
    vanityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    vanityLabel.TextSize = 14
    vanityLabel.Font = Enum.Font.Gotham
    vanityLabel.TextXAlignment = Enum.TextXAlignment.Left
    vanityLabel.Parent = leftSection

    local vanityInput = Instance.new("TextBox")
    vanityInput.Name = "VanityInput"
    vanityInput.Size = UDim2.new(1, 0, 0, 40)
    vanityInput.Position = UDim2.new(0, 0, 0, 30)
    vanityInput.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    vanityInput.BorderSizePixel = 0
    vanityInput.Text = discordVanity
    vanityInput.PlaceholderText = "Enter vanity (e.g., /carols)"
    vanityInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    vanityInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    vanityInput.TextSize = 14
    vanityInput.Font = Enum.Font.Gotham
    vanityInput.ClearTextOnFocus = false
    vanityInput.Parent = leftSection

    local vanityCorner = Instance.new("UICorner")
    vanityCorner.CornerRadius = UDim.new(0, 8)
    vanityCorner.Parent = vanityInput

    local vanityStroke = Instance.new("UIStroke")
    vanityStroke.Color = Color3.fromRGB(60, 60, 70)
    vanityStroke.Thickness = 1
    vanityStroke.Parent = vanityInput

    vanityInput.FocusLost:Connect(function()
        discordVanity = vanityInput.Text ~= "" and vanityInput.Text or "/weep"
        pcall(function()
            if initializeMessageVariations then
                initializeMessageVariations()
            end
        end)
        pcall(function()
            if saveScriptData then
                saveScriptData()
            end
        end)
    end)

    local serverSwapFrame = Instance.new("Frame")
    serverSwapFrame.Name = "ServerSwapFrame"
    serverSwapFrame.Size = UDim2.new(1, 0, 0, 50)
    serverSwapFrame.Position = UDim2.new(0, 0, 0, 85)
    serverSwapFrame.BackgroundTransparency = 1
    serverSwapFrame.Parent = leftSection

    local serverSwapLabel = Instance.new("TextLabel")
    serverSwapLabel.Name = "ServerSwapLabel"
    serverSwapLabel.Size = UDim2.new(1, -60, 1, 0)
    serverSwapLabel.Position = UDim2.new(0, 0, 0, 0)
    serverSwapLabel.BackgroundTransparency = 1
    serverSwapLabel.Text = "Enable Server Swapping"
    serverSwapLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    serverSwapLabel.TextSize = 14
    serverSwapLabel.Font = Enum.Font.Gotham
    serverSwapLabel.TextXAlignment = Enum.TextXAlignment.Left
    serverSwapLabel.Parent = serverSwapFrame

    local serverSwapToggle = Instance.new("TextButton")
    serverSwapToggle.Name = "ServerSwapToggle"
    serverSwapToggle.Size = UDim2.new(0, 50, 0, 28)
    serverSwapToggle.Position = UDim2.new(1, -50, 0, 11)
    serverSwapToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
    serverSwapToggle.BorderSizePixel = 0
    serverSwapToggle.Text = ""
    serverSwapToggle.Parent = serverSwapFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 14)
    toggleCorner.Parent = serverSwapToggle

    local toggleDot = Instance.new("Frame")
    toggleDot.Name = "ToggleDot"
    toggleDot.Size = UDim2.new(0, 22, 0, 22)
    toggleDot.Position = UDim2.new(1, -24, 0, 3)
    toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = serverSwapToggle

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 11)
    dotCorner.Parent = toggleDot

    local function updateToggle()
        if serverSwapEnabled then
            TweenService:Create(serverSwapToggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 80)}):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -24, 0, 3)}):Play()
        else
            TweenService:Create(serverSwapToggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 3)}):Play()
        end
    end

    serverSwapToggle.MouseButton1Click:Connect(function()
        serverSwapEnabled = not serverSwapEnabled
        updateToggle()
        pcall(function()
            if saveScriptData then
                saveScriptData()
            end
        end)
    end)

    updateToggle()

    local rightSection = Instance.new("Frame")
    rightSection.Name = "RightSection"
    rightSection.Size = UDim2.new(0.48, 0, 1, 0)
    rightSection.Position = UDim2.new(0.52, 0, 0, 0)
    rightSection.BackgroundTransparency = 1
    rightSection.Parent = contentFrame

    local startButton = Instance.new("TextButton")
    startButton.Name = "StartButton"
    startButton.Size = UDim2.new(1, 0, 0, 45)
    startButton.Position = UDim2.new(0, 0, 0, 0)
    startButton.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
    startButton.BorderSizePixel = 0
    startButton.Text = "Start"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextSize = 16
    startButton.Font = Enum.Font.GothamBold
    startButton.Parent = rightSection

    local startCorner = Instance.new("UICorner")
    startCorner.CornerRadius = UDim.new(0, 8)
    startCorner.Parent = startButton

    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Size = UDim2.new(1, 0, 0, 45)
    stopButton.Position = UDim2.new(0, 0, 0, 55)
    stopButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    stopButton.BorderSizePixel = 0
    stopButton.Text = "Stop"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextSize = 16
    stopButton.Font = Enum.Font.GothamBold
    stopButton.Parent = rightSection

    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 8)
    stopCorner.Parent = stopButton

    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(1, 0, 0, 100)
    statusFrame.Position = UDim2.new(0, 0, 0, 110)
    statusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = rightSection

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Idle"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusFrame

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -20, 0, 60)
    statsLabel.Position = UDim2.new(0, 10, 0, 35)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Users Processed: 0\nServers Visited: 0"
    statsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statsLabel.TextSize = 12
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.Parent = statusFrame

    local function updateStatus(text, color)
        statusLabel.Text = "Status: " .. text
        statusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    end

    local function updateStats()
        local serverCount = 0
        for _ in pairs(joinedServers) do
            serverCount = serverCount + 1
        end
        statsLabel.Text = string.format("Users Processed: %d\nServers Visited: %d", usersProcessed, serverCount)
    end

    startButton.MouseButton1Click:Connect(function()
        if not isRunning then
            discordVanity = vanityInput.Text ~= "" and vanityInput.Text or "/husband"
            pcall(function()
                if initializeMessageVariations then
                    initializeMessageVariations()
                end
            end)
            isRunning = true
            updateStatus("Running", Color3.fromRGB(50, 200, 80))
            pcall(function()
                if saveScriptData then
                    saveScriptData()
                end
            end)
            pcall(function()
                if startSpamming then
                    startSpamming()
                end
            end)
        end
    end)

    stopButton.MouseButton1Click:Connect(function()
        if isRunning then
            pcall(function()
                if stopSpamming then
                    stopSpamming()
                end
            end)
            updateStatus("Stopped", Color3.fromRGB(220, 50, 50))
        end
    end)

    spawn(function()
        while screenGui.Parent do
            updateStats()
            wait(1)
        end
    end)

    local dragging = false
    local dragStart = nil
    local startPos = nil

    local function updateDrag(input)
        if dragging and dragStart and startPos then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, screenGui.AbsoluteSize.X - mainFrame.AbsoluteSize.X)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, screenGui.AbsoluteSize.Y - mainFrame.AbsoluteSize.Y)
            mainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input)
        end
    end)

    return screenGui, updateStatus, updateStats, vanityInput
end

local function applyNetworkOptimizations()
    local flags = {
        DFIntTaskSchedulerTargetFps = 15,
        FFlagDebugDisableInGameMenuV2 = true,
        FFlagDisableInGameMenuV2 = true,
        DFIntTextureQualityOverride = 1,
        FFlagRenderNoLights = true,
        FFlagRenderNoShadows = true,
        DFIntDebugFRMQualityLevelOverride = 1,
        DFFlagTextureQualityOverrideEnabled = true,
        FFlagHandleAltEnterFullscreenManually = false,
        DFIntConnectionMTUSize = 1500,
        DFIntMaxMissedWorldStepsRemembered = 1,
        DFIntDefaultTimeoutTimeMs = 2000,
        FFlagDebugSimIntegrationStabilityTesting = false,
        DFFlagDebugRenderForceTechnologyVoxel = true,
        FFlagUserHandleCameraToggle = false
    }
    
    for flag, value in pairs(flags) do
        pcall(function()
            game:SetFastFlag(flag, value)
        end)
    end
end

local function optimizeClientPerformance()
    pcall(function()
        settings().Network.IncomingReplicationLag = 0
        settings().Network.RenderStreamedRegions = false
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.MaterialQualityLevel = Enum.MaterialQualityLevel.Level01
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnvironmentalPhysicsThrottle.DefaultAuto
    end)
end

local function forceDisableUI()
    spawn(function()
        while wait(0.5) do
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
                StarterGui:SetCore("TopbarEnabled", false)
            end)
            
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in pairs(playerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "Chat" and gui.Name ~= "SpammerUI" then
                            gui.Enabled = false
                        end
                    end
                end
            end)
            
            pcall(function()
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.FieldOfView = 20
                end
            end)
        end
    end)
end

local function forceChatFeatures()
    spawn(function()
        while wait(0.2) do
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
            end)
            
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local chatGui = playerGui:FindFirstChild("Chat")
                    if chatGui then
                        chatGui.Enabled = true
                    end
                end
            end)
            
            pcall(function()
                if TextChatService.ChatInputBarConfiguration then
                    TextChatService.ChatInputBarConfiguration.Enabled = true
                end
            end)
            
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                break
            end
        end
    end)
end

local function optimizeRendering()
    spawn(function()
        local heartbeatCount = 0
        RunService.Heartbeat:Connect(function()
            heartbeatCount = heartbeatCount + 1
            if heartbeatCount % 20 == 0 then
                pcall(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Decal") or obj:IsA("Texture") then
                            obj.Transparency = 1
                        elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                            obj.Enabled = false
                        elseif obj:IsA("Sound") then
                            obj.Volume = 0
                        end
                    end
                end)
            end
        end)
    end)
end

local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

local function queueScript()
    pcall(function()
        if queueteleport and type(queueteleport) == "function" then
            queueteleport([[
wait(2)
print("Auto-restarting script...")
local success = pcall(function()
    loadstring(game:HttpGet("https://github.com/sketchboyroblox/betterlol/blob/main/hi1.lua"))()
end)
if not success then
    wait(3)
    pcall(function()
        loadstring(game:HttpGet("https://github.com/sketchboyroblox/betterlol/blob/main/hi1.lua"))()
    end)
end
]])
            print("Script queued for auto-restart")
        end
    end)
end

local function loadScriptData()
    local success, content = pcall(function()
        local fileCheck = isfile or (syn and syn.isfile) or (fluxus and fluxus.isfile)
        local fileRead = readfile or (syn and syn.readfile) or (fluxus and fluxus.readfile)
        
        if fileCheck and fileRead and fileCheck("spammer_data.json") then
            return fileRead("spammer_data.json")
        end
        return nil
    end)
    
    if success and content then
        local success2, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        
        if success2 and data then
            joinedServers = data.joinedServers or {}
            failedGames = data.failedGames or {}
            usersProcessed = data.usersProcessed or 0
            serverSwapEnabled = data.serverSwapEnabled ~= false
            if data.discordVanity then
                discordVanity = data.discordVanity
            end
            if data.wasRunning then
                isRunning = true
            end
            print("Data loaded successfully - Vanity: " .. tostring(discordVanity) .. ", Was Running: " .. tostring(data.wasRunning))
            return true, data.wasRunning or false
        else
            warn("Failed to decode saved data: " .. tostring(data))
        end
    else
        print("No saved data found or failed to read file")
    end
    
    return false, false
end

local function waitForStableConnection()
    local connectionAttempts = 0
    while connectionAttempts < 10 do
        local connected = false
        pcall(function()
            if game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character then
                connected = true
            end
        end)
        
        if connected then
            break
        end
        
        wait(0.2)
        connectionAttempts = connectionAttempts + 1
    end
end

local function waitForGameLoad()
    print("Starting enhanced game load sequence...")
    
    waitForStableConnection()
    
    local hasCharacter = false
    pcall(function()
        if player and player.Character then
            hasCharacter = true
        end
    end)
    
    if hasCharacter then
        print("Character loaded successfully")
    else
        print("Character not loaded - continuing anyway (chat is ready)")
    end
    
    applyNetworkOptimizations()
    optimizeClientPerformance()
    
    print("Setting up UI and chat...")
    forceDisableUI()
    forceChatFeatures()
    optimizeRendering()
    
    wait(1)
    
    local chatAttempts = 0
    while chatAttempts < 15 do
        local chatReady = false
        pcall(function()
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                chatReady = true
            end
        end)
        
        if chatReady then
            print("Chat system ready!")
            break
        end
        
        wait(0.3)
        chatAttempts = chatAttempts + 1
    end
    
    if chatAttempts >= 15 then
        print("Chat not ready after 15 attempts, continuing anyway...")
    end
    
    print("Game load sequence complete!")
    return true
end

local function cleanupOldServers()
    local currentTime = tick()
    for serverId, joinTime in pairs(joinedServers) do
        if currentTime - joinTime >= 45 then
            joinedServers[serverId] = nil
        end
    end
    
    for gameId, failTime in pairs(failedGames) do
        if currentTime - failTime >= 90 then
            failedGames[gameId] = nil
        end
    end
end

local function sendMessage(message)
    local success = false
    local attempts = 0
    
    while not success and attempts < 15 do
        local chatReady = false
        local targetChannel = nil
        
        pcall(function()
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                chatReady = true
                targetChannel = TextChatService.ChatInputBarConfiguration.TargetTextChannel
            end
        end)
        
        if not chatReady then
            wait(0.3)
            attempts = attempts + 1
            if attempts == 5 then
                print("Waiting for chat to be ready (attempt " .. attempts .. ")...")
            end
        else
            local sendSuccess, sendError = pcall(function()
                if targetChannel then
                    targetChannel:SendAsync(message)
                    return true
                end
            end)
            
            if sendSuccess then
                success = true
            else
                attempts = attempts + 1
                if attempts <= 3 then
                    wait(0.2)
                else
                    wait(0.5)
                end
                if attempts == 10 then
                    warn("Still trying to send message (attempt " .. attempts .. ")...")
                end
            end
        end
    end
    
    if not success then
        warn("Failed to send message after " .. attempts .. " attempts: " .. tostring(message))
    end
    
    return success
end

local function getRandomMessages()
    local selectedMessages = {}
    
    for i = 1, 3 do
        if #messageVariations > 0 then
            local randomIndex = math.random(1, #messageVariations)
            table.insert(selectedMessages, messageVariations[randomIndex])
        end
    end
    
    return selectedMessages
end

local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

local function waitForCharacterReady(targetPlayer, isLocalPlayer)
    local character = nil
    local rootPart = nil
    local attempts = 0
    local maxAttempts = isLocalPlayer and 50 or 30
    
    while not rootPart and attempts < maxAttempts do
        pcall(function()
            if isLocalPlayer then
                if player and player.Character then
                    character = player.Character
                    if character:FindFirstChild("HumanoidRootPart") then
                        rootPart = character.HumanoidRootPart
                        if character:FindFirstChild("Humanoid") then
                            local humanoid = character.Humanoid
                            if humanoid.Health > 0 then
                                return
                            end
                        end
                    end
                end
            else
                if targetPlayer and targetPlayer.Character then
                    character = targetPlayer.Character
                    if character:FindFirstChild("HumanoidRootPart") then
                        rootPart = character.HumanoidRootPart
                    end
                end
            end
        end)
        
        if not rootPart then
            wait(0.1)
            attempts = attempts + 1
        end
    end
    
    return rootPart
end

local function instantTeleportToPlayer(targetPlayer)
    if not targetPlayer then
        return false
    end
    
    local targetRoot = waitForCharacterReady(targetPlayer, false)
    if not targetRoot then
        return false
    end
    
    local myRoot = waitForCharacterReady(nil, true)
    if not myRoot then
        return false
    end
    
    local teleportSuccess = false
    pcall(function()
        if targetRoot and targetRoot.Parent and myRoot and myRoot.Parent then
            local targetPosition = targetRoot.Position
            local newPosition = targetPosition + Vector3.new(math.random(-2, 2), 8, math.random(-2, 2))
            
            myRoot.CFrame = CFrame.new(newPosition)
            wait(0.1)
            
            local currentPos = myRoot.Position
            local distance = (currentPos - targetPosition).Magnitude
            if distance < 30 then
                teleportSuccess = true
            end
        end
    end)
    
    return teleportSuccess
end

local function spinAroundPlayer(targetPlayer, duration)
    if not targetPlayer then
        return
    end
    
    local targetChar = nil
    pcall(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetChar = targetPlayer.Character
        end
    end)
    
    if not targetChar then
        return
    end
    
    local character = nil
    pcall(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            character = player.Character
        end
    end)
    
    if not character then
        return
    end
    
    local startTime = tick()
    local radius = 5
    local speed = 3
    
    spawn(function()
        while tick() - startTime < duration and isRunning do
            pcall(function()
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and
                   player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = targetPlayer.Character.HumanoidRootPart.Position
                    local angle = (tick() * speed) % (math.pi * 2)
                    local offsetX = math.cos(angle) * radius
                    local offsetZ = math.sin(angle) * radius
                    local newPosition = targetPos + Vector3.new(offsetX, 3, offsetZ)
                    local lookAtTarget = CFrame.new(newPosition, targetPos)
                    player.Character.HumanoidRootPart.CFrame = lookAtTarget
                end
            end)
            wait(0.03)
        end
    end)
end

local function getTopThreePlayers()
    local players = {}
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p and p ~= player then
                pcall(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        table.insert(players, p)
                    end
                end)
            end
        end
    end)
    
    local selectedPlayers = {}
    for i = 1, math.min(3, #players) do
        if #players > 0 then
            local randomIndex = math.random(1, #players)
            table.insert(selectedPlayers, players[randomIndex])
            table.remove(players, randomIndex)
        end
    end
    
    return selectedPlayers
end

local function processMultipleUsers()
    local targetPlayers = getTopThreePlayers()
    if #targetPlayers == 0 then
        print("No players found to process")
        wait(0.5)
        return false
    end
    
    print("Processing " .. #targetPlayers .. " users simultaneously")
    
    local myCharacterReady = false
    pcall(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                myCharacterReady = true
            end
        end
    end)
    
    if not myCharacterReady then
        print("Waiting for character to be ready...")
        local waitAttempts = 0
        while not myCharacterReady and waitAttempts < 30 do
            wait(0.2)
            pcall(function()
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        myCharacterReady = true
                    end
                end
            end)
            waitAttempts = waitAttempts + 1
        end
        
        if myCharacterReady then
            print("Character is now ready!")
        else
            print("Character still not ready after 6 seconds, attempting teleport anyway...")
        end
    end
    
    for _, targetPlayer in ipairs(targetPlayers) do
        spawn(function()
            print("Attempting to teleport to " .. targetPlayer.Name .. "...")
            local teleported = false
            local teleportError = nil
            
            local success, result = pcall(function()
                teleported = instantTeleportToPlayer(targetPlayer)
                return teleported
            end)
            
            if not success then
                teleportError = result
                warn("Teleport error for " .. targetPlayer.Name .. ": " .. tostring(teleportError))
            end
            
            if teleported then
                print("Successfully teleported to " .. targetPlayer.Name)
                wait(0.1)
                spinAroundPlayer(targetPlayer, 2.5)
            else
                if teleportError then
                    print("Could not teleport to " .. targetPlayer.Name .. " - Error: " .. tostring(teleportError))
                else
                    print("Could not teleport to " .. targetPlayer.Name .. " (character may not be loaded)")
                end
            end
            
            local selectedMessages = getRandomMessages()
            print("Sending " .. #selectedMessages .. " messages to " .. targetPlayer.Name)
            
            for i, message in ipairs(selectedMessages) do
                if not isRunning then break end
                local sent = sendMessage(message)
                if sent then
                    print("Sent to " .. targetPlayer.Name .. ": " .. message)
                else
                    warn("Failed to send message to " .. targetPlayer.Name .. ": " .. message)
                end
                wait(math.random(0.3, 0.6))
            end
        end)
        wait(0.05)
    end
    
    wait(2)
    return true
end

local function getAvailableServers(gameId)
    local availableServers = {}
    local httpAttempts = 0
    
    while httpAttempts < 3 do
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100", true)
        end)
        
        if success then
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(result)
            end)
            
            if parseSuccess and data and data.data and type(data.data) == "table" then
                for _, server in ipairs(data.data) do
                    if server and 
                       server.id and 
                       server.playing and 
                       server.maxPlayers and
                       server.ping and
                       server.playing >= 3 and
                       server.playing < server.maxPlayers * 0.9 and
                       server.ping < 180 and
                       server.id ~= game.JobId and 
                       not joinedServers[server.id] then
                        table.insert(availableServers, {
                            id = server.id,
                            playing = server.playing,
                            maxPlayers = server.maxPlayers,
                            ping = server.ping,
                            priority = server.playing - (server.ping / 8)
                        })
                    end
                end
                
                table.sort(availableServers, function(a, b)
                    return a.priority > b.priority
                end)
                break
            end
        end
        
        httpAttempts = httpAttempts + 1
        if httpAttempts < 3 then
            wait(2)
        end
    end
    
    return availableServers
end

local function selectBestServer(availableServers)
    if #availableServers == 0 then
        return nil
    end
    
    local optimalServers = {}
    
    for _, server in ipairs(availableServers) do
        local populationRatio = server.playing / server.maxPlayers
        if server.ping < 120 and server.playing >= 4 and populationRatio >= 0.2 and populationRatio <= 0.8 then
            table.insert(optimalServers, server)
        end
    end
    
    if #optimalServers > 0 then
        return optimalServers[math.random(1, math.min(2, #optimalServers))]
    else
        return availableServers[math.random(1, math.min(2, #availableServers))]
    end
end

local function tryTeleportWithRetry(gameId, serverId)
    local maxRetries = 3
    
    for attempt = 1, maxRetries do
        local success, errorMsg = pcall(function()
            wait(0.5)
            
            if serverId then
                TeleportService:TeleportToPlaceInstance(tonumber(gameId), serverId, player)
            else
                TeleportService:Teleport(tonumber(gameId), player)
            end
        end)
        
        if success then
            return true
        else
            print("Teleport attempt " .. attempt .. " failed: " .. tostring(errorMsg))
            
            if attempt < maxRetries then
                wait(math.random(2, 4))
            else
                failedGames[gameId] = tick()
                return false
            end
        end
    end
    
    return false
end

local function teleportToNewServer()
    if not serverSwapEnabled then
        print("Server swapping is disabled")
        return
    end
    
    cleanupOldServers()
    saveScriptData()
    queueScript()
    
    wait(1)
    
    local currentGameId = tostring(game.PlaceId)
    local attempts = 0
    local maxAttempts = 5
    
    while attempts < maxAttempts and isRunning do
        print("Server search attempt " .. (attempts + 1) .. " for current game: " .. currentGameId)
        
        local availableServers = getAvailableServers(currentGameId)
        
        if #availableServers > 0 then
            local selectedServer = selectBestServer(availableServers)
            
            if selectedServer then
                joinedServers[selectedServer.id] = tick()
                saveScriptData()
                
                print("Attempting to join new server: " .. selectedServer.id)
                if tryTeleportWithRetry(currentGameId, selectedServer.id) then
                    return
                end
            end
        end
        
        print("No suitable servers found, trying random server hop...")
        if tryTeleportWithRetry(currentGameId, nil) then
            return
        end
        
        attempts = attempts + 1
        wait(math.random(3, 6))
    end
    
    print("All server hop attempts failed, retrying in 10 seconds...")
    wait(10)
    if isRunning and serverSwapEnabled then
        teleportToNewServer()
    end
end

startSpamming = function()
    if not isRunning then
        print("Cannot start spamming - isRunning is false")
        return
    end
    
    print("startSpamming() called - isRunning: " .. tostring(isRunning))
    spawn(function()
        pcall(function()
            print("Starting game load in background...")
            spawn(function()
                waitForGameLoad()
            end)
            
            wait(2)
            
            if not isRunning then 
                print("Spam process stopped during initialization")
                return 
            end
            
            print("Starting spam process (chat will be checked during message sending)...")
            
            local processedInThisGame = 0
            local noPlayersCount = 0
            
            while processedInThisGame < maxUsersPerGame and isRunning do
                if processMultipleUsers() then
                    processedInThisGame = processedInThisGame + 1
                    usersProcessed = usersProcessed + 1
                    noPlayersCount = 0
                    saveScriptData()
                    print("Processed batch " .. processedInThisGame .. "/" .. maxUsersPerGame)
                    wait(math.random(0.5, 1))
                else
                    noPlayersCount = noPlayersCount + 1
                    if noPlayersCount % 5 == 0 then
                        print("No players found to process (attempt " .. noPlayersCount .. "), waiting...")
                    end
                    wait(0.5)
                end
            end
            
            if isRunning and serverSwapEnabled then
                print("Max users reached, hopping to new server...")
                usersProcessed = 0
                saveScriptData()
                wait(1)
                teleportToNewServer()
            elseif not isRunning then
                print("Spam process stopped")
            end
        end)
    end)
end

stopSpamming = function()
    isRunning = false
    stopFollowing()
    saveScriptData()
    print("Script stopped")
end

local function initialize()
    print("Initializing modern UI spammer...")
    
    pcall(function()
        local dataLoaded, wasRunning = loadScriptData()
        
        if dataLoaded then
            print("Loaded saved data - Vanity: " .. tostring(discordVanity) .. ", Was Running: " .. tostring(wasRunning))
        end
        
        initializeMessageVariations()
        
        if game.JobId and game.JobId ~= "" then
            joinedServers[game.JobId] = tick()
        end
        
        local screenGui, updateStatus, updateStats, vanityInput = createModernUI()
        
        if dataLoaded and vanityInput then
            vanityInput.Text = discordVanity
        end
        
        if wasRunning and isRunning then
            print("Resuming spam process with vanity: " .. tostring(discordVanity) .. ", isRunning: " .. tostring(isRunning))
            updateStatus("Running", Color3.fromRGB(50, 200, 80))
            spawn(function()
                wait(1)
                print("Quick check for game readiness...")
                local gameReady = false
                local readyAttempts = 0
                while not gameReady and readyAttempts < 10 do
                    pcall(function()
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                            gameReady = true
                        end
                    end)
                    if not gameReady then
                        wait(0.2)
                        readyAttempts = readyAttempts + 1
                    end
                end
                
                if not gameReady then
                    print("Game not fully ready, starting spam process anyway (will wait during execution)...")
                else
                    print("Game ready!")
                end
                
                print("isRunning check: " .. tostring(isRunning))
                if isRunning then
                    print("Starting spam process immediately...")
                    
                    local startAttempts = 0
                    while startAttempts < 3 do
                        if startSpamming and type(startSpamming) == "function" then
                            print("Calling startSpamming()...")
                            startSpamming()
                            break
                        else
                            wait(0.2)
                            startAttempts = startAttempts + 1
                        end
                    end
                    
                    if startAttempts >= 3 then
                        warn("startSpamming function not found after 3 attempts!")
                    end
                else
                    warn("Cannot start spam - isRunning is false")
                end
            end)
        else
            print("Not resuming - wasRunning: " .. tostring(wasRunning) .. ", isRunning: " .. tostring(isRunning))
        end
        
        print("UI initialized successfully")
    end)
end

initialize()







