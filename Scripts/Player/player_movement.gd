extends CharacterBody2D

const baseSpeed = 5.0
var maxSpeed = 200
var attackCooldown = 0
var canAction = false
var invunerabilityTimer = 0
var maxPrimaryUses = 3
@onready var primaryUsesRemaining = maxPrimaryUses

var footstepCooldown = 0

var momentumValue = 100
var maxMomentum = 100

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("TESTIncreaseMomentum"):
		momentumValue += 50
		momentumValue = min(momentumValue,maxMomentum)
	if Input.is_action_just_pressed("TESTDecreaseMomentum"):
		momentumValue -= 50
		momentumValue = max(momentumValue,0)
	if Input.is_action_just_pressed("TESTAddBullet"):
		$RevolverClick.play()
		primaryUsesRemaining = min(maxPrimaryUses, primaryUsesRemaining + 1)
	momentumValue -= delta * (momentumValue / maxMomentum) * 15
	invunerabilityTimer -= delta
	if invunerabilityTimer > 0:
		modulate.a = sin(invunerabilityTimer * 10)
	else:
		modulate.a = 1
	$Camera2D.zoom.x = 6 - (((momentumValue / maxMomentum) ** 4) * 2)
	$Camera2D.zoom.y = $Camera2D.zoom.x
	
func addMomentum(momentum):
	momentumValue += momentum * (1 - ((momentumValue / maxMomentum) * 0.5))
	momentumValue = min(momentumValue,maxMomentum)

func onHit(damage, source):
	if invunerabilityTimer <= 0:
		momentumValue -= damage
		momentumValue = max(momentumValue,0.0)
		invunerabilityTimer = 1.0
		velocity += (global_position.direction_to(source.global_position) * -5) / get_physics_process_delta_time()
		$PlayerHurt.play()
		return true

func _physics_process(delta: float) -> void:
	var mousePos = get_global_mouse_position()
	canAction = true
	if attackCooldown > 0:
		attackCooldown -= delta
		canAction = false
	if invunerabilityTimer > 0.5:
		canAction = false
	
	if global_position.x < mousePos.x:
		$Sprite.scale.x = 1
		$Sprite/Revolver.rotation = $Sprite/Revolver.global_position.angle_to_point(mousePos)
	else:
		$Sprite.scale.x = -1
		$Sprite/Revolver.rotation_degrees = 180-rad_to_deg($Sprite/Revolver.global_position.angle_to_point(mousePos))
	if canAction:
		move(delta)
	
	velocity *= 0.7
	if canAction:
		pass
		if Input.is_action_just_pressed("attackPrimary"):
			if primaryUsesRemaining > 0:
				primaryUsesRemaining -= 1
				velocity += (global_position.direction_to(mousePos) * -2.5) / delta
				attackCooldown = 0.2
				$Sprite/Revolver.play("Shoot")
				$RevolverShoot.play()
				var bulletProjectile = preload("res://Nodes/Projectiles/Player/player_projectile_bullet.tscn").instantiate()
				bulletProjectile.global_position = global_position + global_position.direction_to(mousePos) * 4
				bulletProjectile.direction = global_position.direction_to(mousePos)
				get_tree().get_current_scene().add_child(bulletProjectile)
			else:
				$RevolverClick.play()

		if Input.is_action_just_pressed("attackSecondary"):
				velocity += (global_position.direction_to(mousePos) * 5) / delta
				attackCooldown = 0.4
				$Sprite/Player.play("Primary")
				$KickShoot.play()
				var kickProjectile = preload("res://Nodes/Projectiles/Player/player_projectile_kick.tscn").instantiate()
				kickProjectile.global_position = global_position + global_position.direction_to(mousePos) * 24
				kickProjectile.direction = global_position.direction_to(mousePos)
				get_tree().get_current_scene().main.add_child(kickProjectile)
	
	move_and_slide()

func move(delta):
	var moveDir = Vector2(Input.get_axis("moveLeft","moveRight"),Input.get_axis("moveUp","moveDown")).normalized()
	var finalMoveSpeed = maxSpeed * (((momentumValue / 33.0) ** 1.5) + 1.0)
	velocity = velocity.lerp(finalMoveSpeed * moveDir,delta * baseSpeed)
	footstepCooldown -= (abs(velocity.x) + abs(velocity.y)) * delta
	if footstepCooldown < 0:
		footstepCooldown += 100
		$Footstep.play()

func _on_player_animation_finished() -> void:
	$Sprite/Player.play("Idle")

func _on_revolver_animation_finished() -> void:
	$Sprite/Revolver.play("Idle")
