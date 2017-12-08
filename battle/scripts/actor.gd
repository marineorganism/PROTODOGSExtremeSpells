extends Sprite

onready var GoodTimer = preload("res://battle/scripts/GoodTimer.gd")
onready var Mover = preload("res://battle/scripts/Mover.gd")
onready var SoundWaiter = preload("res://battle/scripts/SoundWaiter.gd")
onready var sound = get_node("sound")
onready var animation = get_node("animation")
onready var bullets = get_node("/root/level/bullets")
onready var bulletSounds = get_node("/root/level/bulletSounds")

const T = "timeout"
const M = "moved"
const S = "soundDone"
signal bongo

export var flippy = false
export var walky = false
export var target = true
export var speed = 100

var velocity = Vector2(0,0)
var health = 1

var routines = []
var finished = false



func _ready():
	set_process(true)
	var hitbox = get_node("hitbox")
	hitbox.connect("body_enter",self,"hit")


func _process(delta):
	if (finished):
		if (routines.size() > 1):
			routines.pop_front()
			call(routines.front())
			finished = false
		else:
			queue_free()
	
	#move
	set_pos(get_pos() + velocity * delta)
	if (flippy):
		if (velocity.x < 0): set_flip_h(true)
		if (velocity.x > 0): set_flip_h(false)
	
	#animate
	if (walky):
		if (velocity.length() == 0): animation.stop()
		elif (!animation.is_playing()):
			animation.play("walk")


func shoot(bullet,angle,origin=self):
	var ib = bullet.instance()
	if (ib.sound != null):
		bulletSounds.play(ib.sound)
	ib.owner = self
	bullets.add_child(ib)
	ib.set_pos(origin.get_pos())
	ib.velocity.x = -sin(angle) * ib.speed
	ib.velocity.y = -cos(angle) * ib.speed
	return ib


func die():
	return


func hit(body):
	if (!body.is_in_group("power") && body.owner != self):
		if (randi() % 5 > 3): bullets.addPowerup(body.get_pos())
		body.queue_free()
		health -= 1
		if (health == 0): die()
		return true
	return false


func isDone():
	if (health < 1):
		finished = true
		return true
	else: return false

func done():
	finished = true


func createTimer(time):
	var timer = GoodTimer.new()
	timer.set_wait_time(time)
	timer.start()
	add_child(timer)
	return timer

func createMover():
	var mover = Mover.new()
	mover.dude = self
	add_child(mover)
	return mover

func createSoundWaiter(sp):
	var waiter = SoundWaiter.new()
	waiter.sp = sp
	add_child(waiter)
	return waiter


func addRoutine(name):
	if (routines.size() == 0): call(name)
	routines.push_back(name)