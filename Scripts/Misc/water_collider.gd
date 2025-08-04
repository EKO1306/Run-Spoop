extends Area2D

@export var pushDirection = Vector2.RIGHT
@export var pushSpeed = 150

func _physics_process(delta: float) -> void:
	for node in get_overlapping_bodies():
		if node.is_in_group("Player"):
			node.velocity += pushDirection * pushSpeed * delta * 5
		if node.is_in_group("EnemyCollider"):
			node.velocity += pushDirection * pushSpeed * delta * node.knockbackValue
