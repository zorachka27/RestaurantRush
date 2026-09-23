local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared") or Instance.new("Folder")
sharedFolder.Name = "Shared"
sharedFolder.Parent = ReplicatedStorage

local DataService = require(script.Parent.Services.DataService)
local RestaurantService = require(script.Parent.Services.RestaurantService)

local restaurantFolder = ReplicatedStorage:FindFirstChild("RestaurantRush") or Instance.new("Folder")
restaurantFolder.Name = "RestaurantRush"
restaurantFolder.Parent = ReplicatedStorage

local stateChangedEvent = restaurantFolder:FindFirstChild("StateChanged") or Instance.new("RemoteEvent")
stateChangedEvent.Name = "StateChanged"
stateChangedEvent.Parent = restaurantFolder

local requestActionEvent = restaurantFolder:FindFirstChild("RequestAction") or Instance.new("RemoteEvent")
requestActionEvent.Name = "RequestAction"
requestActionEvent.Parent = restaurantFolder

RestaurantService:Start(DataService, {
    StateChanged = stateChangedEvent,
    RequestAction = requestActionEvent,
})

print("Restaurant Rush foundation initialized.")
