extends KinematicBody2D

#testtest

signal healthChanged
signal manaChanged


var PlayerHealth = 100
var PlayerMana = 100

var PLAYER_SPEED = 7 * globals.TILE_SIZE
var MaxJumpHeight = 6 * globals.TILE_SIZE + 8
var MinJumpHeight = 2 * globals.TILE_SIZE + 8
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
var fullstop = false
var crouching
var DoAnimationLogic = true
var hasSpell = {"lightning" : true, "fire" : true, "earth" : true, "water" : true}
var currentSpell = "lightning"
var playerSize
var Invincible = false
var IFrames = 0
var Dying = false
var StaggerCounter = 0
var DeathCounter = 0
var CrouchCounter = 0
var CrouchAttackCounter = 0
var CurrSprite
var CurrCollision
var startPos
var DisableInput = false
var ManaRegenCount = 30
var AttackAnimationTimer = 0
var Raycaster


var walk_direction = 0
var velocity = Vector2()
var facing = 1

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
	CurrSprite = $PlayerSprite
	CurrCollision = $PlayerCollision
	Animator = CurrSprite.get_node("general") # animation player
	playerSize = CurrCollision.get_shape().get_extents()
	startPos = get_global_transform()
	Raycaster = $Raycaster
	
	Gravity = 2 * MaxJumpHeight / pow(JumpDuration, 2)
	MaxJumpSpeed = -sqrt(2 * Gravity * MaxJumpHeight)
	MinJumpSpeed = -sqrt(2 * Gravity * MinJumpHeight)

##Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collide_obj_id = 0
	
	#checks if player is on the grounded
	var collision_count = Raycaster.raycast(Raycaster.DOWN, CurrCollision.shape, collision_mask).count
	var is_grounded = true if (collision_count > 0) else false
	
	#checks if player's head is hitting ceiling
	var collision_count2 = Raycaster.raycast(Raycaster.UP, CurrCollision.shape, collision_mask).count
	var hitting_ceiling = true if (collision_count2 > 0) else false

	
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
		fullstop = true
		DoAnimationLogic = false

	elif (StaggerCounter > 0):
		StaggerCounter -= 1
		DisableInput = true
		fullstop = true
		DoAnimationLogic = false
	elif (crouching):
		if (CrouchAttackCounter > 0):
			fullstop = true
			DisableInput = true
			Animator.play("crouch_slash")
			CrouchAttackCounter -= 1
			if (CrouchAttackCounter == 18):
				SpawnMeleeHitbox()
			if (CrouchAttackCounter == 0):
				Animator.play("crouch")
				Animator.seek(0.3, true)
		elif (CrouchCounter < 0):
			Animator.stop()
		else:
			Animator.play("crouch")
			CrouchCounter -= 1
		DoAnimationLogic = false
	elif (AttackAnimationTimer > 0):
		fullstop = true
		DisableInput = true
		DoAnimationLogic = false
		Animator.play("attack")
		AttackAnimationTimer -= 1
		if (AttackAnimationTimer == 30):
			SpawnMeleeHitbox()
	
	if (Input.is_action_pressed("quit")):
			get_tree().quit()
	
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
			if (crouching):
				CrouchAttackCounter = 24
				MeleeTimer = .45
			else:
				AttackAnimationTimer = 40
				MeleeTimer = .7

			
		if (is_grounded):
			pass
			
		##Jumping
		if (Input.is_action_pressed("ui_up") and !jumping and is_grounded):
			velocity[1] = MaxJumpSpeed
			jumping = true
			
		if (!(Input.is_action_pressed("ui_up")) and jumping and velocity[1] < MinJumpSpeed):
			velocity[1] = MinJumpSpeed
		
		if !(Input.is_action_pressed("ui_up")):
			jumping = false
		
		if (hitting_ceiling and velocity[1] < MinJumpSpeed + 200):
			velocity[1] = MinJumpSpeed + 201
		

		
		##Left/Right Movement
		if (Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left")):
			walk_direction = 1
			facing = 1
			#Animator.play("run")
		elif (Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right")):
			walk_direction = -1
			facing = -1
			#Animator.play("run")
		else:
			walk_direction = 0
			
		##Crouch, NEED TO FIX ANIMATION WHILE WALKING AND CROUCHING
		if (Input.is_action_pressed("ui_down") and !crouching):
			CrouchCounter= 15
			crouching = true
		elif (!Input.is_action_pressed("ui_down")):
			CrouchCounter = 0
			crouching = false

	#End General Input Block	
	
	if (facing == 1):
		CurrSprite.flip_h = false
	else:
		CurrSprite.flip_h = true
		
	#Melee Hitbox Timing
	if (MeleeTimer >= 0):
		MeleeTimer -= 1*delta
			
	#Mana Regen
	if (ManaRegenCount <= 0):
		if (PlayerMana < 100):
			PlayerMana += 1
			emit_signal("manaChanged", 1)
		ManaRegenCount = 30
	ManaRegenCount -= 1
	
	##Ticks Down Bolt Cooldown
	BoltCooldown -= 2*delta

	##Applies player speed and gravity to motion vector
	if (fullstop):
		velocity[0] = 0
	else:
		velocity[0] = lerp(velocity[0], walk_direction*PLAYER_SPEED, 0.11)
	if (abs(velocity[0]) < 10 and walk_direction == 0):
		velocity[0] = 0
		
	velocity[1] += Gravity*delta
	
	if (DoAnimationLogic):
		if (velocity[1] < 0 and !is_grounded):
			if (AttackAnimationTimer > 0):
				Animator.play("jump_attack")
			else:
				Animator.play("jump")
		elif (velocity[1] > 0 and !is_grounded):
			if (AttackAnimationTimer > 0):
				Animator.play("jump_attack")
			else:
				Animator.play("fall")
		elif (velocity[0] != 0):
			Animator.play("run")
		else:
			Animator.play("idle")
	
	#Clamps y velocity 
	if (is_grounded):
		velocity[1] = clamp(velocity[1], -1000, 100)
	else:
		velocity[1] = clamp(velocity[1], -1000, 450)
	
	#Moves the character
	move_and_slide(velocity, UP)
	
	DisableInput = false
	fullstop = false
	DoAnimationLogic = true

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
	var BoltPos = get_position()
	if (facing == -1):
		BoltInstance.get_node(currRotation).set_rotation_degrees(90)
		BoltPos[0] += 8
	if (facing == 1):
		BoltInstance.get_node(currRotation).set_rotation_degrees(-90)
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
	if (facing == 1):
		MeleeHitPos[0] += 32
	if (facing == -1):
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

func AnimationLogic():
	pass
