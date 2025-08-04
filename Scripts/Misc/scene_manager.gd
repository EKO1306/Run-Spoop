extends Node

@export var defaultScene = ""

var scenePassover = {}
var changingScene
var main
# hi this is micheal hahahahha >:3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = load(defaultScene).instantiate()
	add_child(main)

func _process(_delta: float) -> void:
	if changingScene != null:
		main = load(changingScene)
		if main == null:
			main = preload("res://Scenes/Levels/level_base.tscn")
		main = main.instantiate()
		add_child(main,true)
		changingScene = null

func changeScene(scene, passover = {}):
	scenePassover = passover
	for i in get_children():
		i.queue_free()
	changingScene = scene
	get_tree().paused = false
