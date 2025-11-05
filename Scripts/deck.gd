extends Node
class_name Deck

var cards = []

var max_cards = 30
var cards_to_extension = 0

func init_deck(count: int):
	cards.clear()
	for i in range(count):
		cards.append(Card.generate_data("random"))

func draw_card():
	if cards.size() == 0:
		return null
	return cards.pop_front()
	
func add_cards(count: int = 1) -> int:
	var added = 0
	for i in range(count): # for each card
		if cards.size() >= max_cards:
			cards_to_extension += 1
			MyLogger.log("Карта сожжена! До увеличения предела карт: " + str(3 - cards_to_extension))
			if cards_to_extension >= 3: # увеличение максимума
				cards_to_extension = 0
				max_cards += 1
			break
		var new_card = Card.generate_data("random")
		var pos = randi() % (cards.size() + 1)
		cards.insert(pos, new_card)
		added += 1
	return added

#при замешивании карт из руки
func add_cards_from_data(cards_data: Array):
	for card_data in cards_data:
		var pos = randi() % (cards.size() + 1)
		cards.insert(pos, card_data)
