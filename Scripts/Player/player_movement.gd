extends CharacterBody2D

const baseSpeed = 100

func _physics_process(delta: float) -> void:
	var mousePos = get_global_mouse_position()
	var moveDir = Vector2(Input.get_axis("moveLeft","moveRight"),Input.get_axis("moveUp","moveDown"))
	velocity = moveDir.normalized() * baseSpeed
	if global_position.x < mousePos.x:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1
	
	if Input.is_action_just_pressed("attackPrimary"):
		velocity += (global_position.direction_to(mousePos) * 2) / delta
		$Sprite/AnimatedSprite2D.play("Primary")
		var kickProjectile = preload("res://Nodes/Projectiles/Player/player_projectile_kick.tscn").instantiate()
		kickProjectile.global_position = global_position + global_position.direction_to(mousePos) * 8
		kickProjectile.direction = global_position.direction_to(mousePos)
		get_tree().get_current_scene().add_child(kickProjectile)
	
	move_and_slide()
