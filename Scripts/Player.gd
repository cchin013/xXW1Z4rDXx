extends KinematicBody2D

export var PLAYER_SPEED = 200
export var PLAYER_JUMP_SPEED = -1800


var RayNode
var Player_Gravity = 300
var BoltCooldown = 0
var jumping = false
var LongJump = false
var FastFall = false
var JumpVelocity = 0
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
	var motion = Vector2()
	var GravityMotion = Vector2(0, Player_Gravity)
	if (Input.is_action_pressed("ui_shoot")):
		if (BoltCooldown <= 0):
			CreateLightning()
			BoltCooldown = 60
	if (Input.is_action_pressed("ui_up") and !jumping and test_move(get_transform(), Vector2(0,10))):
		jumping = true
		LongJump = true
		JumpVelocity = PLAYER_JUMP_SPEED
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
	if (jumping and Input.is_action_pressed("ui_up") and LongJump):
		JumpVelocity += 40
	elif (jumping and Input.is_action_just_released("ui_up") and LongJump):
		JumpVelocity += 100
		LongJump = false
		FastFall = true
	elif (FastFall):
		JumpVelocity += 130
		if (test_move(get_transform(), Vector2(0,10))):
			FastFall = false
			jumping = false
			JumpVelocity = 0
	BoltCooldown -= 1
	motion[0] = motion[0]*PLAYER_SPEED#*delta
	if (test_move(get_transform(), Vector2(0,10))):
		Player_Gravity = 300
	else:
		Player_Gravity += 40
	if (jumping):
		motion[1] += JumpVelocity#*delta
	#GravityMotion *= delta
	motion[1] += GravityMotion[1]
	#print(motion[0])
	#print(motion[1])
	move_and_slide(motion)

func CreateLightning():
	var Lightning = load("res://Scenes/Lightning.tscn")
	var LightningInstance = Lightning.instance()
	LightningInstance.set_name("bolt")
	LightningInstance.get_node("LightningRotation").set_rotation_degrees(get_node("Rotation").get_rotation_degrees())
	var CurrPos = get_position()
	var LightningPos = Vector2()
	LightningPos[0] = CurrPos[0] + (200 * cos(LightningInstance.get_node("LightningRotation").get_rotation_degrees()))
	LightningPos[1] = CurrPos[1] - 100#+ (200 * sin(LightningInstance.get_node("LightningRotation").get_rotation_degrees()))
	LightningInstance.set_position(LightningPos)
	get_node("/root").add_child(LightningInstance)
	
	
	
	
	
