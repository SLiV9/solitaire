extends Control

onready var _quest_zone = find_node("QuestZone")
onready var _discard_pile = find_node("DiscardPile")
onready var _grid = find_node("Grid")
onready var _anecdote = find_node("Anecdote")
onready var _back_button = find_node("BackButton")

const PUZZLE_KEYS = [
	["monday", "monday", "tuesday", "tuesday", "sunday", "sunday"]
]
const PUZZLE_PHRASES = [
	["What day is it today?", "MONDAY", "TUESDAY", "Tomorrow", "SUNDAY", "Yesterday"]
]

var opened = []
var num_pairs_remaining = 0


func _ready():
	var keys = PUZZLE_KEYS[Progress.current_day_number - 1]
	var phrases = PUZZLE_PHRASES[Progress.current_day_number - 1]
	var num_cards = keys.size()
	num_pairs_remaining = keys.size() / 2 - 1
	var indices = range(num_cards)
	indices.shuffle()
	var delay = 0.2 * num_cards
	var reveal_delay = delay + 1.5
	for i in indices:
		var card = $ResourcePreloader.get_resource("card").instance()
		card.pair_name = keys[i]
		card.phrase = phrases[i]
		if i == 0 and Progress.current_day_number != 5:
			card.name = "QuestionCard"
			card.call_deferred("reveal_after", reveal_delay)
			card.connect("revealed", self, "_on_Card_revealed")
		else:
			card.name = "Card" + str(i)
			card.call_deferred("enable_after", reveal_delay)
		card.connect("opened", self, "_on_Card_opened")
		card.call_deferred("place", delay)
		delay -= 0.2
		_grid.add_child(card)


func _on_Card_revealed(card):
	card.call_deferred("set", "pressed", true)


func _on_Card_opened(new_card):
	if new_card.name == "QuestionCard":
		new_card.fly_to(_quest_zone, 0.5, 1.1, false)
		return
	if opened.size() >= 2:
		var delay = 0.1
		for opened_card in opened:
			opened_card.flip_back(delay)
			delay += 0.2
		opened = []
	opened.append(new_card)
	if opened.size() >= 2:
		var is_pair = opened[0].pair_name == opened[1].pair_name
		if is_pair:
			num_pairs_remaining -= 1
			var delay = 0.3
			var duration = 0.8
			for opened_card in opened:
				opened_card.fly_to(_discard_pile, delay, duration, true)
				delay += 0.3
				duration += 0.4
			opened = []
	elif num_pairs_remaining == 0:
		Progress.complete_current_day()
		_anecdote.text = "That's it."
		_back_button.text = "Continue"



func _on_BackButton_pressed():
	var err = get_tree().change_scene("res://assets/titlescreen.tscn")
	if err != OK:
		pass
