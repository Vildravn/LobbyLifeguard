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
		var str_steam_id = String(steam_id)
		if str_steam_id in banlist:
			if Network.GAME_MASTER:
				print("[%s] Player %s found on the banlist and you are game master. Banning them." % [MOD_ID, steam_id])
				Network._ban_player(steam_id)
				Network._update_chat("[color=#ac0029][%s] Detected a connecting player on your ban list. They've been banned from this lobby.[/color]" % [MOD_ID])
			else:
				print("[%s] Player %s found on the banlist and you're not game master. Blocking them." % [MOD_ID, steam_id])
				PlayerData._hide_player(steam_id)
				Network._update_chat("[color=#ac0029][%s] Detected a connecting player on your ban list. They've been blocked in this lobby.[/color]" % [MOD_ID])


func _populate_banlist():
	if config["banlist"]:
		banlist = []
		for entry in config["banlist"].split(","):
			banlist.append(entry.strip_edges())
