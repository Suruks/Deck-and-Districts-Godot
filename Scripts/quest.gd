class_name Quest
extends Resource

@export var short_desc: String = ""
@export var description: String = ""
@export var reward_cards: int = 0
@export var current_progress: int = 0
@export var target_progress: int = 1
@export var quest_type: String = "" # например "city_in_green"

@export var difficulty_levels: Dictionary = {}
var current_difficulty: String

var start_turn: int = 0

# --- Вспомогательные функции для получения параметров ---
func _get_current_param(param_name: String, default_value) -> int:
	if difficulty_levels.has(current_difficulty):
		var params = difficulty_levels[current_difficulty]
		# Если параметр задан для текущей сложности, используем его
		if params.has(param_name):
			return params[param_name]
			
	# Иначе возвращаем значение по умолчанию (например, то, что вписано в QuestDeck)
	# или прямое свойство Resource.
	return default_value

func get_target_progress() -> int:
	return _get_current_param("target_progress", target_progress)

func get_reward_cards() -> int:
	return _get_current_param("reward_cards", reward_cards)

func is_completed() -> bool:
	return current_progress >= get_target_progress()
	
func calculate_score(grid: Array, grid_size: int) -> int:
	var score := 0
	match quest_type:
		"city_in_green":
			score = _calc_city_in_green(grid, grid_size)
		"industrial_balance":
			score = _calc_industrial_balance(grid, grid_size)
		"heart_of_culture":
			score = _calc_heart_of_culture(grid, grid_size)
		"life_belt":
			score = _calc_life_belt(grid, grid_size)
		"eco_industry":
			score = _calc_eco_industry(grid, grid_size)
		"eco_homes":
			score = _calc_eco_homes(grid, grid_size)
		"diagonal_city":
			score = _calc_diagonal_city(grid, grid_size)
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
		"diverse_neighbors":
			score = _calc_diverse_neighbors(grid, grid_size)
		"neighboring_nature":
			score = _calc_neighboring_nature(grid, grid_size) # q23
		"residential_isolation":
			score = _calc_residential_isolation(grid, grid_size) # q24
		"edge_residential_pair":
			score = _calc_edge_residential_pair(grid, grid_size) # q25
		"nature_mix":
			score = _calc_nature_mix(grid, grid_size) # q26
		"type_difference":
			score = _calc_type_difference(grid, grid_size) # q27
		"culture_neighboring_nature":
			score = _calc_culture_neighboring_nature(grid, grid_size) # q28
		"culture_neighboring_residential":
			score = _calc_culture_neighboring_residential(grid, grid_size) # q29
		"mixed_rows":
			score = _calc_mixed_rows(grid, grid_size) # q31
		"unique_squares":
			score = _calc_unique_squares(grid, grid_size) # q32
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
	var progress := 0
	
	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
				var has_industrial = _has_neighbor(grid, x, y, grid_size, "industrial")
				var has_culture = _has_neighbor(grid, x, y, grid_size, "culture")
				
				if has_industrial and has_culture:
					progress += 1
				elif not has_industrial and not has_culture:
					progress -= 2
	
	return progress


# --- 4. Сердце культуры ---
func _calc_heart_of_culture(grid, grid_size):
	var bonus := 0
	
	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "culture"):
				var neighbor_types := {}
				
				for dir in [[-1, 0], [1, 0], [0, -1], [0, 1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						var nblock = grid[ny][nx]
						if nblock != null and nblock is CityBlock:
							neighbor_types[nblock.type] = true
				
				# Если есть хотя бы три разных типа соседей — бонус
				if neighbor_types.keys().size() >= 3:
					bonus += 1
	
	return bonus



# --- 5. Пояс жизни (горизонтальные/вертикальные линии) ---
func _calc_life_belt(grid: Array, grid_size: int) -> int:
	var count_lines = func(horizontal: bool) -> int:
		var b := 0
		for i in range(grid_size):
			var count := 0
			var has_nature := false
			var has_residential := false
			var already_counted := false
			for j in range(grid_size):
				var cell = grid[i][j] if horizontal else grid[j][i]
				if _is_type(cell, "nature"):
					has_nature = true
					count += 1
				elif _is_type(cell, "residential"):
					has_residential = true
					count += 1
				else:
					if count >= 4 and has_nature and has_residential and not already_counted:
						b += 1
					count = 0
					has_nature = false
					has_residential = false
					already_counted = false
					continue

				if count >= 4 and has_nature and has_residential and not already_counted:
					b += 1
					already_counted = true
		return b

	var bonus: int = count_lines.call(true) + count_lines.call(false)
	return bonus


# --- 8. Экологичная индустрия ---
func _calc_eco_industry(grid, grid_size):
	var industrial_count := 0
	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
				industrial_count += 1
				if not _has_neighbor(grid, x, y, grid_size, "industrial"):
					return 0
	return industrial_count


# --- 9. Эко-жильё ---
func _calc_eco_homes(grid, grid_size):
	# Получаем динамический параметр для логики
	var required_neighbors: int = _get_current_param("min_nature_neighbors", 3) # 3 - значение по умолчанию
	
	var eco_homes := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "residential"):
				var nature_count := 0
				# ... (логика подсчета соседей остается прежней) ... 
				
				# Динамическая проверка условия
				if nature_count >= required_neighbors:
					eco_homes += 1

	return eco_homes



func _calc_diagonal_city(grid, grid_size):
	var lines := 0

	# ↘ диагонали (вниз-вправо)
	for y in range(grid_size - 2):
		for x in range(grid_size - 2):
			var first = grid[y][x]
			if first == null:
				continue
			var type = first.type

			var length := 0
			while y + length < grid_size and x + length < grid_size:
				var cell = grid[y + length][x + length]
				if cell == null or cell.type != type:
					break
				length += 1

			if length >= 3:
				lines += 1
				# пропускаем оставшуюся часть этой линии
				x += length - 1
				y += length - 1

	# ↙ диагонали (вверх-вправо)
	for y in range(2, grid_size):
		for x in range(grid_size - 2):
			var first = grid[y][x]
			if first == null:
				continue
			var type = first.type

			var length := 0
			while y - length >= 0 and x + length < grid_size:
				var cell = grid[y - length][x + length]
				if cell == null or cell.type != type:
					break
				length += 1

			if length >= 3:
				lines += 1
				x += length - 1
				y -= length - 1

	return lines



# --- 12. Соседство искусства ---
func _calc_art_neighborhood(grid, grid_size):
	var visited := {} # Dictionary для хранения посещённых клеток
	var count := 0

	for y in range(grid_size):
		for x in range(grid_size):
			var cell = grid[y][x]
			if cell != null and not visited.has(str(x)+","+str(y)):
				var group_size = _dfs_group(grid, x, y, grid_size, cell.type, visited)
				if group_size >= 3:
					count += 1

	return count


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
			if _is_type(grid[y][x], "nature"):
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
	var count_rows := 0
	
	# Горизонтальные ряды
	for y in range(grid_size):
		var industrial_in_row := 0
		for x in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
				industrial_in_row += 1
		if industrial_in_row >= 4:
			count_rows += 1
	
	# Вертикальные ряды
	for x in range(grid_size):
		var industrial_in_col := 0
		for y in range(grid_size):
			if _is_type(grid[y][x], "industrial"):
				industrial_in_col += 1
		if industrial_in_col >= 4:
			count_rows += 1
	
	return count_rows



# --- 16. Городская масса ---
func _calc_urban_mass(grid, grid_size):
	var visited := {} # Dictionary для хранения посещённых клеток
	var count := 0

	for y in range(grid_size):
		for x in range(grid_size):
			var cell = grid[y][x]
			if cell != null and not visited.has(str(x)+","+str(y)):
				var group_size = _dfs_group(grid, x, y, grid_size, cell.type, visited)
				if group_size >= 5:
					count += 1

	return count


func _dfs_group(grid, x, y, grid_size, t, visited):
	if x < 0 or y < 0 or x >= grid_size or y >= grid_size:
		return 0

	var key = str(t) + ":" + str(x) + "," + str(y)
	if visited.has(key):
		return 0

	var cell = grid[y][x]
	if cell == null or cell.type != t:
		return 0

	visited[key] = true
	var s := 1

	for dir in [[1,0],[-1,0],[0,1],[0,-1]]:
		s += _dfs_group(grid, x + dir[0], y + dir[1], grid_size, t, visited)

	return s


# --- 17. Природные линии ---
func _calc_natural_lines(grid, grid_size):
	var progress := 0
	for y in range(grid_size):
		var count := 0
		for x in range(grid_size):
			if _is_type(grid[y][x], "nature"):
				count += 1
		if count == 3:
			progress += 1
	for x in range(grid_size):
		var count := 0
		for y in range(grid_size):
			if _is_type(grid[y][x], "nature"):
				count += 1
		if count == 3:
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


# --- 19. Город-хамелеон ---
func _calc_diverse_neighbors(grid, grid_size):
	var progress := 0

	for y in range(grid_size):
		for x in range(grid_size):
			var block = grid[y][x]
			if block == null:
				continue

			var neighbors: Array = []

			if y > 0:
				var top = grid[y - 1][x]
				if top != null:
					neighbors.append(top.type)
			if y < grid_size - 1:
				var bottom = grid[y + 1][x]
				if bottom != null:
					neighbors.append(bottom.type)
			if x > 0:
				var left = grid[y][x - 1]
				if left != null:
					neighbors.append(left.type)
			if x < grid_size - 1:
				var right = grid[y][x + 1]
				if right != null:
					neighbors.append(right.type)

			# Убираем дубликаты вручную
			var unique_types: Array = []
			for t in neighbors:
				if not unique_types.has(t):
					unique_types.append(t)

			# Проверяем, что все 4 соседа существуют и разных типов
			if neighbors.size() == 4 and unique_types.size() == 4:
				progress += 1

	return progress


func _calc_diverse_block(grid, grid_size):
	for y in range(grid_size - 2):
		for x in range(grid_size - 2):
			var valid := true

			for dy in range(3):
				for dx in range(3):
					var cell = grid[y + dy][x + dx]
					if cell == null:
						valid = false
						break
					var t = cell.type

					# проверяем только правого и нижнего соседа
					var right = Vector2(dx + 1, dy)
					var down = Vector2(dx, dy + 1)

					if right.x < 3:
						var neighbor = grid[y + right.y][x + right.x]
						if neighbor != null and neighbor.type == t:
							valid = false
							break
					if down.y < 3:
						var neighbor = grid[y + down.y][x + down.x]
						if neighbor != null and neighbor.type == t:
							valid = false
							break

				if not valid:
					break

			if valid:
				return 1

	return 0


func _calc_neighboring_nature(grid, grid_size):
	var count := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "residential"):
				var nature_neighbors := 0
				
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						if _is_type(grid[ny][nx], "nature"):
							nature_neighbors += 1
							
				if nature_neighbors >= 2:
					count += 1
					
	return count
	
func _calc_residential_isolation(grid, grid_size):
	var isolated_residences := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "residential"):
				var is_isolated := true
				
				# Проверка в радиусе 2-х клеток (включая саму клетку, но она не industrial)
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var nx = x + dx
						var ny = y + dy
						
						if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
							# Исключаем текущую ячейку
							if dx == 0 and dy == 0:
								continue
								
							if _is_type(grid[ny][nx], "industrial"):
								is_isolated = false
								break
					if not is_isolated:
						break
						
				if is_isolated:
					isolated_residences += 1
					
	return isolated_residences
	
func _calc_edge_residential_pair(grid, grid_size):
	var count := 0

	for y in range(grid_size):
		for x in range(grid_size):	
			if _is_type(grid[y][x], "residential"):
				var has_res_neighbor := false
				
				# Проверка на наличие соседнего жилого района
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						if _is_type(grid[ny][nx], "residential"):
							has_res_neighbor = true
							break
							
				if has_res_neighbor:
					count += 1
					
	return count
	
func _calc_nature_mix(grid, grid_size):
	var count := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "culture"):
				var has_residential := false
				var has_industrial := false
				
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						if _is_type(grid[ny][nx], "residential"):
							has_residential = true
						elif _is_type(grid[ny][nx], "industrial"):
							has_industrial = true
							
				if has_residential and has_industrial:
					count += 1
					
	return count
	
func _calc_type_difference(grid, grid_size):
	var residential_count := 0
	var industrial_count := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "residential"):
				residential_count += 1
			elif _is_type(grid[y][x], "industrial"):
				industrial_count += 1
				
	#print("residential_count = ", residential_count, ", industrial_count = ", industrial_count)
	var difference = abs(industrial_count - residential_count)
	
	# Прогресс = достигнутая разница
	return difference
	
func _calc_culture_neighboring_nature(grid, grid_size):
	var count := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "culture"):
				var nature_neighbors := 0
				
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						if _is_type(grid[ny][nx], "nature"):
							nature_neighbors += 1
							
				if nature_neighbors >= 2:
					count += 1
					
	return count
	
func _calc_culture_neighboring_residential(grid, grid_size):
	var count := 0

	for y in range(grid_size):
		for x in range(grid_size):
			if _is_type(grid[y][x], "culture"):
				var residential_neighbors := 0
				
				for dir in [[-1,0],[1,0],[0,-1],[0,1]]:
					var nx = x + dir[0]
					var ny = y + dir[1]
					if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
						if _is_type(grid[ny][nx], "residential"):
							residential_neighbors += 1
							
				if residential_neighbors >= 2:
					count += 1
					
	return count
	
func _calc_mixed_rows(grid, grid_size):
	var mixed_lines := 0
	var types = ["residential", "industrial", "culture", "nature"]

	# Проверка горизонтальных рядов
	for y in range(grid_size):
		var found_types := {}
		for x in range(grid_size):
			var cell = grid[y][x]
			if cell != null and cell is CityBlock:
				found_types[cell.type] = true
				
		var all_types_present := true
		for t in types:
			if not found_types.has(t):
				all_types_present = false
				break
				
		if all_types_present:
			mixed_lines += 1

	# Проверка вертикальных рядов
	for x in range(grid_size):
		var found_types := {}
		for y in range(grid_size):
			var cell = grid[y][x]
			if cell != null and cell is CityBlock:
				found_types[cell.type] = true
				
		var all_types_present := true
		for t in types:
			if not found_types.has(t):
				all_types_present = false
				break
				
		if all_types_present:
			mixed_lines += 1

	return mixed_lines
	
func _calc_unique_squares(grid, grid_size):
	var unique_squares := 0
	# Проход по всем возможным верхним левым углам квадратов 2x2
	for y in range(grid_size - 1):
		for x in range(grid_size - 1):
			var cell_types := {}
			var cells_filled := true

			# Проверка 4 ячеек в квадрате 2x2
			for dy in range(2):
				for dx in range(2):
					var cell = grid[y+dy][x+dx]
					if cell != null and cell is CityBlock:
						cell_types[cell.type] = true
					else:
						cells_filled = false
						break
				if not cells_filled:
					break
					
			if cells_filled and cell_types.keys().size() == 4:
				# Квадрат заполнен, и все 4 типа уникальны
				unique_squares += 1
					
	return unique_squares
