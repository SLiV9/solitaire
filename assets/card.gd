class_name Card
extends TextureButton

signal opened(card)
signal revealed(card)

export var location_number = 0
export var entity_name = ""
export var pair_name = ""
export var phrase = "Huh?!"

onready var _label = $Front/MarginContainer/VBoxContainer/RichTextLabel


func _ready():
	self.disabled = true
	$Back.visible = false
	_label.bbcode_text = "[center]%s[/center]" % [self.phrase]


func set_phrase(new_phrase):
	self.phrase = new_phrase
	_label.bbcode_text = "[center]%s[/center]" % [new_phrase]


func _on_Card_toggled(button_pressed):
	if button_pressed:
		$AnimationPlayer.play("flip_to_front")
		emit_signal("opened", self)
		var sfxs = [$Sfx/Flip1, $Sfx/Flip2, $Sfx/Flip3]
		var sfx = sfxs[randi() % sfxs.size()]
		sfx.play()


func place(delay):
	var from = Vector2(self.get_parent().rect_global_position.x, -8000)
	var to = self.rect_global_position
	$Tween.interpolate_property(self, "rect_global_position", from, from,
		0.01, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "rect_global_position", from, to,
		0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay)
	$Tween.start()
	$PlaceTimer.wait_time = delay
	$PlaceTimer.start()


func fly_to(other_node, delay, duration, with_angle):
	var current_position = self.rect_global_position
	var hole = Control.new()
	hole.rect_min_size = self.rect_min_size
	get_parent().add_child_below_node(self, hole)
	get_parent().remove_child(self)
	other_node.get_node("Contents").add_child(self)
	$Tween.interpolate_property(self, "rect_global_position",
		current_position, current_position,
		0.01, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "rect_global_position",
		current_position, other_node.rect_global_position,
		duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay)
	if with_angle:
		var current_rotation = 0
		var target_rotation = rand_range(-40.0, 40.0)
		$Tween.interpolate_property($Front, "rect_rotation",
			current_rotation, target_rotation,
			duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay)
	$Tween.start()
	$FlyTimer.wait_time = delay + 0.05
	$FlyTimer.start()


func flip_back(delay):
	self.pressed = false
	$FlipBackTimer.wait_time = delay
	$FlipBackTimer.start()


func _on_FlipBackTimer_timeout():
	$AnimationPlayer.play_backwards("flip_to_front")
	$Sfx/FlipBack.play()


func _on_FlyTimer_timeout():
	var sfxs = [$Sfx/Fly1, $Sfx/Fly2, $Sfx/Fly3]
	var sfx = sfxs[randi() % sfxs.size()]
	sfx.play()


func _on_PlaceTimer_timeout():
	$Back.visible = true
	var sfxs = [$Sfx/Place1]
	var sfx = sfxs[randi() % sfxs.size()]
	sfx.play()


func reveal_after(delay):
	$RevealTimer.wait_time = delay
	$RevealTimer.start()


func enable_after(delay):
	$EnableTimer.wait_time = delay
	$EnableTimer.start()


func _on_RevealTimer_timeout():
	self.disabled = false
	emit_signal("revealed", self)


func _on_EnableTimer_timeout():
	self.disabled = false
