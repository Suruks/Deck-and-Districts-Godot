# GridManager.gd
extends Node2D
class_name GridManager

# --- Переменные из main.gd ---
var grid_size: int
var tile_width: int
var tile_height: int
var tile_texture: Texture2D
var old_texture: Texture2D

var grid_nodes: Array = [] # Спрайты плиток (Node2D)
var grid: Array = []       # Массив CityBlock (данные)
var ghost_tiles: Array = [] # Спрайты превью

# --- ЗАВИСИМОСТИ ---
var card_manager: CardManager

# --- ПУБЛИЧНЫЕ МЕТОДЫ ИНТЕРФЕЙСА ---

func get_grid() -> Array:
	return grid

func get_grid_size() -> int:
	return grid_size
	
func init_grid(size: int, t_w: int, t_h: int, t_tex: Texture2D, o_tex: Texture2D):
	grid_size = size
	tile_width = t_w
	tile_height = t_h
	tile_texture = t_tex
	old_texture = o_tex
	
	# --- Сетка: Логика, которую мы убрали из main.gd::_ready() ---
	grid_nodes.clear()
	grid.clear()
	for y in range(grid_size):
		grid_nodes.append([])
		grid.append([])
		for x in range(grid_size):
			var tile = Sprite2D.new()
			tile.texture = tile_texture
			tile.centered = true
			tile.position = grid_to_screen(x, y)
			add_child(tile)
			grid_nodes[y].append(tile)
			grid[y].append(null)

# --- Преобразование координат ---
func grid_to_screen(x, y):
	return Vector2((x - y) * tile_width / 2, (x + y) * tile_height / 2)
	
func point_in_rhomb(point: Vector2, center: Vector2) -> bool:
	var local = point - center
	var dx = abs(local.x) / (tile_width / 2)
	var dy = abs(local.y) / (tile_height / 2)
	return dx + dy <= 1
	
func get_hovered_cell():
	var mouse_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	for y in range(grid_size):
		for x in range(grid_size):
			if point_in_rhomb(mouse_pos, grid_nodes[y][x].position):
				return Vector2(x, y)
	return null
	
func show_preview(cell_coords: Vector2):
	clear_preview()
	if card_manager.selected_card == null:
		return

	for i in range(card_manager.selected_card.blocks.size()):
		var bpos = card_manager.selected_card.blocks[i] + cell_coords
		if bpos.x < 0 or bpos.y < 0 or bpos.x >= grid_size or bpos.y >= grid_size:
			continue
		var ghost = Sprite2D.new()
		ghost.texture = tile_texture
		ghost.centered = true
		ghost.position = grid_to_screen(bpos.x, bpos.y)
		ghost.modulate = CityBlock.get_color(card_manager.selected_card.block_types[i])
		ghost.modulate.a = 1.0
		add_child(ghost)
		ghost_tiles.append(ghost)

func clear_preview():
	for g in ghost_tiles:
		g.queue_free()
	ghost_tiles.clear()

func update_preview():
	var cell = get_hovered_cell()
	if cell != null:
		show_preview(cell)
	else:
		clear_preview()
		
func _can_place_card(card: Card, cell_coords: Vector2) -> bool:
	# Проверка, помещается ли карта в сетку
	for i in range(card.blocks.size()):
		var bpos = card.blocks[i] + cell_coords
		if bpos.x < 0 or bpos.y < 0 or bpos.x >= grid_size or bpos.y >= grid_size:
			print("❌ Не хватает места для размещения карты")
			return false
	return true
	
func _execute_placement(selected_card: Card, cell_coords: Vector2):
	# Старение всех блоков
	CityBlock.age_all_blocks(grid, 1) # 'grid' и 'CityBlock' доступны в main.gd

	# Размещение блоков
	for i in range(selected_card.blocks.size()):
		var bpos = selected_card.blocks[i] + cell_coords

		# ... (логика удаления старого блока)
		var old_block = grid[bpos.y][bpos.x]
		if old_block != null and is_instance_valid(old_block):
			old_block.queue_free()

		# ... (логика создания нового блока)
		var new_block = CityBlock.new()
		new_block.type = selected_card.block_types[i]
		new_block.place_at_screen_position(grid_to_screen(bpos.x, bpos.y))
		add_child(new_block)
		grid[bpos.y][bpos.x] = new_block
		
func get_center_screen_position() -> Vector2:
	var center_coord = float(grid_size) / 2.0 - 0.5
	return grid_to_screen(center_coord, center_coord)
