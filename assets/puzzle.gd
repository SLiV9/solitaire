extends GridContainer

onready var _quest_zone = get_tree().get_root().find_node("QuestZone", true, false)
onready var _discard_pile = get_tree().get_root().find_node("DiscardPile", true, false)

var opened = []


func _ready():
	randomize()
	var keys = ["monday", "monday", "tuesday", "tuesday", "sunday", "sunday"]
	var phrases = ["What day is it today?", "MONDAY", "TUESDAY", "Tomorrow", "SUNDAY", "Yesterday"]
	var indices = range(6)
	indices.shuffle()
	var delay = 0.2
	for i in indices:
		var card = $ResourcePreloader.get_resource("card").instance()
		card.pair_name = keys[i]
		card.phrase = phrases[i]
		if i == 0:
			card.name = "QuestionCard"
		else:
			card.name = "Card" + str(i)
		card.connect("opened", self, "_on_Card_opened")
		card.call_deferred("place", delay)
		delay += 0.2
		self.add_child(card)


func _on_Card_opened(new_card):
	if new_card.name == "QuestionCard":
		new_card.call_deferred("fly_to", _quest_zone, 0.5, 1.1, false)
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
			var delay = 0.3
			var duration = 0.8
			for opened_card in opened:
				opened_card.fly_to(_discard_pile, delay, duration, true)
				delay += 0.3
				duration += 0.4
			opened = []
