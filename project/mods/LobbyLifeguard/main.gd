extends Node

const MOD_ID = "LobbyLifeguard"

const DEFAULT_CONFIG = {"banlist": ""}
var config: Dictionary
var banlist: Array

onready var TackleBox := $"/root/TackleBox"


func _ready():
	TackleBox.connect("mod_config_updated", self, "_on_config_update")
	Network.connect("_user_connected", self, "_on_player_connect")
	_init_config()


func _init_config():
	config = TackleBox.get_mod_config(MOD_ID)
	if not config["banlist"]:
		config = DEFAULT_CONFIG
		TackleBox.set_mod_config(MOD_ID, config)
	
	_populate_banlist()


func _on_config_update(mod_id, new_config):
	if mod_id != MOD_ID: return
	
	_populate_banlist()


func _on_player_connect(steam_id):
	if not Network.GAME_MASTER:
		return
	
	var str_steam_id = String(steam_id)
	if str_steam_id in banlist:
		print("[%s] Player %s found on the banlist. Banning them." % [MOD_ID, steam_id])
		Network._ban_player(steam_id)
		Network._update_chat("[color=#ac0029][%s]Player banned, they will be removed from the online list soon.[/color]" % [MOD_ID])


func _populate_banlist():
	if config["banlist"]:
		banlist = []
		for entry in config["banlist"].split(","):
			banlist.append(entry.strip_edges())
