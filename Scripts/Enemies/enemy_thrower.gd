extends "enemy_base.gd"

@export var rangedAttackCooldown = 2.0
@onready var attackCooldown = 0
@export var rangedAttackAnimDelay = 0.0
@export var hitRangedAttackDelay = 0.0
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
	if attackCooldown <= rangedAttackAnimDelay:
		playAnim("Throw")
	if attackCooldown <= 0:
		attackCooldown += rangedAttackCooldown
		onThrow()

func onThrow():
	var thrownProjectile = preload("res://Nodes/Projectiles/Enemy/enemy_projectile_petal.tscn").instantiate()
	thrownProjectile.global_position = global_position + (global_position.direction_to(nodePlayer.global_position) * 24)
	thrownProjectile.direction = global_position.direction_to(nodePlayer.global_position)
	get_tree().get_current_scene().main.add_child(thrownProjectile)

func postHit(damage, projectile = null):
	attackCooldown += hitRangedAttackDelay

func canAttack():
	if not canSeePlayer:
		return false
	return true
