class_name Quest
extends Resource

@export var description: String = ""
@export var reward_cards: int = 0
@export var current_progress: int = 0
@export var target_progress: int = 1
@export var quest_type: String = "" # имя или тип квеста (например "city_in_green")

func is_completed() -> bool:
	return current_progress >= target_progress

func calculate_score(grid: Array, grid_size: int) -> int:
	var score := 0
	match quest_type:
		"city_in_green":
			score = _calc_city_in_green(grid, grid_size)
		"industrial_balance":
			score = _calc_industrial_balance(grid, grid_size)
		"cozy_suburbs":
			score = _calc_cozy_suburbs(grid, grid_size)
		"heart_of_culture":
			score = _calc_heart_of_culture(grid, grid_size)
		"life_belt":
			score = _calc_life_belt(grid, grid_size)
		"soul_of_city":
			score = _calc_soul_of_city(grid, grid_size)
		_:
			score = 0

	current_progress = score
	return score
	
# --- 1. Город в зелени ---
func _calc_city_in_green(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			var block = grid[y][x]
			if block == "residential":
				var near_nature = _has_neighbor(grid, x, y, grid_size, "nature")
				bonus += 2 if near_nature else -2
	return bonus


# --- 2. Баланс индустрии ---
func _calc_industrial_balance(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "industrial":
				var has_house = _has_neighbor(grid, x, y, grid_size, "residential")
				var has_park = _has_neighbor(grid, x, y, grid_size, "nature")
				if has_house and has_park:
					bonus += 2
				elif has_house and not has_park:
					bonus -= 2
	return bonus


# --- 3. Комфортные окраины ---
func _calc_cozy_suburbs(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "residential" and (x == 0 or y == 0 or x == grid_size - 1 or y == grid_size - 1):
				if not _has_neighbor(grid, x, y, grid_size, "industrial"):
					bonus += 2
	return bonus


# --- 4. Сердце культуры ---
func _calc_heart_of_culture(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "culture":
				var neighbor_types := {}
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						var ntype = grid[ny][nx]
						if ntype != null:
							neighbor_types[ntype] = true
				if "residential" in neighbor_types and "industrial" in neighbor_types and "nature" in neighbor_types and "culture" in neighbor_types:
					bonus += 3
	return bonus


# --- 5. Пояс жизни ---
func _calc_life_belt(grid, grid_size):
	var bonus := 0

	# Горизонтальные линии
	for y in range(grid_size):
		var count := 0
		var has_nature := false
		var has_residential := false
		for x in range(grid_size):
			var cell = grid[y][x]
			if cell == "nature":
				has_nature = true
				count += 1
			elif cell == "residential":
				has_residential = true
				count += 1
			elif cell == null:
				# сброс линии
				if count >= 4 and has_nature and has_residential:
					bonus += 4
				count = 0
				has_nature = false
				has_residential = false
			else:
				# другой тип блока
				count += 1
		# проверка в конце строки
		if count >= 4 and has_nature and has_residential:
			bonus += 4

	# Вертикальные линии
	for x in range(grid_size):
		var count := 0
		var has_nature := false
		var has_residential := false
		for y in range(grid_size):
			var cell = grid[y][x]
			if cell == "nature":
				has_nature = true
				count += 1
			elif cell == "residential":
				has_residential = true
				count += 1
			elif cell == null:
				if count >= 4 and has_nature and has_residential:
					bonus += 4
				count = 0
				has_nature = false
				has_residential = false
			else:
				count += 1
		if count >= 4 and has_nature and has_residential:
			bonus += 4

	return bonus


# --- 6. Душа города ---
func _calc_soul_of_city(grid, grid_size):
	var max_chain := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "culture":
				var visited := {}
				var chain_len := _dfs_culture(grid, x, y, grid_size, visited)
				if chain_len > max_chain:
					max_chain = chain_len
	return min(max_chain, 8)


func _dfs_culture(grid, x, y, grid_size, visited: Dictionary) -> int:
	var key = str(x) + "," + str(y)
	if x < 0 or y < 0 or x >= grid_size or y >= grid_size:
		return 0
	if grid[y][x] != "culture" or visited.has(key):
		return 0
	visited[key] = true
	var max_len := 1
	for dir in [[0,-1],[1,0],[0,1],[-1,0]]:
		max_len = max(max_len, 1 + _dfs_culture(grid, x + dir[0], y + dir[1], grid_size, visited))
	return max_len


# --- Вспомогательная функция ---
func _has_neighbor(grid, x, y, grid_size, target_type):
	for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
		var nx = x + dir[0]
		var ny = y + dir[1]
		if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size and grid[ny][nx] == target_type:
			return true
	return false
