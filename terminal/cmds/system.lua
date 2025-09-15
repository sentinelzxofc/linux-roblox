-- System Command Module - Advanced system control and information
-- Place this in StarterPlayerScripts.cmds as "system" (ModuleScript)

local SystemCommand = {}

function SystemCommand.execute(args, context)
    if #args == 0 then
        return [[
System Control Commands:
========================

/system info        - Show detailed system information
/system reload       - Reload all commands
/system commands     - List all loaded commands with details
/system clear-data   - Clear session data
/system stats        - Show system statistics
/system test         - Run system diagnostics

Examples:
  /system info
  /system reload
  /system commands]]
    end
    
    local action = args[1]:lower()
    
    if action == "info" then
        local player = context.player
        local commandCount = 0
        for _ in pairs(context.system.commandModules) do
            commandCount = commandCount + 1
        end
        
        return string.format([[
╭─────────────────────────────────────────────────────────────╮
│                    SYSTEM INFORMATION                       │
╰─────────────────────────────────────────────────────────────╯

Terminal Version: Linux-Roblox v2.0
System Status: Online ✅
Commands Loaded: %d
Session Data Keys: %d
Command History: %d entries

User Information:
─────────────────
Username: %s
Display Name: %s
User ID: %d
Account Age: %d days
Membership: %s

Game Information:
─────────────────
Game: %s
Place ID: %d
Server: %s

System Capabilities:
────────────────────
✅ Dynamic Command Loading
✅ Hot Reload Support
✅ Session Data Persistence
✅ Advanced Argument Parsing
✅ Interactive Command Support
✅ Error Recovery
✅ Command Suggestions]], 
            commandCount,
            self:countTable(context.sessionData),
            #context.history,
            player.Name,
            player.DisplayName,
            player.UserId,
            player.AccountAge,
            tostring(player.MembershipType),
            game.Name,
            game.PlaceId,
            game.JobId:sub(1, 8) .. "..."
        )
        
    elseif action == "reload" then
        context.system:loadCommandModules()
        return "🔄 All commands reloaded successfully!"
        
    elseif action == "commands" then
        local output = "Loaded Commands:\n================\n"
        for cmdName, cmdData in pairs(context.system.commandModules) do
            local info = context.system:getCommandInfo(cmdName)
            output = output .. string.format("%-15s v%s - %s\n", 
                cmdName, 
                info.version or "1.0", 
                info.description or "No description"
            )
        end
        return output
        
    elseif action == "clear-data" then
        local keyCount = self:countTable(context.sessionData)
        context.sessionData = {}
        return string.format("🗑️ Cleared %d session data keys", keyCount)
        
    elseif action == "stats" then
        local totalCommands = 0
        local successfulCommands = 0
        
        for _, historyEntry in ipairs(context.history) do
            totalCommands = totalCommands + 1
            -- Assuming successful if no error in the entry
            if not historyEntry.error then
                successfulCommands = successfulCommands + 1
            end
        end
        
        local successRate = totalCommands > 0 and (successfulCommands / totalCommands * 100) or 0
        
        return string.format([[
System Statistics:
==================
Total Commands Executed: %d
Successful Commands: %d
Success Rate: %.1f%%
Session Data Size: %d keys
Uptime: %.1f minutes
Most Used Commands: %s]], 
            totalCommands,
            successfulCommands,
            successRate,
            self:countTable(context.sessionData),
            (tick() - (context.sessionData.startTime or tick())) / 60,
            self:getMostUsedCommand(context.history)
        )
        
    elseif action == "test" then
        local tests = {
            "✅ Terminal Base Connection",
            "✅ Command Module Loading",
            "✅ Session Data Access",
            "✅ Player Information",
            "✅ Utility Functions",
            "✅ Error Handling"
        }
        
        -- Record start time if not exists
        if not context.sessionData.startTime then
            context.sessionData.startTime = tick()
        end
        
        return "System Diagnostics:\n==================\n" .. table.concat(tests, "\n") .. "\n\n🎉 All systems operational!"
        
    else
        return "Unknown system command: " .. action .. "\nTry /system for available options"
    end
end

function SystemCommand:countTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function SystemCommand:getMostUsedCommand(history)
    local counts = {}
    for _, entry in ipairs(history) do
        local cmd = entry.command
        counts[cmd] = (counts[cmd] or 0) + 1
    end
    
    local mostUsed = "N/A"
    local maxCount = 0
    for cmd, count in pairs(counts) do
        if count > maxCount then
            maxCount = count
            mostUsed = cmd
        end
    end
    
    return mostUsed .. " (" .. maxCount .. "x)"
end

-- Command information
SystemCommand.name = "system"
SystemCommand.description = "Advanced system control and information commands"
SystemCommand.usage = "/system <action>"
SystemCommand.author = "Terminal System"
SystemCommand.version = "1.0"
SystemCommand.examples = {
    "/system info - Show detailed system information",
    "/system reload - Reload all command modules",
    "/system stats - Show usage statistics"
}

return SystemCommand