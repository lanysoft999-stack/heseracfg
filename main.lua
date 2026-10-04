-- ═══════════════════════════════════════════════════════════
-- ClumsyScript · v13.0 · Softer menu pattern + animated launch dots
-- ═══════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")
local Lighting         = game:GetService("Lighting")
local RSvc             = game:GetService("ReplicatedStorage")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local ContentProvider  = game:GetService("ContentProvider")
local CollectionService= game:GetService("CollectionService")
local VirtualUser      = game:GetService("VirtualUser")
local LP               = Players.LocalPlayer
local WS               = workspace

local function safeParent(gui)
    if type(gethui)=="function" then local ok,h=pcall(gethui) if ok and h then local o=pcall(function() gui.Parent=h end) if o and gui.Parent then return true end end end
    local pg=LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui",5)
    if pg then local o=pcall(function() gui.Parent=pg end) if o and gui.Parent then return true end end
    local ok,cg=pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then pcall(function() gui.Parent=cg end) end
    return gui.Parent~=nil
end
local function safeDestruct(gui) if gui and gui.Parent then pcall(function() gui:Destroy() end) end end

-- ═══════════════════════════════════════════════════════════
-- CLEANUP PREVIOUS ClumsyScript INSTANCE
-- Prevents duplicate menu / key / loading overlays after re-execution.
-- ═══════════════════════════════════════════════════════════
pcall(function()
    local cg = game:GetService("CoreGui")
    local containers = {cg, LP:FindFirstChild("PlayerGui")}
    for _, parent in ipairs(containers) do
        if parent then
            for _, name in ipairs({
                "ClumsyScript_UI",
                "ClumsyScript_WM",
                "ClumsyTargetButtons",
                "ClumsyFlyJoystick",
                "CH_EscapeIndicator",
                "ClumsyKey_UI",
                "ClumsyLoading_UI",
            }) do
                local old = parent:FindFirstChild(name)
                if old then pcall(function() old:Destroy() end) end
            end
        end
    end
    local oldBlur = Lighting:FindFirstChild("ClumsyLoadingBlur")
    if oldBlur then pcall(function() oldBlur:Destroy() end) end
end)

local VALID_KEYS={ ["@clumsy_cfg"]=true }

local COLOR={
    Bg=Color3.fromRGB(10,10,14), Sidebar=Color3.fromRGB(15,15,20),
    Element=Color3.fromRGB(20,20,28), TabActive=Color3.fromRGB(245,245,245),
    Stroke=Color3.fromRGB(25,25,35), TextMain=Color3.fromRGB(220,220,235),
    TextDim=Color3.fromRGB(120,120,145), TextSection=Color3.fromRGB(70,70,90),
    Accent=Color3.fromRGB(245,245,245), ToggleOff=Color3.fromRGB(35,35,48),
    IconDim=Color3.fromRGB(145,145,145), Error=Color3.fromRGB(245,245,245),
    Success=Color3.fromRGB(245,245,245), Sub=Color3.fromRGB(13,13,18),
}
local CURRENT_ACCENT=COLOR.Accent
-- Monochrome UI: accent is fixed to white; feature-specific effect colors remain independent.
local function noLoc(o) o.AutoLocalize=false return o end

local ICONS={
    logo="rbxassetid://108364111226307", btnLogo="rbxassetid://119392298853999",
    user="rbxassetid://113699377229196", crosshair="rbxassetid://109570069910196",
    eye="rbxassetid://91330131399980", settings="rbxassetid://83630688422081",
    globe="rbxassetid://73228387461668", key="rbxassetid://111503992443665",
    lock="rbxassetid://132729522166336", crown="rbxassetid://121985239923602",
    footprints="rbxassetid://87820687046112", wind="rbxassetid://77522182929041",
    shield="rbxassetid://84540046985424", sparkles="rbxassetid://125849463882635",
    palette="rbxassetid://79736533371549", sun="rbxassetid://122928822578220",
    sword="rbxassetid://108364111226307", ghost="rbxassetid://78863109643720",
    target="rbxassetid://99437299419252", rocket="rbxassetid://89262800617021",
    bot="rbxassetid://77404643876794", zap="rbxassetid://135999726746835",
    download="rbxassetid://136358288949757", cloud="rbxassetid://121616537598596",
}

-- Custom ClumsyScript logo · rounded lowercase "m" based on the supplied reference.
-- Built from overlapping rounded capsules so the silhouette stays consistent at 16/28px.
local function makeMLogo(parent, size, pos, color)
    local holder=Instance.new("Frame")
    holder.Name="ClumsyMLogo"
    holder.Size=UDim2.new(0,size,0,size)
    holder.Position=pos
    holder.BackgroundTransparency=1
    holder.BorderSizePixel=0
    holder.Parent=parent

    local c=color or Color3.new(1,1,1)
    local thickness=math.max(2,math.floor(size*0.12))

    local function capsule(ax,ay,bx,by,extra)
        local dx=(bx-ax)*size
        local dy=(by-ay)*size
        local length=math.max(2,math.sqrt(dx*dx+dy*dy)+(extra or 0))
        local midX=(ax+bx)*0.5
        local midY=(ay+by)*0.5

        local part=Instance.new("Frame")
        part.Name="RoundedStroke"
        part.AnchorPoint=Vector2.new(0.5,0.5)
        part.Size=UDim2.new(0,thickness,0,length)
        part.Position=UDim2.new(midX,0,midY,0)
        part.Rotation=math.deg(math.atan2(dy,dx))-90
        part.BackgroundColor3=c
        part.BorderSizePixel=0
        part.ZIndex=holder.ZIndex+1
        part.Parent=holder

        local corner=Instance.new("UICorner")
        corner.CornerRadius=UDim.new(1,0)
        corner.Parent=part
        return part
    end

    -- Same flowing silhouette as the reference: tall left stroke,
    -- deep first valley, rounded second hump and a raised rounded tail.
    capsule(0.18,0.80,0.25,0.18,2)
    capsule(0.25,0.18,0.40,0.80,2)
    capsule(0.40,0.80,0.44,0.45,2)
    capsule(0.44,0.45,0.54,0.36,2)
    capsule(0.54,0.36,0.69,0.80,2)
    capsule(0.69,0.80,0.72,0.54,2)
    capsule(0.72,0.54,0.78,0.47,2)
    capsule(0.78,0.47,0.84,0.50,2)
    capsule(0.84,0.50,0.83,0.64,2)

    return holder
end

-- Expanded function-color palette. Every function that uses COLOR_NAMES
-- now gets the full palette below instead of only the old four colors.
local COLOR_NAMES={
    "Orange","Red","White","Purple","Blue",
    "Green","Yellow","Cyan","Pink","Lime","Sky Blue","Black"
}
local COLOR_VALUES={
    Color3.fromRGB(255,140,0),   -- Orange
    Color3.fromRGB(235,60,70),   -- Red
    Color3.fromRGB(255,255,255), -- White
    Color3.fromRGB(170,80,255),  -- Purple
    Color3.fromRGB(70,140,255),  -- Blue
    Color3.fromRGB(70,210,120),  -- Green
    Color3.fromRGB(255,220,60),  -- Yellow
    Color3.fromRGB(60,220,220),  -- Cyan
    Color3.fromRGB(255,105,180), -- Pink
    Color3.fromRGB(150,255,70),  -- Lime
    Color3.fromRGB(80,190,255),  -- Sky Blue
    Color3.fromRGB(20,20,24),    -- Black
}
local SNOW_NAMES=COLOR_NAMES
local SNOW_VALUES=COLOR_VALUES
local TRACER_NAMES=COLOR_NAMES
local TRACER_VALUES=COLOR_VALUES
local TRAIL_NAMES=COLOR_NAMES
local TRAIL_VALUES=COLOR_VALUES
local DEATHFX_NAMES=COLOR_NAMES
local DEATHFX_VALUES=COLOR_VALUES
local DEATHFX_TARGETS={"Murderer only","All except me","Everyone"}
local SKELETON_MODES={"Role-based","Single color"}
local SKYBOX_PRESETS={"Purple Nebula","Red Night","Galaxy","Blossom","Jungle","Foggy","Sunset","Starry Night"}
local FOG_NAMES=COLOR_NAMES
local ESP_CLICK_MODES={"TP","Fling","None"}
local XHAIR_MODES={"Static","Rotating","Bent","Nemzz Bent","Rotating X"}
local AURA_TYPES={"Angel","Heavenly","Достоинство"}

local SKYBOXES={
[1]={name="Purple Nebula",SkyboxBk="rbxassetid://13694952867",SkyboxDn="rbxassetid://13694968325",SkyboxFt="rbxassetid://13694980654",SkyboxLf="rbxassetid://13694998113",SkyboxRt="rbxassetid://13695002700",SkyboxUp="rbxassetid://13695007103",StarCount=3000,CelestialBodiesShown=false},
[2]={name="Red Night",SkyboxBk="rbxassetid://401664839",SkyboxDn="rbxassetid://401664862",SkyboxFt="rbxassetid://401664960",SkyboxLf="rbxassetid://401664881",SkyboxRt="rbxassetid://401664901",SkyboxUp="rbxassetid://401664936",StarCount=3000,CelestialBodiesShown=false},
[3]={name="Galaxy",SkyboxBk="rbxassetid://159454299",SkyboxDn="rbxassetid://159454296",SkyboxFt="rbxassetid://159454293",SkyboxLf="rbxassetid://159454286",SkyboxRt="rbxassetid://159454300",SkyboxUp="rbxassetid://159454288",StarCount=5000,CelestialBodiesShown=false},
[4]={name="Blossom",SkyboxBk="rbxassetid://271042516",SkyboxDn="rbxassetid://271077243",SkyboxFt="rbxassetid://271042556",SkyboxLf="rbxassetid://271042310",SkyboxRt="rbxassetid://271042467",SkyboxUp="rbxassetid://271077958",StarCount=3000,CelestialBodiesShown=false},
[5]={name="Jungle",SkyboxBk="rbxassetid://214399891",SkyboxDn="rbxassetid://214399887",SkyboxFt="rbxassetid://214399894",SkyboxLf="rbxassetid://214405668",SkyboxRt="rbxassetid://214399899",SkyboxUp="rbxassetid://214399889",StarCount=3000,CelestialBodiesShown=false},
[6]={name="Foggy",SkyboxBk="rbxassetid://1370717244",SkyboxDn="rbxassetid://1370717336",SkyboxFt="rbxassetid://1370717438",SkyboxLf="rbxassetid://1370717567",SkyboxRt="rbxassetid://1370717698",SkyboxUp="rbxassetid://1370717782",StarCount=1000,CelestialBodiesShown=false},
[7]={name="Sunset",SkyboxBk="rbxassetid://600830446",SkyboxDn="rbxassetid://600831635",SkyboxFt="rbxassetid://600830446",SkyboxLf="rbxassetid://600830446",SkyboxRt="rbxassetid://600830446",SkyboxUp="rbxassetid://600831635",StarCount=2000,CelestialBodiesShown=false},
[8]={name="Starry Night",SkyboxBk="rbxassetid://12064107",SkyboxDn="rbxassetid://12064152",SkyboxFt="rbxassetid://12064121",SkyboxLf="rbxassetid://12063984",SkyboxRt="rbxassetid://12064115",SkyboxUp="rbxassetid://12064145",StarCount=8000,CelestialBodiesShown=false},
}
local FOG_COLORS=COLOR_VALUES
local ORIG_LIGHT={FogColor=Lighting.FogColor,FogStart=Lighting.FogStart,FogEnd=Lighting.FogEnd,Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,GlobalShadows=Lighting.GlobalShadows,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,ExposureCompensation=Lighting.ExposureCompensation}
local ORIG_ATMOSPHERES={}
pcall(function()
    for _,obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Atmosphere") then
            ORIG_ATMOSPHERES[obj]={Density=obj.Density,Offset=obj.Offset,Color=obj.Color,Decay=obj.Decay,Glare=obj.Glare,Haze=obj.Haze,Enabled=obj.Enabled}
        end
    end
end)

Conns={}
local function track(c) Conns[#Conns+1]=c return c end

local function my_hrp() local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function my_hum() local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function get_hrp(p) local c=p and p.Character return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")) end
local function get_hum(p) local c=p and p.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function alive(p) local h=get_hum(p) return h and h.Health>0 end
local function dist(a,b) return (a-b).Magnitude end
local function flat_dist(a,b) return Vector3.new(a.X-b.X,0,a.Z-b.Z).Magnitude end

local GUN_KW={"gun","revolver","pistol","sheriff"} KNIFE_KW={"knife","нож"}
local function hasTool(c,kws)
    if not c then return false end
    for _,item in ipairs(c:GetChildren()) do
        if item:IsA("Tool") then local n=string.lower(item.Name) for _,kw in ipairs(kws) do if n:find(kw,1,true) then return true end end end
    end
    return false
end
local function hasGun() if not LP.Character then return false end local bp=LP:FindFirstChild("Backpack") return hasTool(LP.Character,GUN_KW) or hasTool(bp,GUN_KW) end
local function hasKnife() if not LP.Character then return false end local bp=LP:FindFirstChild("Backpack") return hasTool(LP.Character,KNIFE_KW) or hasTool(bp,KNIFE_KW) end
local function getGun()
    local c=LP.Character if not c then return nil end
    local t=c:FindFirstChildOfClass("Tool")
    if t then local n=string.lower(t.Name) if n:find("gun",1,true) or n:find("pistol",1,true) or n:find("revolver",1,true) then return t end end
    local bp=LP:FindFirstChild("Backpack")
    if bp then for _,item in ipairs(bp:GetChildren()) do if item:IsA("Tool") then local n=string.lower(item.Name) if n:find("gun",1,true) or n:find("pistol",1,true) or n:find("revolver",1,true) then return item end end end end
end
local function getKnife()
    local c=LP.Character if not c then return nil end
    local t=c:FindFirstChildOfClass("Tool") if t and t.Name=="Knife" then return t end
    local bp=LP:FindFirstChildOfClass("Backpack") if bp then return bp:FindFirstChild("Knife") end
end

roundMod=nil
local function getRoundData()
    if not roundMod then local ok,m=pcall(function() return require(RSvc:WaitForChild("Modules"):WaitForChild("CurrentRoundClient")) end) if ok and type(m)=="table" then roundMod=m end end
    return roundMod and roundMod.PlayerData
end
local function getMurdererFromRound()
    local d=getRoundData() if type(d)~="table" then return nil end
    for n,i in pairs(d) do if type(i)=="table" and i.Role=="Murderer" and not i.Dead then local p=Players:FindFirstChild(n) if p and p~=LP then return p end end end
end
local function getSheriffFromRound()
    local d=getRoundData() if type(d)~="table" then return nil end
    for n,i in pairs(d) do if type(i)=="table" and (i.Role=="Sheriff" or i.Role=="Hero") and not i.Dead then local p=Players:FindFirstChild(n) if p and p~=LP then return p end end end
end
local function playerRole(p)
    if p==LP then if hasKnife() then return "murderer" end if hasGun() then return "sheriff" end return "innocent" end
    local d=getRoundData()
    if type(d)=="table" then local i=d[p.Name] if i and not i.Dead then if i.Role=="Murderer" then return "murderer" end if i.Role=="Sheriff" or i.Role=="Hero" then return "sheriff" end end end
    local c=p.Character local bp=p:FindFirstChild("Backpack")
    if hasTool(c,KNIFE_KW) or hasTool(bp,KNIFE_KW) then return "murderer" end
    if hasTool(c,GUN_KW) or hasTool(bp,GUN_KW) then return "sheriff" end
    return "innocent"
end
local function roleColorOf(r)
    if r=="murderer" then return Color3.fromRGB(255,140,0) end
    if r=="sheriff" then return Color3.fromRGB(100,180,255) end
    return Color3.fromRGB(245,245,245)
end

-- ═══════════════════ CONFIG ═══════════════════
local CFG={
    Speed=false, SpeedValue=45, JumpPower=false, JumpPowerValue=100,
    Noclip=false, Bhop=false, InfJump=false,
    Aspect=false, AspectV=100, AspectH=100, FOV=false, FOVValue=90,
    FlyJoystick=false, FlySpeed=60, FlyNoclip=true, FlyGod=true,
    GodMode=false,
    FakeKorblox=false, FakeHeadless=false,
    KillAura=false, KillAuraRange=30, KillAuraDelay=50,
    Spinbot=false, SpinbotSpeed=45,
    SilentAim=false, SilentPredict=true, SilentForce=true, SilentAutoShoot=false, SilentAutoDelay=150,
    KnifeSilent=false, KnifePredict=true, KnifeInstaKill=false,
    KnifeLeadScale=100, KnifeAirScale=35, KnifeLeadAdd=0,
    KnifeThrowSpeed=96, KnifeImpactRadius=12, KnifeRange=400,
    WallShot=false, WallShotRange=200,
    AutoGun=false, AutoGunRange=800,
    FlingMurder=false, FlingSheriff=false, FlingTool=false,
    ESP=false, ESPBox=true, ESPName=true, ESPDist=true, ESPAvatar=true, ESPDistanceMax=500, ESPClickAction=1,
    Skeleton=false, SkeletonColorMode=1, SkeletonCol=1,
    GunESP=false, GunESPHL=true, GunESPText=true, GunESPCol=1,
    Crosshair=false, CrosshairMode=1, CrosshairSize=12, CrosshairGap=4,
    CrosshairThickness=1, CrosshairRotSpeed=90, CrosshairColor=1, CrosshairShowOutline=true,
    ChinaHat=false, ChinaHatColor=1, ChinaHatHeight=0.6, ChinaHatRadius=1.0,
    TungTungSahur=false, TungTungSahurSize=100,
    RoleChams=false, RoleChamsFill=0.5, RoleChamsMode=1,
    Ghost=false, GhostColor=1, GhostTransparency=0.55,
    Aura=false, AuraType=1, AuraColor=1,
    Backtrack=false, BacktrackDelay=0, BacktrackColor=1,
    Fullbright=false, TimeChanger=false, TimeValue=12,
    Fog=false, FogDistance=500, FogColor=1, Skybox=false, SkyboxName=1,
    BulletTracer=false, TracerColor=1, TracerDuration=4,
    Trails=false, TrailColor=1, Snowfall=false, SnowColor=1,
    JumpRing=false, JumpRingColor=1, JumpRingSize=5,
    ShotSound=false, ShotSoundVolume=3, KillSound=false, KillSoundVolume=3,
    DeathFx=false, DeathFxClone=true, DeathFxParticle=true, DeathFxEmitter=true,
    DeathFxColor=1, DeathFxDuration=1.2, DeathFxTarget=3, DeathFxThroughWalls=false,
    AntiAfk=true, AntiFling=true, AntiVoid=false, AntiVoidY=-80,
    AntiCoin=true, AntiTrap=false,
    FakePos=false, FakePosRange=9, VelSpoof=false, VelSpoofMode=1,
    InstantPrompt=false,
    Spectate=false, LoopTP=false, TPOffsetX=0, TPOffsetY=0, TPOffsetZ=0, TPTool=false, TargetButtons=false, TargetButtonWidth=154, TargetButtonHeight=34,
    AutoFarmCoins=false, AutoFarmSpeed=25, AutoFarmDepth=14, AutoFarmRiseXZ=4, AutoFarmCollect=false, AutoFarmAutoReset=false,
    AutoEscape=false, AutoEscapeDist=15, AutoEscapeReturn=25,
}
getgenv().ClumsyCFG=CFG

-- ═══════════════════ UI SHELL ═══════════════════
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="ClumsyScript_UI" ScreenGui.ResetOnSpawn=false ScreenGui.IgnoreGuiInset=true
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling safeParent(ScreenGui)

-- Hard guarantee: legacy upper-right controls cannot survive re-execution.
local pCallRemoved = nil

local WmGui=Instance.new("ScreenGui")
WmGui.Name="ClumsyScript_WM" WmGui.ResetOnSpawn=false WmGui.IgnoreGuiInset=true WmGui.DisplayOrder=999
safeParent(WmGui)

-- ═══════════════════ WATERMARK ═══════════════════
-- Restored compact watermark. Ping is intentionally omitted; separators use "|".
local WatermarkFrame=Instance.new("Frame")
WatermarkFrame.Name="ClumsyWatermark"
WatermarkFrame.Size=UDim2.new(0,240,0,24)
WatermarkFrame.AnchorPoint=Vector2.new(1,0)
WatermarkFrame.Position=UDim2.new(1,-12,0,10)
WatermarkFrame.BackgroundColor3=Color3.fromRGB(0,0,0)
WatermarkFrame.BackgroundTransparency=0.25
WatermarkFrame.BorderSizePixel=0
WatermarkFrame.Parent=WmGui
Instance.new("UICorner",WatermarkFrame).CornerRadius=UDim.new(0,6)
local WmStroke=Instance.new("UIStroke",WatermarkFrame)
WmStroke.Color=Color3.fromRGB(30,30,40)
WmStroke.Thickness=1

local WmLogo=makeMLogo(WatermarkFrame,16,UDim2.new(0,5,0.5,-8),CURRENT_ACCENT)

local WmTitle=noLoc(Instance.new("TextLabel",WatermarkFrame))
WmTitle.Size=UDim2.new(0,78,0,14)
WmTitle.Position=UDim2.new(0,22,0.5,-7)
WmTitle.BackgroundTransparency=1
WmTitle.Text="ClumsyScript"
WmTitle.TextColor3=Color3.fromRGB(220,220,235)
WmTitle.TextSize=10
WmTitle.Font=Enum.Font.GothamBold
WmTitle.TextXAlignment=Enum.TextXAlignment.Left

local WmSep1=noLoc(Instance.new("TextLabel",WatermarkFrame))
WmSep1.Size=UDim2.new(0,8,0,14)
WmSep1.Position=UDim2.new(0,102,0.5,-7)
WmSep1.BackgroundTransparency=1
WmSep1.Text="|"
WmSep1.TextColor3=Color3.fromRGB(100,100,115)
WmSep1.TextSize=10
WmSep1.Font=Enum.Font.GothamBold

local WmFpsIcon=Instance.new("ImageLabel",WatermarkFrame)
WmFpsIcon.Size=UDim2.new(0,11,0,11)
WmFpsIcon.Position=UDim2.new(0,112,0.5,-5.5)
WmFpsIcon.BackgroundTransparency=1
WmFpsIcon.Image=ICONS.zap
WmFpsIcon.ImageColor3=CURRENT_ACCENT
WmFpsIcon.ScaleType=Enum.ScaleType.Fit

local WmFps=noLoc(Instance.new("TextLabel",WatermarkFrame))
WmFps.Size=UDim2.new(0,42,0,14)
WmFps.Position=UDim2.new(0,126,0.5,-7)
WmFps.BackgroundTransparency=1
WmFps.Text="60FPS"
WmFps.TextColor3=CURRENT_ACCENT
WmFps.TextSize=9
WmFps.Font=Enum.Font.GothamBold
WmFps.TextXAlignment=Enum.TextXAlignment.Left

local WmSep2=noLoc(Instance.new("TextLabel",WatermarkFrame))
WmSep2.Size=UDim2.new(0,8,0,14)
WmSep2.Position=UDim2.new(0,169,0.5,-7)
WmSep2.BackgroundTransparency=1
WmSep2.Text="|"
WmSep2.TextColor3=Color3.fromRGB(100,100,115)
WmSep2.TextSize=10
WmSep2.Font=Enum.Font.GothamBold

local WmPlayersIcon=Instance.new("ImageLabel",WatermarkFrame)
WmPlayersIcon.Size=UDim2.new(0,11,0,11)
WmPlayersIcon.Position=UDim2.new(0,180,0.5,-5.5)
WmPlayersIcon.BackgroundTransparency=1
WmPlayersIcon.Image=ICONS.user
WmPlayersIcon.ImageColor3=CURRENT_ACCENT
WmPlayersIcon.ScaleType=Enum.ScaleType.Fit

local WmPlayers=noLoc(Instance.new("TextLabel",WatermarkFrame))
WmPlayers.Size=UDim2.new(0,42,0,14)
WmPlayers.Position=UDim2.new(0,194,0.5,-7)
WmPlayers.BackgroundTransparency=1
WmPlayers.Text="0/0"
WmPlayers.TextColor3=CURRENT_ACCENT
WmPlayers.TextSize=9
WmPlayers.Font=Enum.Font.GothamBold
WmPlayers.TextXAlignment=Enum.TextXAlignment.Left

local fps,fCount,fTime=60,0,0
RunService.RenderStepped:Connect(function(dt)
    fCount=fCount+1
    fTime=fTime+dt
    if fTime>=1 then fps=fCount fCount=0 fTime=0 end
    if WmFps and WmFps.Parent then WmFps.Text=tostring(fps).."FPS" end
end)

task.spawn(function()
    while WmPlayers and WmPlayers.Parent do
        local count=#Players:GetPlayers()
        WmPlayers.Text=tostring(count).."/"..tostring(Players.MaxPlayers)
        task.wait(0.5)
    end
end)

local ButtonGui=Instance.new("ScreenGui")
ButtonGui.Name="ClumsyScript_BTN"
ButtonGui.ResetOnSpawn=false
ButtonGui.IgnoreGuiInset=true
ButtonGui.DisplayOrder=998
ButtonGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
safeParent(ButtonGui)
ButtonGui.Enabled=false

local AccordionButton=Instance.new("ImageButton")
AccordionButton.Name="ClumsyMenuButton"
AccordionButton.Size=UDim2.new(0,52,0,52)
AccordionButton.Position=UDim2.new(0,15,0.4,0)
AccordionButton.BackgroundColor3=Color3.fromRGB(8,8,10)
AccordionButton.AutoButtonColor=false
AccordionButton.Active=true
AccordionButton.Parent=ButtonGui
Instance.new("UICorner",AccordionButton).CornerRadius=UDim.new(1,0)
local AccStroke=Instance.new("UIStroke",AccordionButton)
AccStroke.Color=Color3.fromRGB(35,55,55)
AccStroke.Thickness=3.5
AccStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local AccLogo=makeMLogo(AccordionButton,28,UDim2.new(0.5,-14,0.5,-14),Color3.new(1,1,1))

AccordionButton.MouseEnter:Connect(function()
    TweenService:Create(AccordionButton,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(20,20,28)}):Play()
    TweenService:Create(AccStroke,TweenInfo.new(0.15),{Color=CURRENT_ACCENT}):Play()
end)
AccordionButton.MouseLeave:Connect(function()
    TweenService:Create(AccordionButton,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(8,8,10)}):Play()
    TweenService:Create(AccStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(35,55,55)}):Play()
end)

local btnDrag=false
local btnMoved=false
local btnInput=nil
local btnStart=Vector2.zero
local btnOrigin=Vector2.zero
local btnClickThreshold=8

AccordionButton.InputBegan:Connect(function(input)
    local t=input.UserInputType
    if t~=Enum.UserInputType.MouseButton1 and t~=Enum.UserInputType.Touch then return end
    -- Multitouch protection: while one finger owns the button, every other touch is ignored.
    if btnDrag or btnInput~=nil then return end
    btnDrag=true
    btnMoved=false
    btnInput=input
    btnStart=Vector2.new(input.Position.X,input.Position.Y)
    local ap=AccordionButton.AbsolutePosition
    btnOrigin=Vector2.new(ap.X,ap.Y)
end)

UserInputService.InputChanged:Connect(function(input)
    if not btnDrag or not btnInput then return end
    local inputType=input.UserInputType
    if inputType==Enum.UserInputType.Touch then
        -- IMPORTANT: never use a second finger to move the button.
        if input~=btnInput then return end
    elseif inputType~=Enum.UserInputType.MouseMovement then
        return
    end
    local pos=Vector2.new(input.Position.X,input.Position.Y)
    local delta=pos-btnStart
    if delta.Magnitude>btnClickThreshold then btnMoved=true end
    if not btnMoved then return end
    local viewport=WS.CurrentCamera and WS.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
    local size=AccordionButton.AbsoluteSize
    local x=math.clamp(btnOrigin.X+delta.X,0,math.max(0,viewport.X-size.X))
    local y=math.clamp(btnOrigin.Y+delta.Y,0,math.max(0,viewport.Y-size.Y))
    AccordionButton.Position=UDim2.fromOffset(x,y)
end)

UserInputService.InputEnded:Connect(function(input)
    if not btnInput then return end
    if input==btnInput or (btnInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1) then
        btnDrag=false
        btnInput=nil
    end
end)

local MainFrame=Instance.new("Frame")
MainFrame.Size=UDim2.new(0,540,0,355) MainFrame.AnchorPoint=Vector2.new(0.5,0.5) MainFrame.Position=UDim2.new(0.5,0,0.5,0)
MainFrame.BackgroundColor3=COLOR.Bg MainFrame.BackgroundTransparency=0.08 MainFrame.BorderSizePixel=0
MainFrame.Active=true MainFrame.Visible=false MainFrame.Parent=ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",MainFrame).Color=COLOR.Stroke

-- Subtle white geometric background pattern. Decorative only; never captures input.
do
    local Pattern=Instance.new("Frame")
    Pattern.Name="ClumsyBackgroundPattern"
    Pattern.BackgroundTransparency=1
    Pattern.BorderSizePixel=0
    Pattern.Size=UDim2.fromScale(1,1)
    Pattern.Position=UDim2.fromScale(0,0)
    Pattern.ZIndex=1
    Pattern.ClipsDescendants=true
    Pattern.Active=false
    Pattern.Selectable=false
    Pattern.Parent=MainFrame

    local function diamond(x,y,size,alpha)
        local holder=Instance.new("Frame")
        holder.Name="PatternDiamond"
        holder.Size=UDim2.fromOffset(size,size)
        holder.Position=UDim2.new(x,0,y,0)
        holder.AnchorPoint=Vector2.new(0.5,0.5)
        holder.BackgroundTransparency=1
        holder.BorderSizePixel=0
        holder.Rotation=45
        holder.ZIndex=1
        holder.Active=false
        holder.Selectable=false
        holder.Parent=Pattern

        local stroke=Instance.new("UIStroke")
        stroke.Color=Color3.fromRGB(255,255,255)
        stroke.Transparency=alpha
        stroke.Thickness=1
        stroke.Parent=holder
    end

    -- More visible white geometric texture: layered diamonds, rings, lines and dots.
    -- Still decorative only, but now clearly visible against the dark menu.
    diamond(0.10,0.12,112,0.93)
    diamond(0.30,0.05,54,0.95)
    diamond(0.50,0.15,86,0.94)
    diamond(0.76,0.13,150,0.92)
    diamond(0.96,0.10,72,0.94)
    diamond(0.15,0.38,72,0.95)
    diamond(0.40,0.35,126,0.93)
    diamond(0.65,0.40,68,0.95)
    diamond(0.87,0.36,112,0.93)
    diamond(0.08,0.66,138,0.93)
    diamond(0.30,0.57,62,0.95)
    diamond(0.54,0.64,108,0.93)
    diamond(0.78,0.60,76,0.94)
    diamond(0.96,0.68,128,0.93)
    diamond(0.20,0.91,94,0.93)
    diamond(0.46,0.90,64,0.95)
    diamond(0.70,0.88,142,0.93)
    diamond(0.92,0.92,66,0.95)

    local function ring(x,y,size,alpha)
        local r=Instance.new("Frame")
        r.Name="PatternRing"
        r.Size=UDim2.fromOffset(size,size)
        r.Position=UDim2.new(x,0,y,0)
        r.AnchorPoint=Vector2.new(0.5,0.5)
        r.BackgroundTransparency=1
        r.BorderSizePixel=0
        r.ZIndex=1
        r.Active=false
        r.Selectable=false
        r.Parent=Pattern
        local corner=Instance.new("UICorner")
        corner.CornerRadius=UDim.new(1,0)
        corner.Parent=r
        local stroke=Instance.new("UIStroke")
        stroke.Color=Color3.fromRGB(255,255,255)
        stroke.Transparency=alpha
        stroke.Thickness=1
        stroke.Parent=r
    end

    ring(0.58,0.20,46,0.93)
    ring(0.88,0.23,70,0.94)
    ring(0.12,0.52,40,0.93)
    ring(0.36,0.48,28,0.95)
    ring(0.61,0.52,58,0.93)
    ring(0.84,0.51,34,0.95)
    ring(0.15,0.78,52,0.93)
    ring(0.49,0.76,30,0.94)
    ring(0.79,0.78,64,0.93)

    -- More thin diagonal accents create the requested layered pattern.
    for i=0,10 do
        local line=Instance.new("Frame")
        line.Name="PatternLine"
        line.Size=UDim2.new(0,150+(i%3)*35,0,1)
        line.Position=UDim2.new(-0.16+i*0.12,0,0.04+i*0.095,0)
        line.BackgroundColor3=Color3.fromRGB(255,255,255)
        line.BackgroundTransparency=0.94
        line.BorderSizePixel=0
        line.Rotation=-24
        line.ZIndex=1
        line.Active=false
        line.Selectable=false
        line.Parent=Pattern
    end

    -- Small white points add a subtle dotted layer without becoming distracting.
    for i=1,42 do
        local dot=Instance.new("Frame")
        dot.Name="PatternDot"
        dot.Size=UDim2.fromOffset(i%4==0 and 4 or (i%2==0 and 3 or 2),i%4==0 and 4 or (i%2==0 and 3 or 2))
        dot.Position=UDim2.new(((i*37)%100)/100,0,((i*61)%100)/100,0)
        dot.AnchorPoint=Vector2.new(0.5,0.5)
        dot.BackgroundColor3=Color3.fromRGB(255,255,255)
        dot.BackgroundTransparency=0.88
        dot.BorderSizePixel=0
        dot.ZIndex=1
        dot.Active=false
        dot.Selectable=false
        dot.Parent=Pattern
        local dc=Instance.new("UICorner")
        dc.CornerRadius=UDim.new(1,0)
        dc.Parent=dot
    end
end

local MenuScale=Instance.new("UIScale",MainFrame) MenuScale.Scale=0.84

local menuUnlocked=false

local dragging,dragStart,dragOffset=false,nil,nil
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
    if not MainFrame.Visible then return end
    local pos=input.Position
    local fp,fs=MainFrame.AbsolutePosition,MainFrame.AbsoluteSize
    local function insideTopButton(name)
        local b=MainFrame:FindFirstChild(name)
        if not b then return false end
        local bp,bs=b.AbsolutePosition,b.AbsoluteSize
        return pos.X>=bp.X and pos.X<=bp.X+bs.X and pos.Y>=bp.Y and pos.Y<=bp.Y+bs.Y
    end
    if insideTopButton("ConfigsButton") or insideTopButton("ConfigsList") or insideTopButton("MenuMoveHandle") or insideTopButton("MenuResizeHandle") then return end
    if pos.X>=fp.X and pos.X<=fp.X+fs.X and pos.Y>=fp.Y and pos.Y<=fp.Y+42 then
        dragging=true dragStart=Vector2.new(pos.X,pos.Y) dragOffset=MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart
        MainFrame.Position=UDim2.new(dragOffset.X.Scale,dragOffset.X.Offset+delta.X,dragOffset.Y.Scale,dragOffset.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)

-- Menu resize handle: bottom-right only. The upper-right move/close controls remain removed.
do
    local ResizeHandle=Instance.new("TextButton",MainFrame)
    ResizeHandle.Name="MenuResizeHandle"
    ResizeHandle.Size=UDim2.new(0,20,0,20)
    ResizeHandle.Position=UDim2.new(1,-24,1,-24)
    ResizeHandle.BackgroundColor3=Color3.fromRGB(22,22,30)
    ResizeHandle.BackgroundTransparency=0.22
    ResizeHandle.BorderSizePixel=0
    ResizeHandle.Text="◢"
    ResizeHandle.TextColor3=CURRENT_ACCENT
    ResizeHandle.TextSize=11
    ResizeHandle.Font=Enum.Font.GothamBold
    ResizeHandle.AutoButtonColor=false
    ResizeHandle.ZIndex=70
    Instance.new("UICorner",ResizeHandle).CornerRadius=UDim.new(0,4)

    local rhStroke=Instance.new("UIStroke",ResizeHandle)
    rhStroke.Color=CURRENT_ACCENT
    rhStroke.Transparency=0.62

    local resizingMenu=false
    local resizeStart=Vector2.new()
    local resizeOrigin=Vector2.new()

    ResizeHandle.InputBegan:Connect(function(input)
        if not menuUnlocked then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            resizingMenu=true
            resizeStart=Vector2.new(input.Position.X,input.Position.Y)
            -- Use the logical UDim2 size, not AbsoluteSize (AbsoluteSize already includes UIScale).
            -- Reading AbsoluteSize here caused an immediate size jump on the first resize input.
            resizeOrigin=Vector2.new(MainFrame.Size.X.Offset,MainFrame.Size.Y.Offset)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not resizingMenu then return end
        if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
        local pos=Vector2.new(input.Position.X,input.Position.Y)
        local d=pos-resizeStart
        local w=math.clamp(resizeOrigin.X+d.X,460,760)
        local h=math.clamp(resizeOrigin.Y+d.Y,300,560)
        MainFrame.Size=UDim2.new(0,w,0,h)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            resizingMenu=false
        end
    end)
end

local Sidebar=Instance.new("Frame",MainFrame)
Sidebar.Size=UDim2.new(0,140,1,0) Sidebar.BackgroundColor3=COLOR.Sidebar
Sidebar.BorderSizePixel=0 Sidebar.ZIndex=2
Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,8)

local SLogo=makeMLogo(Sidebar,16,UDim2.new(0,8,0,8),Color3.new(1,1,1))

local STitle=noLoc(Instance.new("TextLabel",Sidebar))
STitle.Size=UDim2.new(0,108,0,18) STitle.Position=UDim2.new(0,26,0,7)
STitle.BackgroundTransparency=1 STitle.Text="ClumsyScript"
STitle.TextColor3=COLOR.TextMain STitle.TextSize=15
STitle.Font=Enum.Font.GothamBold STitle.TextXAlignment=Enum.TextXAlignment.Left


-- ═══════════════════════════════════════════════════════════
-- CONFIGS · верхняя панель меню, поверх фона MainFrame
-- ═══════════════════════════════════════════════════════════
do
    -- Remove legacy top-right controls/icons left by older UI versions.
    for _,legacyName in ipairs({"HideButton","CloseButton","MenuCloseButton","TopRightButton","TopRightLogoButton","HeaderLogoButton","LogoButton"}) do
        local legacy=MainFrame:FindFirstChild(legacyName,true)
        if legacy then pcall(function() legacy:Destroy() end) end
    end

    local ConfigButton=Instance.new("TextButton",MainFrame)
    ConfigButton.Name="ConfigsButton"
    ConfigButton.Size=UDim2.new(0,88,0,22)
    ConfigButton.Position=UDim2.new(0,175,0,7)
    ConfigButton.BackgroundColor3=Color3.fromRGB(22,22,30)
    ConfigButton.BackgroundTransparency=0.18
    ConfigButton.BorderSizePixel=0
    ConfigButton.Text=""
    ConfigButton.AutoButtonColor=false
    ConfigButton.ZIndex=40
    Instance.new("UICorner",ConfigButton).CornerRadius=UDim.new(0,5)

    -- Configs is text-only: no logo, ImageLabel, ImageButton or icon placeholder.
    -- Keep the button clean even if an older UI instance injected a child.
    for _,child in ipairs(ConfigButton:GetChildren()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            child:Destroy()
        end
    end

    local ConfigText=noLoc(Instance.new("TextLabel",ConfigButton))
    ConfigText.Name="ConfigText"
    ConfigText.Size=UDim2.new(1,-20,1,0)
    ConfigText.Position=UDim2.new(0,6,0,0)
    ConfigText.BackgroundTransparency=1
    ConfigText.Text="Configs"
    ConfigText.TextColor3=Color3.fromRGB(215,220,235)
    ConfigText.TextSize=8
    ConfigText.Font=Enum.Font.GothamBold
    ConfigText.TextXAlignment=Enum.TextXAlignment.Left
    ConfigText.ZIndex=41

    local ConfigArrow=noLoc(Instance.new("TextLabel",ConfigButton))
    ConfigArrow.Name="ConfigArrow"
    ConfigArrow.Size=UDim2.new(0,8,1,0)
    ConfigArrow.Position=UDim2.new(1,-10,0,0)
    ConfigArrow.BackgroundTransparency=1
    ConfigArrow.Text="v"
    ConfigArrow.TextColor3=CURRENT_ACCENT
    ConfigArrow.TextSize=7
    ConfigArrow.Font=Enum.Font.GothamBold
    ConfigArrow.ZIndex=41

    -- Hard guarantee: the Configs header contains only text + arrow.
    for _,child in ipairs(ConfigButton:GetChildren()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            child:Destroy()
        end
    end

    local ConfigList=Instance.new("Frame",MainFrame)
    ConfigList.Name="ConfigsList"
    ConfigList.Size=UDim2.new(0,188,0,122)
    ConfigList.Position=UDim2.new(0,175,0,32)
    ConfigList.BackgroundColor3=Color3.fromRGB(14,15,22)
    ConfigList.BackgroundTransparency=0.18
    ConfigList.BorderSizePixel=0
    ConfigList.Visible=false
    ConfigList.ZIndex=80
    Instance.new("UICorner",ConfigList).CornerRadius=UDim.new(0,6)

    local cls=Instance.new("UIStroke",ConfigList)
    cls.Color=CURRENT_ACCENT
    cls.Thickness=1
    cls.Transparency=0.58

    local ConfigLayout=Instance.new("UIListLayout",ConfigList)
    ConfigLayout.FillDirection=Enum.FillDirection.Vertical
    ConfigLayout.Padding=UDim.new(0,4)
    ConfigLayout.SortOrder=Enum.SortOrder.LayoutOrder
    ConfigLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    ConfigLayout.VerticalAlignment=Enum.VerticalAlignment.Top

    local ConfigPad=Instance.new("UIPadding",ConfigList)
    ConfigPad.PaddingTop=UDim.new(0,7)
    ConfigPad.PaddingBottom=UDim.new(0,7)

    local ConfigNames={"Default","Legit","Rage"}
    local selectedConfig="Default"

    local function makeConfigItem(name)
        local b=Instance.new("TextButton",ConfigList)
        b.Name="Config_"..name:gsub("%s+","")
        b.Size=UDim2.new(1,-12,0,32)
        b.BackgroundColor3=Color3.fromRGB(20,21,30)
        b.BackgroundTransparency=0.22
        b.BorderSizePixel=0
        b.AutoButtonColor=false
        b.Text=name
        b.TextColor3=Color3.fromRGB(195,200,215)
        b.TextSize=9
        b.Font=Enum.Font.GothamMedium
        b.TextXAlignment=Enum.TextXAlignment.Left
        b.ZIndex=81
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
        local pad=Instance.new("UIPadding",b)
        pad.PaddingLeft=UDim.new(0,9)

        b.MouseEnter:Connect(function()
            TweenService:Create(b,TweenInfo.new(0.1),{
                BackgroundColor3=CURRENT_ACCENT,
                BackgroundTransparency=0.76
            }):Play()
        end)
        b.MouseLeave:Connect(function()
            if selectedConfig~=name then
                TweenService:Create(b,TweenInfo.new(0.1),{
                    BackgroundColor3=Color3.fromRGB(20,21,30),
                    BackgroundTransparency=0.22
                }):Play()
            end
        end)

        b.MouseButton1Click:Connect(function()
            selectedConfig=name
            ConfigText.Text=name
            ConfigList.Visible=false
            ConfigArrow.Text="v"

            for _,obj in ipairs(ConfigList:GetChildren()) do
                if obj:IsA("TextButton") then
                    obj.BackgroundColor3=(obj==b) and CURRENT_ACCENT or Color3.fromRGB(20,21,30)
                    obj.BackgroundTransparency=(obj==b) and 0.70 or 0.22
                    obj.TextColor3=(obj==b) and Color3.new(1,1,1) or Color3.fromRGB(195,200,215)
                end
            end

            pcall(function()
                if getgenv().ClumsyApplyConfig then
                    getgenv().ClumsyApplyConfig(name)
                end
            end)
        end)
        return b
    end

    for _,name in ipairs(ConfigNames) do
        makeConfigItem(name)
    end

    ConfigButton.MouseButton1Click:Connect(function()
        ConfigList.Visible=not ConfigList.Visible
        ConfigArrow.Text=ConfigList.Visible and "^" or "v"
    end)

    getgenv().ClumsyConfigUI={
        get=function() return selectedConfig end,
        open=function()
            ConfigList.Visible=true
            ConfigArrow.Text="^"
        end,
        close=function()
            ConfigList.Visible=false
            ConfigArrow.Text="v"
        end,
    }
end

local ProfileFrame=Instance.new("Frame",Sidebar)
ProfileFrame.Size=UDim2.new(1,-14,0,32) ProfileFrame.Position=UDim2.new(0,7,1,-38)
ProfileFrame.BackgroundColor3=COLOR.Element ProfileFrame.BorderSizePixel=0 ProfileFrame.ZIndex=3
Instance.new("UICorner",ProfileFrame).CornerRadius=UDim.new(0,6)

local AvatarImg=Instance.new("ImageLabel",ProfileFrame)
AvatarImg.Size=UDim2.new(0,22,0,22) AvatarImg.Position=UDim2.new(0,5,0.5,-11)
AvatarImg.BackgroundColor3=Color3.fromRGB(30,30,40) AvatarImg.ImageColor3=Color3.new(1,1,1) AvatarImg.BorderSizePixel=0 AvatarImg.ZIndex=4
AvatarImg:SetAttribute("NoAccentTint",true)
Instance.new("UICorner",AvatarImg).CornerRadius=UDim.new(1,0)
task.spawn(function()
    local ok,url=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420) end)
    if ok and url then AvatarImg.Image=url end
end)

local PName=noLoc(Instance.new("TextLabel",ProfileFrame))
PName.Size=UDim2.new(1,-46,0,11) PName.Position=UDim2.new(0,32,0,4)
PName.BackgroundTransparency=1 PName.Text=LP.DisplayName~="" and LP.DisplayName or LP.Name
PName.TextColor3=Color3.new(1,1,1) PName.TextSize=9
PName.Font=Enum.Font.GothamBold PName.TextXAlignment=Enum.TextXAlignment.Left
PName.TextTruncate=Enum.TextTruncate.AtEnd PName.ZIndex=4

local PSub=noLoc(Instance.new("TextLabel",ProfileFrame))
PSub.Size=UDim2.new(1,-46,0,9) PSub.Position=UDim2.new(0,32,0,16)
PSub.BackgroundTransparency=1 PSub.Text="PREMIUM"
PSub.TextColor3=CURRENT_ACCENT PSub.TextSize=7
PSub.Font=Enum.Font.Gotham PSub.TextXAlignment=Enum.TextXAlignment.Left PSub.ZIndex=4

local TABS={
    {name="Player",icon=ICONS.user},{name="Combat",icon=ICONS.crosshair},
    {name="Visuals",icon=ICONS.eye},{name="World",icon=ICONS.globe},
    {name="Settings",icon=ICONS.settings},
}
local tabButtons,tabFrames={},{}

local Container=Instance.new("Frame",MainFrame)
Container.Size=UDim2.new(1,-150,1,-40) Container.Position=UDim2.new(0,146,0,40)
Container.BackgroundTransparency=1 Container.ClipsDescendants=true Container.Visible=false

-- ═══════════════════════════════════════════════════════════
-- LAYOUT FIX: columnas con UIListLayout + scroll auto-size
-- ═══════════════════════════════════════════════════════════
local function createTabFrame()
    local scroll=Instance.new("ScrollingFrame",Container)
    scroll.Size=UDim2.new(1,0,1,0) scroll.BackgroundTransparency=1
    scroll.BorderSizePixel=0 scroll.ScrollBarThickness=2
    scroll.ScrollBarImageColor3=Color3.fromRGB(80,80,100)
    -- FIX #2: canvas auto-dims to content, no scroll past end
    scroll.CanvasSize=UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.ScrollingDirection=Enum.ScrollingDirection.Y
    scroll.ElasticBehavior=Enum.ElasticBehavior.Never
    scroll.Visible=false
    local row=Instance.new("Frame",scroll)
    row.Name="Row"
    row.Size=UDim2.new(1,0,0,0)
    row.AutomaticSize=Enum.AutomaticSize.Y
    row.BackgroundTransparency=1
    local rowL=Instance.new("UIListLayout",row)
    rowL.FillDirection=Enum.FillDirection.Horizontal
    rowL.Padding=UDim.new(0,6)
    rowL.SortOrder=Enum.SortOrder.LayoutOrder
    -- Небольшой запас снизу: позволяет пролистать чуть дальше последней функции.
    local scrollPad=Instance.new("UIPadding",scroll)
    scrollPad.PaddingBottom=UDim.new(0,24)
    local left=Instance.new("Frame",row)
    left.Name="Left" left.Size=UDim2.new(0.5,-3,0,0) left.BackgroundTransparency=1
    left.AutomaticSize=Enum.AutomaticSize.Y
    local ll=Instance.new("UIListLayout",left)
    ll.Padding=UDim.new(0,4) ll.SortOrder=Enum.SortOrder.LayoutOrder
    local right=Instance.new("Frame",row)
    right.Name="Right" right.Size=UDim2.new(0.5,-3,0,0) right.BackgroundTransparency=1
    right.AutomaticSize=Enum.AutomaticSize.Y
    right.LayoutOrder=1
    local rl=Instance.new("UIListLayout",right)
    rl.Padding=UDim.new(0,4) rl.SortOrder=Enum.SortOrder.LayoutOrder
    return scroll,left,right
end
for _,t in ipairs(TABS) do
    local s,l,r=createTabFrame()
    tabFrames[t.name]={scroll=s,left=l,right=r}

    local function refreshTabCanvas()
        task.defer(function()
            local lh=math.ceil(l.AbsoluteSize.Y)
            local rh=math.ceil(r.AbsoluteSize.Y)
            local llh=ll0 and math.ceil(ll0.AbsoluteContentSize.Y) or lh
            local rlh=rl0 and math.ceil(rl0.AbsoluteContentSize.Y) or rh
            local h=math.max(lh,llh,rh,rlh)+36
            s.CanvasSize=UDim2.new(0,0,0,h)
        end)
    end
    l:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshTabCanvas)
    r:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshTabCanvas)
    local ll0=l:FindFirstChildOfClass("UIListLayout")
    local rl0=r:FindFirstChildOfClass("UIListLayout")
    if ll0 then ll0:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshTabCanvas) end
    if rl0 then rl0:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshTabCanvas) end
    refreshTabCanvas()
end

local function onAccentChange(fn)
    -- Fixed monochrome UI: callbacks are initialized once and never recolored at runtime.
    pcall(fn, CURRENT_ACCENT)
end

-- sectionHeader ahora es una fila de layout (no usa Y offset manual)
local function sectionHeader(parent,text,iconId)
    local frame=Instance.new("Frame",parent)
    frame.Size=UDim2.new(1,0,0,16)
    frame.BackgroundTransparency=1
    if iconId then
        local ico=Instance.new("ImageLabel",frame)
        ico.Size=UDim2.new(0,12,0,12) ico.Position=UDim2.new(0,4,0.5,-6)
        ico.BackgroundTransparency=1 ico.Image=iconId
        ico.ImageColor3=CURRENT_ACCENT ico.ScaleType=Enum.ScaleType.Fit
        onAccentChange(function(c) ico.ImageColor3=c end)
    end
    local lbl=noLoc(Instance.new("TextLabel",frame))
    lbl.Size=UDim2.new(1,-20,1,0) lbl.Position=UDim2.new(0,20,0,0)
    lbl.BackgroundTransparency=1 lbl.Text="» "..string.upper(text)
    lbl.TextColor3=COLOR.TextSection lbl.TextSize=8
    lbl.Font=Enum.Font.GothamBold lbl.TextXAlignment=Enum.TextXAlignment.Left
    return frame
end

local function makeSliderRow(parent,title,minVal,maxVal,defaultVal,cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,-6,0,22) row.BackgroundColor3=COLOR.Sub row.BackgroundTransparency=0.3 row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
    local lbl=noLoc(Instance.new("TextLabel",row))
    lbl.Size=UDim2.new(0.55,0,0,12) lbl.Position=UDim2.new(0,8,0,3)
    lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=Color3.fromRGB(170,170,190) lbl.TextSize=8
    lbl.Font=Enum.Font.Gotham lbl.TextXAlignment=Enum.TextXAlignment.Left
    local valLbl=noLoc(Instance.new("TextLabel",row))
    valLbl.Size=UDim2.new(0.4,0,0,12) valLbl.Position=UDim2.new(0.58,0,0,3)
    valLbl.BackgroundTransparency=1 valLbl.Text=tostring(defaultVal) valLbl.TextColor3=CURRENT_ACCENT
    valLbl.TextSize=8 valLbl.Font=Enum.Font.GothamBold valLbl.TextXAlignment=Enum.TextXAlignment.Right
    local bar=Instance.new("Frame",row)
    bar.Size=UDim2.new(1,-16,0,3) bar.Position=UDim2.new(0,8,0,16)
    bar.BackgroundColor3=COLOR.ToggleOff bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",bar)
    local ratio=(defaultVal-minVal)/(maxVal-minVal)
    fill.Size=UDim2.new(ratio,0,1,0) fill.BackgroundColor3=CURRENT_ACCENT fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local drag=false
    local function apply(input)
        if not menuUnlocked then return end
        local barPos=bar.AbsolutePosition.X
        local barW=math.max(1,bar.AbsoluteSize.X)
        local r=math.clamp((input.Position.X-barPos)/barW,0,1)
        fill.Size=UDim2.new(r,0,1,0)
        local v=math.floor(minVal+r*(maxVal-minVal)+0.5)
        valLbl.Text=tostring(v)
        if cb then pcall(cb,v) end
    end
    bar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then drag=true apply(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInputService.InputChanged:Connect(function(input) if drag and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then apply(input) end end)
    onAccentChange(function(c) fill.BackgroundColor3=c valLbl.TextColor3=c end)
    return row
end

local function makeCycleRow(parent,title,options,defaultIdx,cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,-6,0,22) row.BackgroundColor3=COLOR.Sub row.BackgroundTransparency=0.3 row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
    local lbl=noLoc(Instance.new("TextLabel",row))
    lbl.Size=UDim2.new(0.5,0,1,0) lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=Color3.fromRGB(170,170,190) lbl.TextSize=8
    lbl.Font=Enum.Font.Gotham lbl.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(0,90,0,16) btn.Position=UDim2.new(1,-96,0.5,-8)
    btn.BackgroundColor3=COLOR.Element btn.Text=tostring(options[defaultIdx] or options[1])
    btn.TextColor3=CURRENT_ACCENT btn.TextSize=8
    btn.Font=Enum.Font.GothamBold btn.AutoButtonColor=false btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
    local idx=defaultIdx or 1
    btn.MouseButton1Click:Connect(function()
        if not menuUnlocked then return end
        idx=idx+1 if idx>#options then idx=1 end
        btn.Text=tostring(options[idx])
        if cb then pcall(cb,idx,options[idx]) end
    end)
    onAccentChange(function(c) btn.TextColor3=c end)
    return row
end

local function makeButtonRow(parent,title,cb)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,-6,0,22)
    btn.BackgroundColor3=COLOR.Element btn.Text=title
    btn.TextColor3=COLOR.TextMain btn.TextSize=8
    btn.Font=Enum.Font.GothamMedium btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.AutoButtonColor=false btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
    Instance.new("UIPadding",btn).PaddingLeft=UDim.new(0,8)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=CURRENT_ACCENT}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=COLOR.Element}):Play() end)
    btn.MouseButton1Click:Connect(function() if not menuUnlocked then return end if cb then pcall(cb) end end)
    return btn
end

-- FIX #1: card expande y el siguiente card se empuja solo (UIListLayout en la columna)
local FEATURE_CONTROLS={}
local function registerFeatureControl(title, control)
    FEATURE_CONTROLS[title]=control
end
local function setFeatureToggle(title, value, fire)
    local c=FEATURE_CONTROLS[title]
    if not c then return false end
    c.set(value and true or false, fire~=false)
    return true
end
getgenv().ClumsyFeatureControls=FEATURE_CONTROLS

local function expandableToggle(parent,opts)
    local title=opts.title or "Feature"
    local default=opts.default or false
    local cb=opts.callback
    local builder=opts.builder

    local card=Instance.new("Frame",parent)
    card.BackgroundColor3=COLOR.Element
    card.BackgroundTransparency=0.08
    card.BorderSizePixel=0
    card.Size=UDim2.new(1,-6,0,24)
    card.ClipsDescendants=true
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,5)

    local stroke=Instance.new("UIStroke",card)
    stroke.Color=CURRENT_ACCENT
    stroke.Transparency=0.88
    stroke.Thickness=1

    local header=Instance.new("Frame",card)
    header.Size=UDim2.new(1,0,0,24)
    header.BackgroundTransparency=1
    header.ZIndex=2

    local lbl=noLoc(Instance.new("TextLabel",header))
    lbl.Size=UDim2.new(1,-36,1,0)
    lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=title
    lbl.TextColor3=Color3.fromRGB(190,190,210)
    lbl.TextSize=9
    lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=3

    -- Restored classic pill switch.
    local btn=Instance.new("TextButton",header)
    btn.Size=UDim2.new(0,28,0,14)
    btn.Position=UDim2.new(1,-34,0.5,-7)
    btn.BackgroundColor3=default and Color3.fromRGB(55,55,55) or COLOR.ToggleOff
    btn.Text=""
    btn.AutoButtonColor=false
    btn.BorderSizePixel=0
    btn.ZIndex=4
    Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)

    local circle=Instance.new("Frame",btn)
    circle.Size=UDim2.new(0,10,0,10)
    circle.Position=default and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)
    circle.BackgroundColor3=Color3.new(1,1,1)
    circle:SetAttribute("NoAccentTint", true)
    circle.BorderSizePixel=0
    circle.ZIndex=5
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)

    local sub=Instance.new("Frame",card)
    sub.BackgroundTransparency=1
    sub.Position=UDim2.new(0,0,0,24)
    sub.Size=UDim2.new(1,0,0,0)
    sub.ClipsDescendants=true
    sub.ZIndex=1

    local subLayout=Instance.new("UIListLayout",sub)
    subLayout.Padding=UDim.new(0,4)
    subLayout.SortOrder=Enum.SortOrder.LayoutOrder

    local subPad=Instance.new("UIPadding",sub)
    subPad.PaddingTop=UDim.new(0,3)
    subPad.PaddingBottom=UDim.new(0,7)
    subPad.PaddingLeft=UDim.new(0,4)
    subPad.PaddingRight=UDim.new(0,4)

    local contentFrame=nil
    local contentLayout=nil
    if builder then
        contentFrame=Instance.new("Frame",sub)
        contentFrame.Size=UDim2.new(1,0,0,0)
        contentFrame.AutomaticSize=Enum.AutomaticSize.Y
        contentFrame.BackgroundTransparency=1
        contentFrame.LayoutOrder=1
        contentLayout=Instance.new("UIListLayout",contentFrame)
        contentLayout.Padding=UDim.new(0,4)
        contentLayout.SortOrder=Enum.SortOrder.LayoutOrder
        builder(contentFrame)
    end

    local state=default
    local resizeSerial=0
    local openTween=nil
    local function getContentHeight()
        if not contentFrame then return 0 end
        -- Use the real layout height of every nested control. Add generous padding
        -- so the final slider/button can never be clipped by the card itself.
        local h=0
        if contentLayout then
            h=math.ceil(contentLayout.AbsoluteContentSize.Y)
        end
        h=math.max(h,math.ceil(contentFrame.AbsoluteSize.Y))
        return math.max(0,h+16)
    end

    local function resize(animated)
        resizeSerial=resizeSerial+1
        local serial=resizeSerial
        task.defer(function()
            -- Wait for both nested UIListLayouts and AutomaticSize to settle.
            for _=1,3 do
                if RunService.RenderStepped then RunService.RenderStepped:Wait() else task.wait() end
            end
            if serial~=resizeSerial or not card.Parent then return end

            -- Extra vertical space (~0.5 cm) is applied only when the function
            -- actually has visible settings controls. Functions without a settings
            -- panel keep their original height with no empty extension.
            local hasSettings=false
            if contentFrame and contentLayout then
                hasSettings=contentFrame.Parent==sub and #contentFrame:GetChildren()>1 and contentLayout.AbsoluteContentSize.Y>0
            end
            local extraSettings=hasSettings and 19 or 0
            local targetSub=state and (getContentHeight()+extraSettings) or 0
            local targetCard=24+targetSub

            if openTween then pcall(function() openTween:Cancel() end) end
            if animated then
                local ti=TweenInfo.new(0.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
                openTween=TweenService:Create(sub,ti,{Size=UDim2.new(1,0,0,targetSub)})
                openTween:Play()
                TweenService:Create(card,ti,{Size=UDim2.new(1,-6,0,targetCard)}):Play()
            else
                sub.Size=UDim2.new(1,0,0,targetSub)
                card.Size=UDim2.new(1,-6,0,targetCard)
            end
        end)
    end

    if contentLayout then
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if state then resize(false) end
        end)
    end
    subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if state then resize(false) end
    end)

    local function setState(v,fire,animated)
        state=v and true or false
        -- Classic switch: knob slides left/right.
        local pos=state and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)
        local col=state and Color3.fromRGB(55,55,55) or COLOR.ToggleOff
        local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        TweenService:Create(circle,ti,{Position=pos}):Play()
        TweenService:Create(btn,ti,{BackgroundColor3=col}):Play()
        -- Feature cards keep the same subtle border in both states; enabling a
        -- feature must not create a bright outline around the whole card.
        TweenService:Create(stroke,ti,{Transparency=0.88}):Play()
        TweenService:Create(lbl,ti,{TextColor3=state and Color3.new(1,1,1) or Color3.fromRGB(190,190,210)}):Play()
        resize(animated~=false)
        if fire and cb then pcall(cb,state) end
    end

    registerFeatureControl(title,{get=function() return state end,set=function(v,fire) setState(v,fire,true) end,button=btn,card=card})

    btn.Activated:Connect(function()
        if not menuUnlocked then return end
        setState(not state,true,true)
    end)
    -- The card/header/sub-content are intentionally passive: tapping their empty
    -- area can never toggle the feature. Only the switch above changes state.
    card.Active=false
    header.Active=false
    sub.Active=false

    card.MouseEnter:Connect(function()
        if not state then
            TweenService:Create(card,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=CURRENT_ACCENT}):Play()
        end
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=COLOR.Element}):Play()
    end)

    onAccentChange(function(c)
        if state then btn.BackgroundColor3=Color3.fromRGB(55,55,55) end
        circle.BackgroundColor3=Color3.new(1,1,1)
        stroke.Color=c
    end)

    -- Initial layout after all builder controls have been created.
    task.defer(function()
        if RunService.RenderStepped then
            RunService.RenderStepped:Wait()
            RunService.RenderStepped:Wait()
        else
            task.wait()
        end
        resize(false)
    end)
    return card
end

-- ═══════════════════════════════════════════════════════════
-- RAGE ROLE CHAMS GUARD
-- While Rage is selected, role colors are independent of UI color/settings.
-- ═══════════════════════════════════════════════════════════
track(RunService.Heartbeat:Connect(function()
    if getgenv().ClumsyActiveConfig=="Rage" and RoleChams then
        pcall(function()
            RoleChams.set_rage_lock(true)
            RoleChams.set_mode(1)
            RoleChams.set_colors(
                Color3.fromRGB(255,140,0),
                Color3.fromRGB(100,180,255),
                Color3.fromRGB(245,245,245)
            )
        end)
    end
end))

-- ═══════════════════════════════════════════════════════════
-- FEATURES — paridad con v32
-- ═══════════════════════════════════════════════════════════

-- Movement
track(RunService.Heartbeat:Connect(function()
    local h=my_hum() if not h then return end
    if CFG.Speed and h.WalkSpeed~=CFG.SpeedValue then h.WalkSpeed=CFG.SpeedValue end
    if CFG.JumpPower then
        if not h.UseJumpPower then h.UseJumpPower=true end
        if h.JumpPower~=CFG.JumpPowerValue then h.JumpPower=CFG.JumpPowerValue end
    end
    if CFG.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local st=h:GetState()
        if st==Enum.HumanoidStateType.Landed or st==Enum.HumanoidStateType.Running then h.Jump=true end
    end
end))
track(UserInputService.JumpRequest:Connect(function() if CFG.InfJump then local h=my_hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))
-- Update 39/40 · Ghost neon chams + performance pass
-- Update 38 · Expanded function color palette
-- Aspect / Screen Stretch · HARD FIX · W:20..125 · H:20..118
-- Orientation-safe implementation:
--   * never permanently modifies the camera's clean CFrame;
--   * re-hooks CurrentCamera and ViewportSize after every rotation;
--   * waits through the orientation transition before applying the stretch;
--   * disabling the feature restores the exact pre-stretch camera transform;
--   * changing Horizontal/Vertical values updates one cached matrix only.
do
    local ENABLED = true
    local WIDTH = math.clamp(tonumber(CFG.AspectH) or 100,20,125)
    local HEIGHT = math.clamp(tonumber(CFG.AspectV) or 100,20,118)
    local matrix = CFrame.new()
    local inverseMatrix = CFrame.new()
    local clean_cf = nil
    local last_camera = nil
    local viewport_conn = nil
    local camera_conn = nil
    local orientation_conn = nil
    local dirty = true
    local settle_frames = 0
    local generation = 0

    local function build_matrix()
        local x = WIDTH / 100
        local y = HEIGHT / 100
        matrix = CFrame.new(0,0,0, x,0,0, 0,y,0, 0,0,1)
        inverseMatrix = matrix:Inverse()
    end

    local function sync_matrix()
        WIDTH = math.clamp(tonumber(CFG.AspectH) or WIDTH,20,125)
        HEIGHT = math.clamp(tonumber(CFG.AspectV) or HEIGHT,20,118)
        build_matrix()
        dirty = false
    end

    local function restore_clean_camera()
        local cam = WS.CurrentCamera
        if not cam then
            clean_cf = nil
            return
        end
        if clean_cf then
            pcall(function() cam.CFrame = clean_cf end)
        else
            -- Fallback for the case where orientation replaced the camera
            -- between frames and there is no cached clean transform.
            pcall(function() cam.CFrame = cam.CFrame * inverseMatrix end)
        end
        clean_cf = nil
    end

    local function arm_orientation(cam)
        generation = generation + 1
        clean_cf = nil
        dirty = true
        -- Give Roblox's camera controller a couple of render frames to finish
        -- the portrait/landscape transition before we lock the new transform.
        settle_frames = 2
        last_camera = cam

        if viewport_conn then
            pcall(function() viewport_conn:Disconnect() end)
            viewport_conn = nil
        end
        if cam then
            viewport_conn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                generation = generation + 1
                clean_cf = nil
                dirty = true
                settle_frames = 2
            end)
        end
    end

    local function refresh_camera(cam)
        if cam ~= last_camera then
            arm_orientation(cam)
        end
    end

    build_matrix()

    camera_conn = WS:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        arm_orientation(WS.CurrentCamera)
    end)

    -- Some clients expose orientation through GuiService even when the camera
    -- object itself is reused. Keep this optional and disconnectable.
    pcall(function()
        local GuiService = game:GetService("GuiService")
        if GuiService.GetPropertyChangedSignal then
            orientation_conn = GuiService:GetPropertyChangedSignal("ScreenResolution"):Connect(function()
                arm_orientation(WS.CurrentCamera)
            end)
        end
    end)

    arm_orientation(WS.CurrentCamera)

    getgenv().ClumsyAspectReset = function()
        CFG.Aspect = false
        WIDTH = 100
        HEIGHT = 100
        CFG.AspectH = 100
        CFG.AspectV = 100
        build_matrix()
        ENABLED = false
        restore_clean_camera()
        settle_frames = 0
        dirty = true
        ENABLED = true
    end

    RunService:BindToRenderStep("ClumsyAspect_Restore", Enum.RenderPriority.Camera.Value - 1, function()
        local cam = WS.CurrentCamera
        refresh_camera(cam)
        if not cam then return end

        if not ENABLED or not CFG.Aspect then
            restore_clean_camera()
            return
        end

        -- Restore the clean camera immediately before Roblox updates it.
        -- This prevents our previous stretched frame from becoming the next
        -- frame's source transform.
        if clean_cf then
            pcall(function() cam.CFrame = clean_cf end)
        end
    end)

    RunService:BindToRenderStep("ClumsyAspect_Apply", Enum.RenderPriority.Camera.Value + 1, function()
        local cam = WS.CurrentCamera
        if not cam then return end
        refresh_camera(cam)

        if not ENABLED or not CFG.Aspect then
            return
        end

        if settle_frames > 0 then
            -- Capture the post-rotation camera without applying stretch yet.
            clean_cf = cam.CFrame
            settle_frames = settle_frames - 1
            return
        end

        -- The camera controller has finished this orientation. Cache its clean
        -- transform, then apply exactly one matrix for this rendered frame.
        clean_cf = cam.CFrame
        if dirty then
            sync_matrix()
        end
        pcall(function() cam.CFrame = clean_cf * matrix end)
    end)

    getgenv().STRETCH = {
        set = function(v)
            ENABLED = v and true or false
            if not ENABLED then
                restore_clean_camera()
            else
                dirty = true
                settle_frames = 2
                clean_cf = nil
            end
        end,
        set_width = function(v)
            WIDTH = math.clamp(tonumber(v) or 100,20,125)
            CFG.AspectH = WIDTH
            build_matrix()
            dirty = false
        end,
        set_height = function(v)
            HEIGHT = math.clamp(tonumber(v) or 100,20,118)
            CFG.AspectV = HEIGHT
            build_matrix()
            dirty = false
        end,
        set_size = function(w,h)
            WIDTH = math.clamp(tonumber(w) or 100,20,125)
            HEIGHT = math.clamp(tonumber(h) or 100,20,118)
            CFG.AspectH = WIDTH
            CFG.AspectV = HEIGHT
            build_matrix()
            dirty = false
        end,
        get = function() return WIDTH, HEIGHT end,
        reset = function()
            CFG.Aspect = false
            WIDTH, HEIGHT = 100, 100
            CFG.AspectH, CFG.AspectV = 100, 100
            build_matrix()
            restore_clean_camera()
            dirty = true
            settle_frames = 0
        end,
        is_on = function() return ENABLED and CFG.Aspect end,
    }
end
track(RunService.RenderStepped:Connect(function()
    if CFG.FOV then local cam=WS.CurrentCamera if cam and cam.FieldOfView~=CFG.FOVValue then cam.FieldOfView=CFG.FOVValue end end
end))

local noclip_cache={}
track(RunService.Stepped:Connect(function()
    if not CFG.Noclip then
        if next(noclip_cache) then
            for p in pairs(noclip_cache) do if p and p.Parent then pcall(function() p.CanCollide=true end) end end
            noclip_cache={}
        end
        return
    end
    local c=LP.Character
    if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then noclip_cache[p]=true p.CanCollide=false end end end
end))
track(RunService.Heartbeat:Connect(function() if CFG.GodMode then local h=my_hum() if h and h.Health<h.MaxHealth then h.Health=h.MaxHealth end end end))

-- Fly joystick + WASD
FlyJoy={active=false,ui=nil,base=nil,knob=nil,bv=nil,bg=nil,conns={},drag=false,touchObj=nil,vec=Vector2.zero,loopConn=nil,charConn=nil,generation=0,noclip_snap={},god_ff=nil,god_conn=nil}
local function fjResetStick() FlyJoy.drag=false FlyJoy.touchObj=nil FlyJoy.vec=Vector2.zero if FlyJoy.knob and FlyJoy.knob.Parent then FlyJoy.knob.Position=UDim2.new(0.5,0,0.5,0) end end
local function fjUpdatePos(inputPos)
    if not FlyJoy.base or not FlyJoy.base.Parent or not FlyJoy.knob or not FlyJoy.knob.Parent then return end
    local center=FlyJoy.base.AbsolutePosition+(FlyJoy.base.AbsoluteSize*0.5)
    local offset=Vector2.new(inputPos.X,inputPos.Y)-center
    local maxR=math.max(1,(math.min(FlyJoy.base.AbsoluteSize.X,FlyJoy.base.AbsoluteSize.Y)*0.5)-28)
    local mag=offset.Magnitude
    if mag>maxR then offset=offset.Unit*maxR end
    FlyJoy.knob.Position=UDim2.new(0.5,offset.X,0.5,offset.Y)
    FlyJoy.vec=Vector2.new(offset.X/maxR,-offset.Y/maxR)
    if FlyJoy.vec.Magnitude>1 then FlyJoy.vec=FlyJoy.vec.Unit end
end
local function fjDisconnectUI() for _,c in ipairs(FlyJoy.conns) do pcall(function() c:Disconnect() end) end FlyJoy.conns={} end
local function fjMakeUI()
    if FlyJoy.ui and FlyJoy.ui.Parent and FlyJoy.base and FlyJoy.base.Parent then return end
    fjDisconnectUI() if FlyJoy.ui then pcall(function() FlyJoy.ui:Destroy() end) end
    local sg=Instance.new("ScreenGui") sg.Name="ClumsyFlyJoystick" sg.ResetOnSpawn=false sg.DisplayOrder=998 sg.IgnoreGuiInset=true
    safeParent(sg) FlyJoy.ui=sg
    local base=Instance.new("Frame",sg)
    base.AnchorPoint=Vector2.new(0.5,0.5) base.Position=UDim2.new(0.18,0,0.72,0) base.Size=UDim2.new(0,150,0,150)
    base.BackgroundColor3=Color3.fromRGB(0,0,0) base.BackgroundTransparency=0.25 base.BorderSizePixel=0 base.Active=true base.ZIndex=10
    Instance.new("UICorner",base).CornerRadius=UDim.new(1,0)
    local st=Instance.new("UIStroke",base) st.Color=CURRENT_ACCENT st.Thickness=1.5 st.Transparency=0.4
    FlyJoy.base=base
    local knob=Instance.new("Frame",base)
    knob.AnchorPoint=Vector2.new(0.5,0.5) knob.Position=UDim2.new(0.5,0,0.5,0) knob.Size=UDim2.new(0,55,0,55)
    knob.BackgroundColor3=CURRENT_ACCENT knob.BackgroundTransparency=0.1 knob.BorderSizePixel=0 knob.ZIndex=11
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0) FlyJoy.knob=knob
    onAccentChange(function(c) st.Color=c knob.BackgroundColor3=c end)
    FlyJoy.conns[#FlyJoy.conns+1]=base.InputBegan:Connect(function(input)
        if not FlyJoy.active then return end
        local t=input.UserInputType
        if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then FlyJoy.drag=true FlyJoy.touchObj=input fjUpdatePos(input.Position) end
    end)
    FlyJoy.conns[#FlyJoy.conns+1]=UserInputService.InputChanged:Connect(function(input)
        if not FlyJoy.active or not FlyJoy.drag then return end
        local t=input.UserInputType
        if t==Enum.UserInputType.Touch then if FlyJoy.touchObj and input~=FlyJoy.touchObj then return end fjUpdatePos(input.Position)
        elseif t==Enum.UserInputType.MouseMovement then fjUpdatePos(input.Position) end
    end)
    FlyJoy.conns[#FlyJoy.conns+1]=UserInputService.InputEnded:Connect(function(input)
        if not FlyJoy.drag then return end
        if input==FlyJoy.touchObj or input.UserInputType==Enum.UserInputType.MouseButton1 then fjResetStick() end
    end)
end
local function fjDestroyForChar()
    if FlyJoy.god_ff then pcall(function() FlyJoy.god_ff:Destroy() end) FlyJoy.god_ff=nil end
    if FlyJoy.god_conn then pcall(function() FlyJoy.god_conn:Disconnect() end) FlyJoy.god_conn=nil end
    if FlyJoy.bv then pcall(function() FlyJoy.bv:Destroy() end) FlyJoy.bv=nil end
    if FlyJoy.bg then pcall(function() FlyJoy.bg:Destroy() end) FlyJoy.bg=nil end
    local c=LP.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=false end end
    if FlyJoy.noclip_snap then for p in pairs(FlyJoy.noclip_snap) do if p and p.Parent then pcall(function() p.CanCollide=true end) end end FlyJoy.noclip_snap={} end
end
local function fjEnableFlight(char)
    if not FlyJoy.active then return end
    local hrp=char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart",5)
    local hum=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",5)
    if not hrp or not hum or not FlyJoy.active then return end
    fjDestroyForChar()
    local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(1e9,1e9,1e9) bv.P=12500 bv.Velocity=Vector3.zero bv.Parent=hrp FlyJoy.bv=bv
    local bg=Instance.new("BodyGyro") bg.MaxTorque=Vector3.new(1e9,1e9,1e9) bg.P=12000 bg.D=700 bg.CFrame=hrp.CFrame bg.Parent=hrp FlyJoy.bg=bg
    hum.PlatformStand=true
    FlyJoy.noclip_snap=FlyJoy.noclip_snap or {}
    if CFG.FlyNoclip then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then FlyJoy.noclip_snap[p]=true p.CanCollide=false end end end
    if CFG.FlyGod then
        if not char:FindFirstChildOfClass("ForceField") then local ff=Instance.new("ForceField") ff.Visible=false ff.Parent=char FlyJoy.god_ff=ff end
        if not FlyJoy.god_conn then
            FlyJoy.god_conn=RunService.Heartbeat:Connect(function()
                if not FlyJoy.active or not CFG.FlyGod then return end
                local c=LP.Character if not c then return end
                local h=c:FindFirstChildOfClass("Humanoid")
                if h and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
                if not c:FindFirstChildOfClass("ForceField") then local ff=Instance.new("ForceField") ff.Visible=false ff.Parent=c FlyJoy.god_ff=ff end
            end)
        end
    end
end
local function fjSet(v)
    if v then
        if FlyJoy.active then fjMakeUI() return end
        FlyJoy.active=true FlyJoy.generation=FlyJoy.generation+1
        fjMakeUI() fjResetStick()
        if LP.Character then fjEnableFlight(LP.Character) end
        if not FlyJoy.charConn then FlyJoy.charConn=LP.CharacterAdded:Connect(function(c) if FlyJoy.active then task.defer(function() if FlyJoy.active then fjEnableFlight(c) end end) end end) end
        local gen=FlyJoy.generation
        FlyJoy.loopConn=RunService.RenderStepped:Connect(function()
            if not FlyJoy.active or gen~=FlyJoy.generation then return end
            local c=LP.Character if not c then return end
            local hrp=c:FindFirstChild("HumanoidRootPart") local hum=c:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            if not FlyJoy.bv or FlyJoy.bv.Parent~=hrp then fjEnableFlight(c) return end
            hum.PlatformStand=true
            if CFG.FlyNoclip then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then FlyJoy.noclip_snap[p]=true p.CanCollide=false end end end
            if FlyJoy.bg and FlyJoy.bg.Parent==hrp then FlyJoy.bg.CFrame=WS.CurrentCamera.CFrame end
            local v2=FlyJoy.vec
            if v2.Magnitude>0.05 then local cf=WS.CurrentCamera.CFrame FlyJoy.bv.Velocity=(cf.RightVector*v2.X+cf.LookVector*v2.Y)*(tonumber(CFG.FlySpeed) or 60)
            else FlyJoy.bv.Velocity=Vector3.zero end
        end)
    else
        if not FlyJoy.active then return end
        FlyJoy.active=false FlyJoy.generation=FlyJoy.generation+1
        if FlyJoy.loopConn then pcall(function() FlyJoy.loopConn:Disconnect() end) FlyJoy.loopConn=nil end
        fjDestroyForChar() fjResetStick() fjDisconnectUI()
        if FlyJoy.ui then pcall(function() FlyJoy.ui:Destroy() end) FlyJoy.ui=nil end
        FlyJoy.base,FlyJoy.knob=nil,nil
        if FlyJoy.charConn then pcall(function() FlyJoy.charConn:Disconnect() end) FlyJoy.charConn=nil end
    end
end

-- Korblox/Headless
local korblox_cache,headless_cache={},{}
track(RunService.Heartbeat:Connect(function()
    local c=LP.Character if not c then return end
    if CFG.FakeKorblox then
        local ru=c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg")
        local rl=c:FindFirstChild("RightLowerLeg") local rf=c:FindFirstChild("RightFoot")
        if ru then
            if not korblox_cache[ru] then korblox_cache[ru]={MeshId=ru.MeshId,TextureID=ru.TextureID} end
            pcall(function() ru.MeshId="rbxassetid://902942096" ru.TextureID="rbxassetid://902843398" end)
        end
        if rl then
            if not korblox_cache[rl] then korblox_cache[rl]={MeshId=rl.MeshId,Transparency=rl.Transparency} end
            pcall(function() rl.MeshId="rbxassetid://902942093" rl.Transparency=1 end)
        end
        if rf then
            if not korblox_cache[rf] then korblox_cache[rf]={MeshId=rf.MeshId,Transparency=rf.Transparency} end
            pcall(function() rf.MeshId="rbxassetid://902942089" rf.Transparency=1 end)
        end
    elseif next(korblox_cache) then
        for p,d in pairs(korblox_cache) do if p and p.Parent then pcall(function()
            if d.MeshId then p.MeshId=d.MeshId end if d.TextureID then p.TextureID=d.TextureID end if d.Transparency~=nil then p.Transparency=d.Transparency end
        end) end end
        korblox_cache={}
    end
    if CFG.FakeHeadless then
        local head=c:FindFirstChild("Head")
        if head then
            if not headless_cache[head] then headless_cache[head]={Transparency=head.Transparency,MeshId=head.MeshId} end
            head.Transparency=1
            for _,d in ipairs(head:GetChildren()) do if d:IsA("Decal") then if headless_cache[d]==nil then headless_cache[d]=d.Transparency end d.Transparency=1 end end
        end
    elseif next(headless_cache) then
        for obj,d in pairs(headless_cache) do if obj and obj.Parent then pcall(function()
            if type(d)=="table" then if d.Transparency~=nil then obj.Transparency=d.Transparency end if d.MeshId then obj.MeshId=d.MeshId end
            else obj.Transparency=d end
        end) end end
        headless_cache={}
    end
end))

-- ESP
esp_holder=Instance.new("ScreenGui")
esp_holder.Name="ClumsyESP" esp_holder.ResetOnSpawn=false esp_holder.IgnoreGuiInset=true
esp_holder.DisplayOrder=990 esp_holder.ZIndexBehavior=Enum.ZIndexBehavior.Sibling safeParent(esp_holder)
-- Aspect/Input fix: keep a 2D hit surface synchronized with each visible ESP icon.
esp_input_gui=Instance.new("ScreenGui")
esp_input_gui.Name="ClumsyESP_Input" esp_input_gui.ResetOnSpawn=false esp_input_gui.IgnoreGuiInset=true
esp_input_gui.DisplayOrder=996 esp_input_gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling safeParent(esp_input_gui)
esp_cache={}

local function performESPClick(p)
    local mode=CFG.ESPClickAction
    if mode~=1 and mode~=2 then return end
    local char=p and p.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local thrp=char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
    if not hum or hum.Health<=0 or not thrp then return end
    if mode==1 then
        local myp=my_hrp()
        if myp then pcall(function() myp.CFrame=CFrame.new(thrp.Position+Vector3.new(0,3,0)); myp.AssemblyLinearVelocity=Vector3.zero; myp.AssemblyAngularVelocity=Vector3.zero end) end
    else
        task.spawn(function() pcall(function() doFling(p) end) end)
    end
end

local function buildESP(p)
    if esp_cache[p] then return end
    local box=Instance.new("BoxHandleAdornment")
    box.Adornee=nil box.AlwaysOnTop=true box.ZIndex=5 box.Size=Vector3.new(2,2,2) box.Transparency=0.4
    box.Color3=CURRENT_ACCENT box.Parent=esp_holder box.Visible=false
    local bill=Instance.new("BillboardGui")
    bill.Name="CH_ESP_Bill" bill.Size=UDim2.new(0,200,0,48) bill.StudsOffset=Vector3.new(0,2.2,0)
    bill.AlwaysOnTop=true bill.LightInfluence=0 bill.MaxDistance=2000
    bill.Active=true bill.Enabled=false bill.Parent=esp_holder
    local avFrame=Instance.new("Frame",bill)
    avFrame.AnchorPoint=Vector2.new(0,0.5) avFrame.Position=UDim2.new(0,0,0.5,0)
    avFrame.Size=UDim2.new(0,40,0,40) avFrame.BackgroundColor3=Color3.fromRGB(15,15,20)
    avFrame.BorderSizePixel=0 avFrame.Visible=false avFrame.Active=true
    Instance.new("UICorner",avFrame).CornerRadius=UDim.new(1,0)
    local avStroke=Instance.new("UIStroke",avFrame) avStroke.Color=CURRENT_ACCENT avStroke.Thickness=1.6 avStroke.Transparency=0.15
    local avImg=Instance.new("ImageLabel",avFrame)
    avImg.Size=UDim2.new(1,-2,1,-2) avImg.Position=UDim2.new(0,1,0,1)
    avImg.BackgroundTransparency=1 avImg.Image=""
    Instance.new("UICorner",avImg).CornerRadius=UDim.new(1,0)
    local clickBtn=Instance.new("TextButton",avFrame)
    clickBtn.BackgroundTransparency=1 clickBtn.Size=UDim2.new(1,0,1,0)
    clickBtn.Text="" clickBtn.ZIndex=10 clickBtn.AutoButtonColor=false
    clickBtn.Active=true clickBtn.Selectable=true
    local screenBtn=Instance.new("TextButton",esp_input_gui)
    screenBtn.Name="ESPInput_"..tostring(p.UserId) screenBtn.BackgroundTransparency=1 screenBtn.BorderSizePixel=0
    screenBtn.Text="" screenBtn.AutoButtonColor=false screenBtn.Active=true screenBtn.Selectable=true
    screenBtn.Visible=false screenBtn.ZIndex=100
    local nL=Instance.new("TextLabel",bill)
    nL.Position=UDim2.new(0,46,0,3) nL.Size=UDim2.new(1,-46,0,22)
    nL.BackgroundTransparency=1 nL.Text="" nL.Visible=false
    nL.TextColor3=Color3.fromRGB(230,240,255) nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)
    nL.Font=Enum.Font.GothamBold nL.TextSize=13 nL.TextXAlignment=Enum.TextXAlignment.Left
    local dL=Instance.new("TextLabel",bill)
    dL.Position=UDim2.new(0,46,0,26) dL.Size=UDim2.new(1,-46,0,18)
    dL.BackgroundTransparency=1 dL.Text="" dL.Visible=false
    dL.TextColor3=Color3.fromRGB(170,170,170) dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)
    dL.Font=Enum.Font.GothamMedium dL.TextSize=10 dL.TextXAlignment=Enum.TextXAlignment.Left
    local hl=Instance.new("Highlight")
    hl.FillTransparency=1 hl.OutlineColor=CURRENT_ACCENT hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Adornee=nil hl.Enabled=false hl.Parent=esp_holder
    esp_cache[p]={
        box=box,bill=bill,avFrame=avFrame,avImg=avImg,avStroke=avStroke,nL=nL,dL=dL,hl=hl,clickBtn=clickBtn,screenBtn=screenBtn,
        lastChar=nil,lastRole=nil,lastRoleColor=nil,lastDistance=-1,lastSizeChar=nil,lastSize=nil,
    }
    task.spawn(function()
        local ok,url=pcall(function() return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
        if ok and url and esp_cache[p] and esp_cache[p].avImg and esp_cache[p].avImg.Parent then esp_cache[p].avImg.Image=url end
    end)
    -- Aspect-safe click handler: both the native BillboardGui button and the
    -- synchronized 2D button call the exact same TP/Fling action.
    local clickBusy=false
    local function activateESPClick()
        if clickBusy then return end
        clickBusy=true
        task.defer(function()
            performESPClick(p)
            task.delay(0.12,function() clickBusy=false end)
        end)
    end
    clickBtn.Activated:Connect(activateESPClick)
    screenBtn.Activated:Connect(activateESPClick)
end
for _,p in ipairs(Players:GetPlayers()) do if p~=LP then buildESP(p) end end
track(Players.PlayerAdded:Connect(function(p) if p~=LP then buildESP(p) end end))
track(Players.PlayerRemoving:Connect(function(p)
    local e=esp_cache[p]
    if e then
        if e.box then e.box:Destroy() end
        if e.bill then e.bill:Destroy() end
        if e.hl then e.hl:Destroy() end
        if e.screenBtn then e.screenBtn:Destroy() end
        esp_cache[p]=nil
    end
end))
track(RunService.Heartbeat:Connect(function()
    -- ESP is visual information; 10 Hz is sufficient and avoids doing
    -- GetExtentsSize/role checks for every player on every rendered frame.
    local now=os.clock()
    if now-(esp_cache._tick or 0)<0.10 then return end
    esp_cache._tick=now

    local myp=my_hrp()
    local myPos=myp and myp.Position or nil

    for p,e in pairs(esp_cache) do
        if typeof(p)~="Instance" or not e or not e.bill then continue end

        local char=p.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")

        if CFG.ESP and char and hrp and hum and hum.Health>0 then
            local d=myPos and (hrp.Position-myPos).Magnitude or nil
            local skip=CFG.ESPDistanceMax>0 and d and d>CFG.ESPDistanceMax

            if skip then
                if e.box then e.box.Adornee=nil e.box.Visible=false end
                e.bill.Adornee=nil e.bill.Enabled=false
                e.hl.Adornee=nil e.hl.Enabled=false
            else
                local adorn=char:FindFirstChild("Head") or hrp
                if e.bill.Adornee~=adorn then e.bill.Adornee=adorn end
                e.bill.Enabled=true

                if CFG.ESPBox and e.box then
                    if e.lastSizeChar~=char then
                        local ok,size=pcall(function()
                            return char:GetExtentsSize()+Vector3.new(0.2,0.2,0.2)
                        end)
                        if ok and size then
                            e.lastSize=size
                            e.lastSizeChar=char
                        end
                    end
                    if e.lastSize then e.box.Size=e.lastSize end
                    e.box.Adornee=char
                    e.box.Visible=true
                elseif e.box then
                    e.box.Visible=false
                end

                local role=playerRole(p)
                if e.lastChar~=char or e.lastRole~=role then
                    e.lastChar=char
                    e.lastRole=role
                    e.lastRoleColor=roleColorOf(role)
                end
                e.hl.Adornee=char
                if e.lastRoleColor then e.hl.OutlineColor=e.lastRoleColor end
                e.hl.Enabled=true

                if e.nL.Visible~=CFG.ESPName then e.nL.Visible=CFG.ESPName end
                if CFG.ESPName and e.nL.Text~=p.Name then e.nL.Text=p.Name end

                if e.avFrame then
                    if e.avFrame.Visible~=CFG.ESPAvatar then e.avFrame.Visible=CFG.ESPAvatar end
                    if CFG.ESPAvatar and e.lastRoleColor then e.avStroke.Color=e.lastRoleColor end
                end

                if e.dL.Visible~=CFG.ESPDist then e.dL.Visible=CFG.ESPDist end
                if CFG.ESPDist and d then
                    local rounded=math.floor(d)
                    if e.lastDistance~=rounded then
                        e.lastDistance=rounded
                        e.dL.Text=rounded.." st"
                    end
                end
            end
        else
            if e.box then e.box.Adornee=nil e.box.Visible=false end
            e.bill.Adornee=nil e.bill.Enabled=false
            e.hl.Adornee=nil e.hl.Enabled=false
        end

        -- Synchronize the 2D hitbox with the actual on-screen avatar icon.
        if e.screenBtn and e.bill then
            local visible=e.bill.Enabled and e.avFrame.Visible and e.avFrame.AbsoluteSize.X>0 and e.avFrame.AbsoluteSize.Y>0
            if visible then
                local pos=e.avFrame.AbsolutePosition
                local size=e.avFrame.AbsoluteSize
                e.screenBtn.Position=UDim2.fromOffset(math.floor(pos.X+0.5),math.floor(pos.Y+0.5))
                e.screenBtn.Size=UDim2.fromOffset(math.max(1,math.floor(size.X+0.5)),math.max(1,math.floor(size.Y+0.5)))
                e.screenBtn.Visible=true
            else
                e.screenBtn.Visible=false
            end
        end
    end
end))

-- Gun ESP (v32)
GunESP=(function()
    local S={enabled=false,hl=true,txt=true,col=1}
    local cache={}
    local holder=Instance.new("Folder") holder.Name="CH_GunESP" safeParent(holder)
    local function collect()
        local out={}
        for _,obj in ipairs(WS:GetDescendants()) do
            if obj.Name=="GunDrop" and (obj:IsA("BasePart") or obj:IsA("Model")) then
                local part=obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true))
                if part and part.Parent then out[#out+1]={obj=obj,part=part,adorn=obj} end
            end
        end
        return out
    end
    local function clear_one(obj)
        local c=cache[obj]
        if c then if c.hl then pcall(function() c.hl:Destroy() end) end if c.txt then pcall(function() c.txt:Remove() end) end cache[obj]=nil end
    end
    track(RunService.RenderStepped:Connect(function()
        if not S.enabled then for obj in pairs(cache) do clear_one(obj) end return end
        local list=collect() local live={} local col=TRACER_VALUES[S.col] or CURRENT_ACCENT
        for _,entry in ipairs(list) do
            live[entry.obj]=true
            local c=cache[entry.obj] if not c then c={hl=nil,txt=nil} cache[entry.obj]=c end
            if S.hl then
                if not c.hl or not c.hl.Parent then c.hl=Instance.new("Highlight") c.hl.FillTransparency=1 c.hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop c.hl.Parent=holder end
                c.hl.Adornee=entry.adorn c.hl.OutlineColor=col c.hl.OutlineTransparency=0 c.hl.Enabled=true
            elseif c.hl then c.hl.Enabled=false end
            if S.txt then
                if not c.txt then local ok,t=pcall(function() return Drawing.new("Text") end) if ok then t.Center=true t.Outline=true t.Size=10 t.Text="Gun" c.txt=t end end
                if c.txt then
                    local cam=WS.CurrentCamera
                    local sp=cam and cam:WorldToViewportPoint(entry.part.Position)
                    if sp and sp.Z>0 then c.txt.Position=Vector2.new(sp.X,sp.Y) c.txt.Color=col c.txt.Visible=true else c.txt.Visible=false end
                end
            elseif c.txt then c.txt.Visible=false end
        end
        for obj in pairs(cache) do if not live[obj] then clear_one(obj) end end
    end))
    return {
        set=function(on) S.enabled=on if not on then for obj in pairs(cache) do clear_one(obj) end end end,
        set_hl=function(v) S.hl=v end,
        set_txt=function(v) S.txt=v end,
        set_col=function(i) S.col=i end,
    }
end)()

-- Skeleton
SkeletonESP=(function()
    local R6_BONES={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
    local R15_BONES={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
    local S={enabled=false,mode=1,color=1}
    local cache={}
    local function new_line() local ok,l=pcall(function() return Drawing.new("Line") end) if ok and l then l.Visible=false l.Thickness=1.5 l.Transparency=1 return l end end
    local function destroy_lines(t) if not t then return end for _,l in ipairs(t) do pcall(function() l:Remove() end) end end
    track(RunService.RenderStepped:Connect(function()
        if not S.enabled then for _,c in pairs(cache) do for _,l in ipairs(c.lines) do if l then l.Visible=false end end end return end
        local cam=WS.CurrentCamera if not cam then return end
        for pl,c in pairs(cache) do
            if not pl.Parent or not pl.Character or not alive(pl) then
                for _,l in ipairs(c.lines) do if l then l.Visible=false end end
            else
                local char=pl.Character local hum=char:FindFirstChildOfClass("Humanoid")
                local bones=(hum and hum.RigType==Enum.HumanoidRigType.R15) and R15_BONES or R6_BONES
                while #c.lines<#bones do local nl=new_line() if nl then c.lines[#c.lines+1]=nl end end
                local col=(S.mode==1) and roleColorOf(playerRole(pl)) or COLOR_VALUES[S.color]
                for i,bone in ipairs(bones) do
                    local a=char:FindFirstChild(bone[1]) local b=char:FindFirstChild(bone[2]) local l=c.lines[i]
                    if a and b and l then
                        local ap,aOn=cam:WorldToViewportPoint(a.Position) local bp,bOn=cam:WorldToViewportPoint(b.Position)
                        if aOn and bOn and ap.Z>0 and bp.Z>0 then l.From=Vector2.new(ap.X,ap.Y) l.To=Vector2.new(bp.X,bp.Y) l.Color=col l.Visible=true
                        else l.Visible=false end
                    elseif l then l.Visible=false end
                end
                for i=#bones+1,#c.lines do if c.lines[i] then c.lines[i].Visible=false end end
            end
        end
    end))
    track(Players.PlayerAdded:Connect(function(p) if p~=LP and not cache[p] then cache[p]={lines={}} end end))
    track(Players.PlayerRemoving:Connect(function(p) if cache[p] then destroy_lines(cache[p].lines) cache[p]=nil end end))
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then cache[p]={lines={}} end end
    return {
        set=function(on) S.enabled=on end,
        set_mode=function(m) S.mode=m end,
        set_color=function(i) S.color=i end,
        clear=function() for _,c in pairs(cache) do destroy_lines(c.lines) end cache={} end,
    }
end)()

-- Ghost Chams · local neon/translucent body
-- Lightweight: no per-frame scan. The character is touched only on toggle/respawn.
GhostChams=(function()
    local S={on=false,color=COLOR_VALUES[1],transparency=0.55}
    local cache={}
    local highlight=nil

    local function clear()
        if highlight then pcall(function() highlight:Destroy() end) end
        highlight=nil
        for part,data in pairs(cache) do
            if part and part.Parent then
                pcall(function()
                    part.Material=data.Material
                    part.Transparency=data.Transparency
                    part.Color=data.Color
                end)
            end
        end
        cache={}
    end

    local function apply()
        clear()
        if not S.on then return end
        local char=LP.Character
        if not char or not char.Parent then return end

        local h=Instance.new("Highlight")
        h.Name="CH_GhostChams"
        h.Adornee=char
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        h.FillColor=S.color
        h.FillTransparency=math.clamp(S.transparency+0.18,0,1)
        h.OutlineColor=S.color
        h.OutlineTransparency=0.05
        h.Enabled=true
        h.Parent=char
        highlight=h

        for _,part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                cache[part]={Material=part.Material,Transparency=part.Transparency,Color=part.Color}
                pcall(function()
                    part.Material=Enum.Material.Neon
                    part.Transparency=math.clamp(S.transparency,0,0.95)
                    part.Color=S.color
                end)
            end
        end
    end

    track(LP.CharacterAdded:Connect(function()
        clear()
        if S.on then task.delay(0.35,apply) end
    end))

    return {
        set=function(v)
            S.on=v and true or false
            CFG.Ghost=S.on
            if S.on then apply() else clear() end
        end,
        set_color=function(i)
            S.color=COLOR_VALUES[i] or S.color
            CFG.GhostColor=i
            if S.on then apply() end
        end,
        set_transparency=function(v)
            S.transparency=math.clamp(tonumber(v) or 0.55,0,0.95)
            CFG.GhostTransparency=S.transparency
            if S.on then apply() end
        end,
        clear=clear,
    }
end)()

-- RoleChams · replaced with the new MM2 role-detection implementation
RoleChams=(function()
    local FORCE_START = false
    local FILL_TRANSPARENCY = 0.5

    local COL_MURDER  = Color3.fromRGB(255, 60, 80)
    local COL_SHERIFF = Color3.fromRGB(100, 180, 255)
    local COL_INNO    = Color3.fromRGB(245, 245, 245)

    local S={
        on=false,
        fill=FILL_TRANSPARENCY,
        mode=1,
        rage_lock=false,
    }

    local chams_cache={}
    local roundMod=nil

    local function getRoundData()
        if not roundMod then
            local ok,m=pcall(function()
                local modules=RSvc:FindFirstChild("Modules")
                local current=modules and modules:FindFirstChild("CurrentRoundClient")
                if not current then return nil end
                return require(current)
            end)
            if ok and type(m)=="table" then roundMod=m end
        end
        return roundMod and roundMod.PlayerData
    end

    local function hasToolRole(player,keywords)
        if not player then return false end
        local char=player.Character
        local bp=player:FindFirstChild("Backpack")
        for _,container in ipairs({char,bp}) do
            if container then
                for _,item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") then
                        local n=string.lower(item.Name)
                        for _,keyword in ipairs(keywords) do
                            if n:find(keyword,1,true) then return true end
                        end
                    end
                end
            end
        end
        return false
    end

    local function normalizeRole(rawRole)
        if type(rawRole) ~= "string" then return nil end
        local role=string.lower(rawRole):gsub("%s+", "")
        if role=="murderer" or role=="murder" then return "murderer" end
        if role=="sheriff" or role=="hero" then return "sheriff" end
        if role=="innocent" then return "innocent" end
        return nil
    end

    local function roundInfoForPlayer(data, player)
        if type(data) ~= "table" or not player then return nil end

        -- MM2 builds have used both player-name keys and other key formats.
        -- Try the direct name key first.
        local direct=data[player.Name]
        if type(direct)=="table" then return direct end

        -- Then match records by common identity fields.
        for key,info in pairs(data) do
            if type(info)=="table" then
                if key==player or key==player.Name or tostring(key)==tostring(player.UserId) then
                    return info
                end
                if info.Player==player or info.Player==player.Name or info.Name==player.Name or info.UserId==player.UserId then
                    return info
                end
            end
        end
        return nil
    end

    local function getRole(player)
        if not player then return "innocent" end

        -- Local player: tools are the only safe local fallback because the round
        -- module may intentionally hide the local role.
        if player==LP then
            if hasToolRole(player,{"knife","нож"}) then return "murderer" end
            if hasToolRole(player,{"gun","pistol","revolver","sheriff"}) then return "sheriff" end
            return "innocent"
        end

        -- Other players: Role Chams use the real current-round role only.
        -- Never infer another player's role from their tools.
        local data=getRoundData()
        local info=roundInfoForPlayer(data,player)
        if type(info)=="table" then
            -- Dead players are not assigned an active role for chams.
            if info.Dead==true then return "innocent" end
            local role=normalizeRole(info.Role or info.role or info.RoleName)
            if role then return role end
        end

        return "innocent"
    end

    local function roleColor(role)
        if role=="murderer" then return COL_MURDER end
        if role=="sheriff" then return COL_SHERIFF end
        return COL_INNO
    end

    local function isAlive(player)
        local char=player and player.Character
        if not char then return false end
        local hum=char:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health>0
    end

    local function clear_one(player)
        local hl=chams_cache[player]
        if hl and hl.Parent then
            pcall(function() hl:Destroy() end)
        end
        chams_cache[player]=nil
    end

    local function clear_all()
        for player in pairs(chams_cache) do
            clear_one(player)
        end
        chams_cache={}
    end

    local function apply_one(player)
        if player==LP then return end

        local char=player.Character
        if not char or not char.Parent then
            clear_one(player)
            return
        end

        if not isAlive(player) then
            clear_one(player)
            return
        end

        local role=getRole(player)
        local col=roleColor(role)
        local hl=chams_cache[player]

        if not hl or not hl.Parent or hl.Adornee~=char then
            clear_one(player)
            hl=Instance.new("Highlight")
            hl.Name="CH_RoleChams"
            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent=char
            chams_cache[player]=hl
        end

        hl.Adornee=char
        hl.FillColor=col
        hl.FillTransparency=math.clamp(S.fill,0,1)
        hl.OutlineColor=col
        hl.OutlineTransparency=0
        hl.Enabled=true
    end

    local function apply_all()
        for _,player in ipairs(Players:GetPlayers()) do
            if player~=LP then
                pcall(apply_one,player)
            end
        end
        for player in pairs(chams_cache) do
            if not player.Parent or not player.Character or not player.Character.Parent then
                clear_one(player)
            end
        end
    end

    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP then
            chams_cache[player]=nil
        end
    end

    track(Players.PlayerRemoving:Connect(function(player)
        clear_one(player)
    end))

    track(Players.PlayerAdded:Connect(function(player)
        if S.on then
            task.delay(0.5,function()
                if S.on then pcall(apply_one,player) end
            end)
        end
    end))

    track(LP.CharacterAdded:Connect(function()
        task.delay(0.5,function()
            if S.on then pcall(apply_all) end
        end)
    end))

    local last_apply=0
    track(RunService.Heartbeat:Connect(function()
        if not S.on then return end
        local now=os.clock()
        if now-last_apply < 0.12 then return end
        last_apply=now
        pcall(apply_all)
    end))

    local api={
        set=function(v)
            -- В Rage Role Chams управляется самим конфигом и не отключается
            -- обычным переключателем/настройками меню.
            if S.rage_lock then
                S.on=true
                CFG.RoleChams=true
            else
                S.on=v and true or false
                CFG.RoleChams=S.on
            end
            if S.on then
                pcall(apply_all)
            else
                clear_all()
            end
        end,
        set_fill=function(t)
            S.fill=math.clamp(tonumber(t) or 0.5,0,1)
            CFG.RoleChamsFill=S.fill
            for _,hl in pairs(chams_cache) do
                if hl and hl.Parent then
                    hl.FillTransparency=S.fill
                end
            end
        end,
        set_mode=function(m)
            -- Всегда используем реальные цвета ролей, без accent-режима.
            S.mode=1
            CFG.RoleChamsMode=1
            if S.on then pcall(apply_all) end
        end,
        set_colors=function(murder,sheriff,innocent)
            if S.rage_lock then
                -- Rage always keeps the actual role palette.
                COL_MURDER=Color3.fromRGB(255,140,0)
                COL_SHERIFF=Color3.fromRGB(100,180,255)
                COL_INNO=Color3.fromRGB(245,245,245)
            else
                if typeof(murder)=="Color3" then COL_MURDER=murder end
                if typeof(sheriff)=="Color3" then COL_SHERIFF=sheriff end
                if typeof(innocent)=="Color3" then COL_INNO=innocent end
            end
            if S.on then pcall(apply_all) end
        end,
        is_on=function() return S.on end,
        set_rage_lock=function(v)
            S.rage_lock=v and true or false
            if S.rage_lock then
                S.mode=1
                S.on=true
                CFG.RoleChams=true
                COL_MURDER=Color3.fromRGB(255,140,0)
                COL_SHERIFF=Color3.fromRGB(100,180,255)
                COL_INNO=Color3.fromRGB(245,245,245)
                pcall(apply_all)
            end
        end,
        clear=clear_all,
    }

    if FORCE_START then
        task.spawn(function()
            S.on=true
            CFG.RoleChams=true
            task.wait(0.5)
            pcall(apply_all)
        end)
    end

    return api
end)()

-- Kill Aura (v32: knife.Parent = char + events)
track(task.spawn(function()
    while true do
        task.wait(math.max(0.01, CFG.KillAuraDelay/1000))
        if CFG.KillAura and hasKnife() then
            local knife=getKnife() local hrp=my_hrp()
            if knife and hrp then
                knife.Parent=LP.Character
                local ev=knife:FindFirstChild("Events")
                if ev then
                    local st=ev:FindFirstChild("KnifeStabbed") local tc=ev:FindFirstChild("HandleTouched")
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p~=LP and alive(p) then
                            local ph=get_hrp(p)
                            if ph and dist(ph.Position,hrp.Position)<=CFG.KillAuraRange then
                                if st then pcall(function() st:FireServer() end) end
                                if tc then pcall(function() tc:FireServer(ph) end) end
                            end
                        end
                    end
                end
            end
        end
    end
end))

-- Spinbot
track(RunService.Heartbeat:Connect(function(dt)
    if not CFG.Spinbot then local h=my_hum() if h and not h.AutoRotate then h.AutoRotate=true end return end
    local hrp,hum=my_hrp(),my_hum() if not hrp or not hum then return end
    hum.AutoRotate=false
    pcall(function() hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(CFG.SpinbotSpeed or 45)*dt*60,0) end)
end))

-- Silent Aim (v32)
local SAU={ws=nil,om=nil,os_=nil,fa=nil,fs=nil,ft=0}
local sa_t,sa_p,sa_i,sa_n={},{},0,0
local sa_tr={part=nil,t=0,pos=nil,vel=Vector3.zero,target=nil,last_track=0}
local function sa_push(now,pos) sa_i=sa_i%20+1 sa_t[sa_i]=now sa_p[sa_i]=pos if sa_n<20 then sa_n=sa_n+1 end end
local function sa_get(k) local i=(sa_i-k-1)%20+1 return sa_t[i],sa_p[i] end
local function sa_track(now)
    if now-sa_tr.last_track<0.05 then return end
    sa_tr.last_track=now
    local target=getMurdererFromRound()
    sa_tr.target=target
    local part=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not part then sa_tr.part=nil return end
    local pos=part.Position
    if sa_tr.part~=part or not sa_tr.pos then sa_tr.part,sa_tr.pos,sa_tr.t=part,pos,now sa_tr.vel=Vector3.zero sa_n,sa_i=0,0 sa_push(now,pos) return end
    local dt=now-sa_tr.t if dt<=0.001 or dt>0.5 then return end
    sa_push(now,pos) sa_tr.t=now
    if sa_n<3 then return end
    local t0,p0=sa_get(0) local t1,p1=sa_get(math.min(sa_n-1,5))
    local d=t0-t1 if d>0.01 then sa_tr.vel=(p0-p1)/d end
end
local sa_los_cache={t=0,from=nil,to=nil,result=true}
local function sa_los(from,to)
    local delta=to-from
    if delta.Magnitude<0.5 then return true end

    local now=os.clock()
    if sa_los_cache.from and sa_los_cache.to
        and now-sa_los_cache.t<0.035
        and (sa_los_cache.from-from).Magnitude<0.05
        and (sa_los_cache.to-to).Magnitude<0.05 then
        return sa_los_cache.result
    end

    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={LP.Character}
    local hit=WS:Raycast(from,delta,params)
    local result
    if not hit then
        result=true
    else
        local m=sa_tr.target
        if m and m.Character and (hit.Instance==m.Character or hit.Instance:IsDescendantOf(m.Character)) then
            result=true
        else
            result=(hit.Position-from).Magnitude>=delta.Magnitude-0.75
        end
    end

    sa_los_cache.t=now
    sa_los_cache.from=from
    sa_los_cache.to=to
    sa_los_cache.result=result
    return result
end
local function sa_restore() if SAU.fa and SAU.fs and SAU.fa.Parent then pcall(function() SAU.fa.CFrame=SAU.fs end) end SAU.fa,SAU.fs=nil,nil end
local function sa_force(cf)
    local c=LP.Character local hrp=c and c:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local att=hrp:FindFirstChild("GunRaycastAttachment") if not att then return false end
    if SAU.fa and SAU.fa~=att then sa_restore() end
    if not SAU.fa then local ok,s=pcall(function() return att.CFrame end) if not ok then return false end SAU.fa,SAU.fs=att,s end
    SAU.ft=os.clock()
    local ok=pcall(function() att.WorldCFrame=cf end)
    if not ok then sa_restore() return false end
    task.defer(sa_restore) return true
end
local function sa_aim()
    local m=sa_tr.target
    if not m or not m.Character then
        m=getMurdererFromRound()
        sa_tr.target=m
    end
    if not m or not m.Character then return nil end
    local part=m.Character:FindFirstChild("HumanoidRootPart") or m.Character:FindFirstChild("Head")
    if not part then return nil end
    local c=LP.Character local hrp=c and c:FindFirstChild("HumanoidRootPart") if not hrp then return nil end
    local att=hrp:FindFirstChild("GunRaycastAttachment") if not att then return nil end
    local ping=0.1 pcall(function() ping=math.clamp(LP:GetNetworkPing(),0.02,0.4) end)
    local base=part.Position
    if CFG.SilentPredict and sa_tr.vel and sa_tr.vel.Magnitude>0.5 then base=base+sa_tr.vel*ping end
    if CFG.SilentForce then
        local origin=att.WorldPosition
        if sa_los(origin,base) then return CFrame.new(origin,base),CFrame.new(base) end
        for i=0,23 do
            local ang=(i/24)*math.pi*2
            for _,d in ipairs({12,18,24}) do
                local probe=base+Vector3.new(math.cos(ang)*d,0,math.sin(ang)*d)
                if sa_los(probe,base) then return CFrame.new(probe,base),CFrame.new(base) end
            end
        end
    end
    return CFrame.new(att.WorldPosition,base),CFrame.new(base)
end
local function sa_install()
    if SAU.ws then return end
    local ok,m=pcall(function() return require(RSvc:WaitForChild("ClientServices"):WaitForChild("WeaponService")) end)
    if not ok or type(m)~="table" then return end
    SAU.ws=m
    pcall(function() setreadonly(m,false) end)
    if type(m.GetMouseTargetCFrame)=="function" then
        SAU.om=m.GetMouseTargetCFrame
        m.GetMouseTargetCFrame=function(self,...)
            if CFG.SilentAim and hasGun() then
                local oc,ac=sa_aim()
                if oc and ac and (not CFG.SilentForce or sa_force(oc)) then return ac end
            end
            return SAU.om(self,...)
        end
    end
    if type(m.GetTargetPosition)=="function" then
        SAU.os_=m.GetTargetPosition
        m.GetTargetPosition=function(self,x,y,...)
            if CFG.SilentAim and hasGun() then
                local oc,ac=sa_aim()
                if oc and ac and (not CFG.SilentForce or sa_force(oc)) then return ac end
            end
            return SAU.os_(self,x,y,...)
        end
    end
end
track(task.spawn(sa_install))
track(task.spawn(function() while true do task.wait(2) if not SAU.ws then pcall(sa_install) end end end))
track(RunService.Heartbeat:Connect(function()
    local now=os.clock()
    if CFG.SilentAim or CFG.SilentAutoShoot then
        sa_track(now)
    elseif sa_tr.part then
        sa_tr.part=nil
        sa_tr.target=nil
    end
    if SAU.fa and now-SAU.ft>0.08 then sa_restore() end
    if CFG.SilentAim and CFG.SilentAutoShoot and hasGun() then
        local gun=getGun()
        if gun and gun.Parent~=LP.Character then local hum=my_hum() if hum then pcall(function() hum:EquipTool(gun) end) end end
        if gun and gun.Parent==LP.Character and sa_tr.part then
            if os.clock()-(CFG._lastShot or 0)>CFG.SilentAutoDelay/1000 then
                CFG._lastShot=os.clock() pcall(function() gun:Activate() end)
            end
        end
    end
end))

-- Knife Silent (full v32)
KnifeSilent=(function()
    local S={enabled=false,predict=true,insta=false,range=400,leadScale=1,airScale=0.35,leadAdd=0,throwSpeed=96,impactRadius=12}
    local trackers={}
    local GRAVITY=workspace.Gravity or 196.2
    local SNAP_CAP=20 local FIT_WINDOW=0.13
    local function flat(v) return Vector3.new(v.X,0,v.Z) end
    local function new_tracker() return {t=table.create(SNAP_CAP,0),p=table.create(SNAP_CAP,Vector3.zero),n=0,i=0,part=nil,pos=nil,time=0,vel=Vector3.zero} end
    local function snap_push(tr,now,pos) tr.i=tr.i%SNAP_CAP+1 tr.t[tr.i]=now tr.p[tr.i]=pos if tr.n<SNAP_CAP then tr.n=tr.n+1 end end
    local function snap_get(tr,k) local idx=(tr.i-k-1)%SNAP_CAP+1 return tr.t[idx],tr.p[idx] end
    local function fit_velocity(tr)
        if tr.n<3 then return nil end
        local newest=snap_get(tr,0) local used,sum_d=0,0
        for k=0,tr.n-1 do local t=snap_get(tr,k) if newest-t>FIT_WINDOW then break end used=used+1 sum_d=sum_d+(t-newest) end
        if used<3 then return nil end
        local mean_d=sum_d/used local num,den=Vector3.zero,0
        for k=0,used-1 do local t,p=snap_get(tr,k) local d=(t-newest)-mean_d num=num+p*d den=den+d*d end
        if den<1e-8 then return nil end
        return num/den
    end
    local function update_tracker(pl,part,now)
        if not trackers[pl] then trackers[pl]=new_tracker() end
        local tr=trackers[pl] local pos=part.Position
        if part~=tr.part or not tr.pos then tr.part,tr.pos,tr.time=part,pos,now tr.vel,tr.n,tr.i=Vector3.zero,0,0 snap_push(tr,now,pos) return end
        local dt=now-tr.time local shift=(pos-tr.pos).Magnitude
        if dt>0.75 or shift>140 then tr.part,tr.pos,tr.time=part,pos,now tr.vel,tr.n,tr.i=Vector3.zero,0,0 snap_push(tr,now,pos) return end
        if shift<0.004 or dt<=0 then return end
        snap_push(tr,now,pos) tr.pos,tr.time=pos,now
        local v=fit_velocity(tr) if v then tr.vel=v end
    end
    local function target_part_of(char)
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("Head")
    end
    local function pick_target()
        local hrp=my_hrp() if not hrp then return nil,nil,nil end
        local myPos=hrp.Position local best,bp,bt,bd=nil,nil,nil,S.range
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LP and alive(pl) then
                local part=target_part_of(pl.Character)
                if part then local d=(part.Position-myPos).Magnitude if d<bd then bd=d best,bp,bt=pl,part,trackers[pl] end end
            end
        end
        return best,bp,bt
    end
    local function predict_aim(tr,part,origin)
        if not S.predict or not tr then return part.Position end
        local ping=0.1 pcall(function() ping=math.clamp(LP:GetNetworkPing(),0.02,0.4) end)
        local base=part.Position
        if not origin then return base end
        local d=(base-origin).Magnitude
        local travel=math.clamp(d/S.throwSpeed,0,0.7)
        local total=ping*S.leadScale+S.leadAdd+travel
        local vel=tr.vel or Vector3.zero
        local hvel=flat(vel)*total local vy=vel.Y
        local airT=total*S.airScale
        local offY=vy*airT-0.5*GRAVITY*airT*airT
        return base+Vector3.new(hvel.X,offY,hvel.Z)
    end
    local function direct_kill(part)
        if not part or not part.Parent then return false end
        local knife=getKnife() if not knife then return false end
        knife.Parent=LP.Character
        local ev=knife:FindFirstChild("Events") if not ev then return false end
        local st=ev:FindFirstChild("KnifeStabbed") local tc=ev:FindFirstChild("HandleTouched")
        if not st or not tc then return false end
        pcall(function() st:FireServer() tc:FireServer(part) end) return true
    end
    local hook_installed=false
    local function install_hook()
        if hook_installed then return end
        local ok,wm=pcall(function() return require(RSvc:WaitForChild("ClientServices"):WaitForChild("WeaponService")) end)
        if not ok or type(wm)~="table" then return end
        hook_installed=true
        pcall(function() setreadonly(wm,false) end)
        local orig=wm.GetMouseTargetCFrame
        if type(orig)=="function" then
            wm.GetMouseTargetCFrame=function(self,...)
                if S.enabled and getKnife() then
                    local _,part,tr=pick_target()
                    if part then
                        local origin=my_hrp() and my_hrp().Position
                        local aim=predict_aim(tr,part,origin)
                        if S.insta and (aim-part.Position).Magnitude<=S.impactRadius then direct_kill(part) end
                        return CFrame.new(aim)
                    end
                end
                return orig(self,...)
            end
        end
    end
    track(task.spawn(function() while true do task.wait(2) if not hook_installed then pcall(install_hook) end end end))
    track(task.spawn(install_hook))
    track(RunService.Heartbeat:Connect(function()
        if not S.enabled then return end
        local now=os.clock()
        for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP then local part=target_part_of(pl.Character) if part and part.Parent then update_tracker(pl,part,now) end end end
    end))
    return {
        set=function(on) S.enabled=on if on then pcall(install_hook) end end,
        set_predict=function(v) S.predict=v end,
        set_insta=function(v) S.insta=v end,
        set_range=function(v) S.range=v end,
        set_leadScale=function(v) S.leadScale=v end,
        set_airScale=function(v) S.airScale=v end,
        set_leadAdd=function(v) S.leadAdd=v end,
        set_throwSpeed=function(v) S.throwSpeed=v end,
        set_impactRadius=function(v) S.impactRadius=v end,
    }
end)()

-- Wall Shot
PistolWallShotModule=(function()
    local busy=false
    local function isPistol(item)
        if not item or not item:IsA("Tool") then return false end
        local n=string.lower(item.Name)
        return n:find("pistol",1,true) or n:find("revolver",1,true) or n:find("gun",1,true)
    end
    local function findPistol()
        local c=LP.Character if not c then return nil end
        local held=c:FindFirstChildOfClass("Tool") if isPistol(held) then return held end
        local bp=LP:FindFirstChild("Backpack") if bp then for _,item in ipairs(bp:GetChildren()) do if isPistol(item) then return item end end end
    end
    local function fire()
        if busy or not CFG.WallShot then return end
        busy=true
        pcall(function()
            local c=LP.Character local hum=c and c:FindFirstChildOfClass("Humanoid")
            if not c or not hum then return end
            local gun=findPistol() if not gun then return end
            if gun.Parent~=c then hum:EquipTool(gun) task.wait(0.12) end
            if gun.Parent~=c then return end
            pcall(function() gun:Activate() end)
        end)
        busy=false
    end
    local inputConn=nil
    local function stop() if inputConn then pcall(function() inputConn:Disconnect() end) inputConn=nil end end
    local function start()
        stop()
        inputConn=UserInputService.InputBegan:Connect(function(input,processed)
            if processed or not CFG.WallShot then return end
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then task.spawn(fire) end
        end)
    end
    return {fire=fire,set=function(v) CFG.WallShot=v and true or false if v then start() else stop() end end,stop=stop}
end)()

-- ═══════════════════════════════════════════════════════════
-- AUTO GUN PICK · SHITARO
-- Автоматически подбирает выпавший пистолет
-- ═══════════════════════════════════════════════════════════
AutoGunModule=(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local FORCE_START = true
    local RANGE = 800
    local POLL_RATE = 0.06

    local ENABLED = false
    local GRABBING = false
    local round_mod = nil

    local function my_hrp()
        local c = LP.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    local function my_hum()
        local c = LP.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end

    local function has_knife()
        local char = LP.Character
        if char and char:FindFirstChild("Knife") then return true end
        local bp = LP:FindFirstChildOfClass("Backpack")
        if bp and bp:FindFirstChild("Knife") then return true end
        return false
    end

    local function has_gun()
        local char = LP.Character
        if char and char:FindFirstChild("Gun") then return true end
        local bp = LP:FindFirstChildOfClass("Backpack")
        if bp and bp:FindFirstChild("Gun") then return true end
        return false
    end

    local function has_role()
        if not round_mod then
            local ok, m = pcall(function()
                return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
            end)
            if ok and type(m) == "table" then
                round_mod = m
            end
        end
        local d = round_mod and round_mod.PlayerData
        if type(d) ~= "table" then return false end
        local me = d[LP.Name]
        return me ~= nil and me.Role ~= nil and not me.Dead
    end

    local function find_all_gun_drops()
        local list = {}
        for _, obj in ipairs(WS:GetDescendants()) do
            if obj.Name == "GunDrop" and (obj:IsA("BasePart") or obj:IsA("Model")) then
                local part = obj:IsA("BasePart") and obj
                    or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true))
                if part and part.Parent then
                    list[#list + 1] = { obj = obj, part = part }
                end
            end
        end
        return list
    end

    local function is_free(obj)
        if not obj or not obj.Parent then return false end
        for _, pl in ipairs(Players:GetPlayers()) do
            local c = pl.Character
            local bp = pl:FindFirstChildOfClass("Backpack")
            if c and (obj:IsDescendantOf(c) or obj == c) then return false end
            if bp and (obj:IsDescendantOf(bp) or obj == bp) then return false end
        end
        return true
    end

    local function find_nearest_drop()
        local hrp = my_hrp()
        if not hrp then return nil end
        local myPos = hrp.Position
        local best, bestDist = nil, RANGE
        for _, entry in ipairs(find_all_gun_drops()) do
            if is_free(entry.obj) then
                local d = (entry.part.Position - myPos).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = entry
                end
            end
        end
        return best
    end

    local function gather_touch_targets(obj)
        local list, seen = {}, {}
        local function add(p)
            if p and not seen[p] and p:IsA("BasePart") and p:FindFirstChildOfClass("TouchTransmitter") then
                seen[p] = true
                list[#list + 1] = p
            end
        end
        if obj:IsA("BasePart") then add(obj) end
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then add(d) end
        end
        return list
    end

    local function gather_prompts(obj)
        local list = {}
        if obj:IsA("ProximityPrompt") then list[#list + 1] = obj end
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("ProximityPrompt") then list[#list + 1] = d end
        end
        return list
    end

    local function grab_gun(entry)
        if GRABBING then return end
        local hrp = my_hrp()
        local hum = my_hum()
        if not hrp or not hum or hum.Health <= 0 then return end
        if not entry or not entry.obj or not entry.obj.Parent then return end

        GRABBING = true

        local savedCF = hrp.CFrame
        local savedVel = hrp.AssemblyLinearVelocity
        local savedAng = hrp.AssemblyAngularVelocity

        local targetPos = entry.part.Position + Vector3.new(0, 1.5, 0)
        pcall(function()
            hrp.CFrame = CFrame.new(targetPos)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        task.wait(0.02)

        if type(firetouchinterest) == "function" then
            local targets = gather_touch_targets(entry.obj)
            for _, tp in ipairs(targets) do
                pcall(firetouchinterest, hrp, tp, 0)
                pcall(firetouchinterest, hrp, tp, 1)
            end
            pcall(function()
                for _, myPart in ipairs(LP.Character:GetDescendants()) do
                    if myPart:IsA("BasePart") then
                        for _, tp in ipairs(targets) do
                            firetouchinterest(myPart, tp, 0)
                            firetouchinterest(myPart, tp, 1)
                        end
                    end
                end
            end)
        end

        task.wait(0.01)

        if type(fireproximityprompt) == "function" then
            for _, pr in ipairs(gather_prompts(entry.obj)) do
                pcall(fireproximityprompt, pr)
            end
        end

        if entry.obj:IsA("Tool") then
            pcall(function()
                entry.obj.Parent = LP.Character
            end)
        end

        task.wait(0.025)

        -- Restore the exact pre-pickup position immediately, then confirm it
        -- again on the next heartbeat so the temporary pickup teleport does not
        -- leave the player at the gun location.
        local function restore_position()
            local curHrp = my_hrp()
            if curHrp and curHrp.Parent then
                pcall(function()
                    curHrp.CFrame = savedCF
                    curHrp.AssemblyLinearVelocity = savedVel
                    curHrp.AssemblyAngularVelocity = savedAng
                end)
            end
        end
        restore_position()
        RunService.Heartbeat:Wait()
        restore_position()
        GRABBING = false
    end

    track(task.spawn(function()
        while true do
            task.wait(POLL_RATE)
            if ENABLED and not GRABBING then
                if not has_knife() and not has_gun() then
                    local entry = find_nearest_drop()
                    if entry then
                        task.spawn(grab_gun, entry)
                    end
                end
            end
        end
    end))

    track(WS.DescendantAdded:Connect(function(obj)
        if not ENABLED then return end
        if obj.Name ~= "GunDrop" then return end
        if not (obj:IsA("BasePart") or obj:IsA("Model")) then return end

        task.wait(0.015)
        if not ENABLED or GRABBING then return end
        if has_knife() or has_gun() then return end

        local part = obj:IsA("BasePart") and obj
            or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true))
        if part and part.Parent then
            task.spawn(grab_gun, { obj = obj, part = part })
        end
    end))

    track(LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        GRABBING = false
    end))

    getgenv().AUTOGUN = {
        set = function(v)
            ENABLED = v and true or false
        end,
        set_range = function(v)
            RANGE = tonumber(v) or 800
        end,
        is_on = function()
            return ENABLED
        end,
        grab_now = function()
            local entry = find_nearest_drop()
            if entry then task.spawn(grab_gun, entry) end
        end,
    }

    getgenv().AUTOGUN_UNLOAD = function()
        ENABLED = false
        getgenv().AUTOGUN = nil
    end

    if FORCE_START then
        task.spawn(function()
            task.wait(0.3)
            ENABLED = true
            print("[AUTOGUN] auto-started")
        end)
    end

    print("[AUTOGUN] loaded · SHITARO · авто-старт: " .. tostring(FORCE_START))

    return {
        set = function(v)
            ENABLED = v and true or false
            if ENABLED and not GRABBING then
                local entry = find_nearest_drop()
                if entry and not has_knife() and not has_gun() then
                    task.spawn(grab_gun, entry)
                end
            end
        end,
        set_range = function(v)
            RANGE = tonumber(v) or 800
        end,
        grab_now = function()
            local entry = find_nearest_drop()
            if entry and not GRABBING then
                task.spawn(grab_gun, entry)
            end
        end,
    }
end)()

-- Crosshair (v32 5-mode with rotation)
Crosshair=(function()
    local S={on=false,mode=1,size=12,gap=4,thickness=1,rot=90,color=3,show_outline=true,outline=Color3.fromRGB(0,0,0)}
    local parts={} local rotation=0
    local function remove_all() for i=1,#parts do if parts[i] then pcall(function() parts[i]:Remove() end) end end parts={} end
    local function make_line(color,thickness)
        local ok,l=pcall(function() return Drawing.new("Line") end)
        if not ok or not l then return nil end
        l.Visible=false l.Color=color l.Thickness=thickness l.Transparency=1
        parts[#parts+1]=l return l
    end
    local function build()
        remove_all()
        if not S.on then return end
        if S.mode==1 or S.mode==2 then
            for i=1,4 do if S.show_outline then make_line(S.outline,S.thickness+2) end make_line(COLOR_VALUES[S.color],S.thickness) end
        elseif S.mode==3 or S.mode==4 then for i=1,8 do make_line(COLOR_VALUES[S.color],S.thickness) end
        elseif S.mode==5 then
            if S.show_outline then for i=1,4 do make_line(S.outline,S.thickness+2) end end
            for i=1,4 do make_line(COLOR_VALUES[S.color],S.thickness) end
        end
    end
    track(RunService.RenderStepped:Connect(function(dt)
        if not S.on then for i=1,#parts do if parts[i] then parts[i].Visible=false end end return end
        if #parts==0 then build() end
        local mp=UserInputService:GetMouseLocation() local cx,cy=mp.X,mp.Y
        rotation=(rotation+dt*S.rot)%360 local rad=math.rad(rotation)
        if S.mode==1 then
            local idx=1
            for i=1,4 do
                local ang=(i-1)*math.pi/2
                local sx=cx+S.gap*math.cos(ang) local sy=cy+S.gap*math.sin(ang)
                local ex=cx+(S.gap+S.size)*math.cos(ang) local ey=cy+(S.gap+S.size)*math.sin(ang)
                if S.show_outline then local o=parts[idx] if o then o.From=Vector2.new(sx-1,sy-1) o.To=Vector2.new(ex+1,ey+1) o.Color=S.outline o.Thickness=S.thickness+2 o.Visible=true end idx=idx+1 end
                local l=parts[idx] if l then l.From=Vector2.new(sx,sy) l.To=Vector2.new(ex,ey) l.Color=COLOR_VALUES[S.color] l.Thickness=S.thickness l.Visible=true end idx=idx+1
            end
        elseif S.mode>=2 and S.mode<=4 then
            local arm=S.size local bend=S.thickness*4+8 local idx=1
            for i=1,4 do
                local base_ang=(i-1)*math.pi/2+rad
                local inner=S.gap outer=S.gap+arm
                local sx=cx+inner*math.cos(base_ang) local sy=cy+inner*math.sin(base_ang)
                local mx=cx+outer*math.cos(base_ang) local my=cy+outer*math.sin(base_ang)
                if S.mode==2 then
                    if S.show_outline then local o=parts[idx] if o then o.From=Vector2.new(sx-1,sy-1) o.To=Vector2.new(mx+1,my+1) o.Color=S.outline o.Thickness=S.thickness+2 o.Visible=true end idx=idx+1 end
                    local l=parts[idx] if l then l.From=Vector2.new(sx,sy) l.To=Vector2.new(mx,my) l.Color=COLOR_VALUES[S.color] l.Thickness=S.thickness l.Visible=true end idx=idx+1
                else
                    local bend_ang=base_ang+math.pi/2
                    local bx=mx+bend*math.cos(bend_ang) local by=my+bend*math.sin(bend_ang)
                    local l1=parts[idx] if l1 then l1.From=Vector2.new(sx,sy) l1.To=Vector2.new(mx,my) l1.Color=COLOR_VALUES[S.color] l1.Thickness=S.thickness l1.Visible=true end idx=idx+1
                    local l2=parts[idx] if l2 then l2.From=Vector2.new(mx,my) l2.To=Vector2.new(bx,by) l2.Color=COLOR_VALUES[S.color] l2.Thickness=S.thickness l2.Visible=true end idx=idx+1
                end
            end
        elseif S.mode==5 then
            local idx=1 local base_ang0=math.pi/4
            for i=1,4 do
                local base_ang=(i-1)*math.pi/2+base_ang0+rad
                local outer=S.gap+S.size
                local ex=cx+outer*math.cos(base_ang) local ey=cy+outer*math.sin(base_ang)
                if S.show_outline then local o=parts[idx] if o then o.From=Vector2.new(cx-1,cy-1) o.To=Vector2.new(ex+1,ey+1) o.Color=S.outline o.Thickness=S.thickness+2 o.Visible=true end idx=idx+1 end
                local l=parts[idx] if l then l.From=Vector2.new(cx,cy) l.To=Vector2.new(ex,ey) l.Color=COLOR_VALUES[S.color] l.Thickness=S.thickness l.Visible=true end idx=idx+1
            end
        end
    end))
    return {
        set=function(v) S.on=v if v then build() else for i=1,#parts do if parts[i] then parts[i].Visible=false end end end end,
        set_mode=function(m) S.mode=math.clamp(m,1,5) build() end,
        set_size=function(v) S.size=v end, set_gap=function(v) S.gap=v end,
        set_thickness=function(v) S.thickness=v build() end,
        set_rot=function(v) S.rot=v end,
        set_color=function(i) S.color=i build() end,
        set_outline_on=function(v) S.show_outline=v build() end,
    }
end)()

-- China Hat (Drawing convex hull from v32)
ChinaHat=(function()
    local S={enabled=false,color=1,height=0.6,radius=1.0}
    local CH_DROP=0.02 local CH_SEG=48 local CH_TAU=math.pi*2 local CH_MAX_ROWS=220
    local rows={} local cpos,csize,ccol,shown={},{},{},{}
    local px,py=table.create(CH_SEG+1),table.create(CH_SEG+1)
    local cosT,sinT,ord,stack={},{},table.create(CH_SEG+1),table.create(CH_SEG+2)
    local function rebuild_circle(r) for i=1,CH_SEG do local a=(i-1)/CH_SEG*CH_TAU cosT[i]=math.cos(a)*r sinT[i]=math.sin(a)*r end end
    local function hull(n)
        for i=1,n do ord[i]=i end
        table.sort(ord,function(i,j) return (px[i]<px[j]) or (px[i]==px[j] and py[i]<py[j]) end)
        local m=0
        for k=1,n do
            local i=ord[k] local x,y=px[i],py[i]
            while m>=2 do local o,a=stack[m-1],stack[m] local ox,oy=px[o],py[o] if (px[a]-ox)*(y-oy)-(py[a]-oy)*(x-ox)>0 then break end m=m-1 end
            m=m+1 stack[m]=i
        end
        local lower=m
        for k=n-1,1,-1 do
            local i=ord[k] local x,y=px[i],py[i]
            while m>lower do local o,a=stack[m-1],stack[m] local ox,oy=px[o],py[o] if (px[a]-ox)*(y-oy)-(py[a]-oy)*(x-ox)>0 then break end m=m-1 end
            m=m+1 stack[m]=i
        end
        return m-1
    end
    local function visible(s) for i=1,#rows do if shown[i]~=s then rows[i].Visible=s shown[i]=s end end end
    local function clear() for i=1,#rows do pcall(function() rows[i]:Remove() end) end table.clear(rows) table.clear(shown) table.clear(cpos) table.clear(csize) table.clear(ccol) end
    local function row(i)
        if rows[i] then return rows[i] end
        local ok,r=pcall(function() return Drawing.new("Square") end)
        if not ok or not r then return nil end
        r.Filled=true r.Thickness=0 r.Transparency=0.72 r.Visible=false r.ZIndex=1
        rows[i]=r shown[i]=false return r
    end
    local last={head=nil,pos=nil,cf=nil,fov=nil,vx=nil,vy=nil,col=nil,r=nil}
    track(RunService.RenderStepped:Connect(function()
        if not S.enabled then visible(false) return end
        local char=LP.Character local head=char and char:FindFirstChild("Head")
        local cam=WS.CurrentCamera
        if not head or not head:IsA("BasePart") or not cam then visible(false) return end
        local col=COLOR_VALUES[S.color] or CURRENT_ACCENT
        local headPos=head.Position local camCF=cam.CFrame local fov=cam.FieldOfView local view=cam.ViewportSize
        if last.head==head and last.pos==headPos and last.cf==camCF and last.fov==fov and last.vx==view.X and last.vy==view.Y and last.col==col and last.r==S.radius then return end
        last.head,last.pos,last.cf=head,headPos,camCF
        last.fov,last.vx,last.vy,last.col,last.r=fov,view.X,view.Y,col,S.radius
        rebuild_circle(S.radius)
        local baseY=headPos.Y+head.Size.Y*0.5-CH_DROP
        local center=Vector3.new(headPos.X,baseY,headPos.Z)
        local apex=cam:WorldToViewportPoint(center+Vector3.new(0,S.height,0))
        if apex.Z<=0 then visible(false) return end
        local probe=cam:WorldToViewportPoint(center+Vector3.new(cosT[1],0,sinT[1]))
        if probe.Z<=0 then visible(false) return end
        px[1],py[1]=apex.X,apex.Y px[2],py[2]=probe.X,probe.Y
        for i=2,CH_SEG do
            local point=cam:WorldToViewportPoint(center+Vector3.new(cosT[i],0,sinT[i]))
            if point.Z<=0 then visible(false) return end
            px[i+1],py[i+1]=point.X,point.Y
        end
        local hn=hull(CH_SEG+1) if hn<3 then visible(false) return end
        local minY,maxY=math.huge,-math.huge
        for i=1,hn do local y=py[stack[i]] if y<minY then minY=y end if y>maxY then maxY=y end end
        local firstY=math.max(0,math.floor(minY)) local lastY=math.min(view.Y,math.ceil(maxY))
        if lastY-firstY<2 then visible(false) return end
        local step=math.max(1,math.ceil((lastY-firstY)/CH_MAX_ROWS)) local span=math.max(1,maxY-minY) local used=0
        for y0=firstY,lastY-1,step do
            local h=math.min(step,lastY-y0) local y=y0+h*0.5
            local left,right=math.huge,-math.huge
            local ax,ay=px[stack[hn]],py[stack[hn]]
            for i=1,hn do
                local ix=stack[i] local bx,by=px[ix],py[ix]
                if (ay<=y and by>y) or (by<=y and ay>y) then
                    local x=ax+(y-ay)*(bx-ax)/(by-ay)
                    if x<left then left=x end if x>right then right=x end
                end
                ax,ay=bx,by
            end
            local w=right-left
            if w>=2.5 then
                used=used+1 local r=row(used)
                local t=(y-minY)/span
                local light=math.max(0,1-t*1.35) local dark=math.max(0,(t-0.58)/0.42)
                local c=col:Lerp(Color3.new(1,1,1),light*0.26):Lerp(Color3.new(0,0,0),dark*0.1)
                local pos=Vector2.new(left,y0) local sz=Vector2.new(w,h)
                if cpos[used]~=pos then r.Position=pos cpos[used]=pos end
                if csize[used]~=sz then r.Size=sz csize[used]=sz end
                if ccol[used]~=c then r.Color=c ccol[used]=c end
                if not shown[used] then r.Visible=true shown[used]=true end
            end
        end
        for i=used+1,#rows do if shown[i] then rows[i].Visible=false shown[i]=false end end
    end))
    return {
        set=function(on) S.enabled=on if not on then clear() end end,
        set_color=function(i) S.color=i end,
        set_height=function(v) S.height=v end,
        set_radius=function(v) S.radius=v end,
        clear=clear,
    }
end)()

-- Aura (StarAura with asset loading)
StarAura=(function()
    local AURA_IDS={angel="97658130917593",heavenly="139300897520961"}
    local AURA_ORDER={"angel","heavenly","dignity"}
    local GROUPS={head={"Head"},torso={"Torso","UpperTorso","LowerTorso","HumanoidRootPart","Root"},larm={"Left Arm","LeftUpperArm","LeftLowerArm","LeftHand"},rarm={"Right Arm","RightUpperArm","RightLowerArm","RightHand"},lleg={"Left Leg","LeftUpperLeg","LeftLowerLeg","LeftFoot"},rleg={"Right Leg","RightUpperLeg","RightLowerLeg","RightFoot"}}
    local group_of={}
    for g,names in pairs(GROUPS) do for i=1,#names do group_of[names[i]]=g end end

    local S={on=false,type="angel",color=Color3.fromRGB(80,140,245),host=nil,parts={},loaded={},applying=false,last_check=0,angelAttachment=nil}
    local connections={}
    local function track(c) connections[#connections+1]=c return c end
    local function is_effect(d) return d:IsA("ParticleEmitter") or d:IsA("PointLight") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") end
    local function load_aura(name)
        if S.loaded[name] then return S.loaded[name] end
        local id=AURA_IDS[name] if not id then return nil end
        local ok,objs=pcall(function() return game:GetObjects("rbxassetid://"..id) end)
        if not ok or type(objs)~="table" or not objs[1] then return nil end
        S.loaded[name]=objs[1] return objs[1]
    end
    local function color_effect(d,color)
        if d:IsA("PointLight") then pcall(function() d.Color=color d.Enabled=true if d.Brightness<1 then d.Brightness=2 end if d.Range<5 then d.Range=8 end end)
        elseif d:IsA("ParticleEmitter") then pcall(function() d.Color=ColorSequence.new(color) d.Enabled=true if d.Rate<=0 then d.Rate=40 end d.Transparency=NumberSequence.new(0.15) d.LightEmission=math.max(d.LightEmission or 0,0.5) end)
        elseif d:IsA("Beam") then pcall(function() d.Color=ColorSequence.new(color) d.Enabled=true d.Transparency=NumberSequence.new(0.2) end)
        elseif d:IsA("Trail") then pcall(function() d.Color=ColorSequence.new(color) d.Enabled=true d.Transparency=NumberSequence.new(0.2) end)
        elseif d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then pcall(function() d.Enabled=true if d:IsA("Sparkles") then d.SparkleColor=color end end) end
    end

    -- ═══════════════════════════════════════════════════════════
    -- Достоинство — Lower Visual v20.
    -- Внутренняя интеграционная оболочка только управляет включением
    -- и выключением блока из основного ClumsyScript; геометрия,
    -- параметры и touch/ragdoll-механика ниже взяты из предоставленного кода.
    -- ═══════════════════════════════════════════════════════════
    local Dignity=(function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LP = Players.LocalPlayer
        local WS = workspace

        local CFG = {
            BallSize = 0.75,
            BallColor = Color3.fromRGB(255, 205, 165),
            BallMaterial = Enum.Material.SmoothPlastic,
            ShaftLength = 1.45,
            ShaftRadius = 0.30,
            ShaftColor = Color3.fromRGB(255, 205, 165),
            ShaftMaterial = Enum.Material.SmoothPlastic,
            TipFlatScale = 0.55,
            TipColor = Color3.fromRGB(255, 130, 160),
            TipMaterial = Enum.Material.SmoothPlastic,
            FrontOffset = 0.760,
            HeightOffset = 0.139,
            ShaftBackOffset = 0.164,
            ShaftYOffset = -0.05,
            BallSpacing = 0.35,
            TipSpringStiffness = 18,
            TipSpringDamping   = 6,
            TipMaxDeflection   = 0.22,
            TipVelocityScale   = 0.06,
            TipRotationScale   = 0.25,
            FlexHalfRatio = 0.5,
            FlexSegments = 4,
            JetEnabled = true,
            JetEmitRate = 240,
            JetLifetime = 0.45,
            JetSpeed = 16,
            JetSpeedVariance = 0.25,
            JetSpread = 5,
            JetSizeStart = 0.055,
            JetSizeMid = 0.085,
            JetSizeEnd = 0.12,
            JetTransparencyStart = 0.0,
            JetTransparencyMid = 0.20,
            JetTransparencyEnd = 1.0,
            JetColor = Color3.fromRGB(255, 255, 255),
            JetAcceleration = Vector3.new(0, -12, 0),
            JetDrag = 0.1,
            JetLightEmission = 1.0,
            JetTexture = "rbxassetid://243660364",
            JetDuration = 3.0,
            TouchRadius = 3.5,
            PerPlayerCooldown = 4.5,
            RagdollDuration = 3.0,
        }

        local holder=nil
        local parts_cache={}
        local jet_part=nil
        local jet_state={active_until=0,emitter=nil,manual_until=0,manual_accum=0,origin=nil,dir=nil,dots={},free={}}
        local tip_state={offset=Vector3.zero,velocity=Vector3.zero,lastCharPos=nil}
        local flex_state={offset=Vector3.zero,velocity=Vector3.zero}
        local lastTouch={}
        local active_session=nil
        local enabled=false
        local localConnections={}

        local function makePart(shape,size,color,material)
            local p=Instance.new("Part")
            p.Shape=shape p.Size=size p.Color=color p.Material=material
            p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false
            p.CastShadow=false p.Massless=true p.Locked=true p.Transparency=0
            p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
            p.Parent=holder
            return p
        end

        local function getRig(char)
            local hum=char:FindFirstChildOfClass("Humanoid")
            local isR15=hum and hum.RigType==Enum.HumanoidRigType.R15
            if isR15 then
                return {r15=true, upperTorso="UpperTorso", leftLeg="LeftUpperLeg", rightLeg="RightUpperLeg"}
            else
                return {r15=false, upperTorso="Torso", leftLeg="Left Leg", rightLeg="Right Leg"}
            end
        end

        local function destroyManualDots()
            for i=#jet_state.dots,1,-1 do
                local d=jet_state.dots[i]
                if d.part then pcall(function() d.part:Destroy() end) end
                jet_state.dots[i]=nil
            end
            jet_state.free={}
            jet_state.manual_accum=0
        end

        local function buildManualDots()
            destroyManualDots()
            if not holder or not holder.Parent then return end
            -- Небольшой пул белых шариков: без создания/удаления объектов во время каждого кадра.
            for i=1,360 do
                local part=Instance.new("Part")
                part.Name="CH_WhiteDot"
                part.Shape=Enum.PartType.Ball
                part.Size=Vector3.new(0.095,0.095,0.095)
                part.Color=Color3.fromRGB(255,255,255)
                part.Material=Enum.Material.SmoothPlastic
                part.Anchored=true
                part.CanCollide=false
                part.CanTouch=false
                part.CanQuery=false
                part.CastShadow=false
                part.Transparency=1
                part.Parent=holder
                jet_state.free[#jet_state.free+1]={part=part,pos=Vector3.zero,vel=Vector3.zero,age=0,life=0.90,active=false}
            end
        end

        local function activateManualJet()
            local now=os.clock()
            jet_state.manual_until=now+CFG.JetDuration
            jet_state.manual_accum=0
            jet_state.pending_burst=not (jet_state.origin and jet_state.dir)

            -- Мгновенный первый выброс, если конец цилиндра уже известен.
            if jet_state.origin and jet_state.dir then
                for i=1,40 do
                    local d=jet_state.free[#jet_state.free]
                    if not d then break end
                    jet_state.free[#jet_state.free]=nil
                    local spread=Vector3.new(
                        (math.random()-0.5)*0.18,
                        (math.random()-0.5)*0.18,
                        (math.random()-0.5)*0.18
                    )
                    d.pos=jet_state.origin+jet_state.dir*0.16
                    d.vel=(jet_state.dir+spread).Unit*(CFG.JetSpeed*(0.75+math.random()*0.30))
                    d.age=0
                    d.life=CFG.JetLifetime*(0.90+math.random()*0.18)
                    d.active=true
                    d.part.Transparency=0
                    jet_state.dots[#jet_state.dots+1]=d
                end
                jet_state.pending_burst=false
            end
        end

        local function updateManualJet(dt)
            local now=os.clock()
            local active=CFG.JetEnabled and now<jet_state.manual_until
            if active and jet_state.origin and jet_state.dir then
                -- Если касание произошло между кадрами построения цилиндра,
                -- первый burst выпускается сразу после получения актуального tip.
                if jet_state.pending_burst then
                    for i=1,40 do
                        local d=jet_state.free[#jet_state.free]
                        if not d then break end
                        jet_state.free[#jet_state.free]=nil
                        local spread=Vector3.new(
                            (math.random()-0.5)*0.18,
                            (math.random()-0.5)*0.18,
                            (math.random()-0.5)*0.18
                        )
                        d.pos=jet_state.origin+jet_state.dir*0.16
                        d.vel=(jet_state.dir+spread).Unit*(CFG.JetSpeed*(0.75+math.random()*0.30))
                        d.age=0
                        d.life=CFG.JetLifetime*(0.90+math.random()*0.18)
                        d.active=true
                        d.part.Transparency=0
                        jet_state.dots[#jet_state.dots+1]=d
                    end
                    jet_state.pending_burst=false
                end

                jet_state.manual_accum=jet_state.manual_accum+dt*CFG.JetEmitRate
                while jet_state.manual_accum>=1 do
                    jet_state.manual_accum=jet_state.manual_accum-1
                    local d=jet_state.free[#jet_state.free]
                    if not d then break end
                    jet_state.free[#jet_state.free]=nil
                    local spread=Vector3.new((math.random()-0.5)*0.12,(math.random()-0.5)*0.12,(math.random()-0.5)*0.12)
                    d.pos=jet_state.origin+jet_state.dir*0.14
                    d.vel=(jet_state.dir+spread).Unit*(CFG.JetSpeed*(0.85+math.random()*0.15))
                    d.age=0 d.life=CFG.JetLifetime*(0.90+math.random()*0.12) d.active=true d.part.Transparency=0
                    jet_state.dots[#jet_state.dots+1]=d
                end
            end
            for i=#jet_state.dots,1,-1 do
                local d=jet_state.dots[i]
                if d.active then
                    d.age=d.age+dt
                    d.vel=d.vel+CFG.JetAcceleration*dt
                    d.vel=d.vel*(1-math.clamp(CFG.JetDrag*dt,0,0.9))
                    d.pos=d.pos+d.vel*dt
                    d.part.CFrame=CFrame.new(d.pos)
                    local t=math.clamp(d.age/d.life,0,1)
                    d.part.Transparency=math.clamp(t,0,1)
                    if d.age>=d.life or not holder or not holder.Parent then
                        d.active=false d.part.Transparency=1
                        table.remove(jet_state.dots,i)
                        jet_state.free[#jet_state.free+1]=d
                    end
                end
            end
        end

        local function destroyJet()
            destroyManualDots()
            jet_state.manual_until=0
            if jet_state.emitter then pcall(function() jet_state.emitter:Destroy() end) jet_state.emitter=nil end
            if jet_part then pcall(function() jet_part:Destroy() end) jet_part=nil end
        end

        local function buildJet()
            -- Rebuild only the hidden emitter carrier. Do NOT call destroyJet() here:
            -- destroyJet() also clears the pooled white dots, which used to erase the
            -- entire touch stream 0.15s after Dignity was enabled.
            if jet_state.emitter then
                pcall(function() jet_state.emitter:Destroy() end)
                jet_state.emitter=nil
            end
            if jet_part then
                pcall(function() jet_part:Destroy() end)
                jet_part=nil
            end
            if not holder or not holder.Parent then return end
            local p=Instance.new("Part")
            p.Name="CH_EmitPart"
            p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false p.CastShadow=false p.Massless=true p.Locked=true p.Transparency=1
            p.Size=Vector3.new(0.5,0.5,0.5) p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=holder
            jet_part=p
            local att=Instance.new("Attachment")
            att.Name="CH_JetOrigin" att.Position=Vector3.zero att.Parent=jet_part
            local pe=Instance.new("ParticleEmitter")
            pe.Name="CH_JetFX" pe.Texture=CFG.JetTexture pe.Color=ColorSequence.new(CFG.JetColor)
            pe.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,CFG.JetSizeStart),NumberSequenceKeypoint.new(0.4,CFG.JetSizeMid),NumberSequenceKeypoint.new(1,CFG.JetSizeEnd)})
            pe.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,CFG.JetTransparencyStart),NumberSequenceKeypoint.new(0.5,CFG.JetTransparencyMid),NumberSequenceKeypoint.new(1,CFG.JetTransparencyEnd)})
            pe.Lifetime=NumberRange.new(CFG.JetLifetime,CFG.JetLifetime*1.2)
            pe.Speed=NumberRange.new(CFG.JetSpeed*(1-CFG.JetSpeedVariance),CFG.JetSpeed*(1+CFG.JetSpeedVariance))
            pe.SpreadAngle=Vector2.new(CFG.JetSpread,CFG.JetSpread) pe.Acceleration=CFG.JetAcceleration pe.Drag=CFG.JetDrag
            pe.Rotation=NumberRange.new(0,360) pe.RotSpeed=NumberRange.new(-180,180) pe.Rate=0 pe.LightEmission=CFG.JetLightEmission pe.LightInfluence=0
            pe.EmissionDirection=Enum.NormalId.Front pe.Enabled=false pe.LockedToPart=false
            pe.Shape=Enum.ParticleEmitterShape.Disc
            pe.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
            pe.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward
            pe.Parent=jet_part
            jet_state.emitter=pe
        end

        local function build()
            if holder and holder.Parent then holder:Destroy() end
            destroyJet()
            holder=Instance.new("Folder") holder.Name="CH_LowerVisual" holder.Parent=WS
            parts_cache={}
            tip_state.offset=Vector3.zero tip_state.velocity=Vector3.zero tip_state.lastCharPos=nil
            flex_state.offset=Vector3.zero flex_state.velocity=Vector3.zero jet_state.active_until=0
            parts_cache.ballA=makePart(Enum.PartType.Ball,Vector3.new(CFG.BallSize,CFG.BallSize,CFG.BallSize),CFG.BallColor,CFG.BallMaterial)
            parts_cache.ballB=makePart(Enum.PartType.Ball,Vector3.new(CFG.BallSize,CFG.BallSize,CFG.BallSize),CFG.BallColor,CFG.BallMaterial)
            local backLen=CFG.ShaftLength*(1-CFG.FlexHalfRatio)
            local frontLen=CFG.ShaftLength*CFG.FlexHalfRatio
            parts_cache.shaftBack=makePart(Enum.PartType.Cylinder,Vector3.new(backLen,CFG.ShaftRadius*2,CFG.ShaftRadius*2),CFG.ShaftColor,CFG.ShaftMaterial)
            local seg_count=math.max(2,CFG.FlexSegments) local seg_len=frontLen/seg_count parts_cache.flexSegments={}
            for i=1,seg_count do
                local seg=makePart(Enum.PartType.Cylinder,Vector3.new(seg_len,CFG.ShaftRadius*2,CFG.ShaftRadius*2),CFG.ShaftColor,CFG.ShaftMaterial)
                parts_cache.flexSegments[i]=seg
            end
            parts_cache.tip=makePart(Enum.PartType.Ball,Vector3.new(CFG.ShaftRadius*2,CFG.ShaftRadius*2,CFG.ShaftRadius*2*CFG.TipFlatScale*2),CFG.TipColor,CFG.TipMaterial)
            buildManualDots()
            task.spawn(function() task.wait(0.15) if enabled then buildJet() task.wait(0.5) if enabled and (not jet_state.emitter or not jet_state.emitter.Parent) then buildJet() end end end)
        end

        local function update(dt)
            if not enabled or not holder or not holder.Parent then return end
            local char=LP.Character if not char then return end
            local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
            local rig=getRig(char)
            local upperTorso=char:FindFirstChild(rig.upperTorso) local leftLeg=char:FindFirstChild(rig.leftLeg) local rightLeg=char:FindFirstChild(rig.rightLeg)
            if not upperTorso or not leftLeg or not rightLeg then return end
            local leftPos=leftLeg.Position local rightPos=rightLeg.Position local legsCenter=(leftPos+rightPos)/2
            local hipY=(upperTorso.Position.Y+leftLeg.Position.Y)/2+CFG.HeightOffset
            local look=hrp.CFrame.LookVector local flatLook=Vector3.new(look.X,0,look.Z)
            if flatLook.Magnitude<0.01 then flatLook=Vector3.new(0,0,-1) end flatLook=flatLook.Unit
            local flatRight=Vector3.new(flatLook.Z,0,-flatLook.X) if flatRight.Magnitude<0.01 then flatRight=Vector3.new(1,0,0) end flatRight=flatRight.Unit
            local centerPos=Vector3.new(legsCenter.X,hipY,legsCenter.Z)+flatLook*CFG.FrontOffset
            parts_cache.ballA.CFrame=CFrame.new(centerPos-flatRight*CFG.BallSpacing)
            parts_cache.ballB.CFrame=CFrame.new(centerPos+flatRight*CFG.BallSpacing)
            local shaftStart=centerPos-flatLook*CFG.ShaftBackOffset+Vector3.new(0,CFG.ShaftYOffset,0)
            local shaftCFrame=CFrame.lookAt(shaftStart,shaftStart+flatLook) local shaftBase=shaftCFrame*CFrame.Angles(0,math.rad(90),0)
            local currentPos=hrp.Position local charVel=Vector3.zero
            if tip_state.lastCharPos then charVel=(currentPos-tip_state.lastCharPos)/math.max(dt,0.001) end tip_state.lastCharPos=currentPos
            local velLocal=Vector3.new(charVel:Dot(shaftBase.RightVector),charVel:Dot(shaftBase.UpVector),charVel:Dot(shaftBase.LookVector))
            local backLen=CFG.ShaftLength*(1-CFG.FlexHalfRatio)
            parts_cache.shaftBack.CFrame=shaftBase*CFrame.new(backLen*0.5,0,0)
            local stiffness=CFG.TipSpringStiffness local damping=CFG.TipSpringDamping
            local targetOffset=Vector3.new(-velLocal.X*CFG.TipVelocityScale*1.4,-velLocal.Y*CFG.TipVelocityScale*2.0,-velLocal.Z*CFG.TipVelocityScale)
            if targetOffset.Magnitude>CFG.TipMaxDeflection*1.2 then targetOffset=targetOffset.Unit*CFG.TipMaxDeflection*1.2 end
            local accel=(targetOffset-flex_state.offset)*stiffness-flex_state.velocity*damping
            flex_state.velocity=flex_state.velocity+accel*dt flex_state.offset=flex_state.offset+flex_state.velocity*dt
            if flex_state.offset.Magnitude>CFG.TipMaxDeflection*1.2 then flex_state.offset=flex_state.offset.Unit*CFG.TipMaxDeflection*1.2 end
            local seg_count=#parts_cache.flexSegments
            if seg_count>0 then
                local seg_len=(CFG.ShaftLength*CFG.FlexHalfRatio)/seg_count
                for i=1,seg_count do
                    local t=i/seg_count local local_flex=flex_state.offset*t
                    local tiltX=math.clamp(local_flex.X*CFG.TipRotationScale*t,-0.5,0.5) local tiltY=math.clamp(local_flex.Y*CFG.TipRotationScale*t,-0.5,0.5)
                    local seg=parts_cache.flexSegments[i] local xPos=backLen+seg_len*(i-0.5)
                    seg.CFrame=shaftBase*CFrame.new(xPos+local_flex.X*0.5,local_flex.Y*0.5,local_flex.Z*0.5)*CFrame.Angles(tiltY,-tiltX,0)
                end
            end
            local tipLocalX=CFG.ShaftLength
            local tipCF=shaftBase*CFrame.new(tipLocalX+flex_state.offset.X,flex_state.offset.Y,flex_state.offset.Z)*CFrame.Angles(math.clamp(flex_state.offset.Y*CFG.TipRotationScale,-0.5,0.5),math.clamp(-flex_state.offset.X*CFG.TipRotationScale,-0.5,0.5),0)
            parts_cache.tip.CFrame=tipCF
            local jetOrigin=tipCF.Position+flatLook*0.20
            jet_state.origin=jetOrigin
            jet_state.dir=flatLook
            if jet_part and jet_part.Parent then jet_part.CFrame=CFrame.lookAt(jetOrigin,jetOrigin+flatLook) end
            -- The ragdoll touch is the authoritative trigger. If it happened before
            -- the tip had a valid position, arm the 3-second white stream here.
            if active_session and os.clock()<active_session.endTime and os.clock()>=jet_state.manual_until then
                jet_state.manual_until=active_session.endTime
                jet_state.manual_accum=0
                jet_state.pending_burst=true
            end
            updateManualJet(dt)
            if jet_state.emitter and jet_state.emitter.Parent then
                local touching=os.clock()<jet_state.active_until
                if CFG.JetEnabled and touching then jet_state.emitter.Rate=CFG.JetEmitRate else jet_state.emitter.Rate=0 end
            elseif not jet_part or not jet_part.Parent then task.spawn(buildJet) end
        end

        local function applyQuadRagdoll(char)
            if not char or not char.Parent then return nil end
            local hum=char:FindFirstChildOfClass("Humanoid") local hrp=char:FindFirstChild("HumanoidRootPart") if not hum or not hrp then return nil end
            local baseLook=hrp.CFrame.LookVector local flatLook=Vector3.new(baseLook.X,0,baseLook.Z) if flatLook.Magnitude<0.01 then flatLook=Vector3.new(0,0,-1) end flatLook=flatLook.Unit
            local flatRight=Vector3.new(flatLook.Z,0,-flatLook.X).Unit
            local rayParams=RaycastParams.new() rayParams.FilterType=Enum.RaycastFilterType.Exclude rayParams.FilterDescendantsInstances={char}
            local hit=WS:Raycast(hrp.Position+Vector3.new(0,3,0),Vector3.new(0,-20,0),rayParams) local groundY=hit and hit.Position.Y or (hrp.Position.Y-2.5)
            local centerGround=Vector3.new(hrp.Position.X,groundY,hrp.Position.Z)
            local parts={} for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then parts[p.Name]=p end end
            local accessoryOffsets={}
            if parts["Head"] then
                local headInv=parts["Head"].CFrame:Inverse()
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p~=parts["Head"] then
                        local isAccessory=false
                        for _,joint in ipairs(p:GetChildren()) do if joint:IsA("Weld") and joint.Part1==parts["Head"] then isAccessory=true break end end
                        if not isAccessory then local par=p.Parent if par and par:IsA("Accessory") then isAccessory=true end end
                        if isAccessory then accessoryOffsets[p]=headInv*p.CFrame end
                    end
                end
            end
            local original_platform=hum.PlatformStand hum.PlatformStand=true pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
            local anchored_original={}
            for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then anchored_original[p]=p.Anchored p.Anchored=true p.CanCollide=false end end
            local torsoHeight=1.2 local armForwardDist=0.9 local hipBackDist=0.7 local sideDist=0.6
            if hum.RigType==Enum.HumanoidRigType.R15 then
                if parts["UpperTorso"] then parts["UpperTorso"].CFrame=CFrame.new(centerGround+Vector3.new(0,torsoHeight,0))*CFrame.Angles(math.rad(-90),0,0) end
                if parts["LowerTorso"] then parts["LowerTorso"].CFrame=CFrame.new(centerGround+Vector3.new(0,torsoHeight,-flatLook.Z*hipBackDist))*CFrame.Angles(math.rad(-90),0,0) end
                if parts["Head"] then local headPos=centerGround+flatLook*armForwardDist*1.1+Vector3.new(0,torsoHeight+0.3,0) parts["Head"].CFrame=CFrame.new(headPos)*CFrame.Angles(math.rad(-45),0,0) for accessory,offset in pairs(accessoryOffsets) do if accessory and accessory.Parent then accessory.CFrame=parts["Head"].CFrame*offset end end end
                for _,side in ipairs({{name="LeftUpperArm",lower="LeftLowerArm",hand="LeftHand",sign=-1},{name="RightUpperArm",lower="RightLowerArm",hand="RightHand",sign=1}}) do
                    local shoulderPos=centerGround+flatLook*armForwardDist*0.7+flatRight*(sideDist*side.sign)+Vector3.new(0,torsoHeight,0) if parts[side.name] then parts[side.name].CFrame=CFrame.new(shoulderPos)*CFrame.Angles(math.rad(80),0,0) end
                    local elbowPos=centerGround+flatLook*armForwardDist+flatRight*(sideDist*side.sign)+Vector3.new(0,0.6,0) if parts[side.lower] then parts[side.lower].CFrame=CFrame.new(elbowPos)*CFrame.Angles(math.rad(-20),0,0) end
                    local handPos=centerGround+flatLook*armForwardDist*1.15+flatRight*(sideDist*side.sign)+Vector3.new(0,0.25,0) if parts[side.hand] then parts[side.hand].CFrame=CFrame.new(handPos) end
                end
                for _,side in ipairs({{name="LeftUpperLeg",lower="LeftLowerLeg",foot="LeftFoot",sign=-1},{name="RightUpperLeg",lower="RightLowerLeg",foot="RightFoot",sign=1}}) do
                    local hipPos=centerGround+flatLook*(-hipBackDist)+flatRight*(sideDist*side.sign)+Vector3.new(0,torsoHeight-0.2,0) if parts[side.name] then parts[side.name].CFrame=CFrame.new(hipPos)*CFrame.Angles(math.rad(20),0,0) end
                    local kneePos=centerGround+flatLook*(-hipBackDist-0.4)+flatRight*(sideDist*side.sign)+Vector3.new(0,0.5,0) if parts[side.lower] then parts[side.lower].CFrame=CFrame.new(kneePos)*CFrame.Angles(math.rad(-85),0,0) end
                    local footPos=centerGround+flatLook*(-hipBackDist-1.0)+flatRight*(sideDist*side.sign)+Vector3.new(0,0.25,0) if parts[side.foot] then parts[side.foot].CFrame=CFrame.new(footPos) end
                end
            else
                if parts["Torso"] then parts["Torso"].CFrame=CFrame.new(centerGround+Vector3.new(0,torsoHeight,0))*CFrame.Angles(math.rad(-90),0,0) end
                if parts["Head"] then local headPos=centerGround+flatLook*armForwardDist*1.1+Vector3.new(0,torsoHeight+0.5,0) parts["Head"].CFrame=CFrame.new(headPos)*CFrame.Angles(math.rad(-45),0,0) for accessory,offset in pairs(accessoryOffsets) do if accessory and accessory.Parent then accessory.CFrame=parts["Head"].CFrame*offset end end end
                for _,side in ipairs({{name="Left Arm",sign=-1},{name="Right Arm",sign=1}}) do local armPos=centerGround+flatLook*armForwardDist+flatRight*(sideDist*side.sign)+Vector3.new(0,0.5,0) if parts[side.name] then parts[side.name].CFrame=CFrame.new(armPos)*CFrame.Angles(math.rad(70),0,0) end end
                for _,side in ipairs({{name="Left Leg",sign=-1},{name="Right Leg",sign=1}}) do local legPos=centerGround+flatLook*(-hipBackDist-0.5)+flatRight*(sideDist*side.sign)+Vector3.new(0,0.6,0) if parts[side.name] then parts[side.name].CFrame=CFrame.new(legPos)*CFrame.Angles(math.rad(-30),0,0) end end
            end
            local frozen={} for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then frozen[p]=p.CFrame end end
            local lockConn=RunService.Heartbeat:Connect(function() for part,cf in pairs(frozen) do if part and part.Parent then pcall(function() part.CFrame=cf part.AssemblyLinearVelocity=Vector3.zero part.AssemblyAngularVelocity=Vector3.zero end) end end end)
            local restored=false
            local function restore()
                if restored then return end restored=true if lockConn then pcall(function() lockConn:Disconnect() end) end
                for part,anchored in pairs(anchored_original) do if part and part.Parent then pcall(function() part.Anchored=anchored end) end end
                if hum and hum.Parent then pcall(function() hum.PlatformStand=original_platform if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end end) end
            end
            return restore
        end

        local function start_session(other_player)
            if active_session then pcall(active_session.their_restore) active_session=nil end
            local their_char=other_player.Character if not their_char then return end
            local now=os.clock() jet_state.active_until=now+CFG.JetDuration
            activateManualJet()
            -- Струя полностью рисуется пулом белых круглых точек из кончика цилиндра.
            if jet_state.emitter and jet_state.emitter.Parent then jet_state.emitter.Rate=0 end
            local their_restore=applyQuadRagdoll(their_char) if not their_restore then return end
            active_session={player=other_player,their_restore=their_restore,endTime=now+CFG.JetDuration}
        end
        local function end_session()
            if not active_session then return end
            local s=active_session active_session=nil pcall(s.their_restore) if jet_state.emitter then jet_state.emitter.Rate=0 end
        end
        local touchAccumulator=0
        local function checkTouches(dt)
            if not enabled then return end
            touchAccumulator=touchAccumulator+(dt or 0)
            if touchAccumulator<0.08 then return end
            touchAccumulator=0
            local char=LP.Character if not char then return end local myRoot=char:FindFirstChild("HumanoidRootPart") if not myRoot then return end
            local now=os.clock()
            if active_session and now>=active_session.endTime then end_session() end
            if not active_session then
                for _,other in ipairs(Players:GetPlayers()) do
                    if other~=LP and other.Character then
                        local oroot=other.Character:FindFirstChild("HumanoidRootPart")
                        if oroot then
                            local d=(myRoot.Position-oroot.Position).Magnitude
                            if d<=CFG.TouchRadius then
                                local last=lastTouch[other] or 0
                                if now-last>=CFG.PerPlayerCooldown then lastTouch[other]=now start_session(other) break end
                            end
                        end
                    end
                end
            end
        end

        local function cleanup()
            end_session()
            enabled=false
            destroyJet()
            if holder then pcall(function() holder:Destroy() end) holder=nil end
            parts_cache={}
        end
        local function start()
            if enabled then return end
            enabled=true build()
        end
        track(RunService.RenderStepped:Connect(function(dt) pcall(update,dt) end))
        track(RunService.Heartbeat:Connect(function(dt) checkTouches(dt) end))
        track(LP.CharacterAdded:Connect(function() if enabled then task.wait(0.4) build() end end))

        return {start=start,stop=cleanup,cfg=CFG,getHolder=function() return holder end,getParts=function() return parts_cache end}
    end)()

    local function clear()
        if Dignity then Dignity.stop() end
        for i=#S.parts,1,-1 do local p=S.parts[i] if p and p.Parent then pcall(function() p:Destroy() end) end S.parts[i]=nil end
        if S.angelAttachment and S.angelAttachment.Parent then pcall(function() S.angelAttachment:Destroy() end) end
        S.angelAttachment=nil S.host=nil
    end
    local function slot(char,name)
        local direct=char:FindFirstChild(name) if direct and direct:IsA("BasePart") then return direct end
        local g=group_of[name] if g then for _,n in ipairs(GROUPS[g]) do local p=char:FindFirstChild(n) if p and p:IsA("BasePart") then return p end end end
        return nil
    end
    local function apply()
        if S.applying then return end
        S.applying=true clear()
        if not S.on then S.applying=false return end
        local char=LP.Character if not char then S.applying=false return end
        local hum=char:FindFirstChildOfClass("Humanoid") if not hum or hum.Health<=0 then S.applying=false return end
        if S.type=="dignity" then Dignity.start() S.host=char S.applying=false return end
        local src=load_aura(S.type)
        if not src then task.delay(2,function() if S.on then apply() end end) S.applying=false return end
        local clone=src:Clone() local hrp=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") local angelTarget=nil
        if S.type=="angel" then angelTarget=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or hrp if angelTarget then local att=Instance.new("Attachment") att.Name="ClumsyAngelWingsBack" att.Position=Vector3.new(0,0,1.15) att.Orientation=Vector3.new(0,180,0) att.Parent=angelTarget S.angelAttachment=att end end
        local effects={}
        for _,d in ipairs(clone:GetDescendants()) do if is_effect(d) then effects[#effects+1]=d end end
        for _,eff in ipairs(effects) do
            local skip=false local nm=string.lower(eff.Name or "")
            if nm:find("ring",1,true) or nm:find("circle",1,true) or nm:find("halo",1,true) or nm:find("orbit",1,true) then skip=true end
            local par=eff.Parent local depth=0
            while par and par~=clone and depth<5 do local pn=string.lower(par.Name or "") if pn:find("ring",1,true) or pn:find("circle",1,true) or pn:find("halo",1,true) or pn:find("orbit",1,true) then skip=true break end par=par.Parent depth=depth+1 end
            if not skip then
                color_effect(eff,S.color)
                local parent=eff.Parent local target=nil
                if S.type=="angel" and S.angelAttachment then target=S.angelAttachment else
                    while parent and parent~=clone do if parent:IsA("BasePart") then target=slot(char,parent.Name) if target then break end end parent=parent.Parent end
                    if not target then target=hrp end
                end
                if target then eff.Parent=target S.parts[#S.parts+1]=eff end
            end
        end
        clone:Destroy() S.host=char S.applying=false
    end
    local function paint(color)
        for i=1,#S.parts do local p=S.parts[i] if p and p.Parent then color_effect(p,color) end end
    end
    track(LP.CharacterAdded:Connect(function() task.wait(.4) if S.on then apply() end end))
    return {
        set=function(v) S.on=v if v then apply() else clear() end end,
        set_type=function(name) S.type=name if S.on then apply() end end,
        set_type_by_idx=function(i) S.type=AURA_ORDER[math.clamp(i or 1,1,#AURA_ORDER)] if S.on then apply() end end,
        set_color=function(c) S.color=c if S.on and S.type~="dignity" then paint(c) end end,
        clear=clear,
    }
end)()

-- Backtrack (Shitaro)
BackTrack=(function()
    local S={delay_ms=0,color=Color3.fromRGB(255,60,60),model=nil,pairs={},hist={},first=1,count=0,cap=64,ping=0.15,ping_at=0,ping_min=0.05,ping_max=0.6,ping_sample=0.2,built_for=nil}
    for i=1,S.cap do S.hist[i]={0,CFrame.new()} end
    local function destroy()
        if S.model then if _G.BACKTRACK_CLONES then _G.BACKTRACK_CLONES[S.model]=nil end pcall(function() S.model:Destroy() end) end
        S.model=nil S.pairs={} S.first=1 S.count=0 S.built_for=nil
    end
    local function build()
        destroy()
        local char=LP.Character if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        char.Archivable=true local ok,clone=pcall(function() return char:Clone() end) char.Archivable=false
        if not ok or not clone then return end
        _G.BACKTRACK_CLONES=_G.BACKTRACK_CLONES or {} _G.BACKTRACK_CLONES[clone]=true
        local rp={} for _,o in ipairs(char:GetDescendants()) do if o:IsA("BasePart") then rp[#rp+1]=o end end
        local ci=0
        for _,o in ipairs(clone:GetDescendants()) do
            if o:IsA("Script") or o:IsA("LocalScript") or o:IsA("Humanoid")
                or o:IsA("Decal") or o:IsA("Texture") or o:IsA("ParticleEmitter")
                or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Highlight")
                or o:IsA("Sound") or o:IsA("Fire") or o:IsA("Smoke")
                or o:IsA("Sparkles") or o:IsA("PointLight") then pcall(function() o:Destroy() end)
            elseif o:IsA("BasePart") then
                o.Anchored=true o.CanCollide=false o.CanQuery=false o.CanTouch=false
                o.Massless=true o.CastShadow=false o.Locked=true o.LocalTransparencyModifier=0
                if o.Name=="HumanoidRootPart" then o.Transparency=1
                else o.Material=Enum.Material.ForceField o.Color=S.color o.Transparency=0.15 end
                ci=ci+1 S.pairs[#S.pairs+1]={o,rp[ci]}
            end
        end
        clone.Name="CH_BackTrack" clone.Parent=WS S.model=clone S.built_for=char
    end
    local function read_ping()
        local ok,ms=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if ok and type(ms)=="number" and ms>0 then return math.clamp(ms/1000,S.ping_min,S.ping_max) end
        local ok2,p=pcall(function() return LP:GetNetworkPing() end)
        if ok2 and type(p)=="number" and p>0 then return math.clamp(p,S.ping_min,S.ping_max) end
        return 0.15
    end
    track(RunService.Heartbeat:Connect(function()
        if not CFG.Backtrack then if S.model then destroy() end return end
        local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if getgenv().FAKE_POS_ACTIVE then if S.model and S.model.Parent then S.model.Parent=nil end return end
        if S.built_for~=char then build() end
        if not S.model then build() if not S.model then return end end
        if not S.model.Parent then S.model.Parent=WS end
        local now=os.clock()
        if S.count<S.cap then S.count=S.count+1 else S.first=S.first%S.cap+1 end
        local slot=S.hist[(S.first+S.count-2)%S.cap+1] slot[1]=now slot[2]=hrp.CFrame
        if now-S.ping_at>=S.ping_sample then S.ping_at=now S.ping=read_ping() end
        local delay=S.ping+(S.delay_ms/1000) local target=now-delay local cf=hrp.CFrame
        for k=S.count,1,-1 do local s=S.hist[(S.first+k-2)%S.cap+1] if s[1]>0 and s[1]<=target then cf=s[2] break end end
        while S.count>0 and S.hist[S.first][1]>0 and S.hist[S.first][1]<now-1 do S.first=S.first%S.cap+1 S.count=S.count-1 end
        local inv=hrp.CFrame:Inverse()
        for i=1,#S.pairs do local cp,rp=S.pairs[i][1],S.pairs[i][2] if cp and cp.Parent and rp and rp.Parent then cp.CFrame=cf*(inv*rp.CFrame) end end
    end))
    track(LP.CharacterAdded:Connect(function() S.count=0 S.first=1 S.built_for=nil destroy() if CFG.Backtrack then task.wait(0.5) build() end end))
    return {
        set=function(v) CFG.Backtrack=v and true or false if CFG.Backtrack then build() else destroy() end end,
        set_delay=function(v) S.delay_ms=v end,
        set_color=function(i) S.color=COLOR_VALUES[i] or S.color
            if S.model then for _,p in ipairs(S.pairs) do if p[1] and p[1].Parent and p[1].Name~="HumanoidRootPart" then p[1].Color=S.color end end end
        end,
        clear=destroy,rebuild=build,
    }
end)()

-- Lighting / Skybox
-- Fog FIX: не трогаем Atmosphere и не ставим FogStart=0.
-- Иначе небо визуально "обрывается" сразу после включения.
do
    local fog_target_on=false
    local fog_last_distance=nil
    local fog_last_color=nil
    local fog_tween=nil

    local function fog_apply(on, instant)
        local distance=math.max(50,tonumber(CFG.FogDistance) or 500)
        -- Плавный градиент: туман начинается не у камеры, а ближе к дальней части сцены.
        local target_start=math.max(25,distance*0.35)
        local target_end=math.max(target_start+50,distance)
        local target_color=FOG_COLORS[CFG.FogColor] or FOG_COLORS[1]

        if fog_tween then pcall(function() fog_tween:Cancel() end) end

        local goal
        if on then
            goal={FogStart=target_start,FogEnd=target_end,FogColor=target_color}
        else
            goal={FogStart=ORIG_LIGHT.FogStart,FogEnd=ORIG_LIGHT.FogEnd,FogColor=ORIG_LIGHT.FogColor}
        end

        fog_target_on=on
        fog_last_distance=distance
        fog_last_color=CFG.FogColor

        if instant then
            Lighting.FogStart=goal.FogStart
            Lighting.FogEnd=goal.FogEnd
            Lighting.FogColor=goal.FogColor
            return
        end

        local TweenService=game:GetService("TweenService")
        local info=TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        local ok,t=pcall(function() return TweenService:Create(Lighting,info,goal) end)
        if ok and t then
            fog_tween=t
            t:Play()
        else
            Lighting.FogStart=goal.FogStart
            Lighting.FogEnd=goal.FogEnd
            Lighting.FogColor=goal.FogColor
        end
    end

    fog_apply(false,true)

    -- Lighting is state-driven, not frame-driven: no property spam on every Heartbeat.
    local last_fullbright,last_time,last_hour=nil,nil,nil
    track(RunService.Heartbeat:Connect(function()
        local fullbright=CFG.Fullbright and true or false
        local time_on=CFG.TimeChanger and true or false
        local hour=tonumber(CFG.TimeValue) or 12
        if fullbright~=last_fullbright then
            last_fullbright=fullbright
            if fullbright then
                Lighting.Brightness=3
                Lighting.GlobalShadows=false
            else
                Lighting.Brightness=ORIG_LIGHT.Brightness
                Lighting.GlobalShadows=ORIG_LIGHT.GlobalShadows
            end
        end
        if time_on~=last_time or (time_on and hour~=last_hour) then
            last_time=time_on
            last_hour=hour
            Lighting.ClockTime=time_on and hour or ORIG_LIGHT.ClockTime
        end

        local on=CFG.Fog and true or false
        local distance=math.max(50,tonumber(CFG.FogDistance) or 500)
        local color_index=CFG.FogColor
        if on~=fog_target_on or distance~=fog_last_distance or color_index~=fog_last_color then
            fog_apply(on,false)
        end
    end))

    -- После респавна Roblox может переинициализировать Lighting.
    track(LP.CharacterAdded:Connect(function()
        task.delay(0.1,function()
            if CFG.Fog then
                fog_apply(true,true)
            else
                fog_apply(false,true)
            end
        end)
    end))

    getgenv().ClumsyFogReset=function()
        fog_apply(false,true)
    end
end

-- ═══════════════════════════════════════════════════════════
-- SKYBOX · 8 PRESETS · БЕЗ АВТО-ЗАПУСКА
-- ═══════════════════════════════════════════════════════════
do
    local CHSKY_PRESET_NAME = "Purple Nebula"
    local CHSKY_created_sky = nil
    local CHSKY_current_name = nil
    local CHSKY_enabled = false

    local CHSKY_DATA = {
        ["Purple Nebula"] = {
            SkyboxBk="rbxassetid://13694952867", SkyboxDn="rbxassetid://13694968325",
            SkyboxFt="rbxassetid://13694980654", SkyboxLf="rbxassetid://13694998113",
            SkyboxRt="rbxassetid://13695002700", SkyboxUp="rbxassetid://13695007103",
            StarCount=3000, CelestialBodiesShown=false,
        },
        ["Red Night"] = {
            SkyboxBk="rbxassetid://401664839", SkyboxDn="rbxassetid://401664862",
            SkyboxFt="rbxassetid://401664960", SkyboxLf="rbxassetid://401664881",
            SkyboxRt="rbxassetid://401664901", SkyboxUp="rbxassetid://401664936",
            StarCount=3000, CelestialBodiesShown=false,
        },
        ["Galaxy"] = {
            SkyboxBk="rbxassetid://159454299", SkyboxDn="rbxassetid://159454296",
            SkyboxFt="rbxassetid://159454293", SkyboxLf="rbxassetid://159454286",
            SkyboxRt="rbxassetid://159454300", SkyboxUp="rbxassetid://159454288",
            StarCount=5000, CelestialBodiesShown=false,
        },
        ["Blossom"] = {
            SkyboxBk="rbxassetid://271042516", SkyboxDn="rbxassetid://271077243",
            SkyboxFt="rbxassetid://271042556", SkyboxLf="rbxassetid://271042310",
            SkyboxRt="rbxassetid://271042467", SkyboxUp="rbxassetid://271077958",
            StarCount=3000, CelestialBodiesShown=false,
        },
        ["Jungle"] = {
            SkyboxBk="rbxassetid://214399891", SkyboxDn="rbxassetid://214399887",
            SkyboxFt="rbxassetid://214399894", SkyboxLf="rbxassetid://214405668",
            SkyboxRt="rbxassetid://214399899", SkyboxUp="rbxassetid://214399889",
            StarCount=3000, CelestialBodiesShown=false,
        },
        ["Foggy"] = {
            SkyboxBk="rbxassetid://1370717244", SkyboxDn="rbxassetid://1370717336",
            SkyboxFt="rbxassetid://1370717438", SkyboxLf="rbxassetid://1370717567",
            SkyboxRt="rbxassetid://1370717698", SkyboxUp="rbxassetid://1370717782",
            StarCount=1000, CelestialBodiesShown=false,
        },
        ["Sunset"] = {
            SkyboxBk="rbxassetid://600830446", SkyboxDn="rbxassetid://600831635",
            SkyboxFt="rbxassetid://600830446", SkyboxLf="rbxassetid://600830446",
            SkyboxRt="rbxassetid://600830446", SkyboxUp="rbxassetid://600831635",
            StarCount=2000, CelestialBodiesShown=false,
        },
        ["Starry Night"] = {
            SkyboxBk="rbxassetid://12064107", SkyboxDn="rbxassetid://12064152",
            SkyboxFt="rbxassetid://12064121", SkyboxLf="rbxassetid://12063984",
            SkyboxRt="rbxassetid://12064115", SkyboxUp="rbxassetid://12064145",
            StarCount=8000, CelestialBodiesShown=false,
        },
    }

    local function CHSKY_purge()
        pcall(function()
            for _,v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") and (v.Name=="CH_Sky" or v.Name=="ClumsySky") then
                    v:Destroy()
                end
            end
        end)
    end

    local sky_apply_busy=false
    local sky_last_apply=0

    local function CHSKY_apply(name)
        local data=CHSKY_DATA[name]
        if not data then
            warn("[SKYBOX] preset not found: "..tostring(name))
            return false
        end
        if sky_apply_busy then return false end
        if os.clock()-sky_last_apply<0.10 then return false end
        sky_apply_busy=true
        sky_last_apply=os.clock()

        -- Reuse one Sky instance instead of destroying/creating it on every
        -- change. This removes the visible hitch caused by repeated cleanup.
        local sky=CHSKY_created_sky
        if not sky or not sky.Parent then
            CHSKY_purge()
            sky=Instance.new("Sky")
            sky.Name="CH_Sky"
            sky.Parent=Lighting
            CHSKY_created_sky=sky
        end
        pcall(function() sky.SkyboxBk=data.SkyboxBk end)
        pcall(function() sky.SkyboxDn=data.SkyboxDn end)
        pcall(function() sky.SkyboxFt=data.SkyboxFt end)
        pcall(function() sky.SkyboxLf=data.SkyboxLf end)
        pcall(function() sky.SkyboxRt=data.SkyboxRt end)
        pcall(function() sky.SkyboxUp=data.SkyboxUp end)
        pcall(function() sky.StarCount=data.StarCount or 3000 end)
        pcall(function() sky.CelestialBodiesShown=data.CelestialBodiesShown or false end)
        CHSKY_current_name=name
        sky_apply_busy=false
        return true
    end

    local function CHSKY_restore()
        CHSKY_purge()
        if CHSKY_created_sky then
            pcall(function() CHSKY_created_sky:Destroy() end)
            CHSKY_created_sky=nil
        end
        CHSKY_current_name=nil
    end

    getgenv().SKY={
        set=function(v)
            CHSKY_enabled=v and true or false
            if CHSKY_enabled then
                return CHSKY_apply(CHSKY_PRESET_NAME)
            end
            CHSKY_restore()
            return true
        end,
        set_preset=function(name)
            if not CHSKY_DATA[name] then return false end
            CHSKY_PRESET_NAME=name
            CFG.SkyboxName=table.find(SKYBOX_PRESETS,name) or CFG.SkyboxName
            if CHSKY_enabled then return CHSKY_apply(name) end
            return true
        end,
        list=function()
            local out={}
            for name in pairs(CHSKY_DATA) do out[#out+1]=name end
            table.sort(out)
            return out
        end,
        current=function() return CHSKY_current_name end,
        is_on=function() return CHSKY_enabled end,
        clear=CHSKY_restore,
    }

    getgenv().SKYBOX_UNLOAD=function()
        CHSKY_enabled=false
        pcall(CHSKY_restore)
        getgenv().SKY=nil
    end

    onAccentChange(function() end)
end

-- Tracer
-- Одна длинная линия на выстрел, КД 3.3 сек.
-- Рисуется в 3D-мире через BoxHandleAdornment, а не Drawing на экране.
-- AlwaysOnTop позволяет видеть линию сквозь стены.
local tracer_parts={}
local TRACER_COOLDOWN=3.3
local TRACER_LENGTH=3000
local last_tracer_fire=0

local function clear_tracers()
    for i=#tracer_parts,1,-1 do
        local e=tracer_parts[i]
        if e then
            if e.adornment and e.adornment.Parent then pcall(function() e.adornment:Destroy() end) end
            if e.part and e.part.Parent then pcall(function() e.part:Destroy() end) end
        end
        tracer_parts[i]=nil
    end
end

local function spawn_tracer_world(fromPos,toPos,color,duration)
    if typeof(fromPos)~="Vector3" or typeof(toPos)~="Vector3" then return end
    local delta=toPos-fromPos
    local length=delta.Magnitude
    if length<1 then return end

    local mid=fromPos+delta*0.5
    local part=Instance.new("Part")
    part.Name="CH_WorldTracer"
    part.Anchored=true
    part.CanCollide=false
    part.CanTouch=false
    part.CanQuery=false
    part.CastShadow=false
    part.Transparency=1
    part.Size=Vector3.new(0.08,0.08,math.max(length,0.1))
    part.CFrame=CFrame.lookAt(mid,toPos)
    part.Parent=WS

    local adorn=Instance.new("BoxHandleAdornment")
    adorn.Name="CH_WorldTracerLine"
    adorn.Adornee=part
    adorn.AlwaysOnTop=true
    adorn.ZIndex=10
    adorn.Size=Vector3.new(0.12,0.12,math.max(length,0.1))
    adorn.CFrame=CFrame.new()
    adorn.Color3=color
    adorn.Transparency=0
    adorn.Parent=part

    local entry={part=part,adornment=adorn,t0=os.clock(),dur=math.max(tonumber(duration) or 4,0.15)}
    tracer_parts[#tracer_parts+1]=entry
end

track(RunService.Heartbeat:Connect(function()
    local now=os.clock()
    for i=#tracer_parts,1,-1 do
        local e=tracer_parts[i]
        if not e or not e.part or not e.part.Parent or not e.adornment or not e.adornment.Parent then
            table.remove(tracer_parts,i)
        elseif now-e.t0>=e.dur then
            pcall(function() e.adornment:Destroy() end)
            pcall(function() e.part:Destroy() end)
            table.remove(tracer_parts,i)
        end
    end
end))

track(LP.CharacterRemoving:Connect(function()
    clear_tracers()
end))

local function tracer_origin()
    local c=LP.Character
    if not c then return nil end
    local att=c:FindFirstChild("GunRaycastAttachment")
    if att then
        local ok,pos=pcall(function() return att.WorldPosition end)
        if ok and typeof(pos)=="Vector3" then return pos end
    end
    local gun=getGun()
    if gun then
        local h=gun:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then return h.Position end
    end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position+Vector3.new(0,2,0) end
end

local lastAimScreen=nil
local function tracer_end(origin,screenPos)
    local cam=WS.CurrentCamera
    local dir=nil
    if cam then
        local p=screenPos
        if not p then
            local ok,mp=pcall(function() return UserInputService:GetMouseLocation() end)
            if ok then p=mp end
        end
        if p then
            local ray=cam:ViewportPointToRay(p.X,p.Y)
            dir=ray.Direction
        else
            dir=cam.CFrame.LookVector
        end
    end
    if not dir or dir.Magnitude<0.1 then
        local gun=getGun()
        local att=gun and gun:FindFirstChild("GunRaycastAttachment",true)
        if att and att:IsA("Attachment") then
            dir=att.WorldCFrame.LookVector
        end
    end
    if not dir or dir.Magnitude<0.1 then
        local gun=getGun()
        local h=gun and gun:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then dir=h.CFrame.LookVector end
    end
    if not dir or dir.Magnitude<0.1 then
        dir=Vector3.new(0,0,-1)
    end
    dir=dir.Unit
    local hitPos=origin+dir*TRACER_LENGTH
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={LP.Character}
    local hit=WS:Raycast(origin,dir*TRACER_LENGTH,params)
    if hit then hitPos=hit.Position end
    return hitPos
end

local function fire_tracer(screenPos)
    if not CFG.BulletTracer then return end
    local gun=getGun()
    if not gun or gun.Parent~=LP.Character then return end
    local now=os.clock()
    if now-last_tracer_fire<TRACER_COOLDOWN then return end
    last_tracer_fire=now
    task.defer(function()
        local from=tracer_origin()
        if not from then return end
        local to=tracer_end(from,screenPos or lastAimScreen)
        local color=TRACER_VALUES[CFG.TracerColor] or Color3.fromRGB(255,60,60)
        spawn_tracer_world(from,to,color,math.max(tonumber(CFG.TracerDuration) or 4,0.5))
    end)
end

track(UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement then
        lastAimScreen=Vector2.new(input.Position.X,input.Position.Y)
    end
end))

track(UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
        lastAimScreen=Vector2.new(input.Position.X,input.Position.Y)
        fire_tracer(lastAimScreen)
    end
end))

track(RunService.Heartbeat:Connect(function()
    if not CFG.BulletTracer then return end
    local char=LP.Character
    if not char then return end
    local tool=char:FindFirstChildOfClass("Tool")
    if tool and (tool.Name:lower():find("gun",1,true) or tool.Name:lower():find("pistol",1,true) or tool.Name:lower():find("revolver",1,true)) then
        if not tool:GetAttribute("CH_TracerHook") then
            tool:SetAttribute("CH_TracerHook",true)
            track(tool.Activated:Connect(function()
                fire_tracer(lastAimScreen)
            end))
        end
    end
end))

-- Убираем системный звук выстрела у пистолета, чтобы оставался только CH Shot Sound.
local function suppressGunSounds()
    local char=LP.Character
    if not char then return end
    local gun=getGun()
    if not gun then return end
    for _,d in ipairs(gun:GetDescendants()) do
        if d:IsA("Sound") and d.Name~="CH_ShotSound" then
            local n=string.lower(tostring(d.Name or ""))
            -- Keep the game's native reload/recharge sound audible, while the
            -- original firing sound remains suppressed when Shot Sound is used.
            local isReload=n:find("reload",1,true) or n:find("recharg",1,true) or n:find("magazine",1,true) or n:find("clip",1,true)
            if not isReload then
                pcall(function()
                    d.Volume=0
                end)
            end
        end
    end
end
track(RunService.Heartbeat:Connect(function()
    if CFG.ShotSound then
        pcall(suppressGunSounds)
    end
end))

-- Shot/Kill sounds
SHOT_ID="rbxassetid://138371055472255" DEATH_ID="rbxassetid://1837879082"
shot_sound=nil death_sound=nil last_shot_play=0 last_death_play=0
local function attachShotSound()
    if shot_sound then pcall(function() shot_sound:Destroy() end) shot_sound=nil end
    local char=LP.Character if not char then return end
    local head=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") if not head then return end
    shot_sound=Instance.new("Sound") shot_sound.Name="CH_ShotSound" shot_sound.SoundId=SHOT_ID
    shot_sound.Volume=CFG.ShotSoundVolume shot_sound.Parent=head
    task.spawn(function() pcall(function() ContentProvider:PreloadAsync({shot_sound}) end) end)
end
local function playShotSound()
    if not CFG.ShotSound or not hasGun() then return end
    local now=os.clock() if now-last_shot_play<3.3 then return end
    last_shot_play=now
    if not shot_sound or not shot_sound.Parent then attachShotSound() end
    if shot_sound then shot_sound.Volume=CFG.ShotSoundVolume pcall(function() shot_sound.TimePosition=0 shot_sound:Play() end) end
end
track(UserInputService.InputBegan:Connect(function(input,gp) if gp then return end if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then playShotSound() end end))
local function attachDeathSound()
    if death_sound then pcall(function() death_sound:Destroy() end) death_sound=nil end
    local char=LP.Character if not char then return end
    local head=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") if not head then return end
    death_sound=Instance.new("Sound") death_sound.Name="CH_DeathSound" death_sound.SoundId=DEATH_ID
    death_sound.Volume=CFG.KillSoundVolume death_sound.Parent=head
    task.spawn(function() pcall(function() ContentProvider:PreloadAsync({death_sound}) end) end)
end
track(task.spawn(function()
    while true do
        task.wait(1)
        if CFG.KillSound and not death_sound then attachDeathSound() end
        if CFG.ShotSound and not shot_sound then attachShotSound() end
    end
end))
track(LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if CFG.ShotSound then pcall(attachShotSound) end
    if CFG.KillSound then pcall(attachDeathSound) end
end))

-- Trail
activeTrail,trailA0,trailA1=nil,nil,nil
local function clearTrail()
    if activeTrail and activeTrail.Parent then pcall(function() activeTrail:Destroy() end) end
    if trailA0 and trailA0.Parent then pcall(function() trailA0:Destroy() end) end
    if trailA1 and trailA1.Parent then pcall(function() trailA1:Destroy() end) end
    activeTrail,trailA0,trailA1=nil,nil,nil
end
local function createTrail(char)
    if not char then return end
    local root=char:WaitForChild("HumanoidRootPart",5) if not root then return end
    clearTrail()
    trailA0=Instance.new("Attachment",root) trailA0.Name="ClumsyTrailAttachment0" trailA0.Position=Vector3.new(0,-2.35,0)
    trailA1=Instance.new("Attachment",root) trailA1.Name="ClumsyTrailAttachment1" trailA1.Position=Vector3.new(0,-2.4,0)
    activeTrail=Instance.new("Trail") activeTrail.Name="ClumsyActiveTrail"
    activeTrail.Attachment0=trailA0 activeTrail.Attachment1=trailA1
    activeTrail.Lifetime=1.2 activeTrail.FaceCamera=true
    activeTrail.Color=ColorSequence.new(TRAIL_VALUES[CFG.TrailColor] or Color3.new(1,1,1))
    activeTrail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
    activeTrail.LightEmission=1 activeTrail.LightInfluence=0 activeTrail.Parent=root
end

-- После смерти Roblox полностью уничтожает старый Character и его Trail.
-- Поэтому после каждого нового Character создаём Trail заново, если функция включена.
track(LP.CharacterAdded:Connect(function(char)
    task.delay(0.35,function()
        if CFG.Trails and char==LP.Character then
            pcall(function() createTrail(char) end)
        end
    end)
end))

track(RunService.Heartbeat:Connect(function()
    if CFG.Trails then
        if not activeTrail or not activeTrail.Parent then createTrail(LP.Character) end
        if activeTrail then activeTrail.Color=ColorSequence.new(TRAIL_VALUES[CFG.TrailColor] or Color3.new(1,1,1)) end
    elseif activeTrail then clearTrail() end
end))

-- Jump Ring
lastJumpRing,jumpRingArmed=0,true
track(RunService.Heartbeat:Connect(function()
    if not CFG.JumpRing then jumpRingArmed=true return end
    local h=my_hum() local hrp=my_hrp() if not h or not hrp then return end
    local onGround=h.FloorMaterial~=Enum.Material.Air
    if onGround then jumpRingArmed=true end
    if not onGround and jumpRingArmed then
        local now=tick()
        if now-lastJumpRing>=0.4 then
            lastJumpRing=now jumpRingArmed=false
            local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={LP.Character}
            local hit=WS:Raycast(hrp.Position,Vector3.new(0,-10,0),params)
            local y=hit and (hit.Position.Y+0.05) or (hrp.Position.Y-3)
            local color=COLOR_VALUES[CFG.JumpRingColor] or Color3.new(1,1,1)
            local disc=Instance.new("Part")
            disc.Shape=Enum.PartType.Cylinder disc.Size=Vector3.new(0.05,1.5,1.5)
            disc.CFrame=CFrame.new(Vector3.new(hrp.Position.X,y,hrp.Position.Z))*CFrame.Angles(0,0,math.rad(90))
            disc.Anchored=true disc.CanCollide=false disc.Transparency=0.15 disc.Material=Enum.Material.Neon disc.Color=color disc.Parent=WS
            TweenService:Create(disc,TweenInfo.new(0.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(0.05,CFG.JumpRingSize*2,CFG.JumpRingSize*2),Transparency=1}):Play()
            task.delay(0.6,function() pcall(function() disc:Destroy() end) end)
        end
    end
end))

-- Snowfall / Dust
Dust={active=false,folder=nil,particles={},conn=nil,lastRootPos=nil}
local function dustColor() return SNOW_VALUES[CFG.SnowColor] or SNOW_VALUES[1] end
local function stopDust()
    Dust.active=false
    if Dust.conn then pcall(function() Dust.conn:Disconnect() end) Dust.conn=nil end
    for _,p in ipairs(Dust.particles) do if p.Part and p.Part.Parent then pcall(function() p.Part:Destroy() end) end end
    Dust.particles={}
    if Dust.folder and Dust.folder.Parent then pcall(function() Dust.folder:Destroy() end) end
    Dust.folder=nil Dust.lastRootPos=nil
end
local function startDust()
    if Dust.active then return end
    Dust.active=true
    local existing=WS:FindFirstChild("CH_Dust") if existing then existing:Destroy() end
    local folder=Instance.new("Folder") folder.Name="CH_Dust" folder.Parent=WS
    Dust.folder=folder Dust.particles={}
    local MAX=60 RADIUS=60
    Dust.conn=RunService.RenderStepped:Connect(function()
        if not Dust.active then return end
        local char=LP.Character if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local rootPos=hrp.Position
        if Dust.lastRootPos then local delta=rootPos-Dust.lastRootPos if delta.Magnitude>50 then for _,p in ipairs(Dust.particles) do p.Position=p.Position+delta end end end
        Dust.lastRootPos=rootPos
        local toAdd=MAX-#Dust.particles
        if toAdd>0 then
            for _=1,math.min(toAdd,3) do
                local ox=math.random(-60,60) oz=math.random(-60,60) hy=math.random(-1,8)+2
                local pos=Vector3.new(rootPos.X+ox,rootPos.Y+hy,rootPos.Z+oz)
                local col=dustColor()
                local part=Instance.new("Part")
                part.Shape=Enum.PartType.Ball part.Size=Vector3.new(0.2,0.2,0.2)
                part.Color=col part.Material=Enum.Material.Neon
                part.CanCollide=false part.Anchored=true part.CastShadow=false
                part.CFrame=CFrame.new(pos) part.Parent=folder
                table.insert(Dust.particles,{Part=part,Position=pos})
            end
        end
        for i=#Dust.particles,1,-1 do
            local p=Dust.particles[i]
            local newPos=p.Position+Vector3.new((math.random()-0.5)*0.4,-0.15,(math.random()-0.5)*0.4)
            p.Position=newPos
            if p.Part and p.Part.Parent then p.Part.CFrame=CFrame.new(newPos) end
            if (newPos-rootPos).Magnitude>RADIUS*1.4 then if p.Part and p.Part.Parent then p.Part:Destroy() end table.remove(Dust.particles,i) end
        end
    end)
end

-- Death FX
DeathFx=(function()
    local clones,active_emitters,emitter_count={},{},0
    local wall_highlights={}
    local hooked_players={}
    local function remove_emitter(rec)
        for i=1,emitter_count do if active_emitters[i]==rec then active_emitters[i]=active_emitters[emitter_count] active_emitters[emitter_count]=nil emitter_count=emitter_count-1 break end end
        if rec.part then local h=wall_highlights[rec.part] if h and h.Parent then h:Destroy() end wall_highlights[rec.part]=nil end
        if rec.part and rec.part.Parent then rec.part:Destroy() end
    end
    local function refresh_wall_visibility()
        local enabled=CFG.DeathFxThroughWalls==true
        for _,clone in ipairs(clones) do
            if clone and clone.Parent then
                local hl=wall_highlights[clone]
                if enabled then
                    if not hl then
                        hl=Instance.new("Highlight")
                        hl.Name="CH_DeathThroughWalls"
                        hl.Adornee=clone
                        hl.FillTransparency=0.05
                        hl.OutlineTransparency=0
                        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent=WS
                        wall_highlights[clone]=hl
                    end
                    hl.FillColor=DEATHFX_VALUES[CFG.DeathFxColor] or DEATHFX_VALUES[1]
                    hl.Enabled=true
                elseif hl then
                    hl.Enabled=false
                end
            end
        end
        for i=1,emitter_count do
            local rec=active_emitters[i]
            local root=rec and rec.part
            if root and root.Parent then
                local hl=wall_highlights[root]
                if enabled then
                    if not hl then
                        hl=Instance.new("Highlight")
                        hl.Name="CH_DeathThroughWalls"
                        hl.Adornee=root
                        hl.FillTransparency=0.05
                        hl.OutlineTransparency=0
                        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent=WS
                        wall_highlights[root]=hl
                    end
                    hl.FillColor=DEATHFX_VALUES[CFG.DeathFxColor] or DEATHFX_VALUES[1]
                    hl.Enabled=true
                elseif hl then
                    hl.Enabled=false
                end
            end
        end
    end

    local function spawn_emitter(char,tint,duration)
        if not char or not char.Parent then return end
        if emitter_count>=3 then remove_emitter(active_emitters[1]) end
        duration=math.max(duration or 1.2,0.2)
        local body_parts={}
        for _,source in ipairs(char:GetChildren()) do if source:IsA("BasePart") and source.Name~="HumanoidRootPart" and #body_parts<15 then body_parts[#body_parts+1]=source end end
        if #body_parts==0 then return end
        local root=Instance.new("Model") root.Name="CH_DeathEmitter" root.Parent=WS
        local record={part=root,balls={}} emitter_count=emitter_count+1 active_emitters[emitter_count]=record
        local wallHighlight=Instance.new("Highlight")
        wallHighlight.Name="CH_DeathThroughWalls"
        wallHighlight.Adornee=root
        wallHighlight.FillColor=tint
        wallHighlight.FillTransparency=0.16
        wallHighlight.OutlineColor=tint
        wallHighlight.OutlineTransparency=0.05
        wallHighlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        wallHighlight.Enabled=true
        wallHighlight.Parent=WS
        if CFG.DeathFxThroughWalls~=true then wallHighlight.Enabled=false end
        wall_highlights[root]=wallHighlight
        local random=math.random
        local min_y,max_y=math.huge,-math.huge
        for _,source in ipairs(body_parts) do local hy=source.Size.Y*0.5 min_y=math.min(min_y,source.Position.Y-hy) max_y=math.max(max_y,source.Position.Y+hy) end
        local height=math.max(max_y-min_y,0.01) local created=0
        for _,source in ipairs(body_parts) do
            local size=source.Size local surface=2*(size.X*size.Y+size.X*size.Z+size.Y*size.Z)
            local count=source.Name=="Head" and 24 or math.clamp(math.floor(surface*0.65+0.5),7,12)
            count=math.min(count,140-created)
            for index=1,count do
                local diameter=source.Name=="Head" and (0.115+random()*0.045) or (0.13+random()*0.06)
                local target_size=Vector3.new(diameter,diameter,diameter)
                local padding=diameter*0.5*0.92
                local pos
                if source.Name=="Head" then
                    local y=1-2*((index-0.5)/count)
                    local angle=index*math.pi*(3-math.sqrt(5))
                    local radial=math.sqrt(math.max(0,1-y*y))
                    pos=source.CFrame:PointToWorldSpace(Vector3.new(radial*math.cos(angle)*(size.X*0.5+padding),y*(size.Y*0.5+padding),radial*math.sin(angle)*(size.Z*0.5+padding)))
                else
                    local ax,ay,az=size.Y*size.Z,size.X*size.Z,size.X*size.Y
                    local pick=random()*(ax+ay+az)
                    if pick<ax then local s=random()<0.5 and -1 or 1 pos=source.CFrame:PointToWorldSpace(Vector3.new(s*(size.X*0.5+padding),(random()-0.5)*size.Y,(random()-0.5)*size.Z))
                    elseif pick<ax+ay then local s=random()<0.5 and -1 or 1 pos=source.CFrame:PointToWorldSpace(Vector3.new((random()-0.5)*size.X,s*(size.Y*0.5+padding),(random()-0.5)*size.Z))
                    else local s=random()<0.5 and -1 or 1 pos=source.CFrame:PointToWorldSpace(Vector3.new((random()-0.5)*size.X,(random()-0.5)*size.Y,s*(size.Z*0.5+padding))) end
                end
                local ball=Instance.new("Part")
                ball.Shape=Enum.PartType.Ball ball.Material=Enum.Material.Neon ball.Color=tint
                ball.Size=Vector3.new(0.015,0.015,0.015) ball.Position=pos ball.Anchored=true
                ball.CanCollide=false ball.CanQuery=false ball.CanTouch=false ball.CastShadow=false
                ball.Massless=true ball.Transparency=1 ball.Parent=root
                record.balls[#record.balls+1]=ball created=created+1
                local vertical=math.clamp((pos.Y-min_y)/height,0,1)
                local phase=math.clamp(math.floor(vertical*7+1.5)+random(-1,1),1,8)
                if not record.groups then record.groups={} for gi=1,8 do record.groups[gi]={} end end
                record.groups[phase][#record.groups[phase]+1]={ball=ball,size=target_size}
            end
            if created>=140 then break end
        end
        local rw=math.min(0.34,duration*0.26) local rt=math.min(0.2,duration*0.18)
        local fb=math.max(rw+rt+0.06,duration*0.42) local fw=math.min(0.28,duration*0.18)
        local ft=math.max(duration-fb-fw,0.1)
        if record.groups then
            for phase=1,8 do
                local alpha=(phase-1)/7 local group=record.groups[phase]
                task.delay(rw*alpha,function() if not root.Parent then return end for _,item in ipairs(group) do if item.ball.Parent then TweenService:Create(item.ball,TweenInfo.new(rt,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size=item.size,Transparency=0.05}):Play() end end end)
                task.delay(fb+fw*alpha,function() if not root.Parent then return end for _,item in ipairs(group) do if item.ball.Parent then TweenService:Create(item.ball,TweenInfo.new(ft,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=item.size*0.58,Transparency=1}):Play() end end end)
            end
        end
        task.delay(duration+0.12,function() remove_emitter(record) end)
    end
    local function make_clone(char,tint,dur)
        local ok,clone=pcall(function() return char:Clone() end) if not ok or not clone then return end
        for _,d in ipairs(clone:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored=true d.CanCollide=false d.CanQuery=false d.CanTouch=false d.CastShadow=false
                if d.Name=="HumanoidRootPart" then d.Transparency=1 else d.Material=Enum.Material.ForceField d.Color=tint d.Transparency=0 end
            elseif not d:IsA("Model") and not d:IsA("Folder") then pcall(function() d:Destroy() end) end
        end
        clone.Name="CH_DeathClone" clone.Parent=WS clones[#clones+1]=clone
        local hl=Instance.new("Highlight")
        hl.Name="CH_DeathThroughWalls"
        hl.Adornee=clone
        hl.FillColor=tint
        hl.FillTransparency=0.05
        hl.OutlineColor=tint
        hl.OutlineTransparency=0
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled=true
        hl.Parent=WS
        wall_highlights[clone]=hl
        if CFG.DeathFxThroughWalls~=true then hl.Enabled=false end
        task.delay(dur,function()
            if not clone.Parent then return end
            for _,d in ipairs(clone:GetDescendants()) do if d:IsA("BasePart") then pcall(function() TweenService:Create(d,TweenInfo.new(1.5),{Transparency=1}):Play() end) end end
            task.delay(1.6,function() wall_highlights[clone]=nil if hl and hl.Parent then hl:Destroy() end for i=#clones,1,-1 do if clones[i]==clone then table.remove(clones,i) end end if clone.Parent then clone:Destroy() end end)
        end)
    end
    local function on_death(char,is_murderer)
        if not CFG.DeathFx then return end
        local target=CFG.DeathFxTarget or 1
        if target==1 and not is_murderer then return end
        local tint=DEATHFX_VALUES[CFG.DeathFxColor] or DEATHFX_VALUES[1]
        local dur=CFG.DeathFxDuration or 1.2
        if CFG.DeathFxClone then make_clone(char,tint,dur) end
        if CFG.DeathFxParticle then spawn_emitter(char,tint,dur) end
    end
    local function bind_char(pl,char)
        local hum=char:WaitForChild("Humanoid",5) if not hum then return end
        hum.Died:Connect(function() if not CFG.DeathFx then return end on_death(char,playerRole(pl)=="murderer") end)
    end
    local function watch(pl)
        if hooked_players[pl] then return end
        hooked_players[pl]=true
        if pl.Character then task.spawn(bind_char,pl,pl.Character) end
        pl.CharacterAdded:Connect(function(c) task.spawn(bind_char,pl,c) end)
    end
    track(task.spawn(function() while true do task.wait(1.2) if CFG.DeathFx then for _,pl in ipairs(Players:GetPlayers()) do watch(pl) end end end end))
    return {
        clear=function() for i=#clones,1,-1 do local c=clones[i] local h=wall_highlights[c] if h and h.Parent then h:Destroy() end wall_highlights[c]=nil if c and c.Parent then c:Destroy() end clones[i]=nil end for i=1,emitter_count do if active_emitters[i] then remove_emitter(active_emitters[i]) end active_emitters[i]=nil end emitter_count=0 end,
        stop=function() hooked_players={} end,
        set_through_walls=function(v) CFG.DeathFxThroughWalls=v and true or false refresh_wall_visibility() end,
    }
end)()

-- Anti Fling · NEW USER VERSION
-- Защита от столкновений с другими моделями + защита от резкого fling.
do
    local anti_fling = false
    local fling_cache = {}
    local fling_reg = {}
    local fling_safe_cf = nil
    local fling_hold_until = 0

    local FLING_MAX_VEL = 700
    local FLING_MAX_ANG = 90
    local FLING_HOLD = 0.25
    local FLING_SAFE_VEL = 250
    local FLING_SNAP_DIST = 60

    local function fling_kill_part(p)
        if fling_cache[p] == nil then
            fling_cache[p] = p.CanCollide
        end
        if p.CanCollide then
            p.CanCollide = false
        end
    end

    local function fling_unregister(model)
        local entry = fling_reg[model]
        if not entry then return end

        fling_reg[model] = nil

        for i = 1, #entry.conns do
            pcall(function()
                entry.conns[i]:Disconnect()
            end)
        end

        for p in pairs(entry.parts) do
            local v = fling_cache[p]
            fling_cache[p] = nil

            if v ~= nil and p.Parent then
                pcall(function()
                    p.CanCollide = v
                end)
            end
        end

        table.clear(entry.parts)
    end

    local function fling_register(model)
        if not anti_fling or not model then return end
        if fling_reg[model] or model == LP.Character then return end

        local entry = {
            parts = {},
            conns = {}
        }

        fling_reg[model] = entry

        local function add(d)
            if d:IsA("BasePart") and not entry.parts[d] then
                entry.parts[d] = true
                if anti_fling then
                    pcall(fling_kill_part, d)
                end
            end
        end

        for _, d in model:GetDescendants() do
            pcall(add, d)
        end

        local function push(c)
            entry.conns[#entry.conns + 1] = c
        end

        push(model.DescendantAdded:Connect(function(d)
            if anti_fling then
                pcall(add, d)
            end
        end))

        push(model.DescendantRemoving:Connect(function(d)
            if entry.parts[d] then
                entry.parts[d] = nil
                fling_cache[d] = nil
            end
        end))

        push(model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                fling_unregister(model)
            end
        end))
    end

    local function fling_is_body(m)
        return m ~= LP.Character
            and m:IsA("Model")
            and m:FindFirstChildOfClass("Humanoid") ~= nil
    end

    local function fling_scan()
        for _, pl in Players:GetPlayers() do
            if pl ~= LP and pl.Character then
                fling_register(pl.Character)
            end
        end

        for _, m in WS:GetChildren() do
            if fling_is_body(m) then
                fling_register(m)
            end
        end
    end

    local function fling_sweep()
        for model, entry in pairs(fling_reg) do
            if not model.Parent or model == LP.Character then
                fling_unregister(model)
            else
                for p in pairs(entry.parts) do
                    if p.Parent then
                        if p.CanCollide then
                            if fling_cache[p] == nil then
                                fling_cache[p] = true
                            end
                            p.CanCollide = false
                        end
                    else
                        entry.parts[p] = nil
                        fling_cache[p] = nil
                    end
                end
            end
        end
    end

    local function fling_busy()
        return false
    end

    local function fling_guard(full)
        local hrp = my_hrp()

        if not hrp or not hrp.Parent then
            fling_safe_cf = nil
            return
        end

        if fling_busy() then
            fling_safe_cf = nil
            return
        end

        local lin = hrp.AssemblyLinearVelocity
        local ang = hrp.AssemblyAngularVelocity

        local spike =
            lin.Magnitude > FLING_MAX_VEL
            or ang.Magnitude > FLING_MAX_ANG

        local now = os.clock()

        if spike then
            fling_hold_until = now + FLING_HOLD
        end

        if spike or now < fling_hold_until then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            if full and fling_safe_cf then
                if (hrp.Position - fling_safe_cf.Position).Magnitude > FLING_SNAP_DIST then
                    pcall(function()
                        hrp.CFrame = fling_safe_cf
                    end)
                end
            end
        elseif full and lin.Magnitude < FLING_SAFE_VEL then
            fling_safe_cf = hrp.CFrame
        end
    end

    local function fling_clear_all()
        for model in pairs(fling_reg) do
            fling_unregister(model)
        end
        fling_reg = {}

        for p, v in pairs(fling_cache) do
            if p and p.Parent and v ~= nil then
                pcall(function()
                    p.CanCollide = v
                end)
            end
            fling_cache[p] = nil
        end

        fling_safe_cf = nil
        fling_hold_until = 0
    end

    track(RunService.Stepped:Connect(function()
        CFG.AntiFling=false
        CFG.AntiCoin=false
        anti_fling = true

        if not anti_fling then
            if next(fling_reg) or next(fling_cache) then
                fling_clear_all()
            end
            return
        end

        pcall(fling_scan)
        pcall(fling_sweep)
        pcall(function()
            fling_guard(true)
        end)
    end))

    Players.PlayerAdded:Connect(function(pl)
        if pl == LP then return end
        pl.CharacterAdded:Connect(function(char)
            task.wait(0.15)
            if anti_fling then
                pcall(fling_register, char)
            end
        end)
    end)

    for _, pl in Players:GetPlayers() do
        if pl ~= LP then
            pl.CharacterAdded:Connect(function(char)
                task.wait(0.15)
                if anti_fling then
                    pcall(fling_register, char)
                end
            end)
        end
    end
end

-- Anti Void
local void_backup=WS.FallenPartsDestroyHeight void_safe=nil void_last_check=0
track(RunService.Heartbeat:Connect(function()
    if CFG.AntiVoid then
        if WS.FallenPartsDestroyHeight~=-9e9 then WS.FallenPartsDestroyHeight=-9e9 end
        local hrp=my_hrp() if not hrp then return end
        local y=hrp.Position.Y
        if y>(CFG.AntiVoidY+30) then local now=os.clock() if now-void_last_check>0.5 then void_last_check=now void_safe=hrp.CFrame end end
        if y<CFG.AntiVoidY then local dest=void_safe or CFrame.new(0,50,0) pcall(function() hrp.CFrame=dest hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end) end
    elseif WS.FallenPartsDestroyHeight==-9e9 then WS.FallenPartsDestroyHeight=void_backup end
end))

-- Anti Coin (v32)
track(CollectionService:GetInstanceAddedSignal("CoinVisual"):Connect(function(v)
    if not CFG.AntiCoin then return end
    task.wait()
    if CFG.AntiCoin and v and v.Parent then
        pcall(function()
            local function disable(p) if p:IsA("BasePart") then p.CanTouch=false p.CanQuery=false end end
            disable(v)
            for _,d in ipairs(v:GetDescendants()) do disable(d) if d:IsA("ProximityPrompt") then d.Enabled=false end end
        end)
    end
end))
track(WS.DescendantAdded:Connect(function(d)
    if not CFG.AntiCoin then return end
    if d.Name=="CoinContainer" then
        task.wait()
        if CFG.AntiCoin and d and d.Parent then
            pcall(function()
                for _,p in ipairs(d:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanTouch=false p.CanQuery=false
                    elseif p:IsA("ProximityPrompt") then p.Enabled=false end
                end
            end)
        end
    end
end))

-- Anti Trap
local trap_speed_cache=16 trap_jump_cache=50 trap_window=0 trap_busy=false trap_hit_conn=nil
local function trap_hum() local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function trap_unlock(hum) if not hum or not hum.Parent then return end pcall(function() if hum.WalkSpeed<=1 then hum.WalkSpeed=trap_speed_cache end if hum.JumpPower<=1 then hum.JumpPower=trap_jump_cache end end) end
local function trap_engage()
    if not CFG.AntiTrap then return end
    trap_window=os.clock()+5
    local hum=trap_hum()
    if hum then if hum.WalkSpeed>1 then trap_speed_cache=hum.WalkSpeed end if hum.JumpPower>1 then trap_jump_cache=hum.JumpPower end end
    pcall(function() local pg=LP:FindFirstChild("PlayerGui") if pg then for _,c in ipairs(pg:GetChildren()) do if c.Name=="TrapGUI" then c:Destroy() end end end end)
    if trap_busy then return end
    trap_busy=true
    task.spawn(function() while CFG.AntiTrap and os.clock()<trap_window do trap_unlock(trap_hum()) RunService.Heartbeat:Wait() end trap_busy=false end)
end
local function trap_attach()
    if trap_hit_conn then return end
    local ok,remote=pcall(function() local sys=RSvc:FindFirstChild("TrapSystem") return sys and sys:FindFirstChild("TrapHitLocal") end)
    if not ok or not remote then return end
    trap_hit_conn=remote.OnClientEvent:Connect(function() task.spawn(trap_engage) end)
end
local function trap_detach() if trap_hit_conn then pcall(function() trap_hit_conn:Disconnect() end) trap_hit_conn=nil end trap_unlock(trap_hum()) end
track(task.spawn(function() while true do task.wait(0.5) if CFG.AntiTrap and not trap_hit_conn then trap_attach() elseif not CFG.AntiTrap and trap_hit_conn then trap_detach() end end end))

-- Anti AFK
LP.Idled:Connect(function() if CFG.AntiAfk then pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end end)

-- Fake Pos
track(RunService.Heartbeat:Connect(function()
    getgenv().FAKE_POS_ACTIVE=CFG.FakePos and true or false
    if not CFG.FakePos then return end
    local hrp=my_hrp() if not hrp then return end
    if type(sethiddenproperty)=="function" then pcall(function() sethiddenproperty(hrp,"NetworkIsSleeping",false) end) end
    local old=hrp.CFrame local r=(CFG.FakePosRange or 9)*1e9
    local fake=CFrame.new((math.random()*2-1)*r,-(math.random())*r,(math.random()*2-1)*r)*CFrame.Angles(math.rad(math.random(1,359)),math.rad(math.random(1,359)),math.rad(math.random(1,359)))
    pcall(function() hrp.CFrame=fake end)
    RunService.RenderStepped:Wait()
    if hrp and hrp.Parent then pcall(function() hrp.CFrame=old end) end
end))

-- Vel Spoof
track(RunService.Heartbeat:Connect(function()
    if not CFG.VelSpoof then return end
    local hrp=my_hrp() if not hrp then return end
    if type(sethiddenproperty)=="function" then pcall(function() sethiddenproperty(hrp,"NetworkIsSleeping",false) end) end
    local oldL=hrp.AssemblyLinearVelocity local oldA=hrp.AssemblyAngularVelocity
    local mode=CFG.VelSpoofMode local v
    if mode==1 then v=Vector3.new(math.random(-300,300),math.random(-300,300),math.random(-300,300))
    elseif mode==2 then v=Vector3.new(math.random(-16000,16000),math.random(-16000,16000),math.random(-16000,16000))
    elseif mode==3 then v=Vector3.new(0,16000,0)
    elseif mode==4 then v=Vector3.new(9e9,9e9,9e9)
    else v=Vector3.zero end
    pcall(function() hrp.AssemblyLinearVelocity=v end)
    RunService.RenderStepped:Wait()
    if hrp and hrp.Parent then pcall(function() hrp.AssemblyLinearVelocity=oldL hrp.AssemblyAngularVelocity=oldA end) end
end))

-- Instant Prompt
track(task.spawn(function()
    while true do
        task.wait(0.5)
        if CFG.InstantPrompt and type(fireproximityprompt)=="function" then
            for _,obj in ipairs(WS:GetDescendants()) do if obj:IsA("ProximityPrompt") and obj.Enabled then pcall(fireproximityprompt,obj) end end
        end
    end
end))

-- Auto Farm Coins (full v32)
AutoFarmModule=(function()
    local S={on=false,speed=25,depth=14,rise_xz=4,auto_reset=false,collect_only=false,target=nil,was_down=false,down_ref_y=nil,last_touch=0,noclip_cache={}}
    local TOUCH_COOLDOWN=0.05
    local function can_touch() local now=os.clock() if now-S.last_touch<TOUCH_COOLDOWN then return false end S.last_touch=now return true end
    local up_params=RaycastParams.new() up_params.FilterType=Enum.RaycastFilterType.Exclude up_params.IgnoreWater=true
    local function set_noclip(on)
        local char=LP.Character if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if on then
            if hum then pcall(function() hum.PlatformStand=true end) end
            for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then if S.noclip_cache[p]==nil then S.noclip_cache[p]=true end p.CanCollide=false end end
        else
            if hum then pcall(function() hum.PlatformStand=false end) end
            for p in pairs(S.noclip_cache) do if p and p.Parent then pcall(function() p.CanCollide=true end) end end
            S.noclip_cache={}
        end
    end
    local function return_to_surface()
        local hrp=my_hrp() if not hrp then return end
        local origin=hrp.Position up_params.FilterDescendantsInstances={LP.Character}
        local hit=WS:Raycast(origin,Vector3.new(0,400,0),up_params)
        local y=hit and (hit.Position.Y+5) or (S.down_ref_y and S.down_ref_y+5)
        if not y then return end
        pcall(function() hrp.CFrame=CFrame.new(origin.X,y,origin.Z) hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end)
    end
    local function release() if S.was_down then S.was_down=false return_to_surface() end set_noclip(false) end
    local function coin_available(v) return v and v.Parent and v:IsA("BasePart") and not v:GetAttribute("Collected") and not v:GetAttribute("Delete") end
    local function get_coins()
        local list={}
        for _,v in ipairs(CollectionService:GetTagged("CoinVisual")) do if coin_available(v) then list[#list+1]=v end end
        if #list==0 then
            for _,v in ipairs(WS:GetDescendants()) do
                if v:IsA("BasePart") then
                    local n=string.lower(v.Name)
                    if (n=="coin" or n=="coinvisual" or n:find("coin",1,true)) and coin_available(v) then list[#list+1]=v end
                end
            end
        end
        return list
    end
    local function nearest_coin(from,list)
        local best,bd=nil,math.huge
        for _,v in ipairs(list) do local d=(v.Position-from).Magnitude if d<bd then bd=d best=v end end
        return best
    end
    local function touch_targets(coin)
        local list,seen={},{}
        local function add(p) if p and not seen[p] and p:IsA("BasePart") and p:FindFirstChildOfClass("TouchTransmitter") then seen[p]=true list[#list+1]=p end end
        add(coin)
        for _,v in ipairs(coin:GetChildren()) do add(v) end
        if coin.Parent and coin.Parent:IsA("BasePart") then add(coin.Parent) end
        if #list==0 then list[1]=coin end
        return list
    end
    local function fire_touch(coin)
        if type(firetouchinterest)~="function" then return end
        if not coin or not coin.Parent then return end
        if not can_touch() then return end
        local hrp=my_hrp() if not hrp then return end
        for _,p in ipairs(touch_targets(coin)) do pcall(firetouchinterest,hrp,p,0) pcall(firetouchinterest,hrp,p,1) end
    end
    local function coin_bags_full()
        local pg=LP:FindFirstChild("PlayerGui")
        local main=pg and pg:FindFirstChild("MainGUI")
        local gg=main and main:FindFirstChild("Game")
        local bags=gg and gg:FindFirstChild("CoinBags")
        local container=bags and bags:FindFirstChild("Container")
        if not container then return false end
        local any=false
        for _,v in ipairs(container:GetChildren()) do
            if v:IsA("Frame") and v.Visible then any=true local full=v:FindFirstChild("Full") if not (full and full.Visible) then return false end end
        end
        return any
    end
    local function conflicts() if FlyJoy and FlyJoy.active then return true end if CFG.AutoEscape and escape_safe then return true end return false end
    track(RunService.Stepped:Connect(function(_,dt)
        if not S.on then if S.was_down then S.was_down=false return_to_surface() end set_noclip(false) S.target=nil return end
        if S.collect_only then return end
        if conflicts() then if S.was_down then S.was_down=false return_to_surface() end set_noclip(false) S.target=nil return end
        local hrp=my_hrp() local hum=my_hum()
        if not hrp or not hum or hum.Health<=0 then set_noclip(false) return end
        local list=get_coins() if #list==0 then release() return end
        local target=nearest_coin(hrp.Position,list) if not target then release() return end
        set_noclip(true) S.was_down=true
        local cpos=target.Position S.down_ref_y=cpos.Y
        local xz=flat_dist(hrp.Position,cpos)
        -- Keep the avatar in the same lying-down pose for the entire farm cycle,
        -- including the final approach and coin pickup. Do not switch back to
        -- an upright CFrame when the target is close.
        local targetPos
        if xz<=S.rise_xz then
            targetPos=cpos
        else
            targetPos=Vector3.new(cpos.X,cpos.Y-S.depth,cpos.Z)
        end
        local dir=targetPos-hrp.Position local d=dir.Magnitude
        local np=d>0.1 and (hrp.Position+dir.Unit*math.min(S.speed*dt,d)) or targetPos
        local cf=CFrame.new(np)*CFrame.Angles(-math.pi*0.5,0,0)
        pcall(function()
            if hum then hum.AutoRotate=false end
            hrp.CFrame=cf
            hrp.AssemblyLinearVelocity=Vector3.zero
            hrp.AssemblyAngularVelocity=Vector3.zero
        end)
        fire_touch(target)
        if S.auto_reset and coin_bags_full() then local h=my_hum() if h then pcall(function() h.Health=0 end) end return end
    end))
    track(task.spawn(function()
        while true do
            task.wait(0.05)
            if S.on and S.collect_only then
                local hrp=my_hrp()
                if hrp then for _,c in ipairs(get_coins()) do if (c.Position-hrp.Position).Magnitude<=250 then fire_touch(c) end end end
            end
        end
    end))
    track(LP.CharacterAdded:Connect(function() S.noclip_cache={} S.was_down=false end))
    return {
        set=function(v) S.on=v if not v then release() end end,
        set_speed=function(v) S.speed=tonumber(v) or 25 end,
        set_depth=function(v) S.depth=tonumber(v) or 14 end,
        set_rise_xz=function(v) S.rise_xz=tonumber(v) or 4 end,
        set_collect_only=function(v) S.collect_only=v end,
        set_auto_reset=function(v) S.auto_reset=v end,
        stop=function() S.on=false release() S.target=nil end,
    }
end)()

-- Auto Escape (v32 with platform + avatar indicator)
escape_safe=nil
AutoEscapePlatform=nil AvatarIndicator=nil
local function buildEscapePlatform()
    if AutoEscapePlatform and AutoEscapePlatform.Parent then return end
    local p=Instance.new("Part") p.Name="CH_EscapePlatform" p.Size=Vector3.new(8,1,8) p.Position=Vector3.new(0,1000,0) p.Anchored=true p.CanCollide=true p.Transparency=1 p.Parent=WS AutoEscapePlatform=p
end
local function buildAvatarIndicator()
    if AvatarIndicator and AvatarIndicator.Parent then return end
    local sg=Instance.new("ScreenGui") sg.Name="CH_EscapeIndicator" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=998
    safeParent(sg)
    local frame=Instance.new("Frame",sg) frame.Size=UDim2.new(0,70,0,70) frame.Position=UDim2.new(0,20,0,20) frame.BackgroundColor3=Color3.fromRGB(20,20,20) frame.BorderSizePixel=0 frame.Visible=false
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke",frame) stroke.Color=Color3.fromRGB(255,60,60) stroke.Thickness=2
    local img=Instance.new("ImageLabel",frame) img.Name="Avatar" img.Size=UDim2.new(1,-8,1,-20) img.Position=UDim2.new(0,4,0,4) img.BackgroundTransparency=1 img.Image=""
    Instance.new("UICorner",img).CornerRadius=UDim.new(0,6)
    local lbl=Instance.new("TextLabel",frame) lbl.Name="Label" lbl.Size=UDim2.new(1,0,0,14) lbl.Position=UDim2.new(0,0,1,-16) lbl.BackgroundTransparency=1 lbl.Font=Enum.Font.GothamBold lbl.Text="DANGER" lbl.TextSize=9 lbl.TextColor3=Color3.fromRGB(255,80,80) lbl.TextStrokeTransparency=0
    AvatarIndicator=frame
end
local function setEscapeIndicator(show,murderer)
    if not AvatarIndicator then return end
    AvatarIndicator.Visible=show
    if show and murderer then
        local img=AvatarIndicator:FindFirstChild("Avatar") local lbl=AvatarIndicator:FindFirstChild("Label")
        if img then pcall(function() img.Image=Players:GetUserThumbnailAsync(murderer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end) end
        if lbl then lbl.Text=murderer.Name end
    end
end
track(task.spawn(function()
    while true do
        task.wait(0.15)
        if CFG.AutoEscape then
            if not AutoEscapePlatform or not AutoEscapePlatform.Parent then buildEscapePlatform() end
            if not AvatarIndicator or not AvatarIndicator.Parent then buildAvatarIndicator() end
            local my_role=playerRole(LP)
            if my_role=="innocent" then
                local m=getMurdererFromRound()
                local hrp=my_hrp()
                if m and m.Character and hrp then
                    local mh=m.Character:FindFirstChild("HumanoidRootPart") or m.Character:FindFirstChild("Head")
                    if mh then
                        local d=(mh.Position-hrp.Position).Magnitude
                        if not escape_safe and d<CFG.AutoEscapeDist then
                            escape_safe=hrp.CFrame
                            pcall(function() hrp.CFrame=AutoEscapePlatform.CFrame+Vector3.new(0,3,0) hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end)
                            setEscapeIndicator(true,m)
                        elseif escape_safe then
                            local saved_p=escape_safe.Position
                            if (mh.Position-saved_p).Magnitude>CFG.AutoEscapeReturn then
                                pcall(function() hrp.CFrame=escape_safe hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end)
                                escape_safe=nil setEscapeIndicator(false)
                            end
                        end
                    end
                else
                    if escape_safe and hrp then pcall(function() hrp.CFrame=escape_safe end) escape_safe=nil end
                    setEscapeIndicator(false)
                end
            else
                if escape_safe then escape_safe=nil end
                setEscapeIndicator(false)
            end
        else setEscapeIndicator(false) end
    end
end))

-- Spectate
spectateTarget=nil
track(RunService.RenderStepped:Connect(function()
    local cam=WS.CurrentCamera if not cam then return end
    if not CFG.Spectate then
        if spectateTarget then spectateTarget=nil local myh=my_hum() if myh then cam.CameraSubject=myh end end
        return
    end
    local target=getMurdererFromRound() or getSheriffFromRound()
    if target then spectateTarget=target local th=get_hum(target) if th then cam.CameraSubject=th end end
end))

-- Loop TP
track(RunService.Heartbeat:Connect(function()
    if not CFG.LoopTP then return end
    local target=getMurdererFromRound()
    if target then
        local thrp=get_hrp(target) local hrp=my_hrp()
        if thrp and hrp then hrp.CFrame=thrp.CFrame+Vector3.new(CFG.TPOffsetX,CFG.TPOffsetY,CFG.TPOffsetZ) end
    end
end))

-- ═══════════════════════════════════════════════════════════
-- TARGET BUTTONS · TP Murderer / TP Sheriff / TP Lobby
-- Кнопки можно перетаскивать по экрану. +/- меняют размер всех кнопок.
do
    local targetButtonsGui=nil
    local targetButtonsFrame=nil
    local targetButtonItems={}
    local targetButtonScale=1.0
    local targetButtonPositions={}

    local function getLobbyCFrame()
        local candidates={"LobbySpawn","Lobby","LobbySpawnLocation","SpawnLocation","GameLobby"}
        for _,name in ipairs(candidates) do
            local obj=WS:FindFirstChild(name,true)
            if obj then
                if obj:IsA("BasePart") then return obj.CFrame + Vector3.new(0,3,0) end
                if obj:IsA("Model") then
                    local pp=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true)
                    if pp then return pp.CFrame + Vector3.new(0,3,0) end
                end
            end
        end
        local spawn=WS:FindFirstChildWhichIsA("SpawnLocation",true)
        if spawn then return spawn.CFrame + Vector3.new(0,3,0) end
        return nil
    end

    local function tpToPlayer(target)
        local hrp=my_hrp()
        local thrp=get_hrp(target)
        if hrp and thrp and target~=LP and alive(target) then
            pcall(function() hrp.CFrame=thrp.CFrame+Vector3.new(0,3,0) hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end)
        end
    end

    local function tpToLobby()
        local hrp=my_hrp() local cf=getLobbyCFrame()
        if hrp and cf then pcall(function() hrp.CFrame=cf hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end) end
    end

    local function updateTargetButtonSize()
        for _,item in ipairs(targetButtonItems) do if item.button and item.button.Parent then item.scale.Scale=targetButtonScale end end
        if targetButtonsFrame then targetButtonsFrame.Size=UDim2.new(0,220,0,155) end
    end

    local function makeTargetButton(parent,text,callback,icon,index)
        local b=Instance.new("TextButton",parent)
        b.Size=UDim2.new(0,154,0,34)
        b.Position=targetButtonPositions[index] or UDim2.new(0,0,0,22+(index-1)*39)
        b.BackgroundColor3=Color3.fromRGB(14,15,22) b.BorderSizePixel=0 b.Text="" b.AutoButtonColor=false b.Active=true b.ZIndex=100
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
        local st=Instance.new("UIStroke",b) st.Color=CURRENT_ACCENT st.Thickness=1 st.Transparency=0.45
        local grad=Instance.new("UIGradient",b) grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(24,24,34)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,12,18))})
        local ico=Instance.new("ImageLabel",b) ico.Size=UDim2.new(0,16,0,16) ico.Position=UDim2.new(0,10,0.5,-8) ico.BackgroundTransparency=1 ico.Image=icon or ICONS.target ico.ImageColor3=CURRENT_ACCENT ico.ZIndex=101
        local lbl=noLoc(Instance.new("TextLabel",b)) lbl.Size=UDim2.new(1,-38,1,0) lbl.Position=UDim2.new(0,34,0,0) lbl.BackgroundTransparency=1 lbl.Text=text lbl.TextColor3=Color3.fromRGB(235,235,245) lbl.TextSize=9 lbl.Font=Enum.Font.GothamBold lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=101
        local arrow=noLoc(Instance.new("TextLabel",b)) arrow.Size=UDim2.new(0,12,1,0) arrow.Position=UDim2.new(1,-18,0,0) arrow.BackgroundTransparency=1 arrow.Text=">" arrow.TextColor3=Color3.fromRGB(120,125,145) arrow.TextSize=11 arrow.Font=Enum.Font.GothamBold arrow.ZIndex=101
        local scale=Instance.new("UIScale",b) scale.Scale=targetButtonScale

        local dragging=false local moved=false local dragInput=nil local dragStart=Vector2.zero local startPos=b.Position
        b.InputBegan:Connect(function(input)
            local t=input.UserInputType
            if t~=Enum.UserInputType.MouseButton1 and t~=Enum.UserInputType.Touch then return end
            dragging=true moved=false dragInput=input dragStart=Vector2.new(input.Position.X,input.Position.Y) startPos=b.Position
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            local t=input.UserInputType
            if t~=Enum.UserInputType.MouseMovement and t~=Enum.UserInputType.Touch then return end
            if dragInput and dragInput.UserInputType==Enum.UserInputType.Touch and input~=dragInput then return end
            local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart
            if delta.Magnitude>5 then moved=true end
            b.Position=UDim2.new(0,startPos.X.Offset+delta.X,0,startPos.Y.Offset+delta.Y)
        end)
        UserInputService.InputEnded:Connect(function(input)
            if dragging and (input==dragInput or input.UserInputType==Enum.UserInputType.MouseButton1) then dragging=false dragInput=nil targetButtonPositions[index]=b.Position end
        end)
        b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,29,42)}):Play() TweenService:Create(st,TweenInfo.new(0.12),{Transparency=0.05}):Play() end)
        b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(14,15,22)}):Play() TweenService:Create(st,TweenInfo.new(0.12),{Transparency=0.45}):Play() end)
        b.MouseButton1Click:Connect(function() if moved then return end if menuUnlocked then pcall(callback) end end)
        onAccentChange(function(c) st.Color=c arrow.TextColor3=c ico.ImageColor3=c end)
        targetButtonItems[#targetButtonItems+1]={button=b,scale=scale}
    end

    local function buildTargetButtons()
        if targetButtonsGui and targetButtonsGui.Parent then return end
        targetButtonsGui=Instance.new("ScreenGui") targetButtonsGui.Name="ClumsyTargetButtons" targetButtonsGui.ResetOnSpawn=false targetButtonsGui.IgnoreGuiInset=true targetButtonsGui.DisplayOrder=997 safeParent(targetButtonsGui)
        targetButtonsFrame=Instance.new("Frame",targetButtonsGui) targetButtonsFrame.Position=UDim2.new(0,18,0.52,0) targetButtonsFrame.Size=UDim2.new(0,220,0,155) targetButtonsFrame.BackgroundTransparency=1 targetButtonsFrame.ZIndex=99
        local title=noLoc(Instance.new("TextLabel",targetButtonsFrame)) title.Size=UDim2.new(0,115,0,18) title.BackgroundTransparency=1 title.Text="QUICK TELEPORT" title.TextColor3=Color3.fromRGB(155,160,180) title.TextSize=7 title.Font=Enum.Font.GothamBold title.TextXAlignment=Enum.TextXAlignment.Left title.ZIndex=100
        local minus=Instance.new("TextButton",targetButtonsFrame) minus.Size=UDim2.new(0,22,0,18) minus.Position=UDim2.new(0,118,0,0) minus.Text="−" minus.TextSize=11 minus.Font=Enum.Font.GothamBold minus.TextColor3=Color3.fromRGB(210,215,230) minus.BackgroundColor3=Color3.fromRGB(20,21,30) minus.BorderSizePixel=0 minus.AutoButtonColor=false minus.ZIndex=101 Instance.new("UICorner",minus).CornerRadius=UDim.new(0,5)
        local plus=Instance.new("TextButton",targetButtonsFrame) plus.Size=UDim2.new(0,22,0,18) plus.Position=UDim2.new(0,143,0,0) plus.Text="+" plus.TextSize=11 plus.Font=Enum.Font.GothamBold plus.TextColor3=CURRENT_ACCENT plus.BackgroundColor3=Color3.fromRGB(20,21,30) plus.BorderSizePixel=0 plus.AutoButtonColor=false plus.ZIndex=101 Instance.new("UICorner",plus).CornerRadius=UDim.new(0,5)
        local sizeLabel=noLoc(Instance.new("TextLabel",targetButtonsFrame)) sizeLabel.Size=UDim2.new(0,38,0,18) sizeLabel.Position=UDim2.new(0,168,0,0) sizeLabel.BackgroundTransparency=1 sizeLabel.Text="100%" sizeLabel.TextColor3=Color3.fromRGB(145,150,170) sizeLabel.TextSize=7 sizeLabel.Font=Enum.Font.GothamBold sizeLabel.ZIndex=101
        local function setScale(v) targetButtonScale=math.clamp(v,0.75,1.5) sizeLabel.Text=tostring(math.floor(targetButtonScale*100+0.5)).."%" updateTargetButtonSize() end
        minus.MouseButton1Click:Connect(function() setScale(targetButtonScale-0.1) end) plus.MouseButton1Click:Connect(function() setScale(targetButtonScale+0.1) end)
        makeTargetButton(targetButtonsFrame,"TP Murderer",function() tpToPlayer(getMurdererFromRound()) end,ICONS.sword,1)
        makeTargetButton(targetButtonsFrame,"TP Sheriff",function() tpToPlayer(getSheriffFromRound()) end,ICONS.target,2)
        makeTargetButton(targetButtonsFrame,"TP Lobby",function() tpToLobby() end,ICONS.globe,3)
        updateTargetButtonSize()
    end

    local function destroyTargetButtons() if targetButtonsGui then pcall(function() targetButtonsGui:Destroy() end) end targetButtonsGui=nil targetButtonsFrame=nil table.clear(targetButtonItems) end

    getgenv().ClumsyTargetButtons={
        set=function(v) CFG.TargetButtons=v and true or false if CFG.TargetButtons then buildTargetButtons() else destroyTargetButtons() end end,
        is_on=function() return CFG.TargetButtons end,
        set_size=function(v) targetButtonScale=math.clamp(tonumber(v) or 1,0.75,1.5) updateTargetButtonSize() end,
        get_size=function() return targetButtonScale end,
        tp_murderer=function() tpToPlayer(getMurdererFromRound()) end, tp_sheriff=function() tpToPlayer(getSheriffFromRound()) end, tp_lobby=tpToLobby, unload=destroyTargetButtons,
    }
end

-- TP Tool
tp_tool_ref=nil
function giveTPTool()
    if tp_tool_ref and tp_tool_ref.Parent then return end
    local bp=LP:FindFirstChildOfClass("Backpack") if not bp then return end
    local t=Instance.new("Tool") t.Name="tp" t.RequiresHandle=false t.CanBeDropped=false t.Parent=bp
    t.Activated:Connect(function() local hrp=my_hrp() local m=LP:GetMouse() if hrp and m.Hit then hrp.CFrame=CFrame.new(m.Hit.X,m.Hit.Y+3,m.Hit.Z) end end)
    tp_tool_ref=t
end
function removeTPTool()
    if tp_tool_ref then pcall(function() tp_tool_ref:Destroy() end) tp_tool_ref=nil end
    for _,cont in ipairs({LP:FindFirstChildOfClass("Backpack"),LP.Character}) do if cont then local t=cont:FindFirstChild("tp") if t then t:Destroy() end end end
end

-- Fling Murderer (v32)
function doFling(tp)
    if not tp or not tp.Character then return end
    local hrp,hum=my_hrp(),my_hum()
    if not hrp or not hum then return end
    local thrp=get_hrp(tp) local th=get_hum(tp)
    if not thrp or not th or th.Health<=0 then return end
    local old_pos=hrp.CFrame local old_vel=hrp.AssemblyLinearVelocity local old_ang=hrp.AssemblyAngularVelocity
    local oldFdh=WS.FallenPartsDestroyHeight
    pcall(function() WS.FallenPartsDestroyHeight=0/0 end)
    local bv=Instance.new("BodyVelocity") bv.Parent=hrp bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero
    local se=hum:GetStateEnabled(Enum.HumanoidStateType.Seated)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    local tEnd=tick()+2 local ang=0
    while tick()<tEnd do
        if not hrp.Parent or not thrp.Parent then break end
        ang=ang+120
        hrp.CFrame=CFrame.new(thrp.Position+Vector3.new(0,1.5,0))*CFrame.Angles(math.rad(ang),0,0)
        local c=LP.Character if c then pcall(function() c:SetPrimaryPartCFrame(hrp.CFrame) end) end
        hrp.Velocity=Vector3.new(9e7,9e8,9e7) hrp.RotVelocity=Vector3.new(9e8,9e8,9e8)
        RunService.Heartbeat:Wait()
    end
    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,se)
    if hrp and hrp.Parent then
        hrp.CFrame=old_pos*CFrame.new(0,0.5,0)
        local c=LP.Character if c then pcall(function() c:SetPrimaryPartCFrame(hrp.CFrame) end) end
        hrp.AssemblyLinearVelocity=old_vel or Vector3.zero
        hrp.AssemblyAngularVelocity=old_ang or Vector3.zero
        pcall(function() hum:ChangeState("GettingUp") end)
    end
    pcall(function() WS.FallenPartsDestroyHeight=oldFdh end)
end
flingThread=nil
local function startFlingLoop()
    if flingThread then return end
    flingThread=task.spawn(function()
        while CFG.FlingMurder do
            local m=getMurdererFromRound()
            if m and alive(m) then doFling(m) else task.wait(0.3) end
            task.wait()
        end
        flingThread=nil
    end)
end

-- ═══════════════════════════════════════════════════════════
-- BUILD TABS (sin offsets manuales — UIListLayout maneja)
-- ═══════════════════════════════════════════════════════════
local function addTo(parent,el) el.LayoutOrder=#parent:GetChildren() el.Parent=parent end
local function buildTabs()
    do
        local L,R=tabFrames["Player"].left,tabFrames["Player"].right
        addTo(L,sectionHeader(L,"Movement",ICONS.footprints))
        addTo(L,expandableToggle(L,{title="Speed",default=false,callback=function(v) CFG.Speed=v end,builder=function(c) makeSliderRow(c,"Value",16,300,45,function(v) CFG.SpeedValue=v end) end}))
        addTo(L,expandableToggle(L,{title="Jump Power",default=false,callback=function(v) CFG.JumpPower=v end,builder=function(c) makeSliderRow(c,"Value",50,500,100,function(v) CFG.JumpPowerValue=v end) end}))
        addTo(L,expandableToggle(L,{title="Bhop",default=false,callback=function(v) CFG.Bhop=v end}))
        addTo(L,expandableToggle(L,{title="Infinite Jump",default=false,callback=function(v) CFG.InfJump=v end}))
        addTo(L,expandableToggle(L,{title="Noclip",default=false,callback=function(v) CFG.Noclip=v end}))
        addTo(L,expandableToggle(L,{title="God Mode",default=false,callback=function(v) CFG.GodMode=v end}))
        addTo(R,sectionHeader(R,"View",ICONS.eye))
        addTo(R,expandableToggle(L,{title="Aspect",default=false,callback=function(v) CFG.Aspect=v if getgenv().STRETCH then getgenv().STRETCH.set(v) end if not v then CFG.AspectH=100 CFG.AspectV=100 end end,builder=function(c)
            makeSliderRow(c,"Vertical %",20,118,100,function(v) CFG.AspectV=v if getgenv().STRETCH then getgenv().STRETCH.set_height(v) end end)
            makeSliderRow(c,"Horizontal %",20,125,100,function(v) CFG.AspectH=v if getgenv().STRETCH then getgenv().STRETCH.set_width(v) end end)
        end}))
        addTo(R,expandableToggle(L,{title="FOV",default=false,callback=function(v) CFG.FOV=v end,builder=function(c) makeSliderRow(c,"Value deg",60,130,90,function(v) CFG.FOVValue=v end) end}))
        addTo(L,sectionHeader(L,"Fly",ICONS.wind))
        addTo(L,expandableToggle(L,{title="Fly Joystick",default=false,callback=function(v) CFG.FlyJoystick=v fjSet(v) end,builder=function(c)
            makeSliderRow(c,"Speed",10,300,60,function(v) CFG.FlySpeed=v end)
            makeCycleRow(c,"Noclip",{"Off","On"},2,function(i) CFG.FlyNoclip=(i==2) end)
            makeCycleRow(c,"God",{"Off","On"},2,function(i) CFG.FlyGod=(i==2) end)
        end}))
        addTo(R,sectionHeader(R,"Cosmetics",ICONS.crown))
        addTo(R,expandableToggle(R,{title="Fake Korblox",default=false,callback=function(v) CFG.FakeKorblox=v end}))
        addTo(R,expandableToggle(R,{title="Fake Headless",default=false,callback=function(v) CFG.FakeHeadless=v end}))
        addTo(R,sectionHeader(R,"Target",ICONS.target))
        addTo(R,expandableToggle(R,{title="Target Buttons",default=false,callback=function(v) if getgenv().ClumsyTargetButtons then getgenv().ClumsyTargetButtons.set(v) end end,builder=function(c)
            makeSliderRow(c,"Button Size",75,150,100,function(v)
                if getgenv().ClumsyTargetButtons and getgenv().ClumsyTargetButtons.set_size then getgenv().ClumsyTargetButtons.set_size(v/100) end
            end)
        end}))
        addTo(R,sectionHeader(R,"Server",ICONS.download))
        addTo(R,makeButtonRow(R,"Rejoin",function() pcall(function() TeleportService:Teleport(game.PlaceId,LP) end) end))
        addTo(R,makeButtonRow(R,"Server Hop",function()
            pcall(function()
                local req=http_request or request or (syn and syn.request)
                if not req then return end
                local res=req({Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"})
                local data=HttpService:JSONDecode(res.Body)
                for _,s in ipairs(data.data or {}) do if s.playing<s.maxPlayers and s.id~=game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,LP) break end end
            end)
        end))
    end


-- ═══════════════════════════════════════════════════════════
-- CONFIG PRESETS · Default / Legit / Rage
-- ═══════════════════════════════════════════════════════════
do
    local function cfg_off()
        -- Default = без активных функций. Все boolean-переключатели CFG выключаются.
        for key,value in pairs(CFG) do
            if type(value)=="boolean" then
                CFG[key]=false
            end
        end

        -- Default действительно означает ПОЛНОСТЬЮ ВЫКЛЮЧЕНО.
        -- Раньше здесь AntiFling/AntiCoin принудительно включались, из-за чего
        -- меню показывало Default, но две функции продолжали работать.
        CFG.AntiFling=false
        CFG.AntiCoin=false

        -- Важно: отключение Speed должно вернуть WalkSpeed, а не только CFG.Speed=false.
        -- Иначе после Rage персонаж продолжал физически бегать со скоростью 35.
        pcall(function()
            local h=my_hum()
            if h then h.WalkSpeed=16 end
        end)

        CFG.SpeedValue=45
        CFG.JumpPowerValue=100
        -- Default must fully reset Aspect, including values changed in another config.
        CFG.Aspect=false
        CFG.AspectV=100
        CFG.AspectH=100
        pcall(function() if getgenv().ClumsyAspectReset then getgenv().ClumsyAspectReset() end end)
        CFG.FakeKorblox=false
        CFG.TungTungSahur=false
        CFG.SkyboxName=1
        CFG.FogDistance=500
        CFG.FogColor=1
        CFG.JumpRingColor=1
        CFG.JumpRingSize=5
        CFG.TrailColor=1
        CFG.DeathFxThroughWalls=false

        -- Останавливаем stateful-модули, если они были включены ранее.
        pcall(function() if RoleChams then RoleChams.set_rage_lock(false) RoleChams.set(false) end end)
        pcall(function() if BackTrack then BackTrack.set(false) end end)
        pcall(function() if StarAura then StarAura.set(false) end end)
        pcall(function() if Crosshair then Crosshair.set(false) end end)
        pcall(function() if ChinaHat then ChinaHat.set(false) end end)
        pcall(function() if GunESP then GunESP.set(false) end end)
        pcall(function() if SkeletonESP then SkeletonESP.set(false) end end)
        pcall(function() if KnifeSilent then KnifeSilent.set(false) end end)
        pcall(function() if PistolWallShotModule then PistolWallShotModule.set(false) end end)
        pcall(function() if AutoGunModule then AutoGunModule.set(false) end end)
        pcall(function() if DeathFx then DeathFx.clear() DeathFx.stop() end end)
        pcall(function() stopDust() end)
        pcall(function() if getgenv().SKY then getgenv().SKY.set(false) end end)
        pcall(function() if getgenv().SAHUR then getgenv().SAHUR.set(false) end end)
        pcall(function() if shot_sound then shot_sound:Destroy() shot_sound=nil end end)
        pcall(function() if death_sound then death_sound:Destroy() death_sound=nil end end)
        CFG.ESPClickAction=1
        CFG.ESPDistanceMax=500
        CFG.ShotSoundVolume=3
        CFG.KillSoundVolume=3
        CFG.FovValue=90
        CFG.JumpPowerValue=100
        CFG.SpinbotSpeed=45
        CFG.AutoGunRange=800
        CFG.WallShotRange=200
        CFG.FogDistance=500
        CFG.FogColor=1
        CFG.SnowColor=1
        CFG.TracerColor=1
        CFG.CrosshairColor=1
        CFG.RoleChamsFill=0.5
        CFG.RoleChamsMode=1
        CFG.AuraType=1
        CFG.AuraColor=1
        CFG.BacktrackDelay=0
        CFG.BacktrackColor=1
        pcall(function() Lighting.FogColor=ORIG_LIGHT.FogColor Lighting.FogStart=ORIG_LIGHT.FogStart Lighting.FogEnd=ORIG_LIGHT.FogEnd end)
        for obj,state in pairs(ORIG_ATMOSPHERES) do
            if obj and obj.Parent then pcall(function() obj.Density=state.Density obj.Offset=state.Offset obj.Color=state.Color obj.Decay=state.Decay obj.Glare=state.Glare obj.Haze=state.Haze obj.Enabled=state.Enabled end) end
        end
        pcall(function() if removeTPTool then removeTPTool() end end)
        pcall(function() if getgenv().ClumsyTargetButtons then getgenv().ClumsyTargetButtons.set(false) end end)
        pcall(function() clearTrail() end)
        pcall(function() stopDust() end)

        -- Жёстко останавливаем stateful-функции, у которых есть собственные
        -- RenderStepped/Heartbeat циклы и внутреннее состояние. CFG=false
        -- само по себе для таких модулей недостаточно.
        pcall(function() if AutoFarmModule then AutoFarmModule.set(false); AutoFarmModule.stop() end end)
        pcall(function() if AutoGunModule then AutoGunModule.set(false) end end)
        pcall(function() if PistolWallShotModule then PistolWallShotModule.set(false) end end)
        pcall(function() if KnifeSilent then KnifeSilent.set(false) end end)
        pcall(function() if RoleChams then RoleChams.set_rage_lock(false); RoleChams.set(false) end end)
        pcall(function() if Crosshair then Crosshair.set(false) end end)
        pcall(function() if GunESP then GunESP.set(false) end end)
        pcall(function() if SkeletonESP then SkeletonESP.set(false) end end)
        pcall(function() if BackTrack then BackTrack.set(false) end end)
        pcall(function() if StarAura then StarAura.set(false) end end)
        pcall(function() if ChinaHat then ChinaHat.set(false) end end)
        pcall(function() if DeathFx then DeathFx.clear(); DeathFx.stop() end end)
        pcall(function() if getgenv().SAHUR then getgenv().SAHUR.set(false) end end)
        pcall(function() if getgenv().SKY then getgenv().SKY.set(false) end end)
        pcall(function() if getgenv().STRETCH then getgenv().STRETCH.reset() end end)
        pcall(function() if getgenv().ClumsyAspectReset then getgenv().ClumsyAspectReset() end end)
        pcall(function() if fjSet then fjSet(false) end end)
        pcall(function() if getgenv().ClumsyTargetButtons then getgenv().ClumsyTargetButtons.set(false) end end)
        pcall(function() if removeTPTool then removeTPTool() end end)
        pcall(function() escape_safe=nil; if setEscapeIndicator then setEscapeIndicator(false) end end)
        pcall(function() if AutoEscapePlatform then AutoEscapePlatform:Destroy(); AutoEscapePlatform=nil end end)
        pcall(function() if AvatarIndicator then AvatarIndicator:Destroy(); AvatarIndicator=nil end end)
        pcall(function() spectateTarget=nil; local cam=WS.CurrentCamera; local h=my_hum(); if cam and h then cam.CameraSubject=h end end)
        pcall(function() flingThread=nil end)

        -- Возвращаем локальные свойства персонажа/камеры, которые могли быть
        -- изменены функциями и не откатываются одной переменной CFG.
        pcall(function()
            local h=my_hum()
            if h then
                h.WalkSpeed=16
                h.JumpPower=50
                h.AutoRotate=true
                h.PlatformStand=false
            end
        end)
        pcall(function()
            local c=WS.CurrentCamera
            if c then
                c.FieldOfView=70
            end
        end)
        pcall(function()
            local c=LP.Character
            if c then
                for _,obj in ipairs(c:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.CanCollide=true
                    end
                end
            end
        end)
    end

    local function cfg_legit()
        cfg_off()

        -- Role Chams. В Legit работает как обычная настройка.
        pcall(function() RoleChams.set_rage_lock(false) end)
        pcall(function() if GhostChams then GhostChams.set(false) end end)
        CFG.Ghost=false
        CFG.RoleChams=true
        CFG.RoleChamsFill=0.5
        CFG.RoleChamsMode=1
        pcall(function()
            RoleChams.set_colors(
                Color3.fromRGB(255,140,0),
                Color3.fromRGB(100,180,255),
                Color3.fromRGB(245,245,245)
            )
            RoleChams.set_fill(0.5)
            RoleChams.set_mode(1)
            RoleChams.set(true)
        end)

        -- Fake Korblox.
        CFG.FakeKorblox=true

        -- Red Night Skybox.
        CFG.Skybox=true
        CFG.SkyboxName=2
        pcall(function()
            if getgenv().SKY then
                getgenv().SKY.set_preset("Red Night")
                getgenv().SKY.set(true)
            end
        end)

        -- Красный эффект прыжка.
        CFG.JumpRing=true
        CFG.JumpRingColor=1
        CFG.JumpRingSize=5

        -- Красный Trail.
        CFG.Trails=true
        CFG.TrailColor=1
        pcall(function()
            if createTrail and LP.Character then createTrail(LP.Character) end
        end)

        -- Красные падающие точки.
        CFG.Snowfall=true
        CFG.SnowColor=1
        pcall(function() startDust() end)

        -- Красный близкий туман.
        CFG.Fog=true
        CFG.FogColor=1
        CFG.FogDistance=150
    end

    local function cfg_rage()
        cfg_legit()

        -- Spinbot в Rage: 25 градусов/с.
        CFG.Spinbot=true
        CFG.SpinbotSpeed=25

        -- Быстрый бег 35.
        CFG.Speed=true
        CFG.SpeedValue=35

        -- Role Chams в Rage: принудительно включены и завязаны только на реальные роли раунда.
        pcall(function() RoleChams.set_rage_lock(true) end)
        CFG.RoleChams=true
        CFG.RoleChamsFill=0.5
        CFG.RoleChamsMode=1
        pcall(function()
            RoleChams.set_colors(
                Color3.fromRGB(255,140,0),
                Color3.fromRGB(100,180,255),
                Color3.fromRGB(245,245,245)
            )
            RoleChams.set_fill(0.5)
            RoleChams.set_mode(1)
            RoleChams.set(true)
        end)

        -- Trail: красный, сохраняется после респавна.
        CFG.Trails=true
        CFG.TrailColor=4

        -- Авто-подбор выпавшего пистолета.
        CFG.AutoGun=true
        CFG.AutoGunRange=800
        pcall(function() if AutoGunModule then AutoGunModule.set_range(800) AutoGunModule.set(true) end end)

        -- Wall Shot.
        CFG.WallShot=true
        CFG.WallShotRange=200
        pcall(function() if PistolWallShotModule then PistolWallShotModule.set(true) end end)

        -- Silent Aim.
        CFG.SilentAim=true
        CFG.SilentPredict=true
        CFG.SilentForce=true
        CFG.SilentAutoShoot=false
        CFG.SilentAutoDelay=150

        -- ESP: ники игроков + аватар-иконки.
        -- Нажатие на иконку игрока = Fling.
        CFG.ESP=true
        CFG.ESPBox=false
        CFG.ESPName=true
        CFG.ESPDist=true
        CFG.ESPAvatar=true
        CFG.ESPDistanceMax=2000
        CFG.ESPClickAction=2

        -- Fog: красный, очень близкий.
        CFG.Fog=true
        CFG.FogColor=1
        CFG.FogDistance=50

        -- Shot Sound + Kill Sound.
        CFG.ShotSound=true
        CFG.ShotSoundVolume=3
        CFG.KillSound=true
        CFG.KillSoundVolume=3
        pcall(function() attachShotSound() end)
        pcall(function() attachDeathSound() end)

        -- Траектория выстрела: красная.
        CFG.BulletTracer=true
        CFG.TracerColor=1
        CFG.TracerDuration=4

        -- Трейл: красный.
        CFG.Trails=true
        CFG.TrailColor=1
        pcall(function()
            if clearTrail then clearTrail() end
        end)

        -- Crosshair: красный.
        CFG.Crosshair=true
        CFG.CrosshairColor=1
        pcall(function()
            if Crosshair then
                Crosshair.set_color(1)
                Crosshair.set(true)
            end
        end)

        -- Death Effects: красный цвет.
        CFG.DeathFx=true
        CFG.DeathFxColor=1
        CFG.DeathFxDuration=1.2
        CFG.DeathFxTarget=3 -- Everyone
        CFG.DeathFxClone=true
        CFG.DeathFxParticle=true
        CFG.DeathFxEmitter=true
        CFG.DeathFxThroughWalls=false

        -- Кастомный Tung Tung Sahur.
        CFG.TungTungSahur=true
        pcall(function()
            if getgenv().SAHUR then
                getgenv().SAHUR.set(true)
            end
        end)

        -- Rage visuals: force the requested red settings after every previous preset value.
        CFG.Fog=true
        CFG.FogColor=1
        CFG.FogDistance=50

        CFG.JumpRing=true
        CFG.JumpRingColor=1
        CFG.JumpRingSize=5

        CFG.Snowfall=true
        CFG.SnowColor=1
        pcall(function() startDust() end)

        CFG.Crosshair=true
        CFG.CrosshairColor=1
        pcall(function()
            if Crosshair then
                Crosshair.set_color(1)
                Crosshair.set(true)
            end
        end)

    end

    local function apply_config(name)
        name=tostring(name or "Default")

        -- Config switching must not teleport the character or inherit an old movement force.
        -- Stop active custom flight/body movers before applying the preset.
        pcall(function()
            if CFG.FlyJoystick then CFG.FlyJoystick=false end
        end)

        if name=="Legit" then
            cfg_legit()
        elseif name=="Rage" then
            cfg_rage()
        else
            cfg_off()
            name="Default"
        end

        getgenv().ClumsyActiveConfig=name

        -- Синхронизация визуального состояния переключателей меню с выбранным конфигом.
        local bindings={
            Speed="Speed", JumpPower="Jump Power", Noclip="Noclip", Bhop="Bhop", InfJump="Infinite Jump",
            GodMode="God Mode", FlyJoystick="Fly Joystick", FakeKorblox="Fake Korblox", FakeHeadless="Fake Headless",
            FlingMurder="Fling Murderer", Spectate="Spectate", LoopTP="Loop TP", TPTool="TP Tool", TargetButtons="Target Buttons",
            SilentAim="Silent Aim", KnifeSilent="Knife Silent Throw", KillAura="Kill Aura", WallShot="Wall Shot", Spinbot="Spinbot", AutoGun="Smart Auto Gun",
            ESP="ESP", GunESP="Gun ESP", Skeleton="Skeleton ESP", Crosshair="Crosshair", ChinaHat="China Hat", RoleChams="Role Chams", Ghost="Ghost",
            Backtrack="Backtrack", Aura="Aura", BulletTracer="Bullet Tracer", Snowfall="Snowfall", JumpRing="Jump Ring", DeathFx="Death Effects",
            TungTungSahur="Tung Tung Sahur", Fullbright="Fullbright", TimeChanger="Time Changer", Fog="Fog", Skybox="Skybox",
            ShotSound="Shot Sound", KillSound="Kill Sound", AntiAfk="Anti AFK", AntiFling="Anti Fling", AntiVoid="Anti Void", AntiCoin="Anti Coin",
            AntiTrap="Anti Trap", FakePos="Fake Pos", VelSpoof="Vel Spoof", AutoFarmCoins="Auto Farm Coins", AutoEscape="Auto Escape", InstantPrompt="Instant Prompt",
        }
        for cfgKey,title in pairs(bindings) do
            local val=CFG[cfgKey]
            if type(val)=="boolean" then
                pcall(function() setFeatureToggle(title,val,false) end)
            end
        end

        -- Последний hard-off проход именно для Default: даже если отдельный
        -- модуль/старый callback успел изменить своё состояние, все CFG-флаги
        -- и связанные переключатели остаются выключенными.
        if name=="Default" then
            for key,value in pairs(CFG) do
                if type(value)=="boolean" then CFG[key]=false end
            end
            pcall(function() setFeatureToggle("Anti Fling",false,false) end)
            pcall(function() setFeatureToggle("Anti Coin",false,false) end)
            pcall(function() if AutoFarmModule then AutoFarmModule.set(false); AutoFarmModule.stop() end end)
            pcall(function() if AutoGunModule then AutoGunModule.set(false) end end)
            pcall(function() if PistolWallShotModule then PistolWallShotModule.set(false) end end)
            pcall(function() if KnifeSilent then KnifeSilent.set(false) end end)
            pcall(function() if RoleChams then RoleChams.set_rage_lock(false); RoleChams.set(false) end end)
            pcall(function() if Crosshair then Crosshair.set(false) end end)
            pcall(function() if DeathFx then DeathFx.clear(); DeathFx.stop() end end)
            pcall(function() if getgenv().SAHUR then getgenv().SAHUR.set(false) end end)
            pcall(function() if getgenv().SKY then getgenv().SKY.set(false) end end)
            pcall(function() if fjSet then fjSet(false) end end)
            pcall(function() if removeTPTool then removeTPTool() end end)
            pcall(function() if getgenv().ClumsyTargetButtons then getgenv().ClumsyTargetButtons.set(false) end end)
            pcall(function() escape_safe=nil; if setEscapeIndicator then setEscapeIndicator(false) end end)
            pcall(function() if AutoEscapePlatform then AutoEscapePlatform:Destroy(); AutoEscapePlatform=nil end end)
            pcall(function() if AvatarIndicator then AvatarIndicator:Destroy(); AvatarIndicator=nil end end)
            pcall(function() clearTrail() end)
            pcall(function() stopDust() end)
            pcall(function() local h=my_hum(); if h then h.WalkSpeed=16; h.JumpPower=50; h.AutoRotate=true; h.PlatformStand=false end end)
            pcall(function() local cam=WS.CurrentCamera; local h=my_hum(); if cam and h then cam.FieldOfView=70; cam.CameraSubject=h end end)
        end

        -- Re-apply module-backed Rage functions after the UI state is synchronized.
        -- This restores the old behavior where selecting Rage immediately activates
        -- the modules instead of only changing their CFG flags.
        if name=="Rage" then
            pcall(function() if PistolWallShotModule then PistolWallShotModule.set(true) end end)
            pcall(function() if AutoGunModule then AutoGunModule.set_range(CFG.AutoGunRange or 800) AutoGunModule.set(true) end end)
            pcall(function() if RoleChams then RoleChams.set_rage_lock(true) RoleChams.set_fill(CFG.RoleChamsFill or 0.5) RoleChams.set_mode(1) RoleChams.set(true) end end)
            pcall(function() if Crosshair then Crosshair.set_color(CFG.CrosshairColor or 1) Crosshair.set(true) end end)
            pcall(function() if getgenv().SAHUR then getgenv().SAHUR.set(true) end end)
            pcall(function() attachShotSound() end)
            pcall(function() attachDeathSound() end)
        end
        print("[CONFIG] applied: "..name)
    end

    local _clumsy_apply_config=apply_config
    apply_config=function(name)
        _clumsy_apply_config(name)
        -- Никаких скрытых авто-включений после Default.
        -- Состояние меню всегда соответствует реальному состоянию CFG.
        if tostring(name or "Default")=="Default" then
            CFG.AntiFling=false
            CFG.AntiCoin=false
            pcall(function() setFeatureToggle("Anti Fling",false,false) end)
            pcall(function() setFeatureToggle("Anti Coin",false,false) end)
        end
    end
    getgenv().ClumsyApplyConfig=apply_config
    getgenv().ClumsyConfigPresets={
        Default=function() apply_config("Default") end,
        Legit=function() apply_config("Legit") end,
        Rage=function() apply_config("Rage") end,
        apply=apply_config,
    }
end

    do
        local L,R=tabFrames["Combat"].left,tabFrames["Combat"].right
        addTo(L,sectionHeader(L,"Silent Aim",ICONS.target))
        addTo(L,expandableToggle(L,{title="Silent Aim",default=false,callback=function(v) CFG.SilentAim=v end,builder=function(c)
            makeCycleRow(c,"Prediction",{"On","Off"},1,function(i) CFG.SilentPredict=(i==1) end)
            makeCycleRow(c,"Force Shoot",{"On","Off"},1,function(i) CFG.SilentForce=(i==1) end)
            makeCycleRow(c,"Auto Shoot",{"Off","On"},1,function(i) CFG.SilentAutoShoot=(i==2) end)
            makeSliderRow(c,"Auto Delay ms",50,1000,150,function(v) CFG.SilentAutoDelay=v end)
        end}))
        addTo(L,sectionHeader(L,"Knife Silent",ICONS.sword))
        addTo(L,expandableToggle(L,{title="Knife Silent Throw",default=false,callback=function(v) CFG.KnifeSilent=v KnifeSilent.set(v) end,builder=function(c)
            makeCycleRow(c,"Predict",{"On","Off"},1,function(i) KnifeSilent.set_predict(i==1) end)
            makeCycleRow(c,"Insta Kill",{"Off","On"},1,function(i) KnifeSilent.set_insta(i==2) end)
            makeSliderRow(c,"Range st",50,800,400,function(v) KnifeSilent.set_range(v) end)
            makeSliderRow(c,"Lead %",0,320,100,function(v) KnifeSilent.set_leadScale(v/100) end)
            makeSliderRow(c,"Air %",0,120,35,function(v) KnifeSilent.set_airScale(v/100) end)
            makeSliderRow(c,"Offset ms",-80,220,0,function(v) KnifeSilent.set_leadAdd(v/1000) end)
            makeSliderRow(c,"Speed",40,400,96,function(v) KnifeSilent.set_throwSpeed(v) end)
            makeSliderRow(c,"Impact st",2,40,12,function(v) KnifeSilent.set_impactRadius(v) end)
        end}))
        addTo(L,sectionHeader(L,"Kill Aura",ICONS.zap))
        addTo(L,expandableToggle(L,{title="Kill Aura",default=false,callback=function(v) CFG.KillAura=v end,builder=function(c)
            makeSliderRow(c,"Range",5,100,30,function(v) CFG.KillAuraRange=v end)
            makeSliderRow(c,"Delay ms",10,500,50,function(v) CFG.KillAuraDelay=v end)
        end}))
        addTo(R,sectionHeader(R,"Wall Shot",ICONS.rocket))
        addTo(R,expandableToggle(L,{title="Wall Shot",default=false,callback=function(v) PistolWallShotModule.set(v) end,builder=function(c) makeSliderRow(c,"Range",100,600,200,function(v) CFG.WallShotRange=v end) end}))
        addTo(R,sectionHeader(R,"Spinbot",ICONS.ghost))
        addTo(R,expandableToggle(L,{title="Spinbot",default=false,callback=function(v) CFG.Spinbot=v if not v then local h=my_hum() if h then h.AutoRotate=true end end end,builder=function(c) makeSliderRow(c,"Speed deg",10,200,45,function(v) CFG.SpinbotSpeed=v end) end}))
        addTo(R,sectionHeader(R,"Auto Gun",ICONS.bot))
        addTo(R,expandableToggle(R,{title="Smart Auto Gun",default=false,callback=function(v) CFG.AutoGun=v AutoGunModule.set(v) end,builder=function(c) makeSliderRow(c,"Range",100,2000,800,function(v) CFG.AutoGunRange=v AutoGunModule.set_range(v) end) end}))
        addTo(R,sectionHeader(R,"Target",ICONS.crosshair))
        addTo(R,expandableToggle(R,{title="Fling Murderer",default=false,callback=function(v) CFG.FlingMurder=v if v then startFlingLoop() end end}))
        addTo(R,expandableToggle(R,{title="Spectate",default=false,callback=function(v) CFG.Spectate=v end}))
        addTo(R,expandableToggle(R,{title="Loop TP",default=false,callback=function(v) CFG.LoopTP=v end,builder=function(c)
            makeSliderRow(c,"X",0,10,0,function(v) CFG.TPOffsetX=v end)
            makeSliderRow(c,"Y",0,10,0,function(v) CFG.TPOffsetY=v end)
            makeSliderRow(c,"Z",0,10,0,function(v) CFG.TPOffsetZ=v end)
        end}))
        addTo(R,expandableToggle(R,{title="TP Tool",default=false,callback=function(v) CFG.TPTool=v if v then giveTPTool() else removeTPTool() end end}))
    end

    do
        local L,R=tabFrames["Visuals"].left,tabFrames["Visuals"].right
        addTo(L,sectionHeader(L,"ESP",ICONS.eye))
        addTo(L,expandableToggle(L,{title="ESP",default=false,callback=function(v) CFG.ESP=v end,builder=function(c)
            makeCycleRow(c,"Name",{"Off","On"},2,function(i) CFG.ESPName=(i==2) end)
            makeCycleRow(c,"Avatar",{"Off","On"},2,function(i) CFG.ESPAvatar=(i==2) end)
            makeCycleRow(c,"Distance",{"Off","On"},2,function(i) CFG.ESPDist=(i==2) end)
            makeCycleRow(c,"Click Action",ESP_CLICK_MODES,1,function(i) CFG.ESPClickAction=i end)
            makeSliderRow(c,"Max Dist",50,2000,500,function(v) CFG.ESPDistanceMax=v end)
        end}))
        addTo(L,sectionHeader(L,"Gun ESP",ICONS.rocket))
        addTo(L,expandableToggle(L,{title="Gun ESP",default=false,callback=function(v) GunESP.set(v) end,builder=function(c)
            makeCycleRow(c,"Highlight",{"Off","On"},2,function(i) GunESP.set_hl(i==2) end)
            makeCycleRow(c,"Text",{"Off","On"},2,function(i) GunESP.set_txt(i==2) end)
            makeCycleRow(c,"Color",TRACER_NAMES,1,function(i) GunESP.set_col(i) end)
        end}))
        addTo(L,sectionHeader(L,"Skeleton",ICONS.zap))
        addTo(L,expandableToggle(L,{title="Skeleton ESP",default=false,callback=function(v) SkeletonESP.set(v) end,builder=function(c)
            makeCycleRow(c,"Mode",SKELETON_MODES,1,function(i) SkeletonESP.set_mode(i) end)
            makeCycleRow(c,"Color",COLOR_NAMES,1,function(i) SkeletonESP.set_color(i) end)
        end}))
        addTo(L,sectionHeader(L,"Crosshair",ICONS.crosshair))
        addTo(L,expandableToggle(L,{title="Crosshair",default=false,callback=function(v) Crosshair.set(v) end,builder=function(c)
            makeCycleRow(c,"Mode",XHAIR_MODES,1,function(i) Crosshair.set_mode(i) end)
            makeSliderRow(c,"Size",4,30,12,function(v) Crosshair.set_size(v) end)
            makeSliderRow(c,"Gap",0,20,4,function(v) Crosshair.set_gap(v) end)
            makeSliderRow(c,"Thickness",1,6,1,function(v) Crosshair.set_thickness(v) end)
            makeSliderRow(c,"Rot Speed",0,360,90,function(v) Crosshair.set_rot(v) end)
            makeCycleRow(c,"Color",COLOR_NAMES,1,function(i) Crosshair.set_color(i) end)
            makeCycleRow(c,"Outline",{"Off","On"},2,function(i) Crosshair.set_outline_on(i==2) end)
        end}))
        addTo(R,sectionHeader(R,"China Hat",ICONS.crown))
        addTo(R,expandableToggle(L,{title="China Hat",default=false,callback=function(v) ChinaHat.set(v) end,builder=function(c)
            makeCycleRow(c,"Color",COLOR_NAMES,1,function(i) ChinaHat.set_color(i) end)
            makeSliderRow(c,"Height",3,30,6,function(v) ChinaHat.set_height(v/10) end)
            makeSliderRow(c,"Radius",5,30,10,function(v) ChinaHat.set_radius(v/10) end)
        end}))
        addTo(R,sectionHeader(R,"Role Chams",ICONS.shield))
        addTo(R,expandableToggle(R,{title="Role Chams",default=false,callback=function(v) RoleChams.set(v) end,builder=function(c)
            makeCycleRow(c,"Mode",{"Role-based","Single"},1,function(i) RoleChams.set_mode(i) end)
            makeSliderRow(c,"Fill",0,100,50,function(v) RoleChams.set_fill(v/100) end)
        end}))
        addTo(R,expandableToggle(R,{title="Ghost",default=false,callback=function(v) GhostChams.set(v) end,builder=function(c)
            makeCycleRow(c,"Color",COLOR_NAMES,1,function(i) GhostChams.set_color(i) end)
            makeSliderRow(c,"Transparency",0,95,55,function(v) GhostChams.set_transparency(v/100) end)
        end}))
        addTo(R,sectionHeader(R,"Backtrack",ICONS.ghost))
        addTo(R,expandableToggle(R,{title="Backtrack",default=false,callback=function(v) BackTrack.set(v) end,builder=function(c)
            makeSliderRow(c,"Delay ms",0,400,0,function(v) BackTrack.set_delay(v) end)
            makeCycleRow(c,"Color",COLOR_NAMES,1,function(i) BackTrack.set_color(i) end)
        end}))
        addTo(R,sectionHeader(R,"Aura",ICONS.sparkles))
        addTo(R,expandableToggle(R,{title="Aura",default=false,callback=function(v) StarAura.set(v) end,builder=function(c)
            makeCycleRow(c,"Type",AURA_TYPES,1,function(i) StarAura.set_type_by_idx(i) end)
            makeCycleRow(c,"Color",COLOR_NAMES,1,function(i) StarAura.set_color(COLOR_VALUES[i]) end)
        end}))
        addTo(R,sectionHeader(R,"Effects",ICONS.zap))
        addTo(R,expandableToggle(R,{title="Bullet Tracer",default=false,callback=function(v) CFG.BulletTracer=v end,builder=function(c)
            makeCycleRow(c,"Color",TRACER_NAMES,1,function(i) CFG.TracerColor=i end)
            makeSliderRow(c,"Duration",1,8,4,function(v) CFG.TracerDuration=v end)
        end}))
        addTo(R,expandableToggle(R,{title="Snowfall",default=false,callback=function(v) CFG.Snowfall=v if v then startDust() else stopDust() end end,builder=function(c) makeCycleRow(c,"Color",SNOW_NAMES,1,function(i) CFG.SnowColor=i end) end}))
        addTo(R,expandableToggle(R,{title="Jump Ring",default=false,callback=function(v) CFG.JumpRing=v end,builder=function(c)
            makeCycleRow(c,"Color",COLOR_NAMES,1,function(i) CFG.JumpRingColor=i end)
            makeSliderRow(c,"Size",1,12,5,function(v) CFG.JumpRingSize=v end)
        end}))
        addTo(R,expandableToggle(R,{title="Death Effects",default=false,callback=function(v) CFG.DeathFx=v if not v then DeathFx.clear() DeathFx.stop() end end,builder=function(c)
            makeCycleRow(c,"Target",DEATHFX_TARGETS,1,function(i) CFG.DeathFxTarget=i end)
            makeCycleRow(c,"Color",DEATHFX_NAMES,1,function(i) CFG.DeathFxColor=i end)
            makeCycleRow(c,"Visibility",{"Through walls","Normal"},2,function(i)
                local v=(i==1)
                CFG.DeathFxThroughWalls=v
                pcall(function() DeathFx.set_through_walls(v) end)
            end)
            makeSliderRow(c,"Duration",0.4,3,1.2,function(v) CFG.DeathFxDuration=v end)
        end}))
    end

    do
        -- ═══════════════════════════════════════════════════════════
        -- TUNG TUNG SAHUR · integrated visual model
        -- Replaced the previous Model Changer implementation.
        -- ═══════════════════════════════════════════════════════════

        local MODEL_ID = "138151705692565"
        local FORCE_START = false

        local SAHUR_ENABLED = false
        local SAHUR_SCALE = math.clamp((tonumber(CFG.TungTungSahurSize) or 100)/100,0.5,3.0)
        local sahur_model_cache = {}
        local sahur_model_inst = nil
        local sahur_update_conn = nil
        local sahur_char_conn = nil
        local sahur_base_scale = 1
        local sahur_camera = nil
        local sahur_base_fov = nil
        local sahur_pivot_fix = nil
        local sahur_y_off = 0

        local function sahur_char()
            return LP.Character
        end

        local function sahur_hrp()
            local c = sahur_char()
            return c and c:FindFirstChild("HumanoidRootPart")
        end

        local function sahur_hum()
            local c = sahur_char()
            return c and c:FindFirstChildOfClass("Humanoid")
        end

        local function sahur_scrub(inst)
            for _,d in ipairs(inst:GetDescendants()) do
                if d:IsA("LuaSourceContainer")
                    or d:IsA("Humanoid")
                    or d:IsA("JointInstance")
                    or d:IsA("Constraint")
                    or d:IsA("BodyMover")
                    or d:IsA("Sound") then
                    pcall(function()
                        d:Destroy()
                    end)
                end
            end
        end

        local function sahur_load_template(id)
            id=tostring(id or ""):gsub("%D","")
            if #id<5 then
                return nil
            end

            local cached=sahur_model_cache[id]
            if cached and cached.Parent then
                return cached
            end

            local ok,objs=pcall(game.GetObjects,game,"rbxassetid://"..id)
            if not ok or type(objs)~="table" or not objs[1] then
                warn("[SAHUR] load fail: "..id)
                return nil
            end

            local root=objs[1]

            if not root:IsA("Model") then
                local holder=Instance.new("Model")
                holder.Name="SahurTemplate"
                root.Parent=holder
                root=holder
            end

            sahur_scrub(root)

            local has_part=false

            for _,d in ipairs(root:GetDescendants()) do
                if d:IsA("BasePart") then
                    has_part=true
                    d.Anchored=true
                    d.CanCollide=false
                    d.CanQuery=false
                    d.CanTouch=false
                    d.Massless=true
                    d.CastShadow=false
                    d.Locked=true
                    d.Transparency=0
                end
            end

            if not has_part then
                pcall(function()
                    root:Destroy()
                end)
                return nil
            end

            sahur_model_cache[id]=root
            return root
        end

        local function sahur_hide_original(char)
            if not char then
                return
            end

            for _,d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") and d.Name~="HumanoidRootPart" then
                    d.LocalTransparencyModifier=1
                elseif d:IsA("Decal") then
                    d.LocalTransparencyModifier=1
                end
            end
        end

        local function sahur_show_original(char)
            if not char then
                return
            end

            for _,d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") or d:IsA("Decal") then
                    d.LocalTransparencyModifier=0
                end
            end
        end

        -- Sahur больше не меняет FieldOfView/камеру.
        -- Размер модели изменяется независимо, поэтому обычная камера игры
        -- сохраняется при любом значении слайдера.
        local function sahur_capture_camera()
            return WS.CurrentCamera
        end

        local function sahur_apply_camera()
            return
        end

        local function sahur_restore_camera()
            sahur_camera=nil
            sahur_base_fov=nil
        end

        local function sahur_update_alignment()
            if not sahur_model_inst or not sahur_model_inst.Parent then return end
            local c=sahur_char()
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            if not hrp then return end

            local ok,box,size=pcall(function()
                return sahur_model_inst:GetBoundingBox()
            end)
            if not ok or not box or not size then return end

            sahur_pivot_fix=(sahur_model_inst:GetPivot():Inverse()*box):Inverse()
            sahur_y_off=size.Y*0.5-hrp.Size.Y*0.5-(hum and hum.HipHeight or 0)
        end

        local function sahur_rescale()
            if not sahur_model_inst or not sahur_model_inst.Parent then return end
            local target=math.max(0.05,sahur_base_scale*SAHUR_SCALE)
            pcall(function() sahur_model_inst:ScaleTo(target) end)
            -- После ScaleTo заново рассчитываем нижнюю точку модели.
            -- Это убирает зависание/плавание Sahur в воздухе при уменьшении.
            sahur_update_alignment()
            sahur_apply_camera()
        end

        local function sahur_clear()
            if sahur_update_conn then
                pcall(function()
                    sahur_update_conn:Disconnect()
                end)
                sahur_update_conn=nil
            end

            if sahur_model_inst then
                pcall(function()
                    sahur_model_inst:Destroy()
                end)
                sahur_model_inst=nil
            end

            sahur_restore_camera()
            sahur_pivot_fix=nil
            sahur_y_off=0

            local c=sahur_char()
            if c then
                sahur_show_original(c)
            end
        end

        local function sahur_apply()
            sahur_clear()

            if not SAHUR_ENABLED then
                return
            end

            local char=sahur_char()
            if not char then
                return
            end

            local hrp=char:FindFirstChild("HumanoidRootPart")
            local hum=char:FindFirstChildOfClass("Humanoid")

            if not hrp then
                return
            end

            local tpl=sahur_load_template(MODEL_ID)
            if not tpl then
                return
            end

            local clone=tpl:Clone()

            local _,char_size=char:GetBoundingBox()
            local _,raw_size=clone:GetBoundingBox()

            if raw_size.Y>0.05 and char_size.Y>0.05 then
                sahur_base_scale=char_size.Y/raw_size.Y
            else
                sahur_base_scale=1
            end

            pcall(function()
                clone:ScaleTo(math.max(0.05,sahur_base_scale*SAHUR_SCALE))
            end)

            sahur_capture_camera()
            sahur_apply_camera()

            local box,size=clone:GetBoundingBox()
            sahur_pivot_fix=(clone:GetPivot():Inverse()*box):Inverse()
            sahur_y_off=size.Y*0.5-hrp.Size.Y*0.5-(hum and hum.HipHeight or 0)

            clone.Name="SahurModel"
            clone.Parent=WS
            sahur_model_inst=clone

            sahur_hide_original(char)

            local last_cf=nil

            sahur_update_conn=RunService.RenderStepped:Connect(function()
                if not SAHUR_ENABLED then
                    sahur_clear()
                    return
                end

                if not sahur_model_inst or not sahur_model_inst.Parent then
                    return
                end

                local c=LP.Character
                local root=c and c:FindFirstChild("HumanoidRootPart")

                if not root then
                    return
                end

                sahur_apply_camera()
                sahur_hide_original(c)

                local cf=root.CFrame

                if last_cf==cf then
                    return
                end

                last_cf=cf

                local look,pos=cf.LookVector,cf.Position

                pcall(function()
                    sahur_model_inst:PivotTo(
                        CFrame.new(pos.X,pos.Y+sahur_y_off,pos.Z)
                        *CFrame.fromEulerAnglesYXZ(
                            0,
                            math.atan2(-look.X,-look.Z),
                            0
                        )
                        *sahur_pivot_fix
                    )
                end)
            end)

            print("[SAHUR] модель применена · Tung Tung Sahur")
        end

        if sahur_char_conn then
            pcall(function()
                sahur_char_conn:Disconnect()
            end)
            sahur_char_conn=nil
        end

        sahur_char_conn=LP.CharacterAdded:Connect(function()
            task.wait(1)

            if SAHUR_ENABLED then
                sahur_apply()
            end
        end)

        getgenv().SAHUR={
            set=function(v)
                SAHUR_ENABLED=v and true or false

                if SAHUR_ENABLED then
                    sahur_apply()
                else
                    sahur_clear()
                end
            end,

            set_id=function(id)
                MODEL_ID=tostring(id or ""):gsub("%D","")

                if SAHUR_ENABLED then
                    sahur_apply()
                end
            end,

            set_size=function(v)
                local pct=math.clamp(tonumber(v) or 100,50,300)
                CFG.TungTungSahurSize=pct
                SAHUR_SCALE=pct/100
                if SAHUR_ENABLED then
                    if sahur_model_inst and sahur_model_inst.Parent then
                        sahur_rescale()
                    else
                        task.spawn(sahur_apply)
                    end
                end
            end,

            get_size=function()
                return SAHUR_SCALE*100
            end,

            is_on=function()
                return SAHUR_ENABLED
            end,

            clear=sahur_clear,
        }

        getgenv().SAHUR_UNLOAD=function()
            SAHUR_ENABLED=false
            sahur_clear()

            if sahur_char_conn then
                pcall(function()
                    sahur_char_conn:Disconnect()
                end)
                sahur_char_conn=nil
            end

            for id,tpl in pairs(sahur_model_cache) do
                pcall(function()
                    tpl:Destroy()
                end)
                sahur_model_cache[id]=nil
            end

            getgenv().SAHUR=nil
            getgenv().SAHUR_UNLOAD=nil
        end

        if FORCE_START then
            task.spawn(function()
                SAHUR_ENABLED=true

                local tries=0

                while not sahur_hrp() and tries<30 do
                    task.wait(0.2)
                    tries=tries+1
                end

                if sahur_hrp() then
                    sahur_apply()
                else
                    print("[SAHUR] ожидание персонажа...")
                end
            end)
        end

        -- ═══════════════════════════════════════════════════════════
        -- VISUALS · MODEL
        -- Один пункт управления для нового рабочего Sahur-модуля.
        -- ═══════════════════════════════════════════════════════════

        local L=tabFrames["Visuals"].left
        addTo(L,sectionHeader(L,"Model",ICONS.crown))

        addTo(L,expandableToggle(L,{
            title="Tung Tung Sahur",
            default=CFG.TungTungSahur,
            callback=function(v)
                CFG.TungTungSahur=v and true or false
                SAHUR_ENABLED=v and true or false

                if SAHUR_ENABLED then
                    task.spawn(sahur_apply)
                    Notify_Toast.push(
                        "Sahur ON",
                        COLOR.Success
                    )
                else
                    sahur_clear()
                    Notify_Toast.push(
                        "Sahur OFF",
                        COLOR.TextDim
                    )
                end
            end,
            builder=function(c)
                makeSliderRow(c,"Sahur Size",50,300,CFG.TungTungSahurSize or 100,function(v)
                    if getgenv().SAHUR and getgenv().SAHUR.set_size then
                        getgenv().SAHUR.set_size(v)
                    else
                        CFG.TungTungSahurSize=v
                    end
                end)
            end
        }))
    end
    do
        local L,R=tabFrames["World"].left,tabFrames["World"].right
        addTo(L,sectionHeader(L,"Lighting",ICONS.sun))
        addTo(L,expandableToggle(L,{title="Fullbright",default=false,callback=function(v) CFG.Fullbright=v end}))
        addTo(L,expandableToggle(L,{title="Time Changer",default=false,callback=function(v) CFG.TimeChanger=v end,builder=function(c) makeSliderRow(c,"Hour",0,24,12,function(v) CFG.TimeValue=v end) end}))
        addTo(L,expandableToggle(L,{title="Fog",default=false,callback=function(v)
            CFG.Fog=v
            if v then
                Lighting.FogColor=FOG_COLORS[CFG.FogColor] or FOG_COLORS[1]
                local d=math.max(50,tonumber(CFG.FogDistance) or 500)
                Lighting.FogStart=math.max(25,d*0.35)
                Lighting.FogEnd=math.max(Lighting.FogStart+50,d)
            else
                Lighting.FogColor=ORIG_LIGHT.FogColor
                Lighting.FogStart=ORIG_LIGHT.FogStart
                Lighting.FogEnd=ORIG_LIGHT.FogEnd
                for obj,state in pairs(ORIG_ATMOSPHERES) do
                    if obj and obj.Parent then pcall(function() obj.Density=state.Density obj.Offset=state.Offset obj.Color=state.Color obj.Decay=state.Decay obj.Glare=state.Glare obj.Haze=state.Haze obj.Enabled=state.Enabled end) end
                end
            end
        end,builder=function(c)
            makeSliderRow(c,"Distance",50,2000,500,function(v) CFG.FogDistance=v end)
            makeCycleRow(c,"Color",FOG_NAMES,1,function(i) CFG.FogColor=i end)
        end}))
        addTo(L,expandableToggle(L,{title="Skybox",default=false,callback=function(v) CFG.Skybox=v if getgenv().SKY then getgenv().SKY.set(v) end end,builder=function(c) makeCycleRow(c,"Preset",SKYBOX_PRESETS,1,function(i) CFG.SkyboxName=i if getgenv().SKY then getgenv().SKY.set_preset(SKYBOX_PRESETS[i]) end end) end}))
        addTo(L,sectionHeader(L,"Sounds",ICONS.zap))
        addTo(L,expandableToggle(L,{title="Shot Sound",default=false,callback=function(v) CFG.ShotSound=v if v then attachShotSound() else if shot_sound then shot_sound:Destroy() shot_sound=nil end end end,builder=function(c) makeSliderRow(c,"Volume",1,5,3,function(v) CFG.ShotSoundVolume=v end) end}))
        addTo(L,expandableToggle(L,{title="Kill Sound",default=false,callback=function(v) CFG.KillSound=v if v then attachDeathSound() else if death_sound then death_sound:Destroy() death_sound=nil end end end,builder=function(c) makeSliderRow(c,"Volume",1,5,3,function(v) CFG.KillSoundVolume=v end) end}))
        addTo(R,sectionHeader(R,"Anti",ICONS.shield))
        addTo(R,expandableToggle(R,{title="Anti AFK",default=true,callback=function(v) CFG.AntiAfk=v end}))
        addTo(R,expandableToggle(R,{title="Anti Fling",default=true,callback=function(v) CFG.AntiFling=v and true or false end}))
        addTo(R,expandableToggle(R,{title="Anti Void",default=false,callback=function(v) CFG.AntiVoid=v end,builder=function(c) makeSliderRow(c,"Y Limit",-300,0,-80,function(v) CFG.AntiVoidY=v end) end}))
        addTo(R,expandableToggle(R,{title="Anti Coin",default=true,callback=function(v) CFG.AntiCoin=v and true or false end}))
        addTo(R,expandableToggle(R,{title="Anti Trap",default=false,callback=function(v) CFG.AntiTrap=v end}))
        addTo(R,sectionHeader(R,"Spoof",ICONS.ghost))
        addTo(R,expandableToggle(R,{title="Fake Pos",default=false,callback=function(v) CFG.FakePos=v end,builder=function(c) makeSliderRow(c,"Range x1e9",1,9,9,function(v) CFG.FakePosRange=v end) end}))
        addTo(R,expandableToggle(R,{title="Vel Spoof",default=false,callback=function(v) CFG.VelSpoof=v end,builder=function(c) makeCycleRow(c,"Preset",{"low","high","y-high","limit","zero"},1,function(i) CFG.VelSpoofMode=i end) end}))
        addTo(L,sectionHeader(L,"Auto",ICONS.bot))
        addTo(L,expandableToggle(R,{title="Auto Farm Coins",default=false,callback=function(v) CFG.AutoFarmCoins=v AutoFarmModule.set(v) end,builder=function(c)
            makeSliderRow(c,"Speed",10,80,25,function(v) CFG.AutoFarmSpeed=v AutoFarmModule.set_speed(v) end)
            makeSliderRow(c,"Depth",6,40,14,function(v) CFG.AutoFarmDepth=v AutoFarmModule.set_depth(v) end)
            makeSliderRow(c,"Rise XZ",1,15,4,function(v) CFG.AutoFarmRiseXZ=v AutoFarmModule.set_rise_xz(v) end)
            makeCycleRow(c,"Collect Only",{"Off","On"},1,function(i) AutoFarmModule.set_collect_only(i==2) end)
            makeCycleRow(c,"Auto Reset",{"Off","On"},1,function(i) AutoFarmModule.set_auto_reset(i==2) end)
        end}))
        addTo(L,expandableToggle(R,{title="Auto Escape",default=false,callback=function(v) CFG.AutoEscape=v end,builder=function(c)
            makeSliderRow(c,"Escape Dist",5,50,15,function(v) CFG.AutoEscapeDist=v end)
            makeSliderRow(c,"Return Dist",10,100,25,function(v) CFG.AutoEscapeReturn=v end)
        end}))
        addTo(L,expandableToggle(R,{title="Instant Prompt",default=false,callback=function(v) CFG.InstantPrompt=v end}))
    end

    do
        local L,R=tabFrames["Settings"].left,tabFrames["Settings"].right
        addTo(L,sectionHeader(L,"UI",ICONS.settings))
        addTo(L,makeButtonRow(L,"Hide Menu",function() MainFrame.Visible=false end))
        addTo(L,makeButtonRow(L,"Delete Cheat",function()
            -- Сначала полностью выключаем все функции и возвращаем стандартные значения.
            pcall(function() cfg_off() end)
            CFG.AntiFling=false
            CFG.AntiCoin=false
            CFG.Fog=false
            CFG.Fullbright=false
            CFG.TimeChanger=false
            CFG.Skybox=false

            -- Жёстко выключаем функции, которые держат состояние/объекты отдельно от CFG.
            CFG.Spinbot=false
            CFG.Trails=false
            pcall(function()
                local h=my_hum()
                if h then h.AutoRotate=true end
            end)
            pcall(function() clearTrail() end)
            pcall(function()
                for _,obj in ipairs((LP.Character and LP.Character:GetDescendants()) or {}) do
                    if obj.Name=="ClumsyTrailAttachment0" or obj.Name=="ClumsyTrailAttachment1" or obj.Name=="ClumsyActiveTrail" then
                        obj:Destroy()
                    end
                end
            end)
            pcall(function() if removeTPTool then removeTPTool() end end)
            pcall(function() clearTrail() end)
            pcall(function() stopDust() end)
            pcall(function() if AutoFarmModule then AutoFarmModule.set(false) end end)
            pcall(function() if getgenv().SAHUR then getgenv().SAHUR.set(false) end end)
            pcall(function() if getgenv().SKY then getgenv().SKY.set(false) end end)

            -- Полностью убрать GUI чита, включая отдельный водяной знак и все вспомогательные окна.
            pcall(function() if getgenv().ClumsyTargetButtons then getgenv().ClumsyTargetButtons.set(false) end end)
            pcall(function() if getgenv().ClumsyPreviewSetVisible then getgenv().ClumsyPreviewSetVisible(false) end end)
            pcall(function() if getgenv().ClumsyAspectReset then getgenv().ClumsyAspectReset() end end)

            -- Остановить все отслеживаемые соединения, чтобы удалённый GUI не создавался заново.
            pcall(function()
                for i=#Conns,1,-1 do
                    local c=Conns[i]
                    if c and c.Disconnect then pcall(function() c:Disconnect() end) end
                    Conns[i]=nil
                end
            end)

            -- Удаляем GUI из PlayerGui, CoreGui и executor gethui.
            local containers={}
            pcall(function() containers[#containers+1]=PlayerGui end)
            pcall(function() containers[#containers+1]=game:GetService("CoreGui") end)
            pcall(function() if type(gethui)=="function" then local h=gethui() if h then containers[#containers+1]=h end end end)

            local names={
                "ClumsyScript_UI", "ClumsyScript_WM", "ClumsyScript_BTN",
                "ClumsyCharacterPreview", "ClumsyTargetButtons", "ClumsyFlyJoystick",
                "ClumsyLoading_UI", "ClumsyKey_UI", "CH_EscapeIndicator"
            }
            for _,parent in ipairs(containers) do
                if parent then
                    for _,name in ipairs(names) do
                        pcall(function()
                            local gui=parent:FindFirstChild(name)
                            if gui then gui:Destroy() end
                        end)
                    end
                end
            end

            -- Прямые ссылки на GUI тоже уничтожаем: это гарантирует удаление watermark.
            pcall(function() if WmGui and WmGui.Parent then WmGui:Destroy() end end)
            pcall(function() if LoadGui and LoadGui.Parent then LoadGui:Destroy() end end)
            pcall(function() if KeyGui and KeyGui.Parent then KeyGui:Destroy() end end)
            pcall(function() if ButtonGui and ButtonGui.Parent then ButtonGui:Destroy() end end)
            pcall(function() if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end end)

            -- Убираем публичные ссылки, чтобы повторный вызов не оставлял хвостов.
            pcall(function() getgenv().ClumsyTargetButtons=nil end)
            pcall(function() getgenv().ClumsyPreviewSetVisible=nil end)
            pcall(function() getgenv().ClumsyAspectReset=nil end)
            pcall(function() getgenv().ClumsyFeatureControls=nil end)
        end))
        -- Accent Color selector removed: UI is permanently black-and-white.
    end
end
buildTabs()

do
    local settingsLeft = tabFrames["Settings"] and tabFrames["Settings"].left
    if settingsLeft then
        addTo(settingsLeft, sectionHeader(settingsLeft, "Character Preview", ICONS.eye))
        addTo(settingsLeft, expandableToggle(settingsLeft, {
            title = "Preview Card",
            default = false,
            callback = function(v)
                if getgenv().ClumsyPreviewSetVisible then
                    pcall(getgenv().ClumsyPreviewSetVisible, v and true or false)
                end
            end
        }))
        addTo(settingsLeft, makeButtonRow(settingsLeft, "Refresh Preview", function()
            if getgenv().ClumsyPreviewRefresh then pcall(getgenv().ClumsyPreviewRefresh) end
        end))
    end
end

getgenv().ClumsyActiveConfig="Default"

local function selectTab(name)
    if not menuUnlocked then return end
    for n,data in pairs(tabButtons) do
        local sel=(n==name)
        data.btn.BackgroundColor3=sel and CURRENT_ACCENT or COLOR.Sidebar
        data.btn.BackgroundTransparency=sel and 0.72 or 0.18
        data.stroke.Transparency=sel and 0.18 or 1
        data.icon.ImageColor3=sel and CURRENT_ACCENT or COLOR.IconDim
        data.title.TextColor3=sel and Color3.new(1,1,1) or COLOR.TextDim
    end
    for n,tf in pairs(tabFrames) do tf.scroll.Visible=(n==name) end
end

onAccentChange(function(c)
    for _,data in pairs(tabButtons) do
        if data and data.btn and data.btn.BackgroundTransparency == 0.72 then
            data.btn.BackgroundColor3=c
        end
        if data and data.stroke then data.stroke.Color=c end
    end
end)

for i,t in ipairs(TABS) do
    local btn=Instance.new("TextButton",Sidebar)
    btn.Size=UDim2.new(1,-14,0,24) btn.Position=UDim2.new(0,7,0,54+(i-1)*25)
    btn.BackgroundColor3=COLOR.Sidebar btn.Text=""
    btn.AutoButtonColor=false btn.AutoLocalize=false btn.BorderSizePixel=0 btn.ZIndex=3
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
    btn.BackgroundTransparency=0.18
    local tabStroke=Instance.new("UIStroke",btn)
    tabStroke.Color=CURRENT_ACCENT
    tabStroke.Thickness=1
    tabStroke.Transparency=1
    local icon=Instance.new("ImageLabel",btn)
    icon.Size=UDim2.new(0,13,0,13) icon.Position=UDim2.new(0,9,0.5,-6.5)
    icon.BackgroundTransparency=1 icon.Image=t.icon
    icon.ImageColor3=COLOR.IconDim icon.ScaleType=Enum.ScaleType.Fit icon.ZIndex=4
    local title=noLoc(Instance.new("TextLabel",btn))
    title.Size=UDim2.new(1,-32,1,0) title.Position=UDim2.new(0,28,0,0)
    title.BackgroundTransparency=1 title.Text=t.name
    title.TextColor3=COLOR.TextDim title.TextSize=9
    title.Font=Enum.Font.GothamMedium title.TextXAlignment=Enum.TextXAlignment.Left title.ZIndex=4
    tabButtons[t.name]={btn=btn,icon=icon,title=title,stroke=tabStroke}
    btn.MouseButton1Click:Connect(function() selectTab(t.name) end)
end

-- ═══════════════════════════════════════════════════════════
-- STANDALONE KEY GATE
-- Small independent authorization window.
-- The cheat menu stays hidden until the key is accepted.
-- ═══════════════════════════════════════════════════════════
local KeyGui=Instance.new("ScreenGui")
KeyGui.Name="ClumsyKey_UI"
KeyGui.ResetOnSpawn=false
KeyGui.IgnoreGuiInset=true
KeyGui.DisplayOrder=2000
safeParent(KeyGui)

local KeyWindow=Instance.new("Frame",KeyGui)
KeyWindow.Name="KeyWindow"
KeyWindow.Size=UDim2.new(0,300,0,190)
KeyWindow.AnchorPoint=Vector2.new(0.5,0.5)
KeyWindow.Position=UDim2.new(0.5,0,0.5,0)
KeyWindow.BackgroundColor3=Color3.fromRGB(12,12,16)
KeyWindow.BackgroundTransparency=0.08
KeyWindow.BorderSizePixel=0
KeyWindow.Active=true
KeyWindow.ZIndex=10
Instance.new("UICorner",KeyWindow).CornerRadius=UDim.new(0,10)

local KeyWindowStroke=Instance.new("UIStroke",KeyWindow)
KeyWindowStroke.Color=CURRENT_ACCENT
KeyWindowStroke.Thickness=1
KeyWindowStroke.Transparency=0.35

local KLogo=Instance.new("ImageLabel",KeyWindow)
KLogo.Size=UDim2.new(0,28,0,28)
KLogo.Position=UDim2.new(0.5,-14,0,24)
KLogo.BackgroundTransparency=1
KLogo.Image=ICONS.key
KLogo.ImageColor3=CURRENT_ACCENT
KLogo.ZIndex=12

local KTitle=noLoc(Instance.new("TextLabel",KeyWindow))
KTitle.Size=UDim2.new(1,-20,0,18)
KTitle.Position=UDim2.new(0,10,0,57)
KTitle.BackgroundTransparency=1
KTitle.Text="ClumsyScript"
KTitle.TextColor3=Color3.new(1,1,1)
KTitle.TextSize=14
KTitle.Font=Enum.Font.GothamBold
KTitle.ZIndex=12

local KSub=noLoc(Instance.new("TextLabel",KeyWindow))
KSub.Size=UDim2.new(1,-20,0,11)
KSub.Position=UDim2.new(0,10,0,76)
KSub.BackgroundTransparency=1
KSub.Text="KEY AUTHENTICATION"
KSub.TextColor3=COLOR.TextDim
KSub.TextSize=7
KSub.Font=Enum.Font.GothamMedium
KSub.ZIndex=12

local KInputFrame=Instance.new("Frame",KeyWindow)
KInputFrame.Size=UDim2.new(0,240,0,30)
KInputFrame.Position=UDim2.new(0.5,-120,0,96)
KInputFrame.BackgroundColor3=Color3.fromRGB(20,20,27)
KInputFrame.BorderSizePixel=0
KInputFrame.ZIndex=12
Instance.new("UICorner",KInputFrame).CornerRadius=UDim.new(0,6)

local KInputStroke=Instance.new("UIStroke",KInputFrame)
KInputStroke.Color=Color3.fromRGB(55,55,70)
KInputStroke.Thickness=1

local KLock=Instance.new("ImageLabel",KInputFrame)
KLock.Size=UDim2.new(0,12,0,12)
KLock.Position=UDim2.new(0,9,0.5,-6)
KLock.BackgroundTransparency=1
KLock.Image=ICONS.lock
KLock.ImageColor3=CURRENT_ACCENT
KLock.ZIndex=13

local KBox=noLoc(Instance.new("TextBox",KInputFrame))
KBox.Size=UDim2.new(1,-30,1,0)
KBox.Position=UDim2.new(0,27,0,0)
KBox.BackgroundTransparency=1
KBox.Text=""
KBox.PlaceholderText="Enter key..."
KBox.PlaceholderColor3=Color3.fromRGB(85,85,100)
KBox.TextColor3=Color3.new(1,1,1)
KBox.TextSize=9
KBox.Font=Enum.Font.GothamMedium
KBox.TextXAlignment=Enum.TextXAlignment.Left
KBox.ClearTextOnFocus=false
KBox.ZIndex=13

local KSubmit=Instance.new("TextButton",KeyWindow)
KSubmit.Size=UDim2.new(0,240,0,28)
KSubmit.Position=UDim2.new(0.5,-120,0,132)
KSubmit.BackgroundColor3=CURRENT_ACCENT
KSubmit.Text="UNLOCK"
KSubmit.TextColor3=Color3.new(0,0,0)
KSubmit.TextSize=9
KSubmit.Font=Enum.Font.GothamBold
KSubmit.AutoButtonColor=false
KSubmit.BorderSizePixel=0
KSubmit.ZIndex=12
Instance.new("UICorner",KSubmit).CornerRadius=UDim.new(0,6)

local KStatus=noLoc(Instance.new("TextLabel",KeyWindow))
KStatus.Size=UDim2.new(1,-20,0,12)
KStatus.Position=UDim2.new(0,10,0,162)
KStatus.BackgroundTransparency=1
KStatus.Text=""
KStatus.TextColor3=COLOR.Error
KStatus.TextSize=7
KStatus.Font=Enum.Font.GothamBold
KStatus.ZIndex=12

-- Make the small key window draggable.
do
    local dragging=false
    local dragInput=nil
    local dragStart=Vector2.zero
    local startPos=KeyWindow.Position

    KeyWindow.InputBegan:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1
            and input.UserInputType~=Enum.UserInputType.Touch then return end
        if KBox:IsFocused() then return end
        dragging=true
        dragInput=input
        dragStart=Vector2.new(input.Position.X,input.Position.Y)
        startPos=KeyWindow.Position
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType~=Enum.UserInputType.MouseMovement
            and input.UserInputType~=Enum.UserInputType.Touch then return end
        if dragInput and dragInput.UserInputType==Enum.UserInputType.Touch and input~=dragInput then return end
        local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart
        KeyWindow.Position=UDim2.new(
            startPos.X.Scale,startPos.X.Offset+delta.X,
            startPos.Y.Scale,startPos.Y.Offset+delta.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input==dragInput or input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
            dragInput=nil
        end
    end)
end

local function kShowError(msg)
    KStatus.Text=msg
    KStatus.TextColor3=COLOR.Error
    KInputStroke.Color=COLOR.Error
    task.delay(1.8,function()
        if KStatus and KStatus.Parent then
            KStatus.Text=""
            KInputStroke.Color=Color3.fromRGB(55,55,70)
        end
    end)
end

-- Fullscreen minimal loading screen: blurred background + spinning circle + percentage.
local LoadGui=Instance.new("ScreenGui")
LoadGui.Name="ClumsyLoading_UI"
LoadGui.ResetOnSpawn=false
LoadGui.IgnoreGuiInset=true
LoadGui.DisplayOrder=1999
LoadGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
safeParent(LoadGui)

local LoadOverlay=Instance.new("Frame",LoadGui)
LoadOverlay.Size=UDim2.new(1,0,1,0)
LoadOverlay.Position=UDim2.new(0,0,0,0)
LoadOverlay.BackgroundColor3=Color3.fromRGB(7,7,10)
LoadOverlay.BackgroundTransparency=0.28
LoadOverlay.BorderSizePixel=0
LoadOverlay.Visible=false
LoadOverlay.ZIndex=20

local LoadCircle=Instance.new("Frame",LoadOverlay)
LoadCircle.Name="LoadingCircle"
LoadCircle.Size=UDim2.new(0,64,0,64)
LoadCircle.AnchorPoint=Vector2.new(0.5,0.5)
LoadCircle.Position=UDim2.new(0.5,0,0.5,-12)
LoadCircle.BackgroundTransparency=1
LoadCircle.BorderSizePixel=0
LoadCircle.ZIndex=25

local LoadDots={}
for i=1,8 do
    local dot=Instance.new("Frame",LoadCircle)
    dot.Name="Dot"..i
    dot.Size=UDim2.new(0,7,0,7)
    dot.AnchorPoint=Vector2.new(0.5,0.5)
    local a=((i-1)/8)*math.pi*2
    dot.Position=UDim2.new(0.5,math.cos(a)*23,0.5,math.sin(a)*23)
    dot.BackgroundColor3=CURRENT_ACCENT
    dot.BackgroundTransparency=0.15
    dot.BorderSizePixel=0
    dot.ZIndex=26
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    LoadDots[i]=dot
end

local LoadPct=noLoc(Instance.new("TextLabel",LoadOverlay))
LoadPct.Size=UDim2.new(0,90,0,20)
LoadPct.AnchorPoint=Vector2.new(0.5,0)
LoadPct.Position=UDim2.new(0.5,0,0.5,25)
LoadPct.BackgroundTransparency=1
LoadPct.Text="0%"
LoadPct.TextColor3=CURRENT_ACCENT
LoadPct.TextSize=10
LoadPct.Font=Enum.Font.GothamBold
LoadPct.ZIndex=25

local LoadStatus=noLoc(Instance.new("TextLabel",LoadOverlay))
LoadStatus.Name="LoadingStatus"
LoadStatus.Size=UDim2.new(0,360,0,34)
LoadStatus.AnchorPoint=Vector2.new(0.5,0)
LoadStatus.Position=UDim2.new(0.5,0,0.5,50)
LoadStatus.BackgroundTransparency=1
LoadStatus.Text="ЗАПУСК РАТКИ"
LoadStatus.TextColor3=Color3.fromRGB(245,245,248)
LoadStatus.TextSize=18
LoadStatus.Font=Enum.Font.GothamBold
LoadStatus.TextXAlignment=Enum.TextXAlignment.Center
LoadStatus.ZIndex=25

local LoadBlur=Instance.new("BlurEffect")
LoadBlur.Name="ClumsyLoadingBlur"
LoadBlur.Size=24
LoadBlur.Enabled=false
LoadBlur.Parent=Lighting

local loadAnim=true
local loadAnimThread=task.spawn(function()
    local phase=0
    while loadAnim and LoadGui.Parent do
        local dt=RunService.RenderStepped:Wait()
        phase=(phase+dt*7.5)%(math.pi*2)
        for i,dot in ipairs(LoadDots) do
            local wave=0.5+0.5*math.cos(phase-(i-1)*(math.pi*2/8))
            dot.BackgroundTransparency=0.08+wave*0.62
            local scale=0.75+wave*0.45
            dot.Size=UDim2.new(0,7*scale,0,7*scale)
        end
                local statusPulse=0.5+0.5*math.sin(phase*0.75)
        LoadStatus.TextTransparency=0.02+statusPulse*0.10
    end
end)

local loginInProgress=false
local function setLoadProgress(v,status)
    v=math.clamp(v,0,1)
    LoadPct.Text=math.floor(v*100).."%"
    if status and status~="" then LoadStatus.Text=status end
end

local function tryLogin()
    if menuUnlocked or loginInProgress then return end

    local key=KBox.Text:gsub("%s+","")
    if key=="" then
        kShowError("Please enter a key!")
        return
    end
    if not VALID_KEYS[key] then
        kShowError("Invalid key!")
        return
    end

    loginInProgress=true
    KStatus.Text="Key accepted"
    KStatus.TextColor3=COLOR.Success
    KInputStroke.Color=COLOR.Success
    KSubmit.Text="VERIFYING..."

    task.wait(0.2)

    -- Move completely away from the key window.
    KeyGui.Enabled=false
    LoadOverlay.Visible=true
    LoadBlur.Enabled=true

    setLoadProgress(0.12,"ЗАПУСК РАТКИ")
    task.wait(0.22)
    setLoadProgress(0.34,"ЗАПУСК РАТКИ")
    task.wait(0.28)
    setLoadProgress(0.58,"ЗАПУСК РАТКИ")
    task.wait(0.28)
    setLoadProgress(0.82,"ЗАПУСК РАТКИ")
    task.wait(0.28)
    setLoadProgress(1,"ЗАПУСК РАТКИ")
    task.wait(0.3)

    menuUnlocked=true
    ButtonGui.Enabled=true
    MainFrame.Visible=true
    Container.Visible=true
    selectTab("Player")

    loadAnim=false
    LoadBlur.Enabled=false
    pcall(function() LoadBlur:Destroy() end)
    LoadGui:Destroy()
    KeyGui:Destroy()
    loginInProgress=false
end

KSubmit.MouseButton1Click:Connect(tryLogin)
KBox.FocusLost:Connect(function(enter)
    if enter then tryLogin() end
end)

-- Keep standalone key/loading accents synchronized with the fixed monochrome theme.
onAccentChange(function(c)
    if KeyWindowStroke then KeyWindowStroke.Color=c end
    if KLogo then KLogo.ImageColor3=c end
    if KLock then KLock.ImageColor3=c end
    if KSubmit then KSubmit.BackgroundColor3=c end
    for _,dot in ipairs(LoadDots or {}) do if dot and dot.Parent then dot.BackgroundColor3=c end end
    if LoadPct then LoadPct.TextColor3=c end
    if ConfigArrow then ConfigArrow.TextColor3=c end
    if AccStroke then AccStroke.Color=c end
    if WmLogo then WmLogo.ImageColor3=c end
    if WmFps then WmFps.TextColor3=c end
    if WmPlayers then WmPlayers.TextColor3=c end
    if WmFpsIcon then WmFpsIcon.ImageColor3=c end
    if WmPlayersIcon then WmPlayersIcon.ImageColor3=c end
end)

-- ═══════════════════════════════════════════════════════════
-- MAIN MENU HOTKEY / FLOATING BUTTON
-- ═══════════════════════════════════════════════════════════
AccordionButton.Activated:Connect(function()
    if btnMoved then
        btnMoved=false
        return
    end
    if not menuUnlocked then return end
    MainFrame.Visible=not MainFrame.Visible
end)
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.RightShift and menuUnlocked then MainFrame.Visible=not MainFrame.Visible end
end)

print("[Clumsy] v12.4 loaded · Watermark FPS/Players icons · key: @clumsy_cfg")-- ═══════════════════════════════════════════════════════════
-- CHARACTER PREVIEW v13.7 · isolated / animation-safe
-- ═══════════════════════════════════════════════════════════
-- Превью полностью отделено от основной логики меню.
-- Любая ошибка внутри этого блока не должна останавливать скрипт.
do
    local okPreview, previewError = pcall(function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        if not LocalPlayer then return end

        local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
        if not PlayerGui then return end

        local PreviewGui = Instance.new("ScreenGui")
        PreviewGui.Name = "ClumsyCharacterPreview"
        PreviewGui.ResetOnSpawn = false
        PreviewGui.IgnoreGuiInset = true
        PreviewGui.DisplayOrder = 994
        PreviewGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        PreviewGui.Enabled = false
        PreviewGui.Parent = PlayerGui

        local PreviewFrame = Instance.new("Frame")
        PreviewFrame.Name = "PreviewFrame"
        PreviewFrame.Size = UDim2.fromOffset(200, 300)
        PreviewFrame.BackgroundColor3 = Color3.fromRGB(18,18,20)
        PreviewFrame.BackgroundTransparency = 0.08
        PreviewFrame.BorderSizePixel = 0
        PreviewFrame.Visible = true
        PreviewFrame.Parent = PreviewGui

        -- Очень прозрачная перемычка между меню и превью.
        -- Она двигается только вместе с меню, без отдельного цикла.
        local PreviewConnector = Instance.new("Frame")
        PreviewConnector.Name = "PreviewConnector"
        PreviewConnector.BackgroundColor3 = Color3.fromRGB(18,18,20)
        PreviewConnector.BackgroundTransparency = 0.965
        PreviewConnector.BorderSizePixel = 0
        PreviewConnector.ZIndex = 0
        PreviewConnector.Visible = false
        PreviewConnector.Parent = PreviewGui

        -- Единый сверхпрозрачный фон вокруг связки "меню + просмотр".
        -- Он не ограничивает положение превью и просто визуально соединяет блоки.
        local PreviewDock = Instance.new("Frame")
        PreviewDock.Name = "PreviewDock"
        PreviewDock.BackgroundColor3 = Color3.fromRGB(18,18,20)
        PreviewDock.BackgroundTransparency = 0.975
        PreviewDock.BorderSizePixel = 0
        PreviewDock.ZIndex = 0
        PreviewDock.Visible = false
        PreviewDock.Parent = PreviewGui

        local DockCorner = Instance.new("UICorner")
        DockCorner.CornerRadius = UDim.new(0, 14)
        DockCorner.Parent = PreviewDock

        local DockStroke = Instance.new("UIStroke")
        DockStroke.Thickness = 1
        DockStroke.Transparency = 0.975
        DockStroke.Color = CURRENT_ACCENT
        DockStroke.Parent = PreviewDock

        local ConnectorStroke = Instance.new("UIStroke")
        ConnectorStroke.Thickness = 1
        ConnectorStroke.Transparency = 0.96
        ConnectorStroke.Color = CURRENT_ACCENT
        ConnectorStroke.Parent = PreviewConnector

        local PreviewCorner = Instance.new("UICorner")
        PreviewCorner.CornerRadius = UDim.new(0, 10)
        PreviewCorner.Parent = PreviewFrame

        local PreviewStroke = Instance.new("UIStroke")
        PreviewStroke.Thickness = 1.2
        PreviewStroke.Transparency = 0.08
        PreviewStroke.Color = CURRENT_ACCENT
        PreviewStroke.Parent = PreviewFrame

        local PreviewHeader = Instance.new("TextLabel")
        PreviewHeader.Name = "Header"
        PreviewHeader.BackgroundTransparency = 1
        PreviewHeader.Position = UDim2.fromOffset(10, 5)
        PreviewHeader.Size = UDim2.new(1, -20, 0, 24)
        PreviewHeader.Font = Enum.Font.GothamBold
        PreviewHeader.Text = "CHARACTER"
        PreviewHeader.TextSize = 12
        PreviewHeader.TextColor3 = Color3.fromRGB(235,235,240)
        PreviewHeader.TextXAlignment = Enum.TextXAlignment.Left
        PreviewHeader.Parent = PreviewFrame

        local PreviewViewport = Instance.new("ViewportFrame")
        PreviewViewport.Name = "CharacterViewport"
        PreviewViewport.BackgroundColor3 = Color3.fromRGB(10,10,12)
        PreviewViewport.BackgroundTransparency = 0.16
        PreviewViewport.BorderSizePixel = 0
        PreviewViewport.Position = UDim2.fromOffset(7, 33)
        PreviewViewport.Size = UDim2.new(1, -14, 1, -40)
        PreviewViewport.Ambient = Color3.fromRGB(190,190,190)
        PreviewViewport.LightColor = Color3.fromRGB(255,255,255)
        PreviewViewport.LightDirection = Vector3.new(-1,-1,-1)
        PreviewViewport.Parent = PreviewFrame

        local ViewCorner = Instance.new("UICorner")
        ViewCorner.CornerRadius = UDim.new(0, 8)
        ViewCorner.Parent = PreviewViewport

        local PreviewWorld = Instance.new("WorldModel")
        PreviewWorld.Name = "CharacterWorld"
        PreviewWorld.Parent = PreviewViewport

        local PreviewCamera = Instance.new("Camera")
        PreviewCamera.Name = "PreviewCamera"
        PreviewCamera.FieldOfView = 38
        PreviewCamera.Parent = PreviewViewport
        PreviewViewport.CurrentCamera = PreviewCamera

        local PreviewName = Instance.new("TextLabel")
        PreviewName.Name = "PlayerName"
        PreviewName.BackgroundColor3 = Color3.fromRGB(0,0,0)
        PreviewName.BackgroundTransparency = 0.35
        PreviewName.AnchorPoint = Vector2.new(0.5, 1)
        PreviewName.Position = UDim2.new(0.5, 0, 1, -7)
        PreviewName.Size = UDim2.new(1, -24, 0, 22)
        PreviewName.Font = Enum.Font.GothamSemibold
        PreviewName.TextSize = 11
        PreviewName.TextColor3 = Color3.fromRGB(245,245,245)
        PreviewName.TextTruncate = Enum.TextTruncate.AtEnd
        PreviewName.Text = LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name
        PreviewName.ZIndex = 5
        PreviewName.Parent = PreviewFrame

        local NameCorner = Instance.new("UICorner")
        NameCorner.CornerRadius = UDim.new(0, 6)
        NameCorner.Parent = PreviewName

        local PreviewModel = nil
        local PreviewHighlight = nil
        local PreviewFreezeConnection = nil
        local PreviewFrozen = {}
        local PreviewPivot = nil
        local PreviewBuildBusy = false

        local function clearPreviewModel()
            if PreviewFreezeConnection then
                pcall(function() PreviewFreezeConnection:Disconnect() end)
                PreviewFreezeConnection = nil
            end
            PreviewFrozen = {}
            PreviewPivot = nil
            PreviewHighlight = nil
            if PreviewModel then
                pcall(function() PreviewModel:Destroy() end)
                PreviewModel = nil
            end
            for _,child in ipairs(PreviewWorld:GetChildren()) do
                pcall(function() child:Destroy() end)
            end
        end

        local function stripUnsafeObjects(model)
            for _,d in ipairs(model:GetDescendants()) do
                -- Не даём клону ничего запускать/проигрывать.
                if d:IsA("Script")
                    or d:IsA("LocalScript")
                    or d:IsA("ModuleScript")
                    or d:IsA("Humanoid")
                    or d:IsA("Animator")
                    or d:IsA("AnimationController")
                    or d:IsA("Animation")
                    or d:IsA("Sound") then
                    pcall(function() d:Destroy() end)
                elseif d.Name == "FaceControls"
                    or d.Name == "FacialAnimation"
                    or d.Name == "ExpressionController" then
                    pcall(function() d:Destroy() end)
                elseif d:IsA("AlignPosition")
                    or d:IsA("AlignOrientation")
                    or d:IsA("LinearVelocity")
                    or d:IsA("AngularVelocity")
                    or d:IsA("LinearForce")
                    or d:IsA("VectorForce")
                    or d:IsA("Torque")
                    or d:IsA("RopeConstraint")
                    or d:IsA("SpringConstraint")
                    or d:IsA("PrismaticConstraint")
                    or d:IsA("HingeConstraint")
                    or d:IsA("RodConstraint")
                    or d:IsA("BallSocketConstraint")
                    or d:IsA("CylindricalConstraint") then
                    pcall(function() d:Destroy() end)
                elseif d:IsA("BasePart") then
                    d.Anchored = true
                    d.CanCollide = false
                    d.CanTouch = false
                    d.CanQuery = false
                    d.CastShadow = false
                end
            end
        end

        local function resetPose(model)
            -- Сбрасываем текущую игровую позу/эмоцию.
            -- Удалённых Animator/Animation недостаточно: Motor6D.Transform может
            -- уже содержать смещение от проигранной эмоции.
            for _,d in ipairs(model:GetDescendants()) do
                if d:IsA("Motor6D") then
                    pcall(function() d.Transform = CFrame.identity end)
                elseif d:IsA("BasePart") then
                    pcall(function() d.AssemblyLinearVelocity = Vector3.zero end)
                    pcall(function() d.AssemblyAngularVelocity = Vector3.zero end)
                end
            end
        end

        local function centerModel(model)
            local cf, size = model:GetBoundingBox()
            -- Геометрический центр модели совпадает с центром viewport.
            -- Ступни больше не прижимаются к Y=0, поэтому персонаж не выглядит выше карточки.
            local offset = -cf.Position
            pcall(function()
                model:PivotTo(model:GetPivot() + offset)
            end)
            return model:GetBoundingBox()
        end

        local function fitCamera(model)
            local cf, size = model:GetBoundingBox()
            local maxSize = math.max(size.X, size.Y, size.Z)
            if maxSize < 0.1 then maxSize = 4 end

            -- Точка прицеливания находится в геометрическом центре тела,
            -- а не в позиции головы/лица, поэтому персонаж остаётся по центру.
            local center = cf.Position
            local target = center + Vector3.new(0, size.Y * 0.02, 0)
            local distance = math.max(5, maxSize * 2.55)
            local cameraPos = target + Vector3.new(0, size.Y * 0.01, distance)
            PreviewCamera.CFrame = CFrame.lookAt(cameraPos, target)
            PreviewCamera.Focus = CFrame.new(target)
        end

        local function buildPreview()
            if PreviewBuildBusy then return end
            PreviewBuildBusy = true

            local success, err = pcall(function()
                local character = LocalPlayer.Character
                if not character or not character.Parent then return end

                clearPreviewModel()

                local oldArchivable = character.Archivable
                character.Archivable = true
                local cloneOk, clone = pcall(function()
                    return character:Clone()
                end)
                character.Archivable = oldArchivable

                if not cloneOk or not clone then return end
                if not clone:IsA("Model") then
                    pcall(function() clone:Destroy() end)
                    return
                end

                clone.Name = "CharacterPreviewModel"
                stripUnsafeObjects(clone)

                -- Питомцы/компаньоны в превью не показываем.
                local petNames = {
                    pet = true, pets = true, companion = true, companions = true,
                    follower = true, followers = true, familiar = true, mascot = true,
                    animal = true, summon = true, summoned = true
                }
                for _,obj in ipairs(clone:GetDescendants()) do
                    local n = string.lower(obj.Name or "")
                    local remove = petNames[n] == true
                        or n:find("pet", 1, true) ~= nil
                        or n:find("companion", 1, true) ~= nil
                        or n:find("follower", 1, true) ~= nil
                        or n:find("familiar", 1, true) ~= nil
                    if remove and obj ~= clone then
                        pcall(function() obj:Destroy() end)
                    end
                end

                clone.Parent = PreviewWorld
                PreviewModel = clone

                -- Полностью нейтральная стойка без эмоций/idle-позы.
                resetPose(clone)

                -- Сначала ставим модель в ноль, затем математически центрируем
                -- её по BoundingBox. Это убирает смещение влево/вправо и снизу/сверху.
                pcall(function()
                    clone:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))
                end)
                local centeredCF, centeredSize = centerModel(clone)
                PreviewPivot = clone:GetPivot()

                for _,part in ipairs(clone:GetDescendants()) do
                    if part:IsA("BasePart") then
                        PreviewFrozen[part] = part.CFrame
                    end
                end

                -- Жёстко фиксируем клон в ViewportFrame. Движение/анимации
                -- исходного персонажа больше не могут менять его положение.
                PreviewFreezeConnection = RunService.RenderStepped:Connect(function()
                    if not PreviewModel or PreviewModel ~= clone then return end
                    for part,cf in pairs(PreviewFrozen) do
                        if part and part.Parent then
                            pcall(function()
                                part.Anchored = true
                                part.CFrame = cf
                                part.AssemblyLinearVelocity = Vector3.zero
                                part.AssemblyAngularVelocity = Vector3.zero
                            end)
                        end
                    end
                end)

                PreviewHighlight = Instance.new("Highlight")
                PreviewHighlight.Name = "PreviewHighlight"
                PreviewHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
                PreviewHighlight.FillColor = CURRENT_ACCENT
                PreviewHighlight.OutlineColor = CURRENT_ACCENT
                PreviewHighlight.FillTransparency = 0.92
                PreviewHighlight.OutlineTransparency = 0.18
                PreviewHighlight.Adornee = clone
                PreviewHighlight.Parent = clone

                fitCamera(clone)
            end)

            PreviewBuildBusy = false
            if not success then
                clearPreviewModel()
                warn("[Clumsy] Character preview isolated error: " .. tostring(err))
            end
        end

        local lastSyncX, lastSyncY, lastSyncW, lastSyncH = -1, -1, -1, -1
        local function syncPreview()
            if not MainFrame or not MainFrame.Parent then return end
            local camera = workspace.CurrentCamera
            if not camera then return end
            local mainPos = MainFrame.AbsolutePosition
            local mainSize = MainFrame.AbsoluteSize
            if mainSize.X <= 1 or mainSize.Y <= 1 then return end

            -- Жёстко приклеено к правой стороне MainFrame.
            -- Никаких ограничений по экрану: если меню выходит за край,
            -- превью выходит вместе с ним и не перескакивает в другое место.
            local previewWidth = math.max(175, math.floor(mainSize.X * 0.37))
            local gap = 8
            local x = math.floor(mainPos.X + mainSize.X + gap)
            -- Карточка просмотра находится немного ниже верхней границы меню,
            -- но сохраняет ту же высоту, что и MainFrame. Поэтому она больше
            -- не выглядит поднятой относительно меню.
            local previewYOffset = 55
            local y = math.floor(mainPos.Y + previewYOffset)
            local h = math.max(120, math.floor(mainSize.Y))

            if x == lastSyncX and y == lastSyncY and previewWidth == lastSyncW and h == lastSyncH then
                return
            end
            lastSyncX, lastSyncY, lastSyncW, lastSyncH = x, y, previewWidth, h

            PreviewFrame.Size = UDim2.fromOffset(previewWidth, h)
            PreviewFrame.Position = UDim2.fromOffset(x, y)
            PreviewViewport.Size = UDim2.new(1, -14, 1, -40)

            -- Большая очень прозрачная "перемычка" на всю высоту.
            -- Визуально это единый блок меню + просмотр, а не отдельное окно.
            local connectorX = math.floor(mainPos.X + mainSize.X - 1)
            local connectorY = y
            local connectorW = math.max(0, math.floor(x - connectorX + 1))
            local connectorH = h
            if connectorW > 0 then
                PreviewConnector.Position = UDim2.fromOffset(connectorX, connectorY)
                PreviewConnector.Size = UDim2.fromOffset(connectorW, connectorH)
                PreviewConnector.Visible = MainFrame.Visible and PreviewGui.Enabled
            else
                PreviewConnector.Visible = false
            end

            -- Общий прозрачный фон охватывает меню, промежуток и просмотр.
            local dockX = math.floor(mainPos.X + mainSize.X - 1)
            local dockY = y - 1
            local dockW = math.floor((x + previewWidth) - (mainPos.X + mainSize.X) + 2)
            local dockH = math.floor(h + 2)
            PreviewDock.Position = UDim2.fromOffset(dockX, dockY)
            PreviewDock.Size = UDim2.fromOffset(math.max(1, dockW), math.max(1, dockH))
            PreviewDock.Visible = MainFrame.Visible and PreviewGui.Enabled
        end

        -- Никакого постоянного RenderStepped/while-loop для позиции.
        -- Превью пересчитывается только при реальном изменении меню/экрана.
        local syncQueued = false
        local function queueSync()
            if syncQueued then return end
            syncQueued = true
            task.defer(function()
                syncQueued = false
                pcall(syncPreview)
            end)
        end

        MainFrame:GetPropertyChangedSignal("Position"):Connect(queueSync)
        MainFrame:GetPropertyChangedSignal("Size"):Connect(queueSync)
        MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(queueSync)
        MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueSync)
        MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            queueSync()
        end)

        local cameraConnection
        local function hookCamera()
            if cameraConnection then
                cameraConnection:Disconnect()
                cameraConnection = nil
            end
            local camera = workspace.CurrentCamera
            if camera then
                cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(queueSync)
            end
            queueSync()
        end
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(hookCamera)
        hookCamera()

        -- Персонаж в ViewportFrame полностью статичен: части уже Anchored,
        -- поэтому постоянный цикл PivotTo/Velocity больше не нужен.

        -- Превью теперь выключено до явного включения пользователем.
        local previewUserEnabled = false

        LocalPlayer.CharacterAdded:Connect(function()
            if previewUserEnabled then
                task.delay(1, function() if previewUserEnabled and menuUnlocked then buildPreview() end end)
            end
        end)

        local visualHookConnections = {}
        local function hookCharacterVisualChanges(character)
            if not character then return end
            for _,c in ipairs(visualHookConnections) do pcall(function() c:Disconnect() end) end
            visualHookConnections = {}

            local function queueVisualRefresh()
                if previewUserEnabled and menuUnlocked then
                    task.defer(buildPreview)
                end
            end

            visualHookConnections[#visualHookConnections+1] = character.DescendantAdded:Connect(queueVisualRefresh)
            visualHookConnections[#visualHookConnections+1] = character.DescendantRemoving:Connect(queueVisualRefresh)
        end
        hookCharacterVisualChanges(LocalPlayer.Character)
        LocalPlayer.CharacterAdded:Connect(hookCharacterVisualChanges)

        -- Визуалы вроде Chams/Aura/China Hat иногда меняют свойства уже
        -- существующего объекта без DescendantAdded. Проверяем только состав
        -- модели раз в секунду, не двигая карточку и не трогая её позицию.
        task.spawn(function()
            local lastVisualCount = -1
            while PreviewGui.Parent do
                task.wait(1)
                if previewUserEnabled and menuUnlocked and LocalPlayer.Character then
                    local count = #LocalPlayer.Character:GetDescendants()
                    if count ~= lastVisualCount then
                        lastVisualCount = count
                        task.defer(buildPreview)
                    end
                end
            end
        end)

        onAccentChange(function(c)
            pcall(function()
                PreviewStroke.Color = c
                ConnectorStroke.Color = c
                DockStroke.Color = c
                if PreviewHighlight then
                    PreviewHighlight.FillColor = c
                    PreviewHighlight.OutlineColor = c
                end
            end)
        end)

        local function updatePreviewVisibility()
            local visible = previewUserEnabled and menuUnlocked and MainFrame.Visible
            PreviewGui.Enabled = visible
            PreviewConnector.Visible = visible and PreviewFrame.Visible
            PreviewDock.Visible = visible and PreviewFrame.Visible
            if visible then
                if not PreviewModel then
                    task.defer(buildPreview)
                end
                queueSync()
            end
        end

        getgenv().ClumsyPreviewSetVisible = function(v)
            previewUserEnabled = v and true or false
            updatePreviewVisibility()
        end
        getgenv().ClumsyPreviewRefresh = function()
            if previewUserEnabled and menuUnlocked then task.defer(buildPreview) end
        end

        MainFrame:GetPropertyChangedSignal("Visible"):Connect(updatePreviewVisibility)
        updatePreviewVisibility()
        queueSync()
    end)

    if not okPreview then
        warn("[Clumsy] Character preview disabled: " .. tostring(previewError))
    end
end

-- KITY CORE UPDATE
getgenv().KITY_CORE = getgenv().KITY_CORE or {}
local KITY = getgenv().KITY_CORE

KITY.Settings = KITY.Settings or {
    AutoPerformance=false,
    ESPThrottle=true,
    SmartUpdate=true,
    AutoSave=false,
    MenuAnimation=true,
    Notifications=true
}

KITY.Config = KITY.Config or {}
KITY.Profiles = {
 Default={},
 Performance={AutoPerformance=true,ESPThrottle=true},
 Visual={AutoPerformance=false},
 Mobile={AutoPerformance=true,SmartUpdate=true}
}

function KITY.Config.Save()
    KITY.SaveData=table.clone(KITY.Settings)
end

function KITY.Config.Load()
    if KITY.SaveData then
        for k,v in pairs(KITY.SaveData) do
            KITY.Settings[k]=v
        end
    end
end

function KITY.Config.Reset()
    KITY.Settings={}
end

function KITY.Config.Profile(name)
    local p=KITY.Profiles[name]
    if p then
        for k,v in pairs(p) do
            KITY.Settings[k]=v
        end
    end
end

KITY.Menu = KITY.Menu or {
 AccentColor=Color3.fromRGB(133,220,255),
 Position=nil,
 Collapsed={}
}

function KITY.Menu.SetAccent(c)
    KITY.Menu.AccentColor=c
end

function KITY.Menu.SavePosition(p)
    KITY.Menu.Position=p
end

KITY.Optimizer = KITY.Optimizer or {}
KITY.Optimizer.FPS=60
KITY.Optimizer._lastCleanup=0
KITY.Optimizer._cleanupInterval=12
KITY.Optimizer._lastUpdate=0

-- Performance: не запускаем полный GC на каждом Heartbeat.
-- Полный collectgarbage слишком дорогой и мог вызывать микрофризы.
function KITY.Optimizer.Cleanup(force)
    local now=os.clock()
    if not force and now-KITY.Optimizer._lastCleanup < KITY.Optimizer._cleanupInterval then
        return false
    end
    KITY.Optimizer._lastCleanup=now
    pcall(collectgarbage,"collect")
    return true
end

function KITY.Optimizer.Update()
    if not KITY.Settings.AutoPerformance then return end
    local now=os.clock()
    -- Проверка производительности раз в 1 секунду вместо 60+ раз в секунду.
    if now-KITY.Optimizer._lastUpdate < 1 then return end
    KITY.Optimizer._lastUpdate=now
    KITY.Optimizer.Cleanup(false)
end

KITY.AntiBug = KITY.AntiBug or {}

function KITY.AntiBug.SafeCall(f,...)
    local ok,res=pcall(f,...)
    return ok,res
end

function KITY.AntiBug.Shutdown()
    pcall(function()
        KITY.Optimizer.Cleanup(true)
    end)
end

-- Performance: the optimizer does not need a 60 Hz heartbeat.
-- Run its inexpensive 1-second check on a lightweight task instead,
-- leaving Heartbeat/RenderStepped free for gameplay and visuals.
if not KITY.Connection then
    KITY.Connection=true
    task.spawn(function()
        while KITY.Connection do
            task.wait(1)
            pcall(KITY.Optimizer.Update)
        end
    end)
end

print("[KITY] Core loaded")
