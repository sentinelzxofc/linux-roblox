-- Player Folder Command Example - Organized command structure
-- This demonstrates how commands work in organized folders
-- Path: /lua /player/player-info.lua

local PlayerInfoCommand = {}

function PlayerInfoCommand.execute(args, context)
    local player = context.player
    
    return string.format([[
╭─────────────────────────────────────────────────────────────╮
│                    PLAYER INFORMATION                       │
╰─────────────────────────────────────────────────────────────╯

Basic Info:
───────────
Username: %s
Display Name: %s
User ID: %d
Account Age: %d days

Premium Status:
───────────────
Membership: %s
Premium: %s

Game Stats:
───────────
Current Place: %s
Place ID: %d
Game ID: %d
Server Job ID: %s

Character Info:
───────────────
Character Exists: %s
Health: %s
WalkSpeed: %s
JumpPower: %s

Location:
─────────
Spawned: %s

Note: This command is organized in /player/ folder
Access with: /lua /player/player-info.lua]], 
        player.Name,
        player.DisplayName,
        player.UserId,
        player.AccountAge,
        tostring(player.MembershipType),
        player.MembershipType == Enum.MembershipType.Premium and "Yes" or "No",
        game.Name,
        game.PlaceId,
        game.GameId,
        game.JobId:sub(1, 12) .. "...",
        player.Character and "Yes" or "No",
        player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health or "N/A",
        player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.WalkSpeed or "N/A",
        player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.JumpPower or "N/A",
        player.Character and "In Game" or "Not Spawned"
    )
end

-- Command information
PlayerInfoCommand.name = "player-info"
PlayerInfoCommand.description = "Display comprehensive player information"
PlayerInfoCommand.usage = "/lua /player/player-info.lua"
PlayerInfoCommand.author = "Terminal System"
PlayerInfoCommand.version = "1.0"
PlayerInfoCommand.examples = {
    "/lua /player/player-info.lua - Show detailed player information"
}

return PlayerInfoCommand