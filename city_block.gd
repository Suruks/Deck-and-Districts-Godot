# city_block.gd
extends Node2D
class_name CityBlock

@export var type: String = "residential"  # residential, industrial, nature, culture
@export var aging: int = 0               # старение района
@export var tile_texture: Texture2D = preload("res://tile.png")

static var max_aging = 20

static var block_colors := {
	"residential": Color(0.3, 0.837, 1.0),
	"industrial": Color(1.0, 0.3, 0.3),
	"nature": Color(0.3, 1.0, 0.3),
	"culture": Color(1.0, 0.813, 0.3)
}

static func get_color(block_type: String) -> Color:
	return block_colors.get(block_type, Color.WHITE)
	
var sprite: Sprite2D

func _init():
	sprite = Sprite2D.new()
	sprite.texture = tile_texture
	sprite.centered = true
	add_child(sprite)

func place_at_screen_position(pos: Vector2):
	position = pos
	update_visual()

func update_visual():
	if sprite == null:
		return
	var base_color = block_colors.get(type, Color.WHITE)
	var alpha = clamp(float(aging) / float(max_aging), 0.0, 1.0)
	sprite.modulate = Color(base_color.r, base_color.g, base_color.b, 1.0 - alpha)


func age_block(amount: int = 1):
	aging += amount
	if aging >= max_aging:
		queue_free()
	else:
		update_visual()

# --- Статический метод старения всей сетки ---
static func age_all_blocks(grid: Array):
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var block = grid[y][x]
			if block != null and block is CityBlock:
				block.age_block()
				# Если блок удалился, чистим ссылку в сетке
				if not is_instance_valid(block):
					grid[y][x] = null
