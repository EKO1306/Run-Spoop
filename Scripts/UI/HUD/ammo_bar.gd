extends TextureRect

@onready var nodePlayer = get_tree().get_current_scene().get_node("Player")

func _process(delta: float) -> void:
	var playerRemainingAmmo = nodePlayer.primaryUsesRemaining
	var i = -1
	for node in $HBoxContainer.get_children():
		i += 1
		node.get_child(0).visible = playerRemainingAmmo > i
