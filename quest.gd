class_name Quest
extends Resource

@export var description: String = ""
@export var reward_cards: int = 0
@export var current_progress: int = 0
@export var target_progress: int = 1
@export var quest_type: String = "" # например "city_in_green"

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


# --- Вспомогательные функции ---
func _is_type(block, t: String) -> bool:
	return block != null and block is CityBlock and block.type == t

func _has_neighbor(grid, x, y, grid_size, target_type):
	for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
		var nx = x + dir[0]
		var ny = y + dir[1]
		if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
			if _is_type(grid[ny][nx], target_type):
				return true
	return false


# --- 1. Город в зелени ---
func _calc_city_in_green(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "residential"):
				bonus += 1 if _has_neighbor(grid, x, y, grid_size, "nature") else -1
	return bonus


# --- 2. Баланс индустрии ---
func _calc_industrial_balance(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
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
			if _is_type(grid[y][x], "residential") and (x == 0 or y == 0 or x == grid_size-1 or y == grid_size-1):
				if not _has_neighbor(grid, x, y, grid_size, "industrial"):
					bonus += 1
	return bonus


# --- 4. Сердце культуры ---
func _calc_heart_of_culture(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "culture"):
				var neighbor_types := {}
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >=0 and ny >=0 and nx<grid_size and ny<grid_size:
						var nblock = grid[ny][nx]
						if nblock != null and nblock is CityBlock:
							neighbor_types[nblock.type] = true
				if "residential" in neighbor_types and "industrial" in neighbor_types and "nature" in neighbor_types and "culture" in neighbor_types:
					bonus += 1
	return bonus


# --- 5. Пояс жизни (горизонтальные/вертикальные линии) ---
func _calc_life_belt(grid, grid_size):
	var bonus := 0

	# горизонтали
	for y in range(grid_size):
		var count := 0
		var has_nature := false
		var has_residential := false
		for x in range(grid_size):
			var cell = grid[y][x]
			if _is_type(cell, "nature"):
				has_nature = true
				count += 1
			elif _is_type(cell, "residential"):
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

	# вертикали
	for x in range(grid_size):
		var count := 0
		var has_nature := false
		var has_residential := false
		for y in range(grid_size):
			var cell = grid[y][x]
			if _is_type(cell, "nature"):
				has_nature = true
				count += 1
			elif _is_type(cell, "residential"):
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
	var visited := {}
	var chains := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] == null:
				continue
			var key = str(x) + "," + str(y)
			if visited.has(key):
				continue

			var cell_type = grid[y][x].type
			var chain_len = _dfs_chain(grid, x, y, grid_size, visited, cell_type)
			if chain_len >= 4:
				chains += 1

	return chains


func _dfs_chain(grid, x, y, grid_size, visited: Dictionary, cell_type: String) -> int:
	if x < 0 or y < 0 or x >= grid_size or y >= grid_size:
		return 0
	var key = str(x) + "," + str(y)
	if visited.has(key) or grid[y][x] == null:
		return 0
	if not _is_type(grid[y][x], cell_type):
		return 0

	visited[key] = true
	var length := 1

	for dir in [[1,0], [-1,0], [0,1], [0,-1]]:
		length += _dfs_chain(grid, x + dir[0], y + dir[1], grid_size, visited, cell_type)

	return length



# --- 7. Зона промышленности 2x4 (горизонтально и вертикально) ---
func _calc_industrial_square(grid, grid_size):
	var progress := 0

	# Горизонтальные 2x4 (2 строки × 4 столбца)
	for y in range(grid_size - 1):
		for x in range(grid_size - 3):
			var all_industrial := true
			for dy in range(2):
				for dx in range(4):
					if not _is_type(grid[y+dy][x+dx], "industrial"):
						all_industrial = false
			if all_industrial:
				progress += 1

	# Вертикальные 2x4 (4 строки × 2 столбца)
	for y in range(grid_size - 3):
		for x in range(grid_size - 1):
			var all_industrial := true
			for dy in range(4):
				for dx in range(2):
					if not _is_type(grid[y+dy][x+dx], "industrial"):
						all_industrial = false
			if all_industrial:
				progress += 1

	return progress


# --- 8. Экологичная индустрия ---
func _calc_eco_industry(grid, grid_size):
	var industrial_count := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
				industrial_count += 1
				if not _has_neighbor(grid, x, y, grid_size, "nature"):
					return 0
	return 5 if industrial_count >= 5 else 0


# --- 9. Эко-жильё ---
func _calc_eco_homes(grid, grid_size):
	var eco_homes := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "residential"):
				var nature_count := 0
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						var nblock = grid[ny][nx]
						if nblock != null and _is_type(nblock, "nature"):
							nature_count += 1
				
				if nature_count >= 3:
					eco_homes += 1

	return eco_homes



# --- 10. Диагональный город ---
func _calc_diagonal_city(grid, grid_size):
	var lines := 0

	# ↘ диагонали (вниз-вправо)
	for y in range(grid_size - 3):
		for x in range(grid_size - 3):
			var first = grid[y][x]
			if first == null:
				continue
			var type = first.type
			var valid := true
			for i in range(4):
				var cell = grid[y + i][x + i]
				if cell == null or not _is_type(cell, type):
					valid = false
					break
			if valid:
				lines += 1

	# ↙ диагонали (вверх-вправо)
	for y in range(3, grid_size):
		for x in range(grid_size - 3):
			var first = grid[y][x]
			if first == null:
				continue
			var type = first.type
			var valid := true
			for i in range(4):
				var cell = grid[y - i][x + i]
				if cell == null or not _is_type(cell, type):
					valid = false
					break
			if valid:
				lines += 1

	return lines


# --- 11. Изолированные заводы ---
func _calc_isolated_factories(grid, grid_size):
	var visited := {}
	var max_group := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "industrial") and not _has_neighbor(grid, x, y, grid_size, "residential"):
				var key = str(x) + "," + str(y)
				if visited.has(key):
					continue

				var group_size = _dfs_isolated_factory_group(grid, x, y, grid_size, visited)

				if group_size > max_group:
					max_group = group_size

	return min(max_group, 6)  # ограничиваем максимумом 6 (цель задания)
	

func _dfs_isolated_factory_group(grid, x, y, grid_size, visited: Dictionary) -> int:
	if x < 0 or y < 0 or x >= grid_size or y >= grid_size:
		return 0
	var key = str(x) + "," + str(y)
	if visited.has(key):
		return 0
	if not _is_type(grid[y][x], "industrial"):
		return 0
	if _has_neighbor(grid, x, y, grid_size, "residential"):
		return 0

	visited[key] = true
	var count := 1

	for dir in [[1,0], [-1,0], [0,1], [0,-1]]:
		count += _dfs_isolated_factory_group(grid, x + dir[0], y + dir[1], grid_size, visited)

	return count


# --- 12. Соседство искусства ---
func _calc_art_neighborhood(grid, grid_size):
	var progress := 0
	for y in range(grid_size - 1):
		for x in range(grid_size - 1):
			var all_residential := true
			var all_culture := true
			for dy in range(2):
				for dx in range(2):
					if not _is_type(grid[y+dy][x+dx], "residential"):
						all_residential = false
					if not _is_type(grid[y+dy][x+dx], "culture"):
						all_culture = false
			if all_residential or all_culture:
				progress += 1
	return progress


# --- 13. Природное равновесие ---
func _calc_natural_balance(grid, grid_size):
	var score := 0
	for row in grid:
		for cell in row:
			if _is_type(cell, "nature"):
				score += 1
			elif _is_type(cell, "industrial"):
				score -= 1
	return score


# --- 14. Культурная уединённость ---
func _calc_culture_isolation(grid, grid_size):
	var bonus := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "culture"):
				var neighbors := 0
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						if grid[ny][nx] != null:
							neighbors += 1
				if neighbors <= 2:
					bonus += 1
	return bonus


# --- 15. Индустриальный ряд ---
func _calc_industrial_row(grid, grid_size):
	var max_in_row := 0
	for y in range(grid_size):
		var count := 0
		for x in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
				count += 1
		max_in_row = max(max_in_row, count)
	for x in range(grid_size):
		var count := 0
		for y in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
				count += 1
		max_in_row = max(max_in_row, count)
	return max_in_row


# --- 16. Городская масса ---
func _calc_urban_mass(grid, grid_size):
	var visited := {}
	var max_group := 0
	for y in range(grid_size):
		for x in range(grid_size):
			var cell = grid[y][x]
			if cell != null and not visited.has(str(x)+","+str(y)):
				var group_size = _dfs_group(grid, x, y, grid_size, visited, cell.type)
				max_group = max(max_group, group_size)
	return max_group

func _dfs_group(grid, x, y, grid_size, visited, t):
	var key = str(x)+","+str(y)
	if x<0 or y<0 or x>=grid_size or y>=grid_size:
		return 0
	if visited.has(key) or not _is_type(grid[y][x], t):
		return 0
	visited[key] = true
	var s := 1
	for dir in [[1,0],[-1,0],[0,1],[0,-1]]:
		s += _dfs_group(grid, x+dir[0], y+dir[1], grid_size, visited, t)
	return s


# --- 17. Природные линии ---
func _calc_natural_lines(grid, grid_size):
	var progress := 0
	for y in range(grid_size):
		var count := 0
		for x in range(grid_size):
			if _is_type(grid[y][x], "nature"):
				count += 1
		if count == 4:
			progress += 1
	for x in range(grid_size):
		var count := 0
		for y in range(grid_size):
			if _is_type(grid[y][x], "nature"):
				count += 1
		if count == 4:
			progress += 1
	return progress


# --- 18. Промышленный контроль ---
func _calc_industrial_control(grid, grid_size):
	var score := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
				var neighbor_count := 0

				for dir in [[1,0], [-1,0], [0,1], [0,-1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						var ncell = grid[ny][nx]
						if ncell != null:
							neighbor_count += 1

				if neighbor_count == 4:
					score += 1
				elif neighbor_count < 3:
					score -= 2
				# если соседей 3 — нейтрально (0)

	return score



func _calc_diverse_block(grid, grid_size):
	var max_diversity := 0
	
	for y in range(grid_size - 2):
		for x in range(grid_size - 2):
			var types := {}
			var valid := true
			
			for dy in range(3):
				for dx in range(3):
					var cell = grid[y + dy][x + dx]
					if cell == null:
						valid = false
						break
					types[cell.type] = true
				if not valid:
					break
			
			if valid:
				var diversity = types.keys().size()
				if diversity > max_diversity:
					max_diversity = diversity
	
	return max_diversity
