extends Area2D

@export var partSize := 256.0

func _ready() -> void:
	$CollisionShape2D.scale.y = partSize
	$Sprite.size.y = partSize
	$Sprite.position.y = -partSize
