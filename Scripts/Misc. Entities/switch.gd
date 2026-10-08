extends StaticBody2D

var activated = false
@export var triggers : Array[NodePath]

func onHit(_damage, _source) -> bool:
	if activated:
		return true
	
	$AnimatedSprite2D.play("On")
	activated = true
	triggerList()
	return true

func triggerList() -> void:
	for i in triggers:
		triggerObject(i) 

func triggerObject(objectPath : NodePath) -> bool:
	if objectPath == null:
		return false
	var node = get_node(objectPath)
	if node == null:
		return false
	node.trigger(-1, self)
	return true

func triggerComplete(waveNo : int):
	return
