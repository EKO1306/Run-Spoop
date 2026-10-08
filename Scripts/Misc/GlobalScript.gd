extends Node

func saveTime(levelName : String) -> void:
	if levelName == "":
		return
	
	var player = get_tree().current_scene.main.get_node("Player")
	if player.cheatsEnabled:
		return
	
	var file : FileAccess
	var timeDict : Dictionary
	if FileAccess.file_exists("user://levelTimes.json"):
		timeDict = getLevelTimesArray()
	else:
		timeDict = {}
	
	var time = player.get_node("UI/TimerUI").timer
	if timeDict.has(levelName):
		if timeDict[levelName] <= time:
			return
	
	file = FileAccess.open("user://levelTimes.json", FileAccess.WRITE)
	timeDict[levelName] = time
	var json = JSON.stringify(timeDict)
	file.store_string(json)
	file.close()
	print()

func getLevelTimesArray() -> Dictionary:
	var file = FileAccess.open("user://levelTimes.json", FileAccess.READ_WRITE)
	if FileAccess.get_open_error():
		print("Error {0} when opening file.".format([FileAccess.get_open_error()]))
		return {}
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error:
		print("Error {0} when loading level times.".format([error]))
		return {}
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Unexpected data when checking level times.")
		return {}
	
	return data

func timeFloatToString(timer : float, bbCode := false, mSecSize := 0) -> String:
	var timerString : String
	if timer > 36000.0:
		if bbCode:
			timerString = "[font_size={12}]Too Long :3[/font_size]"
		else:
			timerString = "Too Long :3"
	else:
		var timeMsec = "%03d" % (int(timer * 1000.0) % 1000)
		var timeSec = "%02d" % (int(timer) % 60)
		var timeMin = "%02d" % (int(timer / 60.0) % 60)
		var timeHour = str(int(timer / 3600.0) % 60)
		if bbCode:
			timerString = "{1}:{2}[font_size={" + str(mSecSize) + "}].{3}[/font_size]"
		else:
			timerString = "{1}:{2}.{3}"
		if timer >= 3600.0:
			timerString = "{0}:" + timerString
		timerString = timerString.format([timeHour,timeMin,timeSec,timeMsec])
	return timerString
