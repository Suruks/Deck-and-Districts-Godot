class_name Quest
extends Resource  # используем Resource, чтобы удобно хранить данные

@export var description: String = ""
@export var reward_cards: int = 0
@export var current_progress: int = 0
@export var target_progress: int = 1

func is_completed() -> bool:
	return current_progress >= target_progress
