local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Config = require(ReplicatedStorage.Shared.Config)

local RestaurantService = {}

local dataService = nil
local remotes = {}
local activeCustomers = {}
local kitchenService = nil
local workerService = nil
local upgradeService = nil

local function getRestaurantFolder()
    local folder = Workspace:FindFirstChild("RestaurantRush")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "RestaurantRush"
        folder.Parent = Workspace
    end
    return folder
end

local function getPlayerSpawnPosition()
    local spawn = Workspace:FindFirstChild("RestaurantSpawn")
    if spawn then
        return spawn.Position + Vector3.new(0, 3, 0)
    end
    return Vector3.new(0, 3, 25)
end

local function createSpawnLocation()
    local existing = Workspace:FindFirstChild("RestaurantSpawn")
    if existing then
        return existing
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "RestaurantSpawn"
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.Position = Vector3.new(0, 3, 25)
    spawn.Anchored = true
    spawn.Transparency = 1
    spawn.Neutral = true
    spawn.Parent = Workspace
    return spawn
end

local function buildStarterRestaurant(player, state)
    local restaurantFolder = getRestaurantFolder()
    local restaurantName = player.Name .. "_Restaurant"
    local existing = restaurantFolder:FindFirstChild(restaurantName)
    if existing then
        return existing
    end

    local model = Instance.new("Model")
    model.Name = restaurantName
    model.Parent = restaurantFolder
    model:PivotTo(CFrame.new(0, 0, -30))

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(40, 1, 26)
    base.Position = Vector3.new(0, 0.5, -30)
    base.Anchored = true
    base.Color = Color3.fromRGB(129, 199, 132)
    base.Material = Enum.Material.SmoothPlastic
    base.Parent = model

    local entrance = Instance.new("Part")
    entrance.Name = "Entrance"
    entrance.Size = Vector3.new(8, 6, 1)
    entrance.Position = Vector3.new(-12, 3, -30)
    entrance.Anchored = true
    entrance.Color = Color3.fromRGB(255, 173, 59)
    entrance.Parent = model

    local counter = Instance.new("Part")
    counter.Name = "Counter"
    counter.Size = Vector3.new(12, 2, 4)
    counter.Position = Vector3.new(5, 2, -33)
    counter.Anchored = true
    counter.Color = Color3.fromRGB(255, 213, 79)
    counter.Parent = model

    local register = Instance.new("Part")
    register.Name = "Register"
    register.Size = Vector3.new(2, 2, 2)
    register.Position = Vector3.new(9, 3, -33)
    register.Anchored = true
    register.Color = Color3.fromRGB(255, 255, 255)
    register.Parent = model

    local kitchen = Instance.new("Part")
    kitchen.Name = "Kitchen"
    kitchen.Size = Vector3.new(8, 6, 8)
    kitchen.Position = Vector3.new(12, 3, -22)
    kitchen.Anchored = true
    kitchen.Color = Color3.fromRGB(255, 118, 117)
    kitchen.Parent = model

    local tableCount = math.max(1, state.Tables or Config.StartingTables)
    for index = 1, tableCount do
        local table = Instance.new("Part")
        table.Name = "Table" .. index
        table.Size = Vector3.new(3, 1.5, 3)
        table.Position = Vector3.new(8 + (index * 5), 1.5, -22)
        table.Anchored = true
        table.Color = Color3.fromRGB(112, 128, 144)
        table.Parent = model

        local chair = Instance.new("Part")
        chair.Name = "Chair" .. index
        chair.Size = Vector3.new(1.5, 2, 1.5)
        chair.Position = Vector3.new(8 + (index * 5), 1, -18)
        chair.Anchored = true
        chair.Color = Color3.fromRGB(255, 255, 255)
        chair.Parent = model
    end

    local sign = Instance.new("Part")
    sign.Name = "RestaurantSign"
    sign.Size = Vector3.new(10, 4, 1)
    sign.Position = Vector3.new(0, 7, -40)
    sign.Anchored = true
    sign.Color = Color3.fromRGB(255, 188, 87)
    sign.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = sign
    billboard.Size = UDim2.new(8, 0, 2, 0)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.Parent = sign

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = state.RestaurantName or Config.StartingRestaurantName
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(25, 25, 25)
    label.Parent = billboard

    model.PrimaryPart = base
    return model
end

local function getActiveCustomersForPlayer(player)
    local userId = player.UserId
    if activeCustomers[userId] == nil then
        activeCustomers[userId] = {}
    end
    return activeCustomers[userId]
end

local function getRestaurantModel(player)
    local restaurantFolder = getRestaurantFolder()
    local restaurantName = player.Name .. "_Restaurant"
    return restaurantFolder:FindFirstChild(restaurantName)
end

local function getAvailableTableIndex(player)
    local model = getRestaurantModel(player)
    if not model then
        return nil
    end

    local usedTables = {}
    for _, customer in ipairs(getActiveCustomersForPlayer(player)) do
        if customer.tableIndex then
            usedTables[customer.tableIndex] = true
        end
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("Part") and descendant.Name:match("^Table%d+$") then
            local numberString = descendant.Name:match("(%d+)$")
            if numberString then
                local tableIndex = tonumber(numberString)
                if tableIndex and not usedTables[tableIndex] then
                    return tableIndex
                end
            end
        end
    end

    return nil
end

local function getTablePosition(model, tableIndex)
    local tablePart = model:FindFirstChild("Table" .. tableIndex, true)
    if tablePart then
        return tablePart.Position + Vector3.new(0, 2, 0)
    end
    return Vector3.new(0, 3, 0)
end

local function getEntrancePosition(model)
    if model then
        local entrance = model:FindFirstChild("Entrance", true)
        if entrance then
            return entrance.Position + Vector3.new(0, 2, 0)
        end
    end
    return Vector3.new(-12, 3, -30)
end

local function getExitPosition(model)
    if model then
        local exitPart = model:FindFirstChild("Entrance", true)
        if exitPart then
            return exitPart.Position + Vector3.new(-8, 2, 0)
        end
    end
    return Vector3.new(-22, 3, -30)
end

local function setCustomerText(customer, text)
    if customer.billboard then
        customer.billboard.Text = text
    end
end

local function createCustomerModel(player, orderName, tableIndex)
    local restaurantModel = getRestaurantModel(player)
    if not restaurantModel then
        return nil
    end

    local customerModel = Instance.new("Model")
    customerModel.Name = "Customer_" .. HttpService:GenerateGUID(false)
    customerModel.Parent = restaurantModel

    local root = Instance.new("Part")
    root.Name = "Root"
    root.Size = Vector3.new(2, 3, 1)
    root.Anchored = false
    root.CanCollide = false
    root.Color = Color3.fromRGB(math.random(90, 255), math.random(90, 255), math.random(90, 255))
    root.Material = Enum.Material.SmoothPlastic
    root.Parent = customerModel

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1.5, 1.5, 1.5)
    head.Position = root.Position + Vector3.new(0, 2.5, 0)
    head.Anchored = false
    head.CanCollide = false
    head.Color = Color3.fromRGB(245, 214, 176)
    head.Parent = customerModel

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = head
    weld.Parent = customerModel

    customerModel.PrimaryPart = root

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 2, 0)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Parent = root

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = orderName
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextScaled = true
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Parent = billboard

    return {
        model = customerModel,
        root = root,
        billboard = textLabel,
        tableIndex = tableIndex,
        orderName = orderName,
        patience = math.random(18, 26),
        waited = 0,
        state = "WalkingIn",
        reward = Config.FoodCatalog[orderName] and Config.FoodCatalog[orderName].price or 18,
        tip = math.random(4, 14),
        foodReady = false,
    }
end

local function moveCustomer(customer, destinationPosition, duration, callback)
    if not customer or not customer.root or not customer.root.Parent then
        return
    end

    local tween = TweenService:Create(customer.root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(destinationPosition),
    })

    if callback then
        tween.Completed:Connect(function()
            callback()
        end)
    end

    tween:Play()
end

local function removeCustomer(player, customer)
    if not customer then
        return
    end

    if customer.model and customer.model.Parent then
        customer.model:Destroy()
    end

    local customers = getActiveCustomersForPlayer(player)
    for index, activeCustomer in ipairs(customers) do
        if activeCustomer == customer then
            table.remove(customers, index)
            break
        end
    end
end

local function startCustomerPatienceLoop(player, customer)
    task.spawn(function()
        while customer and customer.model and customer.model.Parent do
            task.wait(1)
            customer.waited += 1

            if customer.foodReady then
                return
            end

            if customer.waited >= customer.patience then
                setCustomerText(customer, "Too slow!")

                local state = dataService:GetPlayerState(player)
                state.Rating = math.max(1, (state.Rating or 4.5) - 0.3)
                dataService:SetPlayerState(player, state)

                if remotes.StateChanged then
                    remotes.StateChanged:FireClient(player, state)
                end

                local exitPosition = getExitPosition(getRestaurantModel(player))
                moveCustomer(customer, exitPosition, 3, function()
                    removeCustomer(player, customer)
                end)
                return
            end
        end
    end)
end

local function handleCustomerPayment(player, customer)
    local state = dataService:GetPlayerState(player)
    local payout = customer.reward + customer.tip
    state.Money = (state.Money or 0) + payout
    state.Rating = math.min(5, (state.Rating or 4.5) + 0.1)
    dataService:SetPlayerState(player, state)

    if remotes.StateChanged then
        remotes.StateChanged:FireClient(player, state)
    end

    setCustomerText(customer, "Thanks! +$" .. payout)

    local exitPosition = getExitPosition(getRestaurantModel(player))
    moveCustomer(customer, exitPosition, 3, function()
        removeCustomer(player, customer)
    end)
end

local function startCustomerFlow(player, customer)
    local restaurantModel = getRestaurantModel(player)
    if not restaurantModel or not customer then
        return
    end

    local tablePosition = getTablePosition(restaurantModel, customer.tableIndex)
    local entrancePosition = getEntrancePosition(restaurantModel)

    customer.root.CFrame = CFrame.new(entrancePosition)
    customer.state = "WalkingIn"

    moveCustomer(customer, tablePosition, 3, function()
        if not customer.model or not customer.model.Parent then
            return
        end

        customer.state = "Waiting"
        setCustomerText(customer, "Waiting for order...")
        startCustomerPatienceLoop(player, customer)

        if kitchenService and kitchenService.QueueOrder then
            kitchenService:QueueOrder(player, customer.orderName, function()
                if customer.model and customer.model.Parent then
                    customer.foodReady = true
                    customer.state = "Eating"
                    setCustomerText(customer, "Enjoying " .. customer.orderName)

                    task.delay(math.random(3, 5), function()
                        if customer.model and customer.model.Parent then
                            handleCustomerPayment(player, customer)
                        end
                    end)
                end
            end)
        else
            task.delay(math.random(5, 9), function()
                if customer.model and customer.model.Parent then
                    customer.foodReady = true
                    customer.state = "Eating"
                    setCustomerText(customer, "Enjoying " .. customer.orderName)

                    task.delay(math.random(3, 5), function()
                        if customer.model and customer.model.Parent then
                            handleCustomerPayment(player, customer)
                        end
                    end)
                end
            end)
        end
    end)
end

local function spawnCustomerForPlayer(player)
    local restaurantModel = getRestaurantModel(player)
    if not restaurantModel then
        return
    end

    local state = dataService:GetPlayerState(player)
    local unlockedFoods = state.UnlockedFoods or { "Burger" }
    local orderOptions = {}

    for _, foodName in ipairs(unlockedFoods) do
        if Config.FoodCatalog[foodName] then
            table.insert(orderOptions, foodName)
        end
    end

    if #orderOptions == 0 then
        table.insert(orderOptions, "Burger")
    end

    local orderName = orderOptions[math.random(1, #orderOptions)]
    local tableIndex = getAvailableTableIndex(player)
    if not tableIndex then
        return
    end

    local customer = createCustomerModel(player, orderName, tableIndex)
    if not customer then
        return
    end

    table.insert(getActiveCustomersForPlayer(player), customer)
    startCustomerFlow(player, customer)
end

local function startSpawnLoop(player)
    task.spawn(function()
        while player.Parent do
            local active = getActiveCustomersForPlayer(player)
            if #active < 3 then
                spawnCustomerForPlayer(player)
            end
            task.wait(math.random(8, 15))
        end
    end)
end

local function syncPlayerState(player)
    if remotes.StateChanged then
        remotes.StateChanged:FireClient(player, dataService:GetPlayerState(player))
    end
end

function RestaurantService:Start(dataServiceRef, remoteTable, kitchenServiceRef, workerServiceRef, upgradeServiceRef)
    dataService = dataServiceRef
    remotes = remoteTable or {}
    kitchenService = kitchenServiceRef
    workerService = workerServiceRef
    upgradeService = upgradeServiceRef

    createSpawnLocation()

    Players.PlayerAdded:Connect(function(player)
        local state = dataService:LoadPlayer(player)
        state.RestaurantName = state.RestaurantName or Config.StartingRestaurantName
        state.Tables = state.Tables or Config.StartingTables
        state.CookingStations = state.CookingStations or Config.StartingCookingStations
        state.Money = math.max(0, state.Money or Config.StartingMoney)
        state.Rating = math.max(1, math.min(5, state.Rating or Config.StartingRating))
        state.UpgradeLevels = state.UpgradeLevels or {}
        state.Workers = state.Workers or { Chef = 0, Waiter = 0, Cleaner = 0, Cashier = 0, Manager = 0 }
        state.WorkerLevels = state.WorkerLevels or { Chef = 1, Waiter = 1, Cleaner = 1, Cashier = 1, Manager = 1 }

        dataService:SetPlayerState(player, state)
        buildStarterRestaurant(player, state)
        syncPlayerState(player)
        startSpawnLoop(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        local customers = getActiveCustomersForPlayer(player)
        for _, customer in ipairs(customers) do
            if customer.model and customer.model.Parent then
                customer.model:Destroy()
            end
        end
        activeCustomers[player.UserId] = nil
        dataService:SavePlayer(player)
    end)

    if remotes.RequestAction then
        remotes.RequestAction.OnServerEvent:Connect(function(player, action, payload)
            local state = dataService:GetPlayerState(player)

            if action == "AddMoney" then
                state.Money = (state.Money or 0) + (payload or 25)
            elseif action == "ClaimDailyReward" then
                local now = os.time()
                local lastLogin = state.LastLogin or 0
                if now - lastLogin > 86400 then
                    state.Money = (state.Money or 0) + Config.DailyReward
                    state.LastLogin = now
                end
            elseif action == "HireWorker" and workerService then
                local workerType = payload
                workerService:HireWorker(player, workerType)
            elseif action == "UpgradeWorker" and workerService then
                local workerType = payload
                workerService:UpgradeWorker(player, workerType)
            elseif action == "UpgradeRestaurant" and upgradeService then
                local upgradeName = payload
                upgradeService:Upgrade(player, upgradeName)
            elseif action == "UpgradeKitchen" then
                state.KitchenLevel = (state.KitchenLevel or 1) + 1
                state.Money = math.max(0, (state.Money or 0) - 150)
            elseif action == "UpgradeDecor" then
                state.DecorLevel = (state.DecorLevel or 1) + 1
                state.Money = math.max(0, (state.Money or 0) - 125)
            elseif action == "SetRestaurantName" then
                state.RestaurantName = tostring(payload or state.RestaurantName or Config.StartingRestaurantName)
                local restaurantModel = getRestaurantModel(player)
                if restaurantModel then
                    local sign = restaurantModel:FindFirstChild("RestaurantSign", true)
                    if sign then
                        local billboard = sign:FindFirstChildOfClass("BillboardGui")
                        if billboard then
                            local label = billboard:FindFirstChildOfClass("TextLabel")
                            if label then
                                label.Text = state.RestaurantName
                            end
                        end
                    end
                end
            end

            state.RestaurantLevel = math.max(1, math.floor(state.Money / 250) + 1)
            dataService:SetPlayerState(player, state)
            syncPlayerState(player)
        end)
    end
end

return RestaurantService
