local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local WorkerService = {}

local dataService
local remotes

local function getState(player)
    return dataService:GetPlayerState(player)
end

local function getLevel(player, workerType)
    local state = getState(player)
    state.WorkerLevels = state.WorkerLevels or {}
    return state.WorkerLevels[workerType] or 1
end

function WorkerService:HasWorker(player, workerType)
    local state = getState(player)
    return (state.Workers and state.Workers[workerType] or 0) > 0
end

function WorkerService:GetHireCost(player, workerType)
    local info = Config.WorkerCatalog[workerType]
    if not info then return 0 end
    return math.floor((info.baseCost or 100) * (1 + ((getLevel(player, workerType) - 1) * 0.65)))
end

function WorkerService:GetUpgradeCost(player, workerType)
    local info = Config.WorkerCatalog[workerType]
    if not info then return 0 end
    local level = getLevel(player, workerType)
    if level >= (info.maxLevel or 10) then return 0 end
    return math.floor((info.baseCost or 100) * (1 + (level * 0.8)))
end

function WorkerService:HireWorker(player, workerType)
    local info = Config.WorkerCatalog[workerType]
    if not info then return false, "Worker type not found" end

    local state = getState(player)
    local cost = self:GetHireCost(player, workerType)
    if (state.Money or 0) < cost then return false, "Not enough money" end

    state.Money -= cost
    state.Workers = state.Workers or {}
    state.Workers[workerType] = (state.Workers[workerType] or 0) + 1
    dataService:SetPlayerState(player, state)
    remotes.StateChanged:FireClient(player, state)
    return true, state
end

function WorkerService:UpgradeWorker(player, workerType)
    local info = Config.WorkerCatalog[workerType]
    if not info then return false, "Worker type not found" end

    local state = getState(player)
    state.WorkerLevels = state.WorkerLevels or {}
    local level = state.WorkerLevels[workerType] or 1
    if level >= (info.maxLevel or 10) then return false, "Worker already at max level" end

    local cost = self:GetUpgradeCost(player, workerType)
    if (state.Money or 0) < cost then return false, "Not enough money" end

    state.Money -= cost
    state.WorkerLevels[workerType] = level + 1
    dataService:SetPlayerState(player, state)
    remotes.StateChanged:FireClient(player, state)
    return true, state
end

function WorkerService:ProcessPassiveIncome()
    task.spawn(function()
        while true do
            task.wait(5)
            for _, player in ipairs(Players:GetPlayers()) do
                local state = getState(player)
                local income = 0
                for workerType, count in pairs(state.Workers or {}) do
                    local info = Config.WorkerCatalog[workerType]
                    local level = (state.WorkerLevels and state.WorkerLevels[workerType]) or 1
                    if info and type(count) == "number" and count > 0 then
                        income += count * (info.baseCost / 90) * (1 + ((level - 1) * 0.35))
                    end
                end
                if income > 0 then
                    state.Money = (state.Money or 0) + math.floor(income)
                    dataService:SetPlayerState(player, state)
                    remotes.StateChanged:FireClient(player, state)
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
