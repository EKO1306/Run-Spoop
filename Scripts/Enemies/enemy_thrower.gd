extends "enemy_base.gd"

@export var rangedAttackCooldown = 2
@onready var attackCooldown = 0
@export var activationDistance = 128.0
@export var deactivationDistance = 256.0

var activated = false
var canSeePlayer

func postPhysics(delta):
	$RayCast2D.target_position = to_local(nodePlayer.global_position)
	if $RayCast2D.get_collider() == null:
		canSeePlayer = true
	else:
		canSeePlayer = false
	if not canAttack():
		attackCooldown = 0
		return
	attackCooldown -= delta
	if attackCooldown <= 0:
		attackCooldown += rangedAttackCooldown
		onThrow()

func onThrow():
	nodeSprite.play("Throw")
	var thrownProjectile = preload("res://Nodes/Projectiles/Player/player_projectile_kick.tscn").instantiate()
	thrownProjectile.global_position = global_position + (global_position.direction_to(nodePlayer.global_position) * 24)
	thrownProjectile.direction = global_position.direction_to(nodePlayer.global_position)
	get_tree().get_current_scene().add_child(thrownProjectile)
	print("YAh")

func canAttack():
	if not canSeePlayer:
		return false
	return true
