local LuaCommand = {}

function LuaCommand.execute(args, context)
    if not args or #args == 0 then
        return "Uso: /lua /pasta/script.lua [argumentos...]"
    end
    
    local scriptPath = args[1]
    
    if scriptPath:sub(1, 1) == "/" then
        scriptPath = scriptPath:sub(2)
    end
    
    local parts = {}
    for part in scriptPath:gmatch("[^/]+") do
        table.insert(parts, part)
    end
    
    if #parts < 2 then
        return "❌ Formato de caminho inválido. Use: /lua /pasta/script.lua"
    end
    
    local folderName = parts[1]
    local scriptName = parts[2]
    
    if scriptName:match("%.lua$") then
        scriptName = scriptName:gsub("%.lua$", "")
    end
    
    local LinuxTerminalSystem = _G.LinuxTerminalSystem
    
    if not LinuxTerminalSystem or not LinuxTerminalSystem.organizedScripts then
        return "❌ Sistema terminal não carregado ou scripts organizados não disponíveis"
    end
    
    if not LinuxTerminalSystem.organizedScripts[folderName] then
        return "❌ Pasta '" .. folderName .. "' não encontrada"
    end
    
    if not LinuxTerminalSystem.organizedScripts[folderName][scriptName] then
        return "❌ Script '" .. scriptName .. ".lua' não encontrado na pasta '" .. folderName .. "'"
    end
    
    local scriptModule = LinuxTerminalSystem.organizedScripts[folderName][scriptName]
    
    local scriptArgs = {}
    for i = 2, #args do
        table.insert(scriptArgs, args[i])
    end
    
    if scriptModule and scriptModule.execute then
        local success, result = pcall(function()
            return scriptModule.execute(scriptArgs, context)
        end)
        
        if success then
            return result or ("✅ Executado " .. folderName .. "/" .. scriptName .. ".lua com sucesso")
        else
            return "❌ Erro ao executar script: " .. tostring(result)
        end
    elseif scriptModule and scriptModule.module and scriptModule.module.execute then
        local success, result = pcall(function()
            return scriptModule.module.execute(scriptArgs, context)
        end)
        
        if success then
            return result or ("✅ Executado " .. folderName .. "/" .. scriptName .. ".lua com sucesso")
        else
            return "❌ Erro ao executar script: " .. tostring(result)
        end
    else
        return "❌ Script '" .. scriptName .. ".lua' não tem uma função execute"
    end
end

return LuaCommand