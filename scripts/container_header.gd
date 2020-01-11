extends Control

var loadRL

func _ready():
	loadRL = get_node("/root/loadRL")
	
	$btn_loadrl.set("custom_colors/font_color", loadRL.COLOR_INSTALLED)
	$btn_loadrl.set("custom_colors/font_color_hover", loadRL.COLOR_GREEN)
	
	$btn_exit.set("custom_colors/font_color", loadRL.COLOR_INSTALLED)
	$btn_exit.set("custom_colors/font_color_hover", loadRL.COLOR_RED)


# Show home screen
func _on_btn_loadrl_pressed():
	loadRL.set_selected("")


# Exit program
func _on_btn_exit_pressed():
	get_tree().quit()