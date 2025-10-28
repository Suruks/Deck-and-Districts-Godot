extends Node2D

@onready var hand_script: Hand = $CanvasLayer/HandContainer as Hand
@onready var deck: Deck = Deck.new()
@onready var quest_deck: QuestDeck = QuestDeck.new()
@onready var quest_manager = QuestManager.new(quest_deck)
@onready var score_label: Label = $CanvasLayer/Score

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

var total_score = 0

# --- READY ---
func _ready():
	randomize()
	deck.init_deck(16)
	
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
	cam.position = grid_to_screen(grid_size/2 - 0.5, grid_size/2 - 0.5) + Vector2(-250, 0)

	# --- Генерация руки ---
	setup_hand()
	
	# --- Спрайт колоды ---
	deck_sprite = Sprite2D.new()
	deck_sprite.texture = preload("res://deck.png")
	$CanvasLayer.add_child(deck_sprite)
	deck_sprite.position = Vector2(70, get_viewport_rect().size.y - 180) # над рукой
	deck_sprite.scale = Vector2(0.5, 0.5)
	
	# --- Лейбл с количеством карт ---
	deck_label = Label.new()
	deck_label.text = str(deck.cards.size())
	
	var font_var = FontVariation.new()
	font_var.base_font = load("res://ARLRDBD.ttf")
	deck_label.add_theme_font_override("font", font_var)
	deck_label.add_theme_font_size_override("font_size", 36)

	deck_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	deck_label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER

	$CanvasLayer.add_child(deck_label)
	deck_label.position = Vector2(47, get_viewport_rect().size.y - 195)
	deck_label.modulate = Color(0, 0, 0, 1)

	
	var input_node = preload("res://input.gd").new()
	add_child(input_node)
	input_node.main_ref = self
	input_node.grid_size = grid_size
	input_node.tile_width = tile_width
	input_node.tile_height = tile_height
	input_node.connect("card_placed", Callable(self, "update_quest_scores"))
	
	# Квесты
	# Создаём менеджер квестов
	quest_deck.init_quests()
	
	quest_manager = QuestManager.new(quest_deck)
	quest_manager.active_quests_container = active_quests_container
	quest_manager.quest_ui_scene = quest_ui_scene
	quest_manager.setup_quests() # теперь active_quests заполнен
	quest_manager.active_quests_container = active_quests_container
	quest_manager.quest_ui_scene = quest_ui_scene
	
	quest_manager.connect("quest_completed", Callable(self, "_on_quest_completed"))
	

@onready var active_quests_container: VBoxContainer = $CanvasLayer/MarginContainer/ActiveQuests
@export var quest_ui_scene: PackedScene = preload("res://QuestUI.tscn")

var active_quests: Array = []

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
	#quest
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
	

# --- Обновление тайла ---
func update_tile_visual(x, y):
	var cell = grid_nodes[y][x]
	cell.modulate = Color(1,1,1)
	if grid[y][x] != null:
		cell.modulate = block_colors.get(grid[y][x], Color.WHITE)
