extends TextureRect

@onready var nodeTimerText = $TimerMain
@onready var nodeDebugText = $DebugText

var timer = 0.0

func _process(delta: float) -> void:
	timer += delta
	
	nodeDebugText.visible = get_parent().get_parent().cheatsEnabled
	
	var timerString := GlobalScript.timeFloatToString(timer, true, 8)
	nodeTimerText.text = timerString
