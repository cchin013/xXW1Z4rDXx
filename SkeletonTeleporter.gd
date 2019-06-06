extends TileMap

var Skelenode = 0
var dead = false
var telecell1 
var telecell2
var telecell3
var telecell4
var active = false
var playerpos
var x
var y


func _ready():
	pass # Replace with function body.

func _process(delta):
	
	# GET PLAYER POSITION EVERY FRAME 
	playerpos = get_node("/root/map/Player").get_global_transform()
	x = playerpos[2][0]
	y = playerpos[2][1]
	print(x," ", y)
	
	# THIS ENTIRE IF TREE CHECKS FOR THE SUPER SKELETON DEATH TO ACTIVATE THE TELEPORTER
	if (has_node("/root/map/Enemies/SuperSkeleton")):
		#print("this node exists bruh")
		Skelenode = get_node("/root/map/Enemies/SuperSkeleton").DeathCounter
		#print(Skelenode)
		if (Skelenode == 90):
			dead = true
		
	# CHECKS FOR SUPERSKELETON DEATH TO ACTIVATE TELEPORTER
	if (dead && !active):
		#telecell1 = get_cell(-29,18)
		#telecell2 = get_cell(-28,18)
		#telecell3 = get_cell(-26,-4)
		#telecell4 = get_cell(-25,-4)   all testing some stuff
		#print(telecell1)
		#print(telecell2)
		#print(telecell3)
		#print(telecell4)
		
		set_cell ( -29, 18, 4, false, false,false, Vector2( 0, 0 ))
		set_cell ( -28, 18, 5, false, false,false, Vector2( 0, 0 ))
		active = true
	
	if (active && x < -421 && y > 302):
		if (Input.is_action_pressed("Interact")):
			#get_node("/root/map/Player").set_transform(Transform2D(0, Vector2(-300, 302)))
			get_tree().change_scene("res://Level2.tscn")
			#print("we in it to win it")
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.