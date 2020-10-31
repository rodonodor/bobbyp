extends KinematicBody2D

# This demo shows how to build a kinematic controller.

# Member variables
const GRAVITY = 400.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
# const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 6600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 500
const STOP_FORCE = 5
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2
const SLOW_FORCE = 400

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

#animation
const ELAPSED_TIME = .2
const ELAPSED_TIMEF = .1

var velocity = Vector2()
var on_air_time = 50
var push_time = 100
var jumping = false
var should_push = false
var prev_jump_pressed = false
var prev_push_pressed = false
var time_passed = 2
var time_passedF = 2
var time_passedP = 2

func _physics_process(delta):
	# Create forces
	var force = Vector2(0, GRAVITY)
	
	# Takes in inputs
	var walk_left = Input.is_action_pressed("left")
	var jump = Input.is_action_pressed("up")
	var push = Input.is_action_pressed("space")
	
	# resets values
	var slow = false
	var stop = true
	
	
	if time_passed > 50000000:
		time_passed = 2
	if time_passedF > 50000000:
		time_passedF = 2
	if time_passedP > 50000000:
		time_passedP = 2
	
	# default state
	if not push and not slow and not jumping:
		$Sprite.play("default")
	
	# if press left and moving right, slow
	if walk_left:
		if velocity.x > 0 or velocity.x <= -WALK_MAX_SPEED:
			slow = true
	
	
	if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
		if should_push:
			time_passed = 0
		if time_passed >= ELAPSED_TIME and time_passed <= 1:
			force.x += WALK_FORCE
			time_passed = 2
			stop = false
		
	if push and is_on_floor():
		$Sprite.play("push_anim")
	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		
		velocity.x = vlen * vsign
		
	# code for slowing down
	if slow and is_on_floor():
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= SLOW_FORCE * delta
		if vlen < 0:
			vlen = 0
		
		$Sprite.play("stop_anim")
		
		velocity.x = vlen * vsign
	
	# Integrate forces to velocity
	velocity += force * delta	
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		on_air_time = 0
		
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
	
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		time_passedF = 0
	if time_passedF >= ELAPSED_TIMEF and time_passedF <= 1:
		velocity.y = -JUMP_SPEED
		jumping = true
		time_passedF = 2
	if on_air_time > 0:
		$Sprite.play("ollie")
	
	if velocity.y > .1:
		$Sprite.play("fall")
	
	should_push = false
	
	if is_on_floor() and push and abs(velocity.x) < WALK_MAX_SPEED and not prev_push_pressed:
		should_push = true
	
	on_air_time += delta
	time_passed += delta
	time_passedF += delta
	push_time += delta
	prev_jump_pressed = jump
	prev_push_pressed = push
