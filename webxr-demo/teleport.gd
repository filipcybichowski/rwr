extends XRController3D

@onready var ray: RayCast3D = $TeleportRay
@onready var marker: MeshInstance3D = $TeleportMarker

var xr_origin: XROrigin3D
var xr_camera: XRCamera3D

func _ready() -> void:
	# Pobieramy referencje do rodzica (Origin) i kamery
	xr_origin = get_parent() as XROrigin3D
	xr_camera = xr_origin.get_node("XRCamera3D") as XRCamera3D
	marker.visible = false
	
	# Podłączamy sygnał naciśnięcia przycisku
	button_pressed.connect(_on_button_pressed)

func _process(_delta: float) -> void:
	# W każdej klatce sprawdzamy, czy laser w coś trafia
	if ray.is_colliding():
		var point = ray.get_collision_point()
		marker.global_position = point
		
		# Opcjonalnie: dopasuj marker do nachylenia podłoża (normalnej)
		# ale prosty marker wystarczy na płaskie podłogi.
		marker.visible = true
	else:
		marker.visible = false

# Ta funkcja obsługuje wejście z kontrolera
func _on_button_pressed(button_name: String) -> void:
	# "trigger_click" to standardowa nazwa dla głównego spustu
	# Możesz zmienić na "ax_button" (przycisk A) jeśli wolisz
	if button_name == "trigger_click":
		teleport_now()

func teleport_now() -> void:
	# Jeśli laser nie widzi podłogi, nie teleportujemy
	if not ray.is_colliding() or not marker.visible:
		return
		
	var target: Vector3 = ray.get_collision_point()

	# --- OBLICZENIA (WERSJA 4.2.B - STABILNA) ---
	var origin_tf := xr_origin.global_transform
	var cam_tf := xr_camera.global_transform
	
	# Obliczamy przesunięcie gracza względem środka "pokoju" (Origin)
	var cam_offset := cam_tf.origin - origin_tf.origin
	
	# KROK KLUCZOWY: Zerujemy wysokość (Y) w offsecie.
	# Dzięki temu teleportujemy "stopy" gracza w nowe miejsce,
	# niezależnie od tego, czy kuca, czy stoi.
	cam_offset.y = 0.0

	# Przesuwamy Origin w miejsce docelowe, odejmując przesunięcie gracza.
	# Dzięki temu po teleportacji gracz znajdzie się dokładnie nad markerem.
	origin_tf.origin = Vector3(target.x - cam_offset.x, target.y, target.z - cam_offset.z)
	
	xr_origin.global_transform = origin_tf
