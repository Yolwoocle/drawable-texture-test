extends BasicMenu

@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var mouse_sensitivity_slider: HSlider = %MouseSensitivitySlider
@onready var mouse_sensitivity_label: Label = %MouseSensitivityLabel
@onready var volume_label: Label = %VolumeLabel
@onready var volume_slider: HSlider = %VolumeSlider
@onready var input_device_option_button: OptionButton = %InputDeviceOptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	mouse_sensitivity_slider.value_changed.connect(_on_mouse_sensitivity_slider_value_changed)
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	input_device_option_button.item_selected.connect(_on_input_device_option_button_item_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.current_player:
		mouse_sensitivity_label.text = str(Global.current_player.normal_mouse_sensitivity)
		volume_label.text = str(int(100 * AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))))


func enter():
	super()
	if Global.current_player:
		mouse_sensitivity_slider.value = Global.current_player.normal_mouse_sensitivity
		volume_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
	
	var idx = -1
	var devices = AudioServer.get_input_device_list()
	input_device_option_button.clear()
	for i in devices.size():
		var device = devices[i]
		input_device_option_button.add_item(device)
		if AudioServer.input_device == device:
			idx = i
	if idx == -1:
		idx = 0
	input_device_option_button.select(idx)


func _on_resume_button_pressed():
	get_parent().close()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	if Global.current_player:
		Global.current_player.normal_mouse_sensitivity = value


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_input_device_option_button_item_selected(index: int) -> void:
	var device_name = input_device_option_button.get_item_text(index)
	AudioServer.input_device = device_name
