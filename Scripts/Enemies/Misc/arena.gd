extends Area2D

@export var wavesList : Array[ArenaWave]
@export var startTriggers : Array[NodePath]
@export var endTriggers : Array[NodePath]
var wavesTriggersLeft : Array[int]
var wavesPassed : Array[bool]
var started := false
var complete := false

var triggerTimer := 0.0
var nextTrigger := 0
var triggeringWave := -1
@export_range(0.01,1.0) var delayBetweenTriggers = 0.1
@export_range(0.01,5.0) var startDelay = 0.5
@export_range(0.01,5.0) var endDelay = 0.5

func _ready() -> void:
	for i in wavesList:
		wavesTriggersLeft.append(len(i.waveTriggers))
		wavesPassed.append(false)
	if not visible:
		process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if triggeringWave >= 0:
		triggerTimer -= delta
		while triggerTimer <= 0.0:
			updateTriggering()

func updateTriggering() -> void:
	triggerTimer += delayBetweenTriggers
	var triggersList = wavesList[triggeringWave].waveTriggers
	triggerObject(triggersList[nextTrigger], triggeringWave)
	nextTrigger += 1
	if len(triggersList) <= nextTrigger:
		var wave = wavesList[triggeringWave]
		if wave.instantlyTriggerNextWave:
			wavesPassed[triggeringWave] = true
			startWave(wave.nextWave)
		else:
			triggeringWave = -1
		return
	var node = get_node(triggersList[nextTrigger])
	if node != null:
		if node.is_in_group("instantTriggers"):
			triggerTimer -= 0.1
			updateTriggering()

func _physics_process(_delta: float) -> void:
	if not started:
		for i in get_overlapping_bodies():
			if i.is_in_group("Player"):
				startArena()
				

func startArena() -> void:
	if started:
		return
	started = true
	triggerObjectsInList(startTriggers)
	$StartTimer.start(startDelay)

func endArena() -> void:
	if complete:
		return
	complete = true
	$EndTimer.start(endDelay)

func startWave(waveNo : int) -> void:
	if waveNo > len(wavesList) - 1:
		print("a")
		return
	if waveNo < 0:
		print("b")
		return
	if wavesPassed[waveNo]:
		print("c")
		return
	startTriggeringWave(waveNo)

func startTriggeringWave(waveNo : int) -> void:
	triggeringWave = waveNo
	nextTrigger = 0
	triggerTimer = 0.0
	updateTriggering()

func triggerObjectsInList(list : Array[NodePath], waveNo := -1) -> void:
	for i in list:
		triggerObject(i, waveNo) 

func triggerObject(objectPath : NodePath, wave = null) -> bool:
	if objectPath == null:
		return false
	var node = get_node(objectPath)
	if node == null:
		return false
	node.trigger(wave, self)
	return true

func triggerComplete(waveNo : int):
	if waveNo < 0:
		return
	if complete:
		return
	wavesTriggersLeft[waveNo] -= 1
	if wavesTriggersLeft[waveNo] <= 0:
		var wave = wavesList[waveNo]
		if wavesPassed[waveNo]:
			checkIfComplete()
		else:
			wavesPassed[waveNo] = true
			checkIfComplete()
			startWave(wave.nextWave)

func checkIfComplete() -> void:
	if complete:
		return
	var waveNo = -1
	for wave in wavesList:
		waveNo += 1
		if not wave.requiredToComplete:
			continue
		if not wavesPassed[waveNo]:
			return
		if wavesTriggersLeft[waveNo] > 0:
			return
	endArena()


func _on_start_timer_timeout() -> void:
	startWave(0)


func _on_end_timer_timeout() -> void:
	triggerObjectsInList(endTriggers)

func trigger(wave = -1, arena = null) -> bool:
	if visible:
		startArena()
	else:
		visible = true
		process_mode = Node.PROCESS_MODE_INHERIT
	if wave >= 0:
		arena.triggerComplete(wave)
	return true
