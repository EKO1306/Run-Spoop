extends Area2D

@export_category("Player Attack Stats")
@export var attackDamage : int
@export var playerAttackSpeed = 200
@export_category("Enemy Attack Stats")
@export var isPlayerAttack = false
@export var momentumDamage : int
@export var enemyAttackSpeed = 200
@export_category("Misc Attack Stats")
@export var lifespan = 0.2
@export var deleteTimer = 1
@export var heavyProjectile = false
@export var soundOnDespawn = true
var remainingLifespan
var alive = true

var direction = Vector2.ZERO
var velocity = Vector2.ZERO

func _ready() -> void:
	remainingLifespan = lifespan

func _process(delta: float) -> void:
	rotation = Vector2.ZERO.angle_to_point(direction)

func _physics_process(delta: float) -> void:
	remainingLifespan -= delta
	if alive:
		if remainingLifespan <= 0:
			projectileDeath(true)
			return
		if isPlayerAttack:
			set_collision_mask_value(2,false)
			set_collision_mask_value(5,true)
		else:
			set_collision_mask_value(2,true)
			set_collision_mask_value(5,false)
	if not alive:
		if remainingLifespan <= -deleteTimer:
			queue_free()
		return
	if isPlayerAttack:
		velocity = direction * playerAttackSpeed
	else:
		velocity = direction * enemyAttackSpeed
	position += velocity * delta
	for node in get_overlapping_areas():
		if onCollision(node):
			return
	for node in get_overlapping_bodies():
		if onCollision(node):
			break

func onCollision(node):
	if isPlayerAttack:
		if node.is_in_group("EnemyCollider"):
			enemyColliion(node.get_parent())
			return true
	else:
		if node.is_in_group("Player"):
			playerColliion(node.get_parent())
			return true
	if node.is_in_group("Projectile"):
		if not heavyProjectile:
			if isPlayerAttack:
				if not node.isPlayerAttack:
					if not node.heavyProjectile:
						node.isPlayerAttack = true
						node.direction = direction
						node.heavyProjectile = true
						projectileDeath(false)
						return true
	if node.is_in_group("Terrain"):
		projectileDeath(false)
		return true

func playerColliion(playerNode):
	if playerNode.onHit(momentumDamage,self):
		projectileDeath(false, true)

func enemyColliion(enemyNode):
	if enemyNode.onHit(attackDamage,self):
		projectileDeath(false, true)

func projectileDeath(despawn, hitEnemy = false):
	remainingLifespan = min(remainingLifespan, 0.0)
	alive = false
	monitoring = false
	monitorable = false
	$AnimationPlayer.play("Dead")
	if despawn:
		if soundOnDespawn:
			$DeathSound.volume_db -= 10
			$DeathSound.play()
	else:
		if not hitEnemy:
			$DeathSound.volume_db -= 10
		$DeathSound.play()
		
