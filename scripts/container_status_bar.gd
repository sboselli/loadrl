extends Control

var loadRL


func _ready():
	loadRL = get_node("/root/loadRL")
	loadRL.connect("state_updated", self, "_update_status")
	
	$status_bar.set("custom_colors/font_color", loadRL.COLOR_NOT_INSTALLED)
	
	$motd.set("custom_colors/font_color", loadRL.COLOR_NOT_INSTALLED)
	$motd.set("custom_colors/font_color_hover", loadRL.COLOR_YELLOW)


func _update_status():
	$status_bar.text = str(loadRL.state.total_games_installed) + " games installed (" + str(loadRL.state.total_versions_installed) + " versions), " + str(loadRL.state.total_games) + " total"

func _update_motd(msg):
	$motd.text = msg

func _on_motd_pressed():
	if !loadRL.waiting:
		OS.shell_open("https://github.com/sboselli/loadrl/releases")
