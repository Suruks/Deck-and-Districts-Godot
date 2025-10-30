extends Node2D
class_name CityBlock

@export var type: String = "residential"
@export var aging: int = 0
@export var tile_texture: Texture2D = preload("res://tile.png")
@export var old_texture: Texture2D = preload("res://old_tile.png")

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
var aging_overlay: Sprite2D

func _init():
	# Основной спрайт
	sprite = Sprite2D.new()
	sprite.texture = tile_texture
	sprite.centered = true
	add_child(sprite)
	
	# Спрайт "старения"
	aging_overlay = Sprite2D.new()
	aging_overlay.texture = old_texture
	aging_overlay.centered = true
	aging_overlay.modulate = Color(1, 1, 1, 0.0) # Сначала невидим
	add_child(aging_overlay)

func place_at_screen_position(pos: Vector2):
	position = pos
	update_visual()

func update_visual():
	if sprite == null or aging_overlay == null:
		return

	var base_color = block_colors.get(type, Color.WHITE)
	sprite.modulate = base_color

	var t = clamp(float(aging) / float(max_aging), 0.0, 1.0)
	var alpha = pow(t, 2)  # ускоряющееся старение
	aging_overlay.modulate.a = alpha

func age_block(amount: int = 1):
	aging += amount
	if aging >= max_aging:
		queue_free()
	else:
		update_visual()

# --- Старение всей сетки ---
static func age_all_blocks(grid: Array, amount: int):
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var block = grid[y][x]
			if block != null and block is CityBlock:
				block.age_block(amount)
				if not is_instance_valid(block):
					grid[y][x] = null
