extends StaticBody2D

@export var active := false

func _ready() -> void:
	activate(active)

func trigger(wave = null, arena = null) -> bool:
	activate(not active)
	return true

func activate(on : bool) -> void:
	active = on
	visible = active
	if active:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
