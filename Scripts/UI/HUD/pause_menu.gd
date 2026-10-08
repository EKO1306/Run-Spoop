extends Panel

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pauseGame"):
		get_tree().paused = not get_tree().paused
	
	visible = get_tree().paused


func _on_resume_button_pressed() -> void:
	get_tree().paused = false


func _on_restart_pressed() -> void:
	get_tree().current_scene.restartScene()


func _on_quit_pressed() -> void:
	get_tree().get_current_scene().changeScene(load("res://Scenes/menu.tscn"))
