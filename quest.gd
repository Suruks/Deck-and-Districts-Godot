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
		"industrial_square":
			score = _calc_industrial_square(grid, grid_size)
		"eco_industry":
			score = _calc_eco_industry(grid, grid_size)
		"eco_homes":
			score = _calc_eco_homes(grid, grid_size)
		"diagonal_city":
			score = _calc_diagonal_city(grid, grid_size)
		"isolated_factories":
			score = _calc_isolated_factories(grid, grid_size)
		"art_neighborhood":
			score = _calc_art_neighborhood(grid, grid_size)
		"natural_balance":
			score = _calc_natural_balance(grid, grid_size)
		"culture_isolation":
			score = _calc_culture_isolation(grid, grid_size)
		"industrial_row":
			score = _calc_industrial_row(grid, grid_size)
		"urban_mass":
			score = _calc_urban_mass(grid, grid_size)
		"natural_lines":
			score = _calc_natural_lines(grid, grid_size)
		"industrial_control":
			score = _calc_industrial_control(grid, grid_size)
		"diverse_block":
			score = _calc_diverse_block(grid, grid_size)
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
				bonus += 1 if near_nature else -1
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
					bonus += 1
				elif has_house and not has_park:
					bonus -= 1
	return bonus


# --- 3. Комфортные окраины ---
func _calc_cozy_suburbs(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "residential" and (x == 0 or y == 0 or x == grid_size - 1 or y == grid_size - 1):
				if not _has_neighbor(grid, x, y, grid_size, "industrial"):
					bonus += 1
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
					bonus += 1
	return bonus


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
			else:
				if count >= 4 and has_nature and has_residential:
					bonus += 1
				count = 0
				has_nature = false
				has_residential = false
		
		# проверка в конце строки
		if count >= 4 and has_nature and has_residential:
			bonus += 1

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
			else:
				if count >= 4 and has_nature and has_residential:
					bonus += 1
				count = 0
				has_nature = false
				has_residential = false
		
		if count >= 4 and has_nature and has_residential:
			bonus += 1

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


# --- 7. Зона промышленности 2x4 (горизонтально и вертикально) ---
func _calc_industrial_square(grid, grid_size):
	var progress := 0

	# Горизонтальные 2x4 (2 строки × 4 столбца)
	for y in range(grid_size - 1):
		for x in range(grid_size - 3):
			var all_industrial := true
			for dy in range(2):
				for dx in range(4):
					if grid[y + dy][x + dx] != "industrial":
						all_industrial = false
			if all_industrial:
				progress += 1

	# Вертикальные 2x4 (4 строки × 2 столбца)
	for y in range(grid_size - 3):
		for x in range(grid_size - 1):
			var all_industrial := true
			for dy in range(4):
				for dx in range(2):
					if grid[y + dy][x + dx] != "industrial":
						all_industrial = false
			if all_industrial:
				progress += 1

	return progress



# --- 8. Экологичная индустрия ---
func _calc_eco_industry(grid, grid_size):
	var industrial_count := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "industrial":
				industrial_count += 1
				if not _has_neighbor(grid, x, y, grid_size, "nature"):
					return 0
	return 5 if industrial_count >= 5 else 0


# --- 10. Эко-жильё ---
func _calc_eco_homes(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "residential":
				var good := true
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						var ntype = grid[ny][nx]
						if ntype != "nature" and ntype != null:
							good = false
							break
				if good:
					bonus += 1
	return bonus


# --- 11. Диагональный город ---
func _calc_diagonal_city(grid, grid_size):
	var progress := 0
	
	# ↘ диагонали
	for y in range(grid_size - 3):
		for x in range(grid_size - 3):
			var res_count := 0
			var ind_count := 0
			var cul_count := 0
			for i in range(4):
				var cell = grid[y + i][x + i]
				if cell == "residential":
					res_count += 1
				elif cell == "industrial":
					ind_count += 1
				elif cell == "culture":
					cul_count += 1
			if res_count == 4:
				progress += 1
			if ind_count == 4:
				progress += 1
			if cul_count == 4:
				progress += 1

	# ↙ диагонали
	for y in range(3, grid_size):
		for x in range(grid_size - 3):
			var res_count := 0
			var ind_count := 0
			var cul_count := 0
			for i in range(4):
				var cell = grid[y - i][x + i]
				if cell == "residential":
					res_count += 1
				elif cell == "industrial":
					ind_count += 1
				elif cell == "culture":
					cul_count += 1
			if res_count == 4:
				progress += 1
			if ind_count == 4:
				progress += 1
			if cul_count == 4:
				progress += 1
	
	return progress



# --- 12. Изолированные заводы ---
func _calc_isolated_factories(grid, grid_size):
	var max_chain := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "industrial" and not _has_neighbor(grid, x, y, grid_size, "residential"):
				var visited := {}
				var chain_len := _dfs_isolated_factory(grid, x, y, grid_size, visited)
				max_chain = max(max_chain, chain_len)
	return min(max_chain, 6)

func _dfs_isolated_factory(grid, x, y, grid_size, visited: Dictionary) -> int:
	var key = str(x) + "," + str(y)
	if x < 0 or y < 0 or x >= grid_size or y >= grid_size:
		return 0
	if grid[y][x] != "industrial" or visited.has(key):
		return 0
	if _has_neighbor(grid, x, y, grid_size, "residential"):
		return 0
	visited[key] = true
	var length := 1
	for dir in [[1,0],[-1,0],[0,1],[0,-1]]:
		length = max(length, 1 + _dfs_isolated_factory(grid, x + dir[0], y + dir[1], grid_size, visited))
	return length


# --- 13. Соседство искусства (обновлено) ---
func _calc_art_neighborhood(grid, grid_size):
	var progress := 0

	# проверяем все возможные квадраты 2x2
	for y in range(grid_size - 1):
		for x in range(grid_size - 1):
			# 2x2 жилых
			var all_residential := true
			for dy in range(2):
				for dx in range(2):
					if grid[y + dy][x + dx] != "residential":
						all_residential = false
			if all_residential:
				progress += 1

			# 2x2 культурных
			var all_culture := true
			for dy in range(2):
				for dx in range(2):
					if grid[y + dy][x + dx] != "culture":
						all_culture = false
			if all_culture:
				progress += 1

	return progress


# --- 14. Природное равновесие ---
func _calc_natural_balance(grid, grid_size):
	var score := 0
	for row in grid:
		for cell in row:
			if cell == "nature":
				score += 1
			elif cell == "industrial":
				score -= 1
	return score


# --- 15. Культурная уединённость ---
func _calc_culture_isolation(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "culture":
				var neighbors := 0
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size and grid[ny][nx] != null:
						neighbors += 1
				if neighbors <= 2:
					bonus += 1
	return bonus


# --- 16. Индустриальный ряд (обновлено) ---
func _calc_industrial_row(grid, grid_size):
	var max_in_row := 0

	# по строкам (фиксируем y)
	for y in range(grid_size):
		var count := 0
		for x in range(grid_size):
			if grid[y][x] == "industrial":
				count += 1
		max_in_row = max(max_in_row, count)

	# по столбцам (фиксируем x)
	for x in range(grid_size):
		var count := 0
		for y in range(grid_size):
			if grid[y][x] == "industrial":
				count += 1
		max_in_row = max(max_in_row, count)

	return max_in_row


# --- 17. Городская масса ---
func _calc_urban_mass(grid, grid_size):
	var visited := {}
	var max_group := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] != null and not visited.has(str(x)+","+str(y)):
				var group_size = _dfs_group(grid, x, y, grid_size, visited, grid[y][x])
				max_group = max(max_group, group_size)
	# Возвращаем размер самой большой группы (очки = число блоков в ней)
	return max_group

func _dfs_group(grid, x, y, grid_size, visited, t):
	var key = str(x)+","+str(y)
	if x < 0 or y < 0 or x >= grid_size or y >= grid_size:
		return 0
	if visited.has(key) or grid[y][x] != t:
		return 0
	visited[key] = true
	var s = 1
	for dir in [[1,0],[-1,0],[0,1],[0,-1]]:
		s += _dfs_group(grid, x+dir[0], y+dir[1], grid_size, visited, t)
	return s


# --- 18. Природные линии (обновлено) ---
func _calc_natural_lines(grid, grid_size):
	var progress := 0

	# строки
	for y in range(grid_size):
		var count := 0
		for x in range(grid_size):
			if grid[y][x] == "nature":
				count += 1
		if count == 4:
			progress += 1

	# столбцы
	for x in range(grid_size):
		var count := 0
		for y in range(grid_size):
			if grid[y][x] == "nature":
				count += 1
		if count == 4:
			progress += 1

	return progress



# --- 19. Промышленный контроль ---
func _calc_industrial_control(grid, grid_size):
	var score := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == "industrial":
				var sides := 0
				for dir in [[1,0],[-1,0],[0,1],[0,-1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size and grid[ny][nx] != null:
						sides += 1
				if sides == 4:
					score += 1
				elif sides < 4:
					score -= 2
	return score


# --- 20. Разнообразный квартал ---
func _calc_diverse_block(grid, grid_size):
	for y in range(grid_size - 3):
		for x in range(grid_size - 3):
			var valid := true
			for dy in range(4):
				for dx in range(4):
					var cell = grid[y + dy][x + dx]
					if cell == null:
						valid = false
						break
					for dir in [[1,0],[-1,0],[0,1],[0,-1]]:
						var nx = x + dx + dir[0]
						var ny = y + dy + dir[1]
						if nx >= x and nx < x + 4 and ny >= y and ny < y + 4:
							if grid[ny][nx] == cell:
								valid = false
								break
				if not valid:
					break
			if valid:
				return 1
	return 0

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
