@tool
extends Control

@export_tool_button("Play", "Reload") var update = _update_elements

@export var big_text: Control
@export var small_texts_top: Array[TextureRect]
@export var small_texts_bottom: Array[TextureRect]

@export var anim_speed = 0.3

var tweens = []

func _ready() -> void:
	_update_elements()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_update_elements()

func _update_elements():
	if tweens:
		for tween in tweens:
			tween.kill()
		tweens.clear()
	
	_update_big()
	
	for i in range(len(small_texts_bottom)):
		var node = small_texts_bottom[i]
		_update_small(node, (i+1), i)
	
	for i in range(len(small_texts_top)):
		var node = small_texts_top[i]
		_update_small(node, -(i+1), i)
	

func _update_big():
	var target_pos = size / 2.0 - big_text.size / 2
	
	big_text.position = Vector2(size.x, target_pos.y)
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if tweens: tweens.append(tween)
	
	tween.tween_property(big_text, "position", target_pos, anim_speed)
	tween.tween_interval(3.0)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(big_text, "position", Vector2(-big_text.size.x, target_pos.y), anim_speed)


func _update_small(node: Control, y_offset: int, i: int):
	var texture = node.texture
	var texture_size = texture.get_size()
	
	node.size = Vector2(texture_size)
	node.size.x *= floor(float(big_text.size.x) / float(node.size.x))
	
	var target_pos = size / 2.0 - node.size / 2 
	
	target_pos.y += \
		sign(y_offset) * (big_text.size.y/2 - texture_size.y/2) + \
		y_offset * texture_size.y
	
	var scrolls_left = i % 2 == 1
	var x_offset = randf_range(0, texture_size.x)
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if tweens: tweens.append(tween)
	
	var exit_pos: Vector2
	if scrolls_left:
		node.position = Vector2(size.x , target_pos.y)
		exit_pos = Vector2(-node.size.x - texture_size.x, target_pos.y)
	else:
		node.position = Vector2(-node.size.x  - texture_size.x, target_pos.y)
		exit_pos = Vector2(size.x, target_pos.y)
	
	node.position.x += x_offset
	target_pos.x += x_offset
	exit_pos.x += x_offset
	tween.tween_property(node, "position", target_pos, anim_speed * randf_range(0.9, 1.1))
	tween.tween_interval(3.0 * randf_range(0.9, 1.1))
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(node, "position", exit_pos, anim_speed * randf_range(0.9, 1.1))
	
	var mat: ShaderMaterial = node.material
	mat.set_shader_parameter("scroll_speed", (-1 if scrolls_left else 1) * randf_range(0.5, 1.0))
	mat.set_shader_parameter("outline_color", Color("1c1b29"))
	mat.set_shader_parameter("outline_thickness", 2)
	
