extends TextureRect

@export var progressGradient : Gradient

@onready var nodePlayer = get_parent().get_parent()
@onready var nodeMomentumChange = $MomentumChange
@onready var nodeMomentumPrimary = $MomentumBarPrimary
@onready var nodeMomentumDamage = $MomentumBarDamage

func _ready() -> void:
	var momentumValue = nodePlayer.momentumValue
	var maxMomentum = nodePlayer.maxMomentum
	
	nodeMomentumPrimary.max_value = maxMomentum
	nodeMomentumChange.max_value = maxMomentum
	nodeMomentumDamage.max_value = maxMomentum
	
	nodeMomentumPrimary.value = momentumValue
	nodeMomentumChange.value = momentumValue
	nodeMomentumDamage.value = nodePlayer.momentumDamage

func _process(delta: float) -> void:
	var momentumValue = nodePlayer.momentumValue
	var maxMomentum = nodePlayer.maxMomentum
	var momentumDamage = nodePlayer.momentumDamage
	
	nodeMomentumPrimary.max_value = maxMomentum
	nodeMomentumChange.max_value = maxMomentum
	
	nodeMomentumDamage.value = momentumDamage
	
	if nodeMomentumPrimary.value >= momentumValue:
		nodeMomentumPrimary.value = momentumValue
		nodeMomentumChange.value += (momentumValue - nodeMomentumChange.value) * delta * 2
	else:
		nodeMomentumPrimary.value += (momentumValue - nodeMomentumPrimary.value) * delta * 2
		nodeMomentumChange.value = momentumValue

	nodeMomentumPrimary.tint_progress = progressGradient.sample(nodeMomentumPrimary.ratio)
	if nodeMomentumChange.value > momentumValue:
		nodeMomentumChange.tint_progress = Color(1,0.5,0.5)
	else:
		nodeMomentumChange.tint_progress = Color(0.5,1,0.5)
