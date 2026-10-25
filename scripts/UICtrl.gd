extends Control
@onready var sfx_tic: AudioStreamPlayer = $"../Sounds/SFXTic"
@onready var sfx_tac: AudioStreamPlayer = $"../Sounds/SFXTac"

@onready var _subtitulos: RichTextLabel = $Subtitulos
@onready var _contador  : RichTextLabel = $Contador


var i_sfx := 1
var i_wordCount := 29

var firstDialogue := ["Las palabras os condenarán,", "tenéis 22,", "despedíos"]

var displayDialogue := ["",""]
var b_showingText = false
var i_dialogueIndex := 0
var f_textTimer  :=  0.0
var f_phraseWait := -2.0


func StartDialogue() -> void:
	i_dialogueIndex = 0
	displayDialogue = firstDialogue
	
	f_textTimer = 0.0
	_subtitulos.visible_characters = 0
	_subtitulos.text = displayDialogue[0]
	_subtitulos.visible_characters = 0
	
	b_showingText = true
	f_phraseWait = -2.0


func _process(delta: float) -> void:
	if b_showingText == false:
		return
	
	if f_phraseWait > 0.0:
		f_phraseWait -= delta
		return
	elif f_phraseWait > -1.0:
		PhraseEnd()
		f_phraseWait = -2.0
	
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


func PhraseEnd()->void:
	i_dialogueIndex += 1
	#LAST PHRASE OF DIALOGUE
	if i_dialogueIndex >= displayDialogue.size():
		b_showingText = false
		_subtitulos.text = ""
		return
	#CONTINUE NEXT
	f_textTimer = 0.0
	_subtitulos.visible_characters = 0
	_subtitulos.text = displayDialogue[i_dialogueIndex]


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
