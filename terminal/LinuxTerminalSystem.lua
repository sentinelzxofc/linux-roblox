local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local LinuxTerminalSystem = {}
LinuxTerminalSystem.__index = LinuxTerminalSystem

function LinuxTerminalSystem.new()
    local self = setmetatable({}, LinuxTerminalSystem)
    
    self.commandModules = {}
    self.organizedScripts = {}
    self.pluginModules = {}
    self.currentDirectory = "~"
    self.sessionData = {}
    self.commandHistory = {}
    self.activeScripts = {}
    self.fileSystem = {
        ["~"] = {
            type = "directory",
            contents = {
                ["Documents"] = {type = "directory", contents = {}},
                ["Downloads"] = {type = "directory", contents = {}},
                ["Desktop"] = {type = "directory", contents = {}},
                ["welcome.txt"] = {type = "file", content = "Bem-vindo ao Terminal Linux Roblox!"}
            }
        }
    }
    
    self:loadCommandModules()
    self:loadPluginModules()
    self:setupDynamicReloading()
    
    return self
end

function LinuxTerminalSystem:loadCommandModules()
    local success, cmdsFolder = pcall(function()
        return StarterPlayerScripts:FindFirstChild("terminal"):FindFirstChild("cmds")
    end)
    
    if success and cmdsFolder then
        for _, moduleScript in pairs(cmdsFolder:GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local commandName = "/" .. moduleScript.Name
                self:loadSingleCommand(commandName, moduleScript)
            elseif moduleScript:IsA("Folder") then
                self:loadCommandsFromFolder(moduleScript, moduleScript.Name)
            end
        end
    else
        self:initializeFallbackCommands()
    end
end

function LinuxTerminalSystem:loadCommandsFromFolder(folder, folderName)
    for _, script in pairs(folder:GetChildren()) do
        if script:IsA("ModuleScript") then
            local success, commandModule = pcall(function()
                return require(script)
            end)
            
            if success and commandModule then
                if not self.organizedScripts then
                    self.organizedScripts = {}
                end
                
                if not self.organizedScripts[folderName] then
                    self.organizedScripts[folderName] = {}
                end
                
                local scriptName = script.Name
                self.organizedScripts[folderName][scriptName] = {
                    module = commandModule,
                    script = script,
                    lastModified = tick(),
                    execute = commandModule.execute,
                    type = "ModuleScript"
                }
            end
            
        elseif script:IsA("ServerScript") or script:IsA("LocalScript") then
            local scriptName = script.Name
            local globalKey = "TerminalCommand_" .. folderName .. "_" .. scriptName
            
            if not self.organizedScripts then
                self.organizedScripts = {}
            end
            
            if not self.organizedScripts[folderName] then
                self.organizedScripts[folderName] = {}
            end
            
            self.organizedScripts[folderName][scriptName] = {
                script = script,
                lastModified = tick(),
                globalKey = globalKey,
                type = script.ClassName,
                execute = function(args, context)
                    _G[globalKey .. "_Args"] = args
                    _G[globalKey .. "_Context"] = context
                    _G[globalKey .. "_Execute"] = true
                    
                    local startTime = tick()
                    local timeout = 5
                    
                    while not _G[globalKey .. "_Result"] and (tick() - startTime) < timeout do
                        task.wait(0.1)
                    end
                    
                    local result = _G[globalKey .. "_Result"]
                    
                    _G[globalKey .. "_Args"] = nil
                    _G[globalKey .. "_Context"] = nil
                    _G[globalKey .. "_Execute"] = nil
                    _G[globalKey .. "_Result"] = nil
                    
                    if result then
                        return result
                    else
                        return "⚠️ ServerScript timeout (" .. script.ClassName .. ")"
                    end
                end
            }
            
        elseif script:IsA("Folder") then
            self:loadCommandsFromFolder(script, folderName .. "/" .. script.Name)
        end
    end
end

function LinuxTerminalSystem:loadSingleCommand(commandName, moduleScript)
    local success, commandModule = pcall(function()
        return require(moduleScript)
    end)
    
    if success and commandModule then
        self.commandModules[commandName] = {
            module = commandModule,
            script = moduleScript,
            lastModified = tick(),
            path = commandName
        }
    end
end

function LinuxTerminalSystem:loadPluginModules()
    local success, sistemaFolder = pcall(function()
        return StarterPlayerScripts:FindFirstChild("terminal"):FindFirstChild("sistema")
    end)
    
    if success and sistemaFolder then
        for _, moduleScript in pairs(sistemaFolder:GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local pluginName = moduleScript.Name
                local success, pluginModule = pcall(function()
                    return require(moduleScript)
                end)
                
                if success and pluginModule then
                    self.pluginModules[pluginName] = {
                        module = pluginModule,
                        script = moduleScript,
                        lastModified = tick(),
                        enabled = true
                    }
                    
                    if pluginModule.init then
                        pluginModule.init(self)
                    end
                end
            end
        end
    end
end



function LinuxTerminalSystem:setupDynamicReloading()
    local success, cmdsFolder = pcall(function()
        return StarterPlayerScripts:FindFirstChild("terminal"):FindFirstChild("cmds")
    end)
    
    if success and cmdsFolder then
        cmdsFolder.ChildAdded:Connect(function(child)
            if child:IsA("ModuleScript") then
                task.wait(0.1)
                local commandName = "/" .. child.Name
                local success, commandModule = pcall(function()
                    return require(child)
                end)
                
                if success and commandModule then
                    self.commandModules[commandName] = {
                        module = commandModule,
                        script = child,
                        lastModified = tick()
                    }
                    
                    if _G.LinuxTerminalBase then
                        _G.LinuxTerminalBase:addToHistory("[Sistema] Novo comando: " .. commandName)
                    end
                end
            end
        end)
        
        cmdsFolder.ChildRemoved:Connect(function(child)
            if child:IsA("ModuleScript") then
                local commandName = "/" .. child.Name
                if self.commandModules[commandName] then
                    self.commandModules[commandName] = nil
                    
                    if _G.LinuxTerminalBase then
                        _G.LinuxTerminalBase:addToHistory("[Sistema] Comando removido: " .. commandName)
                    end
                end
            end
        end)
    end
end

function LinuxTerminalSystem:initializeFallbackCommands()
    self.commandModules["/help"] = {
        module = {
            execute = function(args)
                return "Pasta de comandos não encontrada. Crie StarterPlayerScripts.terminal.cmds com ModuleScripts."
            end
        },
        script = nil,
        lastModified = tick(),
        path = "/help"
    }
end

function LinuxTerminalSystem:executeCommand(input)
    if not input or input == "" then
        return ""
    end
    
    local command, args = self:parseAdvancedCommand(input)
    
    table.insert(self.commandHistory, {
        command = command,
        args = args,
        fullInput = input,
        timestamp = tick(),
        user = player.Name
    })
    
    local commandData = self.commandModules[command]
    
    if commandData then
        local context = {
            player = player,
            terminal = _G.LinuxTerminalBase,
            currentDirectory = self.currentDirectory,
            fileSystem = self.fileSystem,
            sessionData = self.sessionData,
            system = self,
            utils = {
                print = function(text)
                    if _G.LinuxTerminalBase then
                        _G.LinuxTerminalBase:addToHistory(tostring(text))
                    end
                end,
                printColor = function(text, color)
                    if _G.LinuxTerminalBase then
                        _G.LinuxTerminalBase:addToHistory(tostring(text))
                    end
                end,
                getUserInput = function(prompt)
                    if _G.LinuxTerminalBase then
                        _G.LinuxTerminalBase:addToHistory(prompt or "Input: ")
                    end
                end,
                executeCommand = function(cmd)
                    return self:executeCommand(cmd)
                end,
                commandExists = function(cmd)
                    return self.commandModules["/" .. cmd] ~= nil
                end,
                getCommands = function()
                    local cmds = {}
                    for cmd, _ in pairs(self.commandModules) do
                        table.insert(cmds, cmd:sub(2))
                    end
                    return cmds
                end,
                services = {
                    Players = Players,
                    UserInputService = UserInputService,
                    TweenService = TweenService,
                    RunService = RunService
                }
            },
            rawInput = input,
            history = self.commandHistory
        }
        
        local success, result = pcall(function()
            if commandData.module.execute then
                return commandData.module.execute(args, context)
            elseif type(commandData.module) == "function" then
                return commandData.module(args, context)
            else
                return "Erro: Módulo de comando não tem função execute"
            end
        end)
        
        if success then
            result = self:processResultThroughPlugins(result, command, args, context)
            
            if type(result) == "table" then
                if result.output then
                    return result.output
                elseif result.error then
                    return self:formatError("Erro: " .. result.error)
                else
                    return table.concat(result, "\n")
                end
            elseif type(result) == "string" then
                return result
            elseif result == nil then
                return ""
            else
                return tostring(result)
            end
        else
            return self:formatError("Erro executando comando '" .. command .. "': " .. tostring(result))
        end
    else
        local suggestions = self:findSimilarCommands(command)
        if #suggestions > 0 then
            return command .. ": comando não encontrado\n\nVocê quis dizer?\n" .. table.concat(suggestions, "\n")
        else
            return command .. ": comando não encontrado\nDigite '/help' para comandos disponíveis"
        end
    end
end

function LinuxTerminalSystem:parseAdvancedCommand(input)
    local parts = {}
    local current = ""
    local inQuotes = false
    local quoteChar = nil
    
    for i = 1, #input do
        local char = input:sub(i, i)
        
        if (char == '"' or char == "'") and not inQuotes then
            inQuotes = true
            quoteChar = char
        elseif char == quoteChar and inQuotes then
            inQuotes = false
            quoteChar = nil
        elseif char == " " and not inQuotes then
            if current ~= "" then
                table.insert(parts, current)
                current = ""
            end
        else
            current = current .. char
        end
    end
    
    if current ~= "" then
        table.insert(parts, current)
    end
    
    local command = parts[1] or ""
    local args = {}
    for i = 2, #parts do
        table.insert(args, parts[i])
    end
    
    return command, args
end

function LinuxTerminalSystem:findSimilarCommands(input)
    local suggestions = {}
    local inputLower = input:lower()
    
    for command, _ in pairs(self.commandModules) do
        local cmdName = command:lower()
        
        if cmdName:find(inputLower, 1, true) then
            table.insert(suggestions, command)
        end
    end
    
    table.sort(suggestions, function(a, b)
        return #a < #b
    end)
    
    return suggestions
end

function LinuxTerminalSystem:processResultThroughPlugins(result, command, args, context)
    for pluginName, pluginData in pairs(self.pluginModules) do
        if pluginData.enabled and pluginData.module.processResult then
            local success, processedResult = pcall(function()
                return pluginData.module.processResult(result, command, args, context)
            end)
            
            if success and processedResult then
                result = processedResult
            end
        end
    end
    return result
end

function LinuxTerminalSystem:formatError(errorText)
    for pluginName, pluginData in pairs(self.pluginModules) do
        if pluginData.enabled and pluginData.module.formatError then
            local success, formattedError = pcall(function()
                return pluginData.module.formatError(errorText)
            end)
            
            if success and formattedError then
                return formattedError
            end
        end
    end
    
    return errorText
end

_G.LinuxTerminalSystem = LinuxTerminalSystem.new()

if _G.LinuxTerminalBase then
    
else
    local attempts = 0
    local maxAttempts = 50
    
    local checkConnection
    checkConnection = RunService.Heartbeat:Connect(function()
        attempts = attempts + 1
        if _G.LinuxTerminalBase then
            checkConnection:Disconnect()
        elseif attempts >= maxAttempts then
            checkConnection:Disconnect()
        end
    end)
end

return LinuxTerminalSystem