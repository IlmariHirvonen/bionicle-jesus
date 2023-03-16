extends KinematicBody


export var speed:float = 50.0
export var jump_height:float = 10.0
export var jump_count:int = 1
export var mouse_sens:float = 0.3
export var acceleration:float = 10.0
export var mass:float = 3.0
export var projectile_scene:PackedScene

onready var head:Spatial = $Head
onready var camera:Camera = $Head/Camera

var velocity:Vector3 = Vector3.ZERO
var current_jump:int = 0
var gravity:float = -9.81

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func _process(delta):
	if Input.is_action_pressed("shoot"):
		var direct_state:PhysicsDirectSpaceState  = get_world().direct_space_state
		var collision:Dictionary = direct_state.intersect_ray($Head/Muzzle.global_transform.origin, Vector3($Head.global_translation.x, $Head.global_translation.y, $Head.global_translation.z * -100), [self])
		if collision:
			var proj_inst:Spatial = projectile_scene.instance()
			proj_inst.global_translation = $Head/Muzzle.global_transform.origin


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * mass * delta
	else:
		current_jump = 0
		velocity.y = 0
	if Input.is_action_just_pressed("jump") and current_jump != jump_count:
		current_jump += 1
		velocity.y = jump_height
	var direction:Vector3 = Vector3(Input.get_axis("move_l", "move_r"), 0 , Input.get_axis("move_f", "move_b"))
	direction = direction.normalized()
	var temp_velocity:Vector3 = Vector3.ZERO
	temp_velocity = temp_velocity.linear_interpolate(direction.rotated(Vector3.UP, rotation.y) * speed, acceleration * delta)
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP)
	
	if direction.length() > 0:
		$Head/Camera/MovementShake.add_trauma(1.0)
