extends Area2D

@export var nextLevel : PackedScene

func _physics_process(_delta: float) -> void:
	for node in get_overlapping_areas():
		if node.is_in_group("Player"):
			GlobalScript.saveTime(get_tree().current_scene.main.name)
			get_tree().get_current_scene().changeScene(nextLevel)

func trigger(wave = -1, arena = null) -> bool:
	$AnimatedSprite2D.play("Open")
	$StaticBody2D/DoorCollision.disabled = true
	if wave >= 0:
		arena.triggerComplete(wave)
	return true
