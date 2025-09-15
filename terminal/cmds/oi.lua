-- OI Command Module - Example of interactive command
-- Place this in StarterPlayerScripts.cmds as "oi" (ModuleScript)

local OiCommand = {}

function OiCommand.execute(args, context)
    local player = context.player
    
    -- Handle different argument scenarios
    if #args == 0 then
        -- No arguments - basic greeting
        return string.format("Oi %s! Como você está?\\n\\nTente: /oi pergunta\\nOu: /oi \"como você está?\"", player.DisplayName)
    end
    
    local message = table.concat(args, " "):lower()
    
    -- Interactive responses based on input
    if message:find("como") and (message:find("está") or message:find("esta")) then
        local responses = {
            "Estou ótimo, obrigado por perguntar! 😊",
            "Funcionando perfeitamente no terminal Linux-Roblox! 🐧",
            "Sempre bem quando estou ajudando no terminal! ⚡",
            "Excelente! Pronto para executar mais comandos! 🚀"
        }
        local randomResponse = responses[math.random(1, #responses)]
        
        -- Store interaction in session
        if not context.sessionData.oiInteractions then
            context.sessionData.oiInteractions = 0
        end
        context.sessionData.oiInteractions = context.sessionData.oiInteractions + 1
        
        return string.format("%s\\n\\n(Interação #%d com o comando /oi)", randomResponse, context.sessionData.oiInteractions)
        
    elseif message:find("bom dia") or message:find("boa tarde") or message:find("boa noite") then
        local hour = tonumber(os.date("%H"))
        local greeting
        if hour >= 6 and hour < 12 then
            greeting = "Bom dia"
        elseif hour >= 12 and hour < 18 then
            greeting = "Boa tarde"
        else
            greeting = "Boa noite"
        end
        
        return string.format("%s, %s! 🌅 Que bom ver você no terminal!", greeting, player.DisplayName)
        
    elseif message:find("tchau") or message:find("até") then
        return "Até logo! Continue explorando o terminal Linux-Roblox! 👋"
        
    elseif message:find("ajuda") or message:find("help") then
        return [[
O comando /oi é interativo! Experimente:

🗨️  /oi como você está?
🌅  /oi bom dia
👋  /oi tchau
❓  /oi pergunta qualquer coisa
💬  /oi "frase entre aspas"

Eu respondo baseado no que você escrever!]]
        
    else
        -- Generic response for other inputs
        local responses = {
            "Interessante o que você disse: '" .. table.concat(args, " ") .. "'",
            "Hmm, entendi. Você disse: '" .. table.concat(args, " ") .. "'",
            "Legal! Sobre '" .. table.concat(args, " ") .. "', me faz pensar...",
            "Que conversa boa! Você mencionou: '" .. table.concat(args, " ") .. "'"
        }
        
        return responses[math.random(1, #responses)] .. "\\n\\nTente /oi ajuda para ver mais opções!"
    end
end

-- Command information
OiCommand.name = "oi"
OiCommand.description = "Interactive greeting command with smart responses"
OiCommand.usage = "/oi [message]"
OiCommand.author = "Terminal System"
OiCommand.version = "1.0"
OiCommand.examples = {
    "/oi - Simple greeting",
    "/oi como você está? - Ask how it's going",
    "/oi bom dia - Greet with time awareness",
    "/oi \"mensagem complexa\" - Message with quotes"
}

return OiCommand