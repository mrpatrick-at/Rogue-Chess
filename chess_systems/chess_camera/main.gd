extends Node2D
## enums
## consts
const CAMERA_ZOOM_SPEED:float = 4.0
const CAMERA_ZOOM_RANGE:Vector2 = Vector2(0.1,2.5)
const CAMERA_MOVE_SPEED:Vector2 = Vector2(0.1,2.5)
## exports
## public vars
static var cam_movement_velocity:Vector2
static var cam_zoom_velocity:float = 0.0
## private vars
## onready vars
@onready var cam_node: Node2D = $"."
@onready var cam: Camera2D = $Camera2D
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	pass 

func _physics_process(_delta: float) -> void:
	_apply_camera_movement()
	_apply_camera_zoom()
	pass

## public methods

static func move_camera(direction:Vector2,delta:float) -> void:
	cam_movement_velocity.x = direction.x * delta * 2000
	cam_movement_velocity.y = direction.y * delta * 2000

static func zoom_camera(direction:float,delta:float) -> void:
	cam_zoom_velocity += ((CAMERA_ZOOM_SPEED)* delta) * direction

## private methods

func _apply_camera_movement() -> void:
	if cam_movement_velocity != Vector2.ZERO:
		var camer_zoom_speed:float = remap(
			cam.zoom.x,
			CAMERA_ZOOM_RANGE.x,CAMERA_ZOOM_RANGE.y,
			CAMERA_ZOOM_RANGE.y,CAMERA_ZOOM_RANGE.x)
		cam_node.position.x += cam_movement_velocity.x * camer_zoom_speed
		cam_node.position.y += cam_movement_velocity.y * camer_zoom_speed
		cam_movement_velocity = Vector2.ZERO

func _apply_camera_zoom() -> void:
	if cam_zoom_velocity != 0:
		var calculated_zoom:float = cam.zoom.x + cam_zoom_velocity
		if (calculated_zoom > CAMERA_ZOOM_RANGE.x) and (calculated_zoom < CAMERA_ZOOM_RANGE.y):
			cam.zoom.x += cam_zoom_velocity
			cam.zoom.y += cam_zoom_velocity
	cam_zoom_velocity = 0
	pass
