extends Camera2D
## enums
## consts
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	pass 

func _physics_process(delta: float) -> void:
	move_camera()
	pass

## public methods

func move_camera() -> void:
	var delta = get_process_delta_time()
	if Input.is_action_pressed("_input_up"):
		#print("up")
		position.y -= 4000 * delta
	if Input.is_action_pressed("_input_down"):
		#print("down")
		position.y += 4000 * delta
	if Input.is_action_pressed("_input_left"):
		#print("left")
		position.x -= 4000 * delta
	if Input.is_action_pressed("_input_right"):
		#print("right")
		position.x += 4000 * delta
	if Input.is_action_just_released(&"_input_mouse_scroll_up"):
		#print("scroll up")
		zoom += Vector2(2,2) * delta
	if Input.is_action_just_released(&"_input_mouse_scroll_down"):
		#print("scroll down")
		zoom -= Vector2(2,2) * delta

## private methods
