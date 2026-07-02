-- ============================================================
--  HESERACFG PREMIUM v11.0 - FINAL FIXED
--  + Новый фон меню: 85934187873808
--  + Исправлен Auto Farm (плавный полёт + noclip)
--  + Kill All, Mass Fling, Void
--  + Новые Sun Chams
--  + Система ключа @heseracfg
-- ============================================================

-- ==================== СИСТЕМА КЛЮЧА ====================
local VALID_KEY = "heseracfg"
local keyEntered = false

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "KeySystem"
keyGui.IgnoreGuiInset = true
keyGui.ResetOnSpawn = false
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then repeat task.wait(0.5) until game.Players.LocalPlayer:FindFirstChild("PlayerGui"); playerGui = game.Players.LocalPlayer.PlayerGui end
keyGui.Parent = playerGui

-- Фон
local keyBg = Instance.new("Frame", keyGui)
keyBg.Size = UDim2.new(0, 350, 0, 200)
keyBg.Position = UDim2.new(0.5, -175, 0.5, -100)
keyBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
keyBg.BackgroundTransparency = 0.2
keyBg.BorderSizePixel = 0
keyBg.ZIndex = 1000
Instance.new("UICorner", keyBg).CornerRadius = UDim.new(0, 12)

-- Заголовок
local keyTitle = Instance.new("TextLabel", keyBg)
keyTitle.Size = UDim2.new(1, 0, 0, 35)
keyTitle.Position = UDim2.new(0, 0, 0, 15)
keyTitle.Text = "ENTER KEY"
keyTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
keyTitle.BackgroundTransparency = 1
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.TextSize = 22
keyTitle.ZIndex = 1001

-- Поле ввода
local keyInput = Instance.new("TextBox", keyBg)
keyInput.Size = UDim2.new(0, 250, 0, 35)
keyInput.Position = UDim2.new(0, 50, 0, 70)
keyInput.PlaceholderText = "Введите ключ..."
keyInput.Text = ""
keyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
keyInput.BorderSizePixel = 0
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.Font = Enum.Font.GothamBold
keyInput.TextSize = 14
keyInput.ZIndex = 1001
keyInput.ClearTextOnFocus = false
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

-- Кнопка
local keyBtn = Instance.new("TextButton", keyBg)
keyBtn.Size = UDim2.new(0, 250, 0, 35)
keyBtn.Position = UDim2.new(0, 50, 0, 115)
keyBtn.Text = "АКТИВИРОВАТЬ"
keyBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
keyBtn.BackgroundTransparency = 0.1
keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBtn.Font = Enum.Font.GothamBlack
keyBtn.TextSize = 14
keyBtn.ZIndex = 1001
keyBtn.AutoButtonColor = false
Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)

-- Статус
local keyStatus = Instance.new("TextLabel", keyBg)
keyStatus.Size = UDim2.new(1, 0, 0, 20)
keyStatus.Position = UDim2.new(0, 0, 0, 160)
keyStatus.Text = ""
keyStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
keyStatus.BackgroundTransparency = 1
keyStatus.Font = Enum.Font.GothamBold
keyStatus.TextSize = 12
keyStatus.ZIndex = 1001

-- Обработка
keyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == VALID_KEY then
        keyEntered = true
        keyGui:Destroy()
        -- Запускаем чит после успешного ввода ключа
        loadMainCheat()
    else
        keyStatus.Text = "❌ НЕВЕРНЫЙ КЛЮЧ! Попробуйте ещё раз."
        keyInput.Text = ""
    end
end)

keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        if keyInput.Text == VALID_KEY then
            keyEntered = true
            keyGui:Destroy()
            loadMainCheat()
        else
            keyStatus.Text = "❌ НЕВЕРНЫЙ КЛЮЧ! Попробуйте ещё раз."
            keyInput.Text = ""
        end
    end
end)

-- Основная функция чита (загружается только после ввода ключа)
function loadMainCheat()
    
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then repeat task.wait(0.5) until player:FindFirstChild("PlayerGui"); playerGui = player.PlayerGui end

-- ==================== НАСТРОЙКИ ====================
local Settings = {
    MenuColor = "Red",
    -- Rage
    GodMode = false,
    Noclip = false,
    Fly = false, FlySpeed = 50,
    AntiFling = false,
    AntiKnife = false, AntiKnifeDistance = 25,
    Spinbot = false, SpinSpeed = 20,
    BunnyHop = false, BHOPMultiplier = 1.5, BHOPMaxSpeed = 100,
    AntiLag = false,
    JumpPower = false, JumpMultiplier = 50,
    WallHop = false,
    AutoRejoin = false, RejoinDelay = 3,
    RemoveUI = false,
    -- Visual
    ESP = false, ESPBox = false, ESPTracer = false, ESPName = false, ESPDistance = false,
    SunChams = false,
    CustomSkybox = false, SkyboxType = "White",
    GlowBody = false, GlowColor = "White",
    OrbitOrbs = false, OrbColor = "White",
    FloatingParticles = false, ParticleColor = "White",
    Fog = false, FogDistance = 50, FogColor = "White",
    GraphicsMode = "Off",
    CustomCrosshair = false, CrosshairType = "Cross", CrosshairSize = 20, CrosshairColor = "Red", CrosshairSpinSpeed = 5,
    Trail = false, TrailColor = "White", TrailDuration = 1,
    -- Aimbot
    Aimbot = false, AimbotFOV = 120, AimbotRange = 500, AimbotMode = "Always",
    SilentAim = false,
    -- Other
    FPSBoost = false,
    FOV = false, FOVValue = 70,
    -- Death Effects
    DeathEffect = false, DeathEffectType = "Explosion", DeathEffectColor = "Purple",
    -- Farm
    AutoFarm = false, FarmRadius = 30, FarmDelay = 0.3,
    -- Custom
    CloudColor = "White", CloudEnabled = false,
    -- Lock
    ShiftLock = false,
    -- Gun Grabber
    GunGrabber = false,
}

local gunButtonPosition = UDim2.new(0.85, 0, 0.7, 0)

-- ==================== АВТОСТРАХОВАНИЕ ====================
local function saveAllSettings()
    local data = {Settings = Settings, gunButtonPosition = gunButtonPosition}
    local json = HttpService:JSONEncode(data)
    pcall(function() writefile("HESERACFG_AutoSave.json", json) end)
end

local function loadAllSettings()
    if not isfile("HESERACFG_AutoSave.json") then return false end
    local success, jsonData = pcall(function() return readfile("HESERACFG_AutoSave.json") end)
    if not success or not jsonData then return false end
    local success2, data = pcall(function() return HttpService:JSONDecode(jsonData) end)
    if not success2 or not data then return false end
    if data.Settings then for k, v in pairs(data.Settings) do if Settings[k] ~= nil then if type(v) == "table" then for subK, subV in pairs(v) do if Settings[k][subK] ~= nil then Settings[k][subK] = subV end end else Settings[k] = v end end end end
    if data.gunButtonPosition then gunButtonPosition = data.gunButtonPosition end
    return true
end

local function applyLoadedSettings()
    if Settings.GlowBody then task.wait(0.5); applyGlowBody() end
    if Settings.OrbitOrbs then task.wait(0.5); applyOrbitOrbs() end
    if Settings.Fog then updateFog() end
    if Settings.GraphicsMode ~= "Off" then applyGraphicsMode() end
    if Settings.CustomCrosshair then updateCustomCrosshair() end
    if Settings.CustomSkybox then applySkybox(Settings.SkyboxType) end
    if Settings.Trail then trailContainer = Instance.new("Folder", camera); trailContainer.Name = "TrailParts" end
    if Settings.GunGrabber then gunButton.Visible = true; gunButton.Position = gunButtonPosition end
    if Settings.FOV then camera.FieldOfView = Settings.FOVValue end
    if Settings.Aimbot then if fovCircle then fovCircle.Visible = true end; startAimbotLoop() end
    if Settings.SunChams then startSunChams() end
    if Settings.AutoFarm then task.wait(0.5); Settings.AutoFarm = false; toggleAutoFarm() end
end

game.Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        local wasFly = Settings.Fly
        if wasFly then Settings.Fly = false; stopFly() end
        saveAllSettings()
    end
end)

-- ==================== ГРАФИКА ====================
local graphicsData = {
    originalSettings = {},
    floor = nil, surfaceAppearance = nil, reflectionProbe = nil,
    bloom = nil, atmosphere = nil, colorCorrection = nil, blur = nil, rain = nil, vignetteGuis = {}
}

local function saveOriginalSettings()
    graphicsData.originalSettings = {
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        ShadowSoftness = Lighting.ShadowSoftness,
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
end

local function clearGraphics()
    if graphicsData.originalSettings.EnvironmentSpecularScale then
        Lighting.EnvironmentSpecularScale = graphicsData.originalSettings.EnvironmentSpecularScale
        Lighting.EnvironmentDiffuseScale = graphicsData.originalSettings.EnvironmentDiffuseScale
        Lighting.ShadowSoftness = graphicsData.originalSettings.ShadowSoftness
        Lighting.ClockTime = graphicsData.originalSettings.ClockTime
        Lighting.Brightness = graphicsData.originalSettings.Brightness
        Lighting.Ambient = graphicsData.originalSettings.Ambient
        Lighting.OutdoorAmbient = graphicsData.originalSettings.OutdoorAmbient
    end
    for _, child in ipairs(Lighting:GetChildren()) do if child:IsA("PostEffect") or child:IsA("Atmosphere") then child:Destroy() end end
    if graphicsData.bloom then graphicsData.bloom:Destroy(); graphicsData.bloom = nil end
    if graphicsData.atmosphere then graphicsData.atmosphere:Destroy(); graphicsData.atmosphere = nil end
    if graphicsData.colorCorrection then graphicsData.colorCorrection:Destroy(); graphicsData.colorCorrection = nil end
    if graphicsData.blur then graphicsData.blur:Destroy(); graphicsData.blur = nil end
    if graphicsData.rain then graphicsData.rain:Destroy(); graphicsData.rain = nil end
    if graphicsData.surfaceAppearance then graphicsData.surfaceAppearance:Destroy(); graphicsData.surfaceAppearance = nil end
    if graphicsData.reflectionProbe then graphicsData.reflectionProbe:Destroy(); graphicsData.reflectionProbe = nil end
    if graphicsData.floor and graphicsData.floor.Name == "AutoMirrorFloor" then graphicsData.floor:Destroy(); graphicsData.floor = nil end
    for _, gui in pairs(graphicsData.vignetteGuis) do gui:Destroy() end; graphicsData.vignetteGuis = {}
end

local function setupMirrorFloor()
    local floor = Workspace:FindFirstChild("Baseplate") or Workspace:FindFirstChild("Floor") or Workspace:FindFirstChild("AutoMirrorFloor")
    if not floor then floor = Instance.new("Part"); floor.Name = "AutoMirrorFloor"; floor.Size = Vector3.new(600, 1, 600); floor.Position = Vector3.new(0, -0.5, 0); floor.Anchored = true; floor.Parent = Workspace end
    graphicsData.floor = floor; floor.Material = Enum.Material.Metal; floor.Reflectance = 1.0; floor.Color = Color3.fromRGB(5, 5, 7)
    graphicsData.surfaceAppearance = floor:FindFirstChildOfClass("SurfaceAppearance") or Instance.new("SurfaceAppearance")
    graphicsData.surfaceAppearance.AlphaMode = Enum.AlphaMode.Overlay; graphicsData.surfaceAppearance.Parent = floor
    graphicsData.reflectionProbe = Workspace:FindFirstChild("AdminReflectionProbe") or Instance.new("IndoorReflectionProbe")
    graphicsData.reflectionProbe.Name = "AdminReflectionProbe"; graphicsData.reflectionProbe.Position = Vector3.new(0, 5, 0); graphicsData.reflectionProbe.Brightness = 1.5; graphicsData.reflectionProbe.TimeSlice = Enum.TimeSlice.EveryFrame; graphicsData.reflectionProbe.Parent = Workspace
end

local function enableUltraGraphics()
    saveOriginalSettings(); clearGraphics()
    Lighting.EnvironmentSpecularScale = 1; Lighting.EnvironmentDiffuseScale = 1; Lighting.ShadowSoftness = 0.01; Lighting.ClockTime = 16.5; Lighting.Brightness = 4.5
    Lighting.Ambient = Color3.fromRGB(40, 40, 50); Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 25)
    graphicsData.bloom = Instance.new("BloomEffect", Lighting); graphicsData.bloom.Intensity = 0.95; graphicsData.bloom.Size = 32; graphicsData.bloom.Threshold = 0.6
    setupMirrorFloor()
end

local function enableDarkGraphics()
    saveOriginalSettings(); clearGraphics()
    Lighting.EnvironmentSpecularScale = 1; Lighting.EnvironmentDiffuseScale = 0.5; Lighting.ShadowSoftness = 0.1; Lighting.ClockTime = 17.5; Lighting.Brightness = 1.5
    graphicsData.atmosphere = Instance.new("Atmosphere", Lighting); graphicsData.atmosphere.Density = 0.4; graphicsData.atmosphere.Offset = 0.2
    graphicsData.atmosphere.Color = Color3.fromRGB(130, 140, 160); graphicsData.atmosphere.Decay = Color3.fromRGB(90, 100, 120); graphicsData.atmosphere.Glare = 0.5; graphicsData.atmosphere.Haze = 2
    graphicsData.bloom = Instance.new("BloomEffect", Lighting); graphicsData.bloom.Intensity = 1.3; graphicsData.bloom.Size = 40; graphicsData.bloom.Threshold = 0.5
    graphicsData.colorCorrection = Instance.new("ColorCorrectionEffect", Lighting); graphicsData.colorCorrection.Brightness = -0.05; graphicsData.colorCorrection.Contrast = 0.45
    graphicsData.colorCorrection.Saturation = -0.1; graphicsData.colorCorrection.TintColor = Color3.fromRGB(220, 230, 255)
    graphicsData.blur = Instance.new("BlurEffect", Lighting); graphicsData.blur.Size = 1
    graphicsData.rain = Instance.new("Rain", Workspace); graphicsData.rain.Name = "RealStorm"; graphicsData.rain.Intensity = 0.85; graphicsData.rain.Speed = 1.2
    graphicsData.rain.Color = Color3.fromRGB(225, 235, 255); graphicsData.rain.Opacity = 0.4; graphicsData.rain.SplashIntensity = 1.0; graphicsData.rain.SplashScale = 1.2; graphicsData.rain.Straightness = 0.95
    setupMirrorFloor()
    if graphicsData.floor then graphicsData.floor.Color = Color3.fromRGB(12, 14, 18) end
    if graphicsData.reflectionProbe then graphicsData.reflectionProbe.Position = Vector3.new(0, 6, 0); graphicsData.reflectionProbe.Brightness = 1.4 end
end

local function applyGraphicsMode()
    if Settings.GraphicsMode == "Ultra" then enableUltraGraphics()
    elseif Settings.GraphicsMode == "Dark" then enableDarkGraphics()
    else clearGraphics() end
end

local skyboxImages = {
    Red = {SkyboxBk="rbxassetid://70870101892789",SkyboxDn="rbxassetid://70870101892789",SkyboxFt="rbxassetid://70870101892789",SkyboxLf="rbxassetid://70870101892789",SkyboxRt="rbxassetid://70870101892789",SkyboxUp="rbxassetid://70870101892789"},
    Purple = {SkyboxBk="rbxassetid://117968011922954",SkyboxDn="rbxassetid://117968011922954",SkyboxFt="rbxassetid://117968011922954",SkyboxLf="rbxassetid://117968011922954",SkyboxRt="rbxassetid://117968011922954",SkyboxUp="rbxassetid://117968011922954"},
    Blue = {SkyboxBk="rbxassetid://108023272659702",SkyboxDn="rbxassetid://108023272659702",SkyboxFt="rbxassetid://108023272659702",SkyboxLf="rbxassetid://108023272659702",SkyboxRt="rbxassetid://108023272659702",SkyboxUp="rbxassetid://108023272659702"},
    White = {SkyboxBk="rbxassetid://73989916383543",SkyboxDn="rbxassetid://73989916383543",SkyboxFt="rbxassetid://73989916383543",SkyboxLf="rbxassetid://73989916383543",SkyboxRt="rbxassetid://73989916383543",SkyboxUp="rbxassetid://73989916383543"}
}

local SunChams = {}
local ESPObjects = {}
local Particles = {}; local lastParticleSpawn = 0; local MAX_PARTICLES = 180
local orbitContainer, orbitConnection, highlightBody
local Trails = {}; local trailContainer

-- ==================== ЦВЕТА ====================
local function getMenuColor()
    if Settings.MenuColor == "Red" then return Color3.fromRGB(255, 0, 0)
    elseif Settings.MenuColor == "Blue" then return Color3.fromRGB(0, 150, 255)
    elseif Settings.MenuColor == "Purple" then return Color3.fromRGB(180, 0, 255)
    elseif Settings.MenuColor == "Rainbow" then return Color3.fromHSV(tick() % 1, 1, 1) end
    return Color3.fromRGB(255, 0, 0)
end

local function getColorByName(name)
    if name == "Red" then return Color3.fromRGB(255, 50, 50)
    elseif name == "Blue" then return Color3.fromRGB(50, 150, 255)
    elseif name == "Purple" then return Color3.fromRGB(180, 50, 255)
    elseif name == "White" then return Color3.fromRGB(255, 255, 255)
    elseif name == "Cyan" then return Color3.fromRGB(0, 255, 255)
    elseif name == "Green" then return Color3.fromRGB(0, 255, 100)
    elseif name == "Yellow" then return Color3.fromRGB(255, 255, 0)
    elseif name == "Orange" then return Color3.fromRGB(255, 150, 0)
    elseif name == "Pink" then return Color3.fromRGB(255, 100, 150) end
    return Color3.fromRGB(255, 255, 255)
end

-- ==================== УВЕДОМЛЕНИЯ ====================
local NotificationGui = Instance.new("ScreenGui", playerGui)
NotificationGui.Name = "HeseraNotifications"; NotificationGui.IgnoreGuiInset = true; NotificationGui.ResetOnSpawn = false; NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local activeNotifications = {}
local function notify(text, symbol, duration)
    if #activeNotifications > 4 then local old = table.remove(activeNotifications, 1); if old and old.Parent then old:Destroy() end end
    local f = Instance.new("Frame", NotificationGui)
    f.Size = UDim2.new(0, 220, 0, 30); f.Position = UDim2.new(1, 10, 0.82, -#activeNotifications * 35)
    f.BackgroundColor3 = Color3.fromRGB(0, 0, 0); f.BackgroundTransparency = 0.1; f.BorderSizePixel = 0; f.ZIndex = 99999
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(0, 3, 1, 0); bar.BackgroundColor3 = Color3.fromRGB(255, 200, 0); bar.BorderSizePixel = 0; bar.ZIndex = 99999
    local sym = Instance.new("TextLabel", f); sym.Size = UDim2.new(0, 22, 1, 0); sym.Position = UDim2.new(0, 5, 0, 0); sym.Text = symbol or "●"; sym.TextColor3 = Color3.fromRGB(255, 200, 0); sym.BackgroundTransparency = 1; sym.Font = Enum.Font.GothamBold; sym.TextSize = 12; sym.ZIndex = 99999
    local txt = Instance.new("TextLabel", f); txt.Size = UDim2.new(1, -32, 1, 0); txt.Position = UDim2.new(0, 28, 0, 0); txt.Text = text; txt.TextColor3 = Color3.fromRGB(255, 255, 255); txt.BackgroundTransparency = 1; txt.Font = Enum.Font.GothamBold; txt.TextSize = 9; txt.TextXAlignment = Enum.TextXAlignment.Left; txt.ZIndex = 99999
    table.insert(activeNotifications, f)
    TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -230, f.Position.Y.Scale, f.Position.Y.Offset)}):Play()
    task.delay(duration or 2.5, function() if f and f.Parent then local idx = table.find(activeNotifications, f); if idx then table.remove(activeNotifications, idx) end; f:Destroy() end end)
end

-- ==================== ВОДЯНОЙ ЗНАК ====================
local function createWatermark()
    if playerGui:FindFirstChild("WM") then playerGui.WM:Destroy() end
    local wmGui = Instance.new("ScreenGui", playerGui); wmGui.Name = "WM"; wmGui.IgnoreGuiInset = true; wmGui.ResetOnSpawn = false; wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local wm = Instance.new("TextButton", wmGui)
    wm.Size = UDim2.new(0, 220, 0, 28); wm.Position = UDim2.new(0.5, -110, 0, 2)
    wm.BackgroundColor3 = Color3.fromRGB(0, 0, 0); wm.BackgroundTransparency = 0.6; wm.BorderSizePixel = 0; wm.Text = ""; wm.AutoButtonColor = false; wm.ZIndex = 99999
    Instance.new("UICorner", wm).CornerRadius = UDim.new(0, 5)
    local tl = Instance.new("TextLabel", wm); tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.TextSize = 10; tl.TextXAlignment = Enum.TextXAlignment.Center; tl.RichText = true; tl.TextColor3 = Color3.fromRGB(255, 255, 255); tl.ZIndex = 99999
    tl.Text = '<font color="rgb(255,50,50)">' .. os.date("%H:%M:%S") .. '</font> <font color="rgb(255,255,255)">  |  t.me/heseracfg</font>'
    spawn(function() while wm and wm.Parent and tl and tl.Parent do pcall(function() tl.Text = '<font color="rgb(255,50,50)">' .. os.date("%H:%M:%S") .. '</font> <font color="rgb(255,255,255)">  |  t.me/heseracfg</font>' end); task.wait(1) end end)
    return wm
end
task.wait(0.5); local wmButton = createWatermark()

-- ==================== SUN CHAMS (НОВЫЕ) ====================
local chamsFolder
local function IsPlayerInMatch(playerChar)
    if not playerChar then return false end
    local normal = Workspace:FindFirstChild("Normal")
    local map = normal and normal:FindFirstChild("Map")
    if map then
        local root = playerChar:FindFirstChild("HumanoidRootPart")
        if root then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {map}
            raycastParams.FilterType = Enum.RaycastFilterType.Include
            local result = Workspace:Raycast(root.Position, Vector3.new(0, -60, 0), raycastParams)
            if result then return true end
        end
    end
    return false
end

local function CreatePerfectSunCham(plr, char)
    local old = chamsFolder:FindFirstChild(plr.Name .. "_Cham")
    if old then old:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = plr.Name .. "_Cham"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 200, 0)
    highlight.FillTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = chamsFolder
end

local function startSunChams()
    if chamsFolder then chamsFolder:Destroy() end
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "MM2SunChams"
    screenGui.ResetOnSpawn = false
    chamsFolder = Instance.new("Folder", screenGui)
    chamsFolder.Name = "SunChamsStorage"
    
    RunService.Heartbeat:Connect(function()
        if not Settings.SunChams then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local chamExists = chamsFolder:FindFirstChild(p.Name .. "_Cham")
                local inMatch = IsPlayerInMatch(p.Character)
                local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
                local isAlive = humanoid and humanoid.Health > 0
                
                if inMatch and isAlive and not chamExists then
                    CreatePerfectSunCham(p, p.Character)
                elseif chamExists and (not inMatch or not isAlive) then
                    chamExists:Destroy()
                end
            end
        end
    end)
end

-- ==================== KILL ALL ====================
local function findPlayerByRole(roleType)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character; local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                if roleType == "Murderer" and (char:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife"))) then return char
                elseif roleType == "Sheriff" and (char:FindFirstChild("Gun") or (p.Backpack and p.Backpack:FindFirstChild("Gun"))) then return char
                elseif roleType == "All" then return char end
            end
        end
    end
    return nil
end

local function killAll()
    local myChar = player.Character
    if not myChar then notify("Нет персонажа!", "❌"); return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then notify("Нет HRP!", "❌"); return end
    
    local killedCount = 0
    local originalPos = myHRP.CFrame
    
    -- Включаем noclip для телепорта
    for _, p in ipairs(myChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local theirHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local theirHum = p.Character:FindFirstChild("Humanoid")
            if theirHRP and theirHum and theirHum.Health > 0 then
                myHRP.CFrame = theirHRP.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.02)
                theirHum.Health = 0
                killedCount = killedCount + 1
            end
        end
    end
    
    -- Возвращаемся и восстанавливаем коллизии
    myHRP.CFrame = originalPos
    for _, p in ipairs(myChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    
    if killedCount > 0 then notify("Убито игроков: " .. killedCount, "💀")
    else notify("Нет целей для убийства!", "⚠️") end
end

-- ==================== MASS FLING ====================
local massFlingConn
local function massFling()
    if massFlingConn then massFlingConn:Disconnect(); massFlingConn = nil; notify("Mass Fling: ВЫКЛ", "💥"); return end
    
    local myChar = player.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    massFlingConn = RunService.Heartbeat:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local theirHRP = p.Character:FindFirstChild("HumanoidRootPart")
                if theirHRP then
                    theirHRP.Velocity = Vector3.new(math.random(-500, 500), math.random(200, 800), math.random(-500, 500))
                    theirHRP.RotVelocity = Vector3.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200))
                end
            end
        end
    end)
    notify("Mass Fling: ВКЛ", "💥")
end

-- ==================== VOID ====================
local function voidAll()
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local theirHRP = p.Character:FindFirstChild("HumanoidRootPart")
            if theirHRP then
                theirHRP.CFrame = CFrame.new(0, -500, 0)
                count = count + 1
            end
        end
    end
    if count > 0 then notify("Войд: " .. count .. " игроков", "🕳️")
    else notify("Нет игроков для войда!", "⚠️") end
end

-- ==================== SKYBOX ====================
local function applySkybox(skyType)
    if Lighting:FindFirstChild("CustomSky") then Lighting.CustomSky:Destroy() end
    if not Settings.CustomSkybox then return end
    local sky = Instance.new("Sky", Lighting); sky.Name = "CustomSky"
    local images = skyboxImages[skyType] or skyboxImages.White
    sky.SkyboxBk = images.SkyboxBk; sky.SkyboxDn = images.SkyboxDn; sky.SkyboxFt = images.SkyboxFt
    sky.SkyboxLf = images.SkyboxLf; sky.SkyboxRt = images.SkyboxRt; sky.SkyboxUp = images.SkyboxUp
    Settings.SkyboxType = skyType
end

-- CLOUD COLOR
local function applyCloudColor()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Clouds") then
            if Settings.CloudEnabled then obj.Color = getColorByName(Settings.CloudColor)
            else obj.Color = Color3.fromRGB(255, 255, 255) end
        end
    end
end

-- FOG
local function updateFog()
    if Settings.Fog then
        Lighting.FogEnd = Settings.FogDistance; Lighting.FogStart = Settings.FogDistance * 0.3
        Lighting.FogColor = getColorByName(Settings.FogColor)
    else Lighting.FogEnd = 100000; Lighting.FogStart = 100000 end
end

-- REMOVE UI
local savedUIStates = {}
local function toggleRemoveUI()
    Settings.RemoveUI = not Settings.RemoveUI
    if Settings.RemoveUI then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local name = gui.Name:lower(); savedUIStates[gui.Name] = gui.Enabled
                if name ~= "heseracfg" and name ~= "wm" and name ~= "flygui" and name ~= "aimbotfov" and name ~= "customcrosshair" and name ~= "backpack" and name ~= "inventory" and name ~= "touchgui" and name ~= "gunbutton" and name ~= "heseranotifications" then gui.Enabled = false end
            end
        end
    else
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and savedUIStates[gui.Name] ~= nil then gui.Enabled = savedUIStates[gui.Name] end
        end; savedUIStates = {}
    end
end

-- GLOW BODY
local function applyGlowBody()
    if highlightBody then highlightBody:Destroy(); highlightBody = nil end
    if not Settings.GlowBody or not player.Character then return end
    highlightBody = Instance.new("Highlight")
    highlightBody.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlightBody.FillColor = getColorByName(Settings.GlowColor); highlightBody.FillTransparency = 0.45
    highlightBody.OutlineColor = Color3.fromRGB(255, 255, 255); highlightBody.OutlineTransparency = 0
    highlightBody.Adornee = player.Character; highlightBody.Parent = CoreGui
end

-- ORBIT ORBS
local function applyOrbitOrbs()
    if orbitConnection then orbitConnection:Disconnect(); orbitConnection = nil end
    if orbitContainer then orbitContainer:Destroy(); orbitContainer = nil end
    if not Settings.OrbitOrbs or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    orbitContainer = Instance.new("Model", camera); orbitContainer.Name = "OrbitOrbs"
    local function createOrb() local o = Instance.new("Part", orbitContainer); o.Shape = Enum.PartType.Ball; o.Size = Vector3.new(1.2,1.2,1.2); o.Color = getColorByName(Settings.OrbColor); o.Material = Enum.Material.Neon; o.Anchored = true; o.CanCollide = false; return o end
    local o1, o2 = createOrb(), createOrb()
    orbitConnection = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent then applyOrbitOrbs(); return end
        local t = tick() * 4; local cp = hrp.Position
        o1.Position = Vector3.new(cp.X + math.cos(t) * 4.5, cp.Y + math.sin(t*2) * 0.5, cp.Z + math.sin(t) * 4.5)
        o2.Position = Vector3.new(cp.X + math.cos(t + math.pi) * 4.5, cp.Y + math.sin(t*2 + math.pi) * 0.5, cp.Z + math.sin(t + math.pi) * 4.5)
    end)
end

-- TRAIL
local function createTrailPart(pos, col)
    local p = Instance.new("Part"); p.Size = Vector3.new(0.3, 0.3, 0.3); p.Position = pos
    p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.Neon; p.Color = col
    p.Transparency = 0.5; p.Shape = Enum.PartType.Ball; p.Parent = trailContainer or camera; return p
end

local function updateTrails()
    if not Settings.Trail then for _, t in pairs(Trails) do pcall(function() t.Part:Destroy() end) end; Trails = {}; return end
    local now = tick(); local col = getColorByName(Settings.TrailColor)
    for i = #Trails, 1, -1 do
        local t = Trails[i]
        if now - t.Time > Settings.TrailDuration then pcall(function() t.Part:Destroy() end); table.remove(Trails, i)
        else
            local age = now - t.Time; local alpha = 1 - (age / Settings.TrailDuration)
            pcall(function() t.Part.Transparency = 0.5 + (1 - alpha) * 0.5; t.Part.Size = Vector3.new(0.3 * alpha, 0.3 * alpha, 0.3 * alpha) end)
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (plr == player or Settings.Trail) then
                local newPart = createTrailPart(hrp.Position, col)
                table.insert(Trails, {Part = newPart, Time = now, Player = plr})
            end
        end
    end
    while #Trails > 500 do local old = table.remove(Trails, 1); pcall(function() old.Part:Destroy() end) end
end

-- ==================== GUN GRABBER ====================
local function findGun()
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") then
            local name = item.Name:lower()
            if name == "gundrop" or name == "gun" or (name == "handle" and item.Parent and item.Parent.Name:lower() == "gun") then
                local parent = item.Parent
                if parent then
                    local isInCharacter = false
                    local current = item
                    while current do
                        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then isInCharacter = true; break end
                        current = current.Parent
                    end
                    if not isInCharacter then return item end
                end
            end
        end
    end
    return nil
end

local function hasGun()
    local char = player.Character; if not char then return false end
    if char:FindFirstChild("Gun") then return true end
    if player.Backpack and player.Backpack:FindFirstChild("Gun") then return true end
    return false
end

local function grabGun()
    if hasGun() then notify("У вас уже есть пистолет!", "🔫"); return false end
    local gun = findGun(); if not gun then notify("Пистолет не найден на карте!", "❌"); return false end
    local myChar = player.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then notify("Персонаж не найден!", "❌"); return false end
    local savedPos = myHRP.CFrame
    for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    myHRP.CFrame = gun.CFrame + Vector3.new(0, 3, 0); task.wait(0.05)
    if firetouchinterest then firetouchinterest(myHRP, gun, 0); task.wait(0.05); firetouchinterest(myHRP, gun, 1) end
    task.wait(0.2)
    for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
    myHRP.CFrame = savedPos
    if hasGun() then notify("Пистолет успешно подобран!", "✅"); return true
    else notify("Не удалось подобрать пистолет!", "⚠️"); return false end
end

-- КНОПКА ГЛОКА
local GunButtonGui = Instance.new("ScreenGui", playerGui)
GunButtonGui.Name = "GunButton"; GunButtonGui.IgnoreGuiInset = true; GunButtonGui.ResetOnSpawn = false; GunButtonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local gunButton = Instance.new("TextButton", GunButtonGui)
gunButton.Size = UDim2.new(0, 65, 0, 65); gunButton.Position = gunButtonPosition
gunButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0); gunButton.BackgroundTransparency = 0.7
gunButton.Text = ""; gunButton.AutoButtonColor = false; gunButton.Visible = false; gunButton.ZIndex = 9999
gunButton.Active = true; gunButton.Draggable = true
Instance.new("UICorner", gunButton).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", gunButton).Color = Color3.fromRGB(255, 200, 0)

gunButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        gunButtonPosition = gunButton.Position
    end
end)

local gunIcon = Instance.new("Frame", gunButton)
gunIcon.Size = UDim2.new(0, 40, 0, 40); gunIcon.Position = UDim2.new(0.5, -20, 0.5, -20); gunIcon.BackgroundTransparency = 1; gunIcon.ZIndex = 10000

local barrel = Instance.new("Frame", gunIcon)
barrel.Size = UDim2.new(0, 22, 0, 7); barrel.Position = UDim2.new(0, 14, 0.5, -3.5); barrel.BackgroundColor3 = Color3.fromRGB(20, 20, 20); barrel.BorderSizePixel = 0; Instance.new("UICorner", barrel).CornerRadius = UDim.new(0, 2)

local slide = Instance.new("Frame", gunIcon)
slide.Size = UDim2.new(0, 18, 0, 5); slide.Position = UDim2.new(0, 16, 0.5, -7); slide.BackgroundColor3 = Color3.fromRGB(30, 30, 30); slide.BorderSizePixel = 0; Instance.new("UICorner", slide).CornerRadius = UDim.new(0, 1)

local handle = Instance.new("Frame", gunIcon)
handle.Size = UDim2.new(0, 9, 0, 18); handle.Position = UDim2.new(0, 6, 0.5, -2); handle.BackgroundColor3 = Color3.fromRGB(15, 15, 15); handle.BorderSizePixel = 0; handle.Rotation = 12; Instance.new("UICorner", handle).CornerRadius = UDim.new(0, 3)

local triggerGuard = Instance.new("Frame", gunIcon)
triggerGuard.Size = UDim2.new(0, 7, 0, 9); triggerGuard.Position = UDim2.new(0, 10, 0.5, 3); triggerGuard.BackgroundColor3 = Color3.fromRGB(25, 25, 25); triggerGuard.BorderSizePixel = 0; Instance.new("UICorner", triggerGuard).CornerRadius = UDim.new(0, 2)

local magazine = Instance.new("Frame", gunIcon)
magazine.Size = UDim2.new(0, 7, 0, 10); magazine.Position = UDim2.new(0, 8, 0.5, 10); magazine.BackgroundColor3 = Color3.fromRGB(20, 20, 20); magazine.BorderSizePixel = 0; Instance.new("UICorner", magazine).CornerRadius = UDim.new(0, 2)

local frontSight = Instance.new("Frame", gunIcon)
frontSight.Size = UDim2.new(0, 3, 0, 3); frontSight.Position = UDim2.new(0, 34, 0.5, -8); frontSight.BackgroundColor3 = Color3.fromRGB(40, 40, 40); frontSight.BorderSizePixel = 0

RunService.RenderStepped:Connect(function(dt)
    if gunButton.Visible then gunIcon.Rotation = (gunIcon.Rotation + 180 * dt) % 360 end
end)

gunButton.MouseButton1Click:Connect(function()
    if not hasGun() then grabGun() else notify("У вас уже есть пистолет!", "🔫") end
end)

-- ==================== АНТИ-НОЖ ====================
local antiKnifeConnection = nil
local lastTeleportTime = 0; local teleportCooldown = 2

local function findSafePosition()
    local myChar = player.Character; if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end
    local currentPos = myHRP.Position; local bestPosition = nil; local bestDistance = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored then
            local size = obj.Size
            if size.Y < 5 and (size.X > 15 or size.Z > 15) then
                local pos = obj.Position
                for x = -1, 1, 2 do for z = -1, 1, 2 do
                    local checkPos = pos + Vector3.new(x * size.X/3, size.Y/2 + 3, z * size.Z/3)
                    if checkPos.Y > -10 and checkPos.Y < 100 then
                        local rayResult = Workspace:Raycast(checkPos + Vector3.new(0, 20, 0), Vector3.new(0, -50, 0))
                        if rayResult then
                            local safePos = rayResult.Position + Vector3.new(0, 4, 0)
                            local dist = (safePos - currentPos).Magnitude
                            if dist > 15 and dist > bestDistance then bestDistance = dist; bestPosition = CFrame.new(safePos) end
                        end
                    end
                end end
            end
        end
    end
    if not bestPosition then
        local baseplate = Workspace:FindFirstChild("Baseplate") or Workspace:FindFirstChild("Floor")
        if baseplate then
            local bpPos = baseplate.Position; local bpSize = baseplate.Size
            for attempt = 1, 20 do
                local randX = bpPos.X + (math.random() - 0.5) * bpSize.X * 0.8
                local randZ = bpPos.Z + (math.random() - 0.5) * bpSize.Z * 0.8
                local testPos = Vector3.new(randX, bpPos.Y + bpSize.Y/2 + 4, randZ)
                local dist = (testPos - currentPos).Magnitude
                if dist > 20 and dist > bestDistance then bestDistance = dist; bestPosition = CFrame.new(testPos) end
            end
        end
    end
    if not bestPosition then
        local emergencyPositions = {Vector3.new(0, 10, 0), Vector3.new(30, 10, 30), Vector3.new(-30, 10, -30), Vector3.new(50, 10, -20), Vector3.new(-50, 10, 20)}
        bestPosition = CFrame.new(emergencyPositions[math.random(1, #emergencyPositions)])
    end
    return bestPosition
end

local function findMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character; local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                if char:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife")) then return p, char end
            end
        end
    end
    return nil, nil
end

local function toggleAntiKnife()
    Settings.AntiKnife = not Settings.AntiKnife
    if Settings.AntiKnife then
        if antiKnifeConnection then antiKnifeConnection:Disconnect() end
        antiKnifeConnection = RunService.Heartbeat:Connect(function()
            if not Settings.AntiKnife then return end
            local myChar = player.Character; if not myChar then return end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
            local murderer, murdererChar = findMurderer(); if not murderer or not murdererChar then return end
            local murdererHRP = murdererChar:FindFirstChild("HumanoidRootPart"); if not murdererHRP then return end
            local dist = (murdererHRP.Position - myHRP.Position).Magnitude
            local now = tick()
            if dist <= Settings.AntiKnifeDistance and (now - lastTeleportTime) > teleportCooldown then
                lastTeleportTime = now
                local safePos = findSafePosition()
                if safePos then
                    for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
                    myHRP.CFrame = safePos; task.wait(0.3)
                    for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
                    notify("⚠ Убийца рядом! ТП на " .. math.floor(dist) .. "м", "🔪", 1.5)
                end
            end
        end)
        notify("Анти-Нож: ВКЛ", "🔪")
    else
        if antiKnifeConnection then antiKnifeConnection:Disconnect(); antiKnifeConnection = nil end
        notify("Анти-Нож: ВЫКЛ", "🔪")
    end
end

-- NOCLIP
local noclipConn
local function toggleNoclip()
    Settings.Noclip = not Settings.Noclip
    if Settings.Noclip then if noclipConn then noclipConn:Disconnect() end; noclipConn = RunService.Stepped:Connect(function() if Settings.Noclip and player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
    else if noclipConn then noclipConn:Disconnect(); noclipConn = nil end; if player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end
    notify("Noclip: " .. (Settings.Noclip and "ВКЛ" or "ВЫКЛ"), Settings.Noclip and "👻" or "🚫")
end

-- GOD MODE
local godConn
local function toggleGodMode()
    Settings.GodMode = not Settings.GodMode
    if Settings.GodMode then if godConn then godConn:Disconnect() end; godConn = RunService.Heartbeat:Connect(function() if Settings.GodMode and player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid"); if h and h.Health > 0 then h.Health = h.MaxHealth end end end)
    else if godConn then godConn:Disconnect(); godConn = nil end end
    notify("God Mode: " .. (Settings.GodMode and "ВКЛ" or "ВЫКЛ"), Settings.GodMode and "🛡️" or "🛡️")
end

-- FLY
local flyConn, flyBV, flyBG; local flyMoveDir = Vector3.zero
local FlyGui = Instance.new("ScreenGui", playerGui); FlyGui.Name = "FlyGUI"; FlyGui.ResetOnSpawn = false
local flyJoystick = Instance.new("Frame", FlyGui); flyJoystick.Size = UDim2.new(0,120,0,120); flyJoystick.Position = UDim2.new(0,45,1,-175); flyJoystick.BackgroundColor3 = Color3.fromRGB(0,0,0); flyJoystick.BackgroundTransparency = 0.4; flyJoystick.BorderSizePixel = 1; flyJoystick.BorderColor3 = Color3.fromRGB(255,0,0); flyJoystick.Visible = false; flyJoystick.ZIndex = 100; Instance.new("UICorner", flyJoystick).CornerRadius = UDim.new(0.5,0)
local flyStick = Instance.new("TextButton", flyJoystick); flyStick.Size = UDim2.new(0,46,0,46); flyStick.Position = UDim2.new(0.5,-23,0.5,-23); flyStick.BackgroundColor3 = Color3.fromRGB(255,0,0); flyStick.BorderSizePixel = 0; flyStick.Text = ""; flyStick.AutoButtonColor = false; flyStick.ZIndex = 101; Instance.new("UICorner", flyStick).CornerRadius = UDim.new(0.5,0)

flyStick.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        local center = flyJoystick.AbsolutePosition + flyJoystick.AbsoluteSize/2; local diff = Vector2.new(input.Position.X, input.Position.Y) - center; local maxR = flyJoystick.AbsoluteSize.X/2 - 10
        if diff.Magnitude > maxR then diff = diff.Unit * maxR end; flyStick.Position = UDim2.new(0.5, diff.X-23, 0.5, diff.Y-23); flyMoveDir = Vector3.new(diff.X/maxR, 0, diff.Y/maxR)
    end
end)
flyStick.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then flyStick.Position = UDim2.new(0.5,-23,0.5,-23); flyMoveDir = Vector3.zero end end)

local function startFly()
    local char = player.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity", root); flyBV.MaxForce = Vector3.new(400000,400000,400000); flyBV.Velocity = Vector3.zero
    flyBG = Instance.new("BodyGyro", root); flyBG.MaxTorque = Vector3.new(400000,400000,400000); flyBG.CFrame = root.CFrame
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.Heartbeat:Connect(function()
        if not Settings.Fly then return end; local c = player.Character; if not c then return end; local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end
        local md = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then md += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then md -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then md -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then md += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then md += Vector3.new(0,-1,0) end
        if flyMoveDir.Magnitude > 0 then md += camera.CFrame:VectorToWorldSpace(Vector3.new(flyMoveDir.X,0,flyMoveDir.Z)) end
        if md.Magnitude > 0 then flyBV.Velocity = md.Unit * Settings.FlySpeed else flyBV.Velocity = Vector3.zero end
        flyBG.CFrame = CFrame.lookAt(r.Position, r.Position + camera.CFrame.LookVector)
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = player.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
end

local function toggleFly()
    Settings.Fly = not Settings.Fly; flyJoystick.Visible = Settings.Fly
    if Settings.Fly then startFly(); notify("Fly: ВКЛ", "🕊️")
    else stopFly(); notify("Fly: ВЫКЛ", "🕊️") end
end

-- ANTI-FLING
local aflConn; local lastSafe = Vector3.new(0,50,0)
local function toggleAntiFling()
    Settings.AntiFling = not Settings.AntiFling
    if Settings.AntiFling then if aflConn then aflConn:Disconnect() end; aflConn = RunService.Heartbeat:Connect(function() local c = player.Character; if not c then return end; local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end; if r.Position.Y > -20 and r.Position.Y < 300 and r.Velocity.Magnitude < 100 then lastSafe = r.Position end; if r.Velocity.Magnitude > 350 or r.Position.Y < -50 then r.Velocity = Vector3.zero; r.CFrame = CFrame.new(lastSafe + Vector3.new(0,3,0)) end end)
    else if aflConn then aflConn:Disconnect(); aflConn = nil end end
    notify("Anti-Fling: " .. (Settings.AntiFling and "ВКЛ" or "ВЫКЛ"), Settings.AntiFling and "🛡️" or "🛡️")
end

-- SPINBOT
local spinConn
local function toggleSpinbot()
    Settings.Spinbot = not Settings.Spinbot
    if Settings.Spinbot then if spinConn then spinConn:Disconnect() end; spinConn = RunService.Heartbeat:Connect(function() if not Settings.Spinbot then return end; local r = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame *= CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0) end end)
    else if spinConn then spinConn:Disconnect(); spinConn = nil end end
    notify("Spinbot: " .. (Settings.Spinbot and "ВКЛ" or "ВЫКЛ"), Settings.Spinbot and "🔄" or "🔄")
end

-- BUNNY HOP
local bhopConn
local function toggleBunnyHop()
    Settings.BunnyHop = not Settings.BunnyHop
    if Settings.BunnyHop then if bhopConn then bhopConn:Disconnect() end; bhopConn = RunService.Heartbeat:Connect(function() if not Settings.BunnyHop then return end; local c = player.Character; if not c then return end; local h = c:FindFirstChild("Humanoid"); local r = c:FindFirstChild("HumanoidRootPart"); if not h or not r or h.FloorMaterial == Enum.Material.Air then return end; local md = h.MoveDirection; if md.Magnitude < 0.1 then return end; h.Jump = true; local sp = Vector3.new(r.Velocity.X,0,r.Velocity.Z).Magnitude; if sp > 5 then local d = Vector3.new(md.X,0,md.Z).Unit; r.Velocity = Vector3.new(d.X * math.min(sp*Settings.BHOPMultiplier, Settings.BHOPMaxSpeed), r.Velocity.Y, d.Z * math.min(sp*Settings.BHOPMultiplier, Settings.BHOPMaxSpeed)) end end)
    else if bhopConn then bhopConn:Disconnect(); bhopConn = nil end end
    notify("Bunny Hop: " .. (Settings.BunnyHop and "ВКЛ" or "ВЫКЛ"), Settings.BunnyHop and "🐇" or "🐇")
end

-- ANTI-LAG
local antiLagMaterials = {}
local function toggleAntiLag()
    Settings.AntiLag = not Settings.AntiLag
    if Settings.AntiLag then for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then antiLagMaterials[obj] = obj.Material; obj.Material = Enum.Material.SmoothPlastic elseif obj:IsA("Decal") or obj:IsA("Texture") then antiLagMaterials[obj] = obj.Transparency; obj.Transparency = 1 end end
    else for obj, val in pairs(antiLagMaterials) do if obj and obj.Parent then if obj:IsA("BasePart") then obj.Material = val elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = val end end end; antiLagMaterials = {} end
    notify("Anti-Lag: " .. (Settings.AntiLag and "ВКЛ" or "ВЫКЛ"), Settings.AntiLag and "⚡" or "⚡")
end

-- JUMP POWER
local jumpConn
local function toggleJumpPower()
    Settings.JumpPower = not Settings.JumpPower
    if Settings.JumpPower then if jumpConn then jumpConn:Disconnect() end; jumpConn = UserInputService.JumpRequest:Connect(function() if not Settings.JumpPower then return end; local c = player.Character; if not c then return end; local h = c:FindFirstChildOfClass("Humanoid"); local r = c:FindFirstChild("HumanoidRootPart"); if h and r then h.JumpPower = Settings.JumpMultiplier; h.Jump = true; r.Velocity = Vector3.new(r.Velocity.X, Settings.JumpMultiplier * 0.8, r.Velocity.Z); h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    else if jumpConn then jumpConn:Disconnect(); jumpConn = nil end end
    notify("Jump Power: " .. (Settings.JumpPower and "ВКЛ" or "ВЫКЛ"), Settings.JumpPower and "🦘" or "🦘")
end

-- WALL HOP
local wallHopConn
local function toggleWallHop()
    Settings.WallHop = not Settings.WallHop
    if Settings.WallHop then if wallHopConn then wallHopConn:Disconnect() end; wallHopConn = UserInputService.JumpRequest:Connect(function() if not Settings.WallHop then return end; local c = player.Character; if not c then return end; local r = c:FindFirstChild("HumanoidRootPart"); local h = c:FindFirstChildOfClass("Humanoid"); if not r or not h then return end; local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = {c}; local near = false; for _, d in ipairs({r.CFrame.LookVector, -r.CFrame.LookVector, r.CFrame.RightVector, -r.CFrame.RightVector}) do if workspace:Raycast(r.Position, d*2.2, rp) then near = true; break end end; if near then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    else if wallHopConn then wallHopConn:Disconnect(); wallHopConn = nil end end
    notify("Wall Hop: " .. (Settings.WallHop and "ВКЛ" or "ВЫКЛ"), Settings.WallHop and "🧱" or "🧱")
end

-- AUTO REJOIN
local rejoinConn; local placeId = game.PlaceId
local function toggleAutoRejoin()
    Settings.AutoRejoin = not Settings.AutoRejoin
    if Settings.AutoRejoin then if rejoinConn then rejoinConn:Disconnect() end; rejoinConn = RunService.Heartbeat:Connect(function() if not Settings.AutoRejoin then return end; if not player:IsDescendantOf(Players) then task.wait(Settings.RejoinDelay); pcall(function() TeleportService:Teleport(placeId, player) end) end end)
    else if rejoinConn then rejoinConn:Disconnect(); rejoinConn = nil end end
    notify("Auto Rejoin: " .. (Settings.AutoRejoin and "ВКЛ" or "ВЫКЛ"), Settings.AutoRejoin and "🔄" or "🔄")
end

-- TP FUNCTIONS
local function tpToMurderer()
    local target = findPlayerByRole("Murderer")
    if target then local hrp = target:FindFirstChild("HumanoidRootPart"); local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and myHRP then myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0); notify("ТП к убийце!", "📍") end
    else notify("Убийца не найден!", "❌") end
end

local function tpToSheriff()
    local target = findPlayerByRole("Sheriff")
    if target then local hrp = target:FindFirstChild("HumanoidRootPart"); local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and myHRP then myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0); notify("ТП к шерифу!", "📍") end
    else notify("Шериф не найден!", "❌") end
end

local function tpToLobby()
    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then myHRP.CFrame = CFrame.new(0.27, 504.52, -22.25); notify("ТП в лобби!", "📍") end
end

-- ESP
local function createESP(plr) local bf = Drawing.new("Square"); bf.Visible = false; bf.Filled = true; bf.Color = Color3.fromRGB(255,255,255); bf.Transparency = 0.75; local bo = Drawing.new("Square"); bo.Visible = false; bo.Thickness = 1.5; bo.Filled = false; local tr = Drawing.new("Line"); tr.Visible = false; tr.Thickness = 0.8; local tx = Drawing.new("Text"); tx.Visible = false; tx.Size = 12; tx.Center = true; return {boxFill=bf, boxOutline=bo, tracer=tr, text=tx} end
local function updateESP()
    for plr, e in pairs(ESPObjects) do if not plr or not plr.Parent then pcall(function() e.boxFill:Remove(); e.boxOutline:Remove(); e.tracer:Remove(); e.text:Remove() end); ESPObjects[plr] = nil else pcall(function() e.boxFill.Visible = false; e.boxOutline.Visible = false; e.tracer.Visible = false; e.text.Visible = false end) end end
    if not Settings.ESP then return end; local mc = player.Character; if not mc then return end; local mr = mc:FindFirstChild("HumanoidRootPart"); if not mr then return end
    for plr, e in pairs(ESPObjects) do if plr == player then continue end; local c = plr.Character; if not c then continue end; local h = c:FindFirstChild("Humanoid"); if not h or h.Health <= 0 then continue end; local head = c:FindFirstChild("Head"); local root = c:FindFirstChild("HumanoidRootPart"); if not head or not root then continue end; local d = (root.Position - mr.Position).Magnitude; if d > 500 then continue end
        if Settings.ESPBox then local hp, hv = camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0)); local fp, fv = camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)); if hv and fv then local bh = math.abs(hp.Y-fp.Y); local bw = bh*0.35; if bh<10 then bh=10;bw=4 end; if bh>300 then bh=300;bw=105 end; pcall(function() e.boxFill.Position = Vector2.new(fp.X-bw/2,hp.Y); e.boxFill.Size = Vector2.new(bw,bh); e.boxFill.Visible = true; e.boxOutline.Position = Vector2.new(fp.X-bw/2,hp.Y); e.boxOutline.Size = Vector2.new(bw,bh); e.boxOutline.Visible = true end) end end
        if Settings.ESPTracer then local fp, fv = camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)); if fv then pcall(function() e.tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y); e.tracer.To = Vector2.new(fp.X, fp.Y); e.tracer.Visible = true end) end end
        if Settings.ESPName or Settings.ESPDistance then local txt = ""; if Settings.ESPName then txt = plr.Name end; if Settings.ESPDistance then txt = txt .. " ["..math.floor(d).."m]" end; local fp, fv = camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)); if fv then pcall(function() e.text.Text = txt; e.text.Position = Vector2.new(fp.X, fp.Y-20); e.text.Visible = true end) end end
    end
end
local function addESP(plr) if plr ~= player and not ESPObjects[plr] then ESPObjects[plr] = createESP(plr) end end
local function removeESP(plr) if ESPObjects[plr] then pcall(function() ESPObjects[plr].boxFill:Remove(); ESPObjects[plr].boxOutline:Remove(); ESPObjects[plr].tracer:Remove(); ESPObjects[plr].text:Remove() end); ESPObjects[plr] = nil end end
for _, p in pairs(Players:GetPlayers()) do addESP(p) end; Players.PlayerAdded:Connect(addESP); Players.PlayerRemoving:Connect(removeESP)

-- ==================== AIMBOT ====================
local fovCircle
local function createFOVCircle()
    if playerGui:FindFirstChild("AimbotFOV") then playerGui.AimbotFOV:Destroy() end
    local fg = Instance.new("ScreenGui", playerGui); fg.Name = "AimbotFOV"; fg.IgnoreGuiInset = true; fg.ResetOnSpawn = false
    fovCircle = Instance.new("Frame", fg); fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.Size = UDim2.new(0, Settings.AimbotFOV*2, 0, Settings.AimbotFOV*2); fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); fovCircle.BackgroundTransparency = 0.92; fovCircle.BorderSizePixel = 0
    fovCircle.Visible = false; fovCircle.ZIndex = 999; Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", fovCircle).Color = Color3.fromRGB(255, 255, 255); fovCircle:FindFirstChildOfClass("UIStroke").Thickness = 2; fovCircle:FindFirstChildOfClass("UIStroke").Transparency = 0.3
end
createFOVCircle()

local function getTargetInFOV()
    local murderer = findPlayerByRole("Murderer"); if not murderer then return nil end
    local head = murderer:FindFirstChild("Head"); local hrp = murderer:FindFirstChild("HumanoidRootPart"); if not head or not hrp then return nil end
    local myChar = player.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then if (myChar.HumanoidRootPart.Position - hrp.Position).Magnitude > Settings.AimbotRange then return nil end end
    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
    if onScreen then
        local centerScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        if (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude <= Settings.AimbotFOV then return head end
    end
    return nil
end

local aimConn
local function startAimbotLoop()
    if aimConn then aimConn:Disconnect() end
    aimConn = RunService.RenderStepped:Connect(function()
        if not Settings.Aimbot then return end
        if Settings.AimbotMode == "WeaponOnly" then local c = player.Character; if not c or not (c:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun"))) then return end end
        local t = getTargetInFOV()
        if t then camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, t.Position), 0.3) end
    end)
end

local function toggleAimbot()
    Settings.Aimbot = not Settings.Aimbot; if fovCircle then fovCircle.Visible = Settings.Aimbot end
    if Settings.Aimbot then startAimbotLoop(); notify("Aimbot: ВКЛ", "🎯")
    else if aimConn then aimConn:Disconnect(); aimConn = nil end; notify("Aimbot: ВЫКЛ", "🎯") end
end

-- ==================== DEATH EFFECTS ====================
local function createSmoothParticle(pos, color, size, lifetime, velocity)
    local p = Instance.new("Part"); p.Size = Vector3.new(0, 0, 0); p.Position = pos; p.Anchored = true; p.CanCollide = false
    p.Material = Enum.Material.Neon; p.Color = color; p.Transparency = 0.6; p.Shape = Enum.PartType.Ball; p.Parent = Workspace
    local light = Instance.new("PointLight", p); light.Color = color; light.Brightness = 0; light.Range = 5; light.Shadows = false
    TweenService:Create(p, TweenInfo.new(0.15), {Size = Vector3.new(size, size, size), Transparency = 0.2}):Play()
    TweenService:Create(light, TweenInfo.new(0.15), {Brightness = 3}):Play()
    spawn(function() task.wait(0.15); local st = tick(); local sp2 = p.Position
        while tick() - st < lifetime and p.Parent do local pr = (tick() - st) / lifetime; local ep = pr * pr; local pulse = math.sin(pr * 6) * 0.3; local cs = size * (1 - ep * 0.5) * (1 + pulse * 0.2)
            pcall(function() p.Position = sp2 + velocity * ep; p.Transparency = 0.2 + ep * 0.8; p.Size = Vector3.new(cs, cs, cs); light.Brightness = 3 * (1 - ep) * (0.7 + pulse * 0.5) end)
            velocity = velocity * 0.97; task.wait(0.015) end
        TweenService:Create(p, TweenInfo.new(0.2), {Size = Vector3.new(0, 0, 0), Transparency = 1}):Play(); TweenService:Create(light, TweenInfo.new(0.2), {Brightness = 0}):Play()
        task.delay(0.2, function() pcall(function() p:Destroy() end) end) end)
end

local function spawnExplosionEffect(chr)
    if not Settings.DeathEffect or not chr then return end
    local hrp = chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local pos = hrp.Position; local col = getColorByName(Settings.DeathEffectColor)
    local colors = {col, Color3.fromRGB(math.clamp(col.R*255+50,0,255)/255, math.clamp(col.G*255+50,0,255)/255, math.clamp(col.B*255+50,0,255)/255), Color3.fromRGB(255,255,255)}
    
    local flash = Instance.new("Part"); flash.Size = Vector3.new(0.5,0.5,0.5); flash.Position = pos; flash.Anchored = true; flash.CanCollide = false; flash.Material = Enum.Material.Neon; flash.Color = Color3.fromRGB(255,255,255); flash.Transparency = 0.3; flash.Shape = Enum.PartType.Ball; flash.Parent = Workspace
    local flashLight = Instance.new("PointLight", flash); flashLight.Color = col; flashLight.Brightness = 15; flashLight.Range = 20
    TweenService:Create(flash, TweenInfo.new(0.3), {Size = Vector3.new(8,8,8), Transparency = 0.7}):Play()
    TweenService:Create(flashLight, TweenInfo.new(0.3), {Brightness = 30, Range = 30}):Play()
    spawn(function() task.wait(0.25); TweenService:Create(flash, TweenInfo.new(0.5), {Size = Vector3.new(15,15,15), Transparency = 1}):Play(); TweenService:Create(flashLight, TweenInfo.new(0.5), {Brightness = 0, Range = 0}):Play(); task.delay(0.5, function() pcall(function() flash:Destroy() end) end) end)
    
    for i = 1, 60 do
        local angle = math.random() * math.pi * 2; local elevation = (math.random() - 0.5) * math.pi; local distance = 2 + math.random() * 8
        local spawnPos = pos + Vector3.new(math.cos(angle)*math.cos(elevation)*distance, math.sin(elevation)*distance, math.sin(angle)*math.cos(elevation)*distance)
        local velocity = (spawnPos - pos).Unit * (10 + math.random() * 20); local particleSize = 0.15 + math.random() * 0.5; local lifetime = 0.8 + math.random() * 1.2; local particleColor = colors[math.random(1, #colors)]
        createSmoothParticle(spawnPos, particleColor, particleSize, lifetime, velocity)
    end
end

local function testDeathEffect()
    if player.Character then spawnExplosionEffect(player.Character); notify("Тест эффекта смерти!", "💥") end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then local hum = p.Character:FindFirstChild("Humanoid")
        if hum then hum.Died:Connect(function() task.wait(0.05); spawnExplosionEffect(p.Character) end) end end
    p.CharacterAdded:Connect(function(char) local hum = char:WaitForChild("Humanoid", 20)
        if hum then hum.Died:Connect(function() task.wait(0.05); spawnExplosionEffect(char) end) end end)
end

-- ==================== AUTO FARM (ИСПРАВЛЕНО) ====================
local farmConn, farmFlyBodyGyro, farmFlyBodyVelocity

local function findCoins()
    local coins = {}
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("BasePart") and not o.Anchored and o.Name:lower():find("coin") then table.insert(coins, o) end
    end
    if player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then table.sort(coins, function(a, b) return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude end) end
    end
    return coins
end

local function startFarmFly()
    local char = player.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    if farmFlyBodyGyro then farmFlyBodyGyro:Destroy() end
    farmFlyBodyGyro = Instance.new("BodyGyro", root); farmFlyBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000); farmFlyBodyGyro.CFrame = root.CFrame; farmFlyBodyGyro.P = 3000; farmFlyBodyGyro.D = 500
    if farmFlyBodyVelocity then farmFlyBodyVelocity:Destroy() end
    farmFlyBodyVelocity = Instance.new("BodyVelocity", root); farmFlyBodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000); farmFlyBodyVelocity.Velocity = Vector3.zero; farmFlyBodyVelocity.P = 1000
end

local function stopFarmFly()
    if farmFlyBodyGyro then farmFlyBodyGyro:Destroy(); farmFlyBodyGyro = nil end
    if farmFlyBodyVelocity then farmFlyBodyVelocity:Destroy(); farmFlyBodyVelocity = nil end
    local char = player.Character
    if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
end

local function flyToPosition(targetPos, speed)
    local char = player.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local startPos = root.Position; local distance = (targetPos - startPos).Magnitude; local direction = (targetPos - startPos).Unit
    if farmFlyBodyGyro then farmFlyBodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + direction) end
    local arrived = false; local startTime = tick(); local maxTime = distance / speed + 1
    while not arrived and tick() - startTime < maxTime do
        if not Settings.AutoFarm then return end; if not char or not char.Parent then return end; if not root or not root.Parent then return end
        local currentPos = root.Position; local remaining = (targetPos - currentPos).Magnitude
        if remaining < 2 then arrived = true; break end
        local dir = (targetPos - currentPos).Unit
        if farmFlyBodyVelocity then farmFlyBodyVelocity.Velocity = dir * math.min(speed, remaining * 2) end
        if farmFlyBodyGyro then farmFlyBodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + dir) end
        RunService.Heartbeat:Wait()
    end
    if farmFlyBodyVelocity then farmFlyBodyVelocity.Velocity = Vector3.zero end
    return arrived
end

local function collectCoinSmooth(coin)
    if not coin or not coin.Parent then return false end
    local char = player.Character; if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return false end
    local coinPos = coin.Position; local targetPos = coinPos + Vector3.new(0, 2, 0)
    flyToPosition(targetPos, 80)
    if coin.Parent and firetouchinterest then
        pcall(function() firetouchinterest(root, coin, 0); task.wait(0.05); firetouchinterest(root, coin, 1) end)
    end
    return true
end

local function toggleAutoFarm()
    Settings.AutoFarm = not Settings.AutoFarm
    if Settings.AutoFarm then
        Settings.Noclip = true
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function() if Settings.Noclip and player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
        startFarmFly()
        if farmConn then farmConn:Disconnect() end
        farmConn = RunService.Heartbeat:Connect(function()
            if not Settings.AutoFarm then return end; if not player.Character then return end
            local coins = findCoins(); local collected = 0
            for _, coin in ipairs(coins) do if not Settings.AutoFarm then break end; if not coin.Parent then continue end
                if collectCoinSmooth(coin) then collected = collected + 1; task.wait(Settings.FarmDelay) end
            end
            if collected > 0 then notify("Собрано монет: " .. collected, "🪙") end
        end)
        notify("Auto Farm: ВКЛ (плавный полёт)", "🪙")
    else
        if farmConn then farmConn:Disconnect(); farmConn = nil end
        stopFarmFly()
        Settings.Noclip = false
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
        notify("Auto Farm: ВЫКЛ", "🪙")
    end
end

-- CUSTOM CROSSHAIR
local crosshairGui, crosshairContainer, crosshairLines
local function updateCustomCrosshair()
    if crosshairGui then crosshairGui:Destroy(); crosshairGui = nil end; crosshairLines = {}
    if not Settings.CustomCrosshair then return end
    crosshairGui = Instance.new("ScreenGui", playerGui); crosshairGui.Name = "CustomCrosshair"; crosshairGui.IgnoreGuiInset = true; crosshairGui.ResetOnSpawn = false; crosshairGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    crosshairContainer = Instance.new("Frame", crosshairGui); crosshairContainer.Size = UDim2.new(0,100,0,100); crosshairContainer.Position = UDim2.new(0.5,-50,0.5,-50); crosshairContainer.BackgroundTransparency = 1; crosshairContainer.ZIndex = 99999
    local c = getColorByName(Settings.CrosshairColor); local s = Settings.CrosshairSize; local t = 2
    if Settings.CrosshairType == "Cross" then
        local g = 4; local l = s*0.5; local function cl(x,y,w,h) local ln = Instance.new("Frame", crosshairContainer); ln.Size = UDim2.new(0,w,0,h); ln.Position = UDim2.new(0.5,x,0.5,y); ln.BackgroundColor3 = c; ln.BorderSizePixel = 0; ln.AnchorPoint = Vector2.new(0.5,0.5); table.insert(crosshairLines, ln) end
        cl(0,-g-l/2,t,l); cl(0,g+l/2,t,l); cl(-g-l/2,0,l,t); cl(g+l/2,0,l,t)
    elseif Settings.CrosshairType == "Circle" then
        local ci = Instance.new("Frame", crosshairContainer); ci.Size = UDim2.new(0,s,0,s); ci.Position = UDim2.new(0.5,-s/2,0.5,-s/2); ci.BackgroundColor3 = c; ci.BackgroundTransparency = 0.85; ci.BorderSizePixel = 0; Instance.new("UICorner", ci).CornerRadius = UDim.new(1,0); Instance.new("UIStroke", ci).Color = c; Instance.new("UIStroke", ci).Thickness = t; table.insert(crosshairLines, ci)
    elseif Settings.CrosshairType == "Dot" then
        local d = Instance.new("Frame", crosshairContainer); d.Size = UDim2.new(0,t*4,0,t*4); d.Position = UDim2.new(0.5,-t*2,0.5,-t*2); d.BackgroundColor3 = c; d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); table.insert(crosshairLines, d)
    elseif Settings.CrosshairType == "Paw" then
        local o = s*0.35; local function pd(x,y,sz) local d = Instance.new("Frame", crosshairContainer); d.Size = UDim2.new(0,sz,0,sz); d.Position = UDim2.new(0.5,x-sz/2,0.5,y-sz/2); d.BackgroundColor3 = c; d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); table.insert(crosshairLines, d) end
        pd(-o,-o,t*3); pd(o,-o,t*3); pd(-o,o,t*3); pd(o,o,t*3); pd(0,0,t*4)
    end
end

-- SHIFT LOCK
local lockConn
local function toggleShiftLock()
    Settings.ShiftLock = not Settings.ShiftLock
    if Settings.ShiftLock then if lockConn then lockConn:Disconnect() end; UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter; lockConn = RunService.RenderStepped:Connect(function() if not Settings.ShiftLock then return end; UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter; local c = player.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart"); local h = c and c:FindFirstChildOfClass("Humanoid"); if hrp and h and h.Health > 0 then h.AutoRotate = false; local la = camera.CFrame.LookVector; hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.atan2(-la.X, -la.Z), 0) end end)
    else if lockConn then lockConn:Disconnect(); lockConn = nil end; UserInputService.MouseBehavior = Enum.MouseBehavior.Default; local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if h then h.AutoRotate = true end end
    notify("Shift Lock: " .. (Settings.ShiftLock and "ВКЛ" or "ВЫКЛ"), Settings.ShiftLock and "🔒" or "🔓")
end

-- ==================== ГЛАВНОЕ МЕНЮ ====================
local gui = Instance.new("ScreenGui", playerGui); gui.Name = "HESERACFG"; gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local win = Instance.new("Frame", gui); win.Size = UDim2.new(0, 420, 0, 320); win.Position = UDim2.new(0.02, 0, 0.1, 0); win.BackgroundTransparency = 1; win.BorderSizePixel = 0; win.ZIndex = 1; win.Visible = false; win.ClipsDescendants = true; Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)
local bgImg = Instance.new("ImageLabel", win); bgImg.Size = UDim2.new(1,0,1,0); bgImg.BackgroundTransparency = 0; bgImg.Image = "rbxassetid://85934187873808"; bgImg.ScaleType = Enum.ScaleType.Crop; bgImg.ZIndex = 1; Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0, 12)

local wd, wds, wps = false, Vector2.zero, Vector2.zero
local hd = Instance.new("TextButton", win); hd.Size = UDim2.new(1,0,0,25); hd.BackgroundTransparency = 1; hd.Text = ""; hd.ZIndex = 10000
hd.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then wd = true; wds = i.Position; wps = win.AbsolutePosition; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then wd = false end end) end end)
UserInputService.InputChanged:Connect(function(i) if wd and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then win.Position = UDim2.new(0, wps.X + i.Position.X - wds.X, 0, wps.Y + i.Position.Y - wds.Y) end end)

local function toggleMenu() if win.Visible then TweenService:Create(win, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play(); task.wait(0.2); win.Visible = false else win.Visible = true; win.Size = UDim2.new(0,0,0,0); TweenService:Create(win, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,420,0,320)}):Play() end end
if wmButton then wmButton.MouseButton1Click:Connect(toggleMenu) end

local hdr = Instance.new("Frame", win); hdr.Size = UDim2.new(1,0,0,40); hdr.BackgroundColor3 = Color3.fromRGB(0,0,0); hdr.BackgroundTransparency = 0.8; hdr.ZIndex = 10; Instance.new("UICorner", hdr).CornerRadius = UDim.new(0,12)
local ttl = Instance.new("TextLabel", hdr); ttl.Size = UDim2.new(0,350,1,0); ttl.Position = UDim2.new(0,15,0,0); ttl.Text = "HESERACFG PREMIUM v11.0"; ttl.BackgroundTransparency = 1; ttl.Font = Enum.Font.GothamBlack; ttl.TextSize = 14; ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 11; ttl.TextColor3 = Color3.fromRGB(255, 255, 255)

local cls = Instance.new("TextButton", hdr); cls.Size = UDim2.new(0,22,0,22); cls.Position = UDim2.new(1,-28,0.5,-11); cls.Text = "✕"; cls.BackgroundColor3 = Color3.fromRGB(255,0,0); cls.BackgroundTransparency = 0.5; cls.TextColor3 = Color3.fromRGB(255,255,255); cls.Font = Enum.Font.GothamBold; cls.TextSize = 14; cls.ZIndex = 11; Instance.new("UICorner", cls).CornerRadius = UDim.new(1,0)

local function destroyAll()
    Settings.GunGrabber = false; gunButton.Visible = false
    Settings.AntiKnife = false; if antiKnifeConnection then antiKnifeConnection:Disconnect(); antiKnifeConnection = nil end
    Settings.AutoFarm = false; if farmConn then farmConn:Disconnect(); farmConn = nil end; stopFarmFly()
    Settings.SunChams = false; if chamsFolder then chamsFolder:Destroy() end
    if massFlingConn then massFlingConn:Disconnect(); massFlingConn = nil end
    for k, _ in pairs(Settings) do if type(Settings[k]) == "boolean" and Settings[k] then if k == "Noclip" then toggleNoclip() elseif k == "GodMode" then toggleGodMode() elseif k == "Fly" then toggleFly() elseif k == "AntiFling" then toggleAntiFling() elseif k == "Spinbot" then toggleSpinbot() elseif k == "BunnyHop" then toggleBunnyHop() elseif k == "AntiLag" then toggleAntiLag() elseif k == "JumpPower" then toggleJumpPower() elseif k == "WallHop" then toggleWallHop() elseif k == "AutoRejoin" then toggleAutoRejoin() elseif k == "RemoveUI" then toggleRemoveUI() elseif k == "CustomSkybox" then Settings.CustomSkybox = false; if Lighting:FindFirstChild("CustomSky") then Lighting.CustomSky:Destroy() end elseif k == "Aimbot" then toggleAimbot() elseif k == "SilentAim" then Settings.SilentAim = false elseif k == "DeathEffect" then Settings.DeathEffect = false elseif k == "ShiftLock" then toggleShiftLock() end end end
    Settings.GraphicsMode = "Off"; applyGraphicsMode()
    Settings.Fog = false; updateFog()
    saveAllSettings()
    for _, e in pairs(ESPObjects) do pcall(function() e.boxFill:Remove(); e.boxOutline:Remove(); e.tracer:Remove(); e.text:Remove() end) end; ESPObjects = {}
    for _, t in pairs(Trails) do pcall(function() t.Part:Destroy() end) end; Trails = {}
    if playerGui:FindFirstChild("WM") then playerGui.WM:Destroy() end
    if playerGui:FindFirstChild("FlyGUI") then playerGui.FlyGUI:Destroy() end
    if playerGui:FindFirstChild("AimbotFOV") then playerGui.AimbotFOV:Destroy() end
    if playerGui:FindFirstChild("CustomCrosshair") then playerGui.CustomCrosshair:Destroy() end
    if playerGui:FindFirstChild("GunButton") then playerGui.GunButton:Destroy() end
    if playerGui:FindFirstChild("HESERACFG") then playerGui.HESERACFG:Destroy() end
    gui:Destroy(); notify("Чит удалён!", "🗑️")
end
cls.MouseButton1Click:Connect(destroyAll)

local left = Instance.new("Frame", win); left.Size = UDim2.new(0,70,1,-40); left.Position = UDim2.new(0,0,0,40); left.BackgroundColor3 = Color3.fromRGB(0,0,0); left.BackgroundTransparency = 0.8; left.ZIndex = 10; Instance.new("UICorner", left).CornerRadius = UDim.new(0,12)
local right = Instance.new("Frame", win); right.Size = UDim2.new(1,-70,1,-40); right.Position = UDim2.new(0,70,0,40); right.BackgroundColor3 = Color3.fromRGB(0,0,0); right.BackgroundTransparency = 0.8; right.ZIndex = 10; Instance.new("UICorner", right).CornerRadius = UDim.new(0,12)
local scr = Instance.new("ScrollingFrame", right); scr.Size = UDim2.new(1,0,1,0); scr.BackgroundTransparency = 1; scr.BorderSizePixel = 0; scr.ScrollBarThickness = 2; scr.ScrollBarImageColor3 = getMenuColor(); scr.ZIndex = 10; scr.CanvasSize = UDim2.new(0,0,0,8000)

local function clr() for _, c in pairs(scr:GetChildren()) do if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end end end

local function makeToggle(name, get, set, y)
    local c1 = getMenuColor(); local f = Instance.new("Frame", scr); f.Size = UDim2.new(0.92,0,0,30); f.Position = UDim2.new(0.04,0,0,y); f.BackgroundColor3 = Color3.fromRGB(0,0,0); f.BackgroundTransparency = 0.8; f.ZIndex = 10; Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local lab = Instance.new("TextLabel", f); lab.Size = UDim2.new(0.55,0,1,0); lab.Position = UDim2.new(0.06,0,0,0); lab.Text = name; lab.TextColor3 = Color3.fromRGB(255,255,255); lab.BackgroundTransparency = 1; lab.Font = Enum.Font.GothamBold; lab.TextSize = 10; lab.TextXAlignment = Enum.TextXAlignment.Left; lab.ZIndex = 11
    local val = get(); local tg = Instance.new("Frame", f); tg.Size = UDim2.new(0,32,0,18); tg.Position = UDim2.new(1,-38,0.5,-9); tg.BackgroundColor3 = val and c1 or Color3.fromRGB(60,60,60); tg.BackgroundTransparency = 0.5; tg.BorderSizePixel = 0; tg.ZIndex = 11; Instance.new("UICorner", tg).CornerRadius = UDim.new(1,0)
    local kn = Instance.new("Frame", tg); kn.Size = UDim2.new(0,12,0,12); kn.Position = val and UDim2.new(0,18,0,3) or UDim2.new(0,2,0,3); kn.BackgroundColor3 = Color3.fromRGB(255,255,255); kn.BorderSizePixel = 0; kn.ZIndex = 12; Instance.new("UICorner", kn).CornerRadius = UDim.new(1,0)
    local tb = Instance.new("TextButton", f); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; local state = val
    tb.MouseButton1Click:Connect(function() state = not state; set(state); TweenService:Create(tg, TweenInfo.new(0.3), {BackgroundColor3 = state and c1 or Color3.fromRGB(60,60,60)}):Play(); TweenService:Create(kn, TweenInfo.new(0.3), {Position = state and UDim2.new(0,18,0,3) or UDim2.new(0,2,0,3)}):Play() end)
end

local function makeSlider(name, get, set, minV, maxV, y)
    local c1 = getMenuColor(); local f = Instance.new("Frame", scr); f.Size = UDim2.new(0.92,0,0,42); f.Position = UDim2.new(0.04,0,0,y); f.BackgroundColor3 = Color3.fromRGB(0,0,0); f.BackgroundTransparency = 0.8; f.ZIndex = 10; Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local val = get(); local range = maxV - minV; local lab = Instance.new("TextLabel", f); lab.Size = UDim2.new(0.75,0,0,16); lab.Position = UDim2.new(0.06,0,0,2); lab.Text = name .. ": " .. math.floor(val); lab.TextColor3 = Color3.fromRGB(255,255,255); lab.BackgroundTransparency = 1; lab.Font = Enum.Font.GothamBold; lab.TextSize = 8; lab.TextXAlignment = Enum.TextXAlignment.Left; lab.ZIndex = 11
    local sb = Instance.new("Frame", f); sb.Size = UDim2.new(0.86,0,0,4); sb.Position = UDim2.new(0.06,0,0,28); sb.BackgroundColor3 = Color3.fromRGB(40,40,40); sb.BorderSizePixel = 0; sb.ZIndex = 11; Instance.new("UICorner", sb).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", sb); fill.Size = UDim2.new((val-minV)/range,0,1,0); fill.BackgroundColor3 = c1; fill.BorderSizePixel = 0; fill.ZIndex = 11; Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", sb); knob.Size = UDim2.new(0,10,0,10); knob.Position = UDim2.new((val-minV)/range,-5,0,-3); knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.BorderSizePixel = 0; knob.ZIndex = 12; Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local db = Instance.new("TextButton", f); db.Size = UDim2.new(1,0,1,0); db.BackgroundTransparency = 1; db.Text = ""; db.ZIndex = 100; local dragging = false
    local function us(inputX) local relX = math.clamp((inputX - sb.AbsolutePosition.X) / sb.AbsoluteSize.X, 0, 1); local nv = minV + relX * range; set(nv); TweenService:Create(fill, TweenInfo.new(0.3), {Size = UDim2.new(relX,0,1,0)}):Play(); TweenService:Create(knob, TweenInfo.new(0.3), {Position = UDim2.new(relX,-5,0,-3)}):Play(); lab.Text = name .. ": " .. math.floor(nv) end
    db.MouseButton1Down:Connect(function() dragging = true end); db.MouseButton1Up:Connect(function() dragging = false end); db.MouseLeave:Connect(function() dragging = false end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then us(i.Position.X) end end)
    db.MouseButton1Click:Connect(function() us(UserInputService:GetMouseLocation().X) end)
end

local function makeButton(name, y, action, color)
    local c1 = getMenuColor(); local f = Instance.new("Frame", scr); f.Size = UDim2.new(0.92,0,0,32); f.Position = UDim2.new(0.04,0,0,y); f.BackgroundColor3 = Color3.fromRGB(0,0,0); f.BackgroundTransparency = 0.8; f.ZIndex = 10; Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local lab = Instance.new("TextLabel", f); lab.Size = UDim2.new(0.45,0,1,0); lab.Position = UDim2.new(0.06,0,0,0); lab.Text = name; lab.TextColor3 = Color3.fromRGB(255,255,255); lab.BackgroundTransparency = 1; lab.Font = Enum.Font.GothamBold; lab.TextSize = 10; lab.TextXAlignment = Enum.TextXAlignment.Left; lab.ZIndex = 11
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0,50,0,22); b.Position = UDim2.new(1,-56,0.5,-11); b.Text = ""; b.BackgroundColor3 = color or c1; b.BackgroundTransparency = 0.5; b.ZIndex = 100; b.AutoButtonColor = false; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    local arrow = Instance.new("TextLabel", b); arrow.Size = UDim2.new(1,0,1,0); arrow.BackgroundTransparency = 1; arrow.Text = "➤"; arrow.TextColor3 = Color3.fromRGB(255,255,255); arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 20; arrow.ZIndex = 101; arrow.TextXAlignment = Enum.TextXAlignment.Center; arrow.TextYAlignment = Enum.TextYAlignment.Center
    b.MouseButton1Click:Connect(action)
end

-- ==================== ЗАПОЛНЕНИЕ КАТЕГОРИЙ ====================
local function fillCat(num)
    clr()
    local y = 8
    if num == 1 then -- RAGE
        makeToggle("God Mode [B]", function() return Settings.GodMode end, function(v) if v ~= Settings.GodMode then toggleGodMode() end end, y); y = y + 34
        makeToggle("Noclip [N]", function() return Settings.Noclip end, function(v) if v ~= Settings.Noclip then toggleNoclip() end end, y); y = y + 34
        makeToggle("Fly [F]", function() return Settings.Fly end, function(v) if v ~= Settings.Fly then toggleFly() end end, y); y = y + 34
        if Settings.Fly then makeSlider("  Fly Speed", function() return Settings.FlySpeed end, function(v) Settings.FlySpeed = v end, 10, 200, y); y = y + 46 end
        makeToggle("Gun Grabber", function() return Settings.GunGrabber end, function(v) Settings.GunGrabber = v; gunButton.Visible = v; gunButton.Position = gunButtonPosition end, y); y = y + 34
        makeToggle("Anti-Knife [K]", function() return Settings.AntiKnife end, function(v) if v ~= Settings.AntiKnife then toggleAntiKnife() end; fillCat(1) end, y); y = y + 34
        if Settings.AntiKnife then makeSlider("  Knife Distance", function() return Settings.AntiKnifeDistance end, function(v) Settings.AntiKnifeDistance = v end, 10, 50, y); y = y + 46 end
        makeToggle("Anti-Fling [G]", function() return Settings.AntiFling end, function(v) if v ~= Settings.AntiFling then toggleAntiFling() end end, y); y = y + 34
        makeToggle("Anti-Lag", function() return Settings.AntiLag end, function(v) if v ~= Settings.AntiLag then toggleAntiLag() end end, y); y = y + 34
        makeToggle("Spinbot", function() return Settings.Spinbot end, function(v) if v ~= Settings.Spinbot then toggleSpinbot() end; fillCat(1) end, y); y = y + 34
        if Settings.Spinbot then makeSlider("  Spin Speed", function() return Settings.SpinSpeed end, function(v) Settings.SpinSpeed = v end, 1, 100, y); y = y + 46 end
        makeToggle("Bunny Hop", function() return Settings.BunnyHop end, function(v) if v ~= Settings.BunnyHop then toggleBunnyHop() end; fillCat(1) end, y); y = y + 34
        if Settings.BunnyHop then makeSlider("  BHOP Multiplier", function() return Settings.BHOPMultiplier end, function(v) Settings.BHOPMultiplier = v end, 1.1, 5, y); y = y + 46; makeSlider("  BHOP Max Speed", function() return Settings.BHOPMaxSpeed end, function(v) Settings.BHOPMaxSpeed = v end, 20, 500, y); y = y + 46 end
        makeButton("💀 KILL ALL", y, killAll, Color3.fromRGB(255, 0, 0)); y = y + 36
        makeButton("💥 MASS FLING", y, massFling, Color3.fromRGB(255, 100, 0)); y = y + 36
        makeButton("🕳️ VOID ALL", y, voidAll, Color3.fromRGB(100, 0, 255)); y = y + 36
    elseif num == 2 then -- MOVEMENT
        makeToggle("Jump Power [J]", function() return Settings.JumpPower end, function(v) if v ~= Settings.JumpPower then toggleJumpPower() end; fillCat(2) end, y); y = y + 34
        if Settings.JumpPower then makeSlider("  Jump Multiplier", function() return Settings.JumpMultiplier end, function(v) Settings.JumpMultiplier = v end, 30, 200, y); y = y + 46 end
        makeToggle("Wall Hop [H]", function() return Settings.WallHop end, function(v) if v ~= Settings.WallHop then toggleWallHop() end end, y); y = y + 34
        makeToggle("Auto Rejoin [R]", function() return Settings.AutoRejoin end, function(v) if v ~= Settings.AutoRejoin then toggleAutoRejoin() end; fillCat(2) end, y); y = y + 34
        if Settings.AutoRejoin then makeSlider("  Rejoin Delay", function() return Settings.RejoinDelay end, function(v) Settings.RejoinDelay = v end, 1, 10, y); y = y + 46 end
        makeToggle("Shift Lock [L]", function() return Settings.ShiftLock end, function(v) if v ~= Settings.ShiftLock then toggleShiftLock() end end, y); y = y + 34
        makeToggle("Remove UI", function() return Settings.RemoveUI end, function(v) if v ~= Settings.RemoveUI then toggleRemoveUI() end end, y); y = y + 34
        makeButton("ТП к Убийце", y, tpToMurderer, Color3.fromRGB(255,50,50)); y = y + 36
        makeButton("ТП к Шерифу", y, tpToSheriff, Color3.fromRGB(0,100,255)); y = y + 36
        makeButton("ТП в Лобби", y, tpToLobby, Color3.fromRGB(255,200,0)); y = y + 36
    elseif num == 3 then -- VISUAL
        makeToggle("ESP", function() return Settings.ESP end, function(v) Settings.ESP = v; fillCat(3) end, y); y = y + 34
        if Settings.ESP then makeToggle("  Box", function() return Settings.ESPBox end, function(v) Settings.ESPBox = v end, y); y = y + 34; makeToggle("  Tracers", function() return Settings.ESPTracer end, function(v) Settings.ESPTracer = v end, y); y = y + 34; makeToggle("  Names", function() return Settings.ESPName end, function(v) Settings.ESPName = v end, y); y = y + 34; makeToggle("  Distance", function() return Settings.ESPDistance end, function(v) Settings.ESPDistance = v end, y); y = y + 34 end
        makeToggle("Sun Chams", function() return Settings.SunChams end, function(v) Settings.SunChams = v; if v then startSunChams() else if chamsFolder then chamsFolder:Destroy() end end end, y); y = y + 34
        makeToggle("Trail", function() return Settings.Trail end, function(v) Settings.Trail = v; fillCat(3) end, y); y = y + 34
        if Settings.Trail then makeSlider("  Trail Duration", function() return Settings.TrailDuration end, function(v) Settings.TrailDuration = v end, 0.3, 3, y); y = y + 46
            local ct = Instance.new("TextLabel", scr); ct.Size = UDim2.new(0.8,0,0,16); ct.Position = UDim2.new(0.1,0,0,y); ct.Text = "  Trail Color:"; ct.TextColor3 = Color3.fromRGB(255,255,255); ct.BackgroundTransparency = 1; ct.Font = Enum.Font.GothamBold; ct.TextSize = 9; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.ZIndex = 10; y = y + 18
            for _, cn in ipairs({"White","Red","Blue","Purple","Cyan","Green","Yellow","Pink"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.TrailColor == cn and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.TrailColor == cn and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", mf); d.Size = UDim2.new(0,12,0,12); d.Position = UDim2.new(0.06,0,0.5,-6); d.BackgroundColor3 = getColorByName(cn); d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.2,0,0,0); lb.Text = cn; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.TrailColor = cn; fillCat(3) end); y = y + 24 end end
        makeToggle("Glow Body", function() return Settings.GlowBody end, function(v) Settings.GlowBody = v; applyGlowBody(); fillCat(3) end, y); y = y + 34
        if Settings.GlowBody then local ct = Instance.new("TextLabel", scr); ct.Size = UDim2.new(0.8,0,0,16); ct.Position = UDim2.new(0.1,0,0,y); ct.Text = "  Glow Color"; ct.TextColor3 = Color3.fromRGB(255,255,255); ct.BackgroundTransparency = 1; ct.Font = Enum.Font.GothamBold; ct.TextSize = 9; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.ZIndex = 10; y = y + 18
            for _, cn in ipairs({"White","Red","Blue","Purple","Cyan","Green"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.GlowColor == cn and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.GlowColor == cn and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", mf); d.Size = UDim2.new(0,12,0,12); d.Position = UDim2.new(0.06,0,0.5,-6); d.BackgroundColor3 = getColorByName(cn); d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.2,0,0,0); lb.Text = cn; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.GlowColor = cn; applyGlowBody(); fillCat(3) end); y = y + 24 end end
        makeToggle("Orbit Orbs", function() return Settings.OrbitOrbs end, function(v) Settings.OrbitOrbs = v; applyOrbitOrbs(); fillCat(3) end, y); y = y + 34
        if Settings.OrbitOrbs then local ct = Instance.new("TextLabel", scr); ct.Size = UDim2.new(0.8,0,0,16); ct.Position = UDim2.new(0.1,0,0,y); ct.Text = "  Orb Color"; ct.TextColor3 = Color3.fromRGB(255,255,255); ct.BackgroundTransparency = 1; ct.Font = Enum.Font.GothamBold; ct.TextSize = 9; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.ZIndex = 10; y = y + 18
            for _, cn in ipairs({"White","Red","Blue","Purple","Cyan","Green"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.OrbColor == cn and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.OrbColor == cn and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", mf); d.Size = UDim2.new(0,12,0,12); d.Position = UDim2.new(0.06,0,0.5,-6); d.BackgroundColor3 = getColorByName(cn); d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.2,0,0,0); lb.Text = cn; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.OrbColor = cn; applyOrbitOrbs(); fillCat(3) end); y = y + 24 end end
        makeToggle("Floating Particles", function() return Settings.FloatingParticles end, function(v) Settings.FloatingParticles = v; fillCat(3) end, y); y = y + 34
        if Settings.FloatingParticles then local ct = Instance.new("TextLabel", scr); ct.Size = UDim2.new(0.8,0,0,16); ct.Position = UDim2.new(0.1,0,0,y); ct.Text = "  Particle Color"; ct.TextColor3 = Color3.fromRGB(255,255,255); ct.BackgroundTransparency = 1; ct.Font = Enum.Font.GothamBold; ct.TextSize = 9; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.ZIndex = 10; y = y + 18
            for _, cn in ipairs({"White","Red","Blue","Purple","Cyan","Green"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.ParticleColor == cn and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.ParticleColor == cn and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", mf); d.Size = UDim2.new(0,12,0,12); d.Position = UDim2.new(0.06,0,0.5,-6); d.BackgroundColor3 = getColorByName(cn); d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.2,0,0,0); lb.Text = cn; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.ParticleColor = cn; fillCat(3) end); y = y + 24 end end
        makeToggle("Fog", function() return Settings.Fog end, function(v) Settings.Fog = v; updateFog(); fillCat(3) end, y); y = y + 34
        if Settings.Fog then makeSlider("  Fog Distance", function() return Settings.FogDistance end, function(v) Settings.FogDistance = v; updateFog() end, 10, 500, y); y = y + 46
            local ct = Instance.new("TextLabel", scr); ct.Size = UDim2.new(0.8,0,0,16); ct.Position = UDim2.new(0.1,0,0,y); ct.Text = "  Fog Color"; ct.TextColor3 = Color3.fromRGB(255,255,255); ct.BackgroundTransparency = 1; ct.Font = Enum.Font.GothamBold; ct.TextSize = 9; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.ZIndex = 10; y = y + 18
            for _, cn in ipairs({"White","Red","Blue","Cyan"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.FogColor == cn and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.FogColor == cn and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", mf); d.Size = UDim2.new(0,12,0,12); d.Position = UDim2.new(0.06,0,0.5,-6); d.BackgroundColor3 = getColorByName(cn); d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.2,0,0,0); lb.Text = cn; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.FogColor = cn; updateFog(); fillCat(3) end); y = y + 24 end end
        local gfxTitle = Instance.new("TextLabel", scr); gfxTitle.Size = UDim2.new(0.9,0,0,18); gfxTitle.Position = UDim2.new(0.05,0,0,y); gfxTitle.Text = "--- Graphics Mode"; gfxTitle.TextColor3 = getMenuColor(); gfxTitle.BackgroundTransparency = 1; gfxTitle.Font = Enum.Font.GothamBlack; gfxTitle.TextSize = 10; gfxTitle.TextXAlignment = Enum.TextXAlignment.Left; gfxTitle.ZIndex = 10; y = y + 20
        for _, mode in ipairs({{"Off","Off"},{"Ultra","Ultra"},{"Dark","Dark"}}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.GraphicsMode == mode[1] and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.GraphicsMode == mode[1] and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.06,0,0,0); lb.Text = mode[2]; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.GraphicsMode = mode[1]; applyGraphicsMode(); fillCat(3) end); y = y + 24 end
        makeToggle("Custom Skybox", function() return Settings.CustomSkybox end, function(v) Settings.CustomSkybox = v; if v then applySkybox(Settings.SkyboxType) else if Lighting:FindFirstChild("CustomSky") then Lighting.CustomSky:Destroy() end end; fillCat(3) end, y); y = y + 34
        if Settings.CustomSkybox then local sl = Instance.new("TextLabel", scr); sl.Size = UDim2.new(0.92,0,0,18); sl.Position = UDim2.new(0.04,0,0,y); sl.Text = "  Выбор неба:"; sl.TextColor3 = Color3.fromRGB(255,255,255); sl.BackgroundTransparency = 1; sl.Font = Enum.Font.GothamBold; sl.TextSize = 10; sl.TextXAlignment = Enum.TextXAlignment.Left; sl.ZIndex = 11; y = y + 22
            local st = {{name="Красный",type="Red",color=Color3.fromRGB(255,50,50)},{name="Фиолетовый",type="Purple",color=Color3.fromRGB(180,50,255)},{name="Синий",type="Blue",color=Color3.fromRGB(50,150,255)},{name="Белый",type="White",color=Color3.fromRGB(255,255,255)}}
            for _, s in ipairs(st) do local sb = Instance.new("Frame", scr); sb.Size = UDim2.new(0.92,0,0,28); sb.Position = UDim2.new(0.04,0,0,y); sb.BackgroundColor3 = Settings.SkyboxType == s.type and s.color or Color3.fromRGB(0,0,0); sb.BackgroundTransparency = Settings.SkyboxType == s.type and 0.4 or 0.8; sb.BorderSizePixel = 0; sb.ZIndex = 10; Instance.new("UICorner", sb).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", sb); d.Size = UDim2.new(0,16,0,16); d.Position = UDim2.new(0,10,0.5,-8); d.BackgroundColor3 = s.color; d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", sb); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0,32,0,0); lb.Text = s.name; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 10; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", sb); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.SkyboxType = s.type; applySkybox(s.type); fillCat(3) end); y = y + 30 end end
        makeToggle("FPS Boost", function() return Settings.FPSBoost end, function(v) Settings.FPSBoost = v end, y); y = y + 34
        makeToggle("FOV", function() return Settings.FOV end, function(v) Settings.FOV = v; camera.FieldOfView = v and Settings.FOVValue or 70; fillCat(3) end, y); y = y + 34
        if Settings.FOV then makeSlider("  FOV Value", function() return Settings.FOVValue end, function(v) Settings.FOVValue = v; camera.FieldOfView = v end, 30, 120, y); y = y + 46 end
    elseif num == 4 then -- AIMBOT
        makeToggle("Aimbot FOV", function() return Settings.Aimbot end, function(v) if v ~= Settings.Aimbot then toggleAimbot() end; fillCat(4) end, y); y = y + 34
        if Settings.Aimbot then makeSlider("  FOV Radius", function() return Settings.AimbotFOV end, function(v) Settings.AimbotFOV = v; if fovCircle then fovCircle.Size = UDim2.new(0, v*2, 0, v*2) end end, 50, 300, y); y = y + 46; makeSlider("  Aim Range", function() return Settings.AimbotRange end, function(v) Settings.AimbotRange = v end, 50, 1000, y); y = y + 46
            local mt = Instance.new("TextLabel", scr); mt.Size = UDim2.new(0.8,0,0,16); mt.Position = UDim2.new(0.1,0,0,y); mt.Text = "  Aim Mode:"; mt.TextColor3 = Color3.fromRGB(255,255,255); mt.BackgroundTransparency = 1; mt.Font = Enum.Font.GothamBold; mt.TextSize = 9; mt.TextXAlignment = Enum.TextXAlignment.Left; mt.ZIndex = 11; y = y + 18
            for _, mode in ipairs({{"Always","Всегда"},{"WeaponOnly","С оружием"}}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.AimbotMode == mode[1] and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.AimbotMode == mode[1] and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.06,0,0,0); lb.Text = mode[2]; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.AimbotMode = mode[1]; fillCat(4) end); y = y + 24 end end
    elseif num == 5 then -- EFFECTS
        makeToggle("Death Effect", function() return Settings.DeathEffect end, function(v) Settings.DeathEffect = v; fillCat(5) end, y); y = y + 34
        if Settings.DeathEffect then local et = Instance.new("TextLabel", scr); et.Size = UDim2.new(0.8,0,0,16); et.Position = UDim2.new(0.1,0,0,y); et.Text = "  Effect Type:"; et.TextColor3 = Color3.fromRGB(255,255,255); et.BackgroundTransparency = 1; et.Font = Enum.Font.GothamBold; et.TextSize = 9; et.TextXAlignment = Enum.TextXAlignment.Left; et.ZIndex = 10; y = y + 18
            for _, eff in ipairs({{"Explosion","Explosion"},{"Disintegrate","Disintegrate"}}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.DeathEffectType == eff[1] and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.DeathEffectType == eff[1] and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.06,0,0,0); lb.Text = eff[2]; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.DeathEffectType = eff[1]; fillCat(5) end); y = y + 24 end
            local ec = Instance.new("TextLabel", scr); ec.Size = UDim2.new(0.8,0,0,16); ec.Position = UDim2.new(0.1,0,0,y); ec.Text = "  Effect Color:"; ec.TextColor3 = Color3.fromRGB(255,255,255); ec.BackgroundTransparency = 1; ec.Font = Enum.Font.GothamBold; ec.TextSize = 9; ec.TextXAlignment = Enum.TextXAlignment.Left; ec.ZIndex = 10; y = y + 18
            for _, cn in ipairs({"Purple","White","Red","Blue","Cyan","Green"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.DeathEffectColor == cn and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.DeathEffectColor == cn and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", mf); d.Size = UDim2.new(0,12,0,12); d.Position = UDim2.new(0.06,0,0.5,-6); d.BackgroundColor3 = getColorByName(cn); d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.2,0,0,0); lb.Text = cn; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.DeathEffectColor = cn; fillCat(5) end); y = y + 24 end
            makeButton("  🧪 Тест эффекта", y, testDeathEffect, Color3.fromRGB(200, 100, 255)); y = y + 36
        end
    elseif num == 6 then -- FARM
        makeToggle("Auto Farm", function() return Settings.AutoFarm end, function(v) if v ~= Settings.AutoFarm then toggleAutoFarm() end; fillCat(6) end, y); y = y + 34
        if Settings.AutoFarm then makeSlider("  Farm Radius", function() return Settings.FarmRadius end, function(v) Settings.FarmRadius = v end, 5, 100, y); y = y + 46; makeSlider("  Farm Delay", function() return Settings.FarmDelay end, function(v) Settings.FarmDelay = v end, 0.1, 2, y); y = y + 46 end
    elseif num == 7 then -- CUSTOM
        makeToggle("Custom Crosshair", function() return Settings.CustomCrosshair end, function(v) Settings.CustomCrosshair = v; updateCustomCrosshair(); fillCat(7) end, y); y = y + 34
        if Settings.CustomCrosshair then makeSlider("  Spin Speed", function() return Settings.CrosshairSpinSpeed end, function(v) Settings.CrosshairSpinSpeed = v end, 0, 20, y); y = y + 46
            local ct = Instance.new("TextLabel", scr); ct.Size = UDim2.new(0.8,0,0,16); ct.Position = UDim2.new(0.1,0,0,y); ct.Text = "  Crosshair Type:"; ct.TextColor3 = Color3.fromRGB(255,255,255); ct.BackgroundTransparency = 1; ct.Font = Enum.Font.GothamBold; ct.TextSize = 9; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.ZIndex = 10; y = y + 18
            for _, tp in ipairs({"Cross","Circle","Dot","Paw"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.CrosshairType == tp and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.CrosshairType == tp and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.06,0,0,0); lb.Text = tp; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.CrosshairType = tp; updateCustomCrosshair(); fillCat(7) end); y = y + 24 end
            makeSlider("  Crosshair Size", function() return Settings.CrosshairSize end, function(v) Settings.CrosshairSize = v; updateCustomCrosshair() end, 10, 50, y); y = y + 46
            local cc = Instance.new("TextLabel", scr); cc.Size = UDim2.new(0.8,0,0,16); cc.Position = UDim2.new(0.1,0,0,y); cc.Text = "  Crosshair Color:"; cc.TextColor3 = Color3.fromRGB(255,255,255); cc.BackgroundTransparency = 1; cc.Font = Enum.Font.GothamBold; cc.TextSize = 9; cc.TextXAlignment = Enum.TextXAlignment.Left; cc.ZIndex = 10; y = y + 18
            for _, cn in ipairs({"Red","White","Blue","Purple","Cyan","Green"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.CrosshairColor == cn and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.CrosshairColor == cn and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", mf); d.Size = UDim2.new(0,12,0,12); d.Position = UDim2.new(0.06,0,0.5,-6); d.BackgroundColor3 = getColorByName(cn); d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.2,0,0,0); lb.Text = cn; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.CrosshairColor = cn; updateCustomCrosshair(); fillCat(7) end); y = y + 24 end end
        makeToggle("Cloud Color", function() return Settings.CloudEnabled end, function(v) Settings.CloudEnabled = v; applyCloudColor(); fillCat(7) end, y); y = y + 34
        if Settings.CloudEnabled then local ct = Instance.new("TextLabel", scr); ct.Size = UDim2.new(0.8,0,0,16); ct.Position = UDim2.new(0.1,0,0,y); ct.Text = "  Cloud Color:"; ct.TextColor3 = Color3.fromRGB(255,255,255); ct.BackgroundTransparency = 1; ct.Font = Enum.Font.GothamBold; ct.TextSize = 9; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.ZIndex = 10; y = y + 18
            for _, cn in ipairs({"White","Red","Blue","Purple","Cyan","Green"}) do local mf = Instance.new("Frame", scr); mf.Size = UDim2.new(0.92,0,0,22); mf.Position = UDim2.new(0.04,0,0,y); mf.BackgroundColor3 = Settings.CloudColor == cn and getMenuColor() or Color3.fromRGB(0,0,0); mf.BackgroundTransparency = Settings.CloudColor == cn and 0.4 or 0.8; mf.BorderSizePixel = 0; mf.ZIndex = 10; Instance.new("UICorner", mf).CornerRadius = UDim.new(0,6); local d = Instance.new("Frame", mf); d.Size = UDim2.new(0,12,0,12); d.Position = UDim2.new(0.06,0,0.5,-6); d.BackgroundColor3 = getColorByName(cn); d.BorderSizePixel = 0; Instance.new("UICorner", d).CornerRadius = UDim.new(1,0); local lb = Instance.new("TextLabel", mf); lb.Size = UDim2.new(0.6,0,1,0); lb.Position = UDim2.new(0.2,0,0,0); lb.Text = cn; lb.TextColor3 = Color3.fromRGB(255,255,255); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.TextSize = 9; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 11; local tb = Instance.new("TextButton", mf); tb.Size = UDim2.new(1,0,1,0); tb.BackgroundTransparency = 1; tb.Text = ""; tb.ZIndex = 100; tb.MouseButton1Click:Connect(function() Settings.CloudColor = cn; applyCloudColor(); fillCat(7) end); y = y + 24 end end
    elseif num == 8 then -- CONFIG
        makeButton("💾 Сохранить", y, function() saveAllSettings(); notify("Настройки сохранены!", "💾") end, Color3.fromRGB(0, 200, 0)); y = y + 36
        makeButton("📂 Загрузить", y, function() loadAllSettings(); applyLoadedSettings() end, Color3.fromRGB(0, 150, 255)); y = y + 36
        makeButton("🗑️ УДАЛИТЬ ЧИТ", y, destroyAll, Color3.fromRGB(255,0,0))
    end
end

local cats = {"RAGE", "MOVE", "VISUAL", "AIMBOT", "EFFECTS", "FARM", "CUSTOM", "CONFIG"}
local btns = {}
for i, name in ipairs(cats) do
    local b = Instance.new("TextButton", left); b.Size = UDim2.new(1,0,0,30); b.Position = UDim2.new(0,0,0,8+(i-1)*34); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(0,0,0); b.BackgroundTransparency = 0.8; b.TextColor3 = Color3.fromRGB(255,255,255); b.Font = Enum.Font.GothamBold; b.TextSize = 8; b.TextXAlignment = Enum.TextXAlignment.Center; b.ZIndex = 10; b.AutoButtonColor = false; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function() for j, bb in ipairs(btns) do local c1 = getMenuColor(); if j == i then TweenService:Create(bb, TweenInfo.new(0.3), {BackgroundColor3 = c1, BackgroundTransparency = 0.5}):Play() else TweenService:Create(bb, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.8}):Play() end end; fillCat(i) end)
    table.insert(btns, b)
end
if btns[1] then btns[1].BackgroundColor3 = getMenuColor(); btns[1].BackgroundTransparency = 0.5 end
fillCat(1)

-- ==================== ГОРЯЧИЕ КЛАВИШИ ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.N then toggleNoclip() end; if input.KeyCode == Enum.KeyCode.B then toggleGodMode() end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end; if input.KeyCode == Enum.KeyCode.G then toggleAntiFling() end
    if input.KeyCode == Enum.KeyCode.J then toggleJumpPower() end; if input.KeyCode == Enum.KeyCode.H then toggleWallHop() end
    if input.KeyCode == Enum.KeyCode.R then toggleAutoRejoin() end; if input.KeyCode == Enum.KeyCode.L then toggleShiftLock() end
    if input.KeyCode == Enum.KeyCode.E and Settings.GunGrabber then grabGun() end
    if input.KeyCode == Enum.KeyCode.K then toggleAntiKnife() end
end)

-- ==================== АВТОЗАГРУЗКА ПРИ ЗАПУСКЕ ====================
spawn(function()
    task.wait(2)
    if loadAllSettings() then
        task.wait(0.5)
        applyLoadedSettings()
    end
end)

-- ==================== ОСНОВНОЙ ЦИКЛ ====================
RunService.RenderStepped:Connect(function(dt)
    if Settings.ESP then updateESP() end
    if Settings.Trail then updateTrails() end
    
    if Settings.CustomCrosshair and crosshairContainer then
        crosshairContainer.Rotation = (crosshairContainer.Rotation + Settings.CrosshairSpinSpeed * 60 * dt) % 360
    end
    
    if Settings.FloatingParticles and tick() - lastParticleSpawn > 0.02 and #Particles < MAX_PARTICLES then lastParticleSpawn = tick(); spawnParticle() end
    for i = #Particles, 1, -1 do local p = Particles[i]; p.Age = p.Age + dt; local dist = p.Pos and (p.Pos - (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.zero)).Magnitude or 0; if p.Age >= p.MaxAge or dist > 75 then p.Part:Destroy(); table.remove(Particles, i) else local ct = tick(); local pw = math.sin(ct*8 + p.Seed); p.Part.Size = Vector3.new(0.45 + pw*0.15, 0.45 + pw*0.15, 0.45 + pw*0.15); p.Pos = p.Pos + p.Vel * dt * 6; p.Part.Position = p.Pos; if p.Age/p.MaxAge > 0.8 then p.Part.Transparency = 0.1 + (1 - (1 - p.Age/p.MaxAge)/0.2) * 0.9 end end end
    if Settings.MenuColor == "Rainbow" and ttl then ttl.TextColor3 = getMenuColor(); scr.ScrollBarImageColor3 = getMenuColor() end
end)

player.CharacterAdded:Connect(function()
    if Settings.Noclip then task.wait(0.3); if noclipConn then noclipConn:Disconnect() end; noclipConn = RunService.Stepped:Connect(function() if Settings.Noclip and player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end
    if Settings.GlowBody then task.wait(0.3); applyGlowBody() end
    if Settings.OrbitOrbs then task.wait(0.3); applyOrbitOrbs() end
end)

trailContainer = Instance.new("Folder", camera); trailContainer.Name = "TrailParts"

end -- Конец loadMainCheat()
