extends MarginContainer


func _ready():
	randomize()
	if Progress.furthest_day_number_completed > 0:
		find_node("StartButton").visible = false
		find_node("StartButton1").visible = true
		find_node("StartButton2").visible = true
		find_node("StartButton3").visible = true
		find_node("StartButton4").visible = true
		find_node("StartButton5").visible = true
	$TitleTheme.play()

func goto_day(day_number):
	Progress.current_day_number = day_number
	var err = get_tree().change_scene("res://assets/gameplay.tscn")
	if err != OK:
		pass

func _on_StartButton_pressed():
	_on_StartButton1_pressed()


func _on_StartButton1_pressed():
	goto_day(1)


func _on_StartButton2_pressed():
	goto_day(2)


func _on_StartButton3_pressed():
	goto_day(3)


func _on_StartButton4_pressed():
	goto_day(4)


func _on_StartButton5_pressed():
	goto_day(5)
