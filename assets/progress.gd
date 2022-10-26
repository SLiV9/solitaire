extends Node


export var current_day_number = 1
export var furthest_day_number_completed = 0


func complete_current_day():
	if current_day_number > furthest_day_number_completed:
		furthest_day_number_completed = current_day_number
