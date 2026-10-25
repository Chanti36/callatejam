extends Node

var i_gameState := 0 # 0 -> BOOTUP // 1 -> INTRO // 2 -> GAMEPLAY // 3-> ENDING
var f_hardtimer := 0.0

#intro
var b_leftArrow  := false
var b_rightArrow := false
var f_leftTimer  := 0.0
var f_rightTimer := 0.0
var f_timer := 0.0
var b_toGrayscale := false
var f_colorSaturation := 1.0
#game

#ending


func _ready() -> void:
	$BootUp.visible = true
	$Intro.visible = true
	$Intro/VideoStreamPlayer.play()


func _process(delta: float) -> void:
	if f_hardtimer < .2:
		f_hardtimer+=delta
	elif f_hardtimer < 1:
		$Intro/VideoStreamPlayer.paused = true
		f_hardtimer = 2
	
	##DEBUG
	if Input.is_action_just_released("debug"):
		if i_gameState == 0:
			i_gameState = 1
			$BootUp/AnimationPlayer.stop()
			$BootUp.visible = false
			
		elif i_gameState == 1: 
			$Intro.visible = false
			i_gameState = 2
			$Shaders/ByW.material.set_shader_parameter("saturation", 0.0)
			$UI.StartDialogue()
			
		elif i_gameState == 2: 
			print("debug")
	##___________________________________________________
	
	if i_gameState == 1:
		intro(delta)
	elif i_gameState == 2:
		f_timer += delta
		pass
	
	DisolveArrows(delta)


#region INTRO
func intro(delta)-> void:
	if Input.is_action_pressed("leftArrow") && !b_leftArrow:
		$Intro/LeftArrow.modulate = Color.BLACK
		$Intro/LeftArrow.position = Vector2(0,542)
	if Input.is_action_just_released("leftArrow") && !b_leftArrow:
		$Intro/LeftArrow.position = Vector2(0,522)
		b_leftArrow = true
	
	if Input.is_action_pressed("rightArrow") && !b_rightArrow:
		$Intro/RightArrow.position = Vector2(1024,542)
	if Input.is_action_just_released("rightArrow") && !b_rightArrow:
		$Intro/RightArrow.position = Vector2(1024,522)
		b_rightArrow = true
	
	if b_leftArrow && b_rightArrow:
		$Intro/VideoStreamPlayer.paused = false
		if f_colorSaturation > 0.0:
			f_colorSaturation -= delta
		else: f_colorSaturation = 0.0
		$Shaders/ByW.material.set_shader_parameter("saturation", f_colorSaturation)


func DisolveArrows(delta : float)-> void:
	if b_leftArrow && f_leftTimer < 0.5:
		f_leftTimer += delta
		$Intro/LeftArrow.material.set_shader_parameter("dissolve_value", 1-f_leftTimer * 2)
	
	if b_rightArrow && f_rightTimer < 0.5:
		f_rightTimer += delta
		$Intro/RightArrow.material.set_shader_parameter("dissolve_value", 1-f_rightTimer * 2)

func _on_telon_finished() -> void:
	i_gameState = 2
	$UI.StartDialogue()

#endregion

#region BOOTUP
func _on_bootup_animation_finished(_anim_name: StringName) -> void:
	i_gameState = 1
	$BootUp.visible = false
#endregion
