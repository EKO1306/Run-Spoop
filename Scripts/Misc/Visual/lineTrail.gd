extends Line2D

var queue = []
@export var maxLength = 10

func _ready() -> void:
	global_position = Vector2.ZERO

func _process(delta: float) -> void:
	queue.push_front(get_parent().global_position)
	if queue.size() > maxLength:
		queue.pop_back()
		remove_point(0)
	
	add_point(get_parent().global_position)
	
