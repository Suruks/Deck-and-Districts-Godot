extends Node2D

@onready var hand_script: Hand = $CanvasLayer/HandContainer as Hand
@onready var deck: Deck = Deck.new()
@onready var quest_deck: QuestDeck = QuestDeck.new()
@onready var quest_manager = QuestManager.new(quest_deck)
@onready var score_label: Label = $CanvasLayer/Score

var grid_size = 11
var tile_width = 124
var tile_height = 92
var tile_texture = preload("res://tile.png")
var old_texture = preload("res://old_tile.png")
var grid_nodes = []
var grid = []

var selected_card = null
var selected_card_index = -1
var ghost_tiles = []

var deck_sprite: Sprite2D
var deck_label: Label
var replace_hand_sprite: TextureButton

var total_score = 0

# --- READY ---
func _ready():
	randomize()
	deck.init_deck(20)
	
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

	# Камера
	var cam_scene = preload("res://camera_controller.gd")
	var cam = Camera2D.new()
	cam.set_script(cam_scene)
	add_child(cam)
	cam.zoom = Vector2(0.66, 0.66)
	cam.position = grid_to_screen(grid_size / 2 - 0.5, grid_size / 2 - 0.5) + Vector2(-250, 20)

	# Рука
	setup_hand()
	
	# Колода
	deck_sprite = Sprite2D.new()
	deck_sprite.texture = preload("res://deck.png")
	$CanvasLayer.add_child(deck_sprite)
	deck_sprite.position = Vector2(70, get_viewport_rect().size.y - 180)
	deck_sprite.scale = Vector2(0.5,0.5)
	
	deck_label = Label.new()
	deck_label.text = str(deck.cards.size())
	var font_var = FontVariation.new()
	font_var.base_font = load("res://ARLRDBD.ttf")
	deck_label.add_theme_font_override("font", font_var)
	deck_label.add_theme_font_size_override("font_size", 36)
	deck_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	deck_label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
	$CanvasLayer.add_child(deck_label)
	deck_label.position = Vector2(47,get_viewport_rect().size.y-195)
	deck_label.modulate = Color(0,0,0,1)

	# Кнопка replace_hand
	replace_hand_sprite = TextureButton.new()
	replace_hand_sprite.texture_normal = preload("res://replace_hand.png")
	replace_hand_sprite.mouse_filter = Control.MOUSE_FILTER_STOP
	$CanvasLayer.add_child(replace_hand_sprite)
	replace_hand_sprite.position = Vector2(125, get_viewport_rect().size.y - 210)
	replace_hand_sprite.scale = Vector2(0.35,0.35)
	replace_hand_sprite.connect("gui_input", Callable(self, "_on_replace_hand_input"))
	replace_hand_sprite.connect("mouse_exited", Callable(self, "_on_hover_exit"))

	var input_node = preload("res://input.gd").new()
	add_child(input_node)
	input_node.main_ref = self
	input_node.grid_size = grid_size
	input_node.tile_width = tile_width
	input_node.tile_height = tile_height
	input_node.connect("card_placed", Callable(self, "update_quest_scores"))

	# Квесты
	quest_deck.init_quests()
	quest_manager = QuestManager.new(quest_deck)
	quest_manager.active_quests_container = active_quests_container
	quest_manager.quest_ui_scene = quest_ui_scene
	quest_manager.setup_quests()
	quest_manager.connect("quest_completed", Callable(self, "_on_quest_completed"))

@onready var active_quests_container: VBoxContainer = $CanvasLayer/MarginContainer/ActiveQuests
@export var quest_ui_scene: PackedScene = preload("res://QuestUI.tscn")
var active_quests: Array = []

# --- Квесты ---
func _on_card_rotate_requested():
	if selected_card:
		selected_card.rotate_90()
		self.input_node.update_preview()

func create_quest_ui(quest: Quest) -> Control:
	var panel_instance = quest_ui_scene.instantiate()
	var label: RichTextLabel = panel_instance.get_node("Panel/VBoxContainer/LabelDescription")
	label.bbcode_enabled = true
	label.bbcode_text = quest.description
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.fit_content = true
	panel_instance.call_deferred("_update_size")
	return panel_instance

func update_quest_scores():
	if quest_manager == null:
		return
	var total = quest_manager.compute_all_scores(grid, grid_size)
	print("Общий счёт квестов:", total)

func _on_quest_completed(reward_count: int):
	print("Квест завершён! Добавляем", reward_count, "карт(ы) в колоду.")
	deck.add_cards(reward_count)
	deck_label.text = str(deck.cards.size())
	total_score += reward_count*10
	score_label.text = str(total_score)
	quest_manager.compute_all_scores(grid, grid_size)

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
func _on_card_selected(selected_card_index):
	selected_card = hand_script.selected_card
	selected_card_index = hand_script.selected_card_index
	print("Выбрана карта с формой:", selected_card.blocks)

# --- Преобразование координат ---
func grid_to_screen(x, y):
	return Vector2((x - y) * tile_width / 2, (x + y) * tile_height / 2)

# --- Replace hand ---
func _on_replace_hand_input(event: InputEvent) -> void:
	if replace_hand_sprite.texture_normal == null or hand_script == null:
		return

	# Проверка, что сетка не пустая
	var grid_empty = true
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] != null:
				grid_empty = false
				break
		if not grid_empty:
			break
	if grid_empty:
		replace_hand_sprite.modulate = Color(1,1,1,1)
		return

	var tex = replace_hand_sprite.texture_normal
	var img = tex.get_image()
	var btn_size = replace_hand_sprite.get_size()

	# координаты мыши внутри кнопки
	var local_pos = replace_hand_sprite.get_local_mouse_position()
	var tex_size = tex.get_size()
	var tex_pos = Vector2(
		local_pos.x / btn_size.x * tex_size.x,
		local_pos.y / btn_size.y * tex_size.y
	).floor()

	# проверка выхода за границы текстуры
	if tex_pos.x < 0 or tex_pos.y < 0 or tex_pos.x >= tex_size.x or tex_pos.y >= tex_size.y:
		replace_hand_sprite.modulate = Color(1,1,1,1)
		return

	var alpha = img.get_pixelv(tex_pos).a

	# --- Hover ---
	if event is InputEventMouseMotion:
		if alpha > 0.1:
			replace_hand_sprite.modulate = Color(0.85,0.85,0.85,1)
		else:
			replace_hand_sprite.modulate = Color(1,1,1,1)

	# --- Click ---
	if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if alpha > 0.1:
			replace_hand_sprite.modulate = Color(1,1,1,1)
			_replace_hand()



func _replace_hand():
	var grid_empty = true
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] != null:
				grid_empty = false
				break
		if not grid_empty:
			break
			
	if grid_empty:
		print("Сетка пустая, заменить руку нельзя")
		return
			
	# Старим все блоки
	CityBlock.age_all_blocks(grid, 3)

	if hand_script == null or hand_script.hand_data.size() == 0:
		return

	# Сохраняем старую руку
	var old_hand = hand_script.hand_data.duplicate()
	deck.add_cards_from_data(old_hand)

	# Очищаем руку
	hand_script.hand_data.clear()
	hand_script.draw_hand()

	# Берём новые карты столько же, сколько было
	for i in range(old_hand.size()):
		var new_card = deck.draw_card()
		if new_card:
			hand_script.add_card(new_card)
