extends KinematicBody2D

#testtest

signal healthChanged
signal manaChanged


var PlayerHealth = 100
var PlayerMana = 100

var PLAYER_SPEED = 7 * globals.TILE_SIZE
var MaxJumpHeight = 6 * globals.TILE_SIZE
var MinJumpHeight = 2 * globals.TILE_SIZE
var MaxJumpSpeed
var MinJumpSpeed
var Gravity
var JumpDuration = 0.44

#Global Variables
var BoltCooldown = 0
var JumpVelocity = 0
var MeleeTimer = 0

var is_grounded
var jumping = false
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
var startPos
var DisableInput = false
var ManaRegenCount = 30
var AttackAnimationTimer = 0
var Raycaster

var motion = Vector2()

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
	RayNode = $Rotation
	CurrSprite = $PlayerSprite
	CurrCollision = $PlayerCollision
	RayNode.set_rotation_degrees(-90)
	Animator = CurrSprite.get_node("general") # animation player
	playerSize = CurrCollision.get_shape().get_extents()
	startPos = get_global_transform()
	Raycaster = $Raycaster
	
	Gravity = 2 * MaxJumpHeight / pow(JumpDuration, 2)
	MaxJumpSpeed = -sqrt(2 * Gravity * MaxJumpHeight)
	MinJumpSpeed = -sqrt(2 * Gravity * MinJumpHeight)

##Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#motion = Vector2.ZERO
	var collide_obj_id = 0
	moving = false
	var count = Raycaster.raycast(Raycaster.DOWN, CurrCollision.shape, collision_mask).count
	var is_grounded = true if (count > 0) else false

	
	if (Input.is_action_just_pressed("ui_revive") and Dying):
		Revive()
		return
	
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
		DisableInput = true
		motion[0] = 0

	elif (StaggerCounter > 0):
		StaggerCounter -= 1
		DisableInput = true
		motion[0] = 0

	elif (AttackAnimationTimer > 0):
		motion[0] = 0
		Animator.play("attack")
		DisableInput = true
		AttackAnimationTimer -= 1
		if (AttackAnimationTimer == 30):
			SpawnMeleeHitbox()
	
	#Spell Wheel
	if (Input.is_action_pressed("ui_selectFire") && hasSpell["fire"]):
		currentSpell = "fire"
		
	if (Input.is_action_pressed("ui_selectLightning") && hasSpell["lightning"]):
		currentSpell = "lightning"
		
	if (Input.is_action_pressed("ui_selectEarth") && hasSpell["earth"]):
		currentSpell = "earth"
		
	if (Input.is_action_pressed("ui_selectWater") && hasSpell["water"]):
		currentSpell = "water"
	
	#Begin General Input Block	
	if (!DisableInput):
		##Shoot
		if (Input.is_action_pressed("ui_shoot")):
			if (BoltCooldown <= 0):
				CreateBolt()
				BoltCooldown = 2
					
		##Punching
		if (Input.is_action_just_pressed("ui_melee") and MeleeTimer <= 0):
			MeleeTimer = 1
			AttackAnimationTimer = 40
			#SpawnMeleeHitbox()
			
		if (is_grounded):
			jumping = false
			
		##Jumping
		#print(motion[1])
		#print(Input.is_action_pressed("ui_up"))
		if (Input.is_action_pressed("ui_up") and is_grounded):
			motion[1] = MaxJumpSpeed
			jumping = true
			
		if (!(Input.is_action_pressed("ui_up")) and jumping and motion[1] < MinJumpSpeed):
			motion[1] = MinJumpSpeed

		
		##Left/Right Movement
		
		if (Input.is_action_pressed("ui_right")):
			motion[0] = 1
			RayNode.set_rotation_degrees(-90)
			CurrSprite.flip_h = false
			Animator.play("run")
			moving = true
		elif (Input.is_action_pressed("ui_left")):
			motion[0] = -1
			RayNode.set_rotation_degrees(90)
			CurrSprite.flip_h = true
			Animator.play("run")
			moving = true
		else:
			motion[0] = 0
		##Crouch, TODO
		if (Input.is_action_pressed("ui_down")):
			Animator.play("crouch")
			moving = true
			pass
		else:
			pass
	#End General Input Block	
		
	#Melee Hitbox Timing
	if (MeleeTimer >= 0):
		MeleeTimer -= 1*delta
			
	if (ManaRegenCount <= 0):
		if (PlayerMana < 100):
			PlayerMana += 1
			emit_signal("manaChanged", 1)
		ManaRegenCount = 30
	ManaRegenCount -= 1
	##Ticks Down Bolt Cooldown
	BoltCooldown -= 2*delta

	##Finalizes motion vector and moves character
	motion[0] = motion[0]*PLAYER_SPEED
	motion[1] += Gravity*delta
	#Maximum Fall Speed
	motion[1] = clamp(motion[1], -2000, 450)
	if (is_grounded):
		motion[1] = clamp(motion[1], -2000, 100)
		
	#var snap = Vector2.DOWN * 32 if (!jumping and test_move(get_transform(), Vector2(0,0.1))) else Vector2.ZERO
	move_and_slide(motion, UP)
	
#	if get_slide_count() > 0:
#		collide_obj_id = get_slide_collision(get_slide_count() - 1)
#		if collide_obj_id.collider.name == "PlatformV" or collide_obj_id.collider.name == "PlatformH":
#			self.set_sync_to_physics(true)
#		else:
#			self.set_sync_to_physics(false)
	
	if(!moving and !DisableInput):
		Animator.play("idle")
	DisableInput = false

##Spawns Spell Bolt
func CreateBolt():
	var Bolt
	var manaCost
	var currRotation = "LightningRotation"
	if (currentSpell == "lightning" and PlayerMana >= 20):
		manaCost = -20
		currRotation = "LightningRotation"
		Bolt = load("res://Scenes/Lightning.tscn")
		
	elif (currentSpell == "fire" and PlayerMana >= 15):
		manaCost = -15
		currRotation = "FireballRotation"
		Bolt = load("res://Scenes/Fireball.tscn")
		
	elif (currentSpell == "earth" and PlayerMana >= 20):
		manaCost = -20
		currRotation = "EarthRotation"
		Bolt = load("res://Scenes/Earth.tscn")
		
	elif (currentSpell == "water" and PlayerMana >= 30):
		manaCost = -30
		currRotation = "WaterRotation"
		Bolt = load("res://Scenes/Water.tscn")
	else:
		return
		
	PlayerMana += manaCost
	emit_signal("manaChanged", manaCost)
	
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
	if (currentSpell == "water"):
		BoltPos = get_position() + Vector2(0,-16)
		get_node("/root").add_child(BoltInstance)
		PlayerHealth += 25
		return
	get_node("/root").add_child(BoltInstance)
	
##Spawns Melee Hitbox
func SpawnMeleeHitbox():
	var MeleeHit = load("res://Scenes/MeleeHit.tscn")
	var MeleeHitInstance = MeleeHit.instance()
	MeleeHitInstance.set_name("melee")
	var MeleeHitPos = get_position()
	if (RayNode.get_rotation_degrees() == -90):
		MeleeHitPos[0] += 32
	if (RayNode.get_rotation_degrees() == 90):
		MeleeHitPos[0] -= 32
	MeleeHitPos[1] += 2
	MeleeHitInstance.set_position(MeleeHitPos)
	get_node("/root").add_child(MeleeHitInstance)
	
	
func Take_Damage(damage):
	PlayerHealth -= damage
	StaggerCounter = 15
	emit_signal("healthChanged", damage)
	Animator.play("hurt")
 
func Invincibility_Frames(numFrames):
	Invincible = true
	IFrames = numFrames
   
func Die():
	DeathCounter = 42
	# Animator.play("die") There is no death
   
func Revive():
	PlayerHealth = 100
	emit_signal("healthChanged", 100, true)
	Dying = false
	self.set_transform(startPos)

func PlayAnimation():
	pass
