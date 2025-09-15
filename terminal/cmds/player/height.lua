local HeightCommand = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local scaleRemote = ReplicatedStorage:FindFirstChild("ScaleCharacterRemote")
if not scaleRemote then
    scaleRemote = Instance.new("RemoteEvent")
    scaleRemote.Name = "ScaleCharacterRemote"
    scaleRemote.Parent = ReplicatedStorage
end

local function applyServerScaling(player, scale)
    spawn(function()
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            
            local scaleProperties = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}
            for _, propName in ipairs(scaleProperties) do
                local scaleObj = humanoid:FindFirstChild(propName)
                if not scaleObj then
                    scaleObj = Instance.new("NumberValue")
                    scaleObj.Name = propName
                    scaleObj.Parent = humanoid
                end
                scaleObj.Value = scale
            end
            
            wait(0.1)
            pcall(function()
                humanoid:BuildRigFromAttachments()
            end)
            
            wait(0.1)
            pcall(function()
                local humanoidDesc = humanoid:GetAppliedDescription()
                humanoidDesc.DepthScale = scale
                humanoidDesc.HeightScale = scale  
                humanoidDesc.WidthScale = scale
                humanoidDesc.HeadScale = scale
                humanoid:ApplyDescription(humanoidDesc)
            end)
            
            _G["PlayerScale_" .. player.UserId] = scale
        end
    end)
end

if RunService:IsServer() then
    scaleRemote.OnServerEvent:Connect(function(player, scale)
        applyServerScaling(player, scale)
    end)
else
    scaleRemote.OnClientEvent:Connect(function(targetPlayer, scale)
        if targetPlayer and targetPlayer.Character then
            applyServerScaling(targetPlayer, scale)
        end
    end)
end

local function scaleCharacter(player, scale)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then
        return false, "Personagem ou Humanoid não encontrado"
    end
    
    local humanoid = character.Humanoid
    
    local localSuccess = pcall(function()
        local scaleProperties = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}
        for _, propName in ipairs(scaleProperties) do
            local scaleObj = humanoid:FindFirstChild(propName)
            if not scaleObj then
                scaleObj = Instance.new("NumberValue")
                scaleObj.Name = propName
                scaleObj.Parent = humanoid
            end
            scaleObj.Value = scale
        end
        
        wait(0.1)
        humanoid:BuildRigFromAttachments()
    end)
    
    if localSuccess then
        local humanoidDesc = humanoid:GetAppliedDescription()
        humanoidDesc.DepthScale = scale
        humanoidDesc.HeightScale = scale  
        humanoidDesc.WidthScale = scale
        humanoidDesc.HeadScale = scale
        humanoid:ApplyDescription(humanoidDesc)
    end
    
    if RunService:IsClient() then
        scaleRemote:FireServer(scale)
        scaleRemote:FireAllClients(player, scale)
    else
        applyServerScaling(player, scale)
        scaleRemote:FireAllClients(player, scale)
    end
    
    return true, "Escala aplicada: " .. tostring(scale) .. " - Todos os jogadores podem ver!"
end

function HeightCommand.execute(args, context)
    if not args or #args == 0 then
        return false, "Uso: height <escala> (ex: height 2 para tamanho duplo, height 0.5 para metade)"
    end
    
    local scaleValue = tonumber(args[1])
    if not scaleValue then
        return false, "Valor de escala inválido. Por favor forneça um número."
    end
    
    if scaleValue < 0.1 then
        scaleValue = 0.1
    elseif scaleValue > 10 then
        scaleValue = 10
    end
    
    local player = context.player
    if not player then
        return false, "Contexto do jogador não encontrado"
    end
    
    local success, message = scaleCharacter(player, scaleValue)
    return success, message
end

return HeightCommand