local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local character = player.Character or player.CharacterAdded:Wait()
task.wait(1)

local Config = {
    Enabled = false,
    BuyDelay = 0.08,
    SelectedItems = {},
    PurchaseCount = 0,
    MinimizedHeight = 50,
    FullHeight = 640,
    IsMinimized = false
}

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
    warn("❌ Remotes not found!")
    return
end

local BuyItemRemote = Remotes:FindFirstChild("BuyItem")
local BuyGearRemote = Remotes:FindFirstChild("BuyGear")

if not BuyItemRemote or not BuyGearRemote then
    warn("❌ Buy remotes not found!")
    return
end

local RarityColors = {
    Rare = Color3.fromRGB(80, 90, 110),
    Epic = Color3.fromRGB(90, 80, 110),
    Legendary = Color3.fromRGB(110, 100, 80),
    Mythic = Color3.fromRGB(110, 80, 100),
    Godly = Color3.fromRGB(110, 70, 70),
    Secret = Color3.fromRGB(70, 110, 100)
}

local SeedItems = {
    {name = "Cactus Seed", rarity = "Rare"},
    {name = "Strawberry Seed", rarity = "Rare"},
    {name = "Pumpkin Seed", rarity = "Epic"},
    {name = "Sunflower Seed", rarity = "Epic"},
    {name = "Dragon Fruit Seed", rarity = "Legendary"},
    {name = "Eggplant Seed", rarity = "Legendary"},
    {name = "Watermelon Seed", rarity = "Mythic"},
    {name = "Grape Seed", rarity = "Mythic"},
    {name = "Cocotank Seed", rarity = "Godly"},
    {name = "Carnivorous Plant Seed", rarity = "Godly"},
    {name = "Mr Carrot Seed", rarity = "Secret"},
    {name = "Tomatrio Seed", rarity = "Secret"},
    {name = "Shroombino Seed", rarity = "Secret"},
    {name = "Mango Seed", rarity = "Secret"},
    {name = "King Limone Seed", rarity = "Secret"},
    {name = "Starfruit Seed", rarity = "Secret"}
}

local GearItems = {
    {name = "Water Bucket", rarity = "Rare"},
    {name = "Frost Grenade", rarity = "Rare"},
    {name = "Banana Gun", rarity = "Epic"},
    {name = "Frost Blower", rarity = "Legendary"},
    {name = "Carrot Launcher", rarity = "Godly"}
}

local function buySeed(seedName)
    local success = pcall(function()
        BuyItemRemote:FireServer(seedName)
    end)
    
    if success then
        Config.PurchaseCount = Config.PurchaseCount + 1
        return true
    end
    return false
end

local function buyGear(gearName)
    local success = pcall(function()
        BuyGearRemote:FireServer(gearName)
    end)
    
    if success then
        Config.PurchaseCount = Config.PurchaseCount + 1
        return true
    end
    return false
end

local function setupAntiAFK()
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    
    task.spawn(function()
        while task.wait(math.random(60, 120)) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    local randomDirection = Vector3.new(
                        math.random(-5, 5),
                        0,
                        math.random(-5, 5)
                    )
                    humanoid:Move(randomDirection)
                    task.wait(0.5)
                    humanoid:Move(Vector3.new(0, 0, 0))
                end
            end
        end
    end)
end

local function tweenSize(frame, targetSize, time)
    local tween = TweenService:Create(
        frame,
        TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = targetSize}
    )
    tween:Play()
    return tween
end

local function tweenButton(button, properties)
    local tween = TweenService:Create(
        button,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
end

local function createGUI()
    local oldGUI = playerGui:FindFirstChild("AutoBuyGUI")
    if oldGUI then
        oldGUI:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "AutoBuyGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 380, 0, Config.FullHeight)
    main.Position = UDim2.new(0.5, -190, 0.5, -320)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = main
    
    local blur = Instance.new("Frame")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    blur.BackgroundTransparency = 0.4
    blur.BorderSizePixel = 0
    blur.ZIndex = 1
    blur.Parent = main
    
    local blurCorner = Instance.new("UICorner")
    blurCorner.CornerRadius = UDim.new(0, 15)
    blurCorner.Parent = blur
    
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(60, 60, 70)
    border.Thickness = 1
    border.Transparency = 0.6
    border.Parent = main
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 3
    titleBar.Parent = main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleBar
    
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 15)
    titleFix.Position = UDim2.new(0, 0, 1, -15)
    titleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    titleFix.BackgroundTransparency = 0.3
    titleFix.BorderSizePixel = 0
    titleFix.ZIndex = 3
    titleFix.Parent = titleBar
    
    local anosLabel = Instance.new("TextLabel")
    anosLabel.Size = UDim2.new(0, 80, 0, 30)
    anosLabel.Position = UDim2.new(0, 15, 0, 12)
    anosLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    anosLabel.BackgroundTransparency = 0.3
    anosLabel.BorderSizePixel = 0
    anosLabel.Text = "ANOS"
    anosLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    anosLabel.TextSize = 18
    anosLabel.Font = Enum.Font.GothamBold
    anosLabel.ZIndex = 4
    anosLabel.Parent = titleBar
    
    local anosCorner = Instance.new("UICorner")
    anosCorner.CornerRadius = UDim.new(0, 8)
    anosCorner.Parent = anosLabel
    
    local anosStroke = Instance.new("UIStroke")
    anosStroke.Color = Color3.fromRGB(80, 80, 90)
    anosStroke.Thickness = 1
    anosStroke.Transparency = 0.6
    anosStroke.Parent = anosLabel
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -210, 1, 0)
    title.Position = UDim2.new(0, 100, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "AUTO BUY PVB"
    title.TextColor3 = Color3.fromRGB(200, 200, 210)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 4
    title.Parent = titleBar
    
    local controlBtns = Instance.new("Frame")
    controlBtns.Size = UDim2.new(0, 100, 0, 35)
    controlBtns.Position = UDim2.new(1, -110, 0, 10)
    controlBtns.BackgroundTransparency = 1
    controlBtns.ZIndex = 4
    controlBtns.Parent = titleBar
    
    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 8)
    btnLayout.Parent = controlBtns
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    minimizeBtn.BackgroundTransparency = 0.3
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.ZIndex = 5
    minimizeBtn.Parent = controlBtns
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 60)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 5
    closeBtn.Parent = controlBtns
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 1, -55)
    contentContainer.Position = UDim2.new(0, 0, 0, 55)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.ZIndex = 2
    contentContainer.Parent = main
    
    local statusPanel = Instance.new("Frame")
    statusPanel.Size = UDim2.new(1, -20, 0, 50)
    statusPanel.Position = UDim2.new(0, 10, 0, 10)
    statusPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    statusPanel.BackgroundTransparency = 0.4
    statusPanel.BorderSizePixel = 0
    statusPanel.ZIndex = 3
    statusPanel.Parent = contentContainer
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 12)
    statusCorner.Parent = statusPanel
    
    local statusStroke = Instance.new("UIStroke")
    statusStroke.Color = Color3.fromRGB(60, 60, 70)
    statusStroke.Thickness = 1
    statusStroke.Transparency = 0.7
    statusStroke.Parent = statusPanel
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 24)
    statusLabel.Position = UDim2.new(0, 10, 0, 5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "⚫ Status: STOPPED"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    statusLabel.TextSize = 15
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 4
    statusLabel.Parent = statusPanel
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 27)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "⚡ Speed: " .. math.floor(1/Config.BuyDelay) .. " items/s"
    speedLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
    speedLabel.TextSize = 13
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.ZIndex = 4
    speedLabel.Parent = statusPanel
    
    local actionsBar = Instance.new("Frame")
    actionsBar.Size = UDim2.new(1, -20, 0, 38)
    actionsBar.Position = UDim2.new(0, 10, 0, 70)
    actionsBar.BackgroundTransparency = 1
    actionsBar.ZIndex = 3
    actionsBar.Parent = contentContainer
    
    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.FillDirection = Enum.FillDirection.Horizontal
    actionsLayout.Padding = UDim.new(0, 8)
    actionsLayout.Parent = actionsBar
    
    local selectAllBtn = Instance.new("TextButton")
    selectAllBtn.Size = UDim2.new(0.5, -4, 1, 0)
    selectAllBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 80)
    selectAllBtn.BackgroundTransparency = 0.3
    selectAllBtn.BorderSizePixel = 0
    selectAllBtn.Text = "✓ Select All"
    selectAllBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    selectAllBtn.TextSize = 13
    selectAllBtn.Font = Enum.Font.GothamBold
    selectAllBtn.ZIndex = 4
    selectAllBtn.Parent = actionsBar
    
    local selectAllCorner = Instance.new("UICorner")
    selectAllCorner.CornerRadius = UDim.new(0, 10)
    selectAllCorner.Parent = selectAllBtn
    
    local deselectAllBtn = Instance.new("TextButton")
    deselectAllBtn.Size = UDim2.new(0.5, -4, 1, 0)
    deselectAllBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 60)
    deselectAllBtn.BackgroundTransparency = 0.3
    deselectAllBtn.BorderSizePixel = 0
    deselectAllBtn.Text = "✕ Deselect All"
    deselectAllBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    deselectAllBtn.TextSize = 13
    deselectAllBtn.Font = Enum.Font.GothamBold
    deselectAllBtn.ZIndex = 4
    deselectAllBtn.Parent = actionsBar
    
    local deselectAllCorner = Instance.new("UICorner")
    deselectAllCorner.CornerRadius = UDim.new(0, 10)
    deselectAllCorner.Parent = deselectAllBtn
    
    local filterBar = Instance.new("Frame")
    filterBar.Size = UDim2.new(1, -20, 0, 85)
    filterBar.Position = UDim2.new(0, 10, 0, 118)
    filterBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    filterBar.BackgroundTransparency = 0.4
    filterBar.BorderSizePixel = 0
    filterBar.ZIndex = 3
    filterBar.Parent = contentContainer
    
    local filterCorner = Instance.new("UICorner")
    filterCorner.CornerRadius = UDim.new(0, 12)
    filterCorner.Parent = filterBar
    
    local filterTitle = Instance.new("TextLabel")
    filterTitle.Size = UDim2.new(1, -10, 0, 25)
    filterTitle.Position = UDim2.new(0, 10, 0, 5)
    filterTitle.BackgroundTransparency = 1
    filterTitle.Text = "🎯 Quick Select by Rarity"
    filterTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
    filterTitle.TextSize = 13
    filterTitle.Font = Enum.Font.GothamBold
    filterTitle.TextXAlignment = Enum.TextXAlignment.Left
    filterTitle.ZIndex = 4
    filterTitle.Parent = filterBar
    
    local filterGrid = Instance.new("Frame")
    filterGrid.Size = UDim2.new(1, -20, 0, 50)
    filterGrid.Position = UDim2.new(0, 10, 0, 30)
    filterGrid.BackgroundTransparency = 1
    filterGrid.ZIndex = 4
    filterGrid.Parent = filterBar
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.33, -5, 0, 23)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 4)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = filterGrid
    
    local rarityButtons = {}
    local rarities = {"Rare", "Epic", "Legendary", "Mythic", "Godly", "Secret"}
    
    for i, rarity in ipairs(rarities) do
        local rarityBtn = Instance.new("TextButton")
        rarityBtn.BackgroundColor3 = RarityColors[rarity]
        rarityBtn.BackgroundTransparency = 0.3
        rarityBtn.BorderSizePixel = 0
        rarityBtn.Text = rarity
        rarityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rarityBtn.TextSize = 11
        rarityBtn.Font = Enum.Font.GothamBold
        rarityBtn.ZIndex = 5
        rarityBtn.LayoutOrder = i
        rarityBtn.Parent = filterGrid
        
        local rarityCorner = Instance.new("UICorner")
        rarityCorner.CornerRadius = UDim.new(0, 8)
        rarityCorner.Parent = rarityBtn
        
        rarityButtons[rarity] = rarityBtn
    end
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 320)
    scroll.Position = UDim2.new(0, 10, 0, 213)
    scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    scroll.BackgroundTransparency = 0.5
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scroll.ZIndex = 3
    scroll.Parent = contentContainer
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 12)
    scrollCorner.Parent = scroll
    
    local scrollStroke = Instance.new("UIStroke")
    scrollStroke.Color = Color3.fromRGB(60, 60, 70)
    scrollStroke.Thickness = 1
    scrollStroke.Transparency = 0.7
    scrollStroke.Parent = scroll
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = scroll
    
    local itemButtons = {}
    
    local function addItemButton(itemData, category)
        local itemName = itemData.name
        local rarity = itemData.rarity
        local rarityColor = RarityColors[rarity]
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.ZIndex = 4
        btn.Parent = scroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = rarityColor
        btnStroke.Thickness = 1.5
        btnStroke.Transparency = 0.6
        btnStroke.Parent = btn
        
        local rarityBar = Instance.new("Frame")
        rarityBar.Size = UDim2.new(0, 5, 1, 0)
        rarityBar.BackgroundColor3 = rarityColor
        rarityBar.BackgroundTransparency = 0.2
        rarityBar.BorderSizePixel = 0
        rarityBar.ZIndex = 5
        rarityBar.Parent = btn
        
        local rarityBarCorner = Instance.new("UICorner")
        rarityBarCorner.CornerRadius = UDim.new(0, 10)
        rarityBarCorner.Parent = rarityBar
        
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Size = UDim2.new(1, -90, 1, 0)
        itemLabel.Position = UDim2.new(0, 15, 0, 0)
        itemLabel.BackgroundTransparency = 1
        itemLabel.Text = itemName
        itemLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        itemLabel.TextSize = 13
        itemLabel.Font = Enum.Font.Gotham
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        itemLabel.ZIndex = 5
        itemLabel.Parent = btn
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(0, 70, 0, 22)
        rarityLabel.Position = UDim2.new(1, -138, 0.5, -11)
        rarityLabel.BackgroundColor3 = rarityColor
        rarityLabel.BackgroundTransparency = 0.2
        rarityLabel.BorderSizePixel = 0
        rarityLabel.Text = rarity:upper()
        rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        rarityLabel.TextSize = 10
        rarityLabel.Font = Enum.Font.GothamBold
        rarityLabel.ZIndex = 5
        rarityLabel.Parent = btn
        
        local rarityLabelCorner = Instance.new("UICorner")
        rarityLabelCorner.CornerRadius = UDim.new(0, 7)
        rarityLabelCorner.Parent = rarityLabel
        
        local statusIndicator = Instance.new("Frame")
        statusIndicator.Size = UDim2.new(0, 55, 0, 28)
        statusIndicator.Position = UDim2.new(1, -63, 0.5, -14)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        statusIndicator.BackgroundTransparency = 0.2
        statusIndicator.BorderSizePixel = 0
        statusIndicator.ZIndex = 5
        statusIndicator.Parent = btn
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(0, 7)
        statusCorner.Parent = statusIndicator
        
        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(1, 0, 1, 0)
        statusText.BackgroundTransparency = 1
        statusText.Text = "OFF"
        statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusText.TextSize = 11
        statusText.Font = Enum.Font.GothamBold
        statusText.ZIndex = 6
        statusText.Parent = statusIndicator
        
        Config.SelectedItems[itemName] = false
        table.insert(itemButtons, {
            button = btn,
            name = itemName,
            rarity = rarity,
            indicator = statusIndicator,
            text = statusText,
            label = itemLabel,
            stroke = btnStroke
        })
        
        btn.MouseButton1Click:Connect(function()
            Config.SelectedItems[itemName] = not Config.SelectedItems[itemName]
            
            if Config.SelectedItems[itemName] then
                tweenButton(btn, {BackgroundTransparency = 0.1})
                tweenButton(statusIndicator, {BackgroundColor3 = Color3.fromRGB(50, 200, 100)})
                itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                statusText.Text = "ON"
                btnStroke.Transparency = 0.3
            else
                tweenButton(btn, {BackgroundTransparency = 0.3})
                tweenButton(statusIndicator, {BackgroundColor3 = Color3.fromRGB(150, 50, 50)})
                itemLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                statusText.Text = "OFF"
                btnStroke.Transparency = 0.6
            end
        end)
        
        btn.MouseEnter:Connect(function()
            if not Config.SelectedItems[itemName] then
                tweenButton(btn, {BackgroundTransparency = 0.2})
            end
        end)
        
        btn.MouseLeave:Connect(function()
            if not Config.SelectedItems[itemName] then
                tweenButton(btn, {BackgroundTransparency = 0.3})
            end
        end)
        
        return btn
    end
    
    local function addCategory(text)
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, -10, 0, 35)
        header.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
        header.BackgroundTransparency = 0.2
        header.BorderSizePixel = 0
        header.ZIndex = 4
        header.Parent = scroll
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 10)
        headerCorner.Parent = header
        
        local headerStroke = Instance.new("UIStroke")
        headerStroke.Color = Color3.fromRGB(150, 200, 255)
        headerStroke.Thickness = 1.5
        headerStroke.Transparency = 0.5
        headerStroke.Parent = header
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(150, 200, 255)
        label.TextSize = 15
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 5
        label.Parent = header
        
        return header
    end
    
    addCategory("🌱 SEEDS")
    for _, seed in ipairs(SeedItems) do
        addItemButton(seed, "seed")
    end
    
    local spacer1 = Instance.new("Frame")
    spacer1.Size = UDim2.new(1, -10, 0, 5)
    spacer1.BackgroundTransparency = 1
    spacer1.Parent = scroll
    
    addCategory("⚙️ GEARS")
    for _, gear in ipairs(GearItems) do
        addItemButton(gear, "gear")
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    
    for rarity, btn in pairs(rarityButtons) do
        btn.MouseButton1Click:Connect(function()
            for _, data in ipairs(itemButtons) do
                if data.rarity == rarity then
                    Config.SelectedItems[data.name] = true
                    tweenButton(data.button, {BackgroundTransparency = 0.1})
                    tweenButton(data.indicator, {BackgroundColor3 = Color3.fromRGB(50, 200, 100)})
                    data.label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    data.text.Text = "ON"
                    data.stroke.Transparency = 0.3
                end
            end
        end)
        
        btn.MouseEnter:Connect(function()
            tweenButton(btn, {BackgroundTransparency = 0.1})
        end)
        
        btn.MouseLeave:Connect(function()
            tweenButton(btn, {BackgroundTransparency = 0.3})
        end)
    end
    
    selectAllBtn.MouseButton1Click:Connect(function()
        for _, data in ipairs(itemButtons) do
            Config.SelectedItems[data.name] = true
            tweenButton(data.button, {BackgroundTransparency = 0.1})
            tweenButton(data.indicator, {BackgroundColor3 = Color3.fromRGB(50, 200, 100)})
            data.label.TextColor3 = Color3.fromRGB(255, 255, 255)
            data.text.Text = "ON"
            data.stroke.Transparency = 0.3
        end
    end)
    
    deselectAllBtn.MouseButton1Click:Connect(function()
        for _, data in ipairs(itemButtons) do
            Config.SelectedItems[data.name] = false
            tweenButton(data.button, {BackgroundTransparency = 0.3})
            tweenButton(data.indicator, {BackgroundColor3 = Color3.fromRGB(150, 50, 50)})
            data.label.TextColor3 = Color3.fromRGB(220, 220, 220)
            data.text.Text = "OFF"
            data.stroke.Transparency = 0.6
        end
    end)
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 55)
    toggleBtn.Position = UDim2.new(0, 10, 1, -65)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 80)
    toggleBtn.BackgroundTransparency = 0.3
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "▶ START AUTO BUY"
    toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.ZIndex = 10
    toggleBtn.Parent = contentContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleBtn
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(80, 90, 100)
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.6
    toggleStroke.Parent = toggleBtn
    
    local padding2 = Instance.new("UIPadding")
    padding2.PaddingBottom = UDim.new(0, 20)
    padding2.Parent = scroll
    
    toggleBtn.MouseButton1Click:Connect(function()
        Config.Enabled = not Config.Enabled
        
        if Config.Enabled then
            toggleBtn.Text = "⏸ STOP AUTO BUY"
            tweenButton(toggleBtn, {BackgroundColor3 = Color3.fromRGB(90, 60, 60)})
            toggleStroke.Color = Color3.fromRGB(110, 80, 80)
            statusLabel.Text = "🟢 Status: RUNNING"
            statusLabel.TextColor3 = Color3.fromRGB(140, 160, 140)
        else
            toggleBtn.Text = "▶ START AUTO BUY"
            tweenButton(toggleBtn, {BackgroundColor3 = Color3.fromRGB(60, 70, 80)})
            toggleStroke.Color = Color3.fromRGB(80, 90, 100)
            statusLabel.Text = "⚫ Status: STOPPED"
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        Config.IsMinimized = not Config.IsMinimized
        
        if Config.IsMinimized then
            tweenSize(main, UDim2.new(0, 380, 0, Config.MinimizedHeight), 0.3)
            minimizeBtn.Text = "+"
            contentContainer.Visible = false
        else
            tweenSize(main, UDim2.new(0, 380, 0, Config.FullHeight), 0.3)
            minimizeBtn.Text = "─"
            task.wait(0.15)
            contentContainer.Visible = true
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Config.Enabled = false
        gui:Destroy()
    end)
    
    minimizeBtn.MouseEnter:Connect(function()
        tweenButton(minimizeBtn, {BackgroundTransparency = 0})
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        tweenButton(minimizeBtn, {BackgroundTransparency = 0.2})
    end)
    
    closeBtn.MouseEnter:Connect(function()
        tweenButton(closeBtn, {BackgroundTransparency = 0})
    end)
    
    closeBtn.MouseLeave:Connect(function()
        tweenButton(closeBtn, {BackgroundTransparency = 0.2})
    end)
    
    selectAllBtn.MouseEnter:Connect(function()
        tweenButton(selectAllBtn, {BackgroundTransparency = 0})
    end)
    
    selectAllBtn.MouseLeave:Connect(function()
        tweenButton(selectAllBtn, {BackgroundTransparency = 0.2})
    end)
    
    deselectAllBtn.MouseEnter:Connect(function()
        tweenButton(deselectAllBtn, {BackgroundTransparency = 0})
    end)
    
    deselectAllBtn.MouseLeave:Connect(function()
        tweenButton(deselectAllBtn, {BackgroundTransparency = 0.2})
    end)
    
    toggleBtn.MouseEnter:Connect(function()
        tweenButton(toggleBtn, {BackgroundTransparency = 0})
    end)
    
    toggleBtn.MouseLeave:Connect(function()
        tweenButton(toggleBtn, {BackgroundTransparency = 0.2})
    end)
    
    local dragging = false
    local dragInput, mousePos, framePos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            main.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    return gui
end

local buyConnection
local function startAutoBuy()
    if buyConnection then
        buyConnection:Disconnect()
    end
    
    buyConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        for itemName, enabled in pairs(Config.SelectedItems) do
            if enabled then
                local isSeed = false
                for _, seed in ipairs(SeedItems) do
                    if seed.name == itemName then
                        isSeed = true
                        break
                    end
                end
                
                if isSeed then
                    buySeed(itemName)
                else
                    buyGear(itemName)
                end
                
                task.wait(Config.BuyDelay)
            end
        end
        
        task.wait(0.01)
    end)
end

print("╔════════════════════════════════════════╗")
print("║   AUTO BUY PVB - ANOS EDITION V3.0    ║")
print("╚════════════════════════════════════════╝")

setupAntiAFK()
local success, err = pcall(function()
    createGUI()
end)

if not success then
    warn("Error: " .. tostring(err))
    return
end

startAutoBuy()

print("✅ Ready!")
