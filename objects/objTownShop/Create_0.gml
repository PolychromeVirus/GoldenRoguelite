selected = 0
shoplist = []
alarm_set(0,30)
var _town = global.townlist[global.currentTown]

// Use cached shop inventory if already generated, otherwise build it
if (variable_struct_exists(_town, "cached_shop") && array_length(_town.cached_shop) > 0) {
	shoplist = _town.cached_shop
} else {
	// Build aggregated shop inventory from discard pile
	var _counts = {} // key = itemcardlist index as string, value = count

	for (var i = 0; i < array_length(global.discard); i++) {
		var _id = global.discard[i]
		var _item = global.itemcardlist[_id]
		var _price = 0
		var _cat = ""

		// Weapons have a "melee" field, armor has type "Armor"
		if (variable_struct_exists(_item, "melee") && _town.wpn_price > 0) {
			_price = _town.wpn_price
			_cat = "Weapon"
		} else if (_item.type == "Armor" && _town.arm_price > 0) {
			_price = _town.arm_price
			_cat = "Armor"
		} else if ((_item.type == "Healing" || _item.type == "Battle") && _town.itm_price > 0) {
			_price = _town.itm_price
			_cat = "Item"
		}

		if (_price > 0) {
			var _key = string(_id)
			if (variable_struct_exists(_counts, _key)) {
				_counts[$ _key].count++
			} else {
				_counts[$ _key] = { id: _id, category: _cat, price: _price, count: 1, name: _item.name }
			}
		}
	}

	// Convert to array
	var _keys = variable_struct_get_names(_counts)
	for (var i = 0; i < array_length(_keys); i++) {
		array_push(shoplist, _counts[$ _keys[i]])
	}

	// Add psynergy shop entries (stage 1 only)
	if (_town.psy_price > 0) {
		var _learnable = []
		var _bases_seen = {}
		for (var i = 0; i < array_length(global.psynergylist); i++) {
			var _spell = global.psynergylist[i]
			// Only stage 1 spells, no character-locked spells
			if (real(_spell.stage) != 1) { continue }
			if (_spell.name == "Call Zombie") { continue }
			//if (_spell.character != "") { continue }
			// Skip if base already seen
			if (variable_struct_exists(_bases_seen, _spell.base)) { continue }
			_bases_seen[$ _spell.base] = true
			// Skip if any player already knows any stage of this base
			var _known = false
			for (var p = 0; p < array_length(global.players); p++) {
				for (var s = 0; s < array_length(global.players[p].spells); s++) {
					if (global.psynergylist[global.players[p].spells[s]].base == _spell.base) { _known = true; break }
				}
				if (_known) { break }
			}
			if (!_known) {
				array_push(_learnable, i)
			}
		}
		// Shuffle and pick up to 5, trying to get element variety
		_learnable = array_shuffle(_learnable)
		var _psy_picks = []
		var _elements_covered = {}
		// First pass: one of each element
		for (var i = 0; i < array_length(_learnable) && array_length(_psy_picks) < 4; i++) {
			var _el = global.psynergylist[_learnable[i]].element
			if (!variable_struct_exists(_elements_covered, _el)) {
				array_push(_psy_picks, _learnable[i])
				_elements_covered[$ _el] = true
			}
		}
		// Second pass: fill remaining slots
		for (var i = 0; i < array_length(_learnable) && array_length(_psy_picks) < 5; i++) {
			if (!array_contains(_psy_picks, _learnable[i])) {
				array_push(_psy_picks, _learnable[i])
			}
		}
		for (var i = 0; i < array_length(_psy_picks); i++) {
			var _sp = global.psynergylist[_psy_picks[i]]
			array_push(shoplist, { id: _psy_picks[i], category: "Psynergy", price: _town.psy_price, count: 1, name: _sp.name })
		}
	}

	// Add artifact shop entries
	if (_town.art_price > 0 && array_length(global.artifactlist) > 0) {
		// Build set of itemcard_ids currently owned by any player
		var _owned = {}
		for (var _p = 0; _p < array_length(global.players); _p++) {
			var _pl = global.players[_p]
			// weapon slot
			if (variable_struct_exists(_pl, "weapon") && variable_struct_exists(_pl.weapon, "itemcard_id")) {
				_owned[$ string(_pl.weapon.itemcard_id)] = true
			}
			// inventory
			for (var _ii = 0; _ii < array_length(_pl.inventory); _ii++) {
				var _inv_id = _pl.inventory[_ii]
				if (variable_struct_exists(global.itemcardlist[_inv_id], "itemcard_id")) {
					_owned[$ string(global.itemcardlist[_inv_id].itemcard_id)] = true
				}
			}
			// armor slots
			for (var _ai = 0; _ai < array_length(_pl.armor); _ai++) {
				var _arm_id = _pl.armor[_ai]
				if (_arm_id >= 0 && variable_struct_exists(global.itemcardlist[_arm_id], "itemcard_id")) {
					_owned[$ string(global.itemcardlist[_arm_id].itemcard_id)] = true
				}
			}
		}

		// Filter and shuffle
		var _avail = []
		for (var _ai = 0; _ai < array_length(global.artifactlist); _ai++) {
			var _art = global.artifactlist[_ai]
			if (!variable_struct_exists(_owned, string(_art.itemcard_id))) {
				array_push(_avail, _art)
			}
		}
		_avail = array_shuffle(_avail)
		var _art_count = min(irandom_range(6, 10), array_length(_avail))
		for (var _ai = 0; _ai < _art_count; _ai++) {
			var _art = _avail[_ai]
			array_push(shoplist, { id: _art.itemcard_id, category: "Artifact", price: _town.art_price, count: 1, name: _art.name })
		}
	}

	// Add summon shop entry
	if (_town.sum_price > 0) {
		var _available = []
		for (var i = 0; i < array_length(global.summonlist); i++) {
			if (!array_contains(global.knownSummons, i)) {
				array_push(_available, i)
			}
		}
		if (array_length(_available) > 0) {
			var _pick = _available[irandom(array_length(_available) - 1)]
			array_push(shoplist, { id: _pick, category: "Summon", price: _town.sum_price, count: 1, name: global.summonlist[_pick].name })
		}
	}

	// Sort shoplist: Item → Weapon → Artifact → Armor → Psynergy → Summon
	var _sort_order = function(_a, _b) {
		var _ord = { Item: 0, Weapon: 1, Artifact: 2, Armor: 3, Psynergy: 4, Summon: 5 }
		var _oa = variable_struct_exists(_ord, _a.category) ? _ord[$ _a.category] : 5
		var _ob = variable_struct_exists(_ord, _b.category) ? _ord[$ _b.category] : 5
		if (_oa != _ob) { return _oa - _ob }
		return 0
	}
	array_sort(shoplist, _sort_order)

	// Cache on the town struct
	_town.cached_shop = shoplist
}

psy_pending = -1 // index into shoplist when picking a character for psynergy
side = "left"

DeleteButtons()

var sprite = {image: yes, text: "Buy"}
instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)

_build_buttons = method(id, function() {
    var sprite = {image: yes, text: "Buy"}
    instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
    instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)
})

on_cancel = method(id, function() {
    DeleteButtons()
    CreateOptions()
    // PopMenu + CANCELSOUND handled by objCancel
})

_do_buy = method(id, function() {
    if array_length(shoplist) == 0 or selected < 0 or selected >= array_length(shoplist) { exit }
    var _entry = shoplist[selected]

    if global.gold < _entry.price {
        InjectLog("Not enough gold!")
        exit
    }

    var _bought = false

    switch _entry.category {
        case "Item":
        case "Weapon":
        case "Armor":
            var _target = -1
            for (var _p = 0; _p < array_length(global.players); _p++) {
                if array_length(global.players[_p].inventory) < 5 { _target = _p; break }
            }
            if _target == -1 {
                InjectLog("All inventories are full!")
            } else {
                array_push(global.players[_target].inventory, _entry.id)
                var _dIdx = array_get_index(global.discard, _entry.id)
                if _dIdx >= 0 { array_delete(global.discard, _dIdx, 1) }
                _bought = true
                InjectLog(global.players[_target].name + " received " + _entry.name)
            }
            break

        case "Artifact":
            var _target = -1
            for (var _p = 0; _p < array_length(global.players); _p++) {
                if array_length(global.players[_p].inventory) < 5 { _target = _p; break }
            }
            if _target == -1 {
                InjectLog("All inventories are full!")
            } else {
                array_push(global.players[_target].inventory, _entry.id)
                _bought = true
                InjectLog(global.players[_target].name + " received " + _entry.name)
            }
            break

        case "Psynergy":
            psy_pending = selected
            DeleteButtons()
            var _btn_objs = [objButton2, objButton3, objButton4, objButton5]
            for (var _p = 0; _p < array_length(global.players); _p++) {
                var _pi  = global.players[_p]
                var _spr = { image: _pi.portrait, text: _pi.name, psy_player: _p }
                instance_create_depth(BUTTON1 + (_p * 28), BOTTOMROW, 0, _btn_objs[_p], _spr)
            }
            exit // no _bought, stay in pick mode

        case "Summon":
            if array_contains(global.knownSummons, _entry.id) {
                InjectLog("Already know this summon!")
            } else {
                array_push(global.knownSummons, _entry.id)
                _bought = true
            }
            break
    }

    if _bought {
        global.gold -= _entry.price
        InjectLog("Bought " + _entry.name + " for " + string(_entry.price) + "g")
        _entry.count--
        if _entry.count <= 0 {
            array_delete(shoplist, selected, 1)
            if selected >= array_length(shoplist) { selected = array_length(shoplist) - 1 }
        }
    }
})
