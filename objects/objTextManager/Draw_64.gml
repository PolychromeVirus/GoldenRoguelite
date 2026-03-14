if global.gameover {
    if global.gameover_timer < 240 {
        var _fade = 1 - (global.gameover_timer / 240)
        draw_set_alpha(_fade)
        draw_set_color(c_black)
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
        draw_set_alpha(1)
    }
    exit
}

  //Column layout:                                                                                                          - _margin (2) — left edge padding before first column
  //- _endMargin (15) — right edge padding after last column                                                                - _colW — total width of each player's column (calculated, then -15 extra)
  //- _portraitGap (2) — horizontal gap between portrait and the text/bars area

  //Portrait:
  //- _portraitFull (144) — the original unscaled portrait size, used for positioning so everything stays in place
  //- _scale (0.79) — how much to shrink the portrait
  //- _portraitSize — actual drawn portrait size (144 × 0.79 = 114)
  //- _portraitOffset — shift to center the smaller portrait in the original 144 space (≈15px)

  //Bars:
  //- _barW — bar width, fills column space after portrait area minus 20px padding
  //- _barH (16) — bar height in pixels
  //- _nameH — text line height (from font), used to position text labels

  //Vertical positioning (all bottom-up from portrait):
  //- _portBot — bottom anchor point (portrait bottom minus offset minus 8px nudge)
  //- _ppBarY — PP bar top = _portBot - _barH
  //- _ppTextY — PP label Y = _ppBarY - _nameH/2 + 5 (centered-ish above PP bar)
  //- _hpBarY — HP bar top = _ppTextY - _barH - 8 (the 8 is the gap between HP bar and PP text)
  //- _hpTextY — HP label Y = same formula as PP text
  //- _nameY — name Y = same distance above HP text as HP is above PP

  //Per-column horizontal:
  //- _colX — left edge of column i
  //- _infoX — where text/bars start = _colX + _portraitFull + _portraitGap


draw_text(0,0,string(global.errormessage))

if global.charselect == false{
	var healthtext = ""
	var pptext = ""

	var textx = 3
	var texty = 3

	var offset = 4
	var spacing = 400
	var barsize = 200

	draw_set_font(GoldenSun)

	if (global.pause == false or instance_exists(objCharTarget)) and !isCombatMenu(){
		// --- New portrait layout ---
		var _guiW = display_get_gui_width()
		var _portraitSize = 144
		var _portraitGap = 2
		var _margin = 3
		var _endMargin = 15
		// Calculate column width so last bar ends ~15px before screen edge
		var _colW = (_guiW - _margin - _endMargin) / array_length(global.players)
		// Bar fills remaining space after portrait + gap
		var _barW = 0
		var _nameH = string_height("HP:")
		var _barH = 16

		//draw_set_color(c_black)
		//draw_rectangle(0, 0, _guiW, texty + _portraitSize + 6, false)
		draw_sprite(topbar,0,0,0)
		

		var _portraitFull = 144
		var _scale = 0.79
		var _portraitSize = round(_portraitFull * _scale)
		var _portraitOffset = (_portraitFull - _portraitSize) / 2

		// Recalculate bar width for scaled portrait
		_barW = _colW - _portraitFull - _portraitGap - 40

		for (var i = 0; i < array_length(global.players); i++){
			var _p = global.players[i]
			var _colX = _margin + i * _colW
			var _infoX = _colX + _portraitFull + _portraitGap

			// Portrait — scaled down but centered on original position
			if _p.hp > 0 {draw_sprite_stretched_ext(_p.portrait, 0, _colX + _portraitOffset, texty + _portraitOffset, _portraitSize, _portraitSize,c_white,1)}
			else{draw_sprite_stretched_ext(_p.portrait, 0, _colX + _portraitOffset, texty + _portraitOffset, _portraitSize, _portraitSize,c_white,.5)}

			// Heal flash (green overlay)
			if _p.heal_flash > 0 {
				draw_set_alpha(_p.heal_flash / 12)
				draw_set_colour(c_lime)
				draw_rectangle(_colX + _portraitOffset, texty + _portraitOffset,
				               _colX + _portraitOffset + _portraitSize,
				               texty + _portraitOffset + _portraitSize, false)
				draw_set_alpha(1.0)
				_p.heal_flash--
			}

			// Damage flash (red additive)
			if _p.flash_timer > 0 {
				gpu_set_blendmode(bm_add)
				draw_sprite_stretched_ext(_p.portrait, 0, _colX + _portraitOffset, texty + _portraitOffset,
				                          _portraitSize, _portraitSize, c_red, _p.flash_timer / 12)
				gpu_set_blendmode(bm_normal)
				_p.flash_timer--
			}

			// Layout bottom-up from portrait bottom, shifted up by _portraitOffset
			healthtext = string(_p.hp) + "/" + string(_p.hpmax) + " HP"
			pptext = string(_p.pp) + "/" + string(_p.ppmax) + " PP"
			var hpdiff = _p.hp / _p.hpmax
			var ppdiff = _p.pp / _p.ppmax

			var _portBot = texty + _portraitFull - 1 - _portraitOffset - 6
			var _ppBarY = _portBot - _barH
			var _ppTextY = _ppBarY - _nameH / 2 + 5
			var _hpBarY = _ppTextY - _barH - 8
			var _hpTextY = _hpBarY - _nameH / 2 + 5

			// Name above HP text with same spacing as HP-to-PP
			var _nameY = _hpTextY - (_ppTextY - _hpTextY)
			draw_set_color(c_black)
			draw_text(_infoX + offset, _nameY + offset, _p.name)
			draw_set_color(c_white)
			draw_text(_infoX, _nameY, _p.name)

			// HP bar
			draw_rectangle_color(_infoX, _hpBarY, _infoX + _barW, _hpBarY + _barH, c_red, c_red, c_red, c_red, false)
			draw_rectangle_color(_infoX, _hpBarY, _infoX + (_barW * hpdiff), _hpBarY + _barH, c_blue, c_blue, c_blue, c_blue, false)
			// HP text above HP bar
			draw_set_color(c_black)
			draw_text(_infoX + offset, _hpTextY + offset, healthtext)
			draw_set_color(c_white)
			draw_text(_infoX, _hpTextY, healthtext)

			// PP bar
			draw_rectangle_color(_infoX, _ppBarY, _infoX + _barW, _portBot, c_red, c_red, c_red, c_red, false)
			draw_rectangle_color(_infoX, _ppBarY, _infoX + (_barW * ppdiff), _portBot, c_blue, c_blue, c_blue, c_blue, false)
			// PP text above PP bar
			draw_set_color(c_black)
			draw_text(_infoX + offset, _ppTextY + offset, pptext)
			draw_set_color(c_white)
			draw_text(_infoX, _ppTextY, pptext)

			// Status tokens
			var _tokenX = _infoX + string_width(_p.name) + 2
			var _tokenY = _nameY + 6
			if _p.atkmod < 0 { draw_sprite_stretched(attack_down, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.defmod < 0 { draw_sprite_stretched(defense_down, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.atkmod > 0 { draw_sprite_stretched(attack_up, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.defmod > 0 { draw_sprite_stretched(defense_up, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.poison { draw_sprite_stretched(Poison, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.venom { draw_sprite_stretched(Poison, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.stun > 0 { draw_sprite_stretched(Bolt, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.sleep { draw_sprite_stretched(Sleep, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.rootTokens > 0 { draw_sprite_stretched(Growth, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.regen { draw_sprite_stretched(Ply, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.cloak { draw_sprite_stretched(Cloak, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if array_length(_p.rerolls) > 0 { draw_sprite_stretched( Lucky_Medal1503 , 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if variable_struct_exists(_p.delaydata,"revive") and _p.delaydata.revive{ draw_sprite_stretched(Revive, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			draw_sprite(topframe,0,0,0)
		}

		/* --- OLD LAYOUT (commented out for easy revert) ---
		draw_set_color(c_black)
		draw_rectangle(0, 0, display_get_gui_width(), texty + string_height("HP:") * 2 + 6, false)
		for (var i = 0;i < array_length(global.players);i++){
			healthtext = global.players[i].name + " - " + string(global.players[i].hp) + "/" + string(global.players[i].hpmax) + " HP"
			pptext = string(global.players[i].pp) + "/" + string(global.players[i].ppmax) + " PP"
			var ppoffset = string_width(global.players[i].name + " - ")
			var baroffset = string_height("HP: ") - 2
			var hpdiff = global.players[i].hp / global.players[i].hpmax
			var ppdiff = global.players[i].pp / global.players[i].ppmax
			draw_rectangle_color(textx+ppoffset,texty+(baroffset-16),textx+ppoffset+barsize,texty+baroffset,c_red,c_red,c_red,c_red,false)
			draw_rectangle_color(textx+ppoffset,texty+(baroffset-16),textx+ppoffset+(barsize*hpdiff),texty+baroffset,c_blue,c_blue,c_blue,c_blue,false)
			draw_rectangle_color(textx+ppoffset,texty+(baroffset*2-16),textx+ppoffset+barsize,texty+baroffset*2,c_red,c_red,c_red,c_red,false)
			draw_rectangle_color(textx+ppoffset,texty+(baroffset*2-16),textx+ppoffset+(barsize*ppdiff),texty+baroffset*2,c_blue,c_blue,c_blue,c_blue,false)
			draw_set_color(c_black)
			draw_text(textx+offset,texty+offset,healthtext)
			draw_text(textx+ppoffset+offset,texty+string_height("HP:")+offset,pptext)
			draw_set_color(c_white)
			draw_text(textx,texty,healthtext)
			draw_text(textx+ppoffset,texty+string_height("HP:"),pptext)
			// Status tokens
			var _tokenX = textx
			var _tokenY = texty + string_height("HP:") + 4
			var _p = global.players[i]
			if _p.atkmod < 0 { draw_sprite_stretched(attack_down, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.defmod < 0 { draw_sprite_stretched(defense_down, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.atkmod > 0 { draw_sprite_stretched(attack_up, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.defmod > 0 { draw_sprite_stretched(defense_up, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.poison { draw_sprite_stretched(Poison, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.venom { draw_sprite_stretched(Poison, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.stun > 0 { draw_sprite_stretched(Bolt, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.sleep { draw_sprite_stretched(Sleep, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.rootTokens > 0 { draw_sprite_stretched(Growth, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.regen { draw_sprite_stretched(Ply, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if _p.cloak { draw_sprite_stretched(Cloak, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if array_length(_p.rerolls) > 0 { draw_sprite_stretched( Lucky_Medal1503 , 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			if variable_struct_exists(_p.delaydata,"revive") and _p.delaydata.revive{ draw_sprite_stretched(Revive, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
			textx += spacing
		}
		--- END OLD LAYOUT --- */
	}else if isCombatMenu(){
		textx = 800
		healthtext = global.players[global.turn].name + " - " + string(global.players[global.turn].hp) + "/" + string(global.players[global.turn].hpmax) + " HP"
		pptext = string(global.players[global.turn].pp) + "/" + string(global.players[global.turn].ppmax) + " PP"
		var ppoffset = string_width(global.players[global.turn].name + " - ")
		var baroffset = string_height("HP: ") - 2

		var hpdiff = global.players[global.turn].hp / global.players[global.turn].hpmax
		var ppdiff = global.players[global.turn].pp / global.players[global.turn].ppmax

		draw_rectangle_color(textx+ppoffset,texty+(baroffset-16),textx+ppoffset+barsize,texty+baroffset,c_red,c_red,c_red,c_red,false)
		draw_rectangle_color(textx+ppoffset,texty+(baroffset-16),textx+ppoffset+(barsize*hpdiff),texty+baroffset,c_blue,c_blue,c_blue,c_blue,false)

		draw_rectangle_color(textx+ppoffset,texty+(baroffset*2-16),textx+ppoffset+barsize,texty+baroffset*2,c_red,c_red,c_red,c_red,false)
		draw_rectangle_color(textx+ppoffset,texty+(baroffset*2-16),textx+ppoffset+(barsize*ppdiff),texty+baroffset*2,c_blue,c_blue,c_blue,c_blue,false)

		draw_set_color(c_black)
		draw_text(textx+offset,texty+offset,healthtext)
		draw_text(textx+ppoffset+offset,texty+string_height("HP:")+offset,pptext)

		draw_set_color(c_white)
		draw_text(textx,texty,healthtext)
		draw_text(textx+ppoffset,texty+string_height("HP:"),pptext)

		// Status tokens
		var _tokenX = textx
		var _tokenY = texty + string_height("HP:") + 4
		var _p = global.players[global.turn]
		if _p.atkmod < 0 { draw_sprite_stretched(attack_down, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
		if _p.defmod < 0 { draw_sprite_stretched(defense_down, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
		if _p.atkmod > 0 { draw_sprite_stretched(attack_up, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
		if _p.defmod > 0 { draw_sprite_stretched(defense_up, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
		if _p.poison { draw_sprite_stretched(Poison, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
		if _p.venom { draw_sprite_stretched(Poison, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
		if _p.stun > 0 { draw_sprite_stretched(Bolt, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
		if _p.sleep { draw_sprite_stretched(Sleep, 0, _tokenX, _tokenY, 24, 24); _tokenX += 28 }
	}
	
}

