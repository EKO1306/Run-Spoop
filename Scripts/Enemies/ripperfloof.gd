extends "res://Scripts/Enemies/enemy_mover.gd"

@export var chargeAccel = 1800.0
@export var chargeDuration = 1.5

var chargeWindupTimer = 0.0
var chargeCooldown = 0.0
var charging = false
var fullCharge = false
var chargeTimer := 0.0
var accelTimer := 0.0
var chargeAngle : Vector2
@export var lightImmune := false

@onready var nodeRaycast = $RayCast2D as RayCast2D

func move(delta) -> void:
	calcStartCharge(delta)
	if charging:
		if fullCharge:
			charge(delta)
		return
	
	navAgentUpdateTimer -= delta
	if navAgentUpdateTimer <= 0:
		navAgentUpdateTimer += 0.5
		nodeNavAgent.target_position = nodePlayer.global_position
		targetPos = nodeNavAgent.get_next_path_position()
	velocity = velocity.lerp(maxSpeed * global_position.direction_to(targetPos),delta * moveSpeed)

func calcStartCharge(delta) -> void:
	if charging:
		return
	
	if chargeCooldown > 0.0:
		chargeCooldown -= delta
		return
	
	if nodeRaycast.is_colliding():
		if nodeRaycast.get_collider().is_in_group("Player"):
			chargeWindupTimer += delta
			if chargeWindupTimer >= 0.25:
				nodeAnimPlayer.play("startCharge")
				velocity = (global_position.direction_to(nodePlayer.global_position) * -4.0) / get_physics_process_delta_time()
				charging = true
			return
	chargeWindupTimer = 0.0

func charge(delta) -> void:
	chargeTimer += delta
	if chargeTimer >= chargeDuration:
		nodeAnimPlayer.play("endCharge")
		return
	accelTimer += delta
	if chargeTimer < 1.25:
		velocity += chargeAccel * chargeAngle * delta * accelTimer

func moveSlide(_delta):
	if charging:
		velocity *= 0.9
	else:
		velocity *= 0.8
	var collided = move_and_slide()
	if collided:
		if charging:
			bounceOffHit(get_last_slide_collision().get_normal())

func bounceOffHit(normal : Vector2) -> void:
	velocity = velocity.reflect(normal.rotated(deg_to_rad(90.0)))
	chargeAngle = velocity.normalized()
	accelTimer = min(accelTimer, 0.5)
	#if chargeTimer > 0.1:
	#	nodeAnimPlayer.play("endCharge")
	$SoundBladeImpact.volume_db = -5.0
	$SoundBladeImpact.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	if fullCharge:
		playAnim("Spin", false, true)
	else:
		playAnim("Idle", false, true)

func startFullCharge() -> void:
	fullCharge = true
	chargeTimer = 0.0
	chargeAngle = global_position.direction_to(nodePlayer.global_position)
	lightImmune = true
	playAnim("Spin")

func endFullCharge() -> void:
	fullCharge = false
	chargeTimer = 0.0
	chargeWindupTimer = 0.0

func endCharge() -> void:
	charging = false
	chargeWindupTimer = 0.0
	chargeCooldown = 3.0
	lightImmune = false

func contactAttack() -> void:
	if charging:
		if nodePlayer.onHit(contactDamage * 1.5, self):
			bounceOffHit(nodePlayer.global_position.direction_to(global_position))
	else:
		if nodePlayer.onHit(contactDamage, self):
			playAnim("Attack", true, true)

func onHit(damage, projectile = null):
	if not alive:
		return false
	if lightImmune:
		if projectile != null:
			if not projectile.heavyProjectile:
				velocity = (global_position.direction_to(projectile.global_position) * -knockbackValue) / get_physics_process_delta_time()
				chargeAngle = velocity.normalized()
				$SoundBladeImpact.volume_db = 0.0
				$SoundBladeImpact.play()
				chargeTimer = 0.0
				return true
	calcHit(damage, projectile)
	return true
