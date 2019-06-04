extends MarginContainer

onready var number_label = $Bars/LifeBar/Count/Background/Number
onready var bar = $Bars/LifeBar/Gauge
onready var tween = $Tween
var player_max_health = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player_max_health = $"../../Player".PlayerHealth
	bar.max_value = player_max_health
	bar.value = player_max_health
	number_label.text = str(player_max_health)
	

func _on_Player_healthChanged(value, revive=false):
	update_health(value, revive)

func update_health(value, revive):
	var new_value
	
	if revive:
		new_value = player_max_health
	else:
		new_value = bar.value - value if ((bar.value - value) > 0) else 0
		
	number_label.text = str(new_value)
	bar.value = new_value
