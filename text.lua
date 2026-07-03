-- ==========================================================
-- HESERS.CC v6.5 | Clean World Tab + Spinning Crosshair
-- ==========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Mouse = LocalPlayer:GetMouse()

-- ==================[ ПЕРЕМЕННЫЕ ]======================
local MenuInstance = nil
local WatermarkInstance = nil
local ScreenGui = nil
local MenuOpen = false

-- ==================[ НАСТРОЙКИ ]======================
local Settings = {
    -- ESP
    ESP = false, ESPBox = false, ESPTracer = false, ESPName = false, ESPDistance = false,
    ESPBoxColor = "White",
    -- Chams
    RoleChams = false,
    SkeletonESP = false,
    -- Spectator
    SpectatorList = false,
    -- Trail
    Trail = false, TrailColor = "White", TrailSize = "Big",
    -- Glow
    GlowBody = false, GlowColor = "White",
    -- Orbs
    OrbitOrbs = false, OrbColor = "White",
    -- Particles
    FloatingParticles = false, ParticleColor = "White",
    -- Fog
    Fog = false, FogDistance = 50, FogColor = "White",
    -- FPS
    ShowFPS = false,
    -- Skybox
    CustomSkybox = false, SkyboxType = "White",
    -- FOV
    FOV = false, FOVValue = 70,
    -- Crosshair (КРУТЯЩИЙСЯ КРЕСТ)
    CustomCrosshair = false, CrosshairSize = 20, CrosshairColor = "Red",
    -- World Visuals (ТОЛЬКО WIREFRAME И FULL BRIGHT)
    FullBright = false,
    WireframeMode = false,
    
    -- Rage
    GodMode = false, Noclip = false,
    Fly = false, FlySpeed = 50,
    AntiFling = false, AntiKnife = false, AntiKnifeDistance = 25,
    Spinbot = false, SpinSpeed = 20,
    BunnyHop = false, BHOPMultiplier = 1.5, BHOPMaxSpeed = 100,
    AntiLag = false, Invisibility = false, GunGrabber = false,
    JumpPower = false, JumpMultiplier = 50,
    WallHop = false, AutoRejoin = false, RejoinDelay = 3, ShiftLock = false,
    ZombieWalk = false,
    Aimbot = false, AimbotFOV = 120, AimbotRange = 500, AimbotMode = "Always",
    SilentAim = false, WallShoot = false,
    AutoShoot = false, AutoShootDelay = 0.15, TriggerBot = false,
    DeathEffect = false, DeathEffectColor = "Purple",
    KillSound = false, AutoTaunt = false,
    ClickTP = false,
    AutoFarm = false, FarmRadius = 30, FarmDelay = 0.3,
    AntiVoid = false,
    AutoKnife = false,
    
    -- Settings
    MenuTheme = "Red",
    PanicKey = "Delete",
    AutoSave = true,
    AutoLoad = true,
    ShowPing = false,
    ShowPlayTime = false,
    PlayTime = 0,
    MenuTransparency = 0.7,
    MenuScale = 1.0,
}

-- ==================[ СИСТЕМА УВЕДОМЛЕНИЙ ]======================
local function sendNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
            Icon = "rbxassetid://132691910581653"
        })
    end)
end

local function notifyOnEnable(featureName)
    sendNotification("HESERS.CC", featureName .. " включён!", 2)
end

local function notifyOnAction(featureName, details)
    sendNotification("HESERS.CC", featureName .. ": " .. (details or ""), 2)
end

-- ==================[ СИСТЕМЫ ]======================
local ESPObjects, Chams = {}, {}
local SkeletonESPObjects, SkeletonESPConnection = {}, nil
local SpectatorList, SpectatorConnection = nil, nil
local activeTrails = {}
local trailEnabled = false
local orbitContainer, orbitConnection, highlightBody = nil, nil, nil
local Particles = {}; local lastParticleSpawn = 0
local FPSConnection, FPSGui = nil, nil

local noclipConn, godConn, flyConn, flyBV, flyBG = nil, nil, nil, nil, nil
local flyMoveDir = Vector3.zero; local flyJoystick, flyStick = nil, nil
local aflConn, antiKnifeConn, spinConn, bhopConn = nil, nil, nil, nil
local jumpConn, wallHopConn, rejoinConn, invisConn, lockConn = nil, nil, nil, nil, nil
local lastGoodPosition, lastGoodTime = Vector3.zero, 0; local lastTPTime = 0
local antiLagMaterials = {}; local origTrans = {}
local autoGunTPConnection = nil

local aimConn = nil; local lastShootTime = 0; local oldNamecall = nil; local fovCircle = nil
local fovConnection = nil

local KillSoundConnection = nil
local lastTauntTime = 0

local farmConn, farmFlyBodyGyro, farmFlyBodyVelocity = nil, nil, nil

local crosshairGui, crosshairContainer = nil, nil
local zombieConnection = nil

local InfoConnection = nil
local InfoGui = nil
local antiVoidConn = nil
local autoKnifeConn = nil
local lastKnifeKillTime = 0

local clickTPConnection = nil
local clickTPTapConnection = nil

-- ==================[ ЦВЕТА ]======================
local ColorMap = {
    White = Color3.fromRGB(255, 255, 255), Red = Color3.fromRGB(255, 50, 50),
    Blue = Color3.fromRGB(50, 150, 255), Purple = Color3.fromRGB(180, 50, 255),
    Cyan = Color3.fromRGB(0, 255, 255), Green = Color3.fromRGB(0, 255, 100),
    Yellow = Color3.fromRGB(255, 255, 0), Orange = Color3.fromRGB(255, 150, 0),
    Pink = Color3.fromRGB(255, 100, 150)
}
local function getColor(name) return ColorMap[name] or ColorMap.White end

local UI_THEMES = {
    Red = {Accent = Color3.fromRGB(255, 60, 60), Light = Color3.fromRGB(255, 100, 100), BG = Color3.fromRGB(25, 25, 30)},
    Blue = {Accent = Color3.fromRGB(60, 100, 255), Light = Color3.fromRGB(100, 140, 255), BG = Color3.fromRGB(25, 25, 35)},
    Purple = {Accent = Color3.fromRGB(180, 50, 255), Light = Color3.fromRGB(200, 100, 255), BG = Color3.fromRGB(30, 20, 40)},
    Green = {Accent = Color3.fromRGB(50, 255, 100), Light = Color3.fromRGB(100, 255, 150), BG = Color3.fromRGB(20, 30, 25)},
    Rainbow = {Accent = Color3.fromHSV(tick() % 1, 1, 1), Light = Color3.fromHSV(tick() % 1, 0.8, 1), BG = Color3.fromRGB(25, 25, 30)},
}

local UI_ACCENT = UI_THEMES.Red.Accent
local UI_ACCENT_LIGHT = UI_THEMES.Red.Light
local UI_BG = UI_THEMES.Red.BG

local function updateTheme()
    local theme = UI_THEMES[Settings.MenuTheme] or UI_THEMES.Red
    if Settings.MenuTheme == "Rainbow" then
        UI_ACCENT = Color3.fromHSV(tick() % 1, 1, 1)
        UI_ACCENT_LIGHT = Color3.fromHSV(tick() % 1, 0.8, 1)
    else
        UI_ACCENT = theme.Accent
        UI_ACCENT_LIGHT = theme.Light
    end
    UI_BG = theme.BG
end

-- ==========================================================
--                    LOADING SCREEN
-- ==========================================================
local function showLoadingScreen()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not playerGui then return end
    
    local loadingGui = Instance.new("ScreenGui", playerGui)
    loadingGui.Name = "HesersLoading"
    loadingGui.IgnoreGuiInset = true
    loadingGui.ResetOnSpawn = false
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local bg = Instance.new("Frame", loadingGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0
    bg.ZIndex = 99999
    
    TweenService:Create(bg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
    
    local centerFrame = Instance.new("Frame", bg)
    centerFrame.Size = UDim2.new(0, 200, 0, 200)
    centerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
    centerFrame.BackgroundTransparency = 1
    centerFrame.BorderSizePixel = 0
    centerFrame.ZIndex = 99999
    
    local logo = Instance.new("ImageLabel", centerFrame)
    logo.Size = UDim2.new(0, 80, 0, 80)
    logo.Position = UDim2.new(0.5, -40, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://127846278140386"
    logo.ImageColor3 = UI_ACCENT
    logo.ZIndex = 99999
    logo.ImageTransparency = 1
    
    TweenService:Create(logo, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {ImageTransparency = 0, Size = UDim2.new(0, 90, 0, 90), Position = UDim2.new(0.5, -45, 0, 5)}):Play()
    
    local nameLabel = Instance.new("TextLabel", centerFrame)
    nameLabel.Size = UDim2.new(1, 0, 0, 30)
    nameLabel.Position = UDim2.new(0, 0, 0, 95)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "HESERS.CC"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextSize = 24
    nameLabel.TextTransparency = 1
    nameLabel.ZIndex = 99999
    
    TweenService:Create(nameLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    
    local loadBarBg = Instance.new("Frame", centerFrame)
    loadBarBg.Size = UDim2.new(0.8, 0, 0, 4)
    loadBarBg.Position = UDim2.new(0.1, 0, 0, 135)
    loadBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    loadBarBg.BorderSizePixel = 0
    loadBarBg.ZIndex = 99999
    Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)
    
    local loadBarFill = Instance.new("Frame", loadBarBg)
    loadBarFill.Size = UDim2.new(0, 0, 1, 0)
    loadBarFill.BackgroundColor3 = UI_ACCENT
    loadBarFill.BorderSizePixel = 0
    loadBarFill.ZIndex = 99999
    Instance.new("UICorner", loadBarFill).CornerRadius = UDim.new(1, 0)
    
    TweenService:Create(loadBarFill, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    
    for i = 1, 15 do
        spawn(function()
            local particle = Instance.new("Frame", bg)
            particle.Size = UDim2.new(0, 4, 0, 4)
            particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
            particle.BackgroundColor3 = UI_ACCENT
            particle.BorderSizePixel = 0
            particle.ZIndex = 99999
            particle.BackgroundTransparency = 1
            Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
            
            local startPos = particle.Position
            local targetPos = UDim2.new(startPos.X.Scale + (math.random() - 0.5) * 0.3, 0, startPos.Y.Scale - 0.3, 0)
            
            TweenService:Create(particle, TweenInfo.new(2 + math.random(), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos, BackgroundTransparency = 1, Size = UDim2.new(0, 2, 0, 2)}):Play()
            
            task.wait(3)
            particle:Destroy()
        end)
    end
    
    task.wait(2.8)
    
    TweenService:Create(bg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    TweenService:Create(logo, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1, Size = UDim2.new(0, 70, 0, 70)}):Play()
    TweenService:Create(nameLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    
    task.wait(0.5)
    loadingGui:Destroy()
end

-- ==================[ ОЖИДАНИЕ ЗАГРУЗКИ MM2 ]======================
local function waitForGameLoad()
    local gameLoaded = false
    
    if Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Lobby") or #Workspace:GetChildren() > 10 then
        gameLoaded = true
    end
    
    if not gameLoaded then
        local conn; conn = Workspace.DescendantAdded:Connect(function()
            gameLoaded = true
            if conn then conn:Disconnect() end
        end)
    end
    
    while not gameLoaded do
        if Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Lobby") or #Workspace:GetChildren() > 10 then
            gameLoaded = true
            break
        end
        task.wait(0.5)
    end
    
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    showLoadingScreen()
end

spawn(waitForGameLoad)

-- ==========================================================
--                    ESP
-- ==========================================================
local function createESP(plr)
    local boxFill = Drawing.new("Square")
    boxFill.Filled = true
    boxFill.Color = Color3.fromRGB(255, 255, 255)
    boxFill.Transparency = 0.8
    
    local boxOutline = Drawing.new("Square")
    boxOutline.Filled = false
    boxOutline.Color = getColor(Settings.ESPBoxColor)
    boxOutline.Thickness = 2
    
    local tracer = Drawing.new("Line")
    tracer.Color = getColor(Settings.ESPBoxColor)
    
    local text = Drawing.new("Text")
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Size = 14
    text.Center = true
    text.Outline = true
    
    return {boxFill = boxFill, boxOutline = boxOutline, tracer = tracer, text = text}
end

local function updateESP()
    for plr, e in pairs(ESPObjects) do
        if not plr or not plr.Parent then ESPObjects[plr] = nil continue end
        pcall(function() e.boxFill.Visible = false; e.boxOutline.Visible = false; e.tracer.Visible = false; e.text.Visible = false end)
    end
    if not Settings.ESP then return end
    local mc = LocalPlayer.Character; if not mc then return end
    local mr = mc:FindFirstChild("HumanoidRootPart"); if not mr then return end
    
    local boxColor = getColor(Settings.ESPBoxColor)
    
    for plr, e in pairs(ESPObjects) do
        if plr == LocalPlayer then continue end
        local c = plr.Character; if not c then continue end
        local h = c:FindFirstChild("Humanoid"); if not h or h.Health <= 0 then continue end
        local head = c:FindFirstChild("Head"); local root = c:FindFirstChild("HumanoidRootPart")
        if not head or not root then continue end
        local d = (root.Position - mr.Position).Magnitude; if d > 500 then continue end
        
        if Settings.ESPBox then
            local hp, hv = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local fp, fv = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
            if hv and fv then
                local bh = math.abs(hp.Y-fp.Y); local bw = bh*0.35
                if bh<10 then bh=10;bw=4 end; if bh>300 then bh=300;bw=105 end
                
                e.boxFill.Position = Vector2.new(fp.X-bw/2,hp.Y)
                e.boxFill.Size = Vector2.new(bw,bh)
                e.boxFill.Visible = true
                
                e.boxOutline.Position = Vector2.new(fp.X-bw/2,hp.Y)
                e.boxOutline.Size = Vector2.new(bw,bh)
                e.boxOutline.Color = boxColor
                e.boxOutline.Visible = true
            end
        end
        
        if Settings.ESPTracer then
            local fp, fv = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
            if fv then
                e.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                e.tracer.To = Vector2.new(fp.X, fp.Y)
                e.tracer.Color = boxColor
                e.tracer.Visible = true
            end
        end
        
        if Settings.ESPName or Settings.ESPDistance then
            local txt = ""
            if Settings.ESPName then txt = plr.Name end
            if Settings.ESPDistance then txt = txt .. " ["..math.floor(d).."m]" end
            local fp, fv = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
            if fv then
                e.text.Text = txt
                e.text.Position = Vector2.new(fp.X, fp.Y-20)
                e.text.Visible = true
            end
        end
    end
end

local function addESP(plr)
    if plr ~= LocalPlayer and not ESPObjects[plr] then ESPObjects[plr] = createESP(plr) end
end

local function removeESP(plr)
    if ESPObjects[plr] then
        pcall(function() ESPObjects[plr].boxFill:Remove(); ESPObjects[plr].boxOutline:Remove(); ESPObjects[plr].tracer:Remove(); ESPObjects[plr].text:Remove() end)
        ESPObjects[plr] = nil
    end
end

-- ==================[ TRAIL ]======================
local function createPlayerTrail(char)
    if not char or not trailEnabled then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or activeTrails[char] then return end
    
    local isBig = Settings.TrailSize == "Big"
    local color = getColor(Settings.TrailColor)
    
    local att0 = Instance.new("Attachment")
    att0.Position = Vector3.new(0, -0.1, 0.2)
    att0.Parent = root
    
    local att1 = Instance.new("Attachment")
    att1.Position = Vector3.new(0, -0.7, 0.2)
    att1.Parent = root
    
    local trail = Instance.new("Trail")
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Lifetime = isBig and 1.2 or 0.5
    
    trail.WidthScale = NumberSequence.new(isBig and 0.4 or 0.15, isBig and 0.4 or 0.15)
    trail.Color = ColorSequence.new(color)
    
    if isBig then
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.85, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    else
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.8, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
    end
    
    trail.LightEmission = 1
    trail.LightInfluence = 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 1, 0, 1)
    billboard.Parent = root
    
    trail.Parent = root
    
    activeTrails[char] = {trail = trail, att0 = att0, att1 = att1, bbg = billboard}
end

local function removeAllTrails()
    for char, data in pairs(activeTrails) do
        pcall(function() if data.trail then data.trail:Destroy() end end)
        pcall(function() if data.att0 then data.att0:Destroy() end end)
        pcall(function() if data.att1 then data.att1:Destroy() end end)
        pcall(function() if data.bbg then data.bbg:Destroy() end end)
    end
    activeTrails = {}
end

local function updateAllPlayersTrails()
    if not Settings.Trail then return end
    trailEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then createPlayerTrail(p.Character) end
    end
end

local function toggleTrail()
    Settings.Trail = not Settings.Trail
    if Settings.Trail then
        notifyOnEnable("Trail")
        trailEnabled = true
        updateAllPlayersTrails()
    else
        trailEnabled = false
        removeAllTrails()
    end
end

-- ==================[ ROLE CHAMS ]======================
local function createCham(plr)
    if Chams[plr] then return end
    local hl = Instance.new("Highlight"); hl.FillTransparency = 0.4; hl.OutlineTransparency = 0.2
    hl.OutlineColor = Color3.fromRGB(255,255,255); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled = false; Chams[plr] = hl
end
local function updateRoleChams()
    for plr, hl in pairs(Chams) do
        if not plr.Parent or not plr.Character then pcall(function() hl.Enabled = false end); continue end
        if not Settings.RoleChams then pcall(function() hl.Enabled = false; hl.Parent = nil end); continue end
        local hum = plr.Character:FindFirstChild("Humanoid"); if not hum or hum.Health <= 0 then pcall(function() hl.Enabled = false end); continue end
        pcall(function()
            hl.Parent = plr.Character
            if plr.Character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife")) then hl.FillColor = Color3.fromRGB(255, 0, 0)
            elseif plr.Character:FindFirstChild("Gun") or (plr.Backpack and plr.Backpack:FindFirstChild("Gun")) then hl.FillColor = Color3.fromRGB(0, 120, 255)
            else hl.FillColor = Color3.fromRGB(0, 255, 100) end
            hl.Enabled = true
        end)
    end
end

-- ==================[ SKELETON ESP ]======================
local function createSkeletonESP()
    for _, v in pairs(SkeletonESPObjects) do pcall(function() v:Remove() end) end; SkeletonESPObjects = {}
    if not Settings.SkeletonESP then if SkeletonESPConnection then SkeletonESPConnection:Disconnect(); SkeletonESPConnection = nil end return end
    if SkeletonESPConnection then return end
    SkeletonESPConnection = RunService.RenderStepped:Connect(function()
        if not Settings.SkeletonESP then return end
        for _, v in pairs(SkeletonESPObjects) do pcall(function() v:Remove() end) end; SkeletonESPObjects = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character; local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local head = char:FindFirstChild("Head"); local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                    local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                    local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                    local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
                    if head and torso then
                        local color = Color3.fromRGB(0, 255, 100)
                        if char:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife")) then color = Color3.fromRGB(255, 50, 50)
                        elseif char:FindFirstChild("Gun") or (plr.Backpack and plr.Backpack:FindFirstChild("Gun")) then color = Color3.fromRGB(50, 150, 255) end
                        local function drawLine(from, to)
                            local sf = Camera:WorldToViewportPoint(from.Position); local st = Camera:WorldToViewportPoint(to.Position)
                            if sf.Z > 0 and st.Z > 0 then
                                local line = Drawing.new("Line"); line.Visible = true; line.From = Vector2.new(sf.X, sf.Y); line.To = Vector2.new(st.X, st.Y)
                                line.Color = color; line.Thickness = 2; line.Transparency = 0.5; table.insert(SkeletonESPObjects, line)
                            end
                        end
                        if head and torso then drawLine(head, torso) end
                        if torso and leftArm then drawLine(torso, leftArm) end
                        if torso and rightArm then drawLine(torso, rightArm) end
                        if torso and leftLeg then drawLine(torso, leftLeg) end
                        if torso and rightLeg then drawLine(torso, rightLeg) end
                    end
                end
            end
        end
    end)
end

-- ==================[ SPECTATOR LIST ]======================
local function createSpectatorList()
    if SpectatorList then pcall(function() SpectatorList.Gui:Destroy() end) end
    local sg = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    sg.Name = "SpectatorList"; sg.IgnoreGuiInset = true; sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local mainFrame = Instance.new("Frame", sg)
    mainFrame.Size = UDim2.new(0, 200, 0, 30); mainFrame.Position = UDim2.new(0, 10, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0); mainFrame.BackgroundTransparency = 0.5; mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 99999; mainFrame.Active = true; mainFrame.Draggable = true; mainFrame.Visible = false
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", mainFrame).Color = UI_ACCENT
    local titleBar = Instance.new("Frame", mainFrame); titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = UI_ACCENT; titleBar.BackgroundTransparency = 0.2; titleBar.BorderSizePixel = 0; titleBar.ZIndex = 99999
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel", titleBar); title.Size = UDim2.new(1, 0, 1, 0)
    title.Text = "Spectators: 0"; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack; title.TextSize = 12; title.ZIndex = 99999
    local playerList = Instance.new("Frame", mainFrame); playerList.Size = UDim2.new(1, 0, 0, 0); playerList.Position = UDim2.new(0, 0, 0, 30)
    playerList.BackgroundTransparency = 1; playerList.BorderSizePixel = 0; playerList.ZIndex = 99999
    local uiListLayout = Instance.new("UIListLayout", playerList); uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder; uiListLayout.Padding = UDim.new(0, 2)
    SpectatorList = {Gui = sg, MainFrame = mainFrame, Title = title, PlayerList = playerList, Players = {}}
end
local function updateSpectatorList()
    if not Settings.SpectatorList then
        if SpectatorList then pcall(function() SpectatorList.Gui:Destroy() end); SpectatorList = nil end
        if SpectatorConnection then SpectatorConnection:Disconnect(); SpectatorConnection = nil end; return
    end
    if not SpectatorList then createSpectatorList() end
    if SpectatorConnection then return end
    SpectatorConnection = RunService.RenderStepped:Connect(function()
        if not Settings.SpectatorList then return end
        if not LocalPlayer.Character then return end
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        local spectators = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local theirChar = plr.Character; local theirHum = theirChar:FindFirstChild("Humanoid")
                if theirHum and theirHum.Health <= 0 then
                    local theirHead = theirChar:FindFirstChild("Head")
                    if theirHead and theirHead.CFrame.LookVector:Dot((myHRP.Position - theirHead.Position).Unit) > 0.5 then
                        table.insert(spectators, {Name = plr.Name, DisplayName = plr.DisplayName, Type = "Dead"})
                    end
                end
            end
        end
        local unique = {}; local seen = {}
        for _, s in ipairs(spectators) do if not seen[s.Name] then seen[s.Name] = true; table.insert(unique, s) end end
        if SpectatorList then
            SpectatorList.Title.Text = "Spectators: " .. #unique
            for _, v in pairs(SpectatorList.Players) do v:Destroy() end; SpectatorList.Players = {}
            for _, spec in ipairs(unique) do
                local pf = Instance.new("Frame", SpectatorList.PlayerList)
                pf.Size = UDim2.new(1, -4, 0, 25); pf.BackgroundColor3 = Color3.fromRGB(0,0,0); pf.BackgroundTransparency = 0.6; pf.BorderSizePixel = 0; pf.ZIndex = 99999
                Instance.new("UICorner", pf).CornerRadius = UDim.new(0, 4)
                local nl = Instance.new("TextLabel", pf); nl.Size = UDim2.new(1, -8, 1, 0); nl.Position = UDim2.new(0, 4, 0, 0)
                nl.Text = spec.DisplayName .. " " .. spec.Type; nl.TextColor3 = Color3.fromRGB(255,255,255); nl.BackgroundTransparency = 1
                nl.Font = Enum.Font.GothamBold; nl.TextSize = 10; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.ZIndex = 99999
                table.insert(SpectatorList.Players, pf)
            end
            local totalHeight = 30 + math.max(#unique * 27, 1)
            SpectatorList.MainFrame.Size = UDim2.new(0, 200, 0, totalHeight); SpectatorList.MainFrame.Visible = #unique > 0
        end
    end)
end

-- ==================[ GLOW BODY ]======================
local function applyGlowBody()
    pcall(function()
        if highlightBody then highlightBody:Destroy(); highlightBody = nil end
        if not Settings.GlowBody or not LocalPlayer.Character then return end
        highlightBody = Instance.new("Highlight"); highlightBody.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlightBody.FillColor = getColor(Settings.GlowColor); highlightBody.FillTransparency = 0.45
        highlightBody.OutlineColor = Color3.fromRGB(255,255,255); highlightBody.OutlineTransparency = 0
        highlightBody.Adornee = LocalPlayer.Character; highlightBody.Parent = CoreGui
    end)
end

-- ==================[ ORBIT ORBS ]======================
local function applyOrbitOrbs()
    pcall(function()
        if orbitConnection then orbitConnection:Disconnect(); orbitConnection = nil end
        if orbitContainer then orbitContainer:Destroy(); orbitContainer = nil end
        if not Settings.OrbitOrbs or not LocalPlayer.Character then return end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        orbitContainer = Instance.new("Model", Camera); orbitContainer.Name = "OrbitOrbs"
        local function createOrb() local o = Instance.new("Part", orbitContainer); o.Shape = Enum.PartType.Ball; o.Size = Vector3.new(1.2,1.2,1.2); o.Color = getColor(Settings.OrbColor); o.Material = Enum.Material.Neon; o.Anchored = true; o.CanCollide = false; return o end
        local o1, o2 = createOrb(), createOrb()
        orbitConnection = RunService.Heartbeat:Connect(function()
            if not hrp or not hrp.Parent then applyOrbitOrbs(); return end
            local t = tick() * 4; local cp = hrp.Position
            o1.Position = Vector3.new(cp.X + math.cos(t) * 4.5, cp.Y + math.sin(t*2) * 0.5, cp.Z + math.sin(t) * 4.5)
            o2.Position = Vector3.new(cp.X + math.cos(t + math.pi) * 4.5, cp.Y + math.sin(t*2 + math.pi) * 0.5, cp.Z + math.sin(t + math.pi) * 4.5)
        end)
    end)
end

-- ==================[ PARTICLES ]======================
local function spawnParticle()
    if not Settings.FloatingParticles or not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local col = getColor(Settings.ParticleColor)
    local p = Instance.new("Part"); p.Shape = Enum.PartType.Ball; p.Size = Vector3.new(0.45,0.45,0.45); p.Color = col
    p.Material = Enum.Material.Neon; p.Anchored = true; p.CanCollide = false; p.Transparency = 0.1; p.Parent = Camera
    table.insert(Particles, {Part = p, Pos = hrp.Position + Vector3.new(math.random(-50,50), math.random(-5,25), math.random(-50,50)), Vel = Vector3.new(math.random(-15,15)/10, math.random(-5,15)/10, math.random(-15,15)/10), Age = 0, MaxAge = math.random(50,90)/10, Seed = math.random(1,1000)})
end

-- ==================[ FOG ]======================
local function updateFog()
    pcall(function()
        if Settings.Fog then
            Lighting.FogEnd = Settings.FogDistance; Lighting.FogStart = Settings.FogDistance * 0.3; Lighting.FogColor = getColor(Settings.FogColor)
        else Lighting.FogEnd = 100000; Lighting.FogStart = 100000 end
    end)
end

-- ==================[ FPS ]======================
local function createFPSDisplay()
    if FPSGui then pcall(function() FPSGui.Gui:Destroy() end) end
    local sg = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    sg.Name = "FPSDisplay"; sg.IgnoreGuiInset = true; sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame", sg); frame.Size = UDim2.new(0, 80, 0, 30); frame.Position = UDim2.new(0, 10, 0, 75)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0); frame.BackgroundTransparency = 0.4; frame.BorderSizePixel = 0; frame.ZIndex = 99999
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", frame).Color = UI_ACCENT
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,0,1,0); label.Text = "FPS: 0"
    label.TextColor3 = UI_ACCENT_LIGHT; label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBlack; label.TextSize = 13; label.ZIndex = 99999
    FPSGui = {Gui = sg, Label = label}
    local lastTime = tick(); local frames = 0
    FPSConnection = RunService.RenderStepped:Connect(function()
        frames = frames + 1; local now = tick(); local delta = now - lastTime
        if delta >= 0.5 then
            local fps = math.floor(frames / delta); label.Text = "FPS: " .. math.max(fps, 0)
            label.TextColor3 = fps >= 60 and Color3.fromRGB(255,100,100) or (fps >= 30 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,50,50))
            frames = 0; lastTime = now
        end
    end)
end

-- ==================[ SKYBOX ]======================
local skyboxImages = {
    Red = {SkyboxBk="rbxassetid://70870101892789",SkyboxDn="rbxassetid://70870101892789",SkyboxFt="rbxassetid://70870101892789",SkyboxLf="rbxassetid://70870101892789",SkyboxRt="rbxassetid://70870101892789",SkyboxUp="rbxassetid://70870101892789"},
    Purple = {SkyboxBk="rbxassetid://117968011922954",SkyboxDn="rbxassetid://117968011922954",SkyboxFt="rbxassetid://117968011922954",SkyboxLf="rbxassetid://117968011922954",SkyboxRt="rbxassetid://117968011922954",SkyboxUp="rbxassetid://117968011922954"},
    Blue = {SkyboxBk="rbxassetid://108023272659702",SkyboxDn="rbxassetid://108023272659702",SkyboxFt="rbxassetid://108023272659702",SkyboxLf="rbxassetid://108023272659702",SkyboxRt="rbxassetid://108023272659702",SkyboxUp="rbxassetid://108023272659702"},
    White = {SkyboxBk="rbxassetid://73989916383543",SkyboxDn="rbxassetid://73989916383543",SkyboxFt="rbxassetid://73989916383543",SkyboxLf="rbxassetid://73989916383543",SkyboxRt="rbxassetid://73989916383543",SkyboxUp="rbxassetid://73989916383543"},
    Constellation = {SkyboxBk="rbxassetid://94449088950019",SkyboxDn="rbxassetid://94449088950019",SkyboxFt="rbxassetid://94449088950019",SkyboxLf="rbxassetid://94449088950019",SkyboxRt="rbxassetid://94449088950019",SkyboxUp="rbxassetid://94449088950019"},
}
local function applySkybox(skyType)
    pcall(function()
        if Lighting:FindFirstChild("CustomSky") then Lighting.CustomSky:Destroy() end
        if not Settings.CustomSkybox then return end
        local sky = Instance.new("Sky", Lighting); sky.Name = "CustomSky"
        for k, v in pairs(skyboxImages[skyType] or skyboxImages.White) do sky[k] = v end
    end)
end

-- ==================[ FOV ]======================
local function applyFOV()
    pcall(function()
        if fovConnection then fovConnection:Disconnect(); fovConnection = nil end
        if Settings.FOV then
            Camera.FieldOfView = Settings.FOVValue
            fovConnection = RunService.RenderStepped:Connect(function()
                if Settings.FOV then
                    local current = Camera.FieldOfView; local target = Settings.FOVValue
                    if math.abs(current - target) > 0.1 then Camera.FieldOfView = current + (target - current) * 0.1
                    else Camera.FieldOfView = target end
                else
                    local current = Camera.FieldOfView
                    if math.abs(current - 70) > 0.1 then Camera.FieldOfView = current + (70 - current) * 0.1
                    else Camera.FieldOfView = 70; if fovConnection then fovConnection:Disconnect(); fovConnection = nil end end
                end
            end)
        else Camera.FieldOfView = 70 end
    end)
end

-- ==================[ CUSTOM CROSSHAIR (КРУТЯЩИЙСЯ КРЕСТ) ]======================
local crosshairRotation = 0

local function updateCustomCrosshair()
    pcall(function()
        if crosshairGui then crosshairGui:Destroy(); crosshairGui = nil end
        if not Settings.CustomCrosshair then return end
        crosshairGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
        crosshairGui.Name = "CustomCrosshair"; crosshairGui.IgnoreGuiInset = true; crosshairGui.ResetOnSpawn = false
        crosshairContainer = Instance.new("Frame", crosshairGui); crosshairContainer.Size = UDim2.new(0,100,0,100)
        crosshairContainer.Position = UDim2.new(0.5,-50,0.5,-50); crosshairContainer.BackgroundTransparency = 1
        crosshairContainer.Rotation = crosshairRotation
        local c = getColor(Settings.CrosshairColor); local s = Settings.CrosshairSize; local t = 2
        local g = 4; local l = s*0.5
        local function cl(x,y,w,h) local ln = Instance.new("Frame", crosshairContainer); ln.Size = UDim2.new(0,w,0,h); ln.Position = UDim2.new(0.5,x,0.5,y); ln.BackgroundColor3 = c; ln.BorderSizePixel = 0; ln.AnchorPoint = Vector2.new(0.5,0.5) end
        cl(0,-g-l/2,t,l); cl(0,g+l/2,t,l); cl(-g-l/2,0,l,t); cl(g+l/2,0,l,t)
    end)
end

-- Анимация вращения крестика
RunService.RenderStepped:Connect(function(dt)
    if Settings.CustomCrosshair and crosshairContainer then
        crosshairRotation = crosshairRotation + 60 * dt
        if crosshairRotation >= 360 then crosshairRotation = crosshairRotation - 360 end
        pcall(function() crosshairContainer.Rotation = crosshairRotation end)
    end
end)

-- ==================[ WORLD VISUALS (ТОЛЬКО WIREFRAME И FULL BRIGHT) ]======================
local function applyFullBright()
    pcall(function()
        if Settings.FullBright then
            Lighting.Brightness = 3; Lighting.Ambient = Color3.fromRGB(255, 255, 255); Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255); Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(0, 0, 0); Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0); Lighting.GlobalShadows = true
        end
    end)
end

local function applyWireframeMode()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
                if Settings.WireframeMode then obj.Material = Enum.Material.ForceField
                else obj.Material = Enum.Material.SmoothPlastic end
            end
        end
    end)
end

-- ==================[ RAGE FUNCTIONS ]======================
local function toggleNoclip()
    Settings.Noclip = not Settings.Noclip
    if Settings.Noclip then
        notifyOnEnable("Noclip")
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if Settings.Noclip and LocalPlayer.Character then
                pcall(function()
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                end)
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if LocalPlayer.Character then
            pcall(function()
                for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
            end)
        end
    end
end

local function toggleGodMode()
    Settings.GodMode = not Settings.GodMode
    if Settings.GodMode then
        notifyOnEnable("God Mode")
        if godConn then godConn:Disconnect() end
        godConn = RunService.Heartbeat:Connect(function()
            if Settings.GodMode and LocalPlayer.Character then
                pcall(function()
                    local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h and h.Health > 0 then h.Health = h.MaxHealth end
                end)
            end
        end)
    else if godConn then godConn:Disconnect(); godConn = nil end end
end

local function createFlyJoystick()
    if flyJoystick then return end
    local FlyGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    FlyGui.Name = "FlyGUI"; FlyGui.ResetOnSpawn = false
    flyJoystick = Instance.new("Frame", FlyGui)
    flyJoystick.Size = UDim2.new(0,120,0,120); flyJoystick.Position = UDim2.new(0,45,1,-175)
    flyJoystick.BackgroundColor3 = Color3.fromRGB(0,0,0); flyJoystick.BackgroundTransparency = 0.4
    flyJoystick.BorderSizePixel = 1; flyJoystick.BorderColor3 = UI_ACCENT; flyJoystick.Visible = false; flyJoystick.ZIndex = 100
    Instance.new("UICorner", flyJoystick).CornerRadius = UDim.new(0.5,0)
    flyStick = Instance.new("TextButton", flyJoystick)
    flyStick.Size = UDim2.new(0,46,0,46); flyStick.Position = UDim2.new(0.5,-23,0.5,-23)
    flyStick.BackgroundColor3 = UI_ACCENT; flyStick.BorderSizePixel = 0; flyStick.Text = ""; flyStick.AutoButtonColor = false; flyStick.ZIndex = 101
    Instance.new("UICorner", flyStick).CornerRadius = UDim.new(0.5,0)
    flyStick.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local center = flyJoystick.AbsolutePosition + flyJoystick.AbsoluteSize/2
            local diff = Vector2.new(input.Position.X, input.Position.Y) - center; local maxR = flyJoystick.AbsoluteSize.X/2 - 10
            if diff.Magnitude > maxR then diff = diff.Unit * maxR end
            flyStick.Position = UDim2.new(0.5, diff.X-23, 0.5, diff.Y-23); flyMoveDir = Vector3.new(diff.X/maxR, 0, diff.Y/maxR)
        end
    end)
    flyStick.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            flyStick.Position = UDim2.new(0.5,-23,0.5,-23); flyMoveDir = Vector3.zero
        end
    end)
end

local function startFly()
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity", root); flyBV.MaxForce = Vector3.new(400000,400000,400000); flyBV.Velocity = Vector3.zero
    flyBG = Instance.new("BodyGyro", root); flyBG.MaxTorque = Vector3.new(400000,400000,400000); flyBG.CFrame = root.CFrame
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.Heartbeat:Connect(function()
        if not Settings.Fly then return end
        local c = LocalPlayer.Character; if not c then return end; local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end
        local md = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then md += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then md -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then md -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then md += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then md += Vector3.new(0, -1, 0) end
        if flyMoveDir.Magnitude > 0 then md += Camera.CFrame:VectorToWorldSpace(Vector3.new(flyMoveDir.X, 0, flyMoveDir.Z)) end
        if md.Magnitude > 0 then flyBV.Velocity = md.Unit * Settings.FlySpeed else flyBV.Velocity = Vector3.zero end
        flyBG.CFrame = CFrame.lookAt(r.Position, r.Position + Camera.CFrame.LookVector)
        pcall(function() for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end)
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = false end
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
        end)
    end
    if flyBV then flyBV:Destroy(); flyBV = nil end; if flyBG then flyBG:Destroy(); flyBG = nil end
end
local function toggleFly()
    Settings.Fly = not Settings.Fly; createFlyJoystick()
    if Settings.Fly then
        notifyOnEnable("Fly")
        if flyJoystick then flyJoystick.Visible = true end
        startFly()
    else
        if flyJoystick then flyJoystick.Visible = false end
        stopFly()
    end
end

local function findSafePos()
    if not LocalPlayer.Character then return nil end
    local baseplate = Workspace:FindFirstChild("Baseplate") or Workspace:FindFirstChild("Floor")
    if baseplate then return CFrame.new(baseplate.Position + Vector3.new(0, 10, 0)) end
    return CFrame.new(0, 10, 0)
end
local function toggleAntiFling()
    Settings.AntiFling = not Settings.AntiFling
    if Settings.AntiFling then
        notifyOnEnable("Anti-Fling")
        if aflConn then aflConn:Disconnect() end
        aflConn = RunService.Heartbeat:Connect(function()
            if not Settings.AntiFling then return end
            local char = LocalPlayer.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local vel = hrp.Velocity; local pos = hrp.Position; local now = tick()
            local isFling = vel.Magnitude > 500 or pos.Y < -100 or pos.Y > 1000
            if lastGoodPosition ~= Vector3.zero and (pos - lastGoodPosition).Magnitude / math.max(now - lastGoodTime, 0.001) > 1000 then isFling = true end
            if isFling then local safePos = findSafePos()
                if safePos then hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero; hrp.CFrame = safePos end
            else if pos.Y > -20 and pos.Y < 300 and vel.Magnitude < 100 then lastGoodPosition = pos; lastGoodTime = now end end
        end)
    else if aflConn then aflConn:Disconnect(); aflConn = nil end end
end

local function findMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character; local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and (char:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife"))) then return p, char end
        end
    end; return nil, nil
end
local function findPlayerByRole(roleType)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character; local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                if roleType == "Murderer" and (char:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife"))) then return char
                elseif roleType == "Sheriff" and (char:FindFirstChild("Gun") or (p.Backpack and p.Backpack:FindFirstChild("Gun"))) then return char end
            end
        end
    end; return nil
end
local function toggleAntiKnife()
    Settings.AntiKnife = not Settings.AntiKnife
    if Settings.AntiKnife then
        notifyOnEnable("Anti-Knife")
        if antiKnifeConn then antiKnifeConn:Disconnect() end
        antiKnifeConn = RunService.Heartbeat:Connect(function()
            if not Settings.AntiKnife then return end
            local myChar = LocalPlayer.Character; if not myChar then return end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
            local _, murdererChar = findMurderer(); if not murdererChar then return end
            local mHRP = murdererChar:FindFirstChild("HumanoidRootPart"); if not mHRP then return end
            local dist = (mHRP.Position - myHRP.Position).Magnitude; local now = tick()
            if dist <= Settings.AntiKnifeDistance and (now - lastTPTime) > 2 then
                lastTPTime = now; local safePos = findSafePos()
                if safePos then myHRP.CFrame = safePos end
            end
        end)
    else if antiKnifeConn then antiKnifeConn:Disconnect(); antiKnifeConn = nil end end
end

local function toggleSpinbot()
    Settings.Spinbot = not Settings.Spinbot
    if Settings.Spinbot then
        notifyOnEnable("Spinbot")
        if spinConn then spinConn:Disconnect() end
        spinConn = RunService.Heartbeat:Connect(function()
            if not Settings.Spinbot then return end
            local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then
                r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoRotate = false end
            end
        end)
    else
        if spinConn then spinConn:Disconnect(); spinConn = nil end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoRotate = true end
    end
end

local function toggleJumpPower()
    Settings.JumpPower = not Settings.JumpPower
    if Settings.JumpPower then
        notifyOnEnable("Jump Power")
        if jumpConn then jumpConn:Disconnect() end
        jumpConn = UserInputService.JumpRequest:Connect(function()
            if not Settings.JumpPower then return end
            local c = LocalPlayer.Character; if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid"); local r = c:FindFirstChild("HumanoidRootPart")
            if h and r then
                h.JumpPower = Settings.JumpMultiplier
                h.Jump = true
                r.Velocity = Vector3.new(r.Velocity.X, Settings.JumpMultiplier * 0.8, r.Velocity.Z)
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
    end
end

local function toggleBunnyHop()
    Settings.BunnyHop = not Settings.BunnyHop
    if Settings.BunnyHop then
        notifyOnEnable("Bunny Hop")
        if bhopConn then bhopConn:Disconnect() end
        bhopConn = RunService.Heartbeat:Connect(function()
            if not Settings.BunnyHop then return end
            local c = LocalPlayer.Character; if not c then return end
            local h = c:FindFirstChild("Humanoid"); local r = c:FindFirstChild("HumanoidRootPart")
            if not h or not r or h.FloorMaterial == Enum.Material.Air then return end
            local md = h.MoveDirection
            if md.Magnitude < 0.1 then return end
            h.Jump = true
            local sp = Vector3.new(r.Velocity.X, 0, r.Velocity.Z).Magnitude
            if sp > 5 then
                local d = Vector3.new(md.X, 0, md.Z).Unit
                r.Velocity = Vector3.new(
                    d.X * math.min(sp * Settings.BHOPMultiplier, Settings.BHOPMaxSpeed),
                    r.Velocity.Y,
                    d.Z * math.min(sp * Settings.BHOPMultiplier, Settings.BHOPMaxSpeed)
                )
            end
        end)
    else
        if bhopConn then bhopConn:Disconnect(); bhopConn = nil end
    end
end

local function toggleWallHop()
    Settings.WallHop = not Settings.WallHop
    if Settings.WallHop then
        notifyOnEnable("Wall Hop")
        if wallHopConn then wallHopConn:Disconnect() end
        wallHopConn = UserInputService.JumpRequest:Connect(function()
            if not Settings.WallHop then return end
            local c = LocalPlayer.Character; if not c then return end
            local r = c:FindFirstChild("HumanoidRootPart"); local h = c:FindFirstChildOfClass("Humanoid")
            if not r or not h then return end
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = {c}
            local near = false
            for _, d in ipairs({r.CFrame.LookVector, -r.CFrame.LookVector, r.CFrame.RightVector, -r.CFrame.RightVector}) do
                if workspace:Raycast(r.Position, d * 2.2, rp) then near = true break end
            end
            if near then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if wallHopConn then wallHopConn:Disconnect(); wallHopConn = nil end
    end
end

local function toggleAntiLag()
    Settings.AntiLag = not Settings.AntiLag
    if Settings.AntiLag then
        notifyOnEnable("Anti-Lag")
        for _, obj in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then antiLagMaterials[obj] = obj.Material; obj.Material = Enum.Material.SmoothPlastic
                elseif obj:IsA("Decal") or obj:IsA("Texture") then antiLagMaterials[obj] = obj.Transparency; obj.Transparency = 1 end
            end)
        end
    else
        for obj, val in pairs(antiLagMaterials) do
            pcall(function()
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then obj.Material = val elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = val end
                end
            end)
        end
        antiLagMaterials = {}
    end
end

local function makeInvisible()
    if not LocalPlayer.Character then return end; origTrans = {}
    local char = LocalPlayer.Character
    pcall(function()
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then origTrans[p] = {Transparency = p.Transparency, CanCollide = p.CanCollide}; p.Transparency = 1; p.CanCollide = false
            elseif p:IsA("Decal") or p:IsA("Texture") then origTrans[p] = {Transparency = p.Transparency}; p.Transparency = 1
            elseif p:IsA("Accessory") then local handle = p:FindFirstChild("Handle"); if handle then origTrans[handle] = {Transparency = handle.Transparency}; handle.Transparency = 1 end end
        end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then for _, p in ipairs(tool:GetDescendants()) do if p:IsA("BasePart") then origTrans[p] = {Transparency = p.Transparency}; p.Transparency = 1 elseif p:IsA("Decal") or p:IsA("Texture") then origTrans[p] = {Transparency = p.Transparency}; p.Transparency = 1 end end end
        end
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then for _, p in ipairs(tool:GetDescendants()) do if p:IsA("BasePart") then origTrans[p] = {Transparency = p.Transparency}; p.Transparency = 1 elseif p:IsA("Decal") or p:IsA("Texture") then origTrans[p] = {Transparency = p.Transparency}; p.Transparency = 1 end end end
        end
        local hum = char:FindFirstChild("Humanoid"); if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p:SetNetworkOwner(nil) end end
    end)
end
local function makeVisible()
    if not LocalPlayer.Character then return end
    pcall(function()
        for obj, data in pairs(origTrans) do if obj and obj.Parent then if data.Transparency then obj.Transparency = data.Transparency end; if data.CanCollide ~= nil then obj.CanCollide = data.CanCollide end end end
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid"); if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
    end)
    origTrans = {}
end
local function toggleInvisibility()
    Settings.Invisibility = not Settings.Invisibility
    if Settings.Invisibility then
        notifyOnEnable("Invisibility")
        makeInvisible(); invisConn = LocalPlayer.CharacterAdded:Connect(function() task.wait(0.1); if Settings.Invisibility then makeInvisible() end end)
    else makeVisible(); if invisConn then invisConn:Disconnect(); invisConn = nil end end
end

local function findGun()
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") then
            local name = item.Name:lower()
            if name == "gundrop" or name == "gun" or (name == "handle" and item.Parent and item.Parent.Name:lower() == "gun") then
                local parent = item.Parent
                if parent then local isInChar = false; local cur = item
                    while cur do if cur:IsA("Model") and cur:FindFirstChildOfClass("Humanoid") then isInChar = true; break end; cur = cur.Parent end
                    if not isInChar then return item end
                end
            end
        end
    end; return nil
end
local function toggleGunGrabber()
    Settings.GunGrabber = not Settings.GunGrabber
    if Settings.GunGrabber then
        notifyOnEnable("Auto Gun TP")
        if autoGunTPConnection then autoGunTPConnection:Disconnect() end
        autoGunTPConnection = RunService.Heartbeat:Connect(function()
            if not Settings.GunGrabber then return end
            local myChar = LocalPlayer.Character; if not myChar then return end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
            local hasGun = myChar:FindFirstChild("Gun") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))
            if hasGun then return end
            local gun = findGun()
            if gun then
                local gunPos = gun.Position + Vector3.new(0, 3, 0)
                pcall(function() for _, p in ipairs(myChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end)
                myHRP.CFrame = CFrame.new(gunPos)
                task.wait(0.1)
                if firetouchinterest then pcall(function() firetouchinterest(myHRP, gun, 0); task.wait(0.05); firetouchinterest(myHRP, gun, 1) end) end
                local prompt = gun:FindFirstChildOfClass("ProximityPrompt") or (gun.Parent and gun.Parent:FindFirstChildOfClass("ProximityPrompt"))
                if prompt then pcall(function() prompt:InputHoldBegin() end) end
                task.wait(0.3)
                pcall(function() for _, p in ipairs(myChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end)
            end
        end)
    else
        if autoGunTPConnection then autoGunTPConnection:Disconnect(); autoGunTPConnection = nil end
    end
end

local placeId = game.PlaceId
local function toggleAutoRejoin()
    Settings.AutoRejoin = not Settings.AutoRejoin
    if Settings.AutoRejoin then
        notifyOnEnable("Auto Rejoin")
        if rejoinConn then rejoinConn:Disconnect() end
        rejoinConn = RunService.Heartbeat:Connect(function()
            if not Settings.AutoRejoin then return end
            if not LocalPlayer:IsDescendantOf(Players) then task.wait(Settings.RejoinDelay); pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end) end
        end)
    else if rejoinConn then rejoinConn:Disconnect(); rejoinConn = nil end end
end
local function toggleShiftLock()
    Settings.ShiftLock = not Settings.ShiftLock
    if Settings.ShiftLock then
        notifyOnEnable("Shift Lock")
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        if lockConn then lockConn:Disconnect() end
        lockConn = RunService.RenderStepped:Connect(function()
            if not Settings.ShiftLock then return end; UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            local c = LocalPlayer.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart"); local h = c and c:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.Health > 0 then h.AutoRotate = false; hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.atan2(-Camera.CFrame.LookVector.X, -Camera.CFrame.LookVector.Z), 0) end
        end)
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        if lockConn then lockConn:Disconnect(); lockConn = nil end
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.AutoRotate = true end
    end
end

local function toggleZombieWalk()
    Settings.ZombieWalk = not Settings.ZombieWalk
    if Settings.ZombieWalk then
        notifyOnEnable("Zombie Walk")
        if zombieConnection then zombieConnection:Disconnect() end
        zombieConnection = RunService.RenderStepped:Connect(function()
            if not Settings.ZombieWalk then return end
            local char = LocalPlayer.Character; if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid"); local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if hum and torso then
                local leanAngle = math.rad(-50)
                if hum.MoveDirection.Magnitude > 0 then
                    torso.CFrame = torso.CFrame * CFrame.Angles(leanAngle, 0, 0)
                    local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                    local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                    if leftArm then leftArm.CFrame = leftArm.CFrame * CFrame.Angles(math.rad(-90), 0, 0) end
                    if rightArm then rightArm.CFrame = rightArm.CFrame * CFrame.Angles(math.rad(-90), 0, 0) end
                    hum.WalkSpeed = 6
                else torso.CFrame = torso.CFrame * CFrame.Angles(leanAngle, 0, 0); hum.WalkSpeed = 16 end
            end
        end)
    else
        if zombieConnection then zombieConnection:Disconnect(); zombieConnection = nil end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = 16 end
    end
end

-- ==================[ AIMBOT (ИСПРАВЛЕННЫЙ) ]======================
local function createFOVCircle()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    if pg:FindFirstChild("AimbotFOV") then pg.AimbotFOV:Destroy() end
    local fg = Instance.new("ScreenGui", pg); fg.Name = "AimbotFOV"; fg.IgnoreGuiInset = true; fg.ResetOnSpawn = false
    fovCircle = Instance.new("Frame", fg); fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
    fovCircle.Size = UDim2.new(0, Settings.AimbotFOV*2, 0, Settings.AimbotFOV*2); fovCircle.Position = UDim2.new(0.5,0,0.5,0)
    fovCircle.BackgroundColor3 = Color3.fromRGB(255,255,255); fovCircle.BackgroundTransparency = 0.92; fovCircle.BorderSizePixel = 0
    fovCircle.Visible = false; fovCircle.ZIndex = 999; Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", fovCircle).Color = UI_ACCENT; fovCircle:FindFirstChildOfClass("UIStroke").Thickness = 2
end
createFOVCircle()

local function getTargetInFOV()
    local murderer = findPlayerByRole("Murderer"); if not murderer then return nil end
    local head = murderer:FindFirstChild("Head"); if not head then return nil end
    local hrp = murderer:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") and (myChar.HumanoidRootPart.Position - hrp.Position).Magnitude > Settings.AimbotRange then return nil end
    local sp, on = Camera:WorldToViewportPoint(head.Position)
    if on and (Vector2.new(sp.X, sp.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude <= Settings.AimbotFOV then return head end
    return nil
end

local function shoot()
    local char = LocalPlayer.Character; if not char then return false end
    
    local target = findPlayerByRole("Murderer")
    if target then
        local targetPart = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
        if targetPart then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
        end
    end
    
    local gun = char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun"); if not gun then return false end
    local tool = gun:IsA("Tool") and gun or gun:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end); return true end
    pcall(function()
        for _, child in ipairs(gun:GetDescendants()) do
            if child:IsA("RemoteEvent") and child.Name:lower():find("shoot") then
                child:FireServer(Camera.CFrame.Position + Camera.CFrame.LookVector * 100)
                return true
            end
        end
    end)
    return false
end

local function toggleAimbot()
    Settings.Aimbot = not Settings.Aimbot; if fovCircle then fovCircle.Visible = Settings.Aimbot end
    if Settings.Aimbot then
        notifyOnEnable("Aimbot")
        if aimConn then aimConn:Disconnect() end
        aimConn = RunService.RenderStepped:Connect(function()
            if not Settings.Aimbot then return end
            if Settings.AimbotMode == "WeaponOnly" then local c = LocalPlayer.Character; if not c or not (c:FindFirstChild("Gun") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))) then return end end
            local t = getTargetInFOV()
            if t then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
                if Settings.AutoShoot and tick() - lastShootTime > Settings.AutoShootDelay then
                    shoot()
                    lastShootTime = tick()
                end
            end
        end)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if Settings.TriggerBot and not gpe and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                shoot()
            end
        end)
    else
        if aimConn then aimConn:Disconnect(); aimConn = nil end
    end
end

local function setupSilentAim()
    if oldNamecall then return end
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" and Settings.SilentAim then
            local target = findPlayerByRole("Murderer")
            if target then
                local tp = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
                if tp then
                    local mc = LocalPlayer.Character
                    if mc and mc:FindFirstChild("HumanoidRootPart") then
                        local dist = (mc.HumanoidRootPart.Position - tp.Position).Magnitude
                        if dist <= Settings.AimbotRange then
                            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tp.Position)
                            
                            local newArgs = {}
                            for i, arg in ipairs(args) do
                                if typeof(arg) == "Vector3" then
                                    newArgs[i] = tp.Position
                                elseif typeof(arg) == "CFrame" then
                                    newArgs[i] = CFrame.new(tp.Position)
                                else
                                    newArgs[i] = arg
                                end
                            end
                            return oldNamecall(self, unpack(newArgs))
                        end
                    end
                end
            end
        end
        
        if Settings.WallShoot and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
            local target = findPlayerByRole("Murderer")
            if target then
                local tp = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
                if tp then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tp.Position)
                    
                    if method == "FindPartOnRay" then return tp, tp.Position, Vector3.new(0,1,0), "Flesh"
                    elseif method == "FindPartOnRayWithIgnoreList" then return tp, tp.Position, Vector3.new(0,1,0), "Flesh"
                    elseif method == "FindPartOnRayWithWhitelist" then return tp, tp.Position, Vector3.new(0,1,0), "Flesh"
                    else return {Instance = tp, Position = tp.Position, Normal = Vector3.new(0,1,0), Material = Enum.Material.Flesh} end
                end
            end
        end
        
        return oldNamecall(self, unpack(args))
    end))
end
local function cleanupSilentAim()
    if oldNamecall then pcall(function() hookmetamethod(game, "__namecall", oldNamecall) end); oldNamecall = nil end
end
local function toggleSilentAim()
    Settings.SilentAim = not Settings.SilentAim
    if Settings.SilentAim then notifyOnEnable("Silent Aim"); setupSilentAim()
    elseif not Settings.WallShoot then cleanupSilentAim() end
end
local function toggleWallShoot()
    Settings.WallShoot = not Settings.WallShoot
    if Settings.WallShoot then notifyOnEnable("Wall Shoot"); setupSilentAim()
    elseif not Settings.SilentAim then cleanupSilentAim() end
end

-- ==================[ DEATH EFFECT ]======================
local function createSmoothParticle(pos, color, size, lifetime, velocity)
    local p = Instance.new("Part"); p.Size = Vector3.new(0, 0, 0); p.Position = pos; p.Anchored = true; p.CanCollide = false
    p.Material = Enum.Material.Neon; p.Color = color; p.Transparency = 0.6; p.Shape = Enum.PartType.Ball; p.Parent = Workspace
    local light = Instance.new("PointLight", p); light.Color = color; light.Brightness = 0; light.Range = 5; light.Shadows = false
    local growTime = 0.15
    TweenService:Create(p, TweenInfo.new(growTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(size, size, size), Transparency = 0.2}):Play()
    TweenService:Create(light, TweenInfo.new(growTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 3}):Play()
    spawn(function()
        task.wait(growTime); local startTime = tick(); local startPos = p.Position
        while tick() - startTime < lifetime and p.Parent do
            local progress = (tick() - startTime) / lifetime; local ease = progress * progress; local pulse = math.sin(progress * math.pi * 6) * 0.3
            local currentSize = size * (1 - ease * 0.5) * (1 + pulse * 0.2); local currentTransparency = 0.2 + ease * 0.8
            pcall(function() p.Position = startPos + velocity * ease; p.Size = Vector3.new(currentSize, currentSize, currentSize); p.Transparency = currentTransparency; light.Brightness = 3 * (1 - ease) * (0.7 + math.abs(pulse) * 0.5) end)
            velocity = velocity * 0.97; task.wait(0.015)
        end
        TweenService:Create(p, TweenInfo.new(0.2), {Size = Vector3.new(0, 0, 0), Transparency = 1}):Play()
        TweenService:Create(light, TweenInfo.new(0.2), {Brightness = 0}):Play()
        task.delay(0.2, function() pcall(function() p:Destroy() end) end)
    end)
end

local function spawnExplosionEffect(chr)
    if not Settings.DeathEffect or not chr then return end
    local hrp = chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local pos = hrp.Position; local col = getColor(Settings.DeathEffectColor)
    local colors = {col, Color3.fromRGB(math.clamp(col.R*255+50,0,255)/255, math.clamp(col.G*255+50,0,255)/255, math.clamp(col.B*255+50,0,255)/255), Color3.fromRGB(255,255,255)}
    
    local flash = Instance.new("Part"); flash.Size = Vector3.new(0.5,0.5,0.5); flash.Position = pos; flash.Anchored = true; flash.CanCollide = false
    flash.Material = Enum.Material.Neon; flash.Color = Color3.fromRGB(255,255,255); flash.Transparency = 0.3; flash.Shape = Enum.PartType.Ball; flash.Parent = Workspace
    local flashLight = Instance.new("PointLight", flash); flashLight.Color = col; flashLight.Brightness = 15; flashLight.Range = 20; flashLight.Shadows = false
    TweenService:Create(flash, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Vector3.new(8,8,8), Transparency = 0.7}):Play()
    TweenService:Create(flashLight, TweenInfo.new(0.3), {Brightness = 30, Range = 30}):Play()
    spawn(function() task.wait(0.25); TweenService:Create(flash, TweenInfo.new(0.5), {Size = Vector3.new(15,15,15), Transparency = 1}):Play(); TweenService:Create(flashLight, TweenInfo.new(0.5), {Brightness = 0, Range = 0}):Play(); task.delay(0.5, function() pcall(function() flash:Destroy() end) end) end)
    
    local ring = Instance.new("Part"); ring.Size = Vector3.new(0.3,0.3,0.3); ring.Position = pos; ring.Anchored = true; ring.CanCollide = false
    ring.Material = Enum.Material.Neon; ring.Color = col; ring.Transparency = 0.4; ring.Shape = Enum.PartType.Ball; ring.Parent = Workspace
    local ringLight = Instance.new("PointLight", ring); ringLight.Color = col; ringLight.Brightness = 8; ringLight.Range = 15
    TweenService:Create(ring, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(12,12,12), Transparency = 0.9}):Play()
    TweenService:Create(ringLight, TweenInfo.new(0.4), {Brightness = 15, Range = 25}):Play()
    spawn(function() task.wait(0.4); TweenService:Create(ring, TweenInfo.new(0.3), {Size = Vector3.new(20,20,20), Transparency = 1}):Play(); TweenService:Create(ringLight, TweenInfo.new(0.3), {Brightness = 0}):Play(); task.delay(0.3, function() pcall(function() ring:Destroy() end) end) end)
    
    for i = 1, 60 do
        local angle = math.random() * math.pi * 2; local elevation = (math.random() - 0.5) * math.pi; local distance = 2 + math.random() * 8
        local spawnPos = pos + Vector3.new(math.cos(angle)*math.cos(elevation)*distance, math.sin(elevation)*distance, math.sin(angle)*math.cos(elevation)*distance)
        local velocity = (spawnPos - pos).Unit * (10 + math.random() * 20); local particleSize = 0.15 + math.random() * 0.5
        local lifetime = 0.8 + math.random() * 1.2; local particleColor = colors[math.random(1, #colors)]
        createSmoothParticle(spawnPos, particleColor, particleSize, lifetime, velocity)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        local hum = p.Character:FindFirstChild("Humanoid")
        if hum then hum.Died:Connect(function() task.wait(0.05); spawnExplosionEffect(p.Character) end) end
    end
    p.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 20)
        if hum then hum.Died:Connect(function() task.wait(0.05); spawnExplosionEffect(char) end) end
    end)
end

local function setupKillSound()
    if KillSoundConnection then KillSoundConnection:Disconnect() end
    local sound = Instance.new("Sound", CoreGui); sound.SoundId = "rbxassetid://9117606734"; sound.Volume = 1
    local lastKills = {}
    KillSoundConnection = RunService.Heartbeat:Connect(function()
        if not Settings.KillSound then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum then
                    if hum.Health <= 0 and lastKills[plr.Name] then sound:Play(); lastKills[plr.Name] = false
                    elseif hum.Health > 0 then lastKills[plr.Name] = true end
                end
            end
        end
    end)
end

local TauntList = {"/e dance", "/e dance2", "/e dance3", "/e wave", "/e point", "/e cheer", "/e laugh", "/e victory", "/e flex", "/e salute"}
local function autoTaunt()
    if not Settings.AutoTaunt then return end; if tick() - lastTauntTime < 5 then return end
    if not LocalPlayer.Character then return end; local hum = LocalPlayer.Character:FindFirstChild("Humanoid"); if not hum or hum.Health <= 0 then return end
    pcall(function() ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(TauntList[math.random(1, #TauntList)], "All") end)
    lastTauntTime = tick()
end

-- ==================[ CLICK TP ]======================
local function setupClickTP()
    if clickTPConnection then clickTPConnection:Disconnect(); clickTPConnection = nil end
    if clickTPTapConnection then clickTPTapConnection:Disconnect(); clickTPTapConnection = nil end
    
    if not Settings.ClickTP then return end
    
    clickTPConnection = Mouse.Button1Down:Connect(function()
        if not Settings.ClickTP then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and Mouse.Hit then
            pcall(function()
                hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end)
        end
    end)
    
    clickTPTapConnection = UserInputService.TouchTap:Connect(function(touchPositions)
        if not Settings.ClickTP then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and touchPositions and #touchPositions > 0 then
            pcall(function()
                local camera = workspace.CurrentCamera
                local ray = camera:ScreenPointToRay(touchPositions[1].X, touchPositions[1].Y)
                local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000)
                if raycastResult then
                    hrp.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
                end
            end)
        end
    end)
end

local function toggleClickTP()
    Settings.ClickTP = not Settings.ClickTP
    if Settings.ClickTP then
        notifyOnEnable("Click TP")
        setupClickTP()
    else
        if clickTPConnection then clickTPConnection:Disconnect(); clickTPConnection = nil end
        if clickTPTapConnection then clickTPTapConnection:Disconnect(); clickTPTapConnection = nil end
    end
end

-- ==================[ AUTO FARM ]======================
local function findCoins()
    local coins = {}
    for _, o in ipairs(Workspace:GetDescendants()) do if o:IsA("BasePart") and not o.Anchored and o.Name:lower():find("coin") then table.insert(coins, o) end end
    if LocalPlayer.Character then local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then table.sort(coins, function(a,b) return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude end) end
    end; return coins
end
local function startFarmFly()
    local char = LocalPlayer.Character; if not char then return end; local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    if farmFlyBodyGyro then farmFlyBodyGyro:Destroy() end; farmFlyBodyGyro = Instance.new("BodyGyro", root); farmFlyBodyGyro.MaxTorque = Vector3.new(400000,400000,400000); farmFlyBodyGyro.CFrame = root.CFrame
    if farmFlyBodyVelocity then farmFlyBodyVelocity:Destroy() end; farmFlyBodyVelocity = Instance.new("BodyVelocity", root); farmFlyBodyVelocity.MaxForce = Vector3.new(400000,400000,400000); farmFlyBodyVelocity.Velocity = Vector3.zero
end
local function stopFarmFly()
    if farmFlyBodyGyro then farmFlyBodyGyro:Destroy(); farmFlyBodyGyro = nil end; if farmFlyBodyVelocity then farmFlyBodyVelocity:Destroy(); farmFlyBodyVelocity = nil end
end
local function toggleAutoFarm()
    Settings.AutoFarm = not Settings.AutoFarm
    if Settings.AutoFarm then
        notifyOnEnable("Auto Farm")
        if not Settings.Noclip then Settings.Noclip = true; toggleNoclip() end
        startFarmFly()
        if farmConn then farmConn:Disconnect() end
        farmConn = RunService.Heartbeat:Connect(function()
            if not Settings.AutoFarm then return end; if not LocalPlayer.Character then return end
            if not Settings.Noclip then Settings.Noclip = true; toggleNoclip() end
            local coins = findCoins()
            for _, coin in ipairs(coins) do
                if not Settings.AutoFarm or not coin.Parent then break end
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not root then break end
                farmFlyBodyVelocity.Velocity = (coin.Position - root.Position).Unit * 80
                farmFlyBodyGyro.CFrame = CFrame.lookAt(root.Position, coin.Position)
                if (coin.Position - root.Position).Magnitude < 3 and firetouchinterest then pcall(function() firetouchinterest(root, coin, 0); firetouchinterest(root, coin, 1) end) end
                RunService.Heartbeat:Wait()
            end
        end)
    else if farmConn then farmConn:Disconnect(); farmConn = nil end; stopFarmFly() end
end

local function toggleAntiVoid()
    Settings.AntiVoid = not Settings.AntiVoid
    if Settings.AntiVoid then
        notifyOnEnable("Anti-Void")
        if antiVoidConn then antiVoidConn:Disconnect() end
        antiVoidConn = RunService.Heartbeat:Connect(function()
            if not Settings.AntiVoid then return end
            local char = LocalPlayer.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            if hrp.Position.Y < -50 then
                local safePos = findSafePos()
                if safePos then hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero; hrp.CFrame = safePos
                    notifyOnAction("Anti-Void", "Телепортация на безопасную позицию!") end
            end
        end)
    else if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end end
end

local function findNearestPlayer()
    local nearest = nil; local nearestDist = math.huge
    local myChar = LocalPlayer.Character; if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local theirChar = plr.Character; local theirHum = theirChar:FindFirstChild("Humanoid"); local theirHRP = theirChar:FindFirstChild("HumanoidRootPart")
            if theirHum and theirHum.Health > 0 and theirHRP then
                local dist = (myHRP.Position - theirHRP.Position).Magnitude
                if dist < nearestDist then nearestDist = dist; nearest = {Player = plr, Character = theirChar, HRP = theirHRP, Humanoid = theirHum, Distance = dist} end
            end
        end
    end; return nearest
end

local function equipKnife()
    local char = LocalPlayer.Character; if not char then return false end
    local knife = char:FindFirstChild("Knife"); if knife and knife:IsA("Tool") then return true end
    local backpack = LocalPlayer.Backpack
    if backpack then knife = backpack:FindFirstChild("Knife")
        if knife and knife:IsA("Tool") then pcall(function() local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(knife) return true end end) end
    end
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("Tool") and item.Name == "Knife" and not item.Parent:IsA("Model") then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(item.Handle.Position + Vector3.new(0, 3, 0))
                task.wait(0.1)
                if firetouchinterest then pcall(function() firetouchinterest(hrp, item.Handle, 0); task.wait(0.05); firetouchinterest(hrp, item.Handle, 1) end) end
                task.wait(0.3)
                if char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then notifyOnAction("Auto Knife", "Нож найден и экипирован!"); return true end
            end; break
        end
    end; return false
end

local function attackWithKnife(target)
    if not target or not target.Humanoid or target.Humanoid.Health <= 0 then return false end
    local myChar = LocalPlayer.Character; if not myChar then return false end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart"); local targetHRP = target.HRP
    if not myHRP or not targetHRP then return false end
    local attackPos = targetHRP.Position
    pcall(function() for _, p in ipairs(myChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end)
    myHRP.CFrame = CFrame.new(attackPos)
    local knife = myChar:FindFirstChild("Knife")
    if knife then pcall(function() knife:Activate() end); task.wait(0.1); pcall(function() knife:Deactivate() end) end
    if target.Humanoid.Health <= 0 then return true end
    if target.Humanoid.Health > 0 and firetouchinterest then
        local tool = myChar:FindFirstChild("Knife")
        if tool and tool:FindFirstChild("Handle") then pcall(function() firetouchinterest(tool.Handle, targetHRP, 0); task.wait(0.05); firetouchinterest(tool.Handle, targetHRP, 1) end) end
    end
    task.wait(0.2)
    if target.Humanoid and target.Humanoid.Health <= 0 then return true end
    return false
end

local function toggleAutoKnife()
    Settings.AutoKnife = not Settings.AutoKnife
    if Settings.AutoKnife then
        notifyOnEnable("Auto Knife")
        local hasKnife = equipKnife()
        if not hasKnife then notifyOnAction("Auto Knife", "Нож не найден! Ищу на карте...") end
        if autoKnifeConn then autoKnifeConn:Disconnect() end
        autoKnifeConn = RunService.Heartbeat:Connect(function()
            if not Settings.AutoKnife then return end
            local myChar = LocalPlayer.Character; if not myChar then return end
            local hasKnife = myChar:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
            if not hasKnife then equipKnife(); return end
            if not myChar:FindFirstChild("Knife") then local hum = myChar:FindFirstChildOfClass("Humanoid"); local knife = LocalPlayer.Backpack:FindFirstChild("Knife"); if hum and knife then hum:EquipTool(knife); task.wait(0.2) end end
            local target = findNearestPlayer(); if not target then return end
            local killed = attackWithKnife(target)
            if killed then lastKnifeKillTime = tick(); notifyOnAction("Auto Knife", "Убит: " .. target.Player.Name); task.wait(0.05)
            else task.wait(0.1) end
        end)
    else
        if autoKnifeConn then autoKnifeConn:Disconnect(); autoKnifeConn = nil end
        if LocalPlayer.Character then pcall(function() for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end) end
    end
end

-- ==================[ PANIC KEY ]======================
local function setupPanicKey()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode[Settings.PanicKey] then
            for k, v in pairs(Settings) do if type(v) == "boolean" then Settings[k] = false end end
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            if godConn then godConn:Disconnect(); godConn = nil end
            if flyConn then flyConn:Disconnect(); flyConn = nil end; stopFly()
            if aflConn then aflConn:Disconnect(); aflConn = nil end
            if antiKnifeConn then antiKnifeConn:Disconnect(); antiKnifeConn = nil end
            if spinConn then spinConn:Disconnect(); spinConn = nil end
            if bhopConn then bhopConn:Disconnect(); bhopConn = nil end
            if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
            if wallHopConn then wallHopConn:Disconnect(); wallHopConn = nil end
            if invisConn then invisConn:Disconnect(); invisConn = nil end; makeVisible()
            if lockConn then lockConn:Disconnect(); lockConn = nil end
            if zombieConnection then zombieConnection:Disconnect(); zombieConnection = nil end
            if aimConn then aimConn:Disconnect(); aimConn = nil end
            if fovConnection then fovConnection:Disconnect(); fovConnection = nil end
            if KillSoundConnection then KillSoundConnection:Disconnect(); KillSoundConnection = nil end
            if farmConn then farmConn:Disconnect(); farmConn = nil end; stopFarmFly()
            if autoGunTPConnection then autoGunTPConnection:Disconnect(); autoGunTPConnection = nil end
            if SkeletonESPConnection then SkeletonESPConnection:Disconnect(); SkeletonESPConnection = nil end
            if SpectatorConnection then SpectatorConnection:Disconnect(); SpectatorConnection = nil end
            if FPSConnection then FPSConnection:Disconnect(); FPSConnection = nil end
            if FPSGui then pcall(function() FPSGui.Gui:Destroy() end); FPSGui = nil end
            if InfoConnection then InfoConnection:Disconnect(); InfoConnection = nil end
            if InfoGui then pcall(function() InfoGui.Gui:Destroy() end); InfoGui = nil end
            if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
            if autoKnifeConn then autoKnifeConn:Disconnect(); autoKnifeConn = nil end
            if clickTPConnection then clickTPConnection:Disconnect(); clickTPConnection = nil end
            if clickTPTapConnection then clickTPTapConnection:Disconnect(); clickTPTapConnection = nil end
            cleanupSilentAim(); removeAllTrails()
            if LocalPlayer.Character then
                pcall(function()
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true; p.Transparency = 0 end end
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.AutoRotate = true; hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
                end)
            end
            Camera.FieldOfView = 70
            notifyOnAction("PANIC MODE", "Все функции отключены!")
        end
    end)
end
setupPanicKey()

local function saveConfig()
    if not Settings.AutoSave then return end
    local data = {}
    for k, v in pairs(Settings) do if type(v) ~= "function" and type(v) ~= "table" then data[k] = v end end
    local json = HttpService:JSONEncode(data)
    pcall(function() writefile("HESERS_Config.json", json) end)
end

local function loadConfig()
    if not Settings.AutoLoad then return end
    if not isfile("HESERS_Config.json") then return end
    local success, jsonData = pcall(function() return readfile("HESERS_Config.json") end)
    if not success or not jsonData then return end
    local success2, data = pcall(function() return HttpService:JSONDecode(jsonData) end)
    if not success2 or not data then return end
    for k, v in pairs(data) do if Settings[k] ~= nil and type(v) == type(Settings[k]) then Settings[k] = v end end
    updateTheme()
end

game.Players.PlayerRemoving:Connect(function(plr) if plr == LocalPlayer then saveConfig() end end)

local Keybinds = {
    Noclip = "N", GodMode = "B", Fly = "F", Invisibility = "I", Aimbot = "V", ESP = "M", AutoFarm = "P", MenuToggle = "RightControl", AutoKnife = "K",
}

local function setupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode[Keybinds.Noclip] then toggleNoclip() end
        if input.KeyCode == Enum.KeyCode[Keybinds.GodMode] then toggleGodMode() end
        if input.KeyCode == Enum.KeyCode[Keybinds.Fly] then toggleFly() end
        if input.KeyCode == Enum.KeyCode[Keybinds.Invisibility] then toggleInvisibility() end
        if input.KeyCode == Enum.KeyCode[Keybinds.Aimbot] then toggleAimbot() end
        if input.KeyCode == Enum.KeyCode[Keybinds.ESP] then Settings.ESP = not Settings.ESP end
        if input.KeyCode == Enum.KeyCode[Keybinds.AutoFarm] then toggleAutoFarm() end
        if input.KeyCode == Enum.KeyCode[Keybinds.AutoKnife] then toggleAutoKnife() end
        if input.KeyCode == Enum.KeyCode[Keybinds.MenuToggle] then CreateMainMenu() end
    end)
end
setupKeybinds()

local function createInfoDisplay()
    if InfoGui then pcall(function() InfoGui.Gui:Destroy() end) end
    if not Settings.ShowPing and not Settings.ShowPlayTime then if InfoConnection then InfoConnection:Disconnect(); InfoConnection = nil end return end
    local sg = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    sg.Name = "InfoDisplay"; sg.IgnoreGuiInset = true; sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame", sg); frame.Size = UDim2.new(0, 100, 0, 30); frame.Position = UDim2.new(0, 10, 0, 110)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0); frame.BackgroundTransparency = 0.5; frame.BorderSizePixel = 0; frame.ZIndex = 99999
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", frame).Color = UI_ACCENT
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, 0, 1, 0); label.Text = ""; label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBold; label.TextSize = 10; label.ZIndex = 99999
    InfoGui = {Gui = sg, Label = label}
    local startTime = tick()
    InfoConnection = RunService.RenderStepped:Connect(function()
        local texts = {}
        if Settings.ShowPing then local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 1000); table.insert(texts, "Ping " .. ping .. "ms") end
        if Settings.ShowPlayTime then local elapsed = tick() - startTime + Settings.PlayTime; local hours = math.floor(elapsed / 3600); local minutes = math.floor((elapsed % 3600) / 60); local seconds = math.floor(elapsed % 60); table.insert(texts, string.format("Time %02d:%02d:%02d", hours, minutes, seconds)) end
        label.Text = table.concat(texts, "\n"); Settings.PlayTime = tick() - startTime + Settings.PlayTime; startTime = tick()
    end)
end

local function toggleInfoDisplay()
    if InfoGui then pcall(function() InfoGui.Gui:Destroy() end); InfoGui = nil end
    if InfoConnection then InfoConnection:Disconnect(); InfoConnection = nil end
    createInfoDisplay()
end

-- ==================[ ОСНОВНОЙ ЦИКЛ ]======================
RunService.RenderStepped:Connect(function(dt)
    updateESP(); updateRoleChams()
    if Settings.FloatingParticles and tick() - lastParticleSpawn > 0.02 and #Particles < 180 then lastParticleSpawn = tick(); spawnParticle() end
    for i = #Particles, 1, -1 do
        local p = Particles[i]; p.Age = p.Age + dt
        if p.Age >= p.MaxAge or (p.Pos - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero)).Magnitude > 75 then p.Part:Destroy(); table.remove(Particles, i)
        else local pw = math.sin(tick()*8 + p.Seed); p.Part.Size = Vector3.new(0.45+pw*0.15, 0.45+pw*0.15, 0.45+pw*0.15); p.Pos = p.Pos + p.Vel * dt * 6; p.Part.Position = p.Pos end
    end
    if Settings.AutoTaunt then autoTaunt() end
    if Settings.MenuTheme == "Rainbow" then updateTheme() end
    if Settings.Trail then updateAllPlayersTrails() end
end)

for _, p in pairs(Players:GetPlayers()) do addESP(p); if p ~= LocalPlayer then createCham(p) end end
Players.PlayerAdded:Connect(function(p)
    addESP(p); if p ~= LocalPlayer then createCham(p) end
    p.CharacterAdded:Connect(function(char) if Settings.Trail then task.wait(1); createPlayerTrail(char) end end)
end)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p); if Chams[p] then pcall(function() Chams[p]:Destroy() end); Chams[p] = nil end
    if p.Character and activeTrails[p.Character] then
        local data = activeTrails[p.Character]
        pcall(function() if data.trail then data.trail:Destroy() end end)
        pcall(function() if data.att0 then data.att0:Destroy() end end)
        pcall(function() if data.att1 then data.att1:Destroy() end end)
        pcall(function() if data.bbg then data.bbg:Destroy() end end)
        activeTrails[p.Character] = nil
    end
end)

loadConfig()

-- ==================[ АНИМАЦИИ МЕНЮ ]======================
local function smoothAppear(obj, tSize, tPos)
    obj.Size = UDim2.new(0,0,0,0); obj.AnchorPoint = Vector2.new(0.5,0.5); obj.Position = UDim2.new(0.5,0,0.5,0)
    TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = tSize, Position = tPos, AnchorPoint = Vector2.new(0,0)}):Play()
end
local function smoothDisappear(obj, cb)
    TweenService:Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5)}):Play()
    task.delay(0.2, function() if cb then cb() end end)
end

-- ==================[ СОЗДАНИЕ МЕНЮ ]======================
local function CreateMainMenu()
    if MenuInstance and MenuInstance.Parent then
        if MenuOpen then
            MenuOpen = false
            smoothDisappear(MenuInstance, function() MenuInstance.Visible = false end)
        else
            MenuOpen = true
            MenuInstance.Visible = true
            smoothAppear(MenuInstance, UDim2.new(0, 420 * Settings.MenuScale, 0, 330 * Settings.MenuScale), UDim2.new(0.5, -210 * Settings.MenuScale, 0.5, -165 * Settings.MenuScale))
        end
        return MenuInstance
    end

    if not pcall(function() return LocalPlayer:WaitForChild("PlayerGui") end) then return end

    ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "HesersMainMenu"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui"); ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame"); MainFrame.Size = UDim2.new(0, 420 * Settings.MenuScale, 0, 330 * Settings.MenuScale)
    MainFrame.Position = UDim2.new(0.5, -210 * Settings.MenuScale, 0.5, -165 * Settings.MenuScale); MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12); MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui; MainFrame.ZIndex = 1; MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)
    local Shadow = Instance.new("Frame"); Shadow.Size = UDim2.new(1, 12, 1, 12); Shadow.Position = UDim2.new(0, -6, 0, -6)
    Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0); Shadow.BackgroundTransparency = 0.6; Shadow.BorderSizePixel = 0; Shadow.ZIndex = 0; Shadow.Parent = MainFrame
    Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 20)
    smoothAppear(MainFrame, UDim2.new(0, 420 * Settings.MenuScale, 0, 330 * Settings.MenuScale), UDim2.new(0.5, -210 * Settings.MenuScale, 0.5, -165 * Settings.MenuScale))
    MenuOpen = true

    local Header = Instance.new("Frame"); Header.Size = UDim2.new(1, 0, 0, 34); Header.BackgroundTransparency = 1; Header.Parent = MainFrame; Header.ZIndex = 10
    local LogoIcon = Instance.new("ImageLabel"); LogoIcon.Size = UDim2.new(0, 28, 0, 28); LogoIcon.Position = UDim2.new(0, 8, 0.5, -14); LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = "rbxassetid://127846278140386"; LogoIcon.ImageColor3 = UI_ACCENT; LogoIcon.Parent = Header
    local BrandName = Instance.new("TextLabel"); BrandName.Size = UDim2.new(0, 140, 1, 0); BrandName.Position = UDim2.new(0, 40, 0, 0); BrandName.BackgroundTransparency = 1
    BrandName.Text = "HESERS.CC"; BrandName.TextColor3 = Color3.fromRGB(255, 255, 255); BrandName.Font = Enum.Font.GothamBold; BrandName.TextSize = 15; BrandName.TextXAlignment = Enum.TextXAlignment.Left; BrandName.Parent = Header
    local VersionLabel = Instance.new("TextLabel"); VersionLabel.Size = UDim2.new(0, 100, 1, 0); VersionLabel.Position = UDim2.new(1, -105, 0, 0); VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "Release 6.5"; VersionLabel.TextColor3 = Color3.fromRGB(80, 80, 90); VersionLabel.Font = Enum.Font.Gotham; VersionLabel.TextSize = 10; VersionLabel.TextXAlignment = Enum.TextXAlignment.Right; VersionLabel.Parent = Header
    local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 20, 0, 20); CloseBtn.Position = UDim2.new(1, -25, 0.5, -10)
    CloseBtn.BackgroundColor3 = UI_ACCENT; CloseBtn.BackgroundTransparency = 0.3; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 12; CloseBtn.Parent = Header; CloseBtn.AutoButtonColor = false; CloseBtn.ZIndex = 20
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
    CloseBtn.MouseButton1Click:Connect(function()
        MenuOpen = false
        smoothDisappear(MainFrame, function() MainFrame.Visible = false end)
    end)

    local dragging = false; local dragStart = Vector2.zero; local frameStart = Vector2.zero
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; frameStart = MainFrame.AbsolutePosition end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(0, math.clamp(frameStart.X + delta.X, 0, Camera.ViewportSize.X - MainFrame.AbsoluteSize.X), 0, math.clamp(frameStart.Y + delta.Y, 0, Camera.ViewportSize.Y - MainFrame.AbsoluteSize.Y))
        end
    end)

    local LeftPanel = Instance.new("Frame"); LeftPanel.Size = UDim2.new(0, 55, 0, 290); LeftPanel.Position = UDim2.new(0, 0, 0, 34)
    LeftPanel.BackgroundColor3 = Color3.fromRGB(0,0,0); LeftPanel.BackgroundTransparency = Settings.MenuTransparency; LeftPanel.BorderSizePixel = 0; LeftPanel.Parent = MainFrame
    Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 14)
    
    local IndicatorContainer = Instance.new("Frame"); IndicatorContainer.Size = UDim2.new(0, 3, 0, 0); IndicatorContainer.Position = UDim2.new(0, 2, 0, 8)
    IndicatorContainer.BackgroundTransparency = 1; IndicatorContainer.ZIndex = 25; IndicatorContainer.Parent = LeftPanel
    local TabIndicator = Instance.new("Frame"); TabIndicator.Size = UDim2.new(1, 0, 0, 18); TabIndicator.BackgroundColor3 = UI_ACCENT
    TabIndicator.BorderSizePixel = 0; TabIndicator.ZIndex = 25; TabIndicator.Parent = IndicatorContainer

    local NavTabs = {
        { Name = "Rage", Icon = "rbxassetid://137093279913702" },
        { Name = "Aimbot", Icon = "rbxassetid://86284765308894" },
        { Name = "Visuals", Icon = "rbxassetid://100110878163492" },
        { Name = "Config", Icon = "rbxassetid://118836366309277" },
        { Name = "Settings", Icon = "rbxassetid://125650590805588" },
    }

    local TabButtons = {}; local TabContents = {}; local currentTab = nil

    local function SwitchMainTab(selectedName)
        if currentTab == selectedName then return end; currentTab = selectedName
        for _, content in pairs(TabContents) do if content then content.Visible = false end end
        for _, btn in pairs(TabButtons) do btn.BackgroundTransparency = 1; btn.ImageColor3 = Color3.fromRGB(140, 140, 150) end
        if TabButtons[selectedName] then
            local btn = TabButtons[selectedName]; IndicatorContainer.Position = UDim2.new(0, 2, 0, btn.Position.Y.Offset + 6)
            btn.BackgroundTransparency = 0.8; btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
        if TabContents[selectedName] then TabContents[selectedName].Visible = true end
    end

    for i, tab in ipairs(NavTabs) do
        local btn = Instance.new("ImageButton"); btn.Size = UDim2.new(0, 40, 0, 40); btn.Position = UDim2.new(0.5, -20, 0, (i - 1) * 50 + 10)
        btn.BackgroundTransparency = 1; btn.Image = tab.Icon; btn.ImageColor3 = Color3.fromRGB(140, 140, 150)
        btn.Parent = LeftPanel; btn.AutoButtonColor = false; btn.ZIndex = 15
        TabButtons[tab.Name] = btn
        btn.MouseButton1Click:Connect(function() SwitchMainTab(tab.Name) end)
    end

    local RightPanelBg = Instance.new("Frame"); RightPanelBg.Size = UDim2.new(1, -60, 1, -10); RightPanelBg.Position = UDim2.new(0, 55, 0, 5)
    RightPanelBg.BackgroundColor3 = Color3.fromRGB(0,0,0); RightPanelBg.BackgroundTransparency = Settings.MenuTransparency; RightPanelBg.BorderSizePixel = 0; RightPanelBg.Parent = MainFrame
    Instance.new("UICorner", RightPanelBg).CornerRadius = UDim.new(0, 14)
    local RightPanel = Instance.new("Frame"); RightPanel.Size = UDim2.new(1, -10, 1, -10); RightPanel.Position = UDim2.new(0, 5, 0, 5)
    RightPanel.BackgroundTransparency = 1; RightPanel.Parent = RightPanelBg

    local function CreateCheckbox(parent, yPos, text, default, callback)
        local container = Instance.new("Frame"); container.Size = UDim2.new(1, 0, 0, 26); container.Position = UDim2.new(0, 0, 0, yPos); container.BackgroundTransparency = 1; container.Parent = parent
        local hitbox = Instance.new("TextButton"); hitbox.Size = UDim2.new(1, 0, 1, 0); hitbox.BackgroundTransparency = 1; hitbox.Text = ""; hitbox.Parent = container; hitbox.ZIndex = 10
        local box = Instance.new("Frame"); box.Size = UDim2.new(0, 16, 0, 16); box.Position = UDim2.new(0, 0, 0, 5)
        box.BackgroundColor3 = default and UI_ACCENT or UI_BG; box.BorderSizePixel = 0; box.Parent = container; box.ZIndex = 5
        Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)
        local checkMark = Instance.new("TextLabel"); checkMark.Size = UDim2.new(1, 0, 1, 0); checkMark.BackgroundTransparency = 1
        checkMark.Text = default and "✓" or ""; checkMark.TextColor3 = Color3.fromRGB(255, 255, 255); checkMark.Font = Enum.Font.GothamBold; checkMark.TextSize = 10; checkMark.Parent = box
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -22, 1, 0); label.Position = UDim2.new(0, 22, 0, 0)
        label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.fromRGB(220, 220, 230); label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.Gotham; label.TextSize = 11; label.Parent = container
        local state = default
        hitbox.MouseButton1Click:Connect(function() state = not state; box.BackgroundColor3 = state and UI_ACCENT or UI_BG; checkMark.Text = state and "✓" or ""; if callback then callback(state) end end)
        return state
    end

    local function CreateSlider(parent, yPos, text, minV, maxV, defaultV, callback)
        local container = Instance.new("Frame"); container.Size = UDim2.new(1, 0, 0, 30); container.Position = UDim2.new(0, 0, 0, yPos); container.BackgroundTransparency = 1; container.Parent = parent
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(0, 140, 0, 16); label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.fromRGB(220, 220, 230); label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.Gotham; label.TextSize = 11; label.Parent = container
        local valText = Instance.new("TextLabel"); valText.Size = UDim2.new(0, 50, 0, 16); valText.Position = UDim2.new(1, -55, 0, 0)
        valText.BackgroundTransparency = 1; valText.Text = tostring(defaultV); valText.TextColor3 = Color3.fromRGB(180, 180, 200); valText.TextXAlignment = Enum.TextXAlignment.Right; valText.Font = Enum.Font.Gotham; valText.TextSize = 11; valText.Parent = container
        local barBg = Instance.new("Frame"); barBg.Size = UDim2.new(1, -60, 0, 6); barBg.Position = UDim2.new(0, 0, 0, 20)
        barBg.BackgroundColor3 = UI_BG; barBg.Parent = container; Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame"); fill.Size = UDim2.new((defaultV - minV) / (maxV - minV), 0, 1, 0)
        fill.BackgroundColor3 = UI_ACCENT; fill.Parent = barBg; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("TextButton"); knob.Size = UDim2.new(0, 12, 0, 12); knob.Position = UDim2.new((defaultV - minV) / (maxV - minV), -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.Text = ""; knob.Parent = barBg; knob.AutoButtonColor = false; knob.ZIndex = 10; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local currentValue = defaultV
        
        barBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local mouseX = UserInputService:GetMouseLocation().X
                local percent = math.clamp((mouseX - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                currentValue = math.round(minV + (maxV - minV) * percent)
                fill.Size = UDim2.new(percent, 0, 1, 0); knob.Position = UDim2.new(percent, -6, 0.5, -6); valText.Text = tostring(currentValue)
                if callback then callback(currentValue) end
                local moveConn; moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        local mx = moveInput.Position.X
                        local p = math.clamp((mx - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                        currentValue = math.round(minV + (maxV - minV) * p)
                        fill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -6, 0.5, -6); valText.Text = tostring(currentValue)
                        if callback then callback(currentValue) end
                    end
                end)
                local endConn; endConn = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then moveConn:Disconnect(); endConn:Disconnect() end
                end)
            end
        end)
        return currentValue
    end

    local function CreateDropdown(parent, yPos, text, options, defaultIndex, callback)
        local container = Instance.new("Frame"); container.Size = UDim2.new(1, 0, 0, 26); container.Position = UDim2.new(0, 0, 0, yPos); container.BackgroundTransparency = 1; container.Parent = parent
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -90, 1, 0); label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.fromRGB(220, 220, 230); label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.Gotham; label.TextSize = 11; label.Parent = container
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 80, 0, 20); btn.Position = UDim2.new(1, -85, 0, 3)
        btn.BackgroundColor3 = UI_BG; btn.Text = options[defaultIndex] .. " ▼"; btn.TextColor3 = Color3.fromRGB(200, 200, 210); btn.Font = Enum.Font.Gotham; btn.TextSize = 10
        btn.Parent = container; btn.AutoButtonColor = false; btn.ZIndex = 5; Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local currentIndex = defaultIndex; local isOpen = false; local menu = nil; local shifted = {}
        local function closeMenu()
            if menu and menu.Parent then
                TweenService:Create(menu, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 80, 0, 0)}):Play()
                for _, d in ipairs(shifted) do TweenService:Create(d.C, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = d.OP}):Play() end
                shifted = {}; task.wait(0.1); menu:Destroy(); menu = nil; isOpen = false
            end
        end
        btn.MouseButton1Click:Connect(function()
            if isOpen then closeMenu(); return end; isOpen = true
            local curY = container.Position.Y.Offset; shifted = {}; local shiftAm = #options * 20
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("Frame") and child ~= container and child.Name ~= "ScrollingFrame" then
                    local cY = child.Position.Y.Offset
                    if cY > curY then table.insert(shifted, {C = child, OP = child.Position}); TweenService:Create(child, TweenInfo.new(0.2), {Position = UDim2.new(child.Position.X.Scale, child.Position.X.Offset, child.Position.Y.Scale, cY + shiftAm)}):Play() end
                end
            end
            local sf = parent:FindFirstChildOfClass("ScrollingFrame"); if sf then sf.CanvasSize = UDim2.new(0, 0, 0, sf.CanvasSize.Y.Offset + shiftAm) end
            menu = Instance.new("Frame"); menu.Size = UDim2.new(0, 80, 0, 0); menu.Position = UDim2.new(0, 0, 1, 2)
            menu.BackgroundColor3 = Color3.fromRGB(18, 18, 20); menu.Parent = btn; menu.ZIndex = 100; menu.ClipsDescendants = true
            Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)
            TweenService:Create(menu, TweenInfo.new(0.15), {Size = UDim2.new(0, 80, 0, shiftAm)}):Play()
            for i, opt in ipairs(options) do
                local ob = Instance.new("TextButton"); ob.Size = UDim2.new(1, 0, 0, 20); ob.Position = UDim2.new(0, 0, 0, (i-1)*20)
                ob.BackgroundTransparency = 1; ob.Text = opt; ob.TextColor3 = (i == currentIndex) and UI_ACCENT or Color3.fromRGB(200, 200, 210)
                ob.Font = Enum.Font.Gotham; ob.TextSize = 10; ob.Parent = menu; ob.AutoButtonColor = false
                ob.MouseButton1Click:Connect(function() currentIndex = i; btn.Text = opt .. " ▼"; if callback then callback(opt) end; closeMenu() end)
            end
            task.spawn(function() task.wait(0.2); local cc; cc = UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then if isOpen then closeMenu() end; if cc then cc:Disconnect() end end end) end)
        end)
        return options[currentIndex]
    end

    local function CreateMainTabContent(parent)
        local c = Instance.new("Frame"); c.Size = UDim2.new(1, 0, 1, 0); c.BackgroundTransparency = 1; c.Parent = parent; c.Visible = false; return c
    end

    local function SetupSubTabs(container, tabs)
        local sc = Instance.new("Frame"); sc.Size = UDim2.new(1, 0, 0, 30); sc.Position = UDim2.new(0, 0, 0, 20); sc.BackgroundTransparency = 1; sc.Parent = container
        local sB = {}; local sC = {}
        local li = Instance.new("Frame"); li.Size = UDim2.new(0, 60, 0, 2); li.BackgroundColor3 = UI_ACCENT; li.BorderSizePixel = 0; li.ZIndex = 25; li.Parent = sc; li.Visible = false; li.Position = UDim2.new(0, 0, 0, -4)
        local cur = tabs[1]
        local function sw(name)
            if cur == name then return end; cur = name
            for _, b in pairs(sB) do b.TextColor3 = Color3.fromRGB(140, 140, 150) end
            for _, c in pairs(sC) do c.Visible = false end
            if sB[name] then
                local b = sB[name]; b.TextColor3 = Color3.fromRGB(255, 255, 255); li.Visible = true
                local targetX = b.AbsolutePosition.X - sc.AbsolutePosition.X
                li.Position = UDim2.new(0, targetX, 0, -4); li.Size = UDim2.new(0, b.AbsoluteSize.X, 0, 2)
            end
            if sC[name] then sC[name].Visible = true end
        end
        for i, name in ipairs(tabs) do
            local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 60, 1, 0); b.Position = UDim2.new(0, (i-1)*65, 0, 0)
            b.BackgroundTransparency = 1; b.Text = name; b.TextColor3 = (i==1) and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,150)
            b.Font = Enum.Font.Gotham; b.TextSize = 11; b.Parent = sc; b.AutoButtonColor = false; sB[name] = b
            local ct = Instance.new("Frame"); ct.Size = UDim2.new(1,0,1,-55); ct.Position = UDim2.new(0,0,0,55); ct.BackgroundTransparency = 1; ct.Visible = (i==1); ct.Parent = container; sC[name] = ct
            b.MouseButton1Click:Connect(function() sw(name) end)
        end; return sC
    end

    -- ==================[ ЗАПОЛНЕНИЕ ВКЛАДОК ]======================
    -- RAGE
    local RageContainer = CreateMainTabContent(RightPanel); TabContents["Rage"] = RageContainer
    local RageSubs = SetupSubTabs(RageContainer, {"Combat", "Movement", "Fun"})
    
    local rageScroll1 = Instance.new("ScrollingFrame", RageSubs["Combat"]); rageScroll1.Size = UDim2.new(1,0,1,0); rageScroll1.BackgroundTransparency = 1; rageScroll1.ScrollBarThickness = 3
    rageScroll1.ScrollBarImageColor3 = UI_ACCENT; rageScroll1.CanvasSize = UDim2.new(0,0,0,650)
    CreateCheckbox(rageScroll1, 10, "God Mode", Settings.GodMode, function(v) if v ~= Settings.GodMode then toggleGodMode() end end)
    CreateCheckbox(rageScroll1, 40, "Noclip", Settings.Noclip, function(v) if v ~= Settings.Noclip then toggleNoclip() end end)
    CreateCheckbox(rageScroll1, 70, "Fly", Settings.Fly, function(v) if v ~= Settings.Fly then toggleFly() end end)
    CreateSlider(rageScroll1, 100, "Fly Speed", 10, 200, Settings.FlySpeed, function(v) Settings.FlySpeed = v end)
    CreateCheckbox(rageScroll1, 130, "Anti-Knife", Settings.AntiKnife, function(v) if v ~= Settings.AntiKnife then toggleAntiKnife() end end)
    CreateSlider(rageScroll1, 160, "Knife Distance", 10, 50, Settings.AntiKnifeDistance, function(v) Settings.AntiKnifeDistance = v end)
    CreateCheckbox(rageScroll1, 190, "Anti-Fling", Settings.AntiFling, function(v) if v ~= Settings.AntiFling then toggleAntiFling() end end)
    CreateCheckbox(rageScroll1, 220, "Spinbot", Settings.Spinbot, function(v) if v ~= Settings.Spinbot then toggleSpinbot() end end)
    CreateSlider(rageScroll1, 250, "Spin Speed", 1, 100, Settings.SpinSpeed, function(v) Settings.SpinSpeed = v end)
    CreateCheckbox(rageScroll1, 280, "Invisibility", Settings.Invisibility, function(v) if v ~= Settings.Invisibility then toggleInvisibility() end end)
    CreateCheckbox(rageScroll1, 310, "Anti-Lag", Settings.AntiLag, function(v) if v ~= Settings.AntiLag then toggleAntiLag() end end)
    CreateCheckbox(rageScroll1, 340, "Zombie Walk", Settings.ZombieWalk, function(v) if v ~= Settings.ZombieWalk then toggleZombieWalk() end end)
    CreateCheckbox(rageScroll1, 370, "Anti-Void", Settings.AntiVoid, function(v) if v ~= Settings.AntiVoid then toggleAntiVoid() end end)
    CreateCheckbox(rageScroll1, 400, "Auto Knife (KILL ALL)", Settings.AutoKnife, function(v) if v ~= Settings.AutoKnife then toggleAutoKnife() end end)
    CreateCheckbox(rageScroll1, 430, "Click TP", Settings.ClickTP, function(v) if v ~= Settings.ClickTP then toggleClickTP() end end)

    local rageScroll2 = Instance.new("ScrollingFrame", RageSubs["Movement"]); rageScroll2.Size = UDim2.new(1,0,1,0); rageScroll2.BackgroundTransparency = 1; rageScroll2.ScrollBarThickness = 3
    rageScroll2.ScrollBarImageColor3 = UI_ACCENT; rageScroll2.CanvasSize = UDim2.new(0,0,0,300)
    CreateCheckbox(rageScroll2, 10, "Jump Power", Settings.JumpPower, function(v) if v ~= Settings.JumpPower then toggleJumpPower() end end)
    CreateSlider(rageScroll2, 40, "Jump Multiplier", 30, 200, Settings.JumpMultiplier, function(v) Settings.JumpMultiplier = v end)
    CreateCheckbox(rageScroll2, 70, "Bunny Hop", Settings.BunnyHop, function(v) if v ~= Settings.BunnyHop then toggleBunnyHop() end end)
    CreateSlider(rageScroll2, 100, "BHOP Multiplier", 1.1, 5, Settings.BHOPMultiplier, function(v) Settings.BHOPMultiplier = v end)
    CreateSlider(rageScroll2, 130, "BHOP Max Speed", 20, 500, Settings.BHOPMaxSpeed, function(v) Settings.BHOPMaxSpeed = v end)
    CreateCheckbox(rageScroll2, 160, "Wall Hop", Settings.WallHop, function(v) if v ~= Settings.WallHop then toggleWallHop() end end)
    CreateCheckbox(rageScroll2, 190, "Auto Rejoin", Settings.AutoRejoin, function(v) if v ~= Settings.AutoRejoin then toggleAutoRejoin() end end)
    CreateSlider(rageScroll2, 220, "Rejoin Delay", 1, 10, Settings.RejoinDelay, function(v) Settings.RejoinDelay = v end)
    CreateCheckbox(rageScroll2, 250, "Shift Lock", Settings.ShiftLock, function(v) if v ~= Settings.ShiftLock then toggleShiftLock() end end)

    local rageScroll3 = Instance.new("ScrollingFrame", RageSubs["Fun"]); rageScroll3.Size = UDim2.new(1,0,1,0); rageScroll3.BackgroundTransparency = 1; rageScroll3.ScrollBarThickness = 3
    rageScroll3.ScrollBarImageColor3 = UI_ACCENT; rageScroll3.CanvasSize = UDim2.new(0,0,0,200)
    CreateCheckbox(rageScroll3, 10, "Auto Gun TP", Settings.GunGrabber, function(v) if v ~= Settings.GunGrabber then toggleGunGrabber() end end)
    CreateCheckbox(rageScroll3, 40, "Auto Taunt", Settings.AutoTaunt, function(v) Settings.AutoTaunt = v end)
    CreateCheckbox(rageScroll3, 70, "Kill Sound", Settings.KillSound, function(v) Settings.KillSound = v; if v then setupKillSound() else if KillSoundConnection then KillSoundConnection:Disconnect(); KillSoundConnection = nil end end end)
    CreateCheckbox(rageScroll3, 100, "Death Effect", Settings.DeathEffect, function(v) Settings.DeathEffect = v end)
    CreateDropdown(rageScroll3, 130, "Death Color", {"Purple","White","Red","Blue","Cyan","Green"}, 1, function(v) Settings.DeathEffectColor = v end)

    -- AIMBOT
    local AimbotContainer = CreateMainTabContent(RightPanel); TabContents["Aimbot"] = AimbotContainer
    local AimbotSubs = SetupSubTabs(AimbotContainer, {"Aimbot", "Silent", "Farm"})

    CreateCheckbox(AimbotSubs["Aimbot"], 10, "Enable Aimbot", Settings.Aimbot, function(v) if v ~= Settings.Aimbot then toggleAimbot() end end)
    CreateSlider(AimbotSubs["Aimbot"], 40, "FOV Radius", 50, 300, Settings.AimbotFOV, function(v) Settings.AimbotFOV = v; if fovCircle then fovCircle.Size = UDim2.new(0, v*2, 0, v*2) end end)
    CreateSlider(AimbotSubs["Aimbot"], 70, "Aim Range", 50, 1000, Settings.AimbotRange, function(v) Settings.AimbotRange = v end)
    CreateDropdown(AimbotSubs["Aimbot"], 100, "Aim Mode", {"Always", "WeaponOnly"}, 1, function(v) Settings.AimbotMode = v end)
    CreateCheckbox(AimbotSubs["Aimbot"], 130, "Auto Shoot", Settings.AutoShoot, function(v) Settings.AutoShoot = v end)
    CreateSlider(AimbotSubs["Aimbot"], 160, "Shoot Delay", 0.05, 1, Settings.AutoShootDelay, function(v) Settings.AutoShootDelay = v end)
    CreateCheckbox(AimbotSubs["Aimbot"], 190, "Trigger Bot", Settings.TriggerBot, function(v) Settings.TriggerBot = v end)

    CreateCheckbox(AimbotSubs["Silent"], 10, "Silent Aim", Settings.SilentAim, function(v) if v ~= Settings.SilentAim then toggleSilentAim() end end)
    CreateCheckbox(AimbotSubs["Silent"], 40, "Wall Shoot", Settings.WallShoot, function(v) if v ~= Settings.WallShoot then toggleWallShoot() end end)

    CreateCheckbox(AimbotSubs["Farm"], 10, "Auto Farm", Settings.AutoFarm, function(v) if v ~= Settings.AutoFarm then toggleAutoFarm() end end)
    CreateSlider(AimbotSubs["Farm"], 40, "Farm Radius", 5, 100, Settings.FarmRadius, function(v) Settings.FarmRadius = v end)
    CreateSlider(AimbotSubs["Farm"], 70, "Farm Delay", 0.1, 2, Settings.FarmDelay, function(v) Settings.FarmDelay = v end)

    -- VISUALS
    local VisualsContainer = CreateMainTabContent(RightPanel); TabContents["Visuals"] = VisualsContainer
    local VisualsSubs = SetupSubTabs(VisualsContainer, {"ESP", "Chams", "World"})

    CreateCheckbox(VisualsSubs["ESP"], 10, "Enable ESP", Settings.ESP, function(v) Settings.ESP = v end)
    CreateCheckbox(VisualsSubs["ESP"], 40, "Box ESP", Settings.ESPBox, function(v) Settings.ESPBox = v end)
    CreateDropdown(VisualsSubs["ESP"], 70, "Box Color", {"White","Red","Blue","Purple","Cyan","Green","Yellow","Pink"}, 1, function(v) Settings.ESPBoxColor = v end)
    CreateCheckbox(VisualsSubs["ESP"], 100, "Tracers", Settings.ESPTracer, function(v) Settings.ESPTracer = v end)
    CreateCheckbox(VisualsSubs["ESP"], 130, "Names", Settings.ESPName, function(v) Settings.ESPName = v end)
    CreateCheckbox(VisualsSubs["ESP"], 160, "Distance", Settings.ESPDistance, function(v) Settings.ESPDistance = v end)

    CreateCheckbox(VisualsSubs["Chams"], 10, "Role Chams", Settings.RoleChams, function(v) Settings.RoleChams = v end)
    CreateCheckbox(VisualsSubs["Chams"], 40, "Skeleton ESP", Settings.SkeletonESP, function(v) Settings.SkeletonESP = v; createSkeletonESP() end)
    CreateCheckbox(VisualsSubs["Chams"], 70, "Glow Body", Settings.GlowBody, function(v) Settings.GlowBody = v; applyGlowBody() end)
    CreateDropdown(VisualsSubs["Chams"], 100, "Glow Color", {"White","Red","Blue","Purple","Cyan","Green"}, 1, function(v) Settings.GlowColor = v; if Settings.GlowBody then applyGlowBody() end end)

    local visScroll = Instance.new("ScrollingFrame", VisualsSubs["World"]); visScroll.Size = UDim2.new(1,0,1,0); visScroll.BackgroundTransparency = 1; visScroll.ScrollBarThickness = 3
    visScroll.ScrollBarImageColor3 = UI_ACCENT; visScroll.CanvasSize = UDim2.new(0,0,0,600)
    
    CreateCheckbox(visScroll, 10, "Spectator List", Settings.SpectatorList, function(v) Settings.SpectatorList = v; updateSpectatorList() end)
    CreateCheckbox(visScroll, 40, "Trail", Settings.Trail, function(v) toggleTrail() end)
    CreateDropdown(visScroll, 70, "Trail Color", {"White","Blue","Red","Purple"}, 1, function(v) Settings.TrailColor = v; if Settings.Trail then removeAllTrails(); updateAllPlayersTrails() end end)
    CreateDropdown(visScroll, 100, "Trail Size", {"Thin","Big"}, 2, function(v) Settings.TrailSize = v; if Settings.Trail then removeAllTrails(); updateAllPlayersTrails() end end)
    CreateCheckbox(visScroll, 130, "Orbit Orbs", Settings.OrbitOrbs, function(v) Settings.OrbitOrbs = v; applyOrbitOrbs() end)
    CreateDropdown(visScroll, 160, "Orb Color", {"White","Red","Blue","Purple","Cyan","Green"}, 1, function(v) Settings.OrbColor = v; if Settings.OrbitOrbs then applyOrbitOrbs() end end)
    CreateCheckbox(visScroll, 190, "Particles", Settings.FloatingParticles, function(v) Settings.FloatingParticles = v end)
    CreateDropdown(visScroll, 220, "Particle Color", {"White","Red","Blue","Purple","Cyan","Green"}, 1, function(v) Settings.ParticleColor = v end)
    CreateCheckbox(visScroll, 250, "Fog", Settings.Fog, function(v) Settings.Fog = v; updateFog() end)
    CreateSlider(visScroll, 280, "Fog Distance", 10, 500, Settings.FogDistance, function(v) Settings.FogDistance = v; if Settings.Fog then updateFog() end end)
    CreateDropdown(visScroll, 310, "Fog Color", {"White","Red","Blue","Cyan"}, 1, function(v) Settings.FogColor = v; if Settings.Fog then updateFog() end end)
    CreateCheckbox(visScroll, 340, "Show FPS", Settings.ShowFPS, function(v) Settings.ShowFPS = v; if v then createFPSDisplay() else if FPSGui then pcall(function() FPSGui.Gui:Destroy() end); FPSGui = nil end; if FPSConnection then FPSConnection:Disconnect(); FPSConnection = nil end end end)
    CreateCheckbox(visScroll, 370, "Custom Skybox", Settings.CustomSkybox, function(v) Settings.CustomSkybox = v; if v then applySkybox(Settings.SkyboxType) else if Lighting:FindFirstChild("CustomSky") then Lighting.CustomSky:Destroy() end end end)
    CreateDropdown(visScroll, 400, "Skybox Type", {"White","Red","Purple","Blue","Constellation"}, 1, function(v) Settings.SkyboxType = v; if Settings.CustomSkybox then applySkybox(v) end end)
    CreateCheckbox(visScroll, 430, "Custom FOV", Settings.FOV, function(v) Settings.FOV = v; applyFOV() end)
    CreateSlider(visScroll, 460, "FOV Value", 30, 120, Settings.FOVValue, function(v) Settings.FOVValue = v; if Settings.FOV then applyFOV() end end)
    CreateCheckbox(visScroll, 490, "Custom Crosshair", Settings.CustomCrosshair, function(v) Settings.CustomCrosshair = v; updateCustomCrosshair() end)
    CreateSlider(visScroll, 520, "Crosshair Size", 10, 50, Settings.CrosshairSize, function(v) Settings.CrosshairSize = v; if Settings.CustomCrosshair then updateCustomCrosshair() end end)
    CreateDropdown(visScroll, 550, "Crosshair Color", {"Red","White","Blue","Purple","Cyan","Green"}, 1, function(v) Settings.CrosshairColor = v; if Settings.CustomCrosshair then updateCustomCrosshair() end end)
    
    CreateCheckbox(visScroll, 580, "Full Bright", Settings.FullBright, function(v) Settings.FullBright = v; applyFullBright() end)
    CreateCheckbox(visScroll, 610, "Wireframe Mode", Settings.WireframeMode, function(v) Settings.WireframeMode = v; applyWireframeMode() end)

    -- CONFIG
    local ConfigContainer = CreateMainTabContent(RightPanel); TabContents["Config"] = ConfigContainer
    local ConfigSubs = SetupSubTabs(ConfigContainer, {"Config", "Settings"})

    local function FillConfig(tab, name)
        local btn = Instance.new("TextButton", tab); btn.Size = UDim2.new(0, 200, 0, 40); btn.Position = UDim2.new(0.5, -100, 0, 20)
        btn.BackgroundColor3 = UI_ACCENT; btn.BackgroundTransparency = 0.3; btn.Text = name; btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBlack; btn.TextSize = 14; btn.AutoButtonColor = false; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    end
    FillConfig(ConfigSubs["Config"], "Save/Load Config")
    FillConfig(ConfigSubs["Settings"], "Reset Settings")

    -- SETTINGS
    local SettingsContainer = CreateMainTabContent(RightPanel); TabContents["Settings"] = SettingsContainer
    local settingsTab = Instance.new("ScrollingFrame", SettingsContainer); settingsTab.Size = UDim2.new(1,0,1,0); settingsTab.BackgroundTransparency = 1; settingsTab.ScrollBarThickness = 3
    settingsTab.ScrollBarImageColor3 = UI_ACCENT; settingsTab.CanvasSize = UDim2.new(0,0,0,650)

    CreateDropdown(settingsTab, 10, "Menu Theme", {"Red","Blue","Purple","Green","Rainbow"}, 1, function(v) Settings.MenuTheme = v; updateTheme() end)
    CreateDropdown(settingsTab, 40, "Panic Key", {"Delete","End","Home","F8","F9","F10"}, 1, function(v) Settings.PanicKey = v end)
    CreateCheckbox(settingsTab, 70, "Auto Save Config", Settings.AutoSave, function(v) Settings.AutoSave = v end)
    CreateCheckbox(settingsTab, 100, "Auto Load Config", Settings.AutoLoad, function(v) Settings.AutoLoad = v end)
    CreateCheckbox(settingsTab, 130, "Show Ping", Settings.ShowPing, function(v) Settings.ShowPing = v; toggleInfoDisplay() end)
    CreateCheckbox(settingsTab, 160, "Show Play Time", Settings.ShowPlayTime, function(v) Settings.ShowPlayTime = v; toggleInfoDisplay() end)

    local bindLabel = Instance.new("TextLabel", settingsTab)
    bindLabel.Size = UDim2.new(1, 0, 0, 20); bindLabel.Position = UDim2.new(0, 0, 0, 200)
    bindLabel.Text = "--- Keybinds ---"; bindLabel.TextColor3 = UI_ACCENT; bindLabel.BackgroundTransparency = 1
    bindLabel.Font = Enum.Font.GothamBlack; bindLabel.TextSize = 11; bindLabel.TextXAlignment = Enum.TextXAlignment.Left

    CreateDropdown(settingsTab, 230, "Noclip Key", {"N","G","H","J","K"}, 1, function(v) Keybinds.Noclip = v end)
    CreateDropdown(settingsTab, 260, "GodMode Key", {"B","G","H","J","K"}, 1, function(v) Keybinds.GodMode = v end)
    CreateDropdown(settingsTab, 290, "Fly Key", {"F","G","H","J","K"}, 1, function(v) Keybinds.Fly = v end)
    CreateDropdown(settingsTab, 320, "Invis Key", {"I","G","H","J","K"}, 1, function(v) Keybinds.Invisibility = v end)
    CreateDropdown(settingsTab, 350, "Aimbot Key", {"V","G","H","J","K"}, 1, function(v) Keybinds.Aimbot = v end)
    CreateDropdown(settingsTab, 380, "ESP Key", {"M","G","H","J","K"}, 1, function(v) Keybinds.ESP = v end)
    CreateDropdown(settingsTab, 410, "Auto Knife Key", {"K","G","H","J","N"}, 1, function(v) Keybinds.AutoKnife = v end)

    local resetBtn = Instance.new("TextButton", settingsTab)
    resetBtn.Size = UDim2.new(0, 200, 0, 40); resetBtn.Position = UDim2.new(0.5, -100, 0, 450)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); resetBtn.BackgroundTransparency = 0.3
    resetBtn.Text = "Reset All Settings"; resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
    resetBtn.Font = Enum.Font.GothamBlack; resetBtn.TextSize = 14; resetBtn.AutoButtonColor = false
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 10)
    resetBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(Settings) do
            if type(v) == "boolean" then Settings[k] = false
            elseif type(v) == "number" then Settings[k] = 50
            elseif type(v) == "string" then Settings[k] = "White"
            end
        end
        Settings.AutoSave = true; Settings.AutoLoad = true
        saveConfig()
    end)

    SwitchMainTab("Rage")
    MenuInstance = MainFrame
    return MainFrame
end

-- ==================[ ВОДЯНОЙ ЗНАК ]======================
local function CreateWatermark()
    if WatermarkInstance then return WatermarkInstance end
    if not pcall(function() return LocalPlayer:WaitForChild("PlayerGui") end) then return end
    
    local sg = Instance.new("ScreenGui"); sg.Name = "HesersWatermark"; sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    local MainBox = Instance.new("Frame"); MainBox.Size = UDim2.new(0, 160, 0, 32); MainBox.Position = UDim2.new(0.5, -80, 0, 8)
    MainBox.BackgroundColor3 = Color3.fromRGB(0,0,0); MainBox.BackgroundTransparency = 0.8; MainBox.BorderSizePixel = 0; MainBox.Parent = sg
    Instance.new("UICorner", MainBox).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", MainBox).Color = UI_ACCENT
    local CrossIcon = Instance.new("TextLabel"); CrossIcon.Size = UDim2.new(0, 16, 1, 0); CrossIcon.Position = UDim2.new(0, 8, 0, 0); CrossIcon.BackgroundTransparency = 1
    CrossIcon.Text = "+"; CrossIcon.TextColor3 = UI_ACCENT; CrossIcon.Font = Enum.Font.GothamBold; CrossIcon.TextSize = 12; CrossIcon.Parent = MainBox
    local StarIcon = Instance.new("TextLabel"); StarIcon.Size = UDim2.new(0, 16, 1, 0); StarIcon.Position = UDim2.new(0, 38, 0, 0); StarIcon.BackgroundTransparency = 1
    StarIcon.Text = "✦"; StarIcon.TextColor3 = UI_ACCENT; StarIcon.Font = Enum.Font.GothamBold; StarIcon.TextSize = 14; StarIcon.Parent = MainBox
    local BrandText = Instance.new("TextLabel"); BrandText.Size = UDim2.new(1, -70, 1, 0); BrandText.Position = UDim2.new(0, 65, 0, 0); BrandText.BackgroundTransparency = 1
    BrandText.Text = "HESERS.CC"; BrandText.TextColor3 = Color3.fromRGB(255, 255, 255); BrandText.Font = Enum.Font.Gotham; BrandText.TextSize = 11; BrandText.TextXAlignment = Enum.TextXAlignment.Left; BrandText.Parent = MainBox
    local ClickButton = Instance.new("TextButton"); ClickButton.Size = UDim2.new(1, 0, 1, 0); ClickButton.BackgroundTransparency = 1; ClickButton.Text = ""; ClickButton.Parent = MainBox; ClickButton.AutoButtonColor = false
    ClickButton.MouseButton1Click:Connect(function() CreateMainMenu() end)
    WatermarkInstance = MainBox; return MainBox
end

task.wait(1)
CreateWatermark()
