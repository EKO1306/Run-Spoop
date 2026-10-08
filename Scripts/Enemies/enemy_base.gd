extends CharacterBody2D

@export_category("Basic Stats")
@export var maxHealth : int
@onready var statHealth = maxHealth
@export var contactDamage : float
@export var knockbackValue : float
@export var rotateToPlayer = true
@export_enum("Small", "Medium", "Large") var spawnSize : int

@export_subgroup("Death Fling")
@export var deathFlungEnemy : String
@export var deathMomentum : int

@onready var nodePlayer = get_tree().get_current_scene().main.get_node("Player")
@onready var nodeSprite = $AnimatedSprite2D
@onready var nodeAnimPlayer = $AnimationPlayer

var alive := true
var deathTimer := 0.0
var spawning := false
var arenaSource : Node2D
var waveSource : int

var random = RandomNumberGenerator.new()

func _ready() -> void:
	if not visible:
		process_mode = Node.PROCESS_MODE_DISABLED

func trigger(waveNo : int, arena : Node2D) -> bool:
	if spawning:
		return false
	var spawnEffect
	if spawnSize == 0:
		spawnEffect = preload("res://Nodes/Enemies/Misc/enemy_spawn_small.tscn")
	elif spawnSize == 1:
		spawnEffect = preload("res://Nodes/Enemies/Misc/enemy_spawn_medium.tscn")
	else:
		spawnEffect = preload("res://Nodes/Enemies/Misc/enemy_spawn_medium.tscn")
	spawnEffect = spawnEffect.instantiate()
	spawnEffect.global_position = global_position
	spawnEffect.spawnedEnemy = self
	get_tree().current_scene.main.add_child(spawnEffect)
	waveSource = waveNo
	arenaSource = arena
	return true

func spawn() -> void:
	show()
	process_mode = Node.PROCESS_MODE_INHERIT

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
	rotToPlayer(delta)
	for node in $CollisionArea.get_overlapping_areas():
		if node.is_in_group("Player"):
			contactAttack()
	postPhysics(delta)
	moveSlide(delta)

func contactAttack() -> void:
	if nodePlayer.onHit(contactDamage, self):
		playAnim("Attack", true, true)

func rotToPlayer(_delta):
	if rotateToPlayer:
		rotation = global_position.angle_to_point(nodePlayer.global_position)
	else:
		rotation = 0.0
		if global_position.x > nodePlayer.global_position.x:
			nodeSprite.scale.x = -1
		else:
			nodeSprite.scale.x = 1

func moveSlide(_delta):
	velocity *= 0.7
	move_and_slide()

func prePhysics(_delta):
	pass

func postPhysics(_delta):
	pass

func onHit(damage, projectile = null):
	if not alive:
		return false
	calcHit(damage, projectile)
	return true

func calcHit(damage, projectile = null):
	statHealth -= damage
	playAnim("Hurt",true, true)
	$SoundHurt.play()
	if projectile != null:
		velocity += (global_position.direction_to(projectile.global_position) * -knockbackValue) / get_physics_process_delta_time()
	if statHealth <= 0:
		onDeath(projectile)
	postHit(damage, projectile)

func postHit(_damage, _projectile = null):
	pass

func onDeath(projectile = null):
	if projectile != null:
		if projectile.isPlayerAttack:
			nodePlayer.changeMomentum(deathMomentum)
			var flungEnemy = load("res://Nodes/Projectiles/Flung/" + deathFlungEnemy + ".tscn").instantiate()
			flungEnemy.global_position = global_position
			if projectile != null:
				flungEnemy.direction = projectile.direction
			get_tree().get_current_scene().main.add_child(flungEnemy)
	nodeAnimPlayer.play("Dead")
	alive = false
	deathTimer = 1.0
	if arenaSource != null:
		arenaSource.triggerComplete(waveSource)
	$CollisionArea.monitoring = false
	$CollisionArea.monitorable = false
	$CollisionShape2D.disabled = true


func _on_animated_sprite_2d_animation_finished() -> void:
	playAnim("Idle", false, true)

func playAnim(animationName, force = false, addSuffix = false):
	if addSuffix:
		animationName = applySuffixes(animationName)
	
	if nodeSprite.animation != animationName or force:
		nodeSprite.play(animationName)

func applySuffixes(animationName) -> String:
	return animationName
