extends Control

@onready var nodeEnergyLowOverlay = $EnergyLowOverlay

@onready var nodePlayer = get_parent().get_parent()

func _process(delta: float) -> void:
	var momentumValue = nodePlayer.momentumValue
	var maxMomentum = nodePlayer.maxMomentum
	if momentumValue > 0.0:
		nodeEnergyLowOverlay.modulate.a = (( 1.0 - (momentumValue / maxMomentum)) - 0.5) * 2.0
	else:
		nodeEnergyLowOverlay.modulate.a = 1.0
