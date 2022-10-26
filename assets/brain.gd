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

var _entities = []
var _num_pairs = 0


func _ready():
	data = ConfigFile.new()
	var err = data.load(PATHS[Progress.current_day_number - 1])
	if err != OK:
		printerr("Failed to load dialogue_tree")
	for section_name in data.get_sections():
		if section_name.begins_with("pairs."):
			_num_pairs += 1
	if OS.has_feature("editor"):
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


func open_card(card: Card):
	# TODO
	var phrase_or_face = "Yes!"
	card.imbue("", phrase_or_face)

func open_answer_card(card: Card):
	card.imbue("answer", self.answer())

func close_card(card: Card):
	pass

func lock_card(card: Card):
	pass
