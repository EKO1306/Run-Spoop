extends Node2D

var spawnedEnemy : Node2D

func _ready() -> void:
	$AnimationPlayer.play("Spawn")

func spawnEnemy() -> void:
	spawnedEnemy.spawn()
