extends Node2D

const LINES = 20
const COLS = 10
var grid

const STEP = 28

const TETRAMINOES = 'ITLSZYQ'

var Tetramino
var Tile
var Cell

var tiles

var current

var t = 0
var period = 0.8
var dropt = 0

func _ready():
	Tetramino = preload("res://Tetramino.tscn")
	Tile = preload("res://Tile.tscn")
	Cell = preload("res://Cell.tscn")
	
	# the grid holds placed tiles
	grid = []
	for l in LINES:
		var line = []
		grid.append(line)
		for c in COLS:
			line.append(false)
			
	# draw the field
	for l in LINES:
		for c in COLS:
			var cell = Cell.instance()
			cell.position.x = STEP*c
			cell.position.y = STEP*l
			add_child(cell)
			
	tiles = []
	spawn()
	
func spawn():
	current = Tetramino.instance()
	current.position.x += STEP*3
	add_child(current)
	
	randomize()
	current.set_type(TETRAMINOES[randi() % 7])
	
func _process(delta):
	t += delta
	
	# move down almost each _period_ milliseconds
	if t >= period:
		t = 0
		advance()
		
	# increase speed over time
	period *= 0.9999
		
	# check inputs
	if Input.is_action_just_pressed("ui_right"):
		move(0,1)
	if Input.is_action_just_pressed("ui_left"):
		move(0,-1)
	if Input.is_action_just_pressed("ui_up"):
		move(-1,0)
	if Input.is_action_just_pressed("ui_down"):
		move(1,0)
		
	if Input.is_action_pressed("ui_select"):
		dropt += delta
		
	if dropt > 0.1:
		advance()
		dropt = 0
		
	if Input.is_action_just_pressed("ui_rcw"):
		rotate(90)
	if Input.is_action_just_pressed("ui_rccw"):
		rotate(-90)
	
func is_cell_full(x,y):
	var line = int(floor(y/STEP))
	var col = int(floor(x/STEP))
	
	return line < 0 or line >= LINES or col < 0 or col >= COLS or grid[line][col]
	
func advance():
	# check obstacles and boundaries
	var clear = true
	for t in current.tiles:
		if is_cell_full(current.position.x + t.position.x, current.position.y + t.position.y + STEP):
			clear = false
			break
			
	if clear:
		current.position.y += STEP
	else:
		freeze()
		
func freeze():
	for t in current.tiles:
		grid[int((current.position.y+t.position.y)/STEP)][int((current.position.x+t.position.x)/STEP)] = current.color
		
	# clear completed lines
	var completed_indices = []
	var i = 0
	for line in grid:
		var completed = true
		for cell in line:
			if not cell:
				completed = false
				break
		if completed:
			completed_indices.append(LINES-i)
		i += 1
		
	completed_indices.sort()
	
	for i in completed_indices:
		grid.remove(LINES-i)
		
	for i in completed_indices:
		var line = []
		for c in COLS:
			line.append(false)
		grid.push_front(line)
		
	# refresh graphics
	for tile in tiles:
		tile.queue_free()
		
	tiles = []
	
	var l = 0
	for line in grid:
		var c = 0
		for cell in line:
			if cell:
				var tile = Tile.instance()
				tile.position.x = c*STEP
				tile.position.y = l*STEP
				tile.modulate = cell
				add_child(tile)
				tiles.append(tile)
			c += 1
		l += 1
	
	current.queue_free()
	spawn()
	
func move(di,dj):
	current.move_pivot(di,dj)
	
func rotate(angle):
	current.rrotate(angle)
	
	# avoid overlaps
	for t in current.tiles:
		if is_cell_full(current.position.x + t.position.x, current.position.y + t.position.y):
			current.rrotate(-angle)
			break
	