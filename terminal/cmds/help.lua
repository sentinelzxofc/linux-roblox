-- Help Command Module for Linux Terminal
-- Place this in StarterPlayerScripts.cmds as "help" (ModuleScript)

local HelpCommand = {}

function HelpCommand.execute(args, context)
    -- Enhanced help with dynamic command detection
    local availableCommands = {}
    
    -- Get all commands from the system
    local commands = context.utils.getCommands()
    
    local helpText = [[
╭─────────────────────────────────────────────────────────────╮
│                    LINUX ROBLOX TERMINAL                   │
│                    ENHANCED HELP MENU                      │
╰─────────────────────────────────────────────────────────────╯

Available Commands:
==================
]]
    
    -- Add available commands dynamically (organized by type)
    local rootCommands = {}
    local organizedCommands = {}
    
    for _, cmd in ipairs(commands) do
        local fullCmd = "/" .. cmd
        if fullCmd:find("/lua /") then
            -- Organized command
            table.insert(organizedCommands, fullCmd)
        else
            -- Root command
            table.insert(rootCommands, fullCmd)
        end
    end
    
    -- Show root commands first
    if #rootCommands > 0 then
        helpText = helpText .. "\nRoot Commands:\n" .. string.rep("-", 14) .. "\n"
        for _, cmd in ipairs(rootCommands) do
            local info = context.system:getCommandInfo(cmd)
            if info then
                helpText = helpText .. string.format("%-20s - %s\n", cmd, info.description)
            else
                helpText = helpText .. string.format("%-20s - %s\n", cmd, "No description")
            end
        end
    end
    
    -- Show organized commands
    if #organizedCommands > 0 then
        helpText = helpText .. "\nOrganized Commands:\n" .. string.rep("-", 19) .. "\n"
        for _, cmd in ipairs(organizedCommands) do
            local info = context.system:getCommandInfo(cmd)
            if info then
                helpText = helpText .. string.format("%-35s - %s\n", cmd, info.description)
            else
                helpText = helpText .. string.format("%-35s - %s\n", cmd, "No description")
            end
        end
    end
    
    helpText = helpText .. [[

Command Organization:
====================
• Root Commands: /commandname
• Organized Commands: /lua /folder/script.lua
• Plugin System: Automatic error highlighting and processing

New Features:
=============
• 📁 Folder Organization: Commands can be organized in folders
• 🔌 Plugin System: Extensible functionality through plugins  
• 🔴 Error Highlighting: Automatic red highlighting of errors
• 🔄 Hot Reloading: Add commands/plugins without restart
• 📊 Enhanced Context: Full access to player, terminal, session data

Advanced Features:
==================
• Arguments Support: /command arg1 arg2 "quoted arg"
• Interactive Commands: Commands can request input
• Session Data: Commands can store data between executions
• Hot Reloading: Add new commands without restarting
• Error Handling: Comprehensive error reporting
• Command Suggestions: Similar command recommendations
• Plugin Processing: Results processed through plugin system

System Features:
================
• Click anywhere in terminal to focus input
• Press Enter on empty line for new prompt
• Use Up/Down arrows for command history
• Window controls: minimize (-), maximize (□), close (×)
• Type /terminal in Roblox chat to reopen terminal
• Live command loading from organized cmds folder
• Plugin system for enhanced functionality

Window Controls:
================
• Drag title bar to move terminal
• Click minimize (-) to collapse to title bar
• Click maximize (□) to expand to full screen
• Click close (×) to hide terminal

For Developers:
===============
• Root Commands: Create ModuleScript in StarterPlayerScripts.terminal.cmds
• Organized Commands: Create in terminal.cmds/folder/script (access via /lua /folder/script.lua)
• Plugins: Create ModuleScript in StarterPlayerScripts.terminal.sistema
• Implement execute(args, context) function for commands
• Implement formatError(text) and processResult(...) for plugins
• Access context.utils for terminal interaction
• Use context.sessionData for persistence
• Return string for output or table for complex results

Examples:
=========
/help                           - Show this help
/help commandname               - Show specific command help
/lua /player/height.lua 100     - Organized command with args
/command "quoted arg"            - Command with quoted argument
/system info                    - System information and stats

Repository:
===========
https://github.com/sentinelzxofc/linux-roblox

Note: This terminal supports unlimited extensibility with
organized folder structure and plugin system!
Commands are loaded from StarterPlayerScripts.terminal.cmds
Plugins are loaded from StarterPlayerScripts.terminal.sistema
]]
    
    -- If specific command help requested
    if args[1] then
        local cmdInfo = context.system:getCommandInfo(args[1])
        if cmdInfo then
            helpText = [[
╭─────────────────────────────────────────────────────────────╮
│                    COMMAND INFORMATION                     │
╰─────────────────────────────────────────────────────────────╯

]] .. string.format([[Command: %s
Description: %s
Usage: %s
Author: %s
Version: %s

]], 
                cmdInfo.name, 
                cmdInfo.description, 
                cmdInfo.usage, 
                cmdInfo.author, 
                cmdInfo.version)
            
            if #cmdInfo.examples > 0 then
                helpText = helpText .. "Examples:\n"
                for _, example in ipairs(cmdInfo.examples) do
                    helpText = helpText .. "  " .. example .. "\n"
                end
            end
        else
            helpText = "Command '" .. args[1] .. "' not found."
        end
    end
    
    return helpText
end

-- Command information
HelpCommand.name = "help"
HelpCommand.description = "Display available commands and system information"
HelpCommand.usage = "/help [command]"
HelpCommand.author = "Terminal System"
HelpCommand.version = "2.0"
HelpCommand.examples = {
    "/help - Shows all available commands",
    "/help commandname - Shows specific command information"
}

return HelpCommand