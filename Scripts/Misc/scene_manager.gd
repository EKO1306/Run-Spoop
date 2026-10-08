extends Node

@export var defaultScene := PackedScene.new()

var scenePassover = {}
var mainPackaged : PackedScene
var main
var loadScene := false
# hi this is [REDACTED] hahahahha >:3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = defaultScene.instantiate()
	mainPackaged = defaultScene
	loadScene = false
	add_child(main)

func _process(_delta: float) -> void:
	if loadScene:
		if mainPackaged == null:
			mainPackaged = preload("res://Scenes/menu.tscn")
		print(mainPackaged)
		main = mainPackaged.instantiate()
		add_child(main,true)
		loadScene = false

func restartScene() -> void:
	changeScene(mainPackaged, scenePassover)

func changeScene(scene : PackedScene, passover := {}):
	scenePassover = passover
	for i in get_children():
		i.queue_free()
	mainPackaged = scene
	loadScene = true
	get_tree().paused = false

func reloadScene(passover = {}):
	changeScene(mainPackaged, passover)
