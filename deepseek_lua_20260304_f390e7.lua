-- Nexus Library V2 - Modern UI Framework
-- by: Tanwen

local Nexus = {
    Themes = {
        Default = {
            Background = Color3.fromRGB(10, 10, 15),
            Surface = Color3.fromRGB(20, 20, 30),
            Primary = Color3.fromRGB(100, 150, 255),
            Secondary = Color3.fromRGB(150, 100, 255),
            Text = Color3.fromRGB(240, 240, 255),
            TextDark = Color3.fromRGB(180, 180, 200),
            Stroke = Color3.fromRGB(255, 255, 255),
            Glow = Color3.fromRGB(100, 150, 255),
            Gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 50)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 60, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 30, 50))
            })
        },
        Dark = {
            Background = Color3.fromRGB(5, 5, 10),
            Surface = Color3.fromRGB(15, 15, 25),
            Primary = Color3.fromRGB(200, 50, 100),
            Secondary = Color3.fromRGB(150, 0, 150),
            Text = Color3.fromRGB(255, 200, 220),
            TextDark = Color3.fromRGB(200, 150, 170),
            Stroke = Color3.fromRGB(200, 200, 200),
            Glow = Color3.fromRGB(200, 50, 100),
            Gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 10, 20)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 20, 40)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 20))
            })
        }
    },
    Info = {
        Version = "2.0.0"
    },
    Save = {
        UISize = {600, 400},
        TabSize = 160,
        Theme = "Default"
    },
    Settings = {},
    Connections = {},
    Instances = {},
    Elements = {},
    Flags = {},
    Tabs = {},
    Icons = {} -- (você pode adicionar ícones depois, igual nas outras)
}

local Services = setmetatable({}, {
    __index = function(_, k)
        return game:GetService(k)
    end
})

local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local RunService = Services.RunService
local CoreGui = Services.CoreGui
local Players = Services.Players
local Player = Players.LocalPlayer

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScaleFactor = ViewportSize.Y / 450

-- Funções auxiliares
local function DeepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function MergeTables(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

local function GetColor(instance)
    if instance:IsA("Frame") or instance:IsA("TextButton") then
        return "BackgroundColor3"
    elseif instance:IsA("TextLabel") or instance:IsA("TextBox") then
        return "TextColor3"
    elseif instance:IsA("ImageLabel") then
        return "ImageColor3"
    elseif instance:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    elseif instance:IsA("UIStroke") then
        return "Color"
    end
    return ""
end

local function CreateTween(config)
    local instance = config.Instance or config[1]
    local prop = config.Prop or config[2]
    local newVal = config.NewVal or config[3]
    local time = config.Time or config[4] or 0.3
    local wait = config.Wait or config[5] or false
    local easing = config.Easing or Enum.EasingStyle.Quint
    local tweenInfo = TweenInfo.new(time, easing)
    local tween = TweenService:Create(instance, tweenInfo, {[prop] = newVal})
    tween:Play()
    if wait then
        tween.Completed:Wait()
    end
    return tween
end

-- Sistema de temas
function Nexus:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    self.Save.Theme = themeName
    self:SaveConfig()
    local theme = self.Themes[themeName]
    for _, data in ipairs(self.Instances) do
        local inst = data.Instance
        local type = data.Type
        if type == "Background" then
            inst.BackgroundColor3 = theme.Background
        elseif type == "Surface" then
            inst.BackgroundColor3 = theme.Surface
        elseif type == "Primary" then
            inst[GetColor(inst)] = theme.Primary
        elseif type == "Secondary" then
            inst[GetColor(inst)] = theme.Secondary
        elseif type == "Text" then
            inst[GetColor(inst)] = theme.Text
        elseif type == "TextDark" then
            inst[GetColor(inst)] = theme.TextDark
        elseif type == "Stroke" then
            inst[GetColor(inst)] = theme.Stroke
        elseif type == "Glow" then
            inst[GetColor(inst)] = theme.Glow
        elseif type == "Gradient" then
            inst.Color = theme.Gradient
        end
    end
    self.Connection:Fire("ThemeChanged", themeName)
end

-- Salvamento
function Nexus:SaveConfig()
    if writefile then
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, self.Save)
        if success then
            writefile("NexusConfig.json", encoded)
        end
    end
end

function Nexus:LoadConfig()
    if readfile and isfile and isfile("NexusConfig.json") then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile("NexusConfig.json"))
        if success and type(decoded) == "table" then
            self.Save = MergeTables(self.Save, decoded)
        end
    end
end

Nexus:LoadConfig()

-- Sistema de eventos
local Connections = {}
Nexus.Connection = {
    Fire = function(_, event, ...)
        if Connections[event] then
            for _, func in ipairs(Connections[event]) do
                task.spawn(func, ...)
            end
        end
    end,
    Connect = function(_, event, func)
        Connections[event] = Connections[event] or {}
        table.insert(Connections[event], func)
        return {
            Disconnect = function()
                table.remove(Connections[event], table.find(Connections[event], func))
            end
        }
    end
}

-- Funções de criação de instâncias
function Nexus:Create(class, props, children)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

function Nexus:InsertThemeInstance(instance, typeName)
    table.insert(self.Instances, {Instance = instance, Type = typeName})
    return instance
end

-- Elementos base
function Nexus:AddElement(name, func)
    self.Elements[name] = func
end

Nexus:AddElement("Corner", function(parent, radius)
    return Nexus:Create("UICorner", {CornerRadius = radius or UDim.new(0, 8)})
end)

Nexus:AddElement("Stroke", function(parent, color, thickness)
    return Nexus:InsertThemeInstance(Nexus:Create("UIStroke", {
        Color = color or Nexus.Themes[Nexus.Save.Theme].Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = "Border"
    }), "Stroke")
end)

Nexus:AddElement("Gradient", function(parent, rotation)
    return Nexus:InsertThemeInstance(Nexus:Create("UIGradient", {
        Color = Nexus.Themes[Nexus.Save.Theme].Gradient,
        Rotation = rotation or 0
    }), "Gradient")
end)

Nexus:AddElement("Shadow", function(parent, transparency, size)
    local shadow = Nexus:Create("ImageLabel", {
        Size = UDim2.new(1, size or 20, 1, size or 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843", -- shadow asset
        ImageTransparency = transparency or 0.5,
        ScaleType = "Slice",
        SliceCenter = Rect.new(10, 10, 118, 118)
    })
    shadow.Parent = parent
    return shadow
end)

-- Função de arrastar
local function MakeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X / UIScaleFactor, startPos.Y.Scale, startPos.Y.Offset + delta.Y / UIScaleFactor)
            frame.Position = newPos
        end
    end)
end

-- Criação da ScreenGui
local ScreenGui = Nexus:Create("ScreenGui", {
    Name = "NexusLibraryV2",
    Parent = CoreGui,
    ResetOnSpawn = false,
    ZIndexBehavior = "Sibling"
}, {
    Nexus:Create("UIScale", {Scale = UIScaleFactor})
})

-- Se já existir, destruir
local old = CoreGui:FindFirstChild("NexusLibraryV2")
if old and old ~= ScreenGui then
    old:Destroy()
end

-- Função principal para criar janela
function Nexus:MakeWindow(config)
    config = config or {}
    local title = config.Title or "Nexus Library"
    local subtitle = config.Subtitle or "v"..self.Info.Version
    local saveFolder = config.SaveFolder or false

    self.Settings.ScriptFile = saveFolder

    -- Carregar flags se houver arquivo
    if saveFolder and readfile and isfile then
        local success, data = pcall(readfile, saveFolder)
        if success then
            local decoded = pcall(HttpService.JSONDecode, HttpService, data) and data or {}
            self.Flags = decoded
        end
    end

    local sizeX, sizeY = unpack(self.Save.UISize)

    -- Main frame
    local Main = Nexus:InsertThemeInstance(Nexus:Create("ImageButton", {
        Size = UDim2.fromOffset(sizeX, sizeY),
        Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2),
        BackgroundTransparency = 1,
        Name = "MainWindow",
        AutoButtonColor = false,
        Active = true,
        Parent = ScreenGui
    }), "Background")

    -- Background blur effect
    local backgroundBlur = Nexus:Create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://3570695787",
        ScaleType = "Slice",
        SliceCenter = Rect.new(100, 100, 100, 100),
        ImageTransparency = 0.4,
        BackgroundTransparency = 1
    })
    backgroundBlur.Parent = Main

    -- Gradient overlay
    local gradient = Nexus:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })
    Nexus:AddElement("Gradient", gradient, 45)
    gradient.Parent = Main

    -- Shadow
    Nexus:AddElement("Shadow", Main, 0.7, 30)

    -- Corner
    Nexus:AddElement("Corner", Main, UDim.new(0, 12))

    -- Stroke
    local stroke = Nexus:AddElement("Stroke", Main, nil, 1.5)

    -- Título
    local TopBar = Nexus:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local TitleLabel = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = "Left",
        TextColor3 = Nexus.Themes[Nexus.Save.Theme].Text
    }), "Text")

    local SubtitleLabel = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = subtitle,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = "Left",
        TextColor3 = Nexus.Themes[Nexus.Save.Theme].TextDark
    }), "TextDark")

    TitleLabel.Parent = TopBar
    SubtitleLabel.Parent = TopBar

    -- Botões de janela
    local ButtonHolder = Nexus:Create("Frame", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Parent = TopBar
    })

    local CloseButton = Nexus:Create("ImageButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10747384394", -- X icon
        ImageColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
        Parent = ButtonHolder
    })

    local MinimizeButton = Nexus:Create("ImageButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734896206", -- minus icon
        ImageColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
        Parent = ButtonHolder
    })

    -- Abas e containers
    local TabScroll = Nexus:InsertThemeInstance(Nexus:Create("ScrollingFrame", {
        Size = UDim2.new(0, self.Save.TabSize, 1, -35),
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Nexus.Themes[Nexus.Save.Theme].Primary,
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        BorderSizePixel = 0,
        Parent = Main
    }), "Primary")

    local UIListLayout = Nexus:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = "LayoutOrder"
    })
    UIListLayout.Parent = TabScroll

    local UIPadding = Nexus:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    UIPadding.Parent = TabScroll

    local ContainerFrame = Nexus:Create("Frame", {
        Size = UDim2.new(1, -self.Save.TabSize, 1, -35),
        Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Main
    })

    -- Controles de redimensionamento
    local ResizeControl = Nexus:Create("ImageButton", {
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -10, 1, -10),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10747384552", -- zoom in icon
        ImageColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
        Parent = Main,
        ZIndex = 10
    })

    -- Tabs container list
    local containerList = {}
    local firstTab = true

    -- Função para criar abas
    local Window = {}
    function Window:MakeTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local icon = config.Icon or ""

        -- Botão da aba
        local TabButton = Nexus:InsertThemeInstance(Nexus:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Surface,
            AutoButtonColor = false,
            Text = "",
            Parent = TabScroll
        }), "Surface")
        Nexus:AddElement("Corner", TabButton, UDim.new(0, 6))
        Nexus:AddElement("Stroke", TabButton, nil, 0.5)

        -- Ícone
        local IconLabel
        if icon ~= "" then
            IconLabel = Nexus:Create("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
                Parent = TabButton
            })
        end

        -- Nome
        local NameLabel = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
            Size = UDim2.new(1, icon and -30 or -15, 1, 0),
            Position = UDim2.new(0, icon and 30 or 15, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = "Left",
            TextColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
            Parent = TabButton
        }), "Text")

        -- Indicador de seleção
        local SelectedIndicator = Nexus:InsertThemeInstance(Nexus:Create("Frame", {
            Size = firstTab and UDim2.new(0, 4, 0, 20) or UDim2.new(0, 4, 0, 4),
            Position = UDim2.new(1, -6, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Primary,
            BackgroundTransparency = firstTab and 0 or 0.5,
            Parent = TabButton
        }), "Primary")
        Nexus:AddElement("Corner", SelectedIndicator, UDim.new(0.5, 0))

        -- Container da aba
        local Container = Nexus:InsertThemeInstance(Nexus:Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Nexus.Themes[Nexus.Save.Theme].Primary,
            AutomaticCanvasSize = "Y",
            ScrollingDirection = "Y",
            BorderSizePixel = 0,
            Visible = firstTab,
            Parent = ContainerFrame
        }), "Primary")

        local ContainerLayout = Nexus:Create("UIListLayout", {Padding = UDim.new(0, 8)})
        ContainerLayout.Parent = Container

        local ContainerPadding = Nexus:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        })
        ContainerPadding.Parent = Container

        table.insert(containerList, Container)

        -- Função de seleção
        local function Select()
            for _, c in ipairs(containerList) do
                c.Visible = (c == Container)
            end
            for _, btn in ipairs(TabScroll:GetChildren()) do
                if btn:IsA("TextButton") then
                    local ind = btn:FindFirstChildOfClass("Frame")
                    if ind then
                        CreateTween({ind, "Size", UDim2.new(0, 4, 0, 4), 0.2})
                        CreateTween({ind, "BackgroundTransparency", 0.5, 0.2})
                    end
                end
            end
            CreateTween({SelectedIndicator, "Size", UDim2.new(0, 4, 0, 20), 0.2})
            CreateTween({SelectedIndicator, "BackgroundTransparency", 0, 0.2})
        end

        TabButton.MouseButton1Click:Connect(Select)

        if firstTab then
            firstTab = false
        end

        local Tab = {
            Container = Container,
            Button = TabButton
        }

        -- Métodos da aba
        function Tab:AddSection(config)
            local sectionName = config.Name or "Section"
            local section = Nexus:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Parent = Container
            })
            local label = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                Size = UDim2.new(1, -5, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = "Left",
                TextColor3 = Nexus.Themes[Nexus.Save.Theme].Primary
            }), "Primary")
            label.Parent = section
            return section
        end

        function Tab:AddButton(config)
            local name = config.Name or "Button"
            local desc = config.Desc or ""
            local callback = config.Callback or function() end

            local button = Nexus:InsertThemeInstance(Nexus:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Surface,
                AutoButtonColor = false,
                Text = "",
                Parent = Container
            }), "Surface")
            Nexus:AddElement("Corner", button, UDim.new(0, 8))
            Nexus:AddElement("Stroke", button, nil, 0.5)

            local title = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                Size = UDim2.new(1, -10, 0.5, -5),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = "Left",
                TextColor3 = Nexus.Themes[Nexus.Save.Theme].Text
            }), "Text")
            title.Parent = button

            if desc ~= "" then
                local description = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                    Size = UDim2.new(1, -10, 0.5, -5),
                    Position = UDim2.new(0, 10, 0.5, 0),
                    BackgroundTransparency = 1,
                    Text = desc,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = "Left",
                    TextColor3 = Nexus.Themes[Nexus.Save.Theme].TextDark
                }), "TextDark")
                description.Parent = button
                title.Size = UDim2.new(1, -10, 0.5, -5)
            else
                title.Size = UDim2.new(1, -10, 1, 0)
            end

            button.MouseButton1Click:Connect(callback)

            -- Hover effect
            button.MouseEnter:Connect(function()
                CreateTween({button, "BackgroundColor3", Nexus.Themes[Nexus.Save.Theme].Primary, 0.2})
            end)
            button.MouseLeave:Connect(function()
                CreateTween({button, "BackgroundColor3", Nexus.Themes[Nexus.Save.Theme].Surface, 0.2})
            end)

            return button
        end

        function Tab:AddToggle(config)
            local name = config.Name or "Toggle"
            local desc = config.Desc or ""
            local flag = config.Flag
            local default = config.Default or false
            local callback = config.Callback or function() end

            if flag and Nexus.Flags[flag] ~= nil then
                default = Nexus.Flags[flag]
            end

            local toggleFrame = Nexus:InsertThemeInstance(Nexus:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Surface,
                Parent = Container
            }), "Surface")
            Nexus:AddElement("Corner", toggleFrame, UDim.new(0, 8))
            Nexus:AddElement("Stroke", toggleFrame, nil, 0.5)

            local title = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                Size = UDim2.new(0.7, -10, 0.5, -5),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = "Left",
                TextColor3 = Nexus.Themes[Nexus.Save.Theme].Text
            }), "Text")
            title.Parent = toggleFrame

            if desc ~= "" then
                local description = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                    Size = UDim2.new(0.7, -10, 0.5, -5),
                    Position = UDim2.new(0, 10, 0.5, 0),
                    BackgroundTransparency = 1,
                    Text = desc,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = "Left",
                    TextColor3 = Nexus.Themes[Nexus.Save.Theme].TextDark
                }), "TextDark")
                description.Parent = toggleFrame
                title.Size = UDim2.new(0.7, -10, 0.5, -5)
            else
                title.Size = UDim2.new(0.7, -10, 1, 0)
            end

            -- Toggle switch
            local switch = Nexus:Create("Frame", {
                Size = UDim2.new(0, 50, 0, 24),
                Position = UDim2.new(1, -60, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Primary,
                BackgroundTransparency = 0.5,
                Parent = toggleFrame
            })
            Nexus:AddElement("Corner", switch, UDim.new(0.5, 0))

            local knob = Nexus:Create("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(default and 1 or 0, default and -2 or 2, 0.5, 0),
                AnchorPoint = Vector2.new(default and 1 or 0, 0.5),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
                Parent = switch
            })
            Nexus:AddElement("Corner", knob, UDim.new(0.5, 0))

            local function setState(state)
                if state then
                    CreateTween({knob, "Position", UDim2.new(1, -2, 0.5, 0), 0.2})
                    CreateTween({knob, "AnchorPoint", Vector2.new(1, 0.5), 0.2})
                    CreateTween({switch, "BackgroundTransparency", 0, 0.2})
                else
                    CreateTween({knob, "Position", UDim2.new(0, 2, 0.5, 0), 0.2})
                    CreateTween({knob, "AnchorPoint", Vector2.new(0, 0.5), 0.2})
                    CreateTween({switch, "BackgroundTransparency", 0.5, 0.2})
                end
                if flag then
                    Nexus.Flags[flag] = state
                end
                callback(state)
            end

            local toggled = default
            setState(toggled)

            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggled = not toggled
                    setState(toggled)
                end
            end)

            return toggleFrame
        end

        function Tab:AddSlider(config)
            local name = config.Name or "Slider"
            local desc = config.Desc or ""
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or 50
            local flag = config.Flag
            local callback = config.Callback or function() end

            if flag and Nexus.Flags[flag] then
                default = Nexus.Flags[flag]
            end

            local sliderFrame = Nexus:InsertThemeInstance(Nexus:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Surface,
                Parent = Container
            }), "Surface")
            Nexus:AddElement("Corner", sliderFrame, UDim.new(0, 8))
            Nexus:AddElement("Stroke", sliderFrame, nil, 0.5)

            local title = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                Size = UDim2.new(0.5, -10, 0.5, -5),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = "Left",
                TextColor3 = Nexus.Themes[Nexus.Save.Theme].Text
            }), "Text")
            title.Parent = sliderFrame

            if desc ~= "" then
                local description = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                    Size = UDim2.new(0.5, -10, 0.5, -5),
                    Position = UDim2.new(0, 10, 0.5, 0),
                    BackgroundTransparency = 1,
                    Text = desc,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = "Left",
                    TextColor3 = Nexus.Themes[Nexus.Save.Theme].TextDark
                }), "TextDark")
                description.Parent = sliderFrame
                title.Size = UDim2.new(0.5, -10, 0.5, -5)
            else
                title.Size = UDim2.new(0.5, -10, 1, 0)
            end

            -- Valor
            local valueLabel = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Text = tostring(default),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Nexus.Themes[Nexus.Save.Theme].Primary
            }), "Primary")
            valueLabel.Parent = sliderFrame

            -- Barra
            local bar = Nexus:Create("Frame", {
                Size = UDim2.new(0.8, 0, 0, 4),
                Position = UDim2.new(0.5, 0, 0.75, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Primary,
                BackgroundTransparency = 0.5,
                Parent = sliderFrame
            })
            Nexus:AddElement("Corner", bar, UDim.new(0.5, 0))

            local fill = Nexus:Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Primary,
                Parent = bar
            })
            Nexus:AddElement("Corner", fill, UDim.new(0.5, 0))

            local knob = Nexus:Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
                Parent = bar
            })
            Nexus:AddElement("Corner", knob, UDim.new(0.5, 0))

            local dragging = false
            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            knob.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation()
                    local barPos, barSize = bar.AbsolutePosition, bar.AbsoluteSize
                    local relativeX = math.clamp(mousePos.X - barPos.X, 0, barSize.X)
                    local percent = relativeX / barSize.X
                    local value = min + (max - min) * percent
                    value = math.floor(value * 100) / 100
                    valueLabel.Text = tostring(value)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    if flag then
                        Nexus.Flags[flag] = value
                    end
                    callback(value)
                end
            end)

            return sliderFrame
        end

        function Tab:AddDropdown(config)
            local name = config.Name or "Dropdown"
            local desc = config.Desc or ""
            local options = config.Options or {}
            local default = config.Default or options[1]
            local flag = config.Flag
            local callback = config.Callback or function() end

            if flag and Nexus.Flags[flag] then
                default = Nexus.Flags[flag]
            end

            local dropdownFrame = Nexus:InsertThemeInstance(Nexus:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Surface,
                Parent = Container
            }), "Surface")
            Nexus:AddElement("Corner", dropdownFrame, UDim.new(0, 8))
            Nexus:AddElement("Stroke", dropdownFrame, nil, 0.5)

            local title = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                Size = UDim2.new(0.7, -10, 0.5, -5),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = "Left",
                TextColor3 = Nexus.Themes[Nexus.Save.Theme].Text
            }), "Text")
            title.Parent = dropdownFrame

            if desc ~= "" then
                local description = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                    Size = UDim2.new(0.7, -10, 0.5, -5),
                    Position = UDim2.new(0, 10, 0.5, 0),
                    BackgroundTransparency = 1,
                    Text = desc,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = "Left",
                    TextColor3 = Nexus.Themes[Nexus.Save.Theme].TextDark
                }), "TextDark")
                description.Parent = dropdownFrame
                title.Size = UDim2.new(0.7, -10, 0.5, -5)
            else
                title.Size = UDim2.new(0.7, -10, 1, 0)
            end

            -- Selected display
            local selectedBox = Nexus:Create("Frame", {
                Size = UDim2.new(0, 120, 0, 25),
                Position = UDim2.new(1, -15, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Primary,
                BackgroundTransparency = 0.8,
                Parent = dropdownFrame
            })
            Nexus:AddElement("Corner", selectedBox, UDim.new(0, 6))

            local selectedText = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(default),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = "Left",
                TextColor3 = Nexus.Themes[Nexus.Save.Theme].Text
            }), "Text")
            selectedText.Parent = selectedBox

            local arrow = Nexus:Create("ImageLabel", {
                Size = UDim2.new(0, 15, 0, 15),
                Position = UDim2.new(1, -5, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10709791523",
                ImageColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
                Parent = selectedBox
            })

            -- Dropdown menu (popup)
            local dropdownMenu = Nexus:Create("Frame", {
                Size = UDim2.new(0, 150, 0, 0),
                BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Surface,
                Visible = false,
                ClipsDescendants = true,
                Parent = ScreenGui
            })
            Nexus:AddElement("Corner", dropdownMenu, UDim.new(0, 6))
            Nexus:AddElement("Stroke", dropdownMenu, nil, 1)
            Nexus:AddElement("Shadow", dropdownMenu, 0.5, 15)

            local menuLayout = Nexus:Create("UIListLayout", {Padding = UDim.new(0, 2)})
            menuLayout.Parent = dropdownMenu

            local function updateMenuSize()
                local count = #dropdownMenu:GetChildren() - 1 -- ignoring layout
                local height = count * 25 + 10
                dropdownMenu.Size = UDim2.new(0, 150, 0, height)
            end

            for _, opt in ipairs(options) do
                local optButton = Nexus:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = dropdownMenu
                })
                local optLabel = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(opt),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = "Left",
                    TextColor3 = Nexus.Themes[Nexus.Save.Theme].Text
                }), "Text")
                optLabel.Parent = optButton

                optButton.MouseButton1Click:Connect(function()
                    selectedText.Text = tostring(opt)
                    dropdownMenu.Visible = false
                    if flag then
                        Nexus.Flags[flag] = opt
                    end
                    callback(opt)
                end)

                optButton.MouseEnter:Connect(function()
                    optButton.BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Primary
                    optButton.BackgroundTransparency = 0.5
                end)
                optButton.MouseLeave:Connect(function()
                    optButton.BackgroundTransparency = 1
                end)
            end
            updateMenuSize()

            -- Toggle dropdown
            selectedBox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dropdownMenu.Visible = not dropdownMenu.Visible
                    if dropdownMenu.Visible then
                        -- position under selectedBox
                        local absPos = selectedBox.AbsolutePosition
                        local absSize = selectedBox.AbsoluteSize
                        dropdownMenu.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 5)
                    end
                end
            end)

            -- Close when clicking outside
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownMenu.Visible then
                    local mousePos = Vector2.new(input.Position.X, input.Position.Y)
                    local menuPos = dropdownMenu.AbsolutePosition
                    local menuSize = dropdownMenu.AbsoluteSize
                    if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                        dropdownMenu.Visible = false
                    end
                end
            end)

            return dropdownFrame
        end

        function Tab:AddLabel(config)
            local text = config.Text or "Label"
            local color = config.Color or "Text"
            local size = config.Size or 14
            local font = config.Font or Enum.Font.Gotham

            local label = Nexus:InsertThemeInstance(Nexus:Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = text,
                Font = font,
                TextSize = size,
                TextXAlignment = "Left",
                TextColor3 = Nexus.Themes[Nexus.Save.Theme][color] or Nexus.Themes[Nexus.Save.Theme].Text,
                Parent = Container
            }), color)
            return label
        end

        return Tab
    end

    -- Sistema de minimizar com bolinha
    local minimized = false
    local originalSize = Main.Size
    local originalPos = Main.Position

    local miniButton = Nexus:Create("ImageButton", {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Nexus.Themes[Nexus.Save.Theme].Surface,
        BackgroundTransparency = 0.2,
        Image = "rbxassetid://10747376565", -- wand icon
        ImageColor3 = Nexus.Themes[Nexus.Save.Theme].Text,
        Visible = false,
        Parent = ScreenGui,
        ZIndex = 100
    })
    Nexus:AddElement("Corner", miniButton, UDim.new(0.5, 0))
    Nexus:AddElement("Stroke", miniButton, nil, 1)
    MakeDraggable(miniButton)

    local function toggleMinimize()
        minimized = not minimized
        if minimized then
            originalSize = Main.Size
            originalPos = Main.Position
            CreateTween({Main, "Size", UDim2.new(0, 60, 0, 60), 0.3})
            CreateTween({Main, "Position", UDim2.new(0, 20, 0, 20), 0.3})
            miniButton.Visible = true
            miniButton.Position = Main.Position
            Main.Parent = miniButton -- temporarily parent to miniButton? Better to just hide
            Main.Visible = false
            miniButton.Visible = true
        else
            Main.Visible = true
            miniButton.Visible = false
            CreateTween({Main, "Size", originalSize, 0.3})
            CreateTween({Main, "Position", originalPos, 0.3})
        end
    end

    MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
    miniButton.MouseButton1Click:Connect(toggleMinimize)

    -- Fechar
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Redimensionamento
    local resizing = false
    local resizeStartPos, resizeStartSize

    ResizeControl.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStartPos = input.Position
            resizeStartSize = Main.Size
        end
    end)

    ResizeControl.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            Nexus.Save.UISize = {Main.Size.X.Offset, Main.Size.Y.Offset}
            Nexus:SaveConfig()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStartPos
            local newWidth = math.clamp(resizeStartSize.X.Offset + delta.X / UIScaleFactor, 400, 1000)
            local newHeight = math.clamp(resizeStartSize.Y.Offset + delta.Y / UIScaleFactor, 250, 600)
            Main.Size = UDim2.new(0, newWidth, 0, newHeight)
            -- ajustar containers
            TabScroll.Size = UDim2.new(0, Nexus.Save.TabSize, 1, -35)
            ContainerFrame.Size = UDim2.new(1, -Nexus.Save.TabSize, 1, -35)
        end
    end)

    -- Arrastar janela
    MakeDraggable(Main)

    -- Retornar objeto da janela
    return Window
end

return Nexus