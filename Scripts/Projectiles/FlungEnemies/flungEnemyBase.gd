extends "../Player/projectlePlayerBase.gd"

func _process(delta: float) -> void:
	if alive:
		rotation += delta * 20
