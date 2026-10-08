extends "enemy_mover.gd"

@export var lungeFullDistance = 64.0
@export var lungeMinDistance = 48.0
@export var lungeMaxSpeed = 128.0
@export var lungeMoveSpeed = 4.0
@export var lungeCooldownDuration = 4.0
@export var lungeStunDuration = 1.0

var lungeCooldown := 0.0
var remainingLungeDistance := 0.0
var lungeDir : Vector2

var inWater := true

@onready var nodeWaterDetector := $WaterDetector as ShapeCast2D

func rotToPlayer(_delta):
	if rotateToPlayer:
		nodeSprite.scale.x = 1.0
		if remainingLungeDistance > 0.0:
			rotation = Vector2.ZERO.angle_to_point(lungeDir)
		else:
			rotation = global_position.angle_to_point(nodePlayer.global_position)
	else:
		rotation = 0.0
		if global_position.x > nodePlayer.global_position.x:
			nodeSprite.scale.x = -1.0
		else:
			nodeSprite.scale.x = 1.0

func postPhysics(delta):
	
	var wasInWater = inWater
	inWater = nodeWaterDetector.is_colliding()
	if inWater != wasInWater:
		if remainingLungeDistance <= 0.0:
			playAnim("Idle", false, true)
	
	if lungeCooldown > 0.0:
		lungeCooldown -= delta
	
	if not canMove():
		remove_from_group("NotWaterPushable")
		return
	
	add_to_group("NotWaterPushable")
	
	if remainingLungeDistance > 0.0:
		$GPUParticles2D.emitting = true
		velocity = velocity.lerp(lungeMaxSpeed * lungeDir,delta * lungeMoveSpeed)
		remainingLungeDistance -= velocity.length() * delta
		if remainingLungeDistance <= 0:
			cooldownLunge()
	else:
		set_collision_mask_value(4,true)
		if inWater:
			$GPUParticles2D.emitting = false
			if lungeCooldown <= 0.0:
				if nodePlayer.global_position.distance_to(global_position) <= lungeMinDistance:
					remainingLungeDistance = lungeFullDistance
					$SplashParticles.global_position = global_position
					$SplashParticles.emitting = true
					lungeDir = global_position.direction_to(nodePlayer.global_position)
					set_collision_mask_value(4,false)
					$SoundLunge.play()
					playAnim("Idle", true, true)
					return
			calcMovement(delta)
		else:
			$GPUParticles2D.emitting = true

func cooldownLunge():
	remainingLungeDistance = 0.0
	playAnim("Idle", true, true)
	lungeCooldown = lungeCooldownDuration

func moveSlide(_delta):
	if remainingLungeDistance > 0.0:
		velocity *= 0.9
	else:
		velocity *= 0.7
	var didCollide = move_and_slide()
	if didCollide:
		if remainingLungeDistance > 0.0:
			cooldownLunge()
			velocity = -velocity

func canMove() -> bool:
	return lungeCooldown <= lungeCooldownDuration - lungeStunDuration
	
func playAnim(animationName, force = false, addSuffix = false):
	if addSuffix:
		animationName = applySuffixes(animationName)
	
	if animationName == "Idle_Flop":
		$AnimationPlayer.play("Flop")
	else:
		$AnimationPlayer.play("Idle")
	
	if nodeSprite.animation != animationName or force:
		nodeSprite.play(animationName)

func applySuffixes(animationName) -> String:
	if remainingLungeDistance > 0.0:
		animationName += "_Lunge"
	else:
		if inWater:
			rotateToPlayer = true
		else:
			animationName += "_Flop"
			rotateToPlayer = false
	return animationName
