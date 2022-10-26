class_name Brain
extends Node

const PATHS = [
	"res://assets/puzzles/monday.toml",
	"res://assets/puzzles/tuesday.toml",
	"res://assets/puzzles/wednesday.toml",
	"res://assets/puzzles/thursday.toml",
	"res://assets/puzzles/friday.toml",
]

var data: ConfigFile

var _num_pairs = 0
var _entities = []
var _available_entities = []
var _opened_entities = []
var _locked_entities = []
var _locked_locations = []

var _memories = []


func _ready():
	data = ConfigFile.new()
	var err = data.load(PATHS[Progress.current_day_number - 1])
	if err != OK:
		printerr("Failed to load dialogue_tree")
	for section_name in data.get_sections():
		if section_name.begins_with("pairs."):
			_num_pairs += 1
			var key = section_name.trim_prefix("pairs.")
			_entities.append(key + "?")
			_entities.append(key + "!")
		elif section_name == "answer":
			_entities.append(section_name)
	_available_entities = [] + _entities
	if OS.has_feature("editor"):
		print("entities: ", _entities)
		run_test()


func run_test():
	pass


func num_cards():
	var num_rows = data.get_value("puzzle", "num_rows")
	var num_cols = data.get_value("puzzle", "num_cols")
	return num_rows * num_cols

func num_pairs():
	return _num_pairs

func includes_question():
	return data.get_value("puzzle", "includes_question")

func introduction():
	return data.get_value("puzzle", "introduction")

func conclusion():
	return data.get_value("puzzle", "conclusion")

func question():
	return data.get_value("question", "phrase")

func answer():
	return data.get_value("answer", "phrase")


func _pick_entity(picked_location):
	var impossible_entities = []
	for memory in _memories:
		match memory:
			[picked_location, "contains_entity", var entity_name]:
				return entity_name
			[_, "contains_entity", var entity_name]:
				impossible_entities.append(entity_name)
	var possible_entities = []
	for entity_name in _available_entities:
		if not impossible_entities.has(entity_name):
			possible_entities.append(entity_name)
	return possible_entities[randi() % possible_entities.size()]


func _push_memory(left, operation, right):
	_memories.push_front([left, operation, right])


func open_card(card: Card):
	var entity_name = _pick_entity(card.location_number)
	_available_entities.remove(_available_entities.find(entity_name))
	_opened_entities.append(entity_name)
	_push_memory(card.location_number, "contains_entity", entity_name)
	card.entity_name = entity_name
	var pair_name = entity_name.rstrip("?!")
	card.pair_name = pair_name
	if entity_name.ends_with("?"):
		var face = data.get_value("pairs." + pair_name, "face")
		card.set_phrase(face)
	elif entity_name.ends_with("!"):
		var face = data.get_value("pairs." + pair_name, "phrase")
		card.set_phrase(face)
	else:
		var phrase = data.get_value(entity_name, "phrase")
		card.set_phrase(phrase)

func open_answer_card(card: Card):
	card.set_phrase(self.answer())

func open_question_card(card: Card):
	_locked_locations.append(card.location_number)
	card.set_phrase(self.question())

func close_card(card: Card):
	var entity_name = card.entity_name
	_opened_entities.remove(_opened_entities.find(entity_name))
	_available_entities.append(entity_name)

func lock_card(card: Card):
	var entity_name = card.entity_name
	_opened_entities.remove(_opened_entities.find(entity_name))
	_locked_entities.append(entity_name)
	_locked_locations.append(card.location_number)
