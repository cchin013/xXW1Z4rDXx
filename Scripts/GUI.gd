extends MarginContainer

# Health Bar Variables
onready var hp_number_label = $Top/Bars/LifeBar/Count/Background/Number
onready var hp_bar = $Top/Bars/LifeBar/Gauge
var player_max_health = 0

# Mana Bar Variables
onready var mp_number_label = $Top/Bars/ManaBar/Count/Background/Number
onready var mp_bar = $Top/Bars/ManaBar/Gauge
var player_max_mana = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# Grab player variables
	player_max_health = $"../../Player".PlayerHealth
	player_max_mana = $"../../Player".PlayerMana
	
	# Initialize health bar
	hp_bar.max_value = player_max_health
	hp_bar.value = player_max_health
	hp_number_label.text = str(player_max_health)
	
	# Initialize mana bar
	mp_bar.max_value = player_max_mana
	mp_bar.value = player_max_mana
	mp_number_label.text = str(player_max_mana)

func _on_Player_healthChanged(value, revive=false):
	update_health(value, revive)

func _on_Player_manaChanged(value):
	update_mana(value)

func update_health(value, revive):
	var new_value
	
	if revive:
		new_value = player_max_health
	else:
		new_value = hp_bar.value - value if ((hp_bar.value - value) > 0) else 0
		
	hp_number_label.text = str(new_value)
	hp_bar.value = new_value

func update_mana(value):
	var new_value
	new_value = mp_bar.value + value if ((mp_bar.value - value) > 0) else 0
	mp_number_label.text = str(new_value)
	mp_bar.value = new_value
