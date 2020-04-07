extends Spatial

const DebugTracer = preload("res://DebugTracer.tscn")
const length = 1.5
const num_tracers = 10

var anim_tree : AnimationTree
var anim_playback : AnimationNodeStateMachinePlayback

func _ready():
	var debug_tracers = $Handle/DebugTracers
	for i in range(0,num_tracers):
		var tracer = DebugTracer.instance()
		tracer.translation.y = i * length / num_tracers
		debug_tracers.add_child(tracer)
	
	anim_tree = $AnimationTree
	anim_playback = $AnimationTree['parameters/playback']
	anim_playback.start('idle')


var anim_state_old = ''

func _process(_delta):
	var anim_state = anim_playback.get_current_node()
	
	if anim_state != anim_state_old:
		var swinging = anim_state in ['top','bottom','left','right']
		for tracer in $Handle/DebugTracers.get_children():
			tracer.tracing = swinging
	
	anim_state_old = anim_state


func swipe(dir : Vector2):
	assert(abs(dir.length_squared() - 1) < .001)
	
	var br = Vector2(1,1).normalized()
	var tr = Vector2(1,-1).normalized()
	var bl = Vector2(-1,1).normalized()
	var tl = Vector2(-1,-1).normalized()
	
	if is_between(dir, br, bl): #bottom
		#print('bottom ', inv_lerp(dir,bl,br))
		anim_tree['parameters/bottom/blend_position'] = inv_lerp(dir,bl,br)
		anim_playback.travel('bottom')
	elif is_between(dir, br, tr): #right
		#print('right ', inv_lerp(dir,br,tr))
		anim_tree['parameters/right/blend_position'] = inv_lerp(dir,br,tr)
		anim_playback.travel('right')
	elif is_between(dir, tr, tl): #top
		#print('top ', inv_lerp(dir,tl,tr))
		anim_tree['parameters/top/blend_position'] = inv_lerp(dir,tl,tr)
		anim_playback.travel('top')
	else: # left
		#print('left ', inv_lerp(dir,bl,tl))
		anim_tree['parameters/left/blend_position'] = inv_lerp(dir,bl,tl)
		anim_playback.travel('left')



# checks if v is between v1 and v2 or close
func is_between(v, v1, v2):
	var eps = 0.001
	return v.dot(v1) > -eps && v.dot(v2) > -eps

# finds alpha s.t.
# v = v_min * (1-alpha) + v_max * alpha
# Not very accurate
func inv_lerp(v, v_min, v_max):
	return (v-v_min).length()/(v_max-v_min).length()









