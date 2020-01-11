extends Control

const MAIN_LIST_ITEM = preload("res://scenes/list_item.tscn")

var loadRL


func _ready():
	loadRL = get_node("/root/loadRL")
	loadRL.connect("state_updated", self, "_update_list")
	loadRL.connect("game_installed", self, "_update_list")
	loadRL.connect("game_selected_kb", self, "_on_game_selected_kb")


func _update_list():
	# Reset container list
	loadRL.delete_children($list_content/vbox)
	
	# Loop through games in db
	for g in loadRL.db.keys():
		# Instance the item and feed it a slug
		var item = MAIN_LIST_ITEM.instance()
		item.slug = g
		$list_content/vbox.add_child(item)


# When game is selected via keyboard, update the scroll bar
func _on_game_selected_kb():
	var idx = loadRL.db.keys().find(loadRL.selected)
	$list_content.set_v_scroll(idx * 11.5)	# this magic number... /facepalm
	$list_content.update()
