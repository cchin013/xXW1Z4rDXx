extends KinematicBody2D

#testtest

#Exported Variables
export var PLAYER_SPEED = 100
export var PLAYER_JUMP_SPEED = -500
export var Player_Gravity = 100
export var PlayerHealth = 100

#Global Variables
var BoltCooldown = 0
var JumpVelocity = 0
var MeleeTimer = 0

var jumping = false
var jumpReset = true
var LongJump = false
var JumpWait = false
var ShortHop = false
var moving = false
var hasSpell = {"lightning" : true, "fire" : true, "earth" : true, "water" : true}
var currentSpell = "lightning"
var playerSize
var Invincible = false
var IFrames = 0
var Dying = false
var StaggerCounter = 0
var DeathCounter = 0
var RayNode
var CurrSprite
var CurrCollision

var Animator

var UP = Vector2(0, -1)

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
	RayNode.set_rotation_degrees(-90)
	Animator = CurrSprite.get_node("general") # animation player
	playerSize = self.get_node("PlayerCollision").get_shape().get_extents()

##Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var motion = Vector2()
	var GravityMotion = Vector2(0, Player_Gravity)
	var collide_obj_id = 0
	moving = false
	
	if (PlayerHealth <= 0 and not Dying):
		Die()
		Dying = true
	if (IFrames > 0):
		if (IFrames % 6 == 0):
			self.modulate.a = 0
		else:
			self.modulate.a = 1
		IFrames -= 1
	else :
		Invincible = false
	if (DeathCounter > 0 or Dying):
		DeathCounter -= 1
		#if (DeathCounter == 0):
		#   queue_free()
		return
	if (StaggerCounter > 0):
		StaggerCounter -= 1
		return
	
	#Spell Wheel
	if (Input.is_action_pressed("ui_selectFire") && hasSpell["fire"]):
		currentSpell = "fire"
		
	if (Input.is_action_pressed("ui_selectLightning") && hasSpell["lightning"]):
		currentSpell = "lightning"
		
	if (Input.is_action_pressed("ui_selectEarth") && hasSpell["earth"]):
		currentSpell = "earth"
		
	if (Input.is_action_pressed("ui_selectWater") && hasSpell["water"]):
		currentSpell = "water"
		
	##Shoot
	if (Input.is_action_pressed("ui_shoot")):
		if (BoltCooldown <= 0):
			CreateBolt()
			BoltCooldown = 2
				
	##Punching
	if (Input.is_action_just_pressed("ui_melee") and MeleeTimer <= 0):
		MeleeTimer = 1
		SpawnMeleeHitbox()
		
	##Jumping
	if (Input.is_action_pressed("ui_up") and !jumping and test_move(get_transform(), Vector2(0,0.1)) and jumpReset):
		jumping = true
		LongJump = true
		jumpReset = false
		JumpVelocity = PLAYER_JUMP_SPEED
		Animator.play("jump")
		moving = true
	elif (Input.is_action_pressed("ui_up") and jumping and test_move(get_transform(), Vector2(0,0.1))):
		jumping = false
		LongJump = false
		ShortHop = false
		JumpWait = true
		JumpVelocity = 0
	##Left/Right Movement
	if (Input.is_action_pressed("ui_right")):
		motion += Vector2(1, 0)
		RayNode.set_rotation_degrees(-90)
		CurrSprite.flip_h = false
		Animator.play("run")
		moving = true
	if (Input.is_action_pressed("ui_left")):
		motion += Vector2(-1, 0)
		RayNode.set_rotation_degrees(90)
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
	##Handles Jump Physics	
	if (jumping and Input.is_action_pressed("ui_up") and LongJump):
		if ((JumpVelocity + Player_Gravity) < 20):
			JumpVelocity += 5
		moving = true
	elif (jumping and not Input.is_action_pressed("ui_up") and LongJump):
		if ((JumpVelocity + Player_Gravity) < 20):
			JumpVelocity += 5
		LongJump = false
		ShortHop = true
		moving = true
	elif (ShortHop):
		if ((JumpVelocity + Player_Gravity) < 20):
			JumpVelocity += 20
		if (test_move(get_transform(), Vector2(0,0.1))):
			ShortHop = false
			jumping = false
			JumpWait = true
			JumpVelocity = 0
		moving = true
	if (jumping and (JumpVelocity + Player_Gravity) >= 20):
		Animator.play("fall")
	if (JumpWait):
		if (not Input.is_action_pressed("ui_up")):
			jumpReset = true
			JumpWait = false
			
	##Ticks Down Bolt Cooldown
	BoltCooldown -= 2*delta
	##Gravity acceleration if not on ground
	if (test_move(get_transform(), Vector2(0,0.1))):
		Player_Gravity = 100
	else:
		Player_Gravity += 12
	if (jumping):
		motion[1] += JumpVelocity#*delta
		moving = true
	#GravityMotion *= delta
	##Finalizes motion vector and moves character
	motion[0] = motion[0]*PLAYER_SPEED#*delta
	motion[1] += GravityMotion[1]
	#Maximum Fall Speed
	if (motion[1] >= 450):
		motion[1] = 450
		
	var snap = Vector2.DOWN * 32 if (!jumping and test_move(get_transform(), Vector2(0,0.1))) else Vector2.ZERO
	move_and_slide_with_snap(motion, snap, UP)
	
#	if get_slide_count() > 0:
#		collide_obj_id = get_slide_collision(get_slide_count() - 1)
#		if collide_obj_id.collider.name == "PlatformV" or collide_obj_id.collider.name == "PlatformH":
#			self.set_sync_to_physics(true)
#		else:
#			self.set_sync_to_physics(false)
	
	if(!moving):
		Animator.play("idle")

##Spawns Spell Bolt
func CreateBolt():
	var Bolt
	var currRotation = "LightningRotation"
	if (currentSpell == "lightning"):
		currRotation = "LightningRotation"
		Bolt = load("res://Scenes/Lightning.tscn")
		
	elif (currentSpell == "fire"):
		currRotation = "FireballRotation"
		Bolt = load("res://Scenes/Fireball.tscn")
		
	elif (currentSpell == "earth"):
		currRotation = "EarthRotation"
		Bolt = load("res://Scenes/Earth.tscn")
		
	elif (currentSpell == "water"):
		currRotation = "WaterRotation"
		Bolt = load("res://Scenes/Water.tscn")
		
	var BoltInstance = Bolt.instance()
	BoltInstance.set_name("bolt")
	BoltInstance.get_node(currRotation).set_rotation_degrees(get_node("Rotation").get_rotation_degrees())
	var BoltPos = get_position()
	if (RayNode.get_rotation_degrees() == -90):
		BoltPos[0] += 8
	if (RayNode.get_rotation_degrees() == 90):
		BoltPos[0] -= 8
	BoltPos[1] -= 2
	BoltInstance.set_position(BoltPos)
	get_node("/root").add_child(BoltInstance)
	
##Spawns Melee Hitbox
func SpawnMeleeHitbox():
	var MeleeHit = load("res://Scenes/MeleeHit.tscn")
	var MeleeHitInstance = MeleeHit.instance()
	MeleeHitInstance.set_name("melee")
	var MeleeHitPos = get_position()
	if (RayNode.get_rotation_degrees() == -90):
		MeleeHitPos[0] += 16
	if (RayNode.get_rotation_degrees() == 90):
		MeleeHitPos[0] -= 16
	MeleeHitPos[1] += 2
	MeleeHitInstance.set_position(MeleeHitPos)
	get_node("/root").add_child(MeleeHitInstance)
	
	
func Take_Damage(damage):
	PlayerHealth -= damage
	StaggerCounter = 15
	Animator.play("hurt")
 
func Invincibility_Frames(numFrames):
	Invincible = true
	IFrames = numFrames
   
func Die():
	DeathCounter = 42
	Animator.play("die")
   
func PlayAnimation():
	pass
