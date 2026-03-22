extends "enemy_base.gd"

@export var rangedAttackCooldown = 2.0
@export var startingRangedOffset = 0.0
@onready var attackCooldown = startingRangedOffset
@export var activationDistance = 128.0
@export var deactivationDistance = 256.0

var activated = false
var canSeePlayer

func postPhysics(delta):
	$RayCast2D.target_position = to_local(nodePlayer.global_position)
	canSeePlayer = $RayCast2D.get_collider() == null
	
	if not canAttack():
		attackCooldown = startingRangedOffset
		return
	attackCooldown -= delta
	if attackCooldown <= 0:
		attackCooldown += rangedAttackCooldown
		nodeAnimPlayer.play("Throw")

func onThrow():
	var thrownProjectile = preload("res://Nodes/Projectiles/Enemy/enemy_projectile_petal.tscn").instantiate()
	thrownProjectile.global_position = global_position# + (global_position.direction_to(nodePlayer.global_position) * 24)
	thrownProjectile.direction = global_position.direction_to(nodePlayer.global_position)
	get_tree().get_current_scene().main.add_child(thrownProjectile)

func postHit(_damage, _projectile = null):
	if nodeAnimPlayer.current_animation != "Dead":
		nodeAnimPlayer.play("RESET")

func canAttack():
	return canSeePlayer
