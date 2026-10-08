extends RichTextLabel

@export var active := true

func _ready() -> void:
	if active:
		visible = true
		modulate.a = 1.0
	else:
		visible = false

func trigger(wave = -1, arena = null) -> bool:
	active = not active
	if active:
		$AnimationPlayer.play("FadeIn")
	else:
		$AnimationPlayer.play("FadeOut")
	if wave >= 0:
		arena.triggerComplete(wave)
	return true
