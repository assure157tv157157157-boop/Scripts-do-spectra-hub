--[[
    Created by Redz
    Modified for Laelmano24
    Enhanced with:
    - Multi-touch drag fix
    - Vibrant Red Tech theme
    - Smooth animations (Quad/Expo easing)
    - Tech glow effects
    - Refined borders and strokes
    - Smooth minimize with rotation
]]

local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerMouse = Player:GetMouse()
local HiddenGui = (gethui or function() return game:GetService("CoreGui") end)()

shared.redzlib = shared.redzlib or { Cache = {} }

local redzlib = {
    Themes = {
        -- New vibrant Red Tech theme
        RedTech = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(80, 20, 20)),   -- deep red
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(140, 40, 40)),  -- bright red
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(60, 15, 15))    -- dark red
            }),
            ["Color Hub 2"] = Color3.fromRGB(45, 15, 15),                      -- dark background
            ["Color Stroke"] = Color3.fromRGB(180, 60, 60),                    -- medium red stroke
            ["Color Theme"] = Color3.fromRGB(255, 80, 80),                     -- vibrant accent
            ["Color Text"] = Color3.fromRGB(255, 240, 240),                    -- off-white text
            ["Color Dark Text"] = Color3.fromRGB(210, 180, 180),               -- soft gray-red
            ["Color Glow"] = Color3.fromRGB(255, 100, 100)                     -- glow effect
        },
        -- keep other themes for compatibility
        Darker = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(25, 25, 25)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 25, 25))
            }),
            ["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
            ["Color Stroke"] = Color3.fromRGB(40, 40, 40),
            ["Color Theme"] = Color3.fromRGB(88, 101, 242),
            ["Color Text"] = Color3.fromRGB(243, 243, 243),
            ["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
        },
        Dark = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 40)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(47.5, 47.5, 47.5)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 40, 40))
            }),
            ["Color Hub 2"] = Color3.fromRGB(45, 45, 45),
            ["Color Stroke"] = Color3.fromRGB(65, 65, 65),
            ["Color Theme"] = Color3.fromRGB(65, 150, 255),
            ["Color Text"] = Color3.fromRGB(245, 245, 245),
            ["Color Dark Text"] = Color3.fromRGB(190, 190, 190)
        },
        Purple = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(27.5, 25, 30)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(27.5, 25, 30))
            }),
            ["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
            ["Color Stroke"] = Color3.fromRGB(40, 40, 40),
            ["Color Theme"] = Color3.fromRGB(150, 0, 255),
            ["Color Text"] = Color3.fromRGB(240, 240, 240),
            ["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
        },
        Green = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(19, 97, 61)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(19, 97, 61)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(19, 97, 61))
            }),
            ["Color Hub 2"] = Color3.fromRGB(20, 93, 60),
            ["Color Stroke"] = Color3.fromRGB(26, 119, 77),
            ["Color Theme"] = Color3.fromRGB(50, 229, 148),
            ["Color Text"] = Color3.fromRGB(243, 243, 243),
            ["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
        },
        Troll = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(25, 25, 25)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 25, 25))
            }),
            ["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
            ["Color Stroke"] = Color3.fromRGB(40, 40, 40),
            ["Color Theme"] = Color3.fromRGB(138, 36, 36),
            ["Color Text"] = Color3.fromRGB(243, 243, 243),
            ["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
        }
    },
    Info = { Version = "2.1.0" },
    Save = {
        UISize = {434, 247},
        TabSize = 160,
        Theme = "RedTech"      -- new default theme
    },
    Settings = {},
    Connection = {},
    Instances = {},
    Elements = {},
    Options = {},
    Flags = {},
    Tabs = {},
    ScreenGui = nil,
    Device = UserInputService.TouchEnabled and "Mobile" or "Computer",
    Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/raelhubfunctions/Rael-hub-libary/refs/heads/main/Icons.lua"))()
}

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 450
local Settings = redzlib.Settings
local Flags = redzlib.Flags

-- Helper functions (SetProps, Create, etc.) - keep as original
local SetProps, SetChildren, InsertTheme, Create do
    InsertTheme = function(Instance, Type)
        table.insert(redzlib.Instances, { Instance = Instance, Type = Type })
        return Instance
    end
    SetChildren = function(Instance, Children)
        if Children then
            table.foreach(Children, function(_, Child) Child.Parent = Instance end)
        end
        return Instance
    end
    SetProps = function(Instance, Props)
        if Props then
            table.foreach(Props, function(prop, value) Instance[prop] = value end)
        end
        return Instance
    end
    Create = function(...)
        local args = {...}
        if type(args) ~= "table" then return end
        local new = Instance.new(args[1])
        if type(args[2]) == "table" then
            SetProps(new, args[2])
            SetChildren(new, args[3])
        elseif typeof(args[2]) == "Instance" then
            new.Parent = args[2]
            SetProps(new, args[3])
            SetChildren(new, args[4])
        end
        return new
    end
    local function Save(file)
        if readfile and isfile and isfile(file) then
            local decode = HttpService:JSONDecode(readfile(file))
            if type(decode) == "table" then
                if rawget(decode, "UISize") then redzlib.Save.UISize = decode.UISize end
                if rawget(decode, "TabSize") then redzlib.Save.TabSize = decode.TabSize end
                if rawget(decode, "Theme") and VerifyTheme(decode.Theme) then redzlib.Save.Theme = decode.Theme end
            end
        end
    end
    pcall(Save, "rael hub with redz library.json")
end

-- Funcs, Connections, Flags (keep as original, but we'll modify MakeDrag)
local Funcs = {} do
    function Funcs:RandomString(length)
        if typeof(length) == "number" and length > 0 then
            local result = {}
            for i = 1, length do table.insert(result, string.char(math.random(32, 255))) end
            return table.concat(result)
        end
        return nil
    end
    function Funcs:GetCallback(Configs, index)
        local func = Configs[index] or Configs.Callback or function() end
        if type(func) == "table" then return ({function(Value) func[1][func[2]] = Value end}) end
        return {func}
    end
    function Funcs:InsertCallback(tab, func)
        if type(func) == "function" then table.insert(tab, func) end
        return func
    end
    function Funcs:FireCallback(tab, ...)
        for _, v in ipairs(tab) do if type(v) == "function" then task.spawn(v, ...) end end
    end
    function Funcs:ToggleVisible(Obj, Bool) Obj.Visible = Bool ~= nil and Bool or Obj.Visible end
    function Funcs:ToggleParent(Obj, Parent, Bool) -- simplified
        if Bool ~= nil then Obj.Parent = Bool else Obj.Parent = not Obj.Parent and Parent end
    end
end

-- Connections (keep as original)
local Connections = redzlib.Connection do
    function Funcs:SetConnection(Configs)
        local CSignal = Configs[1] or Configs.Signal
        local CInstance = Configs[2] or Configs.Instance
        local CRandom = Configs[3] or Configs.RandomString or false
        local TableConnect = {}
        local CName = CSignal .. (CRandom and "-" .. Funcs:RandomString(16) or "")
        local CFunc = function() end
        Connections[CName] = {
            Name = CName,
            Function = CFunc,
            Connection = CInstance[CSignal]:Connect(function(...) CFunc(...) end)
        }
        function TableConnect:Connect(callback)
            CFunc = callback
            if Connections[CName] and Connections[CName].Function then Connections[CName].Function = callback end
        end
        function TableConnect:Disconnect()
            if Connections[CName] and Connections[CName].Connection then
                Connections[CName].Connection:Disconnect()
                Connections[CName] = nil
            end
        end
        return TableConnect
    end
    function Funcs:FireCustomConnection(CName, ...)
        local Connection = type(CName) == "string" and Connections[CName] or Connections[CName.Name]
        if Connection and Connection.Functions then
            for _, func in pairs(Connection.Functions) do task.spawn(func, ...) end
        end
    end
    function Funcs:GetCustomConnectionFunctions(connectedFuncs, func)
        local Connected = { Function = func, Connected = true }
        function Connected:Disconnect()
            if self.Connected then
                table.remove(connectedFuncs, table.find(connectedFuncs, self.Function))
                self.Connected = false
            end
        end
        function Connected:Fire(...) if self.Connected then task.spawn(self.Function, ...) end end
        return Connected
    end
    function Funcs:NewCustomConnectionList(List)
        if type(List) ~= "table" then return end
        for _, CName in ipairs(List) do
            local Connection = {}
            local ConnectedFuncs = {}
            local TableConnect = { Name = CName, Connection = Connection, Functions = ConnectedFuncs }
            Connections[CName] = TableConnect
            function TableConnect:Connect(func)
                if type(func) == "function" then
                    table.insert(ConnectedFuncs, func)
                    return Funcs:GetCustomConnectionFunctions(ConnectedFuncs, func)
                end
            end
            function Connection:Disconnect() Connections[CName] = nil end
        end
    end
    Funcs:NewCustomConnectionList({ "FileSaved", "OptionAdded", "FlagsChanged", "ThemeChanged", "ThemeChanging" })
end

-- Flags (keep as original)
local GetFlag, SetFlag, CheckFlag, FlagConnection do
    FlagConnection = Connections["FlagsChanged"]
    CheckFlag = function(Name) return type(Name) == "string" and Flags[Name] ~= nil end
    GetFlag = function(Name) return type(Name) == "string" and Flags[Name] end
    SetFlag = function(Flag, Value)
        if Flag and (Value ~= Flags[Flag] or type(Value) == "table") then
            Flags[Flag] = Value
            Funcs:FireCustomConnection("FlagsChanged", Flag, Value)
        end
    end
    local DatabaseState
    FlagConnection:Connect(function(Flag, Value)
        local ScriptFile = Settings.ScriptFile
        if not DatabaseState and ScriptFile and writefile then
            DatabaseState = true
            task.wait(0.1)
            DatabaseState = false
            local Success, Encoded = pcall(function() return HttpService:JSONEncode(Flags) end)
            if Success then
                local Success = pcall(writefile, ScriptFile, Encoded)
                if Success then Funcs:FireCustomConnection("FileSaved", "Script-Flags", ScriptFile, Encoded) end
            end
        end
    end)
end

-- ScreenGui setup
local ScreenGui = Create("ScreenGui", HiddenGui, { Name = redzLibName or "rael hub with redz library" }, {
    Create("UIScale", { Scale = UIScale, Name = "Scale" })
})
local ScreenFind = HiddenGui:FindFirstChild(ScreenGui.Name)
if ScreenFind and ScreenFind ~= ScreenGui then ScreenFind:Destroy() end
ScreenGui.Destroying:Connect(function()
    for CName, CValue in pairs(Connections) do
        if typeof(CValue) == "table" and CValue.Connection then CValue.Connection:Disconnect() end
    end
end)
redzlib.ScreenGui = ScreenGui

-- NotificationMain
local NotificationMain = Create("Frame", ScreenGui, {
    Name = "NotificationMain",
    BorderSizePixel = 0,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 200, 1, -50),
    Position = UDim2.new(1, -205, 0, 0)
}, {
    Create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom })
})

local function GetStr(val) return type(val) == "function" and val() or val end
local function ConnectSave(Instance, func)
    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait() end
        end
        func()
    end)
end

-- Improved CreateTween with smoother easing
local function CreateTween(Configs)
    local Instance = Configs[1] or Configs.Instance
    local Prop = Configs[2] or Configs.Prop
    local NewVal = Configs[3] or Configs.NewVal
    local Time = Configs[4] or Configs.Time or 0.4
    local TweenWait = Configs[5] or Configs.wait or false
    local Easing = Configs.Easing or Enum.EasingStyle.Quad  -- smoother default
    local Direction = Configs.Direction or Enum.EasingDirection.Out
    local TweenInfo = TweenInfo.new(Time, Easing, Direction)
    local Tween = TweenService:Create(Instance, TweenInfo, { [Prop] = NewVal })
    Tween:Play()
    if TweenWait then Tween.Completed:Wait() end
    return Tween
end

-- Improved MakeDrag with multi-touch fix
local function MakeDrag(Instance, Callback)
    task.spawn(function()
        SetProps(Instance, { Active = true, AutoButtonColor = false })
        local dragStart, startPos, moved, dragging, activeTouch
        local function update(input)
            if not dragging or (activeTouch and input ~= activeTouch) then return end
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then moved = true end
            if moved then
                Instance.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X / UIScale,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y / UIScale
                )
            end
        end
        Instance.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not dragging then
                dragging = true
                moved = false
                dragStart = input.Position
                startPos = Instance.Position
                activeTouch = input  -- store the initiating touch
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        Instance.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                activeTouch = nil
                if not moved and Callback then Callback() end
            end
        end)
        -- Also handle case where touch ends but drag continues? Not needed.
    end)
    return Instance
end

local function VerifyTheme(Theme)
    for name, _ in pairs(redzlib.Themes) do if name == Theme then return true end end
end
local function SaveJson(FileName, save)
    if writefile then pcall(writefile, FileName, HttpService:JSONEncode(save)) end
end

local Theme = redzlib.Themes[redzlib.Save.Theme]

local function AddEle(Name, Func) redzlib.Elements[Name] = Func end
local function Make(Ele, Instance, props, ...) return redzlib.Elements[Ele](Instance, props, ...) end

-- Elements
AddEle("Corner", function(parent, CornerRadius)
    return SetProps(Create("UICorner", parent, { CornerRadius = CornerRadius or UDim.new(0, 7) }), props)
end)
AddEle("Stroke", function(parent, props, ...)
    local args = {...}
    local New = InsertTheme(SetProps(Create("UIStroke", parent, {
        Color = args[1] or Theme["Color Stroke"],
        Thickness = args[2] or 1,
        ApplyStrokeMode = "Border"
    }), props), "Stroke")
    return New
end)
AddEle("Button", function(parent, props, ...)
    local args = {...}
    local New = InsertTheme(SetProps(Create("TextButton", parent, {
        Text = "",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme["Color Hub 2"],
        AutoButtonColor = false
    }), props), "Frame")
    New.MouseEnter:Connect(function()
        TweenService:Create(New, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.4 }):Play()
    end)
    New.MouseLeave:Connect(function()
        TweenService:Create(New, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
    end)
    if args[1] then New.Activated:Connect(args[1]) end
    return New
end)
AddEle("Gradient", function(parent, props, ...)
    local args = {...}
    local New = InsertTheme(SetProps(Create("UIGradient", parent, { Color = Theme["Color Hub 1"] }), props), "Gradient")
    return New
end)
AddEle("GlowStroke", function(parent, props, ...)  -- new element for glow effect
    local args = {...}
    local New = SetProps(Create("UIStroke", parent, {
        Color = Theme["Color Glow"] or Theme["Color Theme"],
        Thickness = args[2] or 2,
        Transparency = 0.7,
        ApplyStrokeMode = "Border"
    }), props)
    return New
end)

local function ButtonFrame(Instance, Title, Description, HolderSize)
    local TitleL = InsertTheme(Create("TextLabel", {
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme["Color Text"],
        Size = UDim2.new(1, -20),
        AutomaticSize = "Y",
        Position = UDim2.new(0, 0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        TextTruncate = "AtEnd",
        TextSize = 10,
        TextXAlignment = "Left",
        Text = "",
        RichText = true
    }), "Text")
    local DescL = InsertTheme(Create("TextLabel", {
        Font = Enum.Font.Gotham,
        TextColor3 = Theme["Color Dark Text"],
        Size = UDim2.new(1, -20),
        AutomaticSize = "Y",
        Position = UDim2.new(0, 12, 0, 15),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextSize = 8,
        TextXAlignment = "Left",
        Text = "",
        RichText = true
    }), "DarkText")
    local Frame = Make("Button", Instance, { Size = UDim2.new(1, 0, 0, 25), AutomaticSize = "Y", Name = "Option" })
    Make("Corner", Frame, UDim.new(0, 6))
    local LabelHolder = Create("Frame", Frame, {
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Size = HolderSize,
        Position = UDim2.new(0, 10, 0),
        AnchorPoint = Vector2.new(0, 0)
    }, {
        Create("UIListLayout", { SortOrder = "LayoutOrder", VerticalAlignment = "Center", Padding = UDim.new(0, 2) }),
        Create("UIPadding", { PaddingBottom = UDim.new(0, 5), PaddingTop = UDim.new(0, 5) }),
        TitleL, DescL
    })
    local Label = {}
    function Label:SetTitle(NewTitle)
        if type(NewTitle) == "string" and NewTitle:gsub(" ", ""):len() > 0 then TitleL.Text = NewTitle end
    end
    function Label:SetDesc(NewDesc)
        if type(NewDesc) == "string" and NewDesc:gsub(" ", ""):len() > 0 then
            DescL.Visible = true
            DescL.Text = NewDesc
            LabelHolder.Position = UDim2.new(0, 10, 0)
            LabelHolder.AnchorPoint = Vector2.new(0, 0)
        else
            DescL.Visible = false
            DescL.Text = ""
            LabelHolder.Position = UDim2.new(0, 10, 0.5)
            LabelHolder.AnchorPoint = Vector2.new(0, 0.5)
        end
    end
    Label:SetTitle(Title)
    Label:SetDesc(Description)
    return Frame, Label
end

local function GetColor(Instance)
    if Instance:IsA("Frame") then return "BackgroundColor3"
    elseif Instance:IsA("ImageLabel") then return "ImageColor3"
    elseif Instance:IsA("TextLabel") then return "TextColor3"
    elseif Instance:IsA("ScrollingFrame") then return "ScrollBarImageColor3"
    elseif Instance:IsA("UIStroke") then return "Color"
    end
    return ""
end

-- redzlib methods
function redzlib:GetIcon(IconName)
    if IconName:find("rbxassetid://") or IconName:len() < 1 then return IconName end
    IconName = IconName:lower():gsub("lucide", ""):gsub("-", "")
    for Name, Icon in pairs(redzlib.Icons) do
        Name = Name:gsub("lucide", ""):gsub("-", "")
        if Name == IconName then return Icon end
    end
    for Name, Icon in pairs(redzlib.Icons) do
        Name = Name:gsub("lucide", ""):gsub("-", "")
        if Name:find(IconName) then return Icon end
    end
    return IconName
end
function redzlib:SetTheme(NewTheme, saveTheme)
    if not VerifyTheme(NewTheme) then return end
    redzlib.Save.Theme = NewTheme
    if saveTheme == true then SaveJson("rael hub with redz library.json", redzlib.Save) end
    Theme = redzlib.Themes[NewTheme]
    Funcs:FireCustomConnection("ThemeChanged", NewTheme)
    table.foreach(redzlib.Instances, function(_, Val)
        if Val.Type == "Gradient" then Val.Instance.Color = Theme["Color Hub 1"]
        elseif Val.Type == "Frame" then Val.Instance.BackgroundColor3 = Theme["Color Hub 2"]
        elseif Val.Type == "Stroke" then Val.Instance[GetColor(Val.Instance)] = Theme["Color Stroke"]
        elseif Val.Type == "Theme" then Val.Instance[GetColor(Val.Instance)] = Theme["Color Theme"]
        elseif Val.Type == "Text" then Val.Instance[GetColor(Val.Instance)] = Theme["Color Text"]
        elseif Val.Type == "DarkText" then Val.Instance[GetColor(Val.Instance)] = Theme["Color Dark Text"]
        elseif Val.Type == "ScrollBar" then Val.Instance[GetColor(Val.Instance)] = Theme["Color Theme"]
        end
    end)
end
function redzlib:SetScale(NewScale)
    NewScale = ViewportSize.Y / math.clamp(NewScale, 300, 2000)
    UIScale, ScreenGui.Scale.Scale = NewScale, NewScale
end
function redzlib:Notify(config)
    local NTitle = config[1] or config.Title or ""
    local NText = config[2] or config.Text or ""
    local NDuration = config[3] or config.Duration or 3
    local NIcon = config[4] or config.Icon
    local NSound = config[5] or config.Sound
    local notification = Create("Frame", NotificationMain, {
        Name = "notification",
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 0, 50)
    })
    local content = Create("Frame", notification, {
        Name = "content",
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 0, 50),
        Position = UDim2.new(0, 300, 0, 0),
        BackgroundColor3 = Theme["Color Stroke"]
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
        Create("UIListLayout", { Name = "content", Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) })
    })
    local textContent = Create("Frame", content, {
        Name = "textContent",
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 190, 0, 40)
    }, {
        Create("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }),
        Create("TextLabel", { Name = "title", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Text = NTitle, TextSize = 13, LayoutOrder = 1, TextColor3 = Color3.fromRGB(255, 255, 255), FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold) }),
        Create("TextLabel", { Name = "description", Text = NText, Size = UDim2.new(1, 0, 1, -16), TextWrapped = true, BackgroundTransparency = 1, TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, LayoutOrder = 2, TextColor3 = Color3.fromRGB(255, 255, 255), FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold) })
    })
    if NIcon then
        local IconContent = typeof(NIcon) == "table" and NIcon.Icon or NIcon
        local IconCornerRadius = typeof(NIcon) == "table" and NIcon.CornerRadius and NIcon.CornerRadius or UDim.new(0, 0)
        textContent.Size = UDim2.new(0, 145, 0, 40)
        Create("ImageLabel", content, { Name = "content", Image = IconContent, BorderSizePixel = 0, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(0, 40, 0, 40) }, { Create("UICorner", { Name = "UICorner", CornerRadius = IconCornerRadius }) })
    end
    if NSound then Create("Sound", notification, { Name = "Sound", SoundId = NSound }):Play() end
    task.spawn(function()
        CreateTween({ content, "Position", UDim2.new(0, 0, 0, 0), 0.5, true, Easing = Enum.EasingStyle.Expo })
        task.wait(NDuration)
        CreateTween({ content, "Position", UDim2.new(0, 300, 0, 0), 0.5, true, Easing = Enum.EasingStyle.Expo })
        notification:Destroy()
    end)
end

function redzlib:MakeWindow(Configs)
    local WTitle = Configs[1] or Configs.Name or Configs.Title or "rael hub with redz library"
    local WMiniText = Configs[2] or Configs.SubTitle or "by : Laelmano24"
    Settings.ScriptFile = Configs[3] or Configs.SaveFolder or false
    local WReleaseMouse = Configs[4] or Configs.ReleaseMouse or false
    local BackgroundImage = Configs.Background or Configs.BackgroundImage
    local BackgroundImageTransparency = Configs.BackgroundImageTransparency or 0

    local function MouseFree(IsReleaseMouse, Visible)
        if not IsReleaseMouse then return end
        shared.redzlib.Cache.MouseProps = shared.redzlib.Cache.MouseProps or {
            MouseIcon = UserInputService.MouseIcon,
            MouseBehavior = UserInputService.MouseBehavior,
            MouseIconEnabled = UserInputService.MouseIconEnabled,
        }
        if Visible then
            UserInputService.MouseIcon = ""
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        else
            local MouseProps = shared.redzlib.Cache.MouseProps
            UserInputService.MouseIcon = MouseProps.MouseIcon
            UserInputService.MouseBehavior = MouseProps.MouseBehavior
            UserInputService.MouseIconEnabled = MouseProps.MouseIconEnabled
        end
    end

    local function LoadFile()
        local File = Settings.ScriptFile
        if type(File) ~= "string" or File == "" or not readfile or not isfile then return end
        local s, r = pcall(isfile, File)
        if s and r then
            local s, _Flags = pcall(readfile, File)
            if s and type(_Flags) == "string" then
                local s, r = pcall(function() return HttpService:JSONDecode(_Flags) end)
                Flags = s and r or {}
            end
        end
    end; LoadFile()

    local UISizeX, UISizeY = unpack(redzlib.Save.UISize)
    local MainFrame = InsertTheme(Create("ImageButton", ScreenGui, {
        Size = UDim2.fromOffset(UISizeX, UISizeY),
        Position = UDim2.new(0.5, -UISizeX/2, 0.5, -UISizeY/2),
        BackgroundTransparency = 0.03,
        Name = "Hub",
        Image = BackgroundImage or "",
        ImageTransparency = BackgroundImageTransparency,
        ScaleType = Enum.ScaleType.Crop,
    }), "Main")
    Make("Gradient", MainFrame, { Rotation = 45 })
    MakeDrag(MainFrame)

    local ButtonTarget = "RightControl"
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode[ButtonTarget] and MainFrame then MainFrame.Visible = not MainFrame.Visible end
    end)

    local MainCorner = Make("Corner", MainFrame)
    local Components = Create("Folder", MainFrame, { Name = "Components" })
    local DropdownHolder = Create("Folder", ScreenGui, { Name = "Dropdown" })
    local TopBar = Create("Frame", Components, { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Name = "Top Bar" })
    local Title = InsertTheme(Create("TextLabel", TopBar, {
        Position = UDim2.new(0, 15, 0.5), AnchorPoint = Vector2.new(0, 0.5), AutomaticSize = "XY",
        Text = WTitle, TextXAlignment = "Left", TextSize = 12, TextColor3 = Theme["Color Text"],
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Name = "Title"
    }, {
        InsertTheme(Create("TextLabel", {
            Size = UDim2.fromScale(0, 1), AutomaticSize = "X", AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(1, 5, 0.9), Text = WMiniText, TextColor3 = Theme["Color Dark Text"],
            BackgroundTransparency = 1, TextXAlignment = "Left", TextYAlignment = "Bottom",
            TextSize = 8, Font = Enum.Font.Gotham, Name = "SubTitle"
        }), "DarkText")
    }), "Text")

    local MainScroll = InsertTheme(Create("ScrollingFrame", Components, {
        Size = UDim2.new(0, redzlib.Save.TabSize, 1, -TopBar.Size.Y.Offset),
        ScrollBarImageColor3 = Theme["Color Theme"],
        Position = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(0, 1),
        ScrollBarThickness = 1.5, BackgroundTransparency = 1, ScrollBarImageTransparency = 0.2,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = "Y", ScrollingDirection = "Y",
        BorderSizePixel = 0, Name = "Tab Scroll"
    }, {
        Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
        Create("UIListLayout", { Padding = UDim.new(0, 5) })
    }), "ScrollBar")

    local Containers = Create("Frame", Components, {
        Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ClipsDescendants = true, Name = "Containers"
    })

    local ControlSize1, ControlSize2 = MakeDrag(Create("ImageButton", MainFrame, {
        Size = UDim2.new(0, 35, 0, 35), Position = MainFrame.Size,
        Active = true, AnchorPoint = Vector2.new(0.8, 0.8), BackgroundTransparency = 1, Name = "Control Hub Size"
    })), MakeDrag(Create("ImageButton", MainFrame, {
        Size = UDim2.new(0, 20, 1, -30), Position = UDim2.new(0, MainScroll.Size.X.Offset, 1, 0),
        AnchorPoint = Vector2.new(0.5, 1), Active = true, BackgroundTransparency = 1, Name = "Control Tab Size"
    }))

    local function ControlSize()
        local Pos1, Pos2 = ControlSize1.Position, ControlSize2.Position
        ControlSize1.Position = UDim2.fromOffset(math.clamp(Pos1.X.Offset, 430, 1000), math.clamp(Pos1.Y.Offset, 200, 500))
        ControlSize2.Position = UDim2.new(0, math.clamp(Pos2.X.Offset, 135, 250), 1, 0)
        MainScroll.Size = UDim2.new(0, ControlSize2.Position.X.Offset, 1, -TopBar.Size.Y.Offset)
        Containers.Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset)
        MainFrame.Size = ControlSize1.Position
    end

    RunService.RenderStepped:Connect(function() MouseFree(WReleaseMouse, MainFrame.Visible) end)
    ControlSize1:GetPropertyChangedSignal("Position"):Connect(ControlSize)
    ControlSize2:GetPropertyChangedSignal("Position"):Connect(ControlSize)

    ConnectSave(ControlSize1, function()
        if not Minimized then
            redzlib.Save.UISize = { MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset }
            SaveJson("rael hub with redz library.json", redzlib.Save)
        end
    end)
    ConnectSave(ControlSize2, function()
        redzlib.Save.TabSize = MainScroll.Size.X.Offset
        SaveJson("rael hub with redz library.json", redzlib.Save)
    end)

    local ButtonsFolder = Create("Folder", TopBar, { Name = "Buttons" })
    local CloseButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -10, 0.5),
        AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1,
        Image = "rbxassetid://10747384394", AutoButtonColor = false, Name = "Close"
    })
    Make("Corner", CloseButton, UDim.new(0.5, 0)) -- round
    local MinimizeButton = SetProps(CloseButton:Clone(), {
        Position = UDim2.new(1, -35, 0.5), Image = "rbxassetid://10734896206", Name = "Minimize"
    })
    SetChildren(ButtonsFolder, { CloseButton, MinimizeButton })

    local Minimized, SaveSize, WaitClick
    local Window, FirstTab = {}, false

    function Window:SetBackgroundImage(imageId, transparency)
        MainFrame.Image = imageId or ""
        if transparency ~= nil then MainFrame.ImageTransparency = transparency end
    end
    function Window:SetBackgroundTransparency(transparency) MainFrame.ImageTransparency = transparency end
    function Window:SetKeybind(value) if value and typeof(value) == "string" then ButtonTarget = value end end
    function Window:CloseBtn()
        local Dialog = Window:Dialog({ Title = "Close", Text = "Are you sure you want to close this script??", Options = { { "Confirm", function() ScreenGui:Destroy() end }, { "Cancel" } } })
    end
    function Window:MinimizeBtn()
        if WaitClick then return end
        WaitClick = true
        if Minimized then
            MinimizeButton.Image = "rbxassetid://10734896206"
            CreateTween({ MinimizeButton, "Rotation", 0, 0.25, Easing = Enum.EasingStyle.Expo })
            CreateTween({ MainFrame, "Size", SaveSize, 0.3, true, Easing = Enum.EasingStyle.Expo })
            ControlSize1.Visible = true
            ControlSize2.Visible = true
            Minimized = false
        else
            MinimizeButton.Image = "rbxassetid://10734924532"
            CreateTween({ MinimizeButton, "Rotation", 180, 0.25, Easing = Enum.EasingStyle.Expo })
            SaveSize = MainFrame.Size
            ControlSize1.Visible = false
            ControlSize2.Visible = false
            CreateTween({ MainFrame, "Size", UDim2.fromOffset(MainFrame.Size.X.Offset, 28), 0.3, true, Easing = Enum.EasingStyle.Expo })
            Minimized = true
        end
        WaitClick = false
    end
    function Window:Minimize() MainFrame.Visible = not MainFrame.Visible end
    function Window:AddMinimizeButton(Configs)
        local Button = MakeDrag(Create("ImageButton", ScreenGui, { Size = UDim2.fromOffset(50, 50), Position = UDim2.fromScale(0.15, 0.15), BackgroundTransparency = 1, BackgroundColor3 = Theme["Color Hub 2"], AutoButtonColor = false }), function() MainFrame.Visible = not MainFrame.Visible end)
        local Stroke, Corner
        if Configs.Corner then Corner = Make("Corner", Button); SetProps(Corner, Configs.Corner) end
        if Configs.Stroke then Stroke = Make("Stroke", Button); SetProps(Stroke, Configs.Stroke) end
        SetProps(Button, Configs.Button)
        return { Stroke = Stroke, Corner = Corner, Button = Button }
    end
    function Window:Set(Val1, Val2)
        if type(Val1) == "string" and type(Val2) == "string" then Title.Text = Val1; Title.SubTitle.Text = Val2
        elseif type(Val1) == "string" then Title.Text = Val1 end
    end
    function Window:Dialog(Configs)
        if MainFrame:FindFirstChild("Dialog") then return end
        if Minimized then Window:MinimizeBtn() end
        local DTitle = Configs[1] or Configs.Title or "Dialog"
        local DText = Configs[2] or Configs.Text or "This is a Dialog"
        local DOptions = Configs[3] or Configs.Options or {}
        local Frame = Create("Frame", { Active = true, Size = UDim2.fromOffset(250 * 1.08, 150 * 1.08), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5) }, {
            InsertTheme(Create("TextLabel", { Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 20), Text = DTitle, TextXAlignment = "Left", TextColor3 = Theme["Color Text"], TextSize = 15, Position = UDim2.fromOffset(15, 5), BackgroundTransparency = 1 }), "Text"),
            InsertTheme(Create("TextLabel", { Font = Enum.Font.GothamMedium, Size = UDim2.new(1, -25), AutomaticSize = "Y", Text = DText, TextXAlignment = "Left", TextColor3 = Theme["Color Dark Text"], TextSize = 12, Position = UDim2.fromOffset(15, 25), BackgroundTransparency = 1, TextWrapped = true }), "DarkText")
        })
        Make("Gradient", Frame, { Rotation = 270 }); Make("Corner", Frame)
        local ButtonsHolder = Create("Frame", Frame, { Size = UDim2.fromScale(1, 0.35), Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme["Color Hub 2"], BackgroundTransparency = 1 }, {
            Create("UIListLayout", { Padding = UDim.new(0, 10), VerticalAlignment = "Center", FillDirection = "Horizontal", HorizontalAlignment = "Center" })
        })
        local Screen = InsertTheme(Create("Frame", MainFrame, { BackgroundTransparency = 0.6, Active = true, BackgroundColor3 = Theme["Color Hub 2"], Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme["Color Stroke"], Name = "Dialog" }), "Stroke")
        MainCorner:Clone().Parent = Screen
        Frame.Parent = Screen
        CreateTween({ Frame, "Size", UDim2.fromOffset(250, 150), 0.2, Easing = Enum.EasingStyle.Expo })
        CreateTween({ Frame, "Transparency", 0, 0.15 })
        CreateTween({ Screen, "Transparency", 0.3, 0.15 })
        local ButtonCount, Dialog = 1, {}
        function Dialog:Button(Configs)
            local Name = Configs[1] or Configs.Name or Configs.Title or ""
            local Callback = Configs[2] or Configs.Callback or function() end
            ButtonCount = ButtonCount + 1
            local Button = Make("Button", ButtonsHolder)
            Make("Corner", Button)
            SetProps(Button, { Text = Name, Font = Enum.Font.GothamBold, TextColor3 = Theme["Color Text"], TextSize = 12 })
            for _, B in pairs(ButtonsHolder:GetChildren()) do if B:IsA("TextButton") then B.Size = UDim2.new(1 / ButtonCount, -(((ButtonCount - 1) * 20) / ButtonCount), 0, 32) end end
            Button.Activated:Connect(Dialog.Close)
            Button.Activated:Connect(Callback)
        end
        function Dialog:Close()
            CreateTween({ Frame, "Size", UDim2.fromOffset(250 * 1.08, 150 * 1.08), 0.2, Easing = Enum.EasingStyle.Expo })
            CreateTween({ Screen, "Transparency", 1, 0.15 })
            CreateTween({ Frame, "Transparency", 1, 0.15, true })
            Screen:Destroy()
        end
        table.foreach(DOptions, function(_, Button) Dialog:Button(Button) end)
        return Dialog
    end
    function Window:SelectTab(TabSelect)
        if type(TabSelect) == "number" then redzlib.Tabs[TabSelect].func:Enable()
        else for _, Tab in pairs(redzlib.Tabs) do if Tab.Cont == TabSelect.Cont then Tab.func:Enable() end end end
    end

    local ContainerList = {}
    function Window:MakeTab(paste, Configs)
        if type(paste) == "table" then Configs = paste end
        local TName = Configs[1] or Configs.Title or "Tab!"
        local TIcon = Configs[2] or Configs.Icon or ""
        TIcon = redzlib:GetIcon(TIcon)
        if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then TIcon = false end

        local TabSelect = Make("Button", MainScroll, { Size = UDim2.new(1, 0, 0, 24) })
        Make("Corner", TabSelect)

        local LabelTitle = InsertTheme(Create("TextLabel", TabSelect, {
            Size = UDim2.new(1, TIcon and -25 or -15, 1), Position = UDim2.fromOffset(TIcon and 25 or 15),
            BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = TName,
            TextColor3 = Theme["Color Text"], TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = (FirstTab and 0.3) or 0, TextTruncate = "AtEnd"
        }), "Text")

        local LabelIcon = InsertTheme(Create("ImageLabel", TabSelect, {
            Position = UDim2.new(0, 8, 0.5), Size = UDim2.new(0, 13, 0, 13), AnchorPoint = Vector2.new(0, 0.5),
            Image = TIcon or "", BackgroundTransparency = 1, ImageTransparency = (FirstTab and 0.3) or 0
        }), "Text")

        local Selected = InsertTheme(Create("Frame", TabSelect, {
            Size = FirstTab and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 4, 0, 13),
            Position = UDim2.new(0, 1, 0.5), AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme["Color Theme"], BackgroundTransparency = FirstTab and 1 or 0
        }), "Theme")
        Make("Corner", Selected, UDim.new(0.5, 0))

        local Container = InsertTheme(Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 1), AnchorPoint = Vector2.new(0, 1),
            ScrollBarThickness = 1.5, BackgroundTransparency = 1, ScrollBarImageTransparency = 0.2,
            ScrollBarImageColor3 = Theme["Color Theme"], AutomaticCanvasSize = "Y", ScrollingDirection = "Y",
            BorderSizePixel = 0, CanvasSize = UDim2.new(), Name = ("Container %i [ %s ]"):format(#ContainerList + 1, TName)
        }, {
            Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
            Create("UIListLayout", { Padding = UDim.new(0, 5) })
        }), "ScrollBar")
        table.insert(ContainerList, Container)
        if not FirstTab then Container.Parent = Containers end

        local function Tabs()
            if Container.Parent then return end
            for _, Frame in pairs(ContainerList) do if Frame:IsA("ScrollingFrame") and Frame ~= Container then Frame.Parent = nil end end
            Container.Parent = Containers
            Container.Size = UDim2.new(1, 0, 1, 150)
            table.foreach(redzlib.Tabs, function(_, Tab) if Tab.Cont ~= Container then Tab.func:Disable() end end)
            CreateTween({ Container, "Size", UDim2.new(1, 0, 1, 0), 0.3, Easing = Enum.EasingStyle.Quad })
            CreateTween({ LabelTitle, "TextTransparency", 0, 0.35, Easing = Enum.EasingStyle.Quad })
            CreateTween({ LabelIcon, "ImageTransparency", 0, 0.35, Easing = Enum.EasingStyle.Quad })
            CreateTween({ Selected, "Size", UDim2.new(0, 4, 0, 13), 0.35, Easing = Enum.EasingStyle.Quad })
            CreateTween({ Selected, "BackgroundTransparency", 0, 0.35, Easing = Enum.EasingStyle.Quad })
        end
        TabSelect.Activated:Connect(Tabs)

        FirstTab = true
        local Tab = {}
        table.insert(redzlib.Tabs, { TabInfo = { Name = TName, Icon = TIcon }, func = Tab, Cont = Container })
        Tab.Cont = Container

        function Tab:Disable()
            Container.Parent = nil
            CreateTween({ LabelTitle, "TextTransparency", 0.3, 0.35, Easing = Enum.EasingStyle.Quad })
            CreateTween({ LabelIcon, "ImageTransparency", 0.3, 0.35, Easing = Enum.EasingStyle.Quad })
            CreateTween({ Selected, "Size", UDim2.new(0, 4, 0, 4), 0.35, Easing = Enum.EasingStyle.Quad })
            CreateTween({ Selected, "BackgroundTransparency", 1, 0.35, Easing = Enum.EasingStyle.Quad })
        end
        function Tab:Enable() Tabs() end
        function Tab:Visible(Bool) Funcs:ToggleVisible(TabSelect, Bool); Funcs:ToggleParent(Container, Bool, Containers) end
        function Tab:Destroy() TabSelect:Destroy(); Container:Destroy() end

        -- Tab methods (AddSection, AddParagraph, etc.) - keep as original but with enhanced styling where needed
        function Tab:AddSection(Configs)
            local SectionName = type(Configs) == "string" and Configs or Configs[1] or Configs.Name or Configs.Title or Configs.Section
            local SectionFrame = Create("Frame", Container, { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Name = "Option" })
            local SectionLabel = InsertTheme(Create("TextLabel", SectionFrame, {
                Font = Enum.Font.GothamBold, Text = SectionName, TextColor3 = Theme["Color Text"],
                Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 5), BackgroundTransparency = 1,
                TextTruncate = "AtEnd", TextSize = 14, TextXAlignment = "Left"
            }), "Text")
            local Section = {}
            table.insert(redzlib.Options, { type = "Section", Name = SectionName, func = Section })
            function Section:Visible(Bool) if Bool == nil then SectionFrame.Visible = not SectionFrame.Visible else SectionFrame.Visible = Bool end end
            function Section:Destroy() SectionFrame:Destroy() end
            function Section:Set(New) if New then SectionLabel.Text = GetStr(New) end end
            return Section
        end
        function Tab:AddParagraph(Configs)
            local PName = Configs[1] or Configs.Title or "Paragraph"
            local PDesc = Configs[2] or Configs.Text or ""
            local Frame, LabelFunc = ButtonFrame(Container, PName, PDesc, UDim2.new(1, -20))
            local Paragraph = {}
            function Paragraph:Visible(...) Funcs:ToggleVisible(Frame, ...) end
            function Paragraph:Destroy() Frame:Destroy() end
            function Paragraph:SetTitle(Val) LabelFunc:SetTitle(GetStr(Val)) end
            function Paragraph:SetDesc(Val) LabelFunc:SetDesc(GetStr(Val)) end
            function Paragraph:Set(Val1, Val2) if Val1 and Val2 then LabelFunc:SetTitle(GetStr(Val1)); LabelFunc:SetDesc(GetStr(Val2)) elseif Val1 then LabelFunc:SetDesc(GetStr(Val1)) end end
            return Paragraph
        end
        function Tab:AddButton(Configs)
            local BName = Configs[1] or Configs.Name or Configs.Title or "Button!"
            local BDescription = Configs.Desc or Configs.Description or ""
            local Callback = Funcs:GetCallback(Configs, 2)
            local FButton, LabelFunc = ButtonFrame(Container, BName, BDescription, UDim2.new(1, -20))
            local ButtonIcon = Create("ImageLabel", FButton, {
                Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1, Image = "rbxassetid://10709791437"
            })
            FButton.Activated:Connect(function() Funcs:FireCallback(Callback) end)
            local Button = {}
            function Button:Visible(...) Funcs:ToggleVisible(FButton, ...) end
            function Button:Destroy() FButton:Destroy() end
            function Button:Callback(...) Funcs:InsertCallback(Callback, ...) end
            function Button:Set(Val1, Val2)
                if type(Val1) == "string" and type(Val2) == "string" then LabelFunc:SetTitle(Val1); LabelFunc:SetDesc(Val2)
                elseif type(Val1) == "string" then LabelFunc:SetTitle(Val1)
                elseif type(Val1) == "function" then Callback = Val1 end
            end
            return Button
        end
        function Tab:AddToggle(Configs)
            local TName = Configs[1] or Configs.Name or Configs.Title or "Toggle"
            local TDesc = Configs.Desc or Configs.Description or ""
            local Callback = Funcs:GetCallback(Configs, 3)
            local Flag = Configs[4] or Configs.Flag or false
            local Default = Configs[2] or Configs.Default or false
            if CheckFlag(Flag) then Default = GetFlag(Flag) end

            local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))

            local ToggleHolder = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 35, 0, 18), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Stroke"]
            }), "Stroke")
            Make("Corner", ToggleHolder, UDim.new(0.5, 0))

            local Slider = Create("Frame", ToggleHolder, {
                BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 0.8, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5)
            })

            local Toggle = InsertTheme(Create("Frame", Slider, {
                Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 0, 0.5), AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme["Color Theme"]
            }), "Theme")
            Make("Corner", Toggle, UDim.new(0.5, 0))

            -- Glow effect
            local ToggleGlow = Create("Frame", ToggleHolder, {
                Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1, BackgroundColor3 = Theme["Color Theme"], Visible = false
            })
            Make("Corner", ToggleGlow, UDim.new(0.5, 0))
            local GlowGradient = Instance.new("UIGradient")
            GlowGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Theme["Color Theme"]), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)) })
            GlowGradient.Parent = ToggleGlow

            local WaitClick
            local function SetToggle(Val)
                if WaitClick then return end
                WaitClick, Default = true, Val
                SetFlag(Flag, Default)
                Funcs:FireCallback(Callback, Default)
                if Default then
                    CreateTween({ Toggle, "Position", UDim2.new(1, 0, 0.5), 0.25, Easing = Enum.EasingStyle.Quad })
                    CreateTween({ Toggle, "BackgroundTransparency", 0, 0.25, Easing = Enum.EasingStyle.Quad })
                    CreateTween({ Toggle, "AnchorPoint", Vector2.new(1, 0.5), 0.25, Easing = Enum.EasingStyle.Quad })
                    TweenService:Create(ToggleGlow, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.5 }):Play()
                    ToggleGlow.Visible = true
                else
                    CreateTween({ Toggle, "Position", UDim2.new(0, 0, 0.5), 0.25, Easing = Enum.EasingStyle.Quad })
                    CreateTween({ Toggle, "BackgroundTransparency", 0.8, 0.25, Easing = Enum.EasingStyle.Quad })
                    CreateTween({ Toggle, "AnchorPoint", Vector2.new(0, 0.5), 0.25, Easing = Enum.EasingStyle.Quad })
                    TweenService:Create(ToggleGlow, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
                    task.delay(0.25, function() ToggleGlow.Visible = false end)
                end
                WaitClick = false
            end; task.spawn(SetToggle, Default)

            Button.Activated:Connect(function() SetToggle(not Default) end)

            local Toggle = {}
            function Toggle:Visible(...) Funcs:ToggleVisible(Button, ...) end
            function Toggle:Destroy() Button:Destroy() end
            function Toggle:Callback(...) Funcs:InsertCallback(Callback, ...)() end
            function Toggle:Set(Val1, Val2)
                if type(Val1) == "string" and type(Val2) == "string" then LabelFunc:SetTitle(Val1); LabelFunc:SetDesc(Val2)
                elseif type(Val1) == "string" then LabelFunc:SetTitle(Val1)
                elseif type(Val1) == "boolean" then
                    if WaitClick and Val2 then repeat task.wait() until not WaitClick end
                    task.spawn(SetToggle, Val1)
                elseif type(Val1) == "function" then Callback = Val1 end
            end
            return Toggle
        end
        function Tab:AddSlider(Configs)
            local SName = Configs[1] or Configs.Name or Configs.Title or "Slider!"
            local SDesc = Configs.Desc or Configs.Description or ""
            local Min = Configs[2] or Configs.MinValue or Configs.Min or 10
            local Max = Configs[3] or Configs.MaxValue or Configs.Max or 100
            local Increase = Configs[4] or Configs.Increase or 1
            local Callback = Funcs:GetCallback(Configs, 6)
            local Flag = Configs[7] or Configs.Flag or false
            local Default = Configs[5] or Configs.Default or 25
            if CheckFlag(Flag) then Default = GetFlag(Flag) end
            Min, Max = Min / Increase, Max / Increase

            local Button, LabelFunc = ButtonFrame(Container, SName, SDesc, UDim2.new(1, -180))

            local SliderHolder = Create("TextButton", Button, {
                Size = UDim2.new(0.45, 0, 1), Position = UDim2.new(1), AnchorPoint = Vector2.new(1, 0),
                AutoButtonColor = false, Text = "", BackgroundTransparency = 1
            })

            local SliderBar = InsertTheme(Create("Frame", SliderHolder, {
                BackgroundColor3 = Theme["Color Stroke"], Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0.5, 0, 0.5), AnchorPoint = Vector2.new(0.5, 0.5)
            }), "Stroke")
            Make("Corner", SliderBar)

            -- Gradient fill
            local FillGradient = Instance.new("UIGradient")
            FillGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Theme["Color Theme"]), ColorSequenceKeypoint.new(1, Theme["Color Theme"]:lerp(Color3.new(1,1,1), 0.5)) })
            FillGradient.Rotation = 90

            local Indicator = InsertTheme(Create("Frame", SliderBar, {
                BackgroundColor3 = Theme["Color Theme"], Size = UDim2.fromScale(0.3, 1), BorderSizePixel = 0
            }), "Theme")
            Make("Corner", Indicator)
            FillGradient.Parent = Indicator

            local SliderIcon = Create("Frame", SliderBar, {
                Size = UDim2.new(0, 8, 0, 16), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.fromScale(0.3, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 0, ZIndex = 2
            })
            Make("Corner", SliderIcon, UDim.new(0.5, 0))
            local IconStroke = Instance.new("UIStroke")
            IconStroke.Color = Theme["Color Theme"]
            IconStroke.Thickness = 1
            IconStroke.Parent = SliderIcon

            local LabelVal = InsertTheme(Create("TextLabel", SliderHolder, {
                Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(0, 0, 0.5),
                BackgroundTransparency = 1, TextColor3 = Theme["Color Text"], Font = Enum.Font.FredokaOne, TextSize = 12
            }), "Text")

            local UIScaleLabel = Create("UIScale", LabelVal)

            local BaseMousePos = Create("Frame", SliderBar, { Position = UDim2.new(0, 0, 0.5, 0), Visible = false })

            local function UpdateLabel(NewValue)
                local Number = tonumber(NewValue * Increase)
                Number = math.floor(Number * 100) / 100
                Default, LabelVal.Text = Number, tostring(Number)
                Funcs:FireCallback(Callback, Default)
            end

            local function ControlPos()
                local MousePos = Player:GetMouse()
                local APos = MousePos.X - BaseMousePos.AbsolutePosition.X
                local ConfigureDpiPos = APos / SliderBar.AbsoluteSize.X
                SliderIcon.Position = UDim2.new(math.clamp(ConfigureDpiPos, 0, 1), 0, 0.5, 0)
            end

            local function UpdateValues()
                Indicator.Size = UDim2.new(SliderIcon.Position.X.Scale, 0, 1, 0)
                local SliderPos = SliderIcon.Position.X.Scale
                local NewValue = math.floor(((SliderPos * Max) / Max) * (Max - Min) + Min)
                UpdateLabel(NewValue)
            end

            SliderHolder.MouseButton1Down:Connect(function()
                CreateTween({ SliderIcon, "Size", UDim2.new(0, 12, 0, 20), 0.2, Easing = Enum.EasingStyle.Quad })
                Container.ScrollingEnabled = false
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait(); ControlPos() end
                CreateTween({ SliderIcon, "Size", UDim2.new(0, 8, 0, 16), 0.2, Easing = Enum.EasingStyle.Quad })
                Container.ScrollingEnabled = true
                SetFlag(Flag, Default)
            end)

            LabelVal:GetPropertyChangedSignal("Text"):Connect(function()
                UIScaleLabel.Scale = 0.3
                CreateTween({ UIScaleLabel, "Scale", 1.2, 0.1, Easing = Enum.EasingStyle.Quad })
                CreateTween({ LabelVal, "Rotation", math.random(-1, 1) * 5, 0.15, true, Easing = Enum.EasingStyle.Quad })
                CreateTween({ UIScaleLabel, "Scale", 1, 0.2, Easing = Enum.EasingStyle.Quad })
                CreateTween({ LabelVal, "Rotation", 0, 0.1, Easing = Enum.EasingStyle.Quad })
            end)

            function SetSlider(NewValue)
                if type(NewValue) ~= "number" then return end
                local Min, Max = Min * Increase, Max * Increase
                local SliderPos = (NewValue - Min) / (Max - Min)
                SetFlag(Flag, NewValue)
                CreateTween({ SliderIcon, "Position", UDim2.fromScale(math.clamp(SliderPos, 0, 1), 0.5), 0.3, true, Easing = Enum.EasingStyle.Quad })
            end; SetSlider(Default)

            SliderIcon:GetPropertyChangedSignal("Position"):Connect(UpdateValues) UpdateValues()

            local Slider = {}
            function Slider:Set(NewVal1, NewVal2)
                if NewVal1 and NewVal2 then LabelFunc:SetTitle(NewVal1); LabelFunc:SetDesc(NewVal2)
                elseif type(NewVal1) == "string" then LabelFunc:SetTitle(NewVal1)
                elseif type(NewVal1) == "function" then Callback = NewVal1
                elseif type(NewVal1) == "number" then SetSlider(NewVal1) end
            end
            function Slider:Callback(...) Funcs:InsertCallback(Callback, ...)(tonumber(Default)) end
            function Slider:Visible(...) Funcs:ToggleVisible(Button, ...) end
            function Slider:Destroy() Button:Destroy() end
            return Slider
        end
        function Tab:AddTextBox(Configs)
            local TName = Configs[1] or Configs.Name or Configs.Title or "Text Box"
            local TDesc = Configs.Desc or Configs.Description or ""
            local TDefault = Configs[2] or Configs.Default or ""
            local TPlaceholderText = Configs[5] or Configs.PlaceholderText or "Input"
            local TClearText = Configs[3] or Configs.ClearText or false
            local Callback = Funcs:GetCallback(Configs, 4)

            if type(TDefault) ~= "string" or TDefault:gsub(" ", ""):len() < 1 then TDefault = false end

            local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))

            local SelectedFrame = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 150, 0, 18), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Stroke"]
            }), "Stroke")
            Make("Corner", SelectedFrame, UDim.new(0, 4))

            local TextBoxInput = InsertTheme(Create("TextBox", SelectedFrame, {
                Size = UDim2.new(0.85, 0, 0.85, 0), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextScaled = true,
                TextColor3 = Theme["Color Text"], ClearTextOnFocus = TClearText,
                PlaceholderText = TPlaceholderText, Text = ""
            }), "Text")

            local Pencil = Create("ImageLabel", SelectedFrame, {
                Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, -5, 0.5), AnchorPoint = Vector2.new(1, 0.5),
                Image = "rbxassetid://15637081879", BackgroundTransparency = 1
            })

            local TextBox = {}
            local function Input()
                local Text = TextBoxInput.Text
                if Text:gsub(" ", ""):len() > 0 then
                    if type(TextBox.OnChanging) == "function" then Text = TextBox.OnChanging(Text) or Text end
                    Funcs:FireCallback(Callback, Text)
                    TextBoxInput.Text = Text
                end
            end

            TextBoxInput.FocusLost:Connect(Input) Input()

            TextBoxInput.FocusLost:Connect(function() CreateTween({ Pencil, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2, Easing = Enum.EasingStyle.Quad }) end)
            TextBoxInput.Focused:Connect(function() CreateTween({ Pencil, "ImageColor3", Theme["Color Theme"], 0.2, Easing = Enum.EasingStyle.Quad }) end)

            TextBox.OnChanging = false
            function TextBox:Visible(...) Funcs:ToggleVisible(Button, ...) end
            function TextBox:Destroy() Button:Destroy() end
            return TextBox
        end
        function Tab:AddKeybind(Configs)
            local KName = Configs[1] or Configs.Name or Configs.Title or "Keybind"
            local KDesc = Configs[2] or Configs.Desc or Configs.Description or ""
            local KValue = Configs[3] or Configs.Value or "..."
            local Callback = Configs[4] or Configs.Callback or function() end

            local Button, LabelFunc = ButtonFrame(Container, KName, KDesc, UDim2.new(1, -38))

            local ButtonTarget = KValue
            local NoCanActive = false

            local SelectedFrame = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 80, 0, 18), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Stroke"]
            }), "Stroke")
            Make("Corner", SelectedFrame, UDim.new(0, 4))

            local keybindTextLabel = InsertTheme(Create("TextLabel", SelectedFrame, {
                Size = UDim2.new(0.85, 0, 0.85, 0), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextScaled = true,
                TextColor3 = Theme["Color Text"], Text = KValue
            }), "Text")

            local ConnectionKeybind = Funcs:SetConnection({ "InputBegan", UserInputService, true }):Connect(function(input)
                local success, result = pcall(function() return input.KeyCode == Enum.KeyCode[ButtonTarget] end)
                if success and result and not NoCanActive then Callback(ButtonTarget) end
            end)

            Button.MouseButton1Click:Connect(function()
                local DetectionConnection
                keybindTextLabel.Text = "..."
                DetectionConnection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local NewButtonTarget = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                        NoCanActive = true
                        ButtonTarget = NewButtonTarget
                        keybindTextLabel.Text = NewButtonTarget
                        task.wait(0.1)
                        if DetectionConnection then
                            NoCanActive = false
                            DetectionConnection:Disconnect()
                            DetectionConnection = nil
                        end
                    end
                end)
            end)

            local Keybind = {}
            function Keybind:SetKeybind(value)
                local NewButtonTarget = tostring(value):gsub("Enum.KeyCode.", "")
                ButtonTarget = NewButtonTarget
                keybindTextLabel.Text = NewButtonTarget
            end
            function Keybind:Destroy()
                if ConnectionKeybind then ConnectionKeybind:Disconnect(); ConnectionKeybind = nil end
                Button:Destroy()
            end
            return Keybind
        end
        function Tab:AddImageButton(Configs)
            local Name = Configs[1] or Configs.Name or "Image Button"
            local ImageId = Configs[2] or Configs.Image or ""
            local Description = Configs.Desc or Configs.Description or ""
            local Callback = Configs[3] or Configs.Callback or function() end

            local Frame = Create("Frame", Container, { Size = UDim2.new(1, 0, 0, 80), BackgroundTransparency = 1, Name = "Option" })

            local ImageButton = Create("ImageButton", Frame, {
                Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0, 5, 0.5), AnchorPoint = Vector2.new(0, 0.5),
                Image = ImageId, BackgroundColor3 = Theme["Color Hub 2"], AutoButtonColor = false, ScaleType = Enum.ScaleType.Crop
            })
            Make("Corner", ImageButton, UDim.new(0, 8))
            Make("Stroke", ImageButton)
            -- Glow on hover
            local GlowStroke = Make("GlowStroke", ImageButton, { Transparency = 0.7, Thickness = 2 })
            ImageButton.MouseEnter:Connect(function() TweenService:Create(GlowStroke, TweenInfo.new(0.2), { Transparency = 0.3 }):Play() end)
            ImageButton.MouseLeave:Connect(function() TweenService:Create(GlowStroke, TweenInfo.new(0.2), { Transparency = 0.7 }):Play() end)

            local TextHolder = Create("Frame", Frame, {
                Size = UDim2.new(1, -80, 0, 60), Position = UDim2.new(0, 70, 0.5), AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", { Padding = UDim.new(0, 2), VerticalAlignment = "Center", SortOrder = "LayoutOrder" })
            })

            local TitleLabel = InsertTheme(Create("TextLabel", TextHolder, {
                Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamBold, Text = Name,
                TextColor3 = Theme["Color Text"], BackgroundTransparency = 1, TextXAlignment = "Left", TextSize = 14
            }), "Text")

            local DescLabel = InsertTheme(Create("TextLabel", TextHolder, {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y", Font = Enum.Font.Gotham,
                Text = Description, TextColor3 = Theme["Color Dark Text"], BackgroundTransparency = 1,
                TextXAlignment = "Left", TextSize = 10, TextWrapped = true
            }), "DarkText")

            ImageButton.Activated:Connect(Callback)

            local ImageButtonObj = {}
            function ImageButtonObj:Visible(...) Funcs:ToggleVisible(Frame, ...) end
            function ImageButtonObj:Destroy() Frame:Destroy() end
            return ImageButtonObj
        end
        function Tab:AddDiscordInvite(Configs)
            local Title = Configs[1] or Configs.Name or Configs.Title or "Discord"
            local Desc = Configs.Desc or Configs.Description or ""
            local Logo = Configs[2] or Configs.Logo or ""
            local Invite = Configs[3] or Configs.Invite or ""

            local InviteHolder = Create("Frame", Container, { Size = UDim2.new(1, 0, 0, 80), Name = "Option", BackgroundTransparency = 1 })

            local InviteLabel = Create("TextLabel", InviteHolder, {
                Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 5), TextColor3 = Color3.fromRGB(40, 150, 255),
                Font = Enum.Font.GothamBold, TextXAlignment = "Left", BackgroundTransparency = 1, TextSize = 10, Text = Invite
            })

            local FrameHolder = InsertTheme(Create("Frame", InviteHolder, {
                Size = UDim2.new(1, 0, 0, 65), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1),
                BackgroundColor3 = Theme["Color Hub 2"]
            }), "Frame")
            Make("Corner", FrameHolder)

            local ImageLabel = Create("ImageLabel", FrameHolder, {
                Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 7, 0, 7), Image = Logo, BackgroundTransparency = 1
            })
            Make("Corner", ImageLabel, UDim.new(0, 4))
            Make("Stroke", ImageLabel)

            local LTitle = InsertTheme(Create("TextLabel", FrameHolder, {
                Size = UDim2.new(1, -52, 0, 15), Position = UDim2.new(0, 44, 0, 7), Font = Enum.Font.GothamBold,
                TextColor3 = Theme["Color Text"], TextXAlignment = "Left", BackgroundTransparency = 1, TextSize = 10, Text = Title
            }), "Text")

            local LDesc = InsertTheme(Create("TextLabel", FrameHolder, {
                Size = UDim2.new(1, -52, 0, 0), Position = UDim2.new(0, 44, 0, 22), TextWrapped = "Y", AutomaticSize = "Y",
                Font = Enum.Font.Gotham, TextColor3 = Theme["Color Dark Text"], TextXAlignment = "Left",
                BackgroundTransparency = 1, TextSize = 8, Text = Desc
            }), "DarkText")

            local JoinButton = Create("TextButton", FrameHolder, {
                Size = UDim2.new(1, -14, 0, 16), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -7),
                Text = "Join", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(220, 220, 220),
                BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            })
            Make("Corner", JoinButton, UDim.new(0, 5))

            local ClickDelay
            JoinButton.Activated:Connect(function()
                setclipboard(Invite)
                if ClickDelay then return end
                ClickDelay = true
                SetProps(JoinButton, { Text = "Copied to Clipboard", BackgroundColor3 = Color3.fromRGB(100, 100, 100), TextColor3 = Color3.fromRGB(150, 150, 150) })
                task.wait(5)
                SetProps(JoinButton, { Text = "Join", BackgroundColor3 = Color3.fromRGB(50, 150, 50), TextColor3 = Color3.fromRGB(220, 220, 220) })
                ClickDelay = false
            end)

            local DiscordInvite = {}
            function DiscordInvite:Destroy() InviteHolder:Destroy() end
            function DiscordInvite:Visible(...) Funcs:ToggleVisible(InviteHolder, ...) end
            return DiscordInvite
        end
        function Tab:AddUserRoblox(Configs)
            local Name = Configs[1] or Configs.Name or "Roblox"
            local Username = Configs[2] or Configs.Username or "Roblox"
            local Desc = Configs[3] or Configs.Desc or Configs.Description or ""
            local UserId = Username and typeof(Username) == "string" and Players:GetUserIdFromNameAsync(Username)
            local ImageId = UserId and typeof(UserId) == "number" and Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

            local Holder = Create("Frame", Container, { Name = "Option", Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1 })
            local FrameHolder = InsertTheme(Create("Frame", Holder, {
                Size = UDim2.new(1, 0, 0, 45), AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 0, 0),
                BackgroundColor3 = Theme["Color Hub 2"]
            }), "Frame")
            Make("Corner", FrameHolder)

            if ImageId then
                local ImageLabel = Create("ImageLabel", FrameHolder, {
                    Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 7, 0, 7), Image = ImageId, BackgroundTransparency = 1
                }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
            end

            local LTitle = InsertTheme(Create("TextLabel", FrameHolder, {
                Size = UDim2.new(1, -52, 0, 15), Position = ImageId and UDim2.new(0, 44, 0, 7) or UDim2.new(0, 7, 0, 7),
                Font = Enum.Font.GothamBold, TextColor3 = Theme["Color Text"], TextXAlignment = "Left",
                BackgroundTransparency = 1, TextSize = 10, Text = Name
            }), "Text")

            local LDesc = InsertTheme(Create("TextLabel", FrameHolder, {
                Size = UDim2.new(1, -52, 0, 0), Position = UDim2.new(0, 44, 0, 22), TextWrapped = "Y", AutomaticSize = "Y",
                Font = Enum.Font.Gotham, TextColor3 = Theme["Color Dark Text"], TextXAlignment = "Left",
                BackgroundTransparency = 1, TextSize = 8, Text = Desc
            }), "DarkText")
        end

        return Tab
    end

    CloseButton.Activated:Connect(Window.CloseBtn)
    MinimizeButton.Activated:Connect(Window.MinimizeBtn)
    return Window
end

shared.redzlib.lib = redzlib
return redzlib