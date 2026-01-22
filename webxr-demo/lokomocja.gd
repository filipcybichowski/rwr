extends XROrigin3D

@export var move_speed: float = 2.5
@export var deadzone: float = 0.15 # Martwa strefa, żeby postać nie sunęła sama, gdy gałka jest lekko zużyta

# Upewnij się, że ścieżki do węzłów są poprawne w Twoim drzewie sceny!
@onready var xr_camera: XRCamera3D = $XRCamera3D 
@onready var left_ctrl: XRController3D = $LeftController

func _physics_process(delta: float) -> void:
	# 1. Pobieramy wektory kierunku z kamery
	# -Z to przód w Godot, X to prawo
	var fwd := -xr_camera.global_transform.basis.z
	var right := xr_camera.global_transform.basis.x

	# --- KOREKTA 5.2 (DLA CHODZENIA PO PŁASKIM) ---
	# Zerujemy oś Y (wysokość), żeby nie latać w powietrzu
	fwd.y = 0.0
	right.y = 0.0
	
	# Normalizujemy, żeby wektor miał długość 1 (inaczej patrzenie lekko w dół zwalniałoby ruch)
	fwd = fwd.normalized()
	right = right.normalized()
	# ----------------------------------------------

	# 2. Pobieramy wychylenie gałki (thumbstick)
	var v: Vector2 = left_ctrl.get_vector2("thumbstick")
	
	# Obsługa martwej strefy (jeśli wychylenie jest minimalne, ignoruj je)
	if v.length() < deadzone:
		v = Vector2.ZERO

	# 3. Obliczamy kierunek ruchu
	# v.y to góra/dół na padzie, v.x to prawo/lewo
	var dir := Vector3.ZERO
	dir += fwd * (-v.y) + right * (v.x) # -v.y bo w Godot "do przodu" to ujemne Z

	# 4. Przesuwamy gracza
	if dir.length() > 0.0:
		# Normalizujemy dir, aby ruch po skosie nie był szybszy (pitagoras: 1^2 + 1^2 > 1)
		global_translate(dir.normalized() * move_speed * delta)
