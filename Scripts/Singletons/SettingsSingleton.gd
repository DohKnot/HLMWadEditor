extends Node

class_name Settings


var settings = {
	'base_wad_path':'',
	'recent_patches':[],
	'multithreading':false
}

func _init():
	var f = File.new()
	if f.open('user://config.txt', File.READ):
		save()
		f.open('user://config.txt', File.READ)
	var r = JSON.parse(f.get_as_text())
	if !r.error:
		settings = r.result
	f.close()


func save():
	var f = File.new()
	f.open('user://config.txt', File.WRITE)
	f.store_string(JSON.print(settings))
	f.close()

func _exit_tree():
	save()
