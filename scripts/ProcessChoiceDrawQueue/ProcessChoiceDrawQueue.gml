function ProcessChoiceDrawQueue() {
	if (array_length(global.choiceDrawQueue) > 0) {
		var _entry      = global.choiceDrawQueue[0]
		var _draw_player = _entry.player
		// Pull up to 3 cards
		var _choices = []
		var _count   = min(3, array_length(global.deck))
		for (var i = 0; i < _count; i++) {
			array_push(_choices, global.deck[0])
			array_delete(global.deck, 0, 1)
		}

		var _items = []
		for (var i = 0; i < array_length(_choices); i++) {
			var _card = global.itemcardlist[_choices[i]]
			array_push(_items, {
				name:   _card.name,
				sprite: asset_get_index(_card.alias),
				desc:   _card.text,
				data:   { card_index: _choices[i] },
			})
		}

		var _draw = method({ _choices: _choices }, function(i, item, cx, cy, bw, bh) {
			var _card    = global.itemcardlist[_choices[i]]
			var _offset  = 4
			var _spr     = asset_get_index(_card.alias)
			if _spr != -1 { draw_sprite_stretched(_spr, 0, cx + bw / 2 - 48, cy + 16, 96, 96) }
			var _catcol = c_white
			if variable_struct_exists(_card, "melee") { _catcol = global.c_weapons }
			else if _card.type == "Armor" { _catcol = global.c_armor }
			var _nx = cx + bw / 2 - string_width(_card.name) / 2
			draw_set_color(c_black)
			draw_text(_nx + _offset, cy + 124 + _offset, _card.name)
			draw_set_color(_catcol)
			draw_text(_nx, cy + 124, _card.name)
			var _type = (variable_struct_exists(_card, "melee") or _card.type != "Armor") ? _card.type : _card.slot
			var _tx = cx + bw / 2 - string_width("[" + _type + "]") / 2
			draw_set_color(c_black)
			draw_text(_tx + _offset, cy + 164 + _offset, "[" + _type + "]")
			draw_set_color(c_ltgray)
			draw_text(_tx, cy + 164, "[" + _type + "]")
			draw_set_color(c_black)
			draw_text_ext(cx + 20 + _offset, cy + 210 + _offset, _card.text, 36, bw - 40)
			draw_set_color(c_ltgray)
			draw_text_ext(cx + 20, cy + 210, _card.text, 36, bw - 40)
		})

		PushMenu(objMenuDraft, {
			items:      _items,
			title:      _draw_player.name + " - Choose a Card",
			draw_item:  _draw,
			on_confirm: method({ _choices: _choices, _draw_player: _draw_player }, function(i, item) {
				var _chosen = _choices[i]
				var _card   = global.itemcardlist[_chosen]
				if array_length(_draw_player.inventory) < 5 and !_card.onDraw {
					array_push(_draw_player.inventory, _chosen)
					InjectLog(_draw_player.name + " chose " + _card.name)
				} else if _card.onDraw {
					array_push(global.postBattleQueue, { type: "onDraw", item: _chosen, player: _draw_player })
					InjectLog(_draw_player.name + " chose " + _card.name)
				} else {
					array_push(global.discard, _chosen)
					InjectLog(_draw_player.name + " chose " + _card.name + " but their inventory was full!")
				}
				for (var _j = 0; _j < array_length(_choices); _j++) {
					if _j != i { array_push(global.deck, _choices[_j]) }
				}
				global.deck = array_shuffle(global.deck)
				array_delete(global.choiceDrawQueue, 0, 1)
				DeleteButtons()
				PopMenu()
				ProcessChoiceDrawQueue()
			}),
			on_cancel: method({ _choices: _choices }, function() {
				for (var _j = 0; _j < array_length(_choices); _j++) {
					array_push(global.deck, _choices[_j])
				}
				global.deck = array_shuffle(global.deck)
				array_delete(global.choiceDrawQueue, 0, 1)
				DeleteButtons()
				PopMenu()
				ProcessChoiceDrawQueue()
			}),
		})
	} else {
		// Queue empty — process any onDraw effects (Elemental Star, Summon Tablet) first
		if (array_length(global.postBattleQueue) > 0) {
			ProcessPostBattleQueue()
		} else if (global.inTown) {
			ProcessTownFinds()
		} else {
			CreateOptions()
		}
	}
}
