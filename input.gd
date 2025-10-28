extends Node

signal card_placed()
signal card_rotated()

var main_ref: Node = null
var tile_width := 128
var tile_height := 96
var grid_size := 10
var ghost_tiles := []

# --- Ввод ---
func _input(event):
	if main_ref == null:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN and main_ref.selected_card:
			main_ref.selected_card.rotate_90()
			update_preview()
			card_rotated.emit()
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP and main_ref.selected_card:
			main_ref.selected_card.rotate_270()
			update_preview()
			card_rotated.emit()
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and main_ref.selected_card:
			var cell = get_hovered_cell()
			if cell != null:
				place_card_on_grid(cell)

	elif event is InputEventMouseMotion and main_ref.selected_card:
		update_preview()

# --- Размещение карты ---
func place_card_on_grid(cell_coords: Vector2):
	var selected_card = main_ref.selected_card
	if selected_card == null:
		return

	# Проверка, помещается ли карта в сетку
	for i in range(selected_card.blocks.size()):
		var bpos = selected_card.blocks[i] + cell_coords
		if bpos.x < 0 or bpos.y < 0 or bpos.x >= grid_size or bpos.y >= grid_size:
			print("❌ Не хватает места для размещения карты")
			return

	# Размещение блоков
	for i in range(selected_card.blocks.size()):
		var bpos = selected_card.blocks[i] + cell_coords
		main_ref.grid[bpos.y][bpos.x] = selected_card.block_types[i]
		main_ref.update_tile_visual(bpos.x, bpos.y)

	# Удаляем карту из руки
	main_ref.hand_script.remove_selected_card()

	# Берём новую карту из колоды
	var new_card = main_ref.deck.draw_card()
	if new_card != null:
		main_ref.hand_script.add_card(new_card)

	# Обновляем лейбл
	main_ref.deck_label.text = str(main_ref.deck.cards.size())
	
		
	# Очистка состояния
	main_ref.selected_card = null
	main_ref.selected_card_index = -1
	clear_preview()
	card_placed.emit()

# --- Предпросмотр ---
func update_preview():
	var cell = get_hovered_cell()
	if cell != null:
		show_preview(cell)
	else:
		clear_preview()

func show_preview(cell_coords: Vector2):
	clear_preview()
	if main_ref.selected_card == null:
		return

	for i in range(main_ref.selected_card.blocks.size()):
		var bpos = main_ref.selected_card.blocks[i] + cell_coords
		if bpos.x < 0 or bpos.y < 0 or bpos.x >= grid_size or bpos.y >= grid_size:
			continue
		var ghost = Sprite2D.new()
		ghost.texture = main_ref.tile_texture
		ghost.centered = true
		ghost.position = grid_to_screen(bpos.x, bpos.y)
		ghost.modulate = main_ref.block_colors.get(main_ref.selected_card.block_types[i], Color.WHITE)
		ghost.modulate.a = 1.0
		main_ref.add_child(ghost)
		ghost_tiles.append(ghost)

func clear_preview():
	for g in ghost_tiles:
		g.queue_free()
	ghost_tiles.clear()

# --- Наведение ---
func get_hovered_cell():
	var mouse_pos = main_ref.get_viewport().get_camera_2d().get_global_mouse_position()
	for y in range(grid_size):
		for x in range(grid_size):
			if point_in_rhomb(mouse_pos, main_ref.grid_nodes[y][x].position):
				return Vector2(x, y)
	return null

func point_in_rhomb(point: Vector2, center: Vector2) -> bool:
	var local = point - center
	var dx = abs(local.x) / (tile_width / 2)
	var dy = abs(local.y) / (tile_height / 2)
	return dx + dy <= 1

# --- Преобразование координат ---
func grid_to_screen(x, y):
	return Vector2((x - y) * tile_width / 2, (x + y) * tile_height / 2)
