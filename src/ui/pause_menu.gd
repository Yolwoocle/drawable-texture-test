extends BasicMenu

@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var mouse_sensitivity_slider: HSlider = %MouseSensitivitySlider
@onready var mouse_sensitivity_label: Label = %MouseSensitivityLabel
@onready var volume_label: Label = %VolumeLabel
@onready var volume_slider: HSlider = %VolumeSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	mouse_sensitivity_slider.value_changed.connect(_on_mouse_sensitivity_slider_value_changed)
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)


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


func _on_resume_button_pressed():
	get_parent().close()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	if Global.current_player:
		Global.current_player.normal_mouse_sensitivity = value


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
