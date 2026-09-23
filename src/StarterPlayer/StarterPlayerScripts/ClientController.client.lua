local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local restaurantFolder = ReplicatedStorage:WaitForChild("RestaurantRush")
local stateChanged = restaurantFolder:WaitForChild("StateChanged")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RestaurantRushHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 300, 0, 110)
panel.Position = UDim2.new(0, 20, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Restaurant Rush"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 204, 94)
title.Parent = panel

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.Size = UDim2.new(1, -20, 0, 60)
stats.Position = UDim2.new(0, 10, 0, 42)
stats.BackgroundTransparency = 1
stats.Text = "Money: $200 | Level: 1 | Rating: 4.0"
stats.Font = Enum.Font.GothamMedium
stats.TextScaled = true
stats.TextColor3 = Color3.fromRGB(255, 255, 255)
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.Parent = panel

local function updateHUD(state)
	if not state then
		return
	end

	local money = state.Money or 0
	local level = state.RestaurantLevel or 1
	local rating = state.Rating or 4.0
	stats.Text = string.format("Money: $%d | Level: %d | Rating: %.1f", money, level, rating)
end

stateChanged.OnClientEvent:Connect(function(state)
	updateHUD(state)
end)

updateHUD({
	Money = 200,
	RestaurantLevel = 1,
	Rating = 4.0,
})

print("Restaurant Rush client HUD loaded.")
