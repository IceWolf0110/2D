extends CharacterBody2D

@onready var animation_spite_2d = $AnimatedSprite2D

const GRAVITY = 1000
@export var speed : int = 1000
@export var max_horizontal_speed : int = 300
@export var slow_down_speed : int = 1700

@export var jump : int = -300
@export var jump_horizontal_speed : int = 1000
@export var max_jump_horizontal_speed : int = 300

var shoot_cooldown_timer : float = 0.0
var shoot_cooldown : float = 0.1  
var is_shooting : bool = false

enum State { Idle, Run, Jump }

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


func player_falling(delta : float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta


func player_idle(_delta : float):
	if is_on_floor():
		if current_state != State.Run:
			current_state = State.Idle


func player_run(delta : float):
	if !is_on_floor():
		return

	var direction = get_input_direction()

	if direction:
		velocity.x += direction * speed * delta
		velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
		if current_state == State.Idle:
			current_state = State.Run
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down_speed * delta)
		if current_state == State.Run:
			current_state = State.Idle

	if direction != 0:
		animation_spite_2d.flip_h = false if direction > 0 else true


func player_jump(delta : float):
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump
		current_state = State.Jump
   
	if !is_on_floor() and current_state == State.Jump:
		var direction = get_input_direction()
		velocity.x += direction * jump_horizontal_speed * delta
		velocity.x = clamp(velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)


func player_shooting(delta : float):
	# Cập nhật cooldown
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= delta
	else:
		is_shooting = false
	
	# Kiểm tra bắn khi ấn hoặc giữ nút
	if Input.is_action_pressed("shoot") and shoot_cooldown_timer <= 0:
		shoot_cooldown_timer = shoot_cooldown
		is_shooting = true
		# Tại đây bạn có thể thêm logic bắn (tạo đạn, âm thanh, v.v.)


func player_animations():
	# Nếu đang bắn, ưu tiên animation bắn
	if is_shooting:
		var direction = get_input_direction()
		if direction != 0:
			animation_spite_2d.play("run_shoot")
		else:
			animation_spite_2d.play("run_shoot")  # Hoặc tạo animation "idle_shoot" nếu cần
	else:
		# Nếu không bắn, dùng animation bình thường
		if current_state == State.Idle:
			animation_spite_2d.play("idle")
		elif current_state == State.Run:
			animation_spite_2d.play("run")
		elif current_state == State.Jump:
			animation_spite_2d.play("jump")


func get_input_direction() -> float:
	return Input.get_axis("move_left", "move_right")
