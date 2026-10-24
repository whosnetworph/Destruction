if getgenv().Destruction and getgenv().Destruction.Unload then
    getgenv().Destruction:Unload()
end

local Library = { } do
    local Players = cloneref(game:GetService("Players"))
    local UserInputService = cloneref(game:GetService("UserInputService"))
    local RunService = cloneref(game:GetService("RunService"))
    local HttpService = cloneref(game:GetService("HttpService"))
    local TweenService = cloneref(game:GetService("TweenService"))
    local GuiService = cloneref(game:GetService("GuiService"))
    local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
    local Stats = cloneref(game:GetService("Stats"))
    local TextService = cloneref(game:GetService("TextService"))
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local GuiInset = GuiService:GetGuiInset().Y
    local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    local gethui = gethui

    local IconsV2
    pcall(function()
        IconsV2 = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
        IconsV2.SetIconsType("lucide")
    end)

    local function ResolveIcon(Icon)
        if type(Icon) == "number" then
            return "rbxassetid://" .. Icon
        end

        if type(Icon) == "string" then
            if string.match(Icon, "^rbxassetid://") then
                return Icon
            end

            if string.match(Icon, "^%d+$") then
                return "rbxassetid://" .. Icon
            end

            if IconsV2 then
                local Ok, Result = pcall(function()
                    return IconsV2.GetIcon(Icon)
                end)
                if Ok and Result and Result ~= "rbxassetid://0" then
                    return Result
                end
            end
        end

        return "rbxassetid://0"
    end

    local function ToVector2(Value)
        if typeof(Value) == "Vector2" then return Value end
        if type(Value) == "table" then return Vector2.new(Value[1] or Value.X or 0, Value[2] or Value.Y or 0) end
        return Vector2.new(0, 0)
    end

    local function ApplyIcon(Object, Icon)
        if not Icon then return end
        local Image, Offset, Size = ResolveIcon(Icon)
        Object.Image = Image
        Object.ImageRectOffset = ToVector2(Offset)
        Object.ImageRectSize = ToVector2(Size)
    end

    local function MeasureText(Text, Size, Width, FontFace)
        local Ok, Bounds = pcall(function()
            return TextService:GetTextBoundsAsync({
                Text = Text,
                Font = FontFace,
                Size = Size,
                Width = Width
            })
        end)

        if Ok and Bounds then
            return Bounds
        end

        return Vector2.new(Width, Size * 1.2)
    end

    Library.__index = Library
    Library.WindowWidth = 714
    Library.WindowHeight = 475

    Library.Theme = {
        Background = Color3.fromRGB(17, 17, 22),
        Section = Color3.fromRGB(20, 20, 26),
        Element = Color3.fromRGB(27, 27, 35),
        Selected = Color3.fromRGB(28, 26, 34),
        Line = Color3.fromRGB(33, 33, 38),
        Text = Color3.fromRGB(255, 255, 255),
        DimText = Color3.fromRGB(103, 104, 126),
        DimIcon = Color3.fromRGB(120, 120, 126),
        Accent = Color3.fromRGB(245, 93, 97)
    }

    Library.Presets = {
        ["Blood"] = {
            Background = Color3.fromRGB(17, 17, 22), Section = Color3.fromRGB(20, 20, 26), Element = Color3.fromRGB(27, 27, 35),
            Selected = Color3.fromRGB(28, 26, 34), Line = Color3.fromRGB(33, 33, 38), Text = Color3.fromRGB(255, 255, 255),
            DimText = Color3.fromRGB(103, 104, 126), DimIcon = Color3.fromRGB(120, 120, 126), Accent = Color3.fromRGB(245, 93, 97)
        },
        ["Ocean"] = {
            Background = Color3.fromRGB(13, 16, 22), Section = Color3.fromRGB(16, 20, 28), Element = Color3.fromRGB(22, 28, 38),
            Selected = Color3.fromRGB(24, 31, 42), Line = Color3.fromRGB(28, 35, 46), Text = Color3.fromRGB(235, 242, 255),
            DimText = Color3.fromRGB(96, 108, 130), DimIcon = Color3.fromRGB(110, 122, 140), Accent = Color3.fromRGB(64, 156, 255)
        },
        ["Violet"] = {
            Background = Color3.fromRGB(17, 14, 22), Section = Color3.fromRGB(21, 18, 28), Element = Color3.fromRGB(29, 24, 39),
            Selected = Color3.fromRGB(31, 26, 42), Line = Color3.fromRGB(36, 30, 47), Text = Color3.fromRGB(244, 238, 255),
            DimText = Color3.fromRGB(112, 100, 132), DimIcon = Color3.fromRGB(124, 112, 144), Accent = Color3.fromRGB(170, 90, 255)
        },
        ["Emerald"] = {
            Background = Color3.fromRGB(13, 19, 16), Section = Color3.fromRGB(16, 24, 20), Element = Color3.fromRGB(22, 32, 27),
            Selected = Color3.fromRGB(24, 35, 29), Line = Color3.fromRGB(28, 40, 34), Text = Color3.fromRGB(236, 248, 242),
            DimText = Color3.fromRGB(98, 120, 108), DimIcon = Color3.fromRGB(110, 132, 120), Accent = Color3.fromRGB(60, 220, 140)
        },
        ["Gold"] = {
            Background = Color3.fromRGB(20, 18, 14), Section = Color3.fromRGB(25, 22, 17), Element = Color3.fromRGB(34, 30, 23),
            Selected = Color3.fromRGB(37, 32, 25), Line = Color3.fromRGB(43, 38, 29), Text = Color3.fromRGB(255, 248, 235),
            DimText = Color3.fromRGB(130, 118, 96), DimIcon = Color3.fromRGB(142, 130, 108), Accent = Color3.fromRGB(240, 180, 60)
        }
    }
    Library.PresetList = { "Blood", "Ocean", "Violet", "Emerald", "Gold" }
    Library.ThemeKeys = { "Background", "Section", "Element", "Line", "Text", "DimText" }

    local function DeriveTheme()
        local T = Library.Theme
        T.AccentDark = T.Accent:Lerp(Color3.new(0, 0, 0), 0.3)
        T.ToggleOn = T.Accent:Lerp(T.Background, 0.78)
        T.ToggleOffCircle = T.DimText:Lerp(T.Background, 0.25)
    end

    DeriveTheme()

    Library.Flags = { }
    Library.SetFlags = { }
    Library.Connections = { }
    Library.Threads = { }
    Library.ThemingStuff = { }
    Library.ThemeMap = { }
    Library.AccentGradients = { }
    Library.OpenFrames = { }
    Library.Windows = { }
    Library.Notifs = { }
    Library.TouchButtons = { }
    Library.TouchShields = { }
    Library.MenuKeybind = Enum.KeyCode.LeftAlt
    Library.UserScale = 1
    Library.Silent = false
    Library.NotifsHidden = false
    Library.WatermarkHidden = false
    Library.Directory = "Destruction"
    Library.ConfigFolder = "Destruction/Configs"
    Library.AssetFolder = "Destruction/Assets"

    if isfolder and not isfolder(Library.Directory) then makefolder(Library.Directory) end
    if isfolder and not isfolder(Library.ConfigFolder) then makefolder(Library.ConfigFolder) end
    if isfolder and not isfolder(Library.AssetFolder) then makefolder(Library.AssetFolder) end

    Library.Animation = {
        Time = 0.25,
        Style = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out
    }

    Library.Create = function(Self, Class, Properties)
        local Data = {
            Class = Class,
            Instance = Instance.new(Class)
        }

        for Property, Value in Properties do
            if Property == "FontFace" then
                Data.Instance.FontFace = Library.Font
                continue
            end

            if Property == "Name" then
                Data.Instance.Name = "\0"
                continue
            end

            Data.Instance[Property] = Value
        end

        return setmetatable(Data, Library)
    end

    Library.Connect = function(Self, Signal, Callback)
        local Connection

        if type(Signal) == "string" and Self.Instance then
            if IsMobile and (Signal == "MouseButton1Down" or Signal == "MouseButton1Click") and Self.Instance:IsA("GuiButton") then
                local LastFire = 0

                local function Fire(Input)
                    local Now = os.clock()
                    if Now - LastFire < 0.25 then return end
                    LastFire = Now
                    Callback(Input)
                end

                table.insert(Library.TouchButtons, { Instance = Self.Instance, Fire = Fire })

                Connection = Self.Instance.Activated:Connect(function(Input)
                    Fire(Input)
                end)
            else
                Connection = Self.Instance[Signal]:Connect(Callback)
            end
        else
            Connection = Signal:Connect(Callback)
        end

        table.insert(Library.Connections, Connection)
        return Connection
    end

    Library.Thread = function(Self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.resume(NewThread)
        table.insert(Library.Threads, NewThread)
        return NewThread
    end

    Library.SafeCall = function(Self, Function, ...)
        if type(Function) ~= "function" then return end
        local Success, Result = pcall(Function, ...)
        if not Success then warn(Result) end
        return Success, Result
    end

    Library.Round = function(Self, Number, Float)
        Float = Float or 1
        local Result = math.floor(Number / Float + 0.5) * Float
        local Places = math.max(0, math.ceil(-math.log(Float, 10)))
        return tonumber(string.format("%." .. Places .. "f", Result))
    end

    Library.Tween = function(Self, Properties, Info, RawItem)
        local Object = RawItem or Self.Instance
        Info = Info or TweenInfo.new(Library.Animation.Time, Library.Animation.Style, Library.Animation.Direction)
        local NewTween = TweenService:Create(Object, Info, Properties)
        NewTween:Play()
        return NewTween
    end

    Library.GetTweenProperty = function(Self, RawItem)
        local Object = RawItem or Self.Instance

        if Object:IsA("Frame") then
            return { "BackgroundTransparency" }
        elseif Object:IsA("TextLabel") or Object:IsA("TextButton") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
            return { "BackgroundTransparency", "ImageTransparency" }
        elseif Object:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Object:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Object:IsA("UIStroke") then
            return { "Transparency" }
        end
    end

    Library.RestingValues = setmetatable({ }, { __mode = "k" })
    Library.FadeTokens = setmetatable({ }, { __mode = "k" })

    Library.CaptureResting = function(Self, Object, Property)
        local Store = Library.RestingValues[Object]
        if not Store then
            Store = { }
            Library.RestingValues[Object] = Store
        end
        if Store[Property] == nil then
            Store[Property] = Object[Property]
        end
        return Store[Property]
    end

    Library.ReleaseResting = function(Self, Object, Property)
        local Store = Library.RestingValues[Object]
        if not Store then return nil end
        local Value = Store[Property]
        Store[Property] = nil
        return Value
    end

    Library.StampResting = function(Self, Object, Property, Value)
        local Store = Library.RestingValues[Object]
        if not Store then
            Store = { }
            Library.RestingValues[Object] = Store
        end
        Store[Property] = Value
    end

    Library.Fade = function(Self, Property, Visibility, RawItem)
        local Object = RawItem or Self.Instance
        local Resting = Library:CaptureResting(Object, Property)

        if Visibility then
            Object[Property] = 1
            return Library:Tween({ [Property] = Resting }, nil, Object)
        end

        return Library:Tween({ [Property] = 1 }, nil, Object)
    end

    Library.FadeDescendants = function(Self, Visibility, Callback)
        local Root = Self.Instance

        Library.FadeTokens[Root] = (Library.FadeTokens[Root] or 0) + 1
        local Token = Library.FadeTokens[Root]

        if Visibility then
            Root.Visible = true
        end

        local Children = Root:GetDescendants()
        table.insert(Children, Root)

        for _, Child in Children do
            local Properties = Library:GetTweenProperty(Child)

            if not Properties then
                continue
            end

            for _, Property in Properties do
                Library:Fade(Property, Visibility, Child)
            end
        end

        task.delay(Library.Animation.Time + 0.03, function()
            if Library.FadeTokens[Root] == Token then
                Root.Visible = Visibility

                for _, Child in Children do
                    local Properties = Library:GetTweenProperty(Child)
                    if Properties then
                        for _, Property in Properties do
                            local Resting = Library:ReleaseResting(Child, Property)
                            if Resting ~= nil then
                                Child[Property] = Resting
                            end
                        end
                    end
                end
            end

            if Callback then Callback() end
        end)
    end

    Library.ResetFade = function(Self)
        local Root = Self.Instance
        Library.FadeTokens[Root] = (Library.FadeTokens[Root] or 0) + 1

        local Children = Root:GetDescendants()
        table.insert(Children, Root)

        for _, Child in Children do
            local Properties = Library:GetTweenProperty(Child)
            if Properties then
                for _, Property in Properties do
                    local Resting = Library:ReleaseResting(Child, Property)
                    if Resting ~= nil then
                        Child[Property] = Resting
                    end
                end
            end
        end
    end

    Library.AddToTheme = function(Self, Properties)
        local Object = Self.Instance

        local ThemeData = {
            Item = Object,
            Properties = Properties
        }

        for Property, Value in Properties do
            if type(Value) == "string" then
                Object[Property] = Library.Theme[Value]
            else
                Object[Property] = Value()
            end
        end

        table.insert(Library.ThemingStuff, ThemeData)
        Library.ThemeMap[Object] = ThemeData
        return Self
    end

    Library.ChangeItemTheme = function(Self, Properties)
        local Object = Self.Instance
        if not Library.ThemeMap[Object] then return end
        Library.ThemeMap[Object].Properties = Properties
    end

    Library.RegisterGradient = function(Self, Gradient)
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, Library.Theme.AccentDark)
        })
        table.insert(Library.AccentGradients, Gradient)
    end

    Library.ThemeDirty = false

    Library.ApplyThemeInstant = function(Self)
        for _, Item in Library.ThemingStuff do
            for Property, Value in Item.Properties do
                if type(Value) == "string" then
                    Item.Item[Property] = Library.Theme[Value]
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end

        for _, Gradient in Library.AccentGradients do
            Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library.Theme.Accent),
                ColorSequenceKeypoint.new(1, Library.Theme.AccentDark)
            })
        end
    end

    Library.SetAccent = function(Self, Color)
        Library.Theme.Accent = Color
        DeriveTheme()
        Library.ThemeDirty = true
    end

    Library.SetPreset = function(Self, Name)
        local Preset = Library.Presets[Name]
        if not Preset then return end

        for Key, Color in Preset do
            Library.Theme[Key] = Color
        end

        DeriveTheme()
        Library.ThemeDirty = true
    end

    Library.SetThemeColor = function(Self, Key, Color)
        Library.Theme[Key] = Color
        DeriveTheme()
        Library.ThemeDirty = true
    end

    Library.OnHover = function(Self, OnEnter, OnLeave)
        Library:Connect(Self.Instance.MouseEnter, OnEnter)
        Library:Connect(Self.Instance.MouseLeave, OnLeave)
    end

    Library.GetScreenScale = function(Self)
        return (Library.UIScale and Library.UIScale.Instance and Library.UIScale.Instance.Scale) or 1
    end

    local function IsOverObject(Object)
        local Position = UserInputService:GetMouseLocation() - Vector2.new(0, GuiInset)

        return Position.X >= Object.AbsolutePosition.X and Position.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X
        and Position.Y >= Object.AbsolutePosition.Y and Position.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y
    end

    Library.IsMouseOverFrame = function(Self)
        return IsOverObject(Self.Instance)
    end

    Library.MakeDraggable = function(Self, Handle)
        local Gui = Self.Instance
        Handle = Handle or Gui
        Handle.Active = true

        local Dragging = false
        local DragStart
        local StartPosition

        local Set = function(Input)
            local Scale = Library:GetScreenScale()
            local DragDelta = (Input.Position - DragStart) / Scale
            local NewX = StartPosition.X + DragDelta.X
            local NewY = StartPosition.Y + DragDelta.Y

            local ScreenSize = Gui.Parent.AbsoluteSize / Scale
            local GuiSize = Gui.AbsoluteSize / Scale
            local Anchor = Gui.AnchorPoint

            NewX = math.clamp(NewX, GuiSize.X * Anchor.X, ScreenSize.X - GuiSize.X * (1 - Anchor.X))
            NewY = math.clamp(NewY, GuiSize.Y * Anchor.Y, ScreenSize.Y - GuiSize.Y * (1 - Anchor.Y))

            Self:Tween({ Position = UDim2.fromOffset(NewX, NewY) }, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        end

        local InputChanged

        Library:Connect(Handle.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position

                local Scale = Library:GetScreenScale()
                local ParentSize = Gui.Parent.AbsoluteSize / Scale
                StartPosition = Vector2.new(
                    Gui.Position.X.Scale * ParentSize.X + Gui.Position.X.Offset,
                    Gui.Position.Y.Scale * ParentSize.Y + Gui.Position.Y.Offset
                )

                if InputChanged then
                    return
                end

                InputChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                        InputChanged:Disconnect()
                        InputChanged = nil
                    end
                end)
            end
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if Dragging then
                    Set(Input)
                end
            end
        end)
    end

    Library.Unload = function(Self)
        for _, Connection in Library.Connections do
            Connection:Disconnect()
        end

        for _, Thread in Library.Threads do
            pcall(coroutine.close, Thread)
        end

        if Library.Holder then Library.Holder.Instance:Destroy() end
        if Library.UnusedHolder then Library.UnusedHolder.Instance:Destroy() end

        getgenv().Destruction = nil
    end

    Library.Font = Font.fromEnum(Enum.Font.ArimoBold)

    Library.Holder = Library:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    Library.UnusedHolder = Library:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        Enabled = false,
        ResetOnSpawn = false
    })

    do
        local Probe = Library:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(0, 1, 0, 1),
            BorderSizePixel = 0
        })

        task.defer(function()
            GuiInset = -Probe.Instance.AbsolutePosition.Y
            Probe.Instance:Destroy()
        end)
    end

    Library.UIScale = Library:Create("UIScale", {
        Parent = Library.Holder.Instance,
        Scale = 1
    })

    Library.DimCount = 0

    Library.Dim = Library:Create("Frame", {
        Parent = Library.UnusedHolder.Instance,
        Name = "\0",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 30,
        BorderSizePixel = 0
    })

    Library:Create("UICorner", { Parent = Library.Dim.Instance, CornerRadius = UDim.new(0, 15) })

    Library.SetDim = function(Self, Bool)
        Library.DimCount = math.max(0, Library.DimCount + (Bool and 1 or -1))

        local Window = Library.Windows[1]
        if not Window then return end

        if Library.DimCount > 0 then
            Library:StampResting(Library.Dim.Instance, "BackgroundTransparency", 0.65)
            Library.Dim.Instance.Parent = Window.Items.MainFrame.Instance
            Library.Dim.Instance.Visible = true
            Library:Tween({ BackgroundTransparency = 0.65 }, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Library.Dim.Instance)
        else
            Library:StampResting(Library.Dim.Instance, "BackgroundTransparency", 1)
            Library:Tween({ BackgroundTransparency = 1 }, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Library.Dim.Instance)
            task.delay(0.3, function()
                if Library.DimCount == 0 then
                    Library.Dim.Instance.Visible = false
                    Library.Dim.Instance.Parent = Library.UnusedHolder.Instance
                end
            end)
        end
    end

    do
        local TouchStart

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch then
                TouchStart = Input.Position
            end
        end)

        Library:Connect(UserInputService.InputEnded, function(Input)
            if not IsMobile then return end
            if Input.UserInputType ~= Enum.UserInputType.Touch then return end
            if not TouchStart then return end

            local Delta = Input.Position - TouchStart
            if math.abs(Delta.X) > 12 or math.abs(Delta.Y) > 12 then return end

            local Position = Input.Position

            local function Inside(Object)
                local Pos, Size = Object.AbsolutePosition, Object.AbsoluteSize
                return Position.X >= Pos.X and Position.X <= Pos.X + Size.X and Position.Y >= Pos.Y and Position.Y <= Pos.Y + Size.Y
            end

            local function OnScreen(Object)
                if not Object:IsDescendantOf(Library.Holder.Instance) then return false end
                local Current = Object
                while Current and Current ~= Library.Holder.Instance do
                    if Current:IsA("GuiObject") and not Current.Visible then return false end
                    Current = Current.Parent
                end
                return true
            end

            local ShieldLevel = 0
            for Panel, Level in Library.TouchShields do
                if Panel:IsDescendantOf(Library.Holder.Instance) and Inside(Panel) then
                    ShieldLevel = math.max(ShieldLevel, Level)
                end
            end

            local Best

            for _, Data in Library.TouchButtons do
                local Object = Data.Instance
                if Object and OnScreen(Object) and Inside(Object) and Object.ZIndex >= ShieldLevel then
                    if not Best
                    or Object.ZIndex > Best.Instance.ZIndex
                    or (Object.ZIndex == Best.Instance.ZIndex and Object.AbsoluteSize.X * Object.AbsoluteSize.Y < Best.Instance.AbsoluteSize.X * Best.Instance.AbsoluteSize.Y) then
                        Best = Data
                    end
                end
            end

            if Best then
                Best.Fire(Input)
            end
        end)
    end

    local function UpdateScale()
        local Scale = Library.UserScale

        if IsMobile and workspace.CurrentCamera then
            local Viewport = workspace.CurrentCamera.ViewportSize
            Scale = Scale * math.clamp(math.min((Viewport.X * 0.9) / Library.WindowWidth, (Viewport.Y * 0.85) / Library.WindowHeight), 0.3, 1)
        end

        Library.UIScale.Instance.Scale = Scale

        for _, Window in Library.Windows do
            if Window.Center then Window:Center() end
        end
    end

    Library.SetUIScale = function(Self, Multiplier)
        Library.UserScale = Multiplier
        Library:CloseAllPopups()
        UpdateScale()
    end

    Library.CloseAllPopups = function(Self)
        for _, Value in Library.OpenFrames do
            if Value.SetOpen then Value:SetOpen(false) end
        end
    end

    UpdateScale()
    Library:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
        task.wait()
        UpdateScale()
    end)

    local function MakeOptionPopup(GetAnchor, Level)
        Level = Level or 40
        local Popup = { IsOpen = false, Debounce = false, Order = { }, Host = nil, OnPick = function() end }
        local Items = { }
        local SearchOffset = 32

        Items.Frame = Library:Create("Frame", {
            Parent = Library.UnusedHolder.Instance,
            Name = "\0",
            Visible = false,
            ClipsDescendants = true,
            Size = UDim2.fromOffset(140, 0),
            ZIndex = Level,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ BackgroundColor3 = "Element" })

        Library:Create("UICorner", { Parent = Items.Frame.Instance, CornerRadius = UDim.new(0, 3) })

        Items.SearchContainer = Library:Create("Frame", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            Visible = false,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 0, SearchOffset),
            ZIndex = Level + 5,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background
        }):AddToTheme({ BackgroundColor3 = "Background" })

        local SearchIconLabel = Library:Create("ImageLabel", {
            Parent = Items.SearchContainer.Instance,
            Name = "\0",
            ImageColor3 = Library.Theme.DimText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, (SearchOffset - 14) / 2),
            Size = UDim2.fromOffset(14, 14),
            ZIndex = Level + 7,
            BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "DimText" })
        ApplyIcon(SearchIconLabel.Instance, "search")

        Items.Search = Library:Create("TextBox", {
            Parent = Items.SearchContainer.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            PlaceholderColor3 = Library.Theme.DimText,
            PlaceholderText = "Search...",
            Text = "",
            TextSize = 13,
            ClearTextOnFocus = false,
            CursorPosition = -1,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(24, 0),
            Size = UDim2.new(1, -28, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = Level + 6,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text", PlaceholderColor3 = "DimText" })

        Library:Create("Frame", {
            Parent = Items.SearchContainer.Instance,
            Name = "\0",
            Position = UDim2.new(0, 4, 1, -1),
            Size = UDim2.new(1, -8, 0, 1),
            BorderSizePixel = 0,
            ZIndex = Level + 6,
            BackgroundColor3 = Library.Theme.Line
        }):AddToTheme({ BackgroundColor3 = "Line" })

        if IsMobile then
            local SearchFocusBtn = Library:Create("TextButton", {
                Parent = Items.SearchContainer.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = Level + 8,
                BorderSizePixel = 0
            })
            SearchFocusBtn:Connect("MouseButton1Down", function()
                Items.Search.Instance:CaptureFocus()
            end)
        end

        Items.Scroll = Library:Create("ScrollingFrame", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            Selectable = false,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = Level + 4,
            BorderSizePixel = 0
        }):AddToTheme({ ScrollBarImageColor3 = "Accent" })

        Library:Create("UIListLayout", {
            Parent = Items.Scroll.Instance,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Popup.Items = Items

        local function ApplySearch(Query)
            Query = string.lower(Query)
            for _, Data in Popup.Order do
                local Visible = Query == "" or string.find(string.lower(Data.Name), Query, 1, true) ~= nil
                Data.Row.Instance.Visible = Visible
            end
        end

        Library:Connect(Items.Search.Instance:GetPropertyChangedSignal("Text"), function()
            ApplySearch(Items.Search.Instance.Text)
        end)

        function Popup:AddRow(Text)
            local Row = Library:Create("Frame", {
                Parent = Items.Scroll.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -3, 0, 30),
                ZIndex = Level + 1,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Selected
            }):AddToTheme({ BackgroundColor3 = "Selected" })

            Library:Create("UICorner", { Parent = Row.Instance, CornerRadius = UDim.new(0, 3) })

            local Circle = Library:Create("Frame", {
                Parent = Row.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(8, 13),
                Size = UDim2.fromOffset(4, 4),
                ZIndex = Level + 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Accent
            }):AddToTheme({ BackgroundColor3 = "Accent" })

            Library:Create("UICorner", { Parent = Circle.Instance, CornerRadius = UDim.new(1, 0) })

            local Label = Library:Create("TextLabel", {
                Parent = Row.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.DimText,
                Text = Text,
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(10, -1),
                Size = UDim2.new(1, -20, 0, 30),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = Level + 2,
                BorderSizePixel = 0
            }):AddToTheme({ TextColor3 = "DimText" })

            local Button = Library:Create("TextButton", {
                Parent = Row.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = Level + 3,
                BorderSizePixel = 0
            })

            local Data = { Name = Text, Selected = false, Row = Row }

            function Data:Set(Active, Instant)
                Data.Selected = Active

                if Active then
                    Label:ChangeItemTheme({ TextColor3 = "Text" })
                else
                    Label:ChangeItemTheme({ TextColor3 = "DimText" })
                end

                Library:StampResting(Row.Instance, "BackgroundTransparency", Active and 0 or 1)
                Library:StampResting(Circle.Instance, "BackgroundTransparency", Active and 0 or 1)

                if Instant then
                    Row.Instance.BackgroundTransparency = Active and 0 or 1
                    Circle.Instance.BackgroundTransparency = Active and 0 or 1
                    Label.Instance.TextColor3 = Active and Library.Theme.Text or Library.Theme.DimText
                    Label.Instance.Position = UDim2.fromOffset(Active and 20 or 10, -1)
                    return
                end

                if Active then
                    Row:Tween({ BackgroundTransparency = 0 })
                    Circle:Tween({ BackgroundTransparency = 0 })
                    Label:Tween({ TextColor3 = Library.Theme.Text, Position = UDim2.fromOffset(20, -1) })
                else
                    Row:Tween({ BackgroundTransparency = 1 })
                    Circle:Tween({ BackgroundTransparency = 1 })
                    Label:Tween({ TextColor3 = Library.Theme.DimText, Position = UDim2.fromOffset(10, -1) })
                end
            end

            Button:Connect("MouseButton1Down", function()
                Popup.OnPick(Data)
            end)

            table.insert(Popup.Order, Data)
            return Data
        end

        function Popup:Clear()
            for _, Data in Popup.Order do
                Data.Row.Instance:Destroy()
            end
            Popup.Order = { }
        end

        local function Place(Extra)
            local Anchor = GetAnchor()
            local Scale = Library:GetScreenScale()
            return UDim2.fromOffset(Anchor.AbsolutePosition.X / Scale, (Anchor.AbsolutePosition.Y + Anchor.AbsoluteSize.Y + GuiInset) / Scale + (Extra or 0))
        end

        function Popup:SetOpen(Bool)
            if Popup.Debounce then return end
            Popup.IsOpen = Bool
            Popup.Debounce = true

            if Popup.OnState then
                Popup.OnState(Bool)
            end

            if Bool then
                local Anchor = GetAnchor()
                local Scale = Library:GetScreenScale()
                local ShowSearch = #Popup.Order > 10

                Items.Search.Instance.Text = ""
                ApplySearch("")

                if ShowSearch then
                    Items.SearchContainer.Instance.Visible = true
                    Items.SearchContainer.Instance.Size = UDim2.new(1, 0, 0, SearchOffset)
                    Items.Scroll.Instance.Position = UDim2.fromOffset(0, SearchOffset)
                    Items.Scroll.Instance.Size = UDim2.new(1, 0, 1, -SearchOffset)
                    Items.Frame.Instance.Size = UDim2.fromOffset(Anchor.AbsoluteSize.X / Scale, math.min(#Popup.Order * 30, 150) + SearchOffset)
                else
                    Items.SearchContainer.Instance.Visible = false
                    Items.Scroll.Instance.Position = UDim2.fromOffset(0, 0)
                    Items.Scroll.Instance.Size = UDim2.new(1, 0, 1, 0)
                    Items.Frame.Instance.Size = UDim2.fromOffset(Anchor.AbsoluteSize.X / Scale, math.min(#Popup.Order * 30, 150))
                end

                Items.Frame.Instance.Parent = Library.Holder.Instance
                Items.Frame.Instance.Position = Place(-6)
                Items.Frame.Instance.Visible = true
                Library.TouchShields[Items.Frame.Instance] = Level
                Library:SetDim(true)
                Items.Frame:Tween({ Position = Place(4) })

                for _, Value in Library.OpenFrames do
                    if Value ~= Popup and Value ~= Popup.Host then Value:SetOpen(false) end
                end
                Library.OpenFrames[Popup] = Popup

                Items.Frame:FadeDescendants(true, function()
                    Popup.Debounce = false
                end)
            else
                Items.Search.Instance.Text = ""
                Library.OpenFrames[Popup] = nil
                Library:SetDim(false)
                local Current = Items.Frame.Instance.Position
                Items.Frame:Tween({ Position = UDim2.fromOffset(Current.X.Offset, Current.Y.Offset - 8) })
                Items.Frame:FadeDescendants(false, function()
                    Popup.Debounce = false
                    Library.TouchShields[Items.Frame.Instance] = nil
                    Items.Frame.Instance.Parent = Library.UnusedHolder.Instance
                end)
            end
        end

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if Popup.IsOpen and not Items.Frame:IsMouseOverFrame() and not IsOverObject(GetAnchor()) then
                    Popup:SetOpen(false)
                end
            end
        end)

        return Popup
    end

    local function MakeColorPopup(GetAnchor, Title, Default, DefaultAlpha, OnChanged)
        local Picker = {
            Hue = 0, Saturation = 0, Value = 0,
            Transparency = DefaultAlpha or 0,
            Color = Color3.new(1, 1, 1),
            IsOpen = false,
            Debounce = false
        }

        local Items = { }

        Items.Window = Library:Create("Frame", {
            Parent = Library.UnusedHolder.Instance,
            Name = "\0",
            Visible = false,
            Size = UDim2.fromOffset(172, 220),
            ZIndex = 45,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Section
        }):AddToTheme({ BackgroundColor3 = "Section" })

        Library:Create("UICorner", { Parent = Items.Window.Instance, CornerRadius = UDim.new(0, 6) })

        Items.Title = Library:Create("TextLabel", {
            Parent = Items.Window.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "\"" .. Title .. "\"",
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 4),
            Size = UDim2.fromOffset(150, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 46,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Items.Palette = Library:Create("ImageButton", {
            Parent = Items.Window.Instance,
            Name = "\0",
            AutoButtonColor = false,
            Position = UDim2.fromOffset(10, 28),
            Size = UDim2.fromOffset(125, 125),
            ZIndex = 46,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        })
        Library:Create("UICorner", { Parent = Items.Palette.Instance, CornerRadius = UDim.new(0, 4) })

        local Sat = Library:Create("Frame", {
            Parent = Items.Palette.Instance, Name = "\0",
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 46, BorderSizePixel = 0
        })
        Library:Create("UIGradient", { Parent = Sat.Instance, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) })
        Library:Create("UICorner", { Parent = Sat.Instance, CornerRadius = UDim.new(0, 4) })

        local Val = Library:Create("Frame", {
            Parent = Items.Palette.Instance, Name = "\0",
            BackgroundColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 46, BorderSizePixel = 0
        })
        Library:Create("UIGradient", { Parent = Val.Instance, Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) })
        Library:Create("UICorner", { Parent = Val.Instance, CornerRadius = UDim.new(0, 4) })

        Items.PaletteDrag = Library:Create("Frame", {
            Parent = Items.Palette.Instance, Name = "\0",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(10, 10), ZIndex = 47, BorderSizePixel = 0
        })
        Library:Create("UICorner", { Parent = Items.PaletteDrag.Instance, CornerRadius = UDim.new(1, 0) })
        Library:Create("UIStroke", { Parent = Items.PaletteDrag.Instance, Color = Color3.new(1, 1, 1), Thickness = 1.5 })

        Items.HueBar = Library:Create("ImageButton", {
            Parent = Items.Window.Instance, Name = "\0",
            AutoButtonColor = false,
            Position = UDim2.fromOffset(145, 28),
            Size = UDim2.fromOffset(15, 125),
            ZIndex = 46, BorderSizePixel = 0,
            BackgroundColor3 = Color3.new(1, 1, 1)
        })
        Library:Create("UICorner", { Parent = Items.HueBar.Instance, CornerRadius = UDim.new(0, 4) })
        Library:Create("UIGradient", {
            Parent = Items.HueBar.Instance,
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
        })

        Items.HueDrag = Library:Create("Frame", {
            Parent = Items.HueBar.Instance, Name = "\0",
            BackgroundColor3 = Color3.new(1, 1, 1),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.fromOffset(19, 5), ZIndex = 47, BorderSizePixel = 0
        })
        Library:Create("UICorner", { Parent = Items.HueDrag.Instance, CornerRadius = UDim.new(0, 2) })
        Library:Create("UIStroke", { Parent = Items.HueDrag.Instance, Color = Library.Theme.Section, Thickness = 1.5 }):AddToTheme({ Color = "Section" })

        Items.Alpha = Library:Create("ImageButton", {
            Parent = Items.Window.Instance, Name = "\0",
            AutoButtonColor = false,
            Position = UDim2.fromOffset(10, 160),
            Size = UDim2.fromOffset(125, 13),
            ZIndex = 46, BorderSizePixel = 0,
            BackgroundColor3 = Color3.new(1, 1, 1)
        })
        Library:Create("UICorner", { Parent = Items.Alpha.Instance, CornerRadius = UDim.new(0, 4) })
        Library:Create("UIGradient", { Parent = Items.Alpha.Instance, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) })

        Items.AlphaDrag = Library:Create("Frame", {
            Parent = Items.Alpha.Instance, Name = "\0",
            BackgroundColor3 = Color3.new(1, 1, 1),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(5, 17), ZIndex = 47, BorderSizePixel = 0
        })
        Library:Create("UICorner", { Parent = Items.AlphaDrag.Instance, CornerRadius = UDim.new(0, 2) })
        Library:Create("UIStroke", { Parent = Items.AlphaDrag.Instance, Color = Library.Theme.Section, Thickness = 1.5 }):AddToTheme({ Color = "Section" })

        Items.Hex = Library:Create("TextBox", {
            Parent = Items.Window.Instance, Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            PlaceholderColor3 = Library.Theme.DimText,
            PlaceholderText = "#ffffff", Text = "#ffffff", TextSize = 14,
            ClearTextOnFocus = false, CursorPosition = -1,
            Position = UDim2.fromOffset(10, 182),
            Size = UDim2.fromOffset(125, 26),
            ZIndex = 46, BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ TextColor3 = "Text", PlaceholderColor3 = "DimText", BackgroundColor3 = "Element" })
        Library:Create("UICorner", { Parent = Items.Hex.Instance, CornerRadius = UDim.new(0, 4) })
        Library:Create("UIPadding", { Parent = Items.Hex.Instance, PaddingLeft = UDim.new(0, 8) })

        if IsMobile then
            local FocusButton = Library:Create("TextButton", {
                Parent = Items.Hex.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 47,
                BorderSizePixel = 0
            })

            FocusButton:Connect("MouseButton1Down", function()
                Items.Hex.Instance:CaptureFocus()
            end)
        end

        Items.Pen = Library:Create("ImageButton", {
            Parent = Items.Window.Instance, Name = "\0",
            AutoButtonColor = false,
            Image = "rbxassetid://10734919691",
            ImageColor3 = Library.Theme.DimText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(144, 187),
            Size = UDim2.fromOffset(16, 16),
            ZIndex = 46, BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "DimText" })

        function Picker:Update()
            Picker.Color = Color3.fromHSV(Picker.Hue, Picker.Saturation, Picker.Value)
            Items.Palette:Tween({ BackgroundColor3 = Color3.fromHSV(Picker.Hue, 1, 1) })
            Items.Alpha:Tween({ BackgroundColor3 = Picker.Color })

            if not Items.Hex.Instance:IsFocused() then
                Items.Hex.Instance.Text = "#" .. Picker.Color:ToHex()
            end

            Library:SafeCall(OnChanged, Picker.Color, Picker.Transparency)
        end

        function Picker:Set(Color, Alpha)
            if type(Color) == "table" then Color = Color3.fromRGB(Color[1], Color[2], Color[3]) end
            if type(Color) == "string" then Color = Color3.fromHex(Color) end
            Picker.Hue, Picker.Saturation, Picker.Value = Color:ToHSV()
            Picker.Transparency = Alpha or Picker.Transparency or 0
            Items.PaletteDrag.Instance.Position = UDim2.new(Picker.Saturation, 0, 1 - Picker.Value, 0)
            Items.HueDrag.Instance.Position = UDim2.new(0.5, 0, Picker.Hue, 0)
            Items.AlphaDrag.Instance.Position = UDim2.new(Picker.Transparency, 0, 0.5, 0)
            Picker:Update()
        end

        local Grabbing = nil
        local SlideInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        local function Slide(Input)
            if Grabbing == "Palette" then
                local SX = math.clamp((Input.Position.X - Items.Palette.Instance.AbsolutePosition.X) / Items.Palette.Instance.AbsoluteSize.X, 0, 1)
                local SY = math.clamp((Input.Position.Y - Items.Palette.Instance.AbsolutePosition.Y) / Items.Palette.Instance.AbsoluteSize.Y, 0, 1)
                Picker.Saturation = SX
                Picker.Value = 1 - SY
                Library:Tween({ Position = UDim2.new(SX, 0, SY, 0) }, SlideInfo, Items.PaletteDrag.Instance)
            elseif Grabbing == "Hue" then
                local HY = math.clamp((Input.Position.Y - Items.HueBar.Instance.AbsolutePosition.Y) / Items.HueBar.Instance.AbsoluteSize.Y, 0, 1)
                Picker.Hue = HY
                Library:Tween({ Position = UDim2.new(0.5, 0, HY, 0) }, SlideInfo, Items.HueDrag.Instance)
            elseif Grabbing == "Alpha" then
                local AX = math.clamp((Input.Position.X - Items.Alpha.Instance.AbsolutePosition.X) / Items.Alpha.Instance.AbsoluteSize.X, 0, 1)
                Picker.Transparency = AX
                Library:Tween({ Position = UDim2.new(AX, 0, 0.5, 0) }, SlideInfo, Items.AlphaDrag.Instance)
            else
                return
            end
            Picker:Update()
        end

        local function Grabber(Wrapper, Mode)
            local Watcher
            Library:Connect(Wrapper.Instance.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Grabbing = Mode
                    Slide(Input)
                    if Watcher then return end
                    Watcher = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            if Grabbing == Mode then Grabbing = nil end
                            Watcher:Disconnect()
                            Watcher = nil
                        end
                    end)
                end
            end)
        end

        Grabber(Items.Palette, "Palette")
        Grabber(Items.HueBar, "Hue")
        Grabber(Items.Alpha, "Alpha")

        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if Grabbing then
                    Slide(Input)
                end
            end
        end)

        Items.Hex:Connect("FocusLost", function()
            local Text = string.gsub(Items.Hex.Instance.Text, "#", "")
            local Ok, Color = pcall(function() return Color3.fromHex(Text) end)
            if Ok and Color then
                Picker:Set(Color, Picker.Transparency)
            else
                Items.Hex.Instance.Text = "#" .. Picker.Color:ToHex()
            end
        end)

        Items.Pen:Connect("MouseButton1Down", function()
            Items.Hex.Instance:CaptureFocus()
        end)

        local function Place(Extra)
            local Anchor = GetAnchor()
            local Scale = Library:GetScreenScale()
            local X = (Anchor.AbsolutePosition.X + Anchor.AbsoluteSize.X) / Scale - 172
            return UDim2.fromOffset(X, (Anchor.AbsolutePosition.Y + Anchor.AbsoluteSize.Y + GuiInset) / Scale + (Extra or 0))
        end

        function Picker:SetOpen(Bool)
            if Picker.Debounce then return end
            Picker.IsOpen = Bool
            Picker.Debounce = true

            if Bool then
                Items.Window.Instance.Parent = Library.Holder.Instance
                Items.Window.Instance.Position = Place(-6)
                Items.Window.Instance.Visible = true
                Library.TouchShields[Items.Window.Instance] = 45
                Library:SetDim(true)
                Items.Window:Tween({ Position = Place(4) })

                for _, Value in Library.OpenFrames do
                    if Value ~= Picker then Value:SetOpen(false) end
                end
                Library.OpenFrames[Picker] = Picker

                Items.Window:FadeDescendants(true, function()
                    Picker.Debounce = false
                end)
            else
                Library.OpenFrames[Picker] = nil
                Library:SetDim(false)
                local Current = Items.Window.Instance.Position
                Items.Window:Tween({ Position = UDim2.fromOffset(Current.X.Offset, Current.Y.Offset - 8) })
                Items.Window:FadeDescendants(false, function()
                    Picker.Debounce = false
                    Library.TouchShields[Items.Window.Instance] = nil
                    Items.Window.Instance.Parent = Library.UnusedHolder.Instance
                end)
            end
        end

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if Picker.IsOpen and not Items.Window:IsMouseOverFrame() and not IsOverObject(GetAnchor()) then
                    Picker:SetOpen(false)
                end
            end
        end)

        Picker:Set(Default or Library.Theme.Accent, Picker.Transparency)

        return Picker
    end

    local function MakeColorSwatch(Parent, RightOffset, Default)
        local Swatch = { }

        Swatch.Halo = Library:Create("Frame", {
            Parent = Parent,
            Name = "\0",
            Position = UDim2.new(1, RightOffset, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.fromOffset(20, 20),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            BackgroundColor3 = Default
        })

        Library:Create("UICorner", { Parent = Swatch.Halo.Instance, CornerRadius = UDim.new(1, 0) })

        Swatch.Core = Library:Create("Frame", {
            Parent = Swatch.Halo.Instance,
            Name = "\0",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(12, 12),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Default
        })

        Library:Create("UICorner", { Parent = Swatch.Core.Instance, CornerRadius = UDim.new(1, 0) })

        Swatch.Hit = Library:Create("TextButton", {
            Parent = Swatch.Halo.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            BorderSizePixel = 0
        })

        function Swatch:SetColor(Color, Alpha)
            Alpha = Alpha or 0
            Library:StampResting(Swatch.Core.Instance, "BackgroundTransparency", Alpha)
            Swatch.Halo:Tween({ BackgroundColor3 = Color })
            Swatch.Core:Tween({ BackgroundColor3 = Color, BackgroundTransparency = Alpha })
        end

        return Swatch
    end

    Library.Notification = function(Self, Params)
        if Library.Silent or Library.NotifsHidden then return end

        Params = Params or { }

        local Text = Params.Name or Params.Text or "Notification"
        local Icon = Params.Icon or "bell"
        local Color = Params.Color or Library.Theme.Accent
        local Duration = Params.Duration or 4

        local Items = { }

        Items.Frame = Library:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(-450, 0),
            Size = UDim2.fromOffset(0, 52),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 80,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background
        }):AddToTheme({ BackgroundColor3 = "Background" })

        Library:Create("UICorner", { Parent = Items.Frame.Instance, CornerRadius = UDim.new(0, 9) })

        Items.Stroke = Library:Create("UIStroke", {
            Parent = Items.Frame.Instance,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Library.Theme.Line
        }):AddToTheme({ Color = "Line" })

        Items.Icon = Library:Create("ImageLabel", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            ImageColor3 = Color,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, 15),
            Size = UDim2.fromOffset(22, 22),
            ZIndex = 81,
            BorderSizePixel = 0
        })
        ApplyIcon(Items.Icon.Instance, Icon)

        Items.Line = Library:Create("Frame", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(50, 13),
            Size = UDim2.fromOffset(1, 26),
            ZIndex = 81,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Line
        }):AddToTheme({ BackgroundColor3 = "Line" })

        Items.Text = Library:Create("TextLabel", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Text,
            TextSize = 16,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(63, 0),
            Size = UDim2.fromOffset(0, 52),
            AutomaticSize = Enum.AutomaticSize.X,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 81,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Library:Create("UIPadding", { Parent = Items.Frame.Instance, PaddingRight = UDim.new(0, 18) })

        local Notif = { Items = Items, Dead = false }
        table.insert(Library.Notifs, Notif)

        local function TargetY(Index)
            return 60 + (Index - 1) * 62
        end

        local function Reflow()
            for Index, Value in Library.Notifs do
                if not Value.Dead then
                    Library:Tween({ Position = UDim2.fromOffset(15, TargetY(Index)) }, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Value.Items.Frame.Instance)
                end
            end
        end

        Items.Frame.Instance.Position = UDim2.fromOffset(-450, TargetY(#Library.Notifs))
        Items.Frame:Tween({ Position = UDim2.fromOffset(15, TargetY(#Library.Notifs)) }, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out))

        task.delay(Duration, function()
            Notif.Dead = true

            local Current = Items.Frame.Instance.Position
            Library:Tween({ Position = UDim2.fromOffset(Current.X.Offset, Current.Y.Offset - 18) }, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Items.Frame.Instance)

            local Fade = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            Library:Tween({ BackgroundTransparency = 1 }, Fade, Items.Frame.Instance)
            Library:Tween({ Transparency = 1 }, Fade, Items.Stroke.Instance)
            Library:Tween({ ImageTransparency = 1 }, Fade, Items.Icon.Instance)
            Library:Tween({ BackgroundTransparency = 1 }, Fade, Items.Line.Instance)
            Library:Tween({ TextTransparency = 1 }, Fade, Items.Text.Instance)

            task.wait(0.3)
            local Index = table.find(Library.Notifs, Notif)
            if Index then table.remove(Library.Notifs, Index) end
            Items.Frame.Instance:Destroy()
            Reflow()
        end)
    end

    Library.Window = function(Self, Params)
        Params = Params or { }

        local Window = {
            Name = Params.Name or "DESTRUCTION",
            Icon = Params.Icon or Params.Logo or "77359238729295",
            IsOpen = true,
            Pages = { },
            CurrentPage = nil,
            Items = { }
        }

        local Items = { }
        local W, H = Library.WindowWidth, Library.WindowHeight
        local Viewport = workspace.CurrentCamera.ViewportSize
        local Scale = Library:GetScreenScale()

        Items.MainFrame = Library:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(Viewport.X / (2 * Scale) - W / 2, Viewport.Y / (2 * Scale) - H / 2),
            Size = UDim2.fromOffset(W, H),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background
        }):AddToTheme({ BackgroundColor3 = "Background" })

        Library:Create("UICorner", { Parent = Items.MainFrame.Instance, CornerRadius = UDim.new(0, 15) })

        Items.Sidebar = Library:Create("Frame", {
            Parent = Items.MainFrame.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(80, H),
            BorderSizePixel = 0
        })

        Items.MainFrame:MakeDraggable(IsMobile and Items.Sidebar.Instance or nil)

        Items.HubIcon = Library:Create("ImageLabel", {
            Parent = Items.Sidebar.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, 10),
            Size = UDim2.fromOffset(63, 60),
            BorderSizePixel = 0
        })
        ApplyIcon(Items.HubIcon.Instance, Window.Icon)

        Items.PagesHolder = Library:Create("ScrollingFrame", {
            Parent = Items.Sidebar.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            Selectable = false,
            ClipsDescendants = false,
            Position = UDim2.fromOffset(0, 75),
            Size = UDim2.fromOffset(80, H - 145),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0
        })

        Items.UserProfile = Library:Create("ImageLabel", {
            Parent = Items.Sidebar.Instance,
            Name = "\0",
            BackgroundColor3 = Library.Theme.Section,
            Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=48&h=48",
            Position = UDim2.fromOffset(22, H - 55),
            Size = UDim2.fromOffset(35, 35),
            BorderSizePixel = 0
        }):AddToTheme({ BackgroundColor3 = "Section" })

        Library:Create("UICorner", { Parent = Items.UserProfile.Instance, CornerRadius = UDim.new(1, 0) })

        Items.ProfileHit = Library:Create("TextButton", {
            Parent = Items.UserProfile.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 2,
            BorderSizePixel = 0
        })

        Items.SubPageFrame = Library:Create("Frame", {
            Parent = Items.MainFrame.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(80, 15),
            Size = UDim2.fromOffset(W - 95, H - 30),
            BorderSizePixel = 0
        })

        Library:Create("UICorner", { Parent = Items.SubPageFrame.Instance, CornerRadius = UDim.new(0, 7) })
        Library:Create("UIStroke", {
            Parent = Items.SubPageFrame.Instance,
            Color = Library.Theme.Line
        }):AddToTheme({ Color = "Line" })

        Library:Create("Frame", {
            Parent = Items.SubPageFrame.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(0, 45),
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Line
        }):AddToTheme({ BackgroundColor3 = "Line" })

        Items.Title = Library:Create("TextLabel", {
            Parent = Items.SubPageFrame.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "Page / SubPage",
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 3),
            Size = UDim2.fromOffset(300, 21),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Items.Description = Library:Create("TextLabel", {
            Parent = Items.SubPageFrame.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.DimText,
            Text = "Customize the description as you want",
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 18),
            Size = UDim2.fromOffset(300, 21),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "DimText" })

        Items.Changer = Library:Create("Frame", {
            Parent = Items.SubPageFrame.Instance,
            Name = "\0",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 11),
            Size = UDim2.fromOffset(140, 25),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Section
        }):AddToTheme({ BackgroundColor3 = "Section" })

        Library:Create("UICorner", { Parent = Items.Changer.Instance, CornerRadius = UDim.new(0, 3) })

        Items.ChangerText = Library:Create("TextLabel", {
            Parent = Items.Changer.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "SubPage",
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, -1),
            Size = UDim2.fromOffset(105, 25),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Items.ChangerArrow = Library:Create("ImageLabel", {
            Parent = Items.Changer.Instance,
            Name = "\0",
            Image = "rbxassetid://127296511745226",
            ImageColor3 = Library.Theme.DimText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(120, 6),
            Size = UDim2.fromOffset(13, 13),
            BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "DimText" })

        Items.ChangerButton = Library:Create("TextButton", {
            Parent = Items.Changer.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0
        })

        Window.Items = Items

        Window.ChangerPopup = MakeOptionPopup(function()
            return Items.Changer.Instance
        end)

        Window.ChangerPopup.OnState = function(Open)
            Items.ChangerArrow:Tween({ Rotation = Open and 180 or 0 })
        end

        Window.ChangerPopup.OnPick = function(Data)
            for _, Other in Window.ChangerPopup.Order do
                Other:Set(Other == Data, true)
            end
            Window.ChangerPopup:SetOpen(false)
            if Window.CurrentPage and Data.SubPage then
                Window.CurrentPage:ShowSub(Data.SubPage)
            end
        end

        Items.ChangerButton:Connect("MouseButton1Down", function()
            if Window.ChangerPopup.Debounce then return end

            if not Window.ChangerPopup.IsOpen then
                local Page = Window.CurrentPage
                Window.ChangerPopup:Clear()
                if Page then
                    for _, Value in Page.SubPages do
                        local Row = Window.ChangerPopup:AddRow(Value.Name)
                        Row.SubPage = Value
                        Row:Set(Value == Page.Current, true)
                    end
                end
            end

            Window.ChangerPopup:SetOpen(not Window.ChangerPopup.IsOpen)
        end)

        local Profile = { IsOpen = false, Debounce = false }
        local ProfilePanel = Library:Create("Frame", {
            Parent = Library.UnusedHolder.Instance,
            Name = "\0",
            Visible = false,
            Size = UDim2.fromOffset(200, 150),
            ZIndex = 45,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Section
        }):AddToTheme({ BackgroundColor3 = "Section" })

        Library:Create("UICorner", { Parent = ProfilePanel.Instance, CornerRadius = UDim.new(0, 6) })

        Library:Create("TextLabel", {
            Parent = ProfilePanel.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "UI Settings",
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 4),
            Size = UDim2.fromOffset(180, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 46,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Library:Create("TextLabel", {
            Parent = ProfilePanel.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.DimText,
            Text = "UI Scale",
            TextSize = 13,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 28),
            Size = UDim2.fromOffset(180, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 46,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "DimText" })

        local ScaleFrame = Library:Create("Frame", {
            Parent = ProfilePanel.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(10, 50),
            Size = UDim2.fromOffset(180, 26),
            ZIndex = 46,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ BackgroundColor3 = "Element" })

        Library:Create("UICorner", { Parent = ScaleFrame.Instance, CornerRadius = UDim.new(0, 4) })

        local ScaleText = Library:Create("TextLabel", {
            Parent = ScaleFrame.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "100%",
            TextSize = 13,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.fromOffset(140, 26),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 47,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        local ScaleArrow = Library:Create("ImageLabel", {
            Parent = ScaleFrame.Instance,
            Name = "\0",
            Image = "rbxassetid://127296511745226",
            ImageColor3 = Library.Theme.DimText,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -19, 0, 6),
            Size = UDim2.fromOffset(13, 13),
            ZIndex = 47,
            BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "DimText" })

        local ScaleHit = Library:Create("TextButton", {
            Parent = ScaleFrame.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 48,
            BorderSizePixel = 0
        })

        local ScaleDropdown = MakeOptionPopup(function()
            return ScaleFrame.Instance
        end, 50)

        ScaleDropdown.Host = Profile

        ScaleDropdown.OnState = function(Open)
            ScaleArrow:Tween({ Rotation = Open and 180 or 0 })
        end

        for _, Value in { "50%", "70%", "100%", "125%", "150%" } do
            local Row = ScaleDropdown:AddRow(Value)
            Row:Set(Value == "100%", true)
        end

        ScaleDropdown.OnPick = function(Data)
            for _, Other in ScaleDropdown.Order do
                Other:Set(Other == Data, true)
            end
            ScaleText.Instance.Text = Data.Name
            ScaleDropdown:SetOpen(false)
            local Value = tonumber((Data.Name:gsub("%%", ""))) or 100
            Library:SetUIScale(Value / 100)
        end

        ScaleHit:Connect("MouseButton1Down", function()
            if ScaleDropdown.Debounce then return end
            ScaleDropdown:SetOpen(not ScaleDropdown.IsOpen)
        end)

        local function ProfileToggle(Y, Text, Get, Set)
            local Row = Library:Create("Frame", {
                Parent = ProfilePanel.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(10, Y),
                Size = UDim2.fromOffset(180, 24),
                ZIndex = 46,
                BorderSizePixel = 0
            })

            local Label = Library:Create("TextLabel", {
                Parent = Row.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.DimText,
                Text = Text,
                TextSize = 13,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.fromOffset(140, 24),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 47,
                BorderSizePixel = 0
            }):AddToTheme({ TextColor3 = "DimText" })

            local Back = Library:Create("Frame", {
                Parent = Row.Instance,
                Name = "\0",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(27, 16),
                ZIndex = 47,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Element
            }):AddToTheme({ BackgroundColor3 = "Element" })

            Library:Create("UICorner", { Parent = Back.Instance, CornerRadius = UDim.new(1, 0) })

            local Circle = Library:Create("Frame", {
                Parent = Back.Instance,
                Name = "\0",
                Position = UDim2.fromOffset(3, 3),
                Size = UDim2.fromOffset(10, 10),
                ZIndex = 48,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.ToggleOffCircle
            }):AddToTheme({ BackgroundColor3 = "ToggleOffCircle" })

            Library:Create("UICorner", { Parent = Circle.Instance, CornerRadius = UDim.new(1, 0) })

            local Hit = Library:Create("TextButton", {
                Parent = Row.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 49,
                BorderSizePixel = 0
            })

            local function Update()
                local Active = Get()

                if Active then
                    Back:ChangeItemTheme({ BackgroundColor3 = "ToggleOn" })
                    Circle:ChangeItemTheme({ BackgroundColor3 = "Accent" })
                    Label:ChangeItemTheme({ TextColor3 = "Text" })
                    Back:Tween({ BackgroundColor3 = Library.Theme.ToggleOn })
                    Circle:Tween({ BackgroundColor3 = Library.Theme.Accent, Position = UDim2.fromOffset(14, 3) })
                    Label:Tween({ TextColor3 = Library.Theme.Text })
                else
                    Back:ChangeItemTheme({ BackgroundColor3 = "Element" })
                    Circle:ChangeItemTheme({ BackgroundColor3 = "ToggleOffCircle" })
                    Label:ChangeItemTheme({ TextColor3 = "DimText" })
                    Back:Tween({ BackgroundColor3 = Library.Theme.Element })
                    Circle:Tween({ BackgroundColor3 = Library.Theme.ToggleOffCircle, Position = UDim2.fromOffset(3, 3) })
                    Label:Tween({ TextColor3 = Library.Theme.DimText })
                end
            end

            Hit:Connect("MouseButton1Down", function()
                Set(not Get())
                Update()
            end)

            Update()
        end

        ProfileToggle(84, "Hide Notifications", function()
            return Library.NotifsHidden
        end, function(Value)
            Library.NotifsHidden = Value
        end)

        ProfileToggle(116, "Hide Watermark", function()
            return Library.WatermarkHidden
        end, function(Value)
            Library.WatermarkHidden = Value
            if Library.WatermarkBar then
                Library.WatermarkBar:FadeDescendants(not Value)
            end
        end)

        local function ProfilePlace(Extra)
            local Anchor = Items.UserProfile.Instance
            local Scale = Library:GetScreenScale()
            local X = (Anchor.AbsolutePosition.X + Anchor.AbsoluteSize.X) / Scale + 10
            local Y = (Anchor.AbsolutePosition.Y + Anchor.AbsoluteSize.Y + GuiInset) / Scale - 150
            return UDim2.fromOffset(X, Y + (Extra or 0))
        end

        function Profile:SetOpen(Bool)
            if Profile.Debounce then return end
            Profile.IsOpen = Bool
            Profile.Debounce = true

            if Bool then
                ProfilePanel.Instance.Parent = Library.Holder.Instance
                ProfilePanel.Instance.Position = ProfilePlace(6)
                ProfilePanel.Instance.Visible = true
                Library.TouchShields[ProfilePanel.Instance] = 45
                Library:SetDim(true)
                ProfilePanel:Tween({ Position = ProfilePlace(-4) })

                for _, Value in Library.OpenFrames do
                    if Value ~= Profile then Value:SetOpen(false) end
                end
                Library.OpenFrames[Profile] = Profile

                ProfilePanel:FadeDescendants(true, function()
                    Profile.Debounce = false
                end)
            else
                Library.OpenFrames[Profile] = nil
                Library:SetDim(false)

                for _, Value in Library.OpenFrames do
                    if Value.Host == Profile then Value:SetOpen(false) end
                end

                local Current = ProfilePanel.Instance.Position
                ProfilePanel:Tween({ Position = UDim2.fromOffset(Current.X.Offset, Current.Y.Offset + 8) })
                ProfilePanel:FadeDescendants(false, function()
                    Profile.Debounce = false
                    Library.TouchShields[ProfilePanel.Instance] = nil
                    ProfilePanel.Instance.Parent = Library.UnusedHolder.Instance
                end)
            end
        end

        Items.ProfileHit:Connect("MouseButton1Down", function()
            Profile:SetOpen(not Profile.IsOpen)
        end)

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if Profile.IsOpen and not ScaleDropdown.IsOpen and not ProfilePanel:IsMouseOverFrame() and not IsOverObject(Items.UserProfile.Instance) then
                    Profile:SetOpen(false)
                end
            end
        end)

        function Window:SetOpen(Bool)
            Window.IsOpen = Bool
            if not Bool then
                Library:CloseAllPopups()
            end
            Items.MainFrame:FadeDescendants(Bool)
            if Items.MobileText then
                Items.MobileText.Instance.Text = Bool and "Close" or "Open"
            end
        end

        Library:Connect(UserInputService.InputBegan, function(Input, Processed)
            if Processed then return end
            if Input.KeyCode == Library.MenuKeybind then
                Window:SetOpen(not Window.IsOpen)
            end
        end)

        function Window:Center()
            local CScale = Library:GetScreenScale()
            local Vp = workspace.CurrentCamera.ViewportSize
            Items.MainFrame.Instance.Position = UDim2.fromOffset(Vp.X / (2 * CScale) - W / 2, Vp.Y / (2 * CScale) - H / 2)
        end

        function Window:UpdateHeader()
            local Page = Window.CurrentPage
            if not Page then return end
            local Sub = Page.Current
            Items.Title.Instance.Text = Page.Name .. (Sub and (" / " .. Sub.Name) or "")
            Items.Description.Instance.Text = Page.Description
            Items.ChangerText.Instance.Text = Sub and Sub.Name or "SubPage"
        end

        function Window:Watermark(WParams)
            WParams = WParams or { }

            local WItems = { }
            local BarHeight = IsMobile and 26 or 38
            local BarText = IsMobile and 12 or 15
            local BarPad = IsMobile and 12 or 22
            local BarGap = IsMobile and 10 or 16

            WItems.Bar = Library:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "\0",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -15, 0, IsMobile and 8 or 12),
                Size = UDim2.fromOffset(0, BarHeight),
                AutomaticSize = Enum.AutomaticSize.X,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Background
            }):AddToTheme({ BackgroundColor3 = "Background" })

            Library:Create("UICorner", { Parent = WItems.Bar.Instance, CornerRadius = UDim.new(0, 8) })
            Library:Create("UIStroke", {
                Parent = WItems.Bar.Instance,
                Color = Library.Theme.Line
            }):AddToTheme({ Color = "Line" })

            Library:Create("UIPadding", {
                Parent = WItems.Bar.Instance,
                PaddingLeft = UDim.new(0, BarPad),
                PaddingRight = UDim.new(0, BarPad)
            })

            Library:Create("UIListLayout", {
                Parent = WItems.Bar.Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, BarGap),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            local IconSize = IsMobile and 12 or 14
            local CurrentLayoutOrder = 1

            local HubIconSize = IsMobile and 18 or 24
            local HubIcon = Library:Create("ImageLabel", {
                Parent = WItems.Bar.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                ImageColor3 = Color3.new(1, 1, 1),
                Size = UDim2.fromOffset(HubIconSize, HubIconSize),
                ScaleType = Enum.ScaleType.Fit,
                LayoutOrder = CurrentLayoutOrder,
                BorderSizePixel = 0
            })
            CurrentLayoutOrder += 1

            ApplyIcon(HubIcon.Instance, WParams.Icon or "infinity")
            WItems.Hub = HubIcon

            WItems.Line = Library:Create("Frame", {
                Parent = WItems.Bar.Instance,
                Name = "\0",
                BackgroundColor3 = Library.Theme.Accent,
                Size = UDim2.new(0, 2, 0, BarHeight),
                LayoutOrder = CurrentLayoutOrder,
                BorderSizePixel = 0
            }):AddToTheme({ BackgroundColor3 = "Accent" })
            CurrentLayoutOrder += 1

            WItems.Bar:MakeDraggable()

            if Library.WatermarkHidden then
                WItems.Bar.Instance.Visible = false
            end

            Library.WatermarkBar = WItems.Bar
            Window.Watermarks = WItems

            local WatermarkAPI = {
                Bar = WItems.Bar,
                Labels = { }
            }

            function WatermarkAPI:AddLabel(Params)
                local LabelData = { }
                local Container = Library:Create("Frame", {
                    Parent = WItems.Bar.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(0, BarHeight),
                    AutomaticSize = Enum.AutomaticSize.X,
                    LayoutOrder = CurrentLayoutOrder,
                    BorderSizePixel = 0
                })
                CurrentLayoutOrder += 1

                Library:Create("UIListLayout", {
                    Parent = Container.Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, IsMobile and 4 or 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                local Icon = Library:Create("ImageLabel", {
                    Parent = Container.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    ImageColor3 = Library.Theme.Text,
                    Size = UDim2.fromOffset(IconSize, IconSize),
                    LayoutOrder = 1,
                    BorderSizePixel = 0
                }):AddToTheme({ ImageColor3 = "Text" })
                ApplyIcon(Icon.Instance, Params.Icon)

                local Label = Library:Create("TextLabel", {
                    Parent = Container.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    Text = Params.Text or "",
                    TextSize = BarText,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(0, BarHeight),
                    AutomaticSize = Enum.AutomaticSize.X,
                    LayoutOrder = 2,
                    BorderSizePixel = 0
                }):AddToTheme({ TextColor3 = "Text" })

                LabelData.Container = Container
                LabelData.Icon = Icon
                LabelData.Label = Label

                function LabelData:SetText(NewText)
                    Label.Instance.Text = NewText
                end

                function LabelData:SetIcon(NewIcon)
                    ApplyIcon(Icon.Instance, NewIcon)
                end

                function LabelData:Destroy()
                    Container.Instance:Destroy()
                    for i, v in WatermarkAPI.Labels do
                        if v == LabelData then
                            table.remove(WatermarkAPI.Labels, i)
                            break
                        end
                    end
                end

                table.insert(WatermarkAPI.Labels, LabelData)
                return LabelData
            end

            return WatermarkAPI
        end

        if IsMobile then
            Items.MobileToggle = Library:Create("TextButton", {
                Parent = Library.Holder.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 8),
                Size = UDim2.fromOffset(90, 32),
                ZIndex = 90,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Background
            }):AddToTheme({ BackgroundColor3 = "Background" })

            Library:Create("UICorner", { Parent = Items.MobileToggle.Instance, CornerRadius = UDim.new(0, 8) })
            Library:Create("UIStroke", {
                Parent = Items.MobileToggle.Instance,
                Color = Library.Theme.Line
            }):AddToTheme({ Color = "Line" })

            Items.MobileText = Library:Create("TextLabel", {
                Parent = Items.MobileToggle.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.Text,
                Text = "Close",
                TextSize = 14,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 91,
                BorderSizePixel = 0
            }):AddToTheme({ TextColor3 = "Text" })

            Items.MobileToggle:Connect("MouseButton1Down", function()
                Window:SetOpen(not Window.IsOpen)
            end)
        end

        table.insert(Library.Windows, Window)
        return setmetatable(Window, Library)
    end

    Library.Page = function(Self, Params)
        Params = Params or { }

        local Window = Self
        local Page = {
            Name = Params.Name or "Page",
            Icon = Params.Icon or "house",
            Description = Params.Description or "Customize the description as you want",
            Window = Window,
            SubPages = { },
            Current = nil,
            Active = false,
            Items = { }
        }

        local Items = { }
        local Index = #Window.Pages

        Items.Button = Library:Create("Frame", {
            Parent = Window.Items.PagesHolder.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, Index * 55),
            Size = UDim2.fromOffset(50, 50),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Section
        }):AddToTheme({ BackgroundColor3 = "Section" })

        Library:Create("UICorner", { Parent = Items.Button.Instance, CornerRadius = UDim.new(0, 3) })

        Items.Icon = Library:Create("ImageLabel", {
            Parent = Items.Button.Instance,
            Name = "\0",
            ImageColor3 = Library.Theme.DimIcon,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, 15),
            Size = UDim2.fromOffset(20, 20),
            BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "DimIcon" })
        ApplyIcon(Items.Icon.Instance, Page.Icon)

        Items.Hit = Library:Create("TextButton", {
            Parent = Items.Button.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0
        })

        Page.Items = Items

        Items.Hit:Connect("MouseButton1Down", function()
            Page:Select()
        end)

        Items.Button:OnHover(function()
            if Page.Active then return end
            Items.Icon:Tween({ ImageColor3 = Library.Theme.Accent })
        end, function()
            if Page.Active then return end
            Items.Icon:Tween({ ImageColor3 = Library.Theme.DimIcon })
        end)

        function Page:SetVisual(Active)
            Page.Active = Active
            if Active then
                Items.Icon:ChangeItemTheme({ ImageColor3 = "Accent" })
                Items.Button:Tween({ BackgroundTransparency = 0 })
                Items.Icon:Tween({ ImageColor3 = Library.Theme.Accent })
            else
                Items.Icon:ChangeItemTheme({ ImageColor3 = "DimIcon" })
                Items.Button:Tween({ BackgroundTransparency = 1 })
                Items.Icon:Tween({ ImageColor3 = Library.Theme.DimIcon })
            end
        end

        function Page:ShowSub(Sub)
            if Page.Current == Sub and Sub.Active then
                Page.Window:UpdateHeader()
                return
            end
            Library:CloseAllPopups()
            if Page.Current and Page.Current ~= Sub then
                Page.Current:Hide()
            end
            Page.Current = Sub
            Sub:Show()
            Page.Window:UpdateHeader()
        end

        function Page:Select()
            local Window = Page.Window
            if Window.CurrentPage == Page then return end
            Library:CloseAllPopups()

            if Window.CurrentPage then
                Window.CurrentPage:SetVisual(false)
                if Window.CurrentPage.Current then
                    Window.CurrentPage.Current:Hide()
                end
            end

            Window.CurrentPage = Page
            Page:SetVisual(true)

            local Sub = Page.Current or Page.SubPages[1]
            if Sub then
                Page.Current = Sub
                Sub:Show()
            end

            Window:UpdateHeader()
        end

        table.insert(Window.Pages, Page)

        if #Window.Pages == 1 then
            task.defer(function()
                Page:Select()
            end)
        end

        return setmetatable(Page, Library)
    end

    Library.SubPage = function(Self, Params)
        Params = Params or { }

        local Page = Self
        local SubPage = {
            Name = Params.Name or "SubPage",
            OneColumn = Params.OneColumn or false,
            Page = Page,
            Active = false,
            Sections = { },
            Toggles = { },
            Columns = { },
            Items = { }
        }

        local Items = { }
        local ContentW = Library.WindowWidth - 95
        local ContentH = Library.WindowHeight - 76

        Items.Content = Library:Create("Frame", {
            Parent = Library.UnusedHolder.Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.fromOffset(0, 46),
            Size = UDim2.fromOffset(ContentW, ContentH),
            Visible = false,
            BorderSizePixel = 0
        })

        local function MakeColumn(X, Width)
            local Holder = Library:Create("ScrollingFrame", {
                Parent = Items.Content.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Selectable = false,
                Active = true,
                Position = UDim2.fromOffset(X, 9),
                Size = UDim2.fromOffset(Width, ContentH - 19),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0
            })

            local Column = { Holder = Holder, Width = Width, Sections = { } }

            function Column:Reflow()
                local Y = 0
                for _, Section in Column.Sections do
                    Section.Y = Y
                    Section.Items.Section.Instance.Position = UDim2.fromOffset(0, Y)
                    Y += Section.Height + 10
                end
                Holder.Instance.CanvasSize = UDim2.fromOffset(0, Y)
            end

            return Column
        end

        if SubPage.OneColumn then
            local Column = MakeColumn(10, ContentW - 20)
            SubPage.Columns[1] = Column
            SubPage.Columns[2] = Column
        else
            local Half = math.floor((ContentW - 31) / 2)
            SubPage.Columns[1] = MakeColumn(10, Half)
            SubPage.Columns[2] = MakeColumn(21 + Half, Half)
        end

        SubPage.Items = Items

        function SubPage:Show()
            SubPage.Active = true
            Items.Content.Instance.Parent = Page.Window.Items.SubPageFrame.Instance
            Items.Content:ResetFade()
            Items.Content.Instance.Visible = true

            for _, Section in SubPage.Sections do
                local Frame = Section.Items.Section.Instance
                Frame.Position = UDim2.fromOffset(35, Section.Y)
                Frame.Size = UDim2.fromOffset(Section.Width + 45, Section.Height)
                Section.Items.Section:FadeDescendants(true)
                Section.Items.Section:Tween({
                    Position = UDim2.fromOffset(0, Section.Y),
                    Size = UDim2.fromOffset(Section.Width, Section.Height)
                }, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            end

            for _, Toggle in SubPage.Toggles do
                Toggle.SetVisual(false, true)
                if Toggle.Value then
                    task.delay(0.2, function()
                        if SubPage.Active and Toggle.Value then
                            Toggle.SetVisual(true, false)
                        end
                    end)
                end
            end

            if SubPage.CustomShow then
                SubPage.CustomShow()
            end
        end

        function SubPage:Hide()
            SubPage.Active = false
            Items.Content:ResetFade()
            Items.Content.Instance.Visible = false
            Items.Content.Instance.Parent = Library.UnusedHolder.Instance
        end

        table.insert(Page.SubPages, SubPage)

        if Params.Default and not Page.Active then
            Page.Current = SubPage
        end

        if Page.Active and #Page.SubPages == 1 then
            Page:ShowSub(SubPage)
        end

        return setmetatable(SubPage, Library)
    end

    Library.Section = function(Self, Params)
        Params = Params or { }

        local SubPage = Self
        local Column = SubPage.Columns[Params.Side or 1]

        local Section = {
            Name = Params.Name or "Section",
            SubPage = SubPage,
            Column = Column,
            Width = Column.Width,
            Y = 0,
            Height = 50,
            NextY = 40,
            Items = { }
        }

        local Items = { }

        Items.Section = Library:Create("Frame", {
            Parent = Column.Holder.Instance,
            Name = "\0",
            Size = UDim2.fromOffset(Column.Width, 50),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Section
        }):AddToTheme({ BackgroundColor3 = "Section" })

        Library:Create("UICorner", { Parent = Items.Section.Instance, CornerRadius = UDim.new(0, 3) })

        Items.Line = Library:Create("Frame", {
            Parent = Items.Section.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(0, 30),
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Line
        }):AddToTheme({ BackgroundColor3 = "Line" })

        Items.Title = Library:Create("TextLabel", {
            Parent = Items.Section.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Section.Name,
            TextSize = 15,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, -2),
            Size = UDim2.fromOffset(200, 30),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Section.Items = Items

        function Section:AddRow(Height)
            local Row = Library:Create("Frame", {
                Parent = Items.Section.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, Section.NextY),
                Size = UDim2.new(1, 0, 0, Height),
                BorderSizePixel = 0
            })

            Section.NextY += Height + 5
            Section.Height = Section.NextY + 5
            Items.Section.Instance.Size = UDim2.fromOffset(Section.Width, Section.Height)
            Section.Column:Reflow()

            return Row
        end

        table.insert(SubPage.Sections, Section)
        table.insert(Column.Sections, Section)
        Column:Reflow()

        return setmetatable(Section, Library)
    end

    Library.Toggle = function(Self, Params)
        Params = Params or { }

        local Section = Self
        local Toggle = {
            Name = Params.Name or "Toggle",
            Default = Params.Default or false,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = false,
            Items = { }
        }

        local Row = Section:AddRow(20)
        local Items = { Row = Row }

        Items.Name = Library:Create("TextLabel", {
            Parent = Row.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Toggle.Name,
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, -1),
            Size = UDim2.new(1, -140, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Items.Background = Library:Create("Frame", {
            Parent = Row.Instance,
            Name = "\0",
            Position = UDim2.new(1, -42, 0, 2),
            Size = UDim2.fromOffset(27, 16),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ BackgroundColor3 = "Element" })

        Library:Create("UICorner", { Parent = Items.Background.Instance, CornerRadius = UDim.new(1, 0) })

        Items.Shadow = Library:Create("ImageLabel", {
            Parent = Items.Background.Instance,
            Name = "\0",
            Image = "rbxassetid://118035861931517",
            ImageColor3 = Library.Theme.Accent,
            ImageTransparency = 1,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(9, -2),
            Size = UDim2.fromOffset(20, 20),
            BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "Accent" })

        Items.Circle = Library:Create("Frame", {
            Parent = Items.Background.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(3, 3),
            Size = UDim2.fromOffset(10, 10),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.ToggleOffCircle
        }):AddToTheme({ BackgroundColor3 = "ToggleOffCircle" })

        Library:Create("UICorner", { Parent = Items.Circle.Instance, CornerRadius = UDim.new(1, 0) })

        Items.Hit = Library:Create("TextButton", {
            Parent = Row.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            BorderSizePixel = 0
        })

        Toggle.Items = Items

        function Toggle.SetVisual(State, Instant)
            local Info = Instant and TweenInfo.new(0) or TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            Library:StampResting(Items.Shadow.Instance, "ImageTransparency", State and 0.2 or 1)

            if State then
                Items.Background:ChangeItemTheme({ BackgroundColor3 = "ToggleOn" })
                Items.Circle:ChangeItemTheme({ BackgroundColor3 = "Accent" })
                Library:Tween({ BackgroundColor3 = Library.Theme.ToggleOn }, Info, Items.Background.Instance)
                Library:Tween({ BackgroundColor3 = Library.Theme.Accent, Position = UDim2.fromOffset(14, 3) }, Info, Items.Circle.Instance)
                Library:Tween({ ImageTransparency = 0.2 }, Info, Items.Shadow.Instance)
            else
                Items.Background:ChangeItemTheme({ BackgroundColor3 = "Element" })
                Items.Circle:ChangeItemTheme({ BackgroundColor3 = "ToggleOffCircle" })
                Library:Tween({ BackgroundColor3 = Library.Theme.Element }, Info, Items.Background.Instance)
                Library:Tween({ BackgroundColor3 = Library.Theme.ToggleOffCircle, Position = UDim2.fromOffset(3, 3) }, Info, Items.Circle.Instance)
                Library:Tween({ ImageTransparency = 1 }, Info, Items.Shadow.Instance)
            end
        end

        function Toggle:Set(Bool)
            Toggle.Value = Bool

            if Toggle.Flag then
                Library.Flags[Toggle.Flag] = Bool
            end

            Toggle.SetVisual(Bool, false)
            Library:SafeCall(Toggle.Callback, Bool)
        end

        function Toggle:Get()
            return Toggle.Value
        end

        function Toggle:Keybind(KeyParams)
            KeyParams = KeyParams or { }

            local Keybind = {
                Key = KeyParams.Default,
                Mode = KeyParams.Mode or "Toggle",
                Flag = KeyParams.Flag,
                IsOpen = false,
                Debounce = false,
                Picking = false
            }

            Items.Name.Instance.Size = UDim2.new(1, -110, 0, 20)

            local KeyIcon = Library:Create("ImageButton", {
                Parent = Row.Instance,
                Name = "\0",
                AutoButtonColor = false,
                Image = "rbxassetid://123677974615593",
                ImageColor3 = Library.Theme.DimText,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -68, 0, 1),
                Size = UDim2.fromOffset(18, 18),
                ZIndex = 4,
                BorderSizePixel = 0
            }):AddToTheme({ ImageColor3 = "DimText" })

            local Panel = Library:Create("Frame", {
                Parent = Library.UnusedHolder.Instance,
                Name = "\0",
                Visible = false,
                Size = UDim2.fromOffset(200, 108),
                ZIndex = 45,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Section
            }):AddToTheme({ BackgroundColor3 = "Section" })

            Library:Create("UICorner", { Parent = Panel.Instance, CornerRadius = UDim.new(0, 6) })

            Library:Create("TextLabel", {
                Parent = Panel.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.Text,
                Text = "\"" .. Toggle.Name .. "\"",
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(10, 4),
                Size = UDim2.fromOffset(180, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 46,
                BorderSizePixel = 0
            }):AddToTheme({ TextColor3 = "Text" })

            local KeyButton = Library:Create("TextButton", {
                Parent = Panel.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.Text,
                Text = "None",
                TextSize = 14,
                AutoButtonColor = false,
                Position = UDim2.fromOffset(10, 30),
                Size = UDim2.fromOffset(180, 30),
                ZIndex = 46,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Element
            }):AddToTheme({ BackgroundColor3 = "Element", TextColor3 = "Text" })

            Library:Create("UICorner", { Parent = KeyButton.Instance, CornerRadius = UDim.new(0, 4) })

            local function MakeModeButton(Text, X)
                local Button = Library:Create("TextButton", {
                    Parent = Panel.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.DimText,
                    Text = Text,
                    TextSize = 13,
                    AutoButtonColor = false,
                    Position = UDim2.fromOffset(X, 68),
                    Size = UDim2.fromOffset(87, 30),
                    ZIndex = 46,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Element
                }):AddToTheme({ BackgroundColor3 = "Element", TextColor3 = "DimText" })

                Library:Create("UICorner", { Parent = Button.Instance, CornerRadius = UDim.new(0, 4) })
                return Button
            end

            local ToggleMode = MakeModeButton("Toggle", 10)
            local HoldMode = MakeModeButton("Hold", 103)

            local function KeyName(Key)
                if not Key then return "None" end
                return tostring(Key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
            end

            local function SaveFlag()
                if Keybind.Flag then
                    Library.Flags[Keybind.Flag] = { Key = Keybind.Key and tostring(Keybind.Key) or "None", Mode = Keybind.Mode }
                end
            end

            function Keybind:SetMode(Mode)
                Keybind.Mode = Mode

                local Active = Mode == "Toggle" and ToggleMode or HoldMode
                local Inactive = Mode == "Toggle" and HoldMode or ToggleMode

                Active:ChangeItemTheme({ BackgroundColor3 = "Accent", TextColor3 = "Text" })
                Active:Tween({ BackgroundColor3 = Library.Theme.Accent, TextColor3 = Library.Theme.Text })
                Inactive:ChangeItemTheme({ BackgroundColor3 = "Element", TextColor3 = "DimText" })
                Inactive:Tween({ BackgroundColor3 = Library.Theme.Element, TextColor3 = Library.Theme.DimText })

                SaveFlag()
            end

            function Keybind:Set(Key)
                Keybind.Key = Key
                KeyButton.Instance.Text = KeyName(Key)
                Keybind.Picking = false
                SaveFlag()
            end

            local function PanelPlace(Extra)
                local Scale = Library:GetScreenScale()
                local A = KeyIcon.Instance
                local X = (A.AbsolutePosition.X + A.AbsoluteSize.X) / Scale - 200
                return UDim2.fromOffset(X, (A.AbsolutePosition.Y + A.AbsoluteSize.Y + GuiInset) / Scale + (Extra or 0))
            end

            function Keybind:SetOpen(Bool)
                if Keybind.Debounce then return end
                Keybind.IsOpen = Bool
                Keybind.Debounce = true

                if Bool then
                    KeyIcon:ChangeItemTheme({ ImageColor3 = "Accent" })
                    KeyIcon:Tween({ ImageColor3 = Library.Theme.Accent })

                    Panel.Instance.Parent = Library.Holder.Instance
                    Panel.Instance.Position = PanelPlace(-6)
                    Panel.Instance.Visible = true
                    Library.TouchShields[Panel.Instance] = 45
                    Library:SetDim(true)
                    Panel:Tween({ Position = PanelPlace(4) })

                    for _, Value in Library.OpenFrames do
                        if Value ~= Keybind then Value:SetOpen(false) end
                    end
                    Library.OpenFrames[Keybind] = Keybind

                    Panel:FadeDescendants(true, function()
                        Keybind.Debounce = false
                    end)
                else
                    KeyIcon:ChangeItemTheme({ ImageColor3 = "DimText" })
                    KeyIcon:Tween({ ImageColor3 = Library.Theme.DimText })

                    Library.OpenFrames[Keybind] = nil
                    Library:SetDim(false)
                    local Current = Panel.Instance.Position
                    Panel:Tween({ Position = UDim2.fromOffset(Current.X.Offset, Current.Y.Offset - 8) })
                    Panel:FadeDescendants(false, function()
                        Keybind.Debounce = false
                        Library.TouchShields[Panel.Instance] = nil
                        Panel.Instance.Parent = Library.UnusedHolder.Instance
                    end)
                end
            end

            KeyIcon:Connect("MouseButton1Down", function()
                Keybind:SetOpen(not Keybind.IsOpen)
            end)

            KeyButton:Connect("MouseButton1Click", function()
                if Keybind.Picking then return end
                Keybind.Picking = true
                KeyButton.Instance.Text = ". . ."

                task.wait()

                local Connection
                Connection = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement then return end
                    Connection:Disconnect()
                    if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Escape then
                        Keybind:Set(nil)
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        Keybind:Set(Input.KeyCode)
                    else
                        Keybind:Set(Input.UserInputType)
                    end
                end)
            end)

            ToggleMode:Connect("MouseButton1Down", function()
                Keybind:SetMode("Toggle")
            end)

            HoldMode:Connect("MouseButton1Down", function()
                Keybind:SetMode("Hold")
            end)

            Library:Connect(UserInputService.InputBegan, function(Input, Processed)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Keybind.IsOpen and not Panel:IsMouseOverFrame() and not IsOverObject(KeyIcon.Instance) then
                        Keybind:SetOpen(false)
                    end
                end

                if Processed or Keybind.Picking or not Keybind.Key then return end
                if Input.KeyCode == Keybind.Key or Input.UserInputType == Keybind.Key then
                    if Keybind.Mode == "Hold" then
                        Toggle:Set(true)
                    else
                        Toggle:Set(not Toggle.Value)
                    end
                end
            end)

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Keybind.Mode ~= "Hold" or not Keybind.Key then return end
                if Input.KeyCode == Keybind.Key or Input.UserInputType == Keybind.Key then
                    Toggle:Set(false)
                end
            end)

            if Keybind.Flag then
                Library.SetFlags[Keybind.Flag] = function(Value)
                    if type(Value) ~= "table" then return end
                    if Value.Mode then
                        Keybind:SetMode(Value.Mode)
                    end
                    local KeyString = Value.Key
                    if type(KeyString) == "string" then
                        if KeyString == "None" then
                            Keybind:Set(nil)
                        else
                            local Name = KeyString:gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
                            local Ok, Key = pcall(function() return Enum.KeyCode[Name] end)
                            if Ok and Key then
                                Keybind:Set(Key)
                            else
                                local Ok2, Key2 = pcall(function() return Enum.UserInputType[Name] end)
                                if Ok2 and Key2 then Keybind:Set(Key2) end
                            end
                        end
                    end
                end
            end

            Keybind:SetMode(Keybind.Mode)
            Keybind:Set(Keybind.Key)
            return Keybind
        end

        Items.Hit:Connect("MouseButton1Down", function()
            Toggle:Set(not Toggle.Value)
        end)

        Toggle.Value = Toggle.Default
        if Toggle.Flag then
            Library.Flags[Toggle.Flag] = Toggle.Value
        end
        Toggle.SetVisual(Toggle.Value, true)
        Library:SafeCall(Toggle.Callback, Toggle.Value)

        if Toggle.Flag then
            Library.SetFlags[Toggle.Flag] = function(Value)
                Toggle:Set(Value)
            end
        end

        table.insert(Section.SubPage.Toggles, Toggle)
        return setmetatable(Toggle, Library)
    end

    local function BuildSliderBase(Section, Name)
        local Row = Section:AddRow(20)
        local Items = { Row = Row }

        Items.Name = Library:Create("TextLabel", {
            Parent = Row.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.DimText,
            Text = Name,
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, -1),
            Size = UDim2.new(1, -200, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "DimText" })

        Items.Value = Library:Create("TextLabel", {
            Parent = Row.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "",
            TextSize = 13,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -190, 0, -1),
            Size = UDim2.fromOffset(70, 20),
            TextXAlignment = Enum.TextXAlignment.Right,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Items.Track = Library:Create("Frame", {
            Parent = Row.Instance,
            Name = "\0",
            Position = UDim2.new(1, -116, 0, 2),
            Size = UDim2.fromOffset(110, 16),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ BackgroundColor3 = "Element" })

        Library:Create("UICorner", { Parent = Items.Track.Instance, CornerRadius = UDim.new(1, 0) })

        Items.Fill = Library:Create("Frame", {
            Parent = Items.Track.Instance,
            Name = "\0",
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.fromOffset(0, 16),
            BorderSizePixel = 0
        })

        Library:Create("UICorner", { Parent = Items.Fill.Instance, CornerRadius = UDim.new(1, 0) })

        local Gradient = Library:Create("UIGradient", { Parent = Items.Fill.Instance })
        Library:RegisterGradient(Gradient.Instance)

        Items.Hit = Library:Create("TextButton", {
            Parent = Row.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -150, 0, -2),
            Size = UDim2.fromOffset(140, 24),
            ZIndex = 3,
            BorderSizePixel = 0
        })

        return Items
    end

    local SliderDragInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    Library.Slider = function(Self, Params)
        Params = Params or { }

        local Section = Self
        local Slider = {
            Name = Params.Name or "Slider",
            Min = Params.Min or 0,
            Max = Params.Max or 100,
            Default = Params.Default or 0,
            Decimals = Params.Decimals or 1,
            Suffix = Params.Suffix or "",
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = 0,
            Sliding = false
        }

        local Items = BuildSliderBase(Section, Slider.Name)
        Slider.Items = Items

        Items.Drag = Library:Create("Frame", {
            Parent = Items.Fill.Instance,
            Name = "\0",
            BackgroundColor3 = Color3.new(1, 1, 1),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -2, 0.5, 0),
            Size = UDim2.fromOffset(12, 12),
            ZIndex = 2,
            BorderSizePixel = 0
        })

        Library:Create("UICorner", { Parent = Items.Drag.Instance, CornerRadius = UDim.new(1, 0) })

        function Slider:Set(Value)
            Slider.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Decimals)

            if Slider.Flag then
                Library.Flags[Slider.Flag] = Slider.Value
            end

            local Fraction = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)

            Library:Tween({ Size = UDim2.fromOffset(math.max(Fraction * 110, 16), 16) }, SliderDragInfo, Items.Fill.Instance)
            Items.Value.Instance.Text = tostring(Slider.Value) .. Slider.Suffix

            Library:SafeCall(Slider.Callback, Slider.Value)
        end

        function Slider:Get()
            return Slider.Value
        end

        local function Calculate(Input)
            local Fraction = math.clamp((Input.Position.X - Items.Track.Instance.AbsolutePosition.X) / Items.Track.Instance.AbsoluteSize.X, 0, 1)
            return Slider.Min + (Slider.Max - Slider.Min) * Fraction
        end

        local Watcher

        Items.Hit:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Slider.Sliding = true
                Slider:Set(Calculate(Input))

                if Watcher then return end
                Watcher = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Slider.Sliding = false
                        Watcher:Disconnect()
                        Watcher = nil
                    end
                end)
            end
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if Slider.Sliding then
                    Slider:Set(Calculate(Input))
                end
            end
        end)

        Slider:Set(Slider.Default)

        if Slider.Flag then
            Library.SetFlags[Slider.Flag] = function(Value)
                Slider:Set(Value)
            end
        end

        return setmetatable(Slider, Library)
    end

    Library.RangeSlider = function(Self, Params)
        Params = Params or { }

        local Section = Self
        local Slider = {
            Name = Params.Name or "Slider",
            Min = Params.Min or 0,
            Max = Params.Max or 100,
            Default = Params.Default,
            Decimals = Params.Decimals or 1,
            MinGap = Params.MinGap or Params.Decimals or 1,
            Suffix = Params.Suffix or "",
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = { 0, 0 },
            Grabbing = nil
        }

        Slider.Default = Slider.Default or { Slider.Min, Slider.Max }

        local Items = BuildSliderBase(Section, Slider.Name)
        Slider.Items = Items

        local function MakeDrag()
            local Drag = Library:Create("Frame", {
                Parent = Items.Track.Instance,
                Name = "\0",
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromOffset(0, 8),
                Size = UDim2.fromOffset(12, 12),
                ZIndex = 3,
                BorderSizePixel = 0
            })
            Library:Create("UICorner", { Parent = Drag.Instance, CornerRadius = UDim.new(1, 0) })
            return Drag
        end

        Items.MinDrag = MakeDrag()
        Items.MaxDrag = MakeDrag()

        function Slider:Set(MinValue, MaxValue, Instant)
            if type(MinValue) == "table" then
                MinValue, MaxValue = MinValue[1], MinValue[2]
            end

            MinValue = Library:Round(math.clamp(MinValue or Slider.Min, Slider.Min, Slider.Max), Slider.Decimals)
            MaxValue = Library:Round(math.clamp(MaxValue or Slider.Max, Slider.Min, Slider.Max), Slider.Decimals)

            if MinValue > MaxValue then
                MinValue, MaxValue = MaxValue, MinValue
            end

            Slider.Value = { MinValue, MaxValue }

            if Slider.Flag then
                Library.Flags[Slider.Flag] = Slider.Value
            end

            local MinF = (MinValue - Slider.Min) / (Slider.Max - Slider.Min)
            local MaxF = (MaxValue - Slider.Min) / (Slider.Max - Slider.Min)

            local FillGap = (MaxF - MinF) * 110
            local DragInset = math.min(8, FillGap / 2)

            if Instant then
                Items.Fill.Instance.Position = UDim2.fromOffset(MinF * 110, 0)
                Items.Fill.Instance.Size = UDim2.fromOffset((MaxF - MinF) * 110, 16)
                Items.MinDrag.Instance.Position = UDim2.fromOffset(MinF * 110 + DragInset, 8)
                Items.MaxDrag.Instance.Position = UDim2.fromOffset(MaxF * 110 - DragInset, 8)
            else
                Library:Tween({ Position = UDim2.fromOffset(MinF * 110, 0), Size = UDim2.fromOffset((MaxF - MinF) * 110, 16) }, SliderDragInfo, Items.Fill.Instance)
                Library:Tween({ Position = UDim2.fromOffset(MinF * 110 + DragInset, 8) }, SliderDragInfo, Items.MinDrag.Instance)
                Library:Tween({ Position = UDim2.fromOffset(MaxF * 110 - DragInset, 8) }, SliderDragInfo, Items.MaxDrag.Instance)
            end

            Items.Value.Instance.Text = tostring(MinValue) .. Slider.Suffix .. " - " .. tostring(MaxValue) .. Slider.Suffix

            Library:SafeCall(Slider.Callback, Slider.Value)
        end

        function Slider:Get()
            return Slider.Value
        end

        local function Apply(Input)
            local Fraction = math.clamp((Input.Position.X - Items.Track.Instance.AbsolutePosition.X) / Items.Track.Instance.AbsoluteSize.X, 0, 1)
            local Value = Slider.Min + (Slider.Max - Slider.Min) * Fraction

            if Slider.Grabbing == "Min" then
                Slider:Set(math.min(Value, Slider.Value[2] - Slider.MinGap), Slider.Value[2])
            else
                Slider:Set(Slider.Value[1], math.max(Value, Slider.Value[1] + Slider.MinGap))
            end
        end

        local Watcher

        Items.Hit:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                local Fraction = math.clamp((Input.Position.X - Items.Track.Instance.AbsolutePosition.X) / Items.Track.Instance.AbsoluteSize.X, 0, 1)
                local MinF = (Slider.Value[1] - Slider.Min) / (Slider.Max - Slider.Min)
                local MaxF = (Slider.Value[2] - Slider.Min) / (Slider.Max - Slider.Min)
                local DMin = math.abs(Fraction - MinF)
                local DMax = math.abs(Fraction - MaxF)

                if DMin < DMax then
                    Slider.Grabbing = "Min"
                elseif DMax < DMin then
                    Slider.Grabbing = "Max"
                else
                    Slider.Grabbing = Fraction <= MinF and "Min" or "Max"
                end

                Apply(Input)

                if Watcher then return end
                Watcher = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Slider.Grabbing = nil
                        Watcher:Disconnect()
                        Watcher = nil
                    end
                end)
            end
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if Slider.Grabbing then
                    Apply(Input)
                end
            end
        end)

        Slider:Set(Slider.Default[1], Slider.Default[2])

        if Slider.Flag then
            Library.SetFlags[Slider.Flag] = function(Value)
                Slider:Set(Value)
            end
        end

        return setmetatable(Slider, Library)
    end

    Library.Dropdown = function(Self, Params)
        Params = Params or { }

        local Section = Self
        local Dropdown = {
            Name = Params.Name or "Dropdown",
            Options = Params.Items or { },
            Default = Params.Default,
            Multi = Params.Multi or false,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = nil
        }

        if Dropdown.Multi then Dropdown.Value = { } end

        local Row = Section:AddRow(60)
        local Items = { Row = Row }

        Items.Name = Library:Create("TextLabel", {
            Parent = Row.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.DimText,
            Text = Dropdown.Name,
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, -1),
            Size = UDim2.new(1, -30, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "DimText" })

        Items.Frame = Library:Create("Frame", {
            Parent = Row.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(15, 25),
            Size = UDim2.new(1, -30, 0, 30),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ BackgroundColor3 = "Element" })

        Library:Create("UICorner", { Parent = Items.Frame.Instance, CornerRadius = UDim.new(0, 3) })

        Items.Item = Library:Create("TextLabel", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "-",
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, -1),
            Size = UDim2.new(1, -39, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Items.Arrow = Library:Create("ImageLabel", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            Image = "rbxassetid://127296511745226",
            ImageColor3 = Library.Theme.DimText,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -21, 0, 8),
            Size = UDim2.fromOffset(13, 13),
            BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "DimText" })

        Items.Hit = Library:Create("TextButton", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            BorderSizePixel = 0
        })

        Dropdown.Items = Items

        local Popup = MakeOptionPopup(function()
            return Items.Frame.Instance
        end)

        Popup.OnState = function(Open)
            Items.Arrow:Tween({ Rotation = Open and 180 or 0 })
        end

        Dropdown.Popup = Popup

        local function UpdateDisplay()
            local Text
            if Dropdown.Multi then
                Text = #Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or "-"
            else
                Text = Dropdown.Value or "-"
            end
            Items.Item.Instance.Text = Text
        end

        local function Report()
            if Dropdown.Flag then
                Library.Flags[Dropdown.Flag] = Dropdown.Value
            end
            UpdateDisplay()
            Library:SafeCall(Dropdown.Callback, Dropdown.Value)
        end

        Popup.OnPick = function(Data)
            if Dropdown.Multi then
                local Index = table.find(Dropdown.Value, Data.Name)
                if Index then
                    table.remove(Dropdown.Value, Index)
                    Data:Set(false)
                else
                    table.insert(Dropdown.Value, Data.Name)
                    Data:Set(true)
                end
            else
                Dropdown.Value = Data.Name
                for _, Other in Popup.Order do
                    Other:Set(Other == Data)
                end
            end

            Report()
        end

        function Dropdown:Refresh(List)
            Popup:Clear()
            Dropdown.Options = List
            for _, Option in List do
                Popup:AddRow(Option)
            end
        end

        function Dropdown:Set(Value)
            if Dropdown.Multi then
                if type(Value) ~= "table" then return end
                Dropdown.Value = Value
                for _, Data in Popup.Order do
                    Data:Set(table.find(Value, Data.Name) ~= nil, true)
                end
            else
                local Found = false
                for _, Data in Popup.Order do
                    if Data.Name == Value then Found = true end
                end
                if not Found then return end
                Dropdown.Value = Value
                for _, Data in Popup.Order do
                    Data:Set(Data.Name == Value, true)
                end
            end

            Report()
        end

        function Dropdown:Get()
            return Dropdown.Value
        end

        Items.Hit:Connect("MouseButton1Down", function()
            Popup:SetOpen(not Popup.IsOpen)
        end)

        for _, Option in Dropdown.Options do
            Popup:AddRow(Option)
        end

        if Dropdown.Default then
            Dropdown:Set(Dropdown.Default)
        end

        if Dropdown.Flag then
            Library.SetFlags[Dropdown.Flag] = function(Value)
                Dropdown:Set(Value)
            end
        end

        return setmetatable(Dropdown, Library)
    end

    Library.Textbox = function(Self, Params)
        Params = Params or { }

        local Section = Self
        local Textbox = {
            Name = Params.Name or "Textbox",
            Default = Params.Default or "",
            Placeholder = Params.Placeholder or "...",
            Finished = Params.Finished or false,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Value = ""
        }

        local Row = Section:AddRow(60)
        local Items = { Row = Row }

        Items.Name = Library:Create("TextLabel", {
            Parent = Row.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.DimText,
            Text = Textbox.Name,
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, -1),
            Size = UDim2.new(1, -30, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "DimText" })

        Items.Frame = Library:Create("Frame", {
            Parent = Row.Instance,
            Name = "\0",
            Position = UDim2.fromOffset(15, 25),
            Size = UDim2.new(1, -30, 0, 30),
            ClipsDescendants = true,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ BackgroundColor3 = "Element" })

        Library:Create("UICorner", { Parent = Items.Frame.Instance, CornerRadius = UDim.new(0, 3) })

        Items.Input = Library:Create("TextBox", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            PlaceholderColor3 = Library.Theme.DimText,
            PlaceholderText = Textbox.Placeholder,
            Text = "",
            TextSize = 14,
            ClearTextOnFocus = false,
            CursorPosition = -1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text", PlaceholderColor3 = "DimText" })

        if IsMobile then
            local FocusButton = Library:Create("TextButton", {
                Parent = Items.Frame.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 5,
                BorderSizePixel = 0
            })

            FocusButton:Connect("MouseButton1Down", function()
                Items.Input.Instance:CaptureFocus()
            end)
        end

        Textbox.Items = Items

        function Textbox:Set(Value)
            Textbox.Value = tostring(Value)
            Items.Input.Instance.Text = Textbox.Value
            if Textbox.Flag then Library.Flags[Textbox.Flag] = Textbox.Value end
            Library:SafeCall(Textbox.Callback, Textbox.Value)
        end

        function Textbox:Get()
            return Textbox.Value
        end

        if Textbox.Finished then
            Items.Input:Connect("FocusLost", function(Enter)
                if Enter then Textbox:Set(Items.Input.Instance.Text) end
            end)
        else
            Library:Connect(Items.Input.Instance:GetPropertyChangedSignal("Text"), function()
                Textbox:Set(Items.Input.Instance.Text)
            end)
        end

        if Textbox.Default ~= "" then
            Textbox:Set(Textbox.Default)
        end

        if Textbox.Flag then
            Library.SetFlags[Textbox.Flag] = function(Value)
                Textbox:Set(Value)
            end
        end

        return setmetatable(Textbox, Library)
    end

    Library.Button = function(Self, Params)
        Params = Params or { }

        local Section = Self
        local Button = {
            Name = Params.Name or "Button",
            Callback = Params.Callback or function() end
        }

        local Row = Section:AddRow(30)
        local Items = { Row = Row }

        Items.Frame = Library:Create("TextButton", {
            Parent = Row.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            Position = UDim2.fromOffset(15, 0),
            Size = UDim2.new(1, -30, 0, 28),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ BackgroundColor3 = "Element" })

        Library:Create("UICorner", { Parent = Items.Frame.Instance, CornerRadius = UDim.new(0, 3) })

        Items.Text = Library:Create("TextLabel", {
            Parent = Items.Frame.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Button.Name,
            TextSize = 14,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Button.Items = Items

        Items.Frame:OnHover(function()
            Items.Frame:Tween({ BackgroundColor3 = Library.Theme.Selected })
        end, function()
            Items.Frame:Tween({ BackgroundColor3 = Library.Theme.Element })
        end)

        function Button:Press()
            Library:Tween({ BackgroundColor3 = Library.Theme.Accent }, TweenInfo.new(0.1), Items.Frame.Instance)
            task.delay(0.15, function()
                Items.Frame:Tween({ BackgroundColor3 = Library.Theme.Element })
            end)
            Library:SafeCall(Button.Callback)
        end

        function Button:SetText(Text)
            Items.Text.Instance.Text = tostring(Text)
        end

        Items.Frame:Connect("MouseButton1Down", function()
            Button:Press()
        end)

        return setmetatable(Button, Library)
    end

    Library.Paragraph = function(Self, Params)
        Params = Params or { }

        local Section = Self
        local Paragraph = {
            Title = Params.Title or "Paragraph",
            Content = Params.Content or "",
            Items = { }
        }

        local Width = Section.Width - 30
        local TitleSize = 14
        local ContentSize = 13
        local Gap = 4

        local TitleBounds = MeasureText(Paragraph.Title, TitleSize, Width, Library.Font)
        local ContentBounds = MeasureText(Paragraph.Content, ContentSize, Width, Library.Font)
        local TotalHeight = TitleBounds.Y + Gap + ContentBounds.Y

        local Row = Section:AddRow(TotalHeight)
        local Items = { Row = Row }

        Items.Title = Library:Create("TextLabel", {
            Parent = Row.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Paragraph.Title,
            TextSize = TitleSize,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, 0),
            Size = UDim2.new(1, -30, 0, TitleBounds.Y),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Items.Content = Library:Create("TextLabel", {
            Parent = Row.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.DimText,
            Text = Paragraph.Content,
            TextSize = ContentSize,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, TitleBounds.Y + Gap),
            Size = UDim2.new(1, -30, 0, ContentBounds.Y),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "DimText" })

        Paragraph.Items = Items

        function Paragraph:SetTitle(Text)
            Paragraph.Title = Text
            Items.Title.Instance.Text = Text
        end

        function Paragraph:SetContent(Text)
            Paragraph.Content = Text
            Items.Content.Instance.Text = Text
        end

        return setmetatable(Paragraph, Library)
    end

    Library.Colorpicker = function(Self, Params)
        Params = Params or { }

        local Section = Self
        local Colorpicker = {
            Name = Params.Name or "Colorpicker",
            Default = Params.Default or Library.Theme.Accent,
            Transparency = Params.Transparency or 0,
            Flag = Params.Flag,
            Callback = Params.Callback or function() end,
            Color = Params.Default or Library.Theme.Accent
        }

        local Row = Section:AddRow(20)
        local Items = { Row = Row }

        Items.Name = Library:Create("TextLabel", {
            Parent = Row.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Colorpicker.Name,
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15, -1),
            Size = UDim2.new(1, -60, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        local Swatch = MakeColorSwatch(Row.Instance, -35, Colorpicker.Default)
        Items.Swatch = Swatch

        Colorpicker.Items = Items

        local Picker = MakeColorPopup(function()
            return Swatch.Halo.Instance
        end, Colorpicker.Name, Colorpicker.Default, Colorpicker.Transparency, function(Color, Alpha)
            Colorpicker.Color = Color
            Colorpicker.Transparency = Alpha
            Swatch:SetColor(Color, Alpha)

            if Colorpicker.Flag then
                Library.Flags[Colorpicker.Flag] = { __color = Color:ToHex(), __alpha = Alpha }
            end

            Library:SafeCall(Colorpicker.Callback, Color, Alpha)
        end)

        Colorpicker.Picker = Picker

        function Colorpicker:Set(Color, Alpha)
            Picker:Set(Color, Alpha)
        end

        function Colorpicker:Get()
            return Colorpicker.Color, Colorpicker.Transparency
        end

        Swatch.Hit:Connect("MouseButton1Down", function()
            Picker:SetOpen(not Picker.IsOpen)
        end)

        if Colorpicker.Flag then
            Library.SetFlags[Colorpicker.Flag] = function(Color, Alpha)
                Picker:Set(Color, Alpha)
            end
        end

        return setmetatable(Colorpicker, Library)
    end

    Library.GetConfig = function(Self, Created)
        local Config = { }
        for Index, Value in Library.Flags do
            if typeof(Value) == "Color3" then
                Config[Index] = { __color = Value:ToHex() }
            else
                Config[Index] = Value
            end
        end

        local ThemeColors = { }
        for _, Key in Library.ThemeKeys do
            ThemeColors[Key] = Library.Theme[Key]:ToHex()
        end
        ThemeColors.Accent = Library.Theme.Accent:ToHex()
        Config.__theme = ThemeColors

        Config.__created = Created or os.date("%d.%m.%Y")

        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(Self, Config)
        local Decoded = HttpService:JSONDecode(Config)

        Library.Silent = true

        for Index, Value in Decoded do
            local SetFunction = Library.SetFlags[Index]
            if SetFunction then
                if type(Value) == "table" and Value.__color then
                    SetFunction(Color3.fromHex(Value.__color), Value.__alpha)
                else
                    SetFunction(Value)
                end
            end
        end

        if type(Decoded.__theme) == "table" then
            for Key, Hex in Decoded.__theme do
                local Ok, Color = pcall(Color3.fromHex, Hex)
                if Ok then Library.Theme[Key] = Color end
            end
            DeriveTheme()
            Library.ThemeDirty = true
        end

        Library.Silent = false
    end
    Library.Config = function(Self)
        local SubPage = Self
        local Content = SubPage.Items.Content.Instance
        local ContentW = Library.WindowWidth - 95
        local ContentH = Library.WindowHeight - 76
        local RowW = ContentW - 24

        SubPage.Columns[1].Holder.Instance.Visible = false
        SubPage.Columns[2].Holder.Instance.Visible = false

        local Config = { Rows = { }, Selected = nil }
        local Items = { }

        Items.Input = Library:Create("TextBox", {
            Parent = Content,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            PlaceholderColor3 = Library.Theme.DimText,
            PlaceholderText = "Create a config",
            Text = "",
            TextSize = 14,
            ClearTextOnFocus = false,
            CursorPosition = -1,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 8),
            Size = UDim2.fromOffset(250, 25),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text", PlaceholderColor3 = "DimText" })

        if IsMobile then
            local FocusButton = Library:Create("TextButton", {
                Parent = Content,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 8),
                Size = UDim2.fromOffset(250, 25),
                ZIndex = 5,
                BorderSizePixel = 0
            })

            FocusButton:Connect("MouseButton1Down", function()
                Items.Input.Instance:CaptureFocus()
            end)
        end

        Items.Pen = Library:Create("ImageButton", {
            Parent = Content,
            Name = "\0",
            AutoButtonColor = false,
            Image = "rbxassetid://10734919691",
            ImageColor3 = Library.Theme.DimText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(268, 12),
            Size = UDim2.fromOffset(16, 16),
            BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "DimText" })

        Items.Plus = Library:Create("Frame", {
            Parent = Content,
            Name = "\0",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.fromOffset(ContentW - 11, 8),
            Size = UDim2.fromOffset(25, 25),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        }):AddToTheme({ BackgroundColor3 = "Element" })

        Library:Create("UICorner", { Parent = Items.Plus.Instance, CornerRadius = UDim.new(0, 4) })

        Items.PlusIcon = Library:Create("ImageLabel", {
            Parent = Items.Plus.Instance,
            Name = "\0",
            Image = "rbxassetid://10734924532",
            ImageColor3 = Library.Theme.Text,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        }):AddToTheme({ ImageColor3 = "Text" })

        Items.PlusHit = Library:Create("TextButton", {
            Parent = Items.Plus.Instance,
            Name = "\0",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0
        })

        Library:Create("Frame", {
            Parent = Content,
            Name = "\0",
            Position = UDim2.fromOffset(0, 41),
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Line
        }):AddToTheme({ BackgroundColor3 = "Line" })

        Items.RowsHolder = Library:Create("ScrollingFrame", {
            Parent = Content,
            Name = "\0",
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            Selectable = false,
            Active = true,
            Position = UDim2.fromOffset(10, 50),
            Size = UDim2.fromOffset(ContentW - 20, ContentH - 60),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0
        }):AddToTheme({ ScrollBarImageColor3 = "Accent" })

        local function Reflow(Animated)
            for Index, Row in Config.Rows do
                local Target = UDim2.fromOffset(0, (Index - 1) * 68)
                if Animated then
                    Library:Tween({ Position = Target }, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Row.Frame.Instance)
                else
                    Row.Frame.Instance.Position = Target
                end
            end
            Items.RowsHolder.Instance.CanvasSize = UDim2.fromOffset(0, #Config.Rows * 68)
        end

        local function AddRow(Name, Date, Animated)
            local Row = { Name = Name, Selected = false }

            Row.Frame = Library:Create("Frame", {
                Parent = Items.RowsHolder.Instance,
                Name = "\0",
                Position = UDim2.fromOffset(0, #Config.Rows * 68),
                Size = UDim2.fromOffset(RowW, 60),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Section
            }):AddToTheme({ BackgroundColor3 = "Section" })

            Library:Create("UICorner", { Parent = Row.Frame.Instance, CornerRadius = UDim.new(0, 4) })

            Row.Title = Library:Create("TextLabel", {
                Parent = Row.Frame.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.Text,
                Text = Name,
                TextSize = 15,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 10),
                Size = UDim2.fromOffset(400, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0
            }):AddToTheme({ TextColor3 = "Text" })

            Row.Date = Library:Create("TextLabel", {
                Parent = Row.Frame.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.DimText,
                Text = "Creation date: " .. Date,
                TextSize = 13,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 32),
                Size = UDim2.fromOffset(400, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0
            }):AddToTheme({ TextColor3 = "DimText" })

            Row.Hit = Library:Create("TextButton", {
                Parent = Row.Frame.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 2,
                BorderSizePixel = 0
            })

            Row.Trash = Library:Create("ImageButton", {
                Parent = Row.Frame.Instance,
                Name = "\0",
                AutoButtonColor = false,
                Image = "rbxassetid://10747362241",
                ImageColor3 = Library.Theme.DimText,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -74, 0, 21),
                Size = UDim2.fromOffset(18, 18),
                ZIndex = 3,
                BorderSizePixel = 0
            }):AddToTheme({ ImageColor3 = "DimText" })

            Row.Select = Library:Create("Frame", {
                Parent = Row.Frame.Instance,
                Name = "\0",
                Position = UDim2.new(1, -40, 0, 17),
                Size = UDim2.fromOffset(26, 26),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Element
            }):AddToTheme({ BackgroundColor3 = "Element" })

            Library:Create("UICorner", { Parent = Row.Select.Instance, CornerRadius = UDim.new(0, 4) })

            Row.Play = Library:Create("ImageLabel", {
                Parent = Row.Select.Instance,
                Name = "\0",
                Image = "rbxassetid://10734923549",
                ImageColor3 = Color3.new(0, 0, 0),
                ImageTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),
                BackgroundTransparency = 1,
                ZIndex = 3,
                BorderSizePixel = 0
            })

            Row.SelectHit = Library:Create("TextButton", {
                Parent = Row.Select.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 4,
                BorderSizePixel = 0
            })

            function Row:SetSelected(Bool)
                Row.Selected = Bool
                if Bool then
                    Row.Select:ChangeItemTheme({ BackgroundColor3 = "Accent" })
                    Row.Select:Tween({ BackgroundColor3 = Library.Theme.Accent })
                    Library:Tween({ ImageTransparency = 0 }, nil, Row.Play.Instance)
                else
                    Row.Select:ChangeItemTheme({ BackgroundColor3 = "Element" })
                    Row.Select:Tween({ BackgroundColor3 = Library.Theme.Element })
                    Library:Tween({ ImageTransparency = 1 }, nil, Row.Play.Instance)
                end
            end

            Row.Trash:OnHover(function()
                Row.Trash:Tween({ ImageColor3 = Library.Theme.Accent })
            end, function()
                Row.Trash:Tween({ ImageColor3 = Library.Theme.DimText })
            end)

            local function ToggleRow()
                if Row.Selected then
                    Row:SetSelected(false)
                    Config.Selected = nil
                    return
                end

                for _, Other in Config.Rows do
                    if Other.Selected then Other:SetSelected(false) end
                end

                Row:SetSelected(true)
                Config.Selected = Row.Name

                local Path = Library.ConfigFolder .. "/" .. Row.Name .. ".json"
                if isfile(Path) then
                    Library:LoadConfig(readfile(Path))
                end
            end

            Row.SelectHit:Connect("MouseButton1Down", ToggleRow)
            Row.Hit:Connect("MouseButton1Down", ToggleRow)

            Row.Trash:Connect("MouseButton1Down", function()
                local Path = Library.ConfigFolder .. "/" .. Row.Name .. ".json"
                if isfile(Path) then
                    delfile(Path)
                end

                local Index = table.find(Config.Rows, Row)
                if Index then table.remove(Config.Rows, Index) end

                local Fade = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local Current = Row.Frame.Instance.Position
                Library:Tween({ Position = UDim2.fromOffset(0, Current.Y.Offset - 14) }, Fade, Row.Frame.Instance)
                Library:Tween({ BackgroundTransparency = 1 }, Fade, Row.Frame.Instance)
                Library:Tween({ TextTransparency = 1 }, Fade, Row.Title.Instance)
                Library:Tween({ TextTransparency = 1 }, Fade, Row.Date.Instance)
                Library:Tween({ ImageTransparency = 1 }, Fade, Row.Trash.Instance)
                Library:Tween({ BackgroundTransparency = 1 }, Fade, Row.Select.Instance)
                Library:Tween({ ImageTransparency = 1 }, Fade, Row.Play.Instance)

                task.delay(0.28, function()
                    Row.Frame.Instance:Destroy()
                end)

                Reflow(true)
            end)

            table.insert(Config.Rows, Row)
            Reflow(false)

            if Animated then
                local Target = Row.Frame.Instance.Position
                Row.Frame.Instance.Position = UDim2.fromOffset(0, Target.Y.Offset + 12)
                Row.Frame:FadeDescendants(true)
                Library:Tween({ Position = Target }, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Row.Frame.Instance)
            end

            return Row
        end

        Items.PlusHit:Connect("MouseButton1Down", function()
            Items.Plus:Tween({ BackgroundColor3 = Library.Theme.Accent }, TweenInfo.new(0.12))
            task.delay(0.25, function()
                Items.Plus:Tween({ BackgroundColor3 = Library.Theme.Element })
            end)

            local Name = Items.Input.Instance.Text
            if Name == "" then return end

            for _, Row in Config.Rows do
                if Row.Name == Name then return end
            end

            local Date = os.date("%d.%m.%Y")
            writefile(Library.ConfigFolder .. "/" .. Name .. ".json", Library:GetConfig(Date))
            AddRow(Name, Date, true)
            Items.Input.Instance.Text = ""
        end)

        Items.Pen:Connect("MouseButton1Down", function()
            Items.Input.Instance:CaptureFocus()
        end)

        for _, File in listfiles(Library.ConfigFolder) do
            if File:sub(-5) == ".json" then
                local Name = File:match("([^/\\]+)%.json$")
                if Name then
                    local Date = os.date("%d.%m.%Y")
                    pcall(function()
                        local Decoded = HttpService:JSONDecode(readfile(File))
                        if type(Decoded.__created) == "string" then
                            Date = Decoded.__created
                        end
                    end)
                    AddRow(Name, Date, false)
                end
            end
        end

        SubPage.CustomShow = function()
            for Index, Row in Config.Rows do
                local Frame = Row.Frame.Instance
                Frame.Position = UDim2.fromOffset(35, (Index - 1) * 68)
                Frame.Size = UDim2.fromOffset(RowW + 45, 60)
                Row.Frame:FadeDescendants(true)
                Row.Frame:Tween({
                    Position = UDim2.fromOffset(0, (Index - 1) * 68),
                    Size = UDim2.fromOffset(RowW, 60)
                }, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            end
        end

        Config.Items = Items
        return Config
    end

    Library.Themes = function(Self)
        local SubPage = Self
        local Content = SubPage.Items.Content.Instance
        local ContentW = Library.WindowWidth - 95
        local BarW = math.floor((ContentW - 27) / 2)

        SubPage.Columns[1].Holder.Instance.Visible = false
        SubPage.Columns[2].Holder.Instance.Visible = false

        local Items = { }
        local Cards = { }
        local Bars = { }

        Items.Title = Library:Create("TextLabel", {
            Parent = Content,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "Presets",
            TextSize = 15,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 8),
            Size = UDim2.fromOffset(200, 25),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        Library:Create("Frame", {
            Parent = Content,
            Name = "\0",
            Position = UDim2.fromOffset(0, 41),
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Line
        }):AddToTheme({ BackgroundColor3 = "Line" })

        local function MakeCard(Name, Index)
            local Card = { Name = Name }

            Card.Frame = Library:Create("Frame", {
                Parent = Content,
                Name = "\0",
                Position = UDim2.fromOffset(10 + (Index - 1) * 122, 52),
                Size = UDim2.fromOffset(110, 74),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Section
            }):AddToTheme({ BackgroundColor3 = "Section" })

            Library:Create("UICorner", { Parent = Card.Frame.Instance, CornerRadius = UDim.new(0, 4) })

            Card.Stroke = Library:Create("UIStroke", {
                Parent = Card.Frame.Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Library.Theme.Line
            }):AddToTheme({ Color = "Line" })

            Card.Preview = Library:Create("Frame", {
                Parent = Card.Frame.Instance,
                Name = "\0",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 12),
                Size = UDim2.fromOffset(22, 22),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Presets[Name].Accent
            })

            Library:Create("UICorner", { Parent = Card.Preview.Instance, CornerRadius = UDim.new(1, 0) })

            Card.Label = Library:Create("TextLabel", {
                Parent = Card.Frame.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.DimText,
                Text = Name,
                TextSize = 13,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 44),
                Size = UDim2.new(1, 0, 0, 20),
                BorderSizePixel = 0
            }):AddToTheme({ TextColor3 = "DimText" })

            Card.Hit = Library:Create("TextButton", {
                Parent = Card.Frame.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0
            })

            function Card:SetSelected(Bool)
                if Bool then
                    Card.Stroke:ChangeItemTheme({ Color = "Accent" })
                    Card.Label:ChangeItemTheme({ TextColor3 = "Text" })
                    Card.Stroke:Tween({ Color = Library.Theme.Accent })
                    Card.Label:Tween({ TextColor3 = Library.Theme.Text })
                else
                    Card.Stroke:ChangeItemTheme({ Color = "Line" })
                    Card.Label:ChangeItemTheme({ TextColor3 = "DimText" })
                    Card.Stroke:Tween({ Color = Library.Theme.Line })
                    Card.Label:Tween({ TextColor3 = Library.Theme.DimText })
                end
            end

            Card.Hit:Connect("MouseButton1Down", function()
                Library:SetPreset(Name)
                for _, Other in Cards do
                    Other:SetSelected(Other == Card)
                end
            end)

            table.insert(Cards, Card)
            return Card
        end

        for Index, Name in Library.PresetList do
            MakeCard(Name, Index)
        end

        Cards[1]:SetSelected(true)

        Items.AccentBar = Library:Create("Frame", {
            Parent = Content,
            Name = "\0",
            Position = UDim2.fromOffset(10, 140),
            Size = UDim2.fromOffset(ContentW - 20, 36),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Section
        }):AddToTheme({ BackgroundColor3 = "Section" })

        Library:Create("UICorner", { Parent = Items.AccentBar.Instance, CornerRadius = UDim.new(0, 4) })

        Library:Create("TextLabel", {
            Parent = Items.AccentBar.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "Accent Color",
            TextSize = 14,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.fromOffset(200, 36),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0
        }):AddToTheme({ TextColor3 = "Text" })

        local Swatch = MakeColorSwatch(Items.AccentBar.Instance, -35, Library.Theme.Accent)

        local AccentPicker = MakeColorPopup(function()
            return Swatch.Halo.Instance
        end, "Accent Color", Library.Theme.Accent, 0, function(Color)
            Swatch:SetColor(Color)
            Library:SetAccent(Color)

            local Matched = nil
            for Name, Preset in Library.Presets do
                if Preset.Accent:ToHex() == Color:ToHex() then Matched = Name end
            end
            for _, Card in Cards do
                Card:SetSelected(Card.Name == Matched)
            end
        end)

        Swatch.Hit:Connect("MouseButton1Down", function()
            AccentPicker:SetOpen(not AccentPicker.IsOpen)
        end)

        local function MakeColorRow(Key, X, Y)
            local Bar = Library:Create("Frame", {
                Parent = Content,
                Name = "\0",
                Position = UDim2.fromOffset(X, Y),
                Size = UDim2.fromOffset(BarW, 36),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Section
            }):AddToTheme({ BackgroundColor3 = "Section" })

            Library:Create("UICorner", { Parent = Bar.Instance, CornerRadius = UDim.new(0, 4) })

            Library:Create("TextLabel", {
                Parent = Bar.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.Text,
                Text = Key,
                TextSize = 14,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.fromOffset(200, 36),
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0
            }):AddToTheme({ TextColor3 = "Text" })

            local RowSwatch = MakeColorSwatch(Bar.Instance, -35, Library.Theme[Key])

            local RowPicker = MakeColorPopup(function()
                return RowSwatch.Halo.Instance
            end, Key, Library.Theme[Key], 0, function(Color)
                RowSwatch:SetColor(Color)
                Library:SetThemeColor(Key, Color)
            end)

            RowSwatch.Hit:Connect("MouseButton1Down", function()
                RowPicker:SetOpen(not RowPicker.IsOpen)
            end)

            table.insert(Bars, Bar)
        end

        for Index, Key in Library.ThemeKeys do
            local Column = (Index - 1) % 2
            local RowIndex = math.floor((Index - 1) / 2)
            MakeColorRow(Key, 10 + Column * (BarW + 7), 186 + RowIndex * 44)
        end

        local Animated = { }

        for _, Card in Cards do
            table.insert(Animated, { Frame = Card.Frame, Position = Card.Frame.Instance.Position, Size = Card.Frame.Instance.Size })
        end

        table.insert(Animated, { Frame = Items.AccentBar, Position = Items.AccentBar.Instance.Position, Size = Items.AccentBar.Instance.Size })

        for _, Bar in Bars do
            table.insert(Animated, { Frame = Bar, Position = Bar.Instance.Position, Size = Bar.Instance.Size })
        end

        SubPage.CustomShow = function()
            for _, Data in Animated do
                local Frame = Data.Frame.Instance
                Frame.Position = Data.Position + UDim2.fromOffset(35, 0)
                Frame.Size = Data.Size + UDim2.fromOffset(45, 0)
                Data.Frame:FadeDescendants(true)
                Data.Frame:Tween({ Position = Data.Position, Size = Data.Size }, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            end
        end

        return Items
    end

    Library:Connect(RunService.Heartbeat, function()
        if Library.ThemeDirty then
            Library.ThemeDirty = false
            Library:ApplyThemeInstant()
        end
    end)

    getgenv().Destruction = Library
end

return Library