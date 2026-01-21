extends Node3D

var webxr_interface

@onready var canvas: CanvasLayer = $CanvasLayer
@onready var start_button: Button = $CanvasLayer/Button
@onready var left_controller: XRController3D = $Player/XROrigin3D/LeftController

func _ready() -> void:
	canvas.visible = false
	start_button.pressed.connect(_on_button_pressed)

	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		webxr_interface.session_supported.connect(_webxr_session_supported)
		webxr_interface.session_started.connect(_webxr_session_started)
		webxr_interface.session_ended.connect(_webxr_session_ended)
		webxr_interface.session_failed.connect(_webxr_session_failed)

		webxr_interface.select.connect(_webxr_on_select)
		webxr_interface.selectstart.connect(_webxr_on_select_start)
		webxr_interface.selectend.connect(_webxr_on_select_end)

		webxr_interface.squeeze.connect(_webxr_on_squeeze)
		webxr_interface.squeezestart.connect(_webxr_on_squeeze_start)
		webxr_interface.squeezeend.connect(_webxr_on_squeeze_end)

		webxr_interface.is_session_supported("immersive-vr")

	# Debug przycisków lewego kontrolera (opcjonalnie)
	left_controller.button_pressed.connect(_on_left_controller_button_pressed)
	left_controller.button_released.connect(_on_left_controller_button_released)

func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == "immersive-vr":
		if supported:
			canvas.visible = true
		else:
			OS.alert("Your browser doesn't support VR")

func _on_button_pressed() -> void:
	webxr_interface.session_mode = "immersive-vr"
	webxr_interface.requested_reference_space_types = "bounded-floor, local-floor, local"
	webxr_interface.required_features = "local-floor"
	webxr_interface.optional_features = "bounded-floor"

	if not webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return

func _webxr_session_started() -> void:
	canvas.visible = false
	get_viewport().use_xr = true
	print("Reference space type: " + webxr_interface.reference_space_type)

func _webxr_session_ended() -> void:
	canvas.visible = true
	get_viewport().use_xr = false

func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)

func _on_left_controller_button_pressed(button: String) -> void:
	print("Left button pressed: " + button)

func _on_left_controller_button_released(button: String) -> void:
	print("Left button released: " + button)

func _webxr_on_select(input_source_id: int) -> void:
	print("Select: " + str(input_source_id))
	var tracker: XRPositionalTracker = webxr_interface.get_input_source_tracker(input_source_id)
	if tracker:
		var xform = tracker.get_pose("default").transform
		print(xform.origin)

func _webxr_on_select_start(input_source_id: int) -> void:
	print("Select Start: " + str(input_source_id))

func _webxr_on_select_end(input_source_id: int) -> void:
	print("Select End: " + str(input_source_id))

func _webxr_on_squeeze(input_source_id: int) -> void:
	print("Squeeze: " + str(input_source_id))

func _webxr_on_squeeze_start(input_source_id: int) -> void:
	print("Squeeze Start: " + str(input_source_id))

func _webxr_on_squeeze_end(input_source_id: int) -> void:
	print("Squeeze End: " + str(input_source_id))
