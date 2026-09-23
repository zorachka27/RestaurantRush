local Config = require(game.ReplicatedStorage.Shared.Config)

local KitchenService = {}

local playerQueues = {}
local kitchenState = {}

local function getQueue(player)
    local userId = player.UserId
    if not playerQueues[userId] then
        playerQueues[userId] = {}
    end
    return playerQueues[userId]
end

local function getKitchenState(player)
    local userId = player.UserId
    if not kitchenState[userId] then
        kitchenState[userId] = {
            active = false,
            processing = nil,
        }
    end
    return kitchenState[userId]
end

local function runNextOrder(player)
    local queue = getQueue(player)
    local state = getKitchenState(player)

    if state.active or #queue == 0 then
        return
    end

    local job = table.remove(queue, 1)
    if not job then
        return
    end

    state.active = true
    state.processing = job

    local foodInfo = Config.FoodCatalog[job.orderName] or { cookTime = 4 }
    local cookTime = foodInfo.cookTime or 4

    task.delay(cookTime, function()
        state.active = false
        state.processing = nil

        if job.callback then
            job.callback(job)
        end

        runNextOrder(player)
    end)
end

function KitchenService:QueueOrder(player, orderName, callback)
    if not player or not orderName then
        return
    end

    local queue = getQueue(player)
    table.insert(queue, {
        orderName = orderName,
        callback = callback,
    })

    runNextOrder(player)
end

function KitchenService:GetQueue(player)
    return getQueue(player)
end

function KitchenService:Start(dataServiceRef, remoteTable)
    _ = dataServiceRef
    _ = remoteTable
end

return KitchenService
