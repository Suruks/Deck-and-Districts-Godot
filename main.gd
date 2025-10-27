extends Node2D

@onready var hand_script: Hand = null

# --- Сетка ---
var grid_size = 10
var tile_width = 128
var tile_height = 96
var tile_texture = preload("res://tile.png")
var grid_nodes = []
var grid = []

# --- Рука ---
var selected_card = null
var selected_card_index = -1

# --- Цвета кварталов ---
var block_colors = {
	"residential": Color(0.3, 0.837, 1.0),
	"industrial": Color(1.0, 0.3, 0.3),
	"nature": Color(0.3, 1.0, 0.3),
	"culture": Color(1.0, 0.813, 0.3)
}

# --- Предпросмотр ---
var preview_blocks: Array = []
var preview_opacity := 1

func _ready():
	setup_grid()
	setup_camera()
	setup_hand()

func setup_grid():
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

func setup_camera():
	var cam = Camera2D.new()
	cam.zoom = Vector2(0.66, 0.66)
	add_child(cam)
	cam.make_current()
	cam.position = grid_to_screen(grid_size / 2 - 0.5, grid_size / 2 - 0.5)

func setup_hand():
	var old_hand = $CanvasLayer.get_node_or_null("HandContainer")
	if old_hand:
		old_hand.queue_free()

	var hand = Hand.new()
	hand.name = "HandContainer"
	$CanvasLayer.add_child(hand)

	# Позиция и масштаб руки
	hand.position = Vector2(0, 490)
	hand.scale = Vector2(1, 1)

	hand.card_scene = preload("res://card.tscn")
	hand.hand_data = [
		{"blocks":[Vector2(0,0), Vector2(1,0), Vector2(0,1)], "block_types":["residential","industrial","nature"]},
		{"blocks":[Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)], "block_types":["residential","industrial","nature","culture"]},
		{"blocks":[Vector2(0,0), Vector2(0,1), Vector2(0,2)], "block_types":["industrial","industrial","residential"]}
	]
	hand.draw_hand()
	hand.connect("card_selected", Callable(self, "_on_card_selected"))
	hand_script = hand
	print("Карты в руке:", hand.get_children())

func _on_card_selected(card_index):
	selected_card = hand_script.selected_card
	selected_card_index = hand_script.selected_card_index
	print("Выбрана карта с формой: ", selected_card.blocks)

func grid_to_screen(x, y):
	return Vector2((x - y) * tile_width / 2, (x + y) * tile_height / 2)

func update_tile_visual(x, y):
	var cell = grid_nodes[y][x]
	if cell == null:
		return
	cell.modulate = block_colors.get(grid[y][x], Color(1,1,1))

func place_card_on_grid(cell_coords: Vector2):
	if selected_card == null:
		return

	# Проверка выхода за границы
	for i in range(selected_card.blocks.size()):
		var bpos = selected_card.blocks[i] + cell_coords
		if bpos.x < 0 or bpos.y < 0 or bpos.x >= grid_size or bpos.y >= grid_size:
			print("Не хватает места")
			return

	# Размещение блоков
	for i in range(selected_card.blocks.size()):
		var bpos = selected_card.blocks[i] + cell_coords
		grid[bpos.y][bpos.x] = selected_card.block_types[i]
		update_tile_visual(bpos.x, bpos.y)

	# Убираем карту из руки
	hand_script.remove_selected_card()
	selected_card = null
	selected_card_index = -1
	clear_preview()

func _input(event):
	# Движение мыши для предпросмотра
	if event is InputEventMouseMotion and selected_card:
		var mouse_pos = get_global_mouse_position()
		var found = false
		for y in range(grid_size):
			for x in range(grid_size):
				if point_in_rhomb(mouse_pos, grid_nodes[y][x].position):
					show_preview(Vector2(x, y))
					found = true
					break
			if found:
				break
		if not found:
			clear_preview()

	# Клик для размещения
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and selected_card:
			var mouse_pos = get_global_mouse_position()
			for y in range(grid_size):
				for x in range(grid_size):
					if point_in_rhomb(mouse_pos, grid_nodes[y][x].position):
						place_card_on_grid(Vector2(x, y))
						break

	# Вращение карты
	if event is InputEventKey and event.pressed:
		if event.keycode == Key.KEY_R and selected_card:
			selected_card.rotate_90()
			
			# Обновляем предпросмотр на текущей позиции мыши
			var mouse_pos = get_global_mouse_position()
			var found = false
			for y in range(grid_size):
				for x in range(grid_size):
					if point_in_rhomb(mouse_pos, grid_nodes[y][x].position):
						show_preview(Vector2(x, y))
						found = true
						break
				if found:
					break
			if not found:
				clear_preview()

func point_in_rhomb(point: Vector2, center: Vector2) -> bool:
	var local = point - center
	var dx = abs(local.x) / (tile_width / 2)
	var dy = abs(local.y) / (tile_height / 2)
	return dx + dy <= 1

# --- Предпросмотр ---
func show_preview(cell_coords: Vector2):
	clear_preview()
	if selected_card == null:
		return

	for i in range(selected_card.blocks.size()):
		var block_pos = selected_card.blocks[i] + cell_coords
		if block_pos.x < 0 or block_pos.y < 0 or block_pos.x >= grid_size or block_pos.y >= grid_size:
			continue

		var block_type = selected_card.block_types[i]
		var color = block_colors.get(block_type, Color(1,1,1))
		var preview_tile = Sprite2D.new()
		preview_tile.texture = tile_texture
		preview_tile.centered = true
		preview_tile.position = grid_to_screen(block_pos.x, block_pos.y)
		preview_tile.modulate = Color(color.r, color.g, color.b, preview_opacity)
		add_child(preview_tile)
		preview_blocks.append(preview_tile)

func clear_preview():
	for p in preview_blocks:
		if is_instance_valid(p):
			p.queue_free()
	preview_blocks.clear()
