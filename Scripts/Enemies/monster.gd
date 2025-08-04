extends Path2D

@export var speed = 25
@export var distanceSpeedMultiplier = 1.0
@onready var nodePlayer = get_tree().get_current_scene().main.get_node("Player")
@onready var nodeMonster = $PathFollow2D
@onready var nodeCollider = $PathFollow2D/Monster

func _process(delta: float) -> void:
	var direction = Vector2.from_angle(nodeMonster.rotation)
	var distanceRatio = (nodeMonster.global_position * direction).distance_to(nodePlayer.global_position * direction)
	if distanceRatio < 64:
		print($AudioStreamPlayer.volume_linear)
		nodePlayer.momentumValue -= delta * 50 * (1-(distanceRatio / 64))
		nodePlayer.momentumValue = max(nodePlayer.momentumValue,0)
		$AudioStreamPlayer.volume_linear = 1.5-(distanceRatio / 64)
		#if nodePlayer.momentumValue <= 0:
			#get_tree().quit()
			#return
	else:
		$AudioStreamPlayer.volume_linear = 0
	
	for node in nodeCollider.get_overlapping_areas():
		if node.is_in_group("Player"):
			get_tree().reload_current_scene()
			return
		if node.is_in_group("EnemyCollider"):
			node.get_parent().onDeath()
	
	distanceRatio = max((distanceRatio / 128) ** distanceSpeedMultiplier, 0.5)
	nodeMonster.progress += speed * delta * distanceRatio
	#progress += delta * speed * distanceRatio
