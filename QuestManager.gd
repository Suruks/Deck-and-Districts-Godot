class_name QuestManager
extends Node

@export var quest_ui_scene: PackedScene
@export var active_quests_container: VBoxContainer

var quest_deck: QuestDeck
var active_quests: Array = []

func _init(_quest_deck: QuestDeck):
	quest_deck = _quest_deck

func setup_quests(count := 3):
	active_quests.clear()
	for child in active_quests_container.get_children():
		child.queue_free()

	for i in range(count):
		var q = quest_deck.draw_quest()
		if q == null:
			break
		active_quests.append(q)

		var ui = quest_ui_scene.instantiate()
		ui.quest = q
		active_quests_container.add_child(ui)
		ui.call_deferred("update_ui")


func compute_all_scores(grid: Array, grid_size: int) -> int:
	var total_score := 0
	for q in active_quests:
		var score = q.calculate_score(grid, grid_size)
		total_score += score
		print("[QuestManager] %s: %d" % [q.quest_type, score])
		
		for child in active_quests_container.get_children():
			if "update_ui" in child:
				child.update_ui()
	return total_score
