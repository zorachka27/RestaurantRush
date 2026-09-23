local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.Services.DataService)
local KitchenService = require(script.Parent.Services.KitchenService)
local RestaurantService = require(script.Parent.Services.RestaurantService)
local WorkerService = require(script.Parent.Services.WorkerService)
local UpgradeService = require(script.Parent.Services.UpgradeService)

local restaurantFolder = ReplicatedStorage:FindFirstChild("RestaurantRush") or Instance.new("Folder")
restaurantFolder.Name = "RestaurantRush"
restaurantFolder.Parent = ReplicatedStorage

local stateChangedEvent = restaurantFolder:FindFirstChild("StateChanged") or Instance.new("RemoteEvent")
stateChangedEvent.Name = "StateChanged"
stateChangedEvent.Parent = restaurantFolder

local requestActionEvent = restaurantFolder:FindFirstChild("RequestAction") or Instance.new("RemoteEvent")
requestActionEvent.Name = "RequestAction"
requestActionEvent.Parent = restaurantFolder

local remotes = {
    StateChanged = stateChangedEvent,
    RequestAction = requestActionEvent,
}

KitchenService:Start(DataService, remotes)
WorkerService:Start(DataService, remotes)
UpgradeService:Start(DataService, remotes)
RestaurantService:Start(DataService, remotes, KitchenService, WorkerService, UpgradeService)

print("Restaurant Rush foundation initialized.")
