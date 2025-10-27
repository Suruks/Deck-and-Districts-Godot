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
	if event is InputEventMouseButton and event.pressed:
		emit_signal("card_selected")

func rotate_90():
	for i in range(blocks.size()):
		var v = blocks[i]
		blocks[i] = Vector2(-v.y, v.x)
	draw_blocks()

func set_selected(value: bool):
	selected = value
	scale = Vector2(0.6, 0.6) if selected else Vector2(0.5, 0.5)
