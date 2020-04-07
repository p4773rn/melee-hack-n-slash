extends Node2D

const radius = 100
var dir = Vector2(1,0) setget set_dir
const color = Color(1,0,0)
const thickness = 5

func set_dir(dir_ : Vector2):
	var norm2 = dir_.length_squared()
	assert(-0.001 < norm2 && norm2 < 1.001)
	dir = dir_
	update()

func _draw():
	draw_arc(position, radius, 0, 2*PI, 100, color, thickness, false)
	
	var pos1 = position
	var pos2 = position + dir * radius * .8
	draw_line(pos1, pos2, color, thickness, false)

