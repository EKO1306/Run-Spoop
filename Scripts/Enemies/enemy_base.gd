extends CharacterBody2D

@export var maxHealth : int
@onready var statHealth = maxHealth
@export var contactDamage : float
@export var deathMomentum : int
@export var deathFlungEnemy : String
@export var knockbackValue : float
@export var rotateToPlayer = true

@onready var nodePlayer = get_tree().get_current_scene().main.get_node("Player")
@onready var nodeSprite = $AnimatedSprite2D

var alive = true
var deathTimer = 0

var random = RandomNumberGenerator.new()

func _process(delta: float) -> void:
	if not alive:
		deathTimer -= delta
		if deathTimer <= 0:
			queue_free()
		return
	postProcess(delta)

func postProcess(_delta):
	pass

func _physics_process(delta: float) -> void:
	if not alive:
		return
	prePhysics(delta)
	if rotateToPlayer:
		rotation = global_position.angle_to_point(nodePlayer.global_position)
	else:
		if global_position.x > nodePlayer.global_position.x:
			nodeSprite.scale.x = -1
		else:
			nodeSprite.scale.x = 1
	for node in $CollisionArea.get_overlapping_areas():
		if node.is_in_group("Player"):
			if node.get_parent().onHit(contactDamage, self):
				playAnim("Attack",true)
	postPhysics(delta)
	velocity *= 0.7
	move_and_slide()

func prePhysics(_delta):
	pass

func postPhysics(_delta):
	pass

func onHit(damage, projectile = null):
	if not alive:
		return false
	statHealth -= damage
	playAnim("Hurt",true)
	$SoundHurt.play()
	if projectile != null:
		velocity += (global_position.direction_to(projectile.global_position) * -knockbackValue) / get_physics_process_delta_time()
	if statHealth <= 0:
		onDeath(projectile)
	postHit(damage, projectile)
	return true

func postHit(damage, projectile = null):
	pass

func onDeath(projectile = null):
	if projectile != null:
		if projectile.isPlayerAttack:
			nodePlayer.addMomentum(deathMomentum)
			var flungEnemy = load("res://Nodes/Projectiles/Flung/" + deathFlungEnemy + ".tscn").instantiate()
			flungEnemy.global_position = global_position
			if projectile != null:
				flungEnemy.direction = projectile.direction
			get_tree().get_current_scene().main.add_child(flungEnemy)
	$AnimationPlayer.play("Dead")
	alive = false
	deathTimer = 1.0
	$CollisionArea.monitoring = false
	$CollisionArea.monitorable = false
	$CollisionShape2D.disabled = true


func _on_animated_sprite_2d_animation_finished() -> void:
	playAnim("Idle")

func playAnim(animationName, force = false):
	if nodeSprite.animation != animationName or force:
		nodeSprite.play(animationName)
