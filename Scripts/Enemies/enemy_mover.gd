extends "enemy_base.gd"


@export var moveSpeed = 5.0
@export var maxSpeed = 40.0
@export var activationDistance = 128.0
@export var deactivationDistance = 256.0
@onready var nodeNavAgent = $NavigationAgent2D
var navAgentUpdateTimer = 0
var targetPos

var activated = false

func postPhysics(delta):
	if not canMove():
		return
	if global_position.distance_to(nodePlayer.global_position) >= deactivationDistance:
		activated = false
	elif global_position.distance_to(nodePlayer.global_position) < activationDistance:
		activated = true
	if activated:
		navAgentUpdateTimer -= delta
		if navAgentUpdateTimer <= 0:
			navAgentUpdateTimer += 0.5
			nodeNavAgent.target_position = nodePlayer.global_position
			targetPos = nodeNavAgent.get_next_path_position()
		velocity = velocity.lerp(maxSpeed * global_position.direction_to(targetPos),delta * moveSpeed)
	else:
		navAgentUpdateTimer = 0

func canMove():
	return true
