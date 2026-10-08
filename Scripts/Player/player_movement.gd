extends CharacterBody2D

const baseSpeed = 5.0
var maxSpeed = 200
var attackCooldown = 0
var canAction = false
var invunerabilityTimer = 0
var maxPrimaryUses = 3
var deathTimer
var dead = false
@onready var primaryUsesRemaining = maxPrimaryUses

var footstepCooldown = 0

var momentumValue = 100.0
var maxMomentum = 100.0
var momentumDamage = 0.0
var timeSinceHit = INF

var cheatsEnabled = false
var cheatPressTimer = 0.0
var disableMomentumDrain = false

func _ready() -> void:
	$UI.show()
	if get_tree().current_scene.main.name == "Level_Test":
		cheatsEnabled = true
		disableMomentumDrain = true

func _process(delta: float) -> void:
	
	handleDebug(delta)
	
	if dead:
		deathTimer -= delta
		modulate.a = 1.0
		$Sprite/Player.play("Dead")
		$Sprite/Revolver.hide()
		if deathTimer <= 0.0:
			get_tree().current_scene.restartScene()
		return
	if not disableMomentumDrain:
		changeMomentum(-delta * (((momentumValue / maxMomentum) * 10.0) + 2.5), false)
	invunerabilityTimer -= delta
	if invunerabilityTimer > 0:
		modulate.a = sin(invunerabilityTimer * 10)
	else:
		modulate.a = 1
	if momentumValue <= 0.0:
		dead = true
		deathTimer = 2.0
		$Sprite/Revolver.hide()
		$Sprite/Player.play("Dead")
		return
	timeSinceHit += delta
	if timeSinceHit > 3.0:
		momentumDamage = max(0.0, momentumDamage - (delta * (((momentumDamage / maxMomentum) * 20.0) + 5.0)))
	$Camera2D.zoom.x = 6 - (((momentumValue / maxMomentum) ** 4) * 2)
	$Camera2D.zoom.y = $Camera2D.zoom.x
	
func changeMomentum(change : float, scaling := true, isDamage := false):
	if scaling and change > 0.0:
		momentumValue += change * (1 - ((momentumValue / maxMomentum) * 0.5))
	else:
		momentumValue += change
	if isDamage and change < 0.0:
		momentumDamage -= (change * 0.5)
		timeSinceHit = 0.0
	momentumValue = clampf(momentumValue,0.0,maxMomentum - momentumDamage)

func onHit(damage, source):
	if invunerabilityTimer <= 0:
		changeMomentum(-damage, false, true)
		invunerabilityTimer = 1.0
		velocity += (global_position.direction_to(source.global_position) * -5) / get_physics_process_delta_time()
		$PlayerHurt.play()
		return true

func _physics_process(delta: float) -> void:
	if dead:
		velocity *= 0.7
		move_and_slide()
		return
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

func handleDebug(delta) -> void:
	if cheatsEnabled:
		if Input.is_action_just_pressed("TESTIncreaseMomentum"):
			changeMomentum(50, false)
			dead = false
		if Input.is_action_just_pressed("TESTDecreaseMomentum"):
			changeMomentum(-50)
		if Input.is_action_just_pressed("TESTAddBullet"):
			$RevolverClick.play()
			primaryUsesRemaining = min(maxPrimaryUses, primaryUsesRemaining + 1)
		if Input.is_action_just_pressed("TESTDisableEnergyDrain"):
			disableMomentumDrain = not disableMomentumDrain
		if Input.is_action_pressed("TESTMinigun"):
			$Sprite/Revolver.play("Shoot")
			var bulletProjectile = preload("res://Nodes/Projectiles/Player/player_projectile_bullet.tscn").instantiate()
			bulletProjectile.global_position = global_position + global_position.direction_to(get_global_mouse_position()) * 4
			bulletProjectile.direction = global_position.direction_to(get_global_mouse_position())
			get_tree().get_current_scene().add_child(bulletProjectile)
		if Input.is_action_just_pressed("TESTNoclip"):
			set_collision_mask_value(1, not get_collision_mask_value(1))
	else:
		if Input.is_action_just_pressed("TESTEnableCheats"):
			if cheatPressTimer > 0.0:
				cheatsEnabled = true
				disableMomentumDrain = true
				momentumValue = maxMomentum
				momentumDamage = 0.0
			else:
				cheatPressTimer = 0.5
		else:
			cheatPressTimer = max(0.0, cheatPressTimer - delta)
