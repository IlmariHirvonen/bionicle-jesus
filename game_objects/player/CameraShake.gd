extends Node

export var noise:OpenSimplexNoise
export var trauma_reduction_rate:float = 1.0
export var max_x:float  = 10.0
export var max_y:float = 10.0
export var max_z:float = 5.0
export var noise_speed:float = 50.0

var trauma:float = 0

onready var init_rotation:Vector3 = Vector3.ZERO
onready var camera:Camera = get_parent()
var time:float = 0

func _ready() -> void:
	pass

func _process(delta)->void:
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	camera.rotation_degrees.x = init_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	camera.rotation_degrees.y = init_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	camera.rotation_degrees.z = init_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)


func add_trauma(trauma_amount: float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)
	
func get_shake_intensity() ->float: 
	return trauma * trauma

func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
