extends Node


export var current_day_number = 1
export var furthest_day_number_completed = 0


func _ready():
	var save_game = ConfigFile.new()
	save_game.load("user://savegame.toml")
	self.furthest_day_number_completed = save_game.get_value("progress",
		"furthest_day_number_completed", 0)


func complete_current_day():
	if current_day_number > furthest_day_number_completed:
		furthest_day_number_completed = current_day_number
	var save_game = ConfigFile.new()
	save_game.set_value("progress", "furthest_day_number_completed",
		self.furthest_day_number_completed)
	save_game.save("user://savegame.toml")
