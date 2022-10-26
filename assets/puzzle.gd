extends Control

onready var _quest_zone = find_node("QuestZone")
onready var _discard_pile = find_node("DiscardPile")
onready var _grid = find_node("Grid")
onready var _anecdote = find_node("Anecdote")
onready var _back_button = find_node("BackButton")

var opened = []
var num_pairs_remaining = 0


func _ready():
	_grid.columns = $Brain.num_cols()
	var num_cards = $Brain.num_cards()
	num_pairs_remaining = $Brain.num_pairs()
	var indices = range(num_cards)
	indices.shuffle()
	var delay = 1.0 + 0.2 * num_cards
	var reveal_delay = delay + 0.5
	for i in indices:
		var card = $ResourcePreloader.get_resource("card").instance()
		card.location_number = i + 1
		if i == 0 and $Brain.includes_question():
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
	_anecdote.text = $Brain.introduction()


func _on_Card_revealed(card):
	$Brain.open_question_card(card)
	card.call_deferred("set", "pressed", true)


func _on_Card_opened(new_card):
	if new_card.name == "QuestionCard":
		new_card.fly_to(_quest_zone, 0.5, 1.1, false)
		return
	if num_pairs_remaining == 0:
		$Brain.open_answer_card(new_card)
	else:
		$Brain.open_card(new_card)
	if opened.size() >= 2:
		var delay = 0.1
		for opened_card in opened:
			$Brain.close_card(opened_card)
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
				$Brain.lock_card(opened_card)
				opened_card.fly_to(_discard_pile, delay, duration, true)
				delay += 0.3
				duration += 0.4
			opened = []
	elif num_pairs_remaining == 0:
		Progress.complete_current_day()
		_anecdote.text = $Brain.conclusion()
		_back_button.text = "Continue"



func _on_BackButton_pressed():
	var err = get_tree().change_scene("res://assets/titlescreen.tscn")
	if err != OK:
		pass
