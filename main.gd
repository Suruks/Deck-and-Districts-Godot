extends Node2D

@onready var hand_script: Hand = $CanvasLayer/HandContainer as Hand
@onready var deck: Deck = Deck.new()

# --- Параметры сетки ---
var grid_size = 10
var tile_width = 128
var tile_height = 96
var tile_texture = preload("res://tile.png")
var grid_nodes = []
var grid = []

# --- Состояние ---
var selected_card = null
var selected_card_index = -1
var ghost_tiles = []

var deck_sprite: Sprite2D
var deck_label: Label

# --- Цвета кварталов ---
var block_colors = {
	"residential": Color(0.3, 0.837, 1.0),
	"industrial": Color(1.0, 0.3, 0.3),
	"nature": Color(0.3, 1.0, 0.3),
	"culture": Color(1.0, 0.813, 0.3)
}

# --- READY ---
func _ready():
	randomize()
	deck.init_deck(12)
	
	# --- Сетка ---
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

	# --- Камера ---
	var cam = Camera2D.new()
	cam.zoom = Vector2(0.66, 0.66)
	add_child(cam)
	cam.make_current()
	cam.position = grid_to_screen(grid_size/2 - 0.5, grid_size/2 - 0.5) + Vector2(-200, 0)

	# --- Генерация руки ---
	setup_hand()
	
		# --- Спрайт колоды ---
	deck_sprite = Sprite2D.new()
	deck_sprite.texture = preload("res://deck.png")
	$CanvasLayer.add_child(deck_sprite)
	deck_sprite.position = Vector2(70, get_viewport_rect().size.y - 180) # над рукой
	deck_sprite.scale = Vector2(0.12, 0.12)

	# --- Лейбл с количеством карт ---
	deck_label = Label.new()
	deck_label.text = str(deck.cards.size())
	deck_label.scale = Vector2(2.0, 2.0)
	$CanvasLayer.add_child(deck_label)
	deck_label.position = Vector2(65, get_viewport_rect().size.y - 200)
	deck_label.modulate = Color(0.0, 0.145, 0.541, 1.0)



# --- Генерация руки ---
func setup_hand():
	var old_hand = $CanvasLayer.get_node_or_null("HandContainer")
	if old_hand:
		old_hand.queue_free()

	var hand = Hand.new()
	hand.name = "HandContainer"
	$CanvasLayer.add_child(hand)
	hand.card_scene = preload("res://card.tscn")

	hand.hand_data = [
		deck.draw_card(),
		deck.draw_card(),
		deck.draw_card()
	]

	hand.draw_hand()
	hand.connect("card_selected", Callable(self, "_on_card_selected"))
	hand_script = hand


# --- Выбор карты ---
func _on_card_selected(card_index):
	selected_card = hand_script.selected_card
	selected_card_index = hand_script.selected_card_index
	print("Выбрана карта с формой:", selected_card.blocks)


# --- Преобразование координат ---
func grid_to_screen(x, y):
	return Vector2((x - y) * tile_width / 2, (x + y) * tile_height / 2)


# --- Обновление тайла ---
func update_tile_visual(x, y):
	var cell = grid_nodes[y][x]
	cell.modulate = Color(1,1,1)
	if grid[y][x] != null:
		cell.modulate = block_colors.get(grid[y][x], Color.WHITE)


# --- Размещение карты ---
func place_card_on_grid(cell_coords: Vector2):
	if selected_card == null:
		return

	for i in range(selected_card.blocks.size()):
		var bpos = selected_card.blocks[i] + cell_coords
		if bpos.x < 0 or bpos.y < 0 or bpos.x >= grid_size or bpos.y >= grid_size:
			print("Не хватает места")
			return

	for i in range(selected_card.blocks.size()):
		var bpos = selected_card.blocks[i] + cell_coords
		grid[bpos.y][bpos.x] = selected_card.block_types[i]
		update_tile_visual(bpos.x, bpos.y)

		# Удаляем карту из руки
	hand_script.remove_selected_card()

	# Берём новую карту из колоды
	var new_card = deck.draw_card()
	if new_card != null:
		hand_script.add_card(new_card)
		
	# Обновляем лейбл
	deck_label.text = str(deck.cards.size())
		
	selected_card = null
	selected_card_index = -1
	clear_preview()


# --- Предпросмотр ---
func show_preview(cell_coords: Vector2):
	clear_preview()
	if selected_card == null:
		return

	for i in range(selected_card.blocks.size()):
		var bpos = selected_card.blocks[i] + cell_coords
		if bpos.x < 0 or bpos.y < 0 or bpos.x >= grid_size or bpos.y >= grid_size:
			continue
		var ghost = Sprite2D.new()
		ghost.texture = tile_texture
		ghost.centered = true
		ghost.position = grid_to_screen(bpos.x, bpos.y)
		ghost.modulate = block_colors.get(selected_card.block_types[i], Color.WHITE)
		ghost.modulate.a = 1.0
		add_child(ghost)
		ghost_tiles.append(ghost)

func clear_preview():
	for g in ghost_tiles:
		g.queue_free()
	ghost_tiles.clear()


# --- Ввод ---
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == Key.KEY_R and selected_card:
			selected_card.rotate_90()
			update_preview()

	if event is InputEventMouseMotion and selected_card:
		update_preview()

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and selected_card:
			var cell = get_hovered_cell()
			if cell != null:
				place_card_on_grid(cell)


# --- Подсобные ---
func get_hovered_cell():
	var mouse_pos = get_global_mouse_position()
	for y in range(grid_size):
		for x in range(grid_size):
			if point_in_rhomb(mouse_pos, grid_nodes[y][x].position):
				return Vector2(x, y)
	return null

func update_preview():
	var cell = get_hovered_cell()
	if cell != null:
		show_preview(cell)
	else:
		clear_preview()

func point_in_rhomb(point: Vector2, center: Vector2) -> bool:
	var local = point - center
	var dx = abs(local.x) / (tile_width / 2)
	var dy = abs(local.y) / (tile_height / 2)
	return dx + dy <= 1
