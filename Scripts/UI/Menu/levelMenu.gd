extends Panel

@onready var nodeLevelContainer = $ScrollContainer/VBoxContainer

func _ready() -> void:
	getMaps()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("TESTEnableCheats"):
		get_tree().get_current_scene().changeScene(load("res://Scenes/level_test.tscn"))

func getMaps() -> void:
	return
	var levelTimes = GlobalScript.getLevelTimesArray()
	var levelFolder = DirAccess.open("res://Scenes/Levels/") as DirAccess
	for i in levelFolder.get_files():
		var extention = i.get_extension()
		if not (extention == "tscn" or extention == "remap"):
			continue
		var levelName = i.trim_prefix("level_").trim_suffix(".tscn")
		var levelNode = load("res://Nodes/UI/Menu/level_panel.tscn").instantiate()
		levelNode.levelName = levelName
		levelNode.levelPath = i
		if levelTimes.has(levelName):
			levelNode.levelTime = levelTimes[levelName]
		else:
			levelNode.levelTime = -1.0
		nodeLevelContainer.add_child(levelNode)
