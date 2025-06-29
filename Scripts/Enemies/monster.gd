extends PathFollow2D

@export var speed = 75
@onready var nodePlayer = get_tree().get_current_scene().get_node("Player")

func _process(delta: float) -> void:
	var distanceRatio = global_position.distance_to(nodePlayer.global_position)
	if distanceRatio < 128:
		nodePlayer.momentumValue -= delta * 50 * (distanceRatio / 128)
		if nodePlayer.momentumValue <= 0:
			get_tree().quit()
			return
		if distanceRatio < 64:
			get_tree().quit()
			return
	
	distanceRatio = clamp(distanceRatio / 256, 0.5, 4.0)
	
	progress += delta * speed * distanceRatio
