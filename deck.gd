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
