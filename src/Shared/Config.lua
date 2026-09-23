local Config = {
	StartingMoney = 200,
	StartingRestaurantName = "Sunny Bite",
	StartingTables = 3,
	StartingCookingStations = 1,
	StartingRating = 4.0,
	RestaurantLevelCap = 25,
	DailyReward = 100,
	FoodCatalog = {
		Burger = {
			price = 15,
			unlockLevel = 1,
			cookTime = 4,
			xp = 5,
		},
		Pizza = {
			price = 24,
			unlockLevel = 2,
			cookTime = 6,
			xp = 8,
		},
		HotDog = {
			price = 18,
			unlockLevel = 2,
			cookTime = 5,
			xp = 7,
		},
		Chicken = {
			price = 28,
			unlockLevel = 3,
			cookTime = 7,
			xp = 10,
		},
		Pasta = {
			price = 35,
			unlockLevel = 4,
			cookTime = 8,
			xp = 12,
		},
		Sushi = {
			price = 42,
			unlockLevel = 5,
			cookTime = 9,
			xp = 14,
		},
		Tacos = {
			price = 40,
			unlockLevel = 5,
			cookTime = 8,
			xp = 13,
		},
	},
	WorkerCatalog = {
		Chef = {
			baseCost = 150,
			maxLevel = 10,
			bonus = 0.15,
		},
		Waiter = {
			baseCost = 180,
			maxLevel = 10,
			bonus = 0.2,
		},
		Cleaner = {
			baseCost = 130,
			maxLevel = 10,
			bonus = 0.12,
		},
		Cashier = {
			baseCost = 220,
			maxLevel = 10,
			bonus = 0.18,
		},
		Manager = {
			baseCost = 300,
			maxLevel = 10,
			bonus = 0.25,
		},
	},
	UpgradeCatalog = {
		Kitchen = {
			baseCost = 120,
			maxLevel = 10,
		},
		Tables = {
			baseCost = 150,
			maxLevel = 20,
		},
		Decor = {
			baseCost = 100,
			maxLevel = 12,
		},
		Lighting = {
			baseCost = 110,
			maxLevel = 12,
		},
		Entrance = {
			baseCost = 140,
			maxLevel = 8,
		},
	},
	WorldCatalog = {
		["Fast Food"] = {
			unlockCost = 0,
			foods = { "Burger", "Pizza", "HotDog" },
		},
		["Italian"] = {
			unlockCost = 800,
			foods = { "Pizza", "Pasta" },
		},
		["Sushi Bar"] = {
			unlockCost = 1800,
			foods = { "Sushi", "Chicken" },
		},
	},
	DefaultState = {
		Money = 200,
		RestaurantLevel = 1,
		RestaurantName = "Sunny Bite",
		Rating = 4.0,
		Tables = 3,
		CookingStations = 1,
		UnlockedFoods = { "Burger" },
		UnlockedLocations = { "Fast Food" },
		Workers = {
			Chef = 0,
			Waiter = 0,
			Cleaner = 0,
			Cashier = 0,
			Manager = 0,
		},
		WorkerLevels = {
			Chef = 1,
			Waiter = 1,
			Cleaner = 1,
			Cashier = 1,
			Manager = 1,
		},
		DailyRewardClaim = 0,
		LastLogin = 0,
		DecorLevel = 1,
		KitchenLevel = 1,
		LightingLevel = 1,
		EntranceLevel = 1,
		LastSavedAt = 0,
	}
}

return Config
