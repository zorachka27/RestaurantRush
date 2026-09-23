local Config = require(game.ReplicatedStorage.Shared.Config)

local UpgradeService = {}

local dataService = nil
local remotes = {}

local function getUpgradeLevel(player, upgradeName)
    local state = dataService:GetPlayerState(player)
    local upgradeLevels = state.UpgradeLevels or {}
    return upgradeLevels[upgradeName] or 1
end

function UpgradeService:GetUpgradeCost(player, upgradeName)
    local data = Config.UpgradeCatalog[upgradeName]
    if not data then
        return 0
    end

    local level = getUpgradeLevel(player, upgradeName)
    if level >= (data.maxLevel or 10) then
        return 0
    end

    return math.floor((data.baseCost or 100) * (1 + (level * 0.8)))
end

function UpgradeService:Upgrade(player, upgradeName)
    if not player or not upgradeName then
        return false, "Missing player or upgrade name"
    end

    local configData = Config.UpgradeCatalog[upgradeName]
    if not configData then
        return false, "Upgrade not found"
    end

    local state = dataService:GetPlayerState(player)
    local level = state.UpgradeLevels and state.UpgradeLevels[upgradeName] or 1
    local maxLevel = configData.maxLevel or 10

    if level >= maxLevel then
        return false, "Upgrade already at max level"
    end

    local cost = self:GetUpgradeCost(player, upgradeName)
    if state.Money < cost then
        return false, "Not enough money"
    end

    state.Money -= cost
    state.UpgradeLevels = state.UpgradeLevels or {}
    state.UpgradeLevels[upgradeName] = level + 1

    if upgradeName == "Tables" then
        state.Tables = (state.Tables or Config.StartingTables) + 1
    elseif upgradeName == "Kitchen" then
        state.KitchenLevel = (state.KitchenLevel or 1) + 1
    elseif upgradeName == "Decor" then
        state.DecorLevel = (state.DecorLevel or 1) + 1
    elseif upgradeName == "Lighting" then
        state.LightingLevel = (state.LightingLevel or 1) + 1
    elseif upgradeName == "Entrance" then
        state.EntranceLevel = (state.EntranceLevel or 1) + 1
    end

    dataService:SetPlayerState(player, state)

    if remotes.StateChanged then
        remotes.StateChanged:FireClient(player, state)
    end

    return true, state
end

function UpgradeService:Start(dataServiceRef, remoteTable)
    dataService = dataServiceRef
    remotes = remoteTable or {}
end

return UpgradeService
