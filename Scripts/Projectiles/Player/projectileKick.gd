extends "projectlePlayerBase.gd"

@onready var nodePlayer = get_tree().get_current_scene().main.get_node("Player") as CharacterBody2D

func projectileDeath(despawn, hitEnemy = false):
	alive = false
	monitoring = false
	monitorable = false
	$AnimationPlayer.play("Dead")
	if despawn:
		if soundOnDespawn:
			$DeathSound.volume_db -= 10
			$DeathSound.play()
	else:
		nodePlayer.velocity = direction * - 5.0 / get_physics_process_delta_time()
		print(nodePlayer.velocity)
		if not hitEnemy:
			$DeathSound.volume_db -= 10
		$DeathSound.play()
	remainingLifespan = min(remainingLifespan, 0.0)
