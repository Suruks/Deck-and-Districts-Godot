extends Node
class_name Deck

var cards = []

func init_deck(count: int = 12):
	cards.clear()
	for i in range(count):
		cards.append(Card.generate_data("random"))

func draw_card():
	if cards.size() == 0:
		return null
	return cards.pop_front()
	
func add_cards(count: int = 1):
	for i in range(count):
		var new_card = Card.generate_data("random")
		var pos = randi() % (cards.size() + 1) # случайная позиция от 0 до размера колоды
		cards.insert(pos, new_card)
		
	
