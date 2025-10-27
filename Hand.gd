class_name Hand  # <--- ключевой момент
extends Node2D

signal card_selected(card_index)

@export var card_scene: PackedScene

var hand_data: Array = []
var hand_nodes: Array = []
var selected_card_index: int = -1
var selected_card = null

func draw_hand():
	# удаляем старые Node
	for child in get_children():
		child.queue_free()
	hand_nodes.clear()

	for i in range(hand_data.size()):
		var card_data = hand_data[i]
		var card_instance = card_scene.instantiate()
		card_instance.blocks = card_data.blocks.duplicate()
		card_instance.block_types = card_data.block_types.duplicate()
		card_instance.position = Vector2(i * 120, 0)
		add_child(card_instance)
		hand_nodes.append(card_instance)
		# соединяем сигнал с индексом через bind
		card_instance.connect("card_selected", Callable(self, "_on_card_selected").bind(i))

func _on_card_selected(card_index):
	selected_card_index = card_index
	selected_card = hand_nodes[card_index]
	emit_signal("card_selected", card_index)

func remove_selected_card():
	if selected_card_index == -1:
		return
	hand_data.remove_at(selected_card_index)
	selected_card.queue_free()
	selected_card_index = -1
	selected_card = null
	draw_hand()
