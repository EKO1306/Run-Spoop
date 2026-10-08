extends Panel

@export var levelName : String
@export var levelPath : String
@export var levelTime : float

func _ready() -> void:
	$LevelName.text = levelName.replace("_","-")
	if levelTime < 0.0:
		$LevelTime.text = "--:--.---"
	else:
		$LevelTime.text = GlobalScript.timeFloatToString(levelTime, true, 16)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				get_tree().get_current_scene().changeScene(load("res://Scenes/Levels/{0}".format([levelPath])))
