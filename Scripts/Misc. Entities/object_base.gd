extends StaticBody2D

func parentToMain() -> void:
	call_deferred("reparent", get_tree().current_scene.main)
