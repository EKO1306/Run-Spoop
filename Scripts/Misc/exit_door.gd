extends Area2D

@export var nextLevel : PackedScene

func _physics_process(_delta: float) -> void:
	for node in get_overlapping_areas():
		if node.is_in_group("Player"):
			get_tree().get_current_scene().changeScene(nextLevel)
