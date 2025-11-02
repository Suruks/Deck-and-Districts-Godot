class_name CardManager
extends Node

signal deck_updated
signal card_rotated(card: Card) # Излучается после вращения

var main: Node2D  # <- ссылка на main.gd
var selected_card: Card = null
var selected_card_index: int = -1

@export var card_scene: PackedScene = preload("res://card.tscn")

var deck: Deck
var hand: Hand

func _init():
	deck = Deck.new()
	add_child(deck)

func complete_placement_transaction():
	if selected_card == null:
		return null

	# 1. Удаляем карту из руки
	hand.remove_selected_card() 
	
	# 2. Очищаем состояние выбора
	selected_card = null
	selected_card_index = -1
	hand.clear_selection() # <--- метод для снятия выделения со всех карт в Hand.gd

	# 3. Добераем новую карту
	var new_card_data = deck.draw_card()
	if new_card_data != null:
		hand.add_card(new_card_data)
		
	# 4. Сообщаем main.gd, что счетчик колоды нужно обновить
	emit_signal("deck_updated") # <--- Нужно создать этот сигнал в CardManager.gd
	
func handle_rotation_request(clockwise: bool):
	if selected_card == null:
		return

	if clockwise:
		selected_card.rotate_90()
	else:
		selected_card.rotate_270()

	# Оповещаем main.gd и UI о том, что карта изменилась
	card_rotated.emit(selected_card)
	
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

func add_cards(count: int):
	if is_instance_valid(deck):
		return deck.add_cards(count)

func add_cards_from_data(cards_data: Array):
	deck.add_cards_from_data(cards_data)
	
func draw_card():
	# CardManager — единственный, кто знает о существовании deck
	return deck.draw_card()
	
func get_deck_size() -> int:
	return deck.cards.size()

func get_selected_card() -> Card:
	# CardManager — единственный источник истины для этой переменной
	return selected_card
