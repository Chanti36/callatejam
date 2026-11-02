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
var i_gameplay := 0 # 0 -> ZOOM IN // 1-> // 2-> // 3-> ZOOM OUT
var f_zoom := 0.0
var v2_gotoPos := Vector2(0,0)
var v2_defPos  := Vector2(0,0)
var v2_startPos  := Vector2(0,0)
var f_lerpPos  := 2.0

@onready var _monasterio: Sprite2D = $Gameplay/sceneZero/Monasterio
@onready var _circleTransition: ColorRect = $Transition/CircleTransition

@onready var button_1: Button = $Gameplay/sceneOne/Control/HBoxContainer/Button1
@onready var button_2: Button = $Gameplay/sceneOne/Control/HBoxContainer/Button2
@onready var circle_1: ColorRect = $Gameplay/sceneOne/Control/HBoxContainer2/Circle1
@onready var circle_2: ColorRect = $Gameplay/sceneOne/Control/HBoxContainer2/Circle2


var f_circleLerp := -3.0
var b_sceneChange := false

var f_opt := 0.0
var i_selectedOpt := 1


var b_1ready := false

#ending


func _ready() -> void:
	$Shaders.visible = true
	$BootUp.visible  = true
	$Intro.visible   = true
	$Outro.visible   = false
	$Gameplay/sceneZero.visible = true
	$Gameplay/sceneOne.visible  = false
	
	$Intro/VideoStreamPlayer.play()
	f_circleLerp = -3.0
	f_lerpPos = 5.0
	v2_defPos = _monasterio.position
	v2_startPos = v2_defPos

func _process(delta: float) -> void:
	if f_hardtimer < .2:
		f_hardtimer+=delta
	elif f_hardtimer < 1:
		$Intro/VideoStreamPlayer.paused = true
		f_hardtimer = 2
	
	##DEBUG
	if Input.is_action_just_released("8"):
		i_gameState = 3
		DoOutro()
	if Input.is_action_just_released("debug"):
		if i_gameState == 0:
			i_gameState = 1
			$BootUp/AnimationPlayer.stop()
			$BootUp.visible = false
			
		elif i_gameState == 1: #intro
			$Intro.visible = false
			i_gameState = 2
			$Shaders/ByW.material.set_shader_parameter("saturation", 0.0)
			$UI/UI0.visible = true
			b_leftArrow = false
			b_rightArrow = false
			
		elif i_gameState == 2: #gameplay 0
			#$Gameplay/sceneZero
			pass
		
		elif i_gameState == 3: #gameplay 1
			print("debug")
	##___________________________________________________
	
	if i_gameState == 1:
		intro(delta)
	elif i_gameState == 2:
		Gameplay(delta)
	
	DisolveArrows(delta)
	Floating(delta)
	DoCircleTransition(delta)


#region GAMEPLAY

func Gameplay(delta:float) -> void:
	if   i_gameplay == 0: GameplayZero(delta)
	elif i_gameplay == 1: GameplayOne(delta)
	elif i_gameplay == 2: pass
	elif i_gameplay == 3: pass

func GameplayOne(delta : float) -> void:
	if !b_1ready: return
	
	if f_opt < 2:
		f_opt += delta
		if i_selectedOpt == 1: circle_1.material.set_shader_parameter("progress", f_opt * 0.5)
		if i_selectedOpt == 2: circle_2.material.set_shader_parameter("progress", f_opt * 0.5)
	else:
		f_opt = 2
		if i_selectedOpt == 1: button_2.modulate = Color.TRANSPARENT; DoButton(1); $Gameplay/sceneOne/Control/HBoxContainer2.visible = false
		if i_selectedOpt == 2: button_1.modulate = Color.TRANSPARENT; DoButton(2); $Gameplay/sceneOne/Control/HBoxContainer2.visible = false
		b_1ready = false
		

func DoButton(num:int)->void:
	if num == 1:
		print("SILENCIO")
	if num == 2:
		print("RESPUESTA")

func _on_gameplay1_options_finished(anim_name: StringName) -> void: 
	if anim_name =="showOptions":
		b_1ready = true
	elif anim_name == "carta":
		$UI.StartMessage()

func _on_button_1_focus_entered() -> void: i_selectedOpt = 1; f_opt = 0.0; ResetOptions()
func _on_button_2_focus_entered() -> void: i_selectedOpt = 2; f_opt = 0.0; ResetOptions()
func ResetOptions() -> void:
	circle_1.material.set_shader_parameter("progress", 0)
	circle_2.material.set_shader_parameter("progress", 0)

func PlayCartaSFX()->void:
	$Sounds/SFXPapel.play()

func GameplayZero(delta : float)->void:
	if Input.is_action_just_released("leftArrow"): b_leftArrow  = false;  $UI/UI0/LeftArrow.visible  = true
	if Input.is_action_just_pressed("leftArrow"):  b_leftArrow  = true;   $UI/UI0/LeftArrow.visible  = false
	if Input.is_action_just_released("rightArrow"):b_rightArrow = false; $UI/UI0/RightArrow.visible = true
	if Input.is_action_just_pressed("rightArrow"): b_rightArrow = true;  $UI/UI0/RightArrow.visible = false
	
	if !b_leftArrow || !b_rightArrow:
		return
	
	f_zoom += delta
	if f_zoom < 2:
		_monasterio.scale = Vector2(lerp(0.07, 0.9, f_zoom * .5), lerp(0.07, 0.9, f_zoom * .5))
	else:
		_monasterio.scale = Vector2(0.9, 0.9)
		if !$UI/UI0.visible:
			return
		$UI/UI0.visible = false
		$UI.StartDialogue()

func _on_text_finished() -> void:
	if i_gameplay == 0: f_circleLerp = 0.0
	if i_gameplay == 1: $Gameplay/sceneOne/AnimationPlayer.play("showOptions")

func DoCircleTransition(delta:float)->void:
	if f_circleLerp < -2:
		return
	
	f_circleLerp += delta
	if f_circleLerp < 2:
		_circleTransition.material.set_shader_parameter("_Progress", f_circleLerp * .5)
	elif f_circleLerp < 3:
		if !b_sceneChange:
			b_sceneChange = true
			if   i_gameplay == 0: 
				$Gameplay/sceneZero.visible = false
				$Gameplay/sceneOne.visible  = true
				$Gameplay/sceneOne/Control/HBoxContainer/Button1.grab_focus()
				i_gameplay = 1
			elif i_gameplay == 1: print("asd")
	elif f_circleLerp < 5:
		$Transition/Transition2.modulate = Color.BLACK.lerp(Color.TRANSPARENT, (f_circleLerp-3) * 0.5)
		_circleTransition.material.set_shader_parameter("_Progress", 0.0)
	else:
		b_sceneChange = false
		f_circleLerp = -3
		if i_gameplay == 1: $Gameplay/sceneOne/AnimationPlayer.play("carta")

func Floating(delta: float)->void:
	f_lerpPos += delta
	
	if f_lerpPos >= 5.0:
		f_lerpPos = 0.0
		v2_gotoPos = v2_defPos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		v2_startPos = _monasterio.position
	
	_monasterio.position = v2_startPos.lerp(v2_gotoPos, f_lerpPos * 0.2)
	#+-50
	#$Gameplay/sceneZero/Monasterio.position
	#$bg/space.position

#endregion

#region OUTRO
func DoOutro()->void:
	$Gameplay.visible = false
	$UI.visible = false
	$Outro.visible = true
	$Intro.visible = false
	$Outro/VideoStreamPlayer.play()
	$Outro/AnimationPlayer.play("outro")
	

func _on_outroVid_finished() -> void:
	return
	#$Outro/AnimationPlayer.play("outro")
	#print("TriggerANim")

#endregion

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
	$UI/UI0.visible = true
	b_leftArrow = false
	b_rightArrow = false

#endregion

#region BOOTUP
func _on_bootup_animation_finished(_anim_name: StringName) -> void:
	i_gameState = 1
	$BootUp.visible = false
#endregion
