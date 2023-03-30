extends KinematicBody

enum STATES {FOLLOWING=0, ATTACKING=1}

export var speed:float = 25.0 setget set_speed
export var acceleration:float = 10.0

onready var player:KinematicBody = get_tree().get_nodes_in_group("player")[0]

var velocity:Vector3 = Vector3.ZERO
var current_state:int = STATES.FOLLOWING

func set_speed(value:float):
	speed = value
	$NavigationAgent.max_speed = speed

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $NavigationAgent.is_target_reached():
		current_state = STATES.FOLLOWING
		$NavigationAgent.set_target_location(player.global_transform.origin)
		var next_location:Vector3 = $NavigationAgent.get_next_location()
		var current_pos:Vector3 = self.global_transform.origin
		var dir:Vector3 = (next_location - current_pos)
		dir = dir.normalized()
		var vel:Vector3
		vel = lerp(vel, dir * speed, acceleration * delta)
		$NavigationAgent.set_velocity(vel)
	else:
		current_state = STATES.ATTACKING
		velocity = Vector3.ZERO
	
	if current_state == STATES.ATTACKING:
		if $AttackTimer.is_stopped():
			$AttackTimer.start()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += -9.81 * 3 * delta
	else:
		velocity.y = 0.0
	move_and_slide(velocity, Vector3.UP)

func _on_HealthSystem_enemy_is_dead():
	queue_free()


func _on_NavigationAgent_velocity_computed(safe_velocity):
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z





func _on_AttackTimer_timeout():
	if current_state == STATES.ATTACKING:
		if player.has_node("HealthSystem"):
			player.get_node("HealthSystem").set_health(rand_range(-5.0,-8.0))
