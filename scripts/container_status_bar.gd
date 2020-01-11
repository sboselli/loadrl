extends Control

var loadRL


func _ready():
	loadRL = get_node("/root/loadRL")
	loadRL.connect("state_updated", self, "_update_status")
	
	$status_bar.set("custom_colors/font_color", loadRL.COLOR_NOT_INSTALLED)


func _update_status():
	$status_bar.text = str(loadRL.state.total_games_installed) + " games installed (" + str(loadRL.state.total_versions_installed) + " versions), " + str(loadRL.state.total_games) + " total"