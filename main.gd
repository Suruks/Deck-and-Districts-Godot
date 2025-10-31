extends Node2D

@onready var hand_script: Hand = $CanvasLayer/HandContainer as Hand
@onready var quest_deck: QuestDeck = QuestDeck.new()
@onready var quest_manager = QuestManager.new(quest_deck)
@onready var score_label: Label = $CanvasLayer/Score

var card_manager: CardManager

const InputScriptClass = preload("res://input.gd")
var input_script: InputClass

const GridManagerClass = preload("res://GridManager.gd")
var grid_manager: GridManager

var deck_sprite: Sprite2D
var deck_label: Label
var replace_hand_sprite: TextureButton

var total_score = 0

# --- READY ---
func _ready():
	randomize()
	
	# 1. Создание экземпляров контроллеров
	input_script = InputClass.new()
	add_child(input_script)

	card_manager = CardManager.new()
	add_child(card_manager) # Теперь Godot управляет его жизненным циклом!
	card_manager.init_deck(23)
	
	card_manager.setup_hand($CanvasLayer)
	
	input_script.placement_attempted.connect(Callable(self, "_on_placement_attempted"))
	input_script.rotation_requested.connect(card_manager.handle_rotation_request)
	card_manager.card_rotated.connect(Callable(self, "_on_card_rotated"))
	card_manager.connect("deck_updated", Callable(self, "_update_deck_ui"))
	
	input_script.is_active = true # Включаем обработчик ввода
	
	# --- Сетка ---
	grid_manager = GridManagerClass.new()
	add_child(grid_manager)
	
	var tile_texture = preload("res://tile.png")
	var old_texture = preload("res://old_tile.png")
	grid_manager.init_grid(11, 124, 92, tile_texture, old_texture)
	grid_manager.card_manager = card_manager

	# Камера
	var cam_scene = preload("res://camera_controller.gd")
	var cam = Camera2D.new()
	cam.set_script(cam_scene)
	add_child(cam)
	cam.zoom = Vector2(0.66, 0.66)
	
	var grid_center_pos = grid_manager.get_center_screen_position()
	var final_camera_pos = grid_center_pos + Vector2(-250, 20)
	cam.position = final_camera_pos

	# Колода
	deck_sprite = Sprite2D.new()
	deck_sprite.texture = preload("res://deck.png")
	$CanvasLayer.add_child(deck_sprite)
	deck_sprite.position = Vector2(70, get_viewport_rect().size.y - 180)
	deck_sprite.scale = Vector2(0.5,0.5)
	
	deck_label = Label.new()
	deck_label.text = str(card_manager.get_deck_size()) # <--- Теперь обращаемся к CardManager
	var font_var = FontVariation.new()
	font_var.base_font = load("res://ARLRDBD.ttf")
	deck_label.add_theme_font_override("font", font_var)
	deck_label.add_theme_font_size_override("font_size", 32)
	deck_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	deck_label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
	$CanvasLayer.add_child(deck_label)
	deck_label.position = Vector2(50,get_viewport_rect().size.y-195)
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
	var current_grid = grid_manager.get_grid()
	var current_grid_size = grid_manager.get_grid_size()
	total_score = quest_manager.compute_all_scores(current_grid, current_grid_size)
	score_label.text = str(total_score)

func _on_quest_completed(reward_count: int):
	print("Квест завершён! Добавляем", reward_count, "карт(ы) в колоду.")
	var added = card_manager.add_cards(reward_count)
	var not_added = reward_count - added
	deck_label.text = str(card_manager.get_deck_size())
	
	# очки: добавленные х10, не добавленные из-за лимита х20
	total_score += added * 10 + not_added * 20
	score_label.text = str(total_score)
	
	quest_manager.compute_all_scores(grid_manager.get_grid(), grid_manager.get_grid_size())


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
		card_manager.draw_card(),
		card_manager.draw_card(),
		card_manager.draw_card()
	]
	hand.draw_hand()
	hand.connect("card_selected", Callable(self, "_on_card_selected"))
	hand_script = hand



func _on_placement_attempted():
	# 1. Определение ячейки
	var cell_coords = grid_manager.get_hovered_cell()
	if cell_coords == null:
		return

	# 2. Получение данных карты (через CardManager)
	var selected_card = card_manager.get_selected_card()
	if selected_card == null:
		return

	# 3. Проверка правил (переносим логику проверки из input.gd)
	if not grid_manager._can_place_card(selected_card, cell_coords):
		return

	# 4. Выполнение размещения блоков (логика из input.gd)
	grid_manager._execute_placement(selected_card, cell_coords)

	# 5. Выполнение транзакции (обновление руки/колоды)
	card_manager.complete_placement_transaction()
	
	# 6. Обновление UI/Квестов
	_update_deck_ui() # Обновляем счетчик
	grid_manager.clear_preview()
	# card_placed.emit() # Если такой сигнал нужен для квестов, излучаем его здесь!
	update_quest_scores() # Обновление квестов


func _update_deck_ui():
	deck_label.text = str(card_manager.get_deck_size())
	
# --- Replace hand ---
func _on_replace_hand_input(event: InputEvent) -> void:
	if replace_hand_sprite.texture_normal == null or hand_script == null:
		return

	# Проверка, что сетка не пустая
	var grid_empty = true
	for y in range(grid_manager.grid_size):
		for x in range(grid_manager.grid_size):
			if grid_manager.grid[y][x] != null:
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

func _on_card_rotated(_card: Card):
	update_ghost_preview()
	
func update_ghost_preview():
	var cell = grid_manager.get_hovered_cell()
	if cell != null:
		grid_manager.show_preview(cell)
	else:
		grid_manager.clear_preview()

func _replace_hand():
	var grid_empty = true
	for y in range(grid_manager.grid_size):
		for x in range(grid_manager.grid_size):
			if grid_manager.grid[y][x] != null:
				grid_empty = false
				break
		if not grid_empty:
			break
			
	if grid_empty:
		print("Сетка пустая, заменить руку нельзя")
		return
			
	# Старим все блоки
	CityBlock.age_all_blocks(grid_manager.grid, 3)

	if hand_script == null or hand_script.hand_data.size() == 0:
		return

	# Сохраняем старую руку
	var old_hand = hand_script.hand_data.duplicate()
	card_manager.add_cards_from_data(old_hand)

	# Очищаем руку
	hand_script.hand_data.clear()
	hand_script.draw_hand()

	# Берём новые карты столько же, сколько было
	for i in range(old_hand.size()):
		var new_card = card_manager.draw_card()
		if new_card:
			hand_script.add_card(new_card)
			
	deck_label.text = str(card_manager.get_deck_size())

func _input(event):
	# Проверяем, что событие — это движение мыши
	if event is InputEventMouseMotion:
		# Main.gd спрашивает CardManager, выбрана ли карта
		if card_manager.get_selected_card() != null:
			grid_manager.update_preview() # Вызываем локальный метод main.gd
