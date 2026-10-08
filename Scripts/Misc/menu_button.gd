extends Button

func _pressed() -> void:
	get_tree().get_current_scene().changeScene(preload("res://Scenes/Levels/level_1_0.tscn"))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("TESTEnableCheats"):
		get_tree().get_current_scene().changeScene(preload("res://Scenes/level_test.tscn"))
