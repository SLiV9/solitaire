extends TextureButton

signal opened(card)

export var pair_name = ""
export var phrase = ""

onready var _label = $Front/MarginContainer/VBoxContainer/RichTextLabel


func _ready():
	_label.bbcode_text = "[center]%s[/center]" % [phrase]


func _on_Card_toggled(button_pressed):
	if button_pressed:
		$AnimationPlayer.play("flip_to_front")
		emit_signal("opened", self)
	else:
		$AnimationPlayer.play_backwards("flip_to_front")


func fly_to(other_node, duration, with_angle):
	var current_position = self.rect_global_position
	var hole = Control.new()
	hole.rect_min_size = self.rect_min_size
	get_parent().add_child_below_node(self, hole)
	get_parent().remove_child(self)
	other_node.add_child(self)
	$Tween.interpolate_property(self, "rect_global_position",
		current_position, other_node.rect_global_position,
		duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	if with_angle:
		var target_rotation = rand_range(-40.0, 40.0)
		$Tween.interpolate_property($Front, "rect_rotation",
			self.rect_rotation, target_rotation,
			duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
