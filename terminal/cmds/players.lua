-- Players Command Module - Show information about all players in the server
-- Place this in StarterPlayerScripts.terminal.cmds as "players" (ModuleScript)

local PlayersCommand = {}

function PlayersCommand.execute(args, context)
    local Players = game:GetService("Players")
    local allPlayers = Players:GetPlayers()
    
    if #allPlayers == 0 then
        return "📭 No players found in the server."
    end
    
    -- Create header
    local result = [[
╭─────────────────────────────────────────────────────────────╮
│                      PLAYERS IN SERVER                     │
╰─────────────────────────────────────────────────────────────╯

Players Online: ]] .. #allPlayers .. "/" .. Players.MaxPlayers .. "\n"
    
    result = result .. string.rep("=", 65) .. "\n"
    result = result .. string.format("%-20s %-25s %-15s\n", "[ USERNAME ]", "[ DISPLAY NAME ]", "[ USER ID ]")
    result = result .. string.rep("-", 65) .. "\n"
    
    -- Sort players alphabetically by username
    table.sort(allPlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    
    -- List all players with their information
    for i, player in ipairs(allPlayers) do
        local username = player.Name
        local displayName = player.DisplayName
        local userId = tostring(player.UserId)
        
        -- Truncate long names to fit the format
        if #username > 18 then
            username = username:sub(1, 15) .. "..."
        end
        if #displayName > 23 then
            displayName = displayName:sub(1, 20) .. "..."
        end
        
        -- Add indicator for current player
        local indicator = ""
        if player == context.player then
            indicator = "🔹 "
        end
        
        result = result .. string.format("%s%-18s %-25s %-15s\n", 
            indicator, username, displayName, userId)
    end
    
    result = result .. string.rep("=", 65) .. "\n"
    
    -- Add additional server information
    result = result .. "\nServer Information:\n"
    result = result .. "• Max Players: " .. Players.MaxPlayers .. "\n"
    result = result .. "• Current Players: " .. #allPlayers .. "\n"
    result = result .. "• Available Slots: " .. (Players.MaxPlayers - #allPlayers) .. "\n"
    
    -- Add legend
    result = result .. "\nLegend:\n"
    result = result .. "🔹 = You (current player)\n"
    result = result .. "\nTip: Use '/lua /player/clone.lua [username]' to clone another player's appearance!"
    
    return result
end

-- Command information
PlayersCommand.name = "players"
PlayersCommand.description = "Display information about all players in the server"
PlayersCommand.usage = "/players"
PlayersCommand.author = "Terminal System"
PlayersCommand.version = "1.0"
PlayersCommand.examples = {
    "/players - Show all players with usernames, display names, and IDs"
}

return PlayersCommand