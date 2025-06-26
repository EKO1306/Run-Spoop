extends Area2D

@export var speed = 200
@export var lifespan = 0.2
@export var deleteTimer = 1
var remainingLifespan
var alive = true

var direction = Vector2.ZERO
var velocity = Vector2.ZERO

func _ready() -> void:
	remainingLifespan = lifespan

func _physics_process(delta: float) -> void:
	remainingLifespan -= delta
	if alive:
		if remainingLifespan <= 0:
			alive = false
			monitoring = false
			monitorable = false
			$AnimationPlayer.play("Dead")
	if not alive:
		if remainingLifespan <= -deleteTimer:
			queue_free()
		return
	rotation = Vector2.ZERO.angle_to_point(direction)
	velocity = direction * speed
	print(velocity)
	position += velocity * delta
