extends TextureRect

@export var progressGradient : Gradient

@onready var nodePlayer = get_tree().get_current_scene().get_node("Player")
@onready var nodeMomentumChange = $MomentumChange
@onready var nodeMomentumPrimary = $MomentumBarPrimary

func _process(delta: float) -> void:
	var momentumValue = nodePlayer.momentumValue
	var maxMomentum = nodePlayer.maxMomentum
	
	nodeMomentumPrimary.max_value = maxMomentum
	nodeMomentumChange.max_value = maxMomentum
	
	if nodeMomentumPrimary.value >= momentumValue:
		nodeMomentumPrimary.value = nodePlayer.momentumValue
		nodeMomentumChange.value += (nodePlayer.momentumValue - nodeMomentumChange.value) * delta * 2
	else:
		nodeMomentumPrimary.value += (nodePlayer.momentumValue - nodeMomentumPrimary.value) * delta * 2
		nodeMomentumChange.value = nodePlayer.momentumValue

	nodeMomentumPrimary.tint_progress = progressGradient.sample(nodeMomentumPrimary.ratio)
	if nodeMomentumChange.value > momentumValue:
		nodeMomentumChange.tint_progress = Color(1,0.5,0.5)
	else:
		nodeMomentumChange.tint_progress = Color(0.5,1,0.5)
