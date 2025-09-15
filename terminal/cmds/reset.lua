-- Reset Command Module - Reset player character
-- Place this in StarterPlayerScripts.terminal.cmds as "reset" (ModuleScript)

local ResetCommand = {}

function ResetCommand.execute(args, context)
    local player = context.player
    
    if not player.Character then
        return "❌ Error: No character to reset. You need to be spawned first."
    end
    
    -- Reset the character
    local success = pcall(function()
        player.Character.Humanoid.Health = 0
    end)
    
    if success then
        return "🔄 Character reset successfully! You will respawn shortly."
    else
        -- Alternative reset method
        local success2 = pcall(function()
            player:LoadCharacter()
        end)
        
        if success2 then
            return "🔄 Character reset using alternative method! You will respawn shortly."
        else
            return "❌ Error: Failed to reset character. Try again or contact an admin."
        end
    end
end

-- Command information
ResetCommand.name = "reset"
ResetCommand.description = "Reset your character (respawn)"
ResetCommand.usage = "/reset"
ResetCommand.author = "Terminal System"
ResetCommand.version = "1.0"
ResetCommand.examples = {
    "/reset - Reset your character and respawn"
}

return ResetCommand