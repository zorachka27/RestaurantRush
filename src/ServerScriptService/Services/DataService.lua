local DataStoreService = game:GetService("DataStoreService")
local Config = require(game.ReplicatedStorage.Shared.Config)

local DataService = {}

local DATASTORE_KEY = "RestaurantRushV1"
local dataStore = DataStoreService:GetDataStore(DATASTORE_KEY)
local playerStates = {}

local function deepClone(value)
	if typeof(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, item in pairs(value) do
		copy[key] = deepClone(item)
	end
	return copy
end

local function makeDefaultState()
	return deepClone(Config.DefaultState)
end

local function sanitizeState(state)
	if typeof(state) ~= "table" then
		return makeDefaultState()
	end

	local defaultState = makeDefaultState()
	for key, value in pairs(defaultState) do
		if state[key] == nil then
			state[key] = deepClone(value)
		end
	end

	if typeof(state.Workers) ~= "table" then
		state.Workers = deepClone(defaultState.Workers)
	end

	if typeof(state.WorkerLevels) ~= "table" then
		state.WorkerLevels = deepClone(defaultState.WorkerLevels)
	end

	if typeof(state.UnlockedFoods) ~= "table" then
		state.UnlockedFoods = deepClone(defaultState.UnlockedFoods)
	end

	if typeof(state.UnlockedLocations) ~= "table" then
		state.UnlockedLocations = deepClone(defaultState.UnlockedLocations)
	end

	return state
end

function DataService:LoadPlayer(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return dataStore:GetAsync(key)
	end)

	local state = success and data or nil
	state = sanitizeState(state or makeDefaultState())
	playerStates[player.UserId] = state
	return deepClone(state)
end

function DataService:GetPlayerState(player)
	local userId = player.UserId
	if not playerStates[userId] then
		playerStates[userId] = makeDefaultState()
	end

	return playerStates[userId]
end

function DataService:SetPlayerState(player, state)
	local sanitized = sanitizeState(state)
	playerStates[player.UserId] = sanitized
	return deepClone(sanitized)
end

function DataService:SavePlayer(player)
	local state = self:GetPlayerState(player)
	state.LastSavedAt = os.time()

	local success, err = pcall(function()
		dataStore:SetAsync("Player_" .. player.UserId, state)
	end)

	if not success then
		warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
	end

	return success
end

function DataService:ResetPlayer(player)
	playerStates[player.UserId] = makeDefaultState()
	self:SavePlayer(player)
	return deepClone(playerStates[player.UserId])
end

return DataService
