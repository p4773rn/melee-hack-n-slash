extends ImmediateGeometry

var line_strips = [[]]

var tracing = false setget set_tracing

func set_tracing(tracing_):
	tracing = tracing_
	if tracing_:
		line_strips = [[]]


func _ready():
	var material = SpatialMaterial.new()
	material.flags_unshaded = true
	material.vertex_color_use_as_albedo = true
	set_material_override(material)
	

func _process(_delta):
	if tracing:
		var line_strip = line_strips.back()
		var pos = global_transform.origin
		if line_strip.empty() || line_strip.back().distance_to(pos) > .1:
			line_strip.append(pos)
	
	clear()
	for strip in line_strips:
		begin(Mesh.PRIMITIVE_LINE_STRIP)
		set_color(Color(1,0,0))
		for pos in strip:
			add_vertex(global_transform.xform_inv(pos))
		end()
	

