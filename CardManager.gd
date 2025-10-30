class_name CardManager
extends Node

var main: Node2D  # <- ссылка на main.gd
var selected_card: Card = null
var selected_card_index: int = -1

@export var card_scene: PackedScene = preload("res://card.tscn")
@onready var deck: Deck = Deck.new()
@onready var hand: Hand

func select_card(card: Card, index: int):
	selected_card = card
	selected_card_index = index

func init_deck(size: int):
	deck.init_deck(size)

func setup_hand(parent: CanvasLayer):
	# Очистим старую руку, если есть
	var old_hand = parent.get_node_or_null("HandContainer")
	if old_hand:
		old_hand.queue_free()

	# Создаём новую
	hand = Hand.new()
	hand.name = "HandContainer"
	parent.add_child(hand)
	hand.card_scene = card_scene

	hand.hand_data = [
		deck.draw_card(),
		deck.draw_card(),
		deck.draw_card()
	]

	hand.draw_hand()
	hand.connect("card_selected", Callable(self, "_on_card_selected"))

func _on_card_selected(index: int):
	selected_card = hand.selected_card
	selected_card_index = index

func rotate_selected():
	if selected_card:
		selected_card.rotate_90()

func add_cards(count: int):
	deck.add_cards(count)

func get_deck_size() -> int:
	return deck.cards.size()
