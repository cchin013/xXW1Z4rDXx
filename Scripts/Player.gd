extends KinematicBody2D

#Static Variables
export var PLAYER_SPEED = 200
export var PLAYER_JUMP_SPEED = -1800

#Global Variables
var Player_Gravity = 300
var BoltCooldown = 0
var JumpVelocity = 0
var MeleeTimer = 0

var jumping = false
var LongJump = false
var FastFall = false
var moving = false
var hasSpell = {"lightning" : true, "fire" : true, "earth" : false, "water" : false}
var currentSpell = "lightning"

var RayNode
var CurrSprite
var CurrCollision

var Animator

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

##Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	RayNode = get_node("Rotation")
	CurrSprite = get_node("PlayerSprite")
	CurrCollision = get_node("PlayerCollision")
	RayNode.set_rotation_degrees(0)
	Animator = CurrSprite.get_node("general") # animation player

##Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var motion = Vector2()
	var GravityMotion = Vector2(0, Player_Gravity)
	moving = false
	
	
	#Spell Wheel
	if (Input.is_action_pressed("ui_selectFire") && hasSpell["fire"]):
		print("fire selected")
		currentSpell = "fire"
		
	if (Input.is_action_pressed("ui_selectLightning") && hasSpell["lightning"]):
		print("lightning selected")
		currentSpell = "lightning"
		
	##Shoot
	if (Input.is_action_pressed("ui_shoot")):
		if (BoltCooldown <= 0):
			if (currentSpell == "lightning"):
				CreateLightning()
				BoltCooldown = 2
			elif (currentSpell == "fire"):
				CreateFire()
				BoltCooldown = 2
				
	##Punching
	if (Input.is_action_just_pressed("ui_melee") and MeleeTimer <= 0):
		MeleeTimer = 1
		SpawnMeleeHitbox()
		
	##Jumping
	if (Input.is_action_pressed("ui_up") and !jumping and test_move(get_transform(), Vector2(0,10))):
		jumping = true
		LongJump = true
		JumpVelocity = PLAYER_JUMP_SPEED
		Animator.play("jump")
		moving = true
	##Left/Right Movement
	if (Input.is_action_pressed("ui_right")):
		motion += Vector2(1, 0)
		RayNode.set_rotation_degrees(0)
		CurrSprite.flip_h = false
		Animator.play("run")
		moving = true
	if (Input.is_action_pressed("ui_left")):
		motion += Vector2(-1, 0)
		RayNode.set_rotation_degrees(180)
		CurrSprite.flip_h = true
		Animator.play("run")
		moving = true
	##Crouch, TODO
	if (Input.is_action_pressed("ui_down")):
		Animator.play("crouch")
		moving = true
		pass
	else:
		pass
		
	#Melee Hitbox Timing
	if (MeleeTimer >= 0):
		MeleeTimer -= 1*delta
		#if (MeleeTimer <= 0.4):
			#get_node("melee").queue_free()
	##Handles Jump Physics	
	if (jumping and Input.is_action_pressed("ui_up") and LongJump):
		JumpVelocity += 40
		moving = true
	elif (jumping and Input.is_action_just_released("ui_up") and LongJump):
		JumpVelocity += 100
		LongJump = false
		FastFall = true
		Animator.play("fall")
		moving = true
	elif (FastFall):
		JumpVelocity += 130
		if (test_move(get_transform(), Vector2(0,10))):
			FastFall = false
			jumping = false
			JumpVelocity = 0
		moving = true
	##Ticks Down Bolt Cooldown
	BoltCooldown -= 2*delta
	##Gravity acceleration if not on ground
	if (test_move(get_transform(), Vector2(0,10))):
		Player_Gravity = 300
	else:
		Player_Gravity += 40
	if (jumping):
		motion[1] += JumpVelocity#*delta
		moving = true
	#GravityMotion *= delta
	##Finalizes motion vector and moves character
	motion[0] = motion[0]*PLAYER_SPEED#*delta
	motion[1] += GravityMotion[1]
	move_and_slide(motion)
	
	if(!moving):
		Animator.play("idle")

##Spawns Lightning Bolt
func CreateLightning():
	var Lightning = load("res://Scenes/Lightning.tscn")
	var LightningInstance = Lightning.instance()
	LightningInstance.set_name("bolt")
	LightningInstance.get_node("LightningRotation").set_rotation_degrees(get_node("Rotation").get_rotation_degrees())
	var CurrPos = get_position()
	var LightningPos = Vector2()
	var playerSize = self.get_node("PlayerCollision").get_shape().get_extents()
	LightningPos[0] = CurrPos[0] + (playerSize[0])
	# (200 * cos(LightningInstance.get_node("LightningRotation").get_rotation_degrees()))
	LightningPos[1] = CurrPos[1] - (playerSize[1]/2)
	#+ (200 * sin(LightningInstance.get_node("LightningRotation").get_rotation_degrees()))
	LightningInstance.set_position(LightningPos)
	get_node("/root").add_child(LightningInstance)
	
##Spawns Melee Hitbox
func SpawnMeleeHitbox():
	var MeleeHit = load("res://Scenes/MeleeHit.tscn")
	var MeleeHitInstance = MeleeHit.instance()
	MeleeHitInstance.set_name("melee")
	var MeleeHitPos = get_position()
	MeleeHitPos[0] += 250 * cos(get_node("Rotation").get_rotation_degrees())
	MeleeHitPos[1] -= 85
	MeleeHitInstance.set_position(MeleeHitPos)
	get_node("/root").add_child(MeleeHitInstance)
	
func PlayAnimation():
	pass