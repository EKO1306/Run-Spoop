extends "enemy_mover.gd"

@export var shieldMaxHealth = 100
@onready var shieldHealth = shieldMaxHealth

var shieldUpTimer = 0

func postProcess(_delta: float) -> void:
	if shieldUpTimer > 0:
		nodeSprite.position = Vector2(random.randf_range(-0.5,0.5),random.randf_range(-0.5,0.5))
	else:
		nodeSprite.position = Vector2.ZERO

func onHit(damage, projectile = null, playerProjectile = false):
	if not alive:
		return false
	playAnim("Hurt",true)
	if shieldHealth > 0 and shieldUpTimer <= 0:
		shieldHealth -= damage
		$SoundShieldImpact.play()
		if shieldHealth <= 0:
			maxSpeed = 80.0
			knockbackValue = 5.0
			playAnim("Enter_Shieldless",true,false)
			$SoundShieldBreak.play()
		elif projectile.heavyProjectile:
			shieldUpTimer = 3.0
			playAnim("Enter_ShieldUp",true,false)
	else:
		$SoundHurt.play
		statHealth -= damage
	if projectile != null:
		velocity += (global_position.direction_to(projectile.global_position) * -knockbackValue) / get_physics_process_delta_time()
	if statHealth <= 0:
		onDeath(projectile)
	return true

func prePhysics(delta):
	if shieldUpTimer > 0:
		shieldUpTimer -= delta
		if shieldUpTimer <= 0:
			playAnim("Leave_ShieldUp",true,false)

func canMove():
	if shieldUpTimer > 0:
		return false
	return true

func _on_animated_sprite_2d_animation_finished() -> void:
	playAnim("Idle")

func playAnim(animationName, force = false, addSuffix = true):
	if addSuffix:
		if shieldHealth <= 0:
			animationName += "_Shieldless"
		elif shieldUpTimer > 0:
			animationName += "_ShieldUp"

	if nodeSprite.animation != animationName or force:
		nodeSprite.play(animationName)
