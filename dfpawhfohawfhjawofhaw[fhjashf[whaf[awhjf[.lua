local ESP = {}

ESP.settings = {
    box = {
        enabled = false,
        color = Color3.new(1, 1, 1),
        thickness = 1,
        transparency = 1,
        filled = false
    },
    text = {
        nameEnabled = false,
        color = Color3.new(1, 1, 1),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    },
    distanceText = {
        enabled = false,
        color = Color3.new(0, 1, 0),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    },
    healthText = {
        enabled = false,
        color = Color3.new(1, 1, 0),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    },
    healthBar = {
        enabled = false,
        color = Color3.new(1, 1, 0),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    }
}

local espObjects = {}

local function CreateESP(part)
    local boxSettings = ESP.settings.box
    local textSettings = ESP.settings.text
    local distanceTextSettings = ESP.settings.distanceText
    local healthTextSettings = ESP.settings.healthText
    local healthBarSettings = ESP.settings.healthBar

    local box = Drawing.new("Square")
    box.Visible = boxSettings.enabled
    box.Color = boxSettings.color
    box.Thickness = boxSettings.thickness
    box.Transparency = boxSettings.transparency
    box.Filled = boxSettings.filled

    local text = Drawing.new("Text")
    text.Visible = textSettings.nameEnabled
    text.Color = textSettings.color
    text.Size = textSettings.size
    text.Center = textSettings.center
    text.Outline = textSettings.outline
    text.OutlineColor = textSettings.outlineColor

    local distancetext = Drawing.new("Text")
    distancetext.Visible = distanceTextSettings.enabled
    distancetext.Color = distanceTextSettings.color
    distancetext.Size = distanceTextSettings.size
    distancetext.Center = distanceTextSettings.center
    distancetext.Outline = distanceTextSettings.outline
    distancetext.OutlineColor = distanceTextSettings.outlineColor

    local healthText = Drawing.new("Text")
    healthText.Visible = healthTextSettings.enabled
    healthText.Color = healthTextSettings.color
    healthText.Size = healthTextSettings.size
    healthText.Center = healthTextSettings.center
    healthText.Outline = healthTextSettings.outline
    healthText.OutlineColor = healthTextSettings.outlineColor

    local healthBarBackground = Drawing.new("Square")
    healthBarBackground.Visible = false
    healthBarBackground.Color = Color3.new(0, 0, 0)
    healthBarBackground.Thickness = 3
    healthBarBackground.Transparency = 0.5
    healthBarBackground.Filled = true

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Thickness = 3
    healthBar.Transparency = 0.5
    healthBar.Filled = true

    local gradientColors = {
        Color3.new(255, 0, 0), -- Red
        Color3.new(255, 255, 0), -- Yellow
        Color3.new(0, 255, 0) -- Green
    }

    return {
        update = function()
            if part and part.Parent then
                local head = part.Parent:FindFirstChild("Head")
                if head then
                    local headPosition, headVisible = workspace.CurrentCamera:WorldToViewportPoint(head.Position - Vector3.new(0, 2, 0))
                    if headVisible then
                        local scaleFactor = 1 / (headPosition.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView / 2)) * 2) * 100
                        local width = math.floor(35 * scaleFactor)
                        local height = math.floor(50 * scaleFactor)
                        local headScreenPosition = Vector2.new(headPosition.X, headPosition.Y)
                        box.Size = Vector2.new(width, height)
                        box.Position = headScreenPosition - Vector2.new(width / 2, height / 2)
                        box.Visible = boxSettings.enabled

                        local nameText = tostring(part.Parent.Name)
                        text.Text = nameText
                        text.Position = headScreenPosition + Vector2.new(0, -(height / 2) - 16)
                        text.Visible = textSettings.nameEnabled

                        local localPlayer = game:GetService("Players").LocalPlayer
                        local localHumanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local distance = localHumanoidRootPart and (part.Position - localHumanoidRootPart.Position).Magnitude or nil

                        if distance then
                            distancetext.Text = string.format("%.1f studs", distance)
                            distancetext.Position = headScreenPosition + Vector2.new(0, (height / 2) + 2)
                            distancetext.Visible = distanceTextSettings.enabled
                        else
                            distancetext.Visible = false
                        end

                        local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            local maxHealth = humanoid.MaxHealth
                            local currentHealth = humanoid.Health

                            if maxHealth > 0 and healthTextSettings.enabled then
                                local healthPercentage = currentHealth / maxHealth
                                healthText.Text = string.format("%d%%", healthPercentage * 100)
                                healthText.Position = headScreenPosition + Vector2.new(0, (height / 2) + 16)
                                healthText.Visible = true

                                healthBarBackground.Size = Vector2.new(5, height)
                                healthBarBackground.Position = headScreenPosition + Vector2.new(width / 2 + 8, -height / 2)
                                healthBarBackground.Visible = healthBarSettings.enabled

                                local gradientIndex = math.floor(healthPercentage * (#gradientColors - 1)) + 1
                                local gradientColor = gradientColors[gradientIndex]
                                healthBar.Color = gradientColor
                                healthBar.Size = Vector2.new(5, height * healthPercentage)
                                healthBar.Position = headScreenPosition + Vector2.new(width / 2 + 8, -height / 2)
                                healthBar.Visible = healthBarSettings.enabled
                       
                    else
                        box.Visible = false
                        text.Visible = false
                        distancetext.Visible = false
                        healthText.Visible = false
                        healthBar.Visible = false
                        healthBarBackground.Visible = false
                    end
                end
            end
    end,
    remove = function()
        box:Remove()
        text:Remove()
        distancetext:Remove()
        healthText:Remove()
        healthBar:Remove()
        healthBarBackground:Remove()
    end
}
end

local function updateESP()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                if not espObjects[character] then
                    espObjects[character] = CreateESP(humanoidRootPart)
                end
                espObjects[character].update()
            end
        end
    end
end

local function handleCharacterAdded(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    espObjects[character] = CreateESP(humanoidRootPart)
end

local function handleCharacterRemoving(character)
    local espObject = espObjects[character]
    if espObject then
        espObject.remove()
        espObjects[character] = nil
    end
end

local function handlePlayerAdded(player)
    local function onCharacterAdded(character)
        handleCharacterAdded(character)
    end

    local function onCharacterRemoving(character)
        handleCharacterRemoving(character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(onCharacterRemoving)

    -- Check if the player already has a character
    if player.Character then
        handleCharacterAdded(player.Character)
    end
end

game:GetService("Players").PlayerAdded:Connect(handlePlayerAdded)
for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    handlePlayerAdded(player)
end

game:GetService("RunService").Heartbeat:Connect(updateESP)

return ESP
