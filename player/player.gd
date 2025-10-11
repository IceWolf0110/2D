extends CharacterBody2D

@onready var animation_spite_2d = $AnimatedSprite2D

const GRAVITY = 1000
@export var speed : int = 1000
@export var  max_horizontal_speed : int = 300
@export var slow_down_speed : int = 1700

@export var jump : int = -300
@export var jump_horizontal_speed : int = 1000
@export var  max_jump_horizontal_speed : int = 300

enum State { Idle, Run, Jump, Shoot }

var current_state : State


func _ready():
	current_state = State.Idle


func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_shooting(delta)
	
	move_and_slide()

	player_animations()

	print("State: ", State.keys()[current_state])


func player_falling(delta : float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta


func player_idle(_delta : float):
	if is_on_floor():
		current_state = State.Idle


func player_run(delta : float):
	if !is_on_floor():
		return

	var direction = input_movement()

	if direction:
		velocity.x += direction * speed * delta
		velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down_speed * delta)

	if direction != 0:
		current_state = State.Run
		animation_spite_2d.flip_h = false if direction > 0 else true


func player_jump(delta : float):
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump
		current_state = State.Jump
   
	if !is_on_floor() and current_state == State.Jump:
		var direction = input_movement()
		velocity.x += direction * jump_horizontal_speed * delta
		velocity.x = clamp(velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)


func player_shooting(_delta : float):
	var direction = input_movement()
	
	if direction != 0 and Input.is_action_just_pressed("shoot"):
		current_state = State.Shoot



func player_animations():
	if current_state == State.Idle:
		animation_spite_2d.play("idle")
	elif current_state == State.Run and animation_spite_2d.animation != "run_shoot":
		animation_spite_2d.play("run")
	elif current_state == State.Jump:
		animation_spite_2d.play("jump")
	elif current_state == State.Shoot:
		animation_spite_2d.play("run_shoot")


func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")

	return direction
