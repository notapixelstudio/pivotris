extends Node2D

const STEP = 28

var Tile
var Pivot

var type
var tiles
var pivot
var color

var grid

func _ready():
	Tile = preload("res://Tile.tscn")
	Pivot = preload("res://Pivot.tscn")
	
func set_type(ty):
	type = ty
	
	if type == 'I':
		grid = [['-','X','-','-'],['-','P','-','-'],['-','X','-','-'],['-','X','-','-']]
		color = Color(1, 0, 0)
	elif type == 'T':
		grid = [['-','-','-','-'],['X','P','X','-'],['-','X','-','-'],['-','-','-','-']]
		color = Color(0, 1, 0)
	elif type == 'S':
		grid = [['-','-','X','-'],['-','P','X','-'],['-','X','-','-'],['-','-','-','-']]
		color = Color(0.2, 0.2, 1)
	elif type == 'Z':
		grid = [['-','X','-','-'],['X','P','-','-'],['X','-','-','-'],['-','-','-','-']]
		color = Color(1, 1, 0)
	elif type == 'L':
		grid = [['-','X','-','-'],['-','X','-','-'],['-','P','X','-'],['-','-','-','-']]
		color = Color(1, 0, 1)
	elif type == 'Y':
		grid = [['-','-','X','-'],['-','-','X','-'],['-','X','P','-'],['-','-','-','-']]
		color = Color(0, 1, 1)
	elif type == 'Q':
		grid = [['-','X','X','-'],['-','P','X','-'],['-','-','-','-'],['-','-','-','-']]
		color = Color(1, 1, 1)
		
	realize()

func realize():
	# clear
	for child in get_children():
		child.queue_free()
		
	tiles = []
	
	var t
	var l = 0
	for line in grid:
		var c = 0
		for cell in line:
			if cell != '-':
				t = Tile.instance()
				t.position.x += c*STEP
				t.position.y += l*STEP
				t.modulate = color
				add_child(t)
				tiles.append(t)
			c += 1
		l += 1
	
	l = 0
	for line in grid:
		var c = 0
		for cell in line:
			if cell == 'P':
				pivot = Pivot.instance()
				pivot.position.x += c*STEP
				pivot.position.y += l*STEP
				add_child(pivot)
			c += 1
		l += 1
		
func is_cell_valid(x,y):
	var line = int(floor(y/STEP))
	var col = int(floor(x/STEP))
	
	var clear = false
	for t in tiles:
		if int(floor(t.position.x/STEP)) == col and int(floor(t.position.y/STEP)) == line:
			clear = true
			break
	
	return clear
	
func move_pivot(di,dj):
	if is_cell_valid(pivot.position.x + STEP*dj, pivot.position.y + STEP*di):
		pivot.position.x += STEP*dj
		pivot.position.y += STEP*di
		
func rrotate(angle):
	var alpha = deg2rad(angle)
	
	# save pivot's position
	var px = pivot.position.x
	var py = pivot.position.y
	
	# rotate tiles
	for t in tiles:
		# translate according to pivot
		t.position.x -= px
		t.position.y -= py
		
		var newx = t.position.x*cos(alpha) - t.position.y*sin(alpha)
		var newy = t.position.x*sin(alpha) + t.position.y*cos(alpha)
		t.position.x = int(round(newx))
		t.position.y = int(round(newy))
		
		# translate according to pivot
		t.position.x += px
		t.position.y += py
		