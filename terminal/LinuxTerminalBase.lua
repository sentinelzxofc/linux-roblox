local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TERMINAL_CONFIG = {
    TRANSPARENCY = 0.15,
    BACKGROUND_COLOR = Color3.fromRGB(20, 20, 20),
    TEXT_COLOR = Color3.fromRGB(0, 255, 0),
    FONT = Enum.Font.RobotoMono,
    FONT_SIZE = 14,
    TERMINAL_SIZE = UDim2.new(0.8, 0, 0.7, 0),
    MIN_SIZE = UDim2.new(0.3, 0, 0.2, 0),
    MAX_SIZE = UDim2.new(0.95, 0, 0.9, 0),
    ANIMATION_TIME = 0.3,
    RESIZE_HANDLE_SIZE = 16
}

local function safeSetClipboard(text)
    local methods = {
        {name = "setclipboard", func = setclipboard},
        {name = "toclipboard", func = toclipboard},
        {name = "writeclipboard", func = writeclipboard},
        {name = "syn.write_clipboard", func = syn and syn.write_clipboard},
        {name = "Krnl.writefileclipboard", func = Krnl and Krnl.writefileclipboard},
        {name = "write_clipboard", func = write_clipboard},
        {name = "clipboard.set", func = clipboard and clipboard.set}
    }
    
    for _, method in ipairs(methods) do
        if method.func then
            local success = pcall(function()
                method.func(text)
            end)
            if success then
                return true
            end
        end
    end
    
    return false
end
local function createTerminalGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LinuxTerminal"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local terminalFrame = Instance.new("Frame")
    terminalFrame.Name = "TerminalWindow"
    terminalFrame.Size = TERMINAL_CONFIG.TERMINAL_SIZE
    terminalFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
    terminalFrame.BackgroundColor3 = TERMINAL_CONFIG.BACKGROUND_COLOR
    terminalFrame.BackgroundTransparency = TERMINAL_CONFIG.TRANSPARENCY
    terminalFrame.BorderSizePixel = 2
    terminalFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    terminalFrame.Parent = screenGui
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = terminalFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(0.8, 0, 1, 0)
    titleText.Position = UDim2.new(0.02, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Terminal - " .. player.Name .. "@roblox-linux"
    titleText.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleText.Font = TERMINAL_CONFIG.FONT
    titleText.TextSize = 12
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = TERMINAL_CONFIG.FONT
    closeButton.TextSize = 14
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    local maximizeButton = Instance.new("TextButton")
    maximizeButton.Name = "MaximizeButton"
    maximizeButton.Size = UDim2.new(0, 20, 0, 20)
    maximizeButton.Position = UDim2.new(1, -50, 0, 5)
    maximizeButton.BackgroundColor3 = Color3.fromRGB(255, 189, 46)
    maximizeButton.Text = "□"
    maximizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    maximizeButton.Font = TERMINAL_CONFIG.FONT
    maximizeButton.TextSize = 12
    maximizeButton.BorderSizePixel = 0
    maximizeButton.Parent = titleBar
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Position = UDim2.new(1, -75, 0, 5)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(40, 201, 64)
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.Font = TERMINAL_CONFIG.FONT
    minimizeButton.TextSize = 14
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Parent = titleBar
    
    local terminalDisplay = Instance.new("ScrollingFrame")
    terminalDisplay.Name = "TerminalDisplay"
    terminalDisplay.Size = UDim2.new(1, -20, 1, -70)
    terminalDisplay.Position = UDim2.new(0, 10, 0, 35)
    terminalDisplay.BackgroundTransparency = 1
    terminalDisplay.BorderSizePixel = 0
    terminalDisplay.ScrollBarThickness = 8
    terminalDisplay.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    terminalDisplay.CanvasSize = UDim2.new(0, 0, 0, 0)
    terminalDisplay.Parent = terminalFrame
    
    local outputText = Instance.new("TextLabel")
    outputText.Name = "OutputText"
    outputText.Size = UDim2.new(1, 0, 1, 0)
    outputText.Position = UDim2.new(0, 0, 0, 0)
    outputText.BackgroundTransparency = 1
    outputText.Text = ""
    outputText.TextColor3 = TERMINAL_CONFIG.TEXT_COLOR
    outputText.Font = TERMINAL_CONFIG.FONT
    outputText.TextSize = TERMINAL_CONFIG.FONT_SIZE
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.TextWrapped = true
    outputText.Parent = terminalDisplay
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -20, 0, 25)
    inputFrame.Position = UDim2.new(0, 10, 1, -30)
    inputFrame.BackgroundTransparency = 1
    inputFrame.BackgroundColor3 = TERMINAL_CONFIG.BACKGROUND_COLOR
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = terminalFrame
    
    local promptLabel = Instance.new("TextLabel")
    promptLabel.Name = "PromptLabel"
    promptLabel.Size = UDim2.new(0, 200, 1, 0)
    promptLabel.Position = UDim2.new(0, 0, 0, 0)
    promptLabel.BackgroundTransparency = 1
    promptLabel.Text = player.Name .. "@roblox-linux:~$ "
    promptLabel.TextColor3 = TERMINAL_CONFIG.TEXT_COLOR
    promptLabel.Font = TERMINAL_CONFIG.FONT
    promptLabel.TextSize = TERMINAL_CONFIG.FONT_SIZE
    promptLabel.TextXAlignment = Enum.TextXAlignment.Left
    promptLabel.Parent = inputFrame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "CommandInput"
    inputBox.Size = UDim2.new(1, -200, 1, 0)
    inputBox.Position = UDim2.new(0, 200, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Text = ""
    inputBox.TextColor3 = TERMINAL_CONFIG.TEXT_COLOR
    inputBox.Font = TERMINAL_CONFIG.FONT
    inputBox.TextSize = TERMINAL_CONFIG.FONT_SIZE
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextYAlignment = Enum.TextYAlignment.Center
    inputBox.ClearTextOnFocus = false
    inputBox.PlaceholderText = ""
    inputBox.TextWrapped = false
    inputBox.Parent = inputFrame
    
    return screenGui, terminalFrame, outputText, inputBox, promptLabel
end

local LinuxTerminal = {}
LinuxTerminal.__index = LinuxTerminal

function LinuxTerminal.new()
    local self = setmetatable({}, LinuxTerminal)
    
    self.gui, self.frame, self.output, self.input, self.prompt = createTerminalGUI()
    self.history = {}
    self.commandHistory = {}
    self.historyIndex = 0
    self.isMinimized = false
    self.isMaximized = false
    self.isVisible = true
    self.originalSize = TERMINAL_CONFIG.TERMINAL_SIZE
    self.originalPosition = UDim2.new(0.1, 0, 0.15, 0)
    
    self:setupEvents()
    self:setupChatCommands()
    self:showWelcomeMessage()
    self:focusInput()
    
    return self
end

function LinuxTerminal:addToHistory(text, isCommandOutput)
    table.insert(self.history, {text = text, isOutput = isCommandOutput or false})
    self:updateDisplayWithCopyButtons()
end

function LinuxTerminal:updateDisplayWithCopyButtons()
    for _, child in pairs(self.output.Parent:GetChildren()) do
        if child.Name ~= "OutputText" then
            child:Destroy()
        end
    end
    
    local yPosition = 10
    local lineHeight = 20
    
    for i, entry in ipairs(self.history) do
        local text = entry.text or entry
        local isOutput = entry.isOutput or false
        
        local lineFrame = Instance.new("Frame")
        lineFrame.Name = "Line" .. i
        lineFrame.Size = UDim2.new(1, -20, 0, lineHeight)
        lineFrame.Position = UDim2.new(0, 0, 0, yPosition)
        lineFrame.BackgroundTransparency = 1
        lineFrame.Parent = self.output.Parent
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "LineText"
        textLabel.Size = UDim2.new(1, -30, 1, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = TERMINAL_CONFIG.TEXT_COLOR
        textLabel.Font = TERMINAL_CONFIG.FONT
        textLabel.TextSize = TERMINAL_CONFIG.FONT_SIZE
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.TextWrapped = true
        textLabel.Parent = lineFrame
        
        if isOutput and text ~= "" and not text:match("^" .. player.Name .. "@roblox%-linux:") then
            local copyButton = Instance.new("TextButton")
            copyButton.Name = "CopyButton"
            copyButton.Size = UDim2.new(0, 25, 0, 18)
            copyButton.Position = UDim2.new(1, -28, 0, 1)
            copyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            copyButton.BackgroundTransparency = 0.3
            copyButton.BorderSizePixel = 0
            copyButton.Text = "📋"
            copyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            copyButton.Font = Enum.Font.SourceSans
            copyButton.TextSize = 12
            copyButton.Visible = false -- Initially hidden
            copyButton.Parent = lineFrame
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = copyButton
            
            copyButton.MouseButton1Click:Connect(function()
                local success = safeSetClipboard(text)
                
                if success then
                    copyButton.Text = "✓"
                    copyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                else
                    copyButton.Text = "?"
                    copyButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
                    
                    spawn(function()
                        if _G.LinuxTerminalBase then
                            _G.LinuxTerminalBase:addToHistory("\n=== TEXTO PARA CÓPIA MANUAL ===", true)
                            _G.LinuxTerminalBase:addToHistory(text, true)
                            _G.LinuxTerminalBase:addToHistory("=== FIM DO TEXTO ===", true)
                            _G.LinuxTerminalBase:addToHistory("Selecione o texto acima e copie manualmente (Ctrl+C)\n", true)
                        end
                    end)
                end
                
                spawn(function()
                    wait(2)
                    copyButton.Text = "📋"
                    copyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                end)
            end)
            
            copyButton.MouseEnter:Connect(function()
                local hoverTween = TweenService:Create(
                    copyButton,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(60, 60, 60)}
                )
                hoverTween:Play()
            end)
            
            copyButton.MouseLeave:Connect(function()
                local leaveTween = TweenService:Create(
                    copyButton,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(40, 40, 40)}
                )
                leaveTween:Play()
            end)
            
            lineFrame.MouseEnter:Connect(function()
                copyButton.Visible = true
                local showTween = TweenService:Create(
                    copyButton,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.2}
                )
                showTween:Play()
            end)
            
            lineFrame.MouseLeave:Connect(function()
                local hideTween = TweenService:Create(
                    copyButton,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 1}
                )
                hideTween:Play()
                hideTween.Completed:Connect(function()
                    copyButton.Visible = false
                end)
            end)
        end
        
        local textBounds = TextService:GetTextSize(
            text,
            TERMINAL_CONFIG.FONT_SIZE,
            TERMINAL_CONFIG.FONT,
            Vector2.new(textLabel.AbsoluteSize.X, math.huge)
        )
        
        local actualHeight = math.max(lineHeight, textBounds.Y + 4)
        lineFrame.Size = UDim2.new(1, -20, 0, actualHeight)
        textLabel.Size = UDim2.new(1, -30, 0, actualHeight)
        
        yPosition = yPosition + actualHeight + 2
    end
    
    local maxHeight = math.max(yPosition + 40, self.output.Parent.AbsoluteSize.Y)
    self.output.Parent.CanvasSize = UDim2.new(0, 0, 0, maxHeight)
    
    self.output.Visible = false
    
    local targetPosition = math.max(0, maxHeight - self.output.Parent.AbsoluteSize.Y)
    
    local scrollTween = TweenService:Create(
        self.output.Parent,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CanvasPosition = Vector2.new(0, targetPosition)}
    )
    scrollTween:Play()
end

function LinuxTerminal:updateDisplay()
    local displayText = table.concat(self.history, "\n")
    self.output.Text = displayText
    
    local textBounds = TextService:GetTextSize(
        displayText, 
        TERMINAL_CONFIG.FONT_SIZE, 
        TERMINAL_CONFIG.FONT, 
        Vector2.new(self.output.AbsoluteSize.X - 20, math.huge)
    )
    
    local maxHeight = math.max(textBounds.Y + 40, self.output.Parent.AbsoluteSize.Y)
    self.output.Parent.CanvasSize = UDim2.new(0, 0, 0, maxHeight)
    
    local targetPosition = math.max(0, maxHeight - self.output.Parent.AbsoluteSize.Y)
    
    local scrollTween = TweenService:Create(
        self.output.Parent,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CanvasPosition = Vector2.new(0, targetPosition)}
    )
    scrollTween:Play()
end

function LinuxTerminal:showWelcomeMessage()
    local ascii = [[
╭─────────────────────────────────────────────────────────────╮
│  ██      ██ ███    ██ ██    ██ ██   ██                      │
│  ██      ██ ████   ██ ██    ██  ██ ██                       │
│  ██      ██ ██ ██  ██ ██    ██   ███                        │
│  ██      ██ ██  ██ ██ ██    ██  ██ ██                       │
│  ███████ ██ ██   ████  ██████  ██   ██                      │
│                                                             │
│                        -                                    │
│                                                             │
│  ██████   ██████  ██████  ██       ██████  ██   ██         │
│  ██   ██ ██    ██ ██   ██ ██      ██    ██  ██ ██          │
│  ██████  ██    ██ ██████  ██      ██    ██   ███           │
│  ██   ██ ██    ██ ██   ██ ██      ██    ██  ██ ██          │
│  ██   ██  ██████  ██████  ███████  ██████  ██   ██         │
╰─────────────────────────────────────────────────────────────╯]]
    
    self:addToHistory(ascii, false)
    self:addToHistory("", false)
    self:addToHistory("Bem-vindo " .. player.Name .. "!", false)
    self:addToHistory("", false)
    self:addToHistory("Repositório Terminal Linux: https://github.com/sentinelzxofc/linux-roblox", false)
    self:addToHistory("", false)
    self:addToHistory("Informações do Sistema:", false)
    self:addToHistory("Usuário: " .. player.Name, false)
    self:addToHistory("ID do Usuário: " .. player.UserId, false)
    self:addToHistory("Nome de Exibição: " .. player.DisplayName, false)
    self:addToHistory("Idade da Conta: " .. player.AccountAge .. " dias", false)
    self:addToHistory("Membresía: " .. tostring(player.MembershipType), false)
    self:addToHistory("", false)
    self:addToHistory("📋 Botões de Cópia: Passe o mouse sobre as respostas para copiar!", false)
    
    local clipboardMethods = {}
    if setclipboard then table.insert(clipboardMethods, "setclipboard") end
    if toclipboard then table.insert(clipboardMethods, "toclipboard") end
    if syn and syn.write_clipboard then table.insert(clipboardMethods, "syn.write_clipboard") end
    if Krnl and Krnl.writefileclipboard then table.insert(clipboardMethods, "Krnl.writefileclipboard") end
    
    if #clipboardMethods > 0 then
        self:addToHistory("✅ Clipboard disponível: " .. table.concat(clipboardMethods, ", "), false)
    else
        self:addToHistory("⚠️ Clipboard não disponível - usará cópia manual", false)
    end
    self:addToHistory("Digite: /help para ver comandos", false)
    self:addToHistory("", false)
end

function LinuxTerminal:processCommand(command)
    if command ~= "" then
        table.insert(self.commandHistory, command)
    end
    self.historyIndex = #self.commandHistory + 1
    
    self:addToHistory(self.prompt.Text .. command, false)
    
    if command == "" then
        return
    end
    
    local success, result = pcall(function()
        if _G.LinuxTerminalSystem then
            return _G.LinuxTerminalSystem:executeCommand(command)
        else
            return "System script not loaded. Please ensure LinuxTerminalSystem.lua is running."
        end
    end)
    
    if success and result and result ~= "" then
        self:addToHistory(result, true)
    elseif not success then
        self:addToHistory("Error: " .. tostring(result), true)
    end
end

function LinuxTerminal:clearTerminal()
    self.history = {}
    
    for _, child in pairs(self.output.Parent:GetChildren()) do
        if child.Name ~= "OutputText" then
            child:Destroy()
        end
    end
    
    self:showWelcomeMessage()
end

function LinuxTerminal:setupChatCommands()
    if player.Chatted then
        player.Chatted:Connect(function(message)
            if message:lower() == "/terminal" then
                if not self.isVisible then
                    self:toggleVisible()
                    self:addToHistory("Terminal opened via chat command.")
                end
            end
        end)
    end
end



function LinuxTerminal:setupEvents()
    self.input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local command = self.input.Text:gsub("^%s*(.-)%s*$", "%1")
            self.input.Text = ""
            self:processCommand(command)
            task.wait(0.05) 
            self:focusInput()
        end
    end)
    
    self.frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:focusInput()
        end
    end)
    
    self.output.Parent.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:focusInput()
        end
    end)
    
    self.input:GetPropertyChangedSignal("Text"):Connect(function()
        if #self.input.Text > 200 then
            self.input.Text = self.input.Text:sub(1, 200)
        end
    end)
    
    self.frame.TitleBar.CloseButton.MouseButton1Click:Connect(function()
        self:hide()
    end)
    
    self.frame.TitleBar.MinimizeButton.MouseButton1Click:Connect(function()
        self:minimize()
    end)
    
    self.frame.TitleBar.MaximizeButton.MouseButton1Click:Connect(function()
        self:maximize()
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not self.input:IsFocused() then return end
        
        if input.KeyCode == Enum.KeyCode.Up then
            if self.historyIndex > 1 then
                self.historyIndex = self.historyIndex - 1
                self.input.Text = self.commandHistory[self.historyIndex] or ""
                task.wait() 
                self.input.CursorPosition = #self.input.Text + 1
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            if self.historyIndex <= #self.commandHistory then
                self.historyIndex = self.historyIndex + 1
                self.input.Text = self.commandHistory[self.historyIndex] or ""
                task.wait() 
                self.input.CursorPosition = #self.input.Text + 1
            end
        end
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.frame.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local viewport = workspace.CurrentCamera.ViewportSize
            local newPos = UDim2.new(
                startPos.X.Scale, 
                math.max(0, math.min(startPos.X.Offset + delta.X, viewport.X - self.frame.AbsoluteSize.X)), 
                startPos.Y.Scale, 
                math.max(0, math.min(startPos.Y.Offset + delta.Y, viewport.Y - self.frame.AbsoluteSize.Y))
            )
            self.frame.Position = newPos
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function LinuxTerminal:focusInput()
    if self.isVisible and self.frame.Visible and not self.isMinimized then
        task.wait(0.1)
        if self.input and self.input.Parent then
            self.input:CaptureFocus()
        end
    end
end

function LinuxTerminal:hide()
    self.isVisible = false
    local hideTween = TweenService:Create(
        self.frame,
        TweenInfo.new(TERMINAL_CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    hideTween:Play()
    
    hideTween.Completed:Connect(function()
        self.frame.Visible = false
    end)
end

function LinuxTerminal:show()
    self.isVisible = true
    self.frame.Visible = true
    
    local showTween = TweenService:Create(
        self.frame,
        TweenInfo.new(TERMINAL_CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = TERMINAL_CONFIG.TRANSPARENCY}
    )
    showTween:Play()
    
    showTween.Completed:Connect(function()
        self:focusInput()
    end)
end

function LinuxTerminal:toggleVisible()
    if self.isVisible then
        self:hide()
    else
        self:show()
    end
end

function LinuxTerminal:minimize()
    if self.isMinimized then
        local restoreTween = TweenService:Create(
            self.frame,
            TweenInfo.new(TERMINAL_CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = self.originalSize}
        )
        restoreTween:Play()
        
        self.frame.InputFrame.Visible = true
        self.frame.TerminalDisplay.Visible = true
        
        self.isMinimized = false
        restoreTween.Completed:Connect(function()
            self:focusInput()
        end)
    else
        local minimizeTween = TweenService:Create(
            self.frame,
            TweenInfo.new(TERMINAL_CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(self.frame.Size.X.Scale, self.frame.Size.X.Offset, 0, 30)}
        )
        minimizeTween:Play()
        
        self.frame.InputFrame.Visible = false
        self.frame.TerminalDisplay.Visible = false
        
        self.isMinimized = true
    end
end

function LinuxTerminal:maximize()
    if self.isMaximized then
        local restoreTween = TweenService:Create(
            self.frame,
            TweenInfo.new(TERMINAL_CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = self.originalSize, Position = self.originalPosition}
        )
        restoreTween:Play()
        
        self.isMaximized = false
        restoreTween.Completed:Connect(function()
            self:focusInput()
        end)
    else
        local maximizeTween = TweenService:Create(
            self.frame,
            TweenInfo.new(TERMINAL_CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.95, 0, 0.9, 0), Position = UDim2.new(0.025, 0, 0.05, 0)}
        )
        maximizeTween:Play()
        
        self.isMaximized = true
        maximizeTween.Completed:Connect(function()
            self:focusInput()
        end)
    end
end

_G.LinuxTerminalBase = LinuxTerminal.new()

game:GetService("RunService").Heartbeat:Connect(function()
    if _G.LinuxTerminalBase and _G.LinuxTerminalBase.frame.Visible and not _G.LinuxTerminalBase.input:IsFocused() then
        
    end
end)