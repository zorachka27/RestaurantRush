local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)

local WorkerService = {}

local dataService = nil
local remotes = {}

local function getWorkerLevel(player, workerType)
    local state = dataService:GetPlayerState(player)
    local workerLevels = state.WorkerLevels or {}
    return workerLevels[workerType] or 1
end

function WorkerService:GetHireCost(player, workerType)
    local info = Config.WorkerCatalog[workerType]
    if not info then
        return 0
    end

    local level = getWorkerLevel(player, workerType)
    return math.floor((info.baseCost or 100) * (1 + ((level - 1) * 0.65)))
end

function WorkerService:GetUpgradeCost(player, workerType)
    local info = Config.WorkerCatalog[workerType]
    if not info then
        return 0
    end

    local level = getWorkerLevel(player, workerType)
    if level >= (info.maxLevel or 10) then
        return 0
    end

    return math.floor((info.baseCost or 100) * (1 + (level * 0.8)))
end

function WorkerService:HireWorker(player, workerType)
    if not player or not workerType then
        return false, "Missing player or worker type"
    end

    if not Config.WorkerCatalog[workerType] then
        return false, "Worker type not found"
    end

    local state = dataService:GetPlayerState(player)
    local cost = self:GetHireCost(player, workerType)

    if state.Money < cost then
        return false, "Not enough money"
    end

    state.Money -= cost
    state.Workers[workerType] = (state.Workers[workerType] or 0) + 1
    dataService:SetPlayerState(player, state)

    if remotes.StateChanged then
        remotes.StateChanged:FireClient(player, state)
    end

    return true, state
end

function WorkerService:UpgradeWorker(player, workerType)
    if not player or not workerType then
        return false, "Missing player or worker type"
    end

    local info = Config.WorkerCatalog[workerType]
    if not info then
        return false, "Worker type not found"
    end

    local state = dataService:GetPlayerState(player)
    local currentLevel = state.WorkerLevels[workerType] or 1

    if currentLevel >= (info.maxLevel or 10) then
        return false, "Worker already at max level"
    end

    local cost = self:GetUpgradeCost(player, workerType)
    if state.Money < cost then
        return false, "Not enough money"
    end

    state.Money -= cost
    state.WorkerLevels[workerType] = currentLevel + 1
    dataService:SetPlayerState(player, state)

    if remotes.StateChanged then
        remotes.StateChanged:FireClient(player, state)
    end

    return true, state
end

function WorkerService:ProcessPassiveIncome()
    task.spawn(function()
        while true do
            task.wait(5)

            for _, player in ipairs(Players:GetPlayers()) do
                local state = dataService:GetPlayerState(player)
                local totalIncome = 0

                for workerType, count in pairs(state.Workers or {}) do
                    local info = Config.WorkerCatalog[workerType]
                    local level = state.WorkerLevels[workerType] or 1

                    if type(count) == "number" and count > 0 and info then
                        totalIncome += count * (info.baseCost / 90) * (1 + (level - 1) * 0.35)
                    end
                end

                if totalIncome > 0 then
                    state.Money = (state.Money or 0) + math.floor(totalIncome)
                    dataService:SetPlayerState(player, state)

                    if remotes.StateChanged then
                        remotes.StateChanged:FireClient(player, state)
                    end
                end
            end
        end
    end)
end

function WorkerService:Start(dataServiceRef, remoteTable)
    dataService = dataServiceRef
    remotes = remoteTable or {}
    self:ProcessPassiveIncome()
end

return WorkerService
