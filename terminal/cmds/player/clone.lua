-- Clone Command Module - Clone another player's character appearance
-- Place this in StarterPlayerScripts.terminal.cmds.player as "clone" (ModuleScript)

local CloneCommand = {}

function CloneCommand.execute(args, context)
    local player = context.player
    local Players = game:GetService("Players")
    
    -- Check if target player name was provided
    if not args[1] then
        return [[
Usage: /lua /player/clone.lua [username]

Clone another player's character appearance (clothing, accessories, colors).

Examples:
  /lua /player/clone.lua sentinelzxofc  - Clone sentinelzxofc's appearance
  /lua /player/clone.lua john123        - Clone john123's appearance
  /lua /player/clone.lua "Display Name" - Clone using display name (with quotes)

Tips:
• Use /players to see all available players
• The target player must be in the same server
• Your character will be respawned with the new appearance
• Original height/scale will be preserved
]]
    end
    
    local targetName = args[1]
    local targetPlayer = nil
    
    -- Find the target player (try username first, then display name)
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == targetName:lower() or p.DisplayName:lower() == targetName:lower() then
            targetPlayer = p
            break
        end
    end
    
    -- If not found, try partial match
    if not targetPlayer then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():find(targetName:lower(), 1, true) or 
               p.DisplayName:lower():find(targetName:lower(), 1, true) then
                targetPlayer = p
                break
            end
        end
    end
    
    if not targetPlayer then
        return "❌ Player '" .. targetName .. "' not found in the server.\n\n💡 Use /players to see all available players."
    end
    
    if targetPlayer == player then
        return "🤔 You can't clone yourself! You already look like... you."
    end
    
    if not targetPlayer.Character then
        return "❌ Target player '" .. targetPlayer.Name .. "' doesn't have a character loaded."
    end
    
    if not player.Character then
        return "❌ You don't have a character loaded. Please spawn first."
    end
    
    -- Store current scale if any
    local currentScale = 1
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local scaleValue = leaderstats:FindFirstChild("CharacterScale")
        if scaleValue then
            currentScale = scaleValue.Value
        end
    end
    
    -- Get target player's HumanoidDescription
    local success, targetDescription = pcall(function()
        local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then
            return targetHumanoid:GetAppliedDescription()
        end
        return nil
    end)
    
    if not success or not targetDescription then
        return "❌ Failed to get appearance data from '" .. targetPlayer.Name .. "'. They might have restricted avatar copying."
    end
    
    -- Apply the appearance to current player
    local applySuccess = pcall(function()
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Apply the cloned appearance
            humanoid:ApplyDescription(targetDescription)
            
            -- Wait a moment then restore scale if it was different from 1
            if currentScale ~= 1 then
                task.wait(1) -- Wait for appearance to load
                
                -- Restore the scale
                local scaleProperties = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}
                for _, propName in ipairs(scaleProperties) do
                    local scaleObj = humanoid:FindFirstChild(propName)
                    if not scaleObj then
                        scaleObj = Instance.new("NumberValue")
                        scaleObj.Name = propName
                        scaleObj.Parent = humanoid
                    end
                    scaleObj.Value = currentScale
                end
            end
        end
    end)
    
    if applySuccess then
        local result = "✅ Successfully cloned " .. targetPlayer.Name .. "'s appearance!"
        result = result .. "\n\n👤 Target Player Info:"
        result = result .. "\n• Username: " .. targetPlayer.Name
        result = result .. "\n• Display Name: " .. targetPlayer.DisplayName
        result = result .. "\n• User ID: " .. targetPlayer.UserId
        
        if currentScale ~= 1 then
            result = result .. "\n\n📏 Your custom scale (" .. currentScale .. "x) has been preserved."
        end
        
        result = result .. "\n\n💡 Tip: Use /reset to return to your original appearance."
        
        -- Store clone history in session data
        if not context.sessionData.cloneHistory then
            context.sessionData.cloneHistory = {}
        end
        
        table.insert(context.sessionData.cloneHistory, {
            targetName = targetPlayer.Name,
            targetDisplayName = targetPlayer.DisplayName,
            targetUserId = targetPlayer.UserId,
            timestamp = tick()
        })
        
        -- Keep only last 10 clones
        if #context.sessionData.cloneHistory > 10 then
            table.remove(context.sessionData.cloneHistory, 1)
        end
        
        return result
    else
        return "❌ Failed to apply appearance. This might be due to Roblox restrictions or the target player having a private avatar."
    end
end

-- Command information
CloneCommand.name = "clone"
CloneCommand.description = "Clone another player's character appearance including clothing and accessories"
CloneCommand.usage = "/lua /player/clone.lua [username]"
CloneCommand.author = "Terminal System"
CloneCommand.version = "1.0"
CloneCommand.examples = {
    "/lua /player/clone.lua sentinelzxofc - Clone sentinelzxofc's appearance",
    "/lua /player/clone.lua john123 - Clone john123's appearance",
    "/lua /player/clone.lua \"Display Name\" - Clone using display name"
}

return CloneCommand