extends Node2D

const UP = Vector2(0,-1)
const DOWN = Vector2(0,1)
const LEFT = Vector2(-1,0)
const RIGHT = Vector2(1,0)
const SKIN_WIDTH = 1

export (int) var buffer_size = 3 setget _set_buffer_size
var buffer = []

func _ready():
	_set_buffer_size(buffer_size)

func raycast(direction, rect, mask, exceptions = [], ray_length = 4, buffer = self.buffer):
	if !(direction == UP || direction == DOWN || direction == LEFT || direction == RIGHT):
		return 0
	
	var space_state = get_world_2d().direct_space_state
	var extents = rect.extents - Vector2(SKIN_WIDTH, SKIN_WIDTH)
	var count = 0
	var ray_count = buffer.size()
	var cast_to = (ray_length + SKIN_WIDTH) * direction
	var origin 
	var spacing
	
	if (direction == UP || direction == DOWN):
		spacing = (extents.x * 2) / (ray_count - 1)
	else:
		spacing = (extents.y * 2) / (ray_count - 1)
	
	for i in range(ray_count):
		if (direction == UP || direction == DOWN):
			origin = Vector2(-extents.x + spacing * i + 1, extents.y)
			if (direction == UP):
				origin.y = -origin.y
		else:
			origin = Vector2(extents.x, -extents.y + spacing * i)
			if (direction == LEFT):
				origin.x = -origin.x
		var result = space_state.intersect_ray(global_position + origin, global_position + origin + cast_to, exceptions, mask)
		if result:
			buffer[count] = result
			count += 1
	return {buffer = buffer, count = count}

func _set_buffer_size(val):
	var buffer_size = max(val, 2)
	buffer.resize(buffer_size)
	
