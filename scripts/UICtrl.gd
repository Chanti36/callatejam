extends Control
@onready var sfx_tic: AudioStreamPlayer = $"../Sounds/SFXTic"
@onready var sfx_tac: AudioStreamPlayer = $"../Sounds/SFXTac"

@onready var _subtitulosscn1: RichTextLabel = $Subtitulos
@onready var _subtitulosscn2: RichTextLabel = $"../Gameplay/sceneOne/Control/RichTextLabel"

@onready var _subtitulos: RichTextLabel = $Subtitulos
@onready var _contador  : RichTextLabel = $Contador
var i_sfx := 1
var i_wordCount := 29

var firstDialogue := ["Las palabras te condenarán", "despidete"]
var secondMsg     := ["Alejarte no sirvió de nada", "Aquí no llegan bien las señales"] #-> 7
#RESPONDER
var badEnding     := ["El silencio atronó el cielo durante horas.", 
					  "Mis manos te buscan al crear",
					  "Quien querrá ver esto" ]

var goodEnding     := ["Siempre recordaré ese día",
					   "Conservaré este recuerdo como una revelación." ]


var displayDialogue := ["",""]
var b_showingText = false
var i_dialogueIndex := 0
var f_textTimer  :=  0.0
var f_phraseWait := -2.0

var b_fadeout := false
var f_lerpFade := 0.0

var b_disappear := true

func StartDialogue() -> void:
	_subtitulos = _subtitulosscn1
	_subtitulos.add_theme_color_override("default_color", Color.WHITE)
	i_dialogueIndex = 0
	displayDialogue = firstDialogue
	
	f_textTimer = 0.0
	_subtitulos.visible_characters = 0
	_subtitulos.text = displayDialogue[0]
	_subtitulos.visible_characters = 0
	
	b_showingText = true
	b_disappear = true
	f_phraseWait = -2.0
	
func StartMessage() -> void:
	_subtitulos = _subtitulosscn2
	_subtitulos.add_theme_color_override("default_color", Color.WHITE)
	i_dialogueIndex = 0
	displayDialogue = secondMsg
	
	f_textTimer = 0.0
	_subtitulos.visible_characters = 0
	_subtitulos.text = displayDialogue[0]
	_subtitulos.visible_characters = 0
	
	b_showingText = true
	b_disappear = false
	f_phraseWait = -2.0


func _process(delta: float) -> void:
	
	if b_fadeout: FadeOut(delta); return
	if !b_showingText: return
	
	if f_phraseWait > 0.0:
		f_phraseWait -= delta
		return
	elif f_phraseWait > -1.0:
		PhraseEnd()
		f_phraseWait = -2.0
		return
	
	if _subtitulos.visible_ratio < 1:
		f_textTimer += delta
		if f_textTimer > 0.1:
			_subtitulos.visible_characters += 1
			$"../Sounds/sfxWord".play()
			f_textTimer = 0.0
			TextSfx(false)
	else:
		_subtitulos.visible_ratio = 1
		#print("adajkhsdjka.>>>", _subtitulos.text)
		if _subtitulos.text != "": # LO VUELVE A LLAMAR AQUÍ PQ NO SE HA TERMINADO!!!!
			TextSfx(true)
		f_phraseWait = 2.0


func PhraseEnd() -> void:
	i_dialogueIndex += 1
	#LAST PHRASE OF DIALOGUE
	if i_dialogueIndex >= displayDialogue.size():
		if b_disappear:
			b_fadeout = true
		else:
			FINISHED.emit()
		b_showingText = false
		return
	#CONTINUE NEXT
	f_textTimer = 0.0
	_subtitulos.visible_characters = 0
	_subtitulos.text = displayDialogue[i_dialogueIndex]

func FadeOut(delta : float)->void:
	f_lerpFade += delta
	if f_lerpFade > 1:
		_subtitulos.add_theme_color_override("default_color", Color.WHITE.lerp(Color.BLACK, (f_lerpFade - 1) * 0.5))
	if f_lerpFade > 3:
		b_fadeout = false
		_subtitulos.text = ""
		FINISHED.emit()

signal FINISHED

func TextSfx(b_end : bool)->void:
	if b_end:
		UseWord()
		return
	
	if _subtitulos.visible_characters - 1 < 0:
		return
	if _subtitulos.text[_subtitulos.visible_characters - 1] == " ":
		UseWord()

func UseWord()->void:
	i_wordCount -= 1
	_contador.text = str(i_wordCount)
	if i_sfx < 0: sfx_tac.play()
	else:         sfx_tic.play()
	i_sfx *= - 1
