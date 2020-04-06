extends KinematicBody

# Walking variables.
# This manages how fast we are moving, fast we can walk,
# how quickly we can get to top speed, how strong gravity is, and how high we jump.
const GRAVITY = -100
var vel = Vector3()
const MAX_SPEED = 15
const ACCEL= 10

# A vector for storing the direction the player intends to move towards.
var dir = Vector3()


# How fast we slow down, and the steepest angle that counts as a floor (to the KinematicBody).
const DEACCEL= 32
const MAX_SLOPE_ANGLE = 40

# The camera and the rotation helper.
# We need the camera to get its directional vectors.
# We rotate ourselves on the Y-axis using the rotation_helper to avoid rotating on more than one axis at a time.
var camera
var rotation_helper

# The sensitivity of the mouse
# (Higher values equals faster movements with the mouse. Lower values equals slower movements with the mouse)
# (You may need to adjust depending on the sensitivity of your mouse)
var MOUSE_SENSITIVITY = 0.05




func _ready():
	
	# Get the camera and the rotation helper
	camera = $RotationHelper/Camera
	rotation_helper = $RotationHelper
	
	# We need to capture the mouse in order to use it for a FPS style camera control.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	


func process_input(_delta):
	# ----------------------------------
	# Walking
	# Based on the action pressed, we move in a direction relative to the camera.
	
	# Reset dir, so our previous movement does not effect us
	dir = Vector3()
	# Get the camera's global transform so we can use its directional vectors
	var cam_xform = camera.get_global_transform()
	
	# Create a vector for storing our keyboard/joypad input
	var input_movement_vector = Vector2()
	
	# Add keyboard input
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x = 1
	
	# Normalize the input movement vector so we cannot move faster if we have
	# keyboard movement and joypad movement at the same time.
	input_movement_vector = input_movement_vector.normalized()
	
	# Add the camera's local vectors based on what direction we are heading towards.
	# NOTE: because the camera is rotated by -180 degrees
	# all of the directional vectors are the opposite in comparison to our KinematicBody.
	# (The camera's local Z axis actually points backwards while our KinematicBody points forwards)
	# To get around this, we flip the camera's directional vectors so they point in the same direction
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------
	
	

func process_movement(delta):
	# Process our movements (influenced by our input) and sending them to KinematicBody
	
	# Assure our movement direction on the Y axis is zero, and then normalize it.
	dir.y = 0
	dir = dir.normalized()
	
	# Apply gravity
	vel.y += delta*GRAVITY
	
	# Set our velocity to a new variable (hvel) and remove the Y velocity.
	var hvel = vel
	hvel.y = 0
	
	var target = dir * MAX_SPEED
	
	
	# If we have movement input, then accelerate.
	# Otherwise we are not moving and need to start slowing down.
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	# Interpolate our velocity (without gravity), and then move using move_and_slide
	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0,1,0), true, 4, deg2rad(MAX_SLOPE_ANGLE), true);


# Mouse based camera movement
func _input(event):
	
	# Make sure the event is a mouse motion event, and that the cursor is captured
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var x_change_deg = event.relative.y * MOUSE_SENSITIVITY * -1
		var y_change_deg = event.relative.x * MOUSE_SENSITIVITY * -1

		# We need to clamp the rotation_helper's rotation so we cannot rotate ourselves upside down
		# We need to do this every time we rotate so we cannot rotate upside down with mouse
		var curr_x_rot = rad2deg(rotation_helper.rotation.x)
		if x_change_deg > 0:
			x_change_deg = min(x_change_deg, 70 - curr_x_rot)
		else:
			x_change_deg = max(x_change_deg, -70 - curr_x_rot)

		rotation_helper.rotate_x(deg2rad(x_change_deg))
		self.rotate_y(deg2rad(y_change_deg))
	
	if event is InputEventMouseButton:
		# if event.pressed is true then mouse button was just pressed
		# otherwise just released
		
		for tracer in $RotationHelper/DebugTracers.get_children():
			tracer.tracing = event.pressed
