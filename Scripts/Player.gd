extends KinematicBody2D

export var PLAYER_SPEED = 200


var RayNode
var Player_Gravity = 100
var BoltCooldown = 0
var CurrSprite
var CurrCollision

#COLLISION LAYER/MASK SETUP (TENTATIVE)
#1 = Player
#2 = Terrain
#3 = NOTHING ITS BUGGED
#4 = Lightning Bolt (Potentially all projectiles)
#5 = Enemies
#6-20 unused for now

#Z-INDEX (temp)
#0 = Terrain/Tiles
#1 = Projectiles
#2 = Enemies
#3 = Player

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	RayNode = get_node("Rotation")
	CurrSprite = get_node("PlayerSprite")
	CurrCollision = get_node("PlayerCollision")
	RayNode.set_rotation_degrees(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (RayNode.is_colliding()):
		print("reeee")
	var motion = Vector2()
	var GravityMotion = Vector2(0, Player_Gravity)
	
	if (Input.is_action_pressed("ui_shoot")):
		if (BoltCooldown <= 0):
			CreateLightning()
			BoltCooldown = 60
	if (Input.is_action_pressed("ui_up")):
		#todo
		pass
	if (Input.is_action_pressed("ui_right")):
		motion += Vector2(1, 0)
		RayNode.set_rotation_degrees(0)
	if (Input.is_action_pressed("ui_left")):
		motion += Vector2(-1, 0)
		RayNode.set_rotation_degrees(180)
	if (Input.is_action_pressed("ui_down")):
		#CurrSprite.texture = load("res://Assets/Sprites/testcrouch.png")
		#CurrSprite.scale = Vector2(1,1)
		#CurrCollision.scale = Vector2(0.35,0.35)
		#move_and_collide(Vector2(0,20))
		pass
	else:
		#CurrSprite.texture = load("res://Assets/Sprites/test123.png")
		#CurrSprite.scale = Vector2(0.3,0.3)
		#CurrCollision.scale = Vector2(1,1)
		#move_and_collide(Vector2(0,-20))
		pass
	BoltCooldown -= 1
	motion = motion.normalized()*PLAYER_SPEED*delta
	GravityMotion *= delta
	move_and_collide(motion)
	move_and_collide(GravityMotion)

func CreateLightning():
	var Lightning = load("res://Assets/Lightning.tscn")
	var LightningInstance = Lightning.instance()
	LightningInstance.set_name("bolt")
	LightningInstance.get_node("LightningRotation").set_rotation_degrees(get_node("Rotation").get_rotation_degrees())
	var CurrPos = get_position()
	var LightningPos = Vector2()
	LightningPos[0] = CurrPos[0] + (200 * cos(LightningInstance.get_node("LightningRotation").get_rotation_degrees()))
	LightningPos[1] = CurrPos[1] #+ (200 * sin(LightningInstance.get_node("LightningRotation").get_rotation_degrees()))
	LightningInstance.set_position(LightningPos)
	get_node("/root").add_child(LightningInstance)
	
