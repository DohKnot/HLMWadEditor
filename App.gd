extends Control

export(NodePath) var asset_tree
export(NodePath) var asset_tree_container
export(NodePath) var meta_editor_node
export(NodePath) var room_editor_node
export(NodePath) var sprite_editor_node
export(NodePath) var background_editor_node
export(NodePath) var object_editor_node
export(NodePath) var editor_tabs

var base_wad = null
var base_wad_path = ''
var recent_patches = []

var selected_asset_list_path = ''
var selected_asset_name = ''
var selected_asset_data = null
var thread = null

var show_base_wad = true

# Called when the node enters the scene tree for the first time.
func _init():
	var config = File.new()
	config.open('config.txt', File.READ_WRITE)
	base_wad_path = config.get_line()
	
	var num = min(int(config.get_line()), 6)
	for i in range(num):
		recent_patches.append(config.get_line())

func _ready():
	
	asset_tree = get_node(asset_tree)
	asset_tree_container = get_node(asset_tree_container)
	meta_editor_node = get_node(meta_editor_node)
	room_editor_node = get_node(room_editor_node)
	sprite_editor_node = get_node(sprite_editor_node)
	background_editor_node = get_node(background_editor_node)
	object_editor_node = get_node(object_editor_node)
	editor_tabs = get_node(editor_tabs)
	
	open_wad(base_wad_path)

func open_wad(file_path):
	var wad = Wad.new()
	if !wad.open(file_path, File.READ_WRITE):
		wad.parse_header()
		var s :SpritesBin= wad.parse_sprite_data()
		var o :ObjectsBin= wad.parse_objects()
		var r :RoomsBin = wad.parse_rooms()
		var b :BackgroundsBin = wad.parse_backgrounds()
		var files = wad.new_files.keys()
		files += wad.file_locations.keys()
		for file in files:
			if "Atlas" in file and (".meta" in file or ".gmeta" in file):
				asset_tree.create_path(file)
		for sprite_name in s.sprite_data.keys():
			asset_tree.create_path('Sprites/' + sprite_name)
		for background_name in b.background_data.keys():
			asset_tree.create_path('Backgrounds/' + background_name)
		for object_name in o.object_data.keys():
			asset_tree.create_path('Objects/' + object_name)
		for room_name in r.room_data.keys():
			asset_tree.create_path('Rooms/' + room_name)
		base_wad = wad

func open_asset(asset_path):
	selected_asset_list_path = asset_path
	if '.meta' in asset_path:
		editor_tabs.current_tab = 1
		selected_asset_name = asset_path
		selected_asset_data = meta_editor_node.set_asset(asset_path)
	if '.gmeta' in asset_path:
		editor_tabs.current_tab = 1
		selected_asset_name = asset_path
		selected_asset_data = meta_editor_node.set_asset(asset_path)
		selected_asset_data.is_gmeta = true
	if 'Rooms/' == asset_path.substr(0,len('Rooms/')):
		editor_tabs.current_tab = 2
		selected_asset_name = asset_path.substr(len('Rooms/'))
		selected_asset_data = room_editor_node.set_room(selected_asset_name)
	if 'Sprites/' == asset_path.substr(0,len('Sprites/')):
		editor_tabs.current_tab = 3
		selected_asset_name = asset_path.substr(len('Sprites/'))
		selected_asset_data = sprite_editor_node.set_sprite(selected_asset_name)
	if 'Objects/' == asset_path.substr(0,len('Objects/')):
		editor_tabs.current_tab = 5
		selected_asset_name = asset_path.substr(len('Objects/'))
		selected_asset_data = object_editor_node.set_object(selected_asset_name)
	if 'Backgrounds/' == asset_path.substr(0,len('Backgrounds/')):
		editor_tabs.current_tab = 4
		selected_asset_name = asset_path.substr(len('Backgrounds/'))
		selected_asset_data = background_editor_node.set_background(selected_asset_name)

func open_file_dialog(name, filter, oncomplete):
	pass


func _on_SearchBar_text_entered(new_text):
	asset_tree.reset()
	if new_text == '':
		var s :SpritesBin= base_wad.spritebin
		var o :ObjectsBin= base_wad.objectbin
		var r :RoomsBin = base_wad.roombin
		var b :BackgroundsBin = base_wad.backgroundbin
		for file in base_wad.new_files.keys():
			if "Atlas" == file.substr(0,len('Atlas')) and (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
				asset_tree.create_path(file, 1)
		if show_base_wad:
			for file in base_wad.file_locations.keys():
				if "Atlas" == file.substr(0,len('Atlas')) and (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
					asset_tree.create_path(file)
			for sprite_name in s.sprite_data.keys():
				asset_tree.create_path('Sprites/' + sprite_name)
			for background_name in b.background_data.keys():
				asset_tree.create_path('Backgrounds/' + background_name)
			for object_name in o.object_data.keys():
				asset_tree.create_path('Objects/' + object_name)
			for room_name in r.room_data.keys():
				asset_tree.create_path('Rooms/' + room_name)
		return
#		op
	else:
		for file in base_wad.new_files.keys():
			if "Atlas" == file.substr(0,len('Atlas')) and (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
				if new_text in file:
					asset_tree.create_path(file, 1)
		if show_base_wad:
			for file in base_wad.file_locations.keys():
				if "Atlas" == file.substr(0,len('Atlas')) and (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
					if new_text in file:
						asset_tree.create_path(file)
			for room_name in base_wad.roombin.room_data.keys():
				if new_text in room_name:
					asset_tree.create_path('Rooms/' + room_name)
			for sprite_name in base_wad.spritebin.sprite_data.keys():
				if new_text in sprite_name:
					asset_tree.create_path('Sprites/' + sprite_name)
			for object_name in base_wad.objectbin.object_data.keys():
				if new_text in object_name:
					asset_tree.create_path('Objects/' + object_name)
			for background_name in base_wad.backgroundbin.background_data.keys():
				if new_text in background_name:
					asset_tree.create_path('Backgrounds/' + background_name)


func _on_RecalculateSheetButton_pressed():
	thread = Thread.new()
	# Third argument is optional userdata, it can be any variable.
	var meta = meta_editor_node.meta
	meta.connect('resolve_progress', self, 'update_resolve_progress')
	thread.start(meta, "resolve", [meta.sprites, meta.texture_page], Thread.PRIORITY_HIGH)

func update_resolve_progress(v=0):
	print(v)

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	if thread:
		thread.wait_to_finish()


func _on_ExportSpriteStripButton_pressed():
	var w :FileDialog= get_node("ImportantPopups/ExportSpriteStripDialog")
	var meta = meta_editor_node.meta
	w.meta = meta
	w.sprite = meta_editor_node.current_sprite
	get_node("ImportantPopups").show()
	w.popup()

#func change_sprite_attr(sprite_name, attr, new_value):
#	pass

func _on_importSpriteStripButton_pressed():
	var w :FileDialog= get_node("ImportantPopups/ImportSpriteStripDialog")
	var nw :WindowDialog= get_node("ImportantPopups/ImportSpriteStripSliceDialog")
	var meta = meta_editor_node.meta
	nw.meta = meta
	nw.sprite = meta_editor_node.current_sprite
	get_node("ImportantPopups").show()
	w.popup()


func _on_AddResourceDialog_file_selected(path):
	base_wad.add_file(path)
	_on_SearchBar_text_entered('')
