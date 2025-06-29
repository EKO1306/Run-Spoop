extends Area2D

@export var damage : int
@export var speed = 200
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
	if not alive:
		if remainingLifespan <= -deleteTimer:
			queue_free()
		return
	velocity = direction * speed
	position += velocity * delta
	for node in get_overlapping_areas():
		if onCollision(node):
			return
	for node in get_overlapping_bodies():
		if onCollision(node):
			break

func onCollision(node):
	if node.is_in_group("EnemyCollider"):
		enemyColliion(node.get_parent())
		return true
	if node.is_in_group("Terrain"):
		projectileDeath(false)
		return true

func enemyColliion(enemyNode):
	if enemyNode.onHit(damage,self,true):
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
		
