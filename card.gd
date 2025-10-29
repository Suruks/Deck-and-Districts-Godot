class_name Card
extends Node2D

signal card_selected(card)

@export var blocks: Array = []
@export var block_types: Array = []

const Globals = preload("res://globals.gd")

@onready var background = $Sprite2D
@onready var area = $Area2D

var selected = false
var tile_texture = preload("res://tile.png")
var block_scale := 0.6

func _ready():
	draw_blocks()
	
	scale = Vector2(0.5, 0.5)
	position += Vector2(80, 80)
	area.connect("input_event", Callable(self, "_on_input_event"))


func iso_to_screen(v: Vector2) -> Vector2:
	var tile_w = 128 * block_scale
	var tile_h = 96 * block_scale
	return Vector2((v.x - v.y) * tile_w / 2, (v.x + v.y) * tile_h / 2)
	
# --- Данные форм карт и их веса ---
var card_shapes = [
	# --- несимметричные формы + их зеркала ---
	[Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(2,1)],       # XX\n  XX
	[Vector2(0,0), Vector2(1,0), Vector2(2,0), Vector2(2,1)],       # XXX\n  X
	[Vector2(0,0), Vector2(1,0), Vector2(1,1)],                     # XX\n  X

	# зеркальные варианты
	[Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(-1,1)],      # зеркальная XX\nXX
	[Vector2(0,0), Vector2(1,0), Vector2(2,0), Vector2(0,1)],       # зеркальная XXX\nX

	# --- симметричные формы ---
	[Vector2(0,0), Vector2(1,0), Vector2(2,0)],                     # XXX
	[Vector2(0,0), Vector2(1,0), Vector2(2,0), Vector2(3,0)],       # XXXX
	[Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]        # XX\nXX
]

var card_weights = [
	0.5,  # XX\n  XX
	0.5,  # XXX\n  X
	1.0,  # XX\n  X (симметричная)
	0.5,  # зеркальная XX\nXX
	0.5,  # зеркальная XXX\nX
	1.0,  # XXX
	1.0,  # XXXX
	1.0   # квадрат
]

static func generate_data(shape_type: Variant = "random") -> Dictionary:
	var c = Card.new()
	var shape: Array
	var block_types: Array = []
	var types = ["residential", "industrial", "nature", "culture"]

	# --- выбираем форму ---
	if typeof(shape_type) == TYPE_INT:
		if shape_type >= 0 and shape_type < c.card_shapes.size():
			shape = c.card_shapes[shape_type]
		else:
			push_warning("Некорректный индекс формы карты: %s" % str(shape_type))
			shape = c.choose_weighted_shape()
	elif typeof(shape_type) == TYPE_STRING and shape_type == "random":
		shape = c.choose_weighted_shape()
	else:
		push_warning("Неподдерживаемый тип shape_type: %s" % typeof(shape_type))
		shape = c.choose_weighted_shape()

	# --- распределяем типы без повторов ---
	var available_types = types.duplicate()
	available_types.shuffle()
	for i in range(shape.size()):
		if available_types.size() > 0:
			var t = available_types.pop_back()  # берём уникальный тип
			block_types.append(t)
		else:
			# если типов не хватило — начинаем добавлять случайные
			block_types.append(types[randi() % types.size()])

	return {"blocks": shape, "block_types": block_types}


# --- Функции выбора и генерации карт ---
func choose_weighted_shape():
	var total_weight = 0.0
	for w in card_weights:
		total_weight += w
	var r = randf() * total_weight
	var accum = 0.0
	for i in range(card_shapes.size()):
		accum += card_weights[i]
		if r <= accum:
			return card_shapes[i]
	return card_shapes[-1]

func generate_random_card():
	var shape = choose_weighted_shape()
	var types = ["residential", "industrial", "nature", "culture"]
	var block_types = []
	for i in range(shape.size()):
		block_types.append(types[randi() % types.size()])
	return {"blocks": shape, "block_types": block_types}

func draw_blocks():
	# Удаляем старые блоки, кроме фона и Area2D
	for child in get_children():
		if child != background and child != area:
			child.queue_free()

	# Найдём центр формы, чтобы карта выглядела ровно по центру
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for v in blocks:
		min_x = min(min_x, v.x)
		max_x = max(max_x, v.x)
		min_y = min(min_y, v.y)
		max_y = max(max_y, v.y)

	var center_offset = iso_to_screen(Vector2((min_x + max_x) / 2.0, (min_y + max_y) / 2.0))

	# Создаём изометрические тайлы
	for i in range(blocks.size()):
		var sprite = Sprite2D.new()
		sprite.texture = tile_texture
		sprite.centered = true
		sprite.scale = Vector2(block_scale, block_scale)
		sprite.position = iso_to_screen(blocks[i]) - center_offset
		sprite.modulate = Globals.block_colors.get(block_types[i], Color.WHITE)
		add_child(sprite)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		emit_signal("card_selected")

func rotate_90():
	for i in range(blocks.size()):
		var v = blocks[i]
		blocks[i] = Vector2(-v.y, v.x)
	draw_blocks()
	
func rotate_270():
	for i in range(blocks.size()):
		var v = blocks[i]
		blocks[i] = Vector2(v.y, -v.x)
	draw_blocks()

func set_selected(value: bool):
	selected = value
	scale = Vector2(0.6, 0.6) if selected else Vector2(0.5, 0.5)
