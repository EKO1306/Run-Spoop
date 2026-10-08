extends "object_base.gd"

@export var closed := false

func _ready() -> void:
	activate(closed, true)

func trigger(wave = -1, arena = null) -> bool:
	activate(not closed)
	if wave >= 0:
		arena.triggerComplete(wave)
	return true

func activate(on : bool, instant := false) -> void:
	closed = on
	if not instant:
		if get_node("DoorSound") != null:
			$DoorSound.play()
	if instant:
		$AnimationPlayer.speed_scale = 1000.0
	else:
		$AnimationPlayer.speed_scale = 1.0
	if closed:
		$AnimationPlayer.play("close")
	else:
		$AnimationPlayer.play("open")
