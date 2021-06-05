extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	update()
export(Texture) var origin_icon
export(Color) var icon_modulate
export(Color) var color

var origin_pos = Vector2.ZERO
var origin_draw_pos = Vector2.ZERO

onready var metaeditor = get_tree().get_nodes_in_group('MetaApp')[0]

func _draw():
	if !texture:return
	var sprite_w = texture.get_width()
	var window_w = rect_size.x
	var sprite_h = texture.get_height()
	var window_h = rect_size.y
	var sx = sprite_h / window_h
	var sy = sprite_w / window_w
	var x = window_w/2 - sprite_w/(2*sx)
	if x < 0:
		x = 0
		sx = 1
		sprite_w = window_w
	var y = window_h/2 - sprite_h/(2*sy)
	if y < 0:
		y = 0
		sy = 1
		sprite_h = window_h
	if sx <= 0: sx = 1
	if sy <= 0: sy = 1
	var dx = sprite_w / (sx)
	var dy = sprite_h / (sy)
	draw_rect(Rect2(x,y,dx,dy), color, false, 1)
	origin_draw_pos = Vector2(x,y) + (origin_pos/Vector2(texture.get_width(),texture.get_height())) * Vector2(dx, dy) - origin_icon.get_size()/2
	draw_texture(origin_icon, origin_draw_pos+Vector2.ONE, Color(0,0,0,0.3))
	draw_texture(origin_icon, origin_draw_pos, icon_modulate)
	
var moving = false

func _on_SpriteTextureRect_gui_input(event):
	var e : InputEvent = event
	if e.is_action_pressed("ui_lmb"):
		if get_local_mouse_position().distance_squared_to(origin_draw_pos + origin_icon.get_size()/2) < 500:
			moving = true
	if e.is_action_released('ui_lmb'):
		moving = false
	if e is InputEventMouseMotion and moving:
			if !texture:return
			var sprite_w = texture.get_width()
			var window_w = rect_size.x
			var sprite_h = texture.get_height()
			var window_h = rect_size.y
			var sx = sprite_h / window_h
			var sy = sprite_w / window_w
			var x = window_w/2 - sprite_w/(2*sx)
			if x < 0:
				x = 0
				sx = 1
				sprite_w = window_w
			var y = window_h/2 - sprite_h/(2*sy)
			if y < 0:
				y = 0
				sy = 1
				sprite_h = window_h
			if sx <= 0: sx = 1
			if sy <= 0: sy = 1
			var dx = sprite_w / (sx)
			var dy = sprite_h / (sy)
			origin_pos = (get_local_mouse_position() - Vector2(x+4,y+4) + origin_icon.get_size()/2) * Vector2(texture.get_width(),texture.get_height()) / Vector2(dx, dy)
			origin_pos = origin_pos.floor()
			origin_pos = Vector2(clamp(origin_pos.x,0,texture.get_width()), clamp(origin_pos.y,0,texture.get_height()))
			update()
#			metaeditor.app.base_wad.sprite_data[metaeditor.current_sprite]['center'] = origin_pos
			metaeditor.xorigin_node.value = origin_pos.x
			metaeditor.yorigin_node.value = origin_pos.y
			

