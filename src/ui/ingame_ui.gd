extends MenuSwitcher


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_opened:
			close()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			open()
			switch_to_menu("PauseMenu")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			if not is_opened:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
