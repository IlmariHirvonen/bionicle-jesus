extends KinematicBody


export var speed:float = 50.0
export var jump_height:float = 10.0
export var jump_count:int = 1
export var mouse_sens:float = 0.3
export var acceleration:float = 10.0
export var mass:float = 3.0
export var projectile_scene:PackedScene
export var fire_spread:Vector2 = Vector2(0,0)
export var auto_fire_weapon:bool = false

onready var head:Spatial = $Head
onready var camera:Camera = $Head/Camera

var velocity:Vector3 = Vector3.ZERO
var current_jump:int = 0
var gravity:float = -9.81
var can_fire:bool = true
var overheat_value:float = 0.0
var is_dead:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$"%PlayerAnimations".play("Idle")

func _input(event):
	if event is InputEventMouseMotion and not is_dead:
		rotate_y(deg2rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func _process(delta):
	if $"%ShootingRay".is_colliding():
		if  $"%ShootingRay".get_collider().is_in_group("enemy"):
			$"%Crosshair".modulate = Color.red
		else:
			$"%Crosshair".modulate = Color.white
	else:
		$"%Crosshair".modulate = Color.white
	if not is_dead:
		if Input.is_action_pressed("shoot") or auto_fire_weapon and can_fire:
			overheat_value += rand_range(3,4)
			overheat_value = clamp(overheat_value, 0.0, 100)
			$Head/Camera/ShootingShake.add_trauma(0.6)
			if overheat_value >= 100:
				can_fire = false
				$Cooldown.start()
				$"%PlayerAnimations".play("Overheat")
			if can_fire:
				fire_weapon()
				Fmod.play_one_shot("event:/shoot", self)
				$FireRate.start()
				can_fire = false
			var tween:SceneTreeTween = get_tree().create_tween()
			tween.tween_property($"%Overheat", "value", overheat_value, 0.2).set_trans(Tween.TRANS_CUBIC)

func fire_weapon()->void:
	$"%PlayerAnimations".play("Shoot")
	$"%ShootingRay".set_cast_to(Vector3(rand_range(fire_spread.x * -1,fire_spread.x), rand_range(fire_spread.y * -1,fire_spread.y), -100))
	var proj_inst:Spatial = projectile_scene.instance()
	get_tree().current_scene.add_child(proj_inst)
	proj_inst.global_translation = $Head/Muzzle.global_transform.origin
	if $"%ShootingRay".is_colliding():
		proj_inst.launch_direction = $"%ShootingRay".get_collision_point() - $Head/Muzzle.global_transform.origin
	else:
		proj_inst.launch_direction =  $"%ShootingRay".to_global($"%ShootingRay".get_cast_to()) - $Head/Muzzle.global_transform.origin

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * mass * delta
	else:
		current_jump = 0
		velocity.y = 0
	if not is_dead:
		if Input.is_action_just_pressed("jump") and current_jump != jump_count:
			Fmod.play_one_shot("event:/jump", self)
			current_jump += 1
			velocity.y = jump_height
		var direction:Vector3 = Vector3(Input.get_axis("move_l", "move_r"), 0 , Input.get_axis("move_f", "move_b"))
		direction = direction.normalized()
		var temp_velocity:Vector3 = Vector3.ZERO
		temp_velocity = temp_velocity.linear_interpolate(direction.rotated(Vector3.UP, rotation.y) * speed, acceleration * delta)
		velocity.x = temp_velocity.x
		velocity.z = temp_velocity.z
		if direction.length() > 0:
			$Head/Camera/MovementShake.add_trauma(1.0)
	velocity = move_and_slide(velocity, Vector3.UP)


func _on_FireRate_timeout():
	can_fire = true
	$"%PlayerAnimations".play("Idle")


func _on_Cooldown_timeout():
	overheat_value = 0.0
	var tween:SceneTreeTween = get_tree().create_tween()
	yield(tween.tween_property($"%Overheat", "value", overheat_value, 0.2).set_trans(Tween.TRANS_CUBIC),"finished")
	can_fire = true
	$"%PlayerAnimations".play("Idle")


func _on_HealthSystem_enemy_is_dead():
	is_dead = true
	$"%PlayerHud".visible = false
	$"%PlayerDead".visible = true
	$CollisionShape.shape.height = 0.1
	$Head.translation = Vector3.ZERO
	$Head.rotation = Vector3.ZERO
	$Head.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_HealthSystem_update_health(value):
	var tween:SceneTreeTween = get_tree().create_tween()
	tween.tween_property($"%Health", "value", value, 0.2).set_trans(Tween.TRANS_CUBIC)


func _on_Quit_pressed():
	get_tree().change_scene("res://levels/MainMenu.tscn")


func _on_Restart_pressed():
	get_tree().reload_current_scene()
