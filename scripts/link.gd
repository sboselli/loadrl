extends Control

var loadRL
var text = "Google"
var url = "http://www.google.com"


func _ready():
	# Get root ref
	loadRL = get_node("/root/loadRL")
	
	# Set container size. Min size required to not get squashed by vboxcontainer
	self.rect_min_size = Vector2(140, 20)
	
	# Set text & color
	$btn.text = text
	$btn.set("custom_colors/font_color", loadRL.COLOR_PARAGRAPH)
	$btn.set("custom_colors/font_color_hover", loadRL.COLOR_HOVER)


func _on_btn_pressed():
	if !loadRL.waiting:
		OS.shell_open(url)
