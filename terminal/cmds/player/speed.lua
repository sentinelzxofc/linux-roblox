-- Speed Command Module - Example of organized command with arguments
-- Place this in StarterPlayerScripts.terminal.cmds.player as "speed" (ModuleScript)
-- Access with: /lua /player/speed.lua <number>

local SpeedCommand = {}

function SpeedCommand.execute(args, context)
    local player = context.player
    
    -- Check if argument provided
    if not args[1] then
        return [[
Usage: /lua /player/speed.lua <number>

Sets your character's walkspeed.

Examples:
  /lua /player/speed.lua 16    - Normal speed
  /lua /player/speed.lua 50    - Fast speed  
  /lua /player/speed.lua 100   - Very fast speed

Current speed: ]] .. (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.WalkSpeed or "Unknown")
    end
    
    local speed = tonumber(args[1])
    if not speed then
        return "Error: Speed must be a number. Example: /speed 50"
    end
    
    if speed < 0 or speed > 200 then
        return "Error: Speed must be between 0 and 200"
    end
    
    -- Apply speed
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed
        
        -- Store in session data
        context.sessionData.lastSpeed = speed
        
        return string.format("Speed set to %d. Previous speeds can be viewed with /lua /player/speed.lua history", speed)
    else
        return "Error: Character not found. Make sure you're spawned in the game."
    end
end

-- Command information
SpeedCommand.name = "speed"
SpeedCommand.description = "Set character walkspeed with validation"
SpeedCommand.usage = "/lua /player/speed.lua <number>"
SpeedCommand.author = "Terminal System"
SpeedCommand.version = "1.0"
SpeedCommand.examples = {
    "/lua /player/speed.lua 16 - Set normal speed",
    "/lua /player/speed.lua 50 - Set fast speed",
    "/lua /player/speed.lua - Show current speed and usage"
}

return SpeedCommand