pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()
	poke4(0x5600,0x0005.0803)
	poke4(0x5708,0x307.0301,0x.0001)
	poke4(0x5710,0x0700,0x.0002)
	poke4(0x5718,0x.0702,0)
	poke4(0x5720,0x0707.0300)
	poke4(0x5728,0x000f.0f00)
	poke4(0x5730,0x0007.0700)


end

function _update60()
	if #active_menus == 0 then
		if btnp(4) then
			command:open()
		end
	else
		active_menus[#active_menus]:update()
	end

end

function _draw()
	cls(0)
	map(0,0,0,0,16,16)
	
	for m in all(active_menus) do
		m:draw()
	end
	
	--print("\14\34",64,119)
--[[
	draw_panel(move)
	print("attack\nspells\nitem\ndefend",8,100)
	draw_panel(enemy)
	print("dragon\ndragon\ndragon\ndragon",48,100,7)
	print("1\n1\n1\n1",116,100)
	draw_panel(battle)
	print("name\nname\nname\nname",8,8,7)
	print("100/100\n100/100\n100/100\n100/100",28,8)
	print("100/100\n100/100\n100/100\n100/100",60,8)
	print("\n\nligma\nsleepy",92,8)
	palt(0,false)
	palt(3,true)
	spr(5,44,36,5,6)
]]
print("\#0"..stat(1),0,0,7)
end

function inset_number(value) --makes a number always take 3 characters
	local z = "00"
	return sub(z,#tostr(value))..value
end

wayne = {
	name = "wayne",
	max_hp = 100,
	hp = 100,
	max_mp = 100,
	mp = 100,
	attack = 30,
	agility = 30,
	weapon = {name = "penny", description = {"penny (atk +1):","worth one cent in a","foreign currency."}},
	armor = {name = "galoshes", description = {"galoshes (hp +10):","protects you against wet","feet, but not much else."}},
	spells = {},
	status = {},
	change_equipment = function(self,key,equipment)
		local a = self[key]
		self[key] = equipment
		return a
	end

}
dedesmuln = {
	name = "dedesmuln",
	max_hp = 90,
	hp = 90,
	max_mp = 100,
	mp = 100,
	attack = 30,
	agility = 30,
	weapon = nil,
	armor = nil,
	spells = {},
	status = {},
	change_equipment = function(self,key,equipment)
		local a = self[key]
		self[key] = equipment
		return a
	end
}
pongorma = {
	name = "pongorma",
	max_hp = 100,
	hp = 100,
	max_mp = 90,
	mp = 90,
	attack = 30,
	agility = 30,
	weapon = nil,
	armor = nil,
	spells = {},
	status = {},
	change_equipment = function(self,key,equipment)
		local a = self[key]
		self[key] = equipment
		return a
	end
}
somsnosa = {
	name = "somsnosa",
	max_hp = 90,
	hp = 90,
	max_mp = 90,
	mp = 90,
	attack = 30,
	agility = 30,
	weapon = nil,
	armor = nil,
	spells = {},
	status = {},
	change_equipment = function(self,key,equipment)
		local a = self[key]
		self[key] = equipment
		return a
	end
}

party = {wayne,dedesmuln,pongorma,somsnosa}

armor = {
	name = "armor",
	contents = {{name = "stinky hat", description = {"stinky hat (hp +10) (agi +5):","valuable looking, if","it weren't for the smell..."}}}
}

weapons = {
	name = "weapons",
	contents = {{name = "big fork", description = {"big fork (atk +20): don't","try to eat a salad with","this, you may hurt yourself."}}}
}

active_menus = {}

menu = {
	cursor = 1,
	cursor_a = 15,
	action = nil,
}

function menu:new(x1,y1,x2,y2,title,contents,sub_panels)
	local obj = {
		x1 = x1,
		y1 = y1,
		x2 = x2,
		y2 = y2,
		title = title, --{title 1,xoffset,title2,xoffset,...}
		contents = contents or {},--{{item 1 name,on_click,[moused over]},{...}}
		sub_panels = sub_panels,--{display menu 1, display menu 2, ...}
		base = self}
	return setmetatable(obj, {__index = self})
end

function menu:open(action)
	add(active_menus, self)
	self.action = action or self.action
	self.cursor_a = 0
end

function menu:close()
	deli(active_menus)
	self.cursor = 1
	self.cursor_a = 15
end

function menu:update()
	self.cursor_a = (self.cursor_a+1)%30
	if btnp(2) and #self.contents > 0 then
		self.cursor = (self.cursor-2)%#self.contents+1
		self.cursor_a = 0
	elseif btnp(3) and #self.contents > 0 then
		self.cursor = self.cursor%#self.contents+1
		self.cursor_a = 0
	elseif btnp(4) then
		self:close()
	elseif btnp(5) and #self.contents > 0 and self.contents[self.cursor][2] then
		self.cursor_a = 0
		self.contents[self.cursor][2](self.action)
	end
end

function menu:draw()
	if #self.contents > 0 and self.contents[self.cursor][3] and active_menus[#active_menus] == self then self.contents[self.cursor][3](self.action) end
	for s in all(self.sub_panels) do
		draw_panel(s)
	end
	draw_panel(self)
end

inventory = {48, 8, 95, 43}
inventory = menu:new(unpack(inventory))

actor_stats = {0,0,55,35}
actor_stats = menu:new(unpack(actor_stats))
function actor_stats:change_to(actor)
	if actor != self.action then 
		self.action = actor or self.action
		self.title = {actor.name,1}
		self.contents[1] = {"maxhp: "..actor.max_hp}
		self.contents[2] = {"maxmp: "..actor.max_mp}
		self.contents[3] = {"power: "..actor.attack}
		self.contents[4] = {"speed: "..actor.agility}
	end
end

actor_equipment = {0, 36, 55, 59,
	{"equipment",1},
	{{"",function(actor) weapon_select:open(actor) end,
		function() 
			weapon_select:draw() end},
	{"",function(actor) armor_select:open(actor) end,
	function() 
		armor_select:draw() end}
	},
	{actor_stats}
}
actor_equipment = menu:new(unpack(actor_equipment))
function actor_equipment:change_to(actor)
		self.action = actor or self.action
		self.contents[1] = {(self.action.weapon and self.action.weapon.name or ""), 
		function() 
			weapon_select:open(self.action) end,
		function() 
			weapon_select:draw() end}
		self.contents[2] = {(self.action.armor and self.action.armor.name or ""), 
		function() 
			armor_select:open(self.action) end,
		function() 
			armor_select:draw() end}
	for s in all(self.sub_panels) do --do NOT let this circular reference
		s:change_to(self.action)
	end
end

weapon_select = {72,0,127,91,
	{"weapons",1},
	{},
	{},
}
weapon_select = menu:new(unpack(weapon_select))
function weapon_select:update_contents()
	self.contents = {}
	
	for c in all(weapons.contents) do
		add(self.contents,{c.name,function(actor)
			local b = actor:change_equipment("weapon",c)
			
			add(weapons.contents, b)
			del(weapons.contents, c)
			
			weapon_select:update_contents()
			actor_equipment:change_to()
			end,
			function() text_box:draw(unpack(c.description)) end})
	end
	add(self.contents,{"",function(actor)
		local b = actor:change_equipment("weapon",c)
		
		add(weapons.contents, b)
		del(weapons.contents, c)
		weapon_select:update_contents()
		actor_equipment:change_to()
	end,
		function() end})
end
weapon_select:update_contents()

armor_select = {72,0,127,91,
	{"armor",1},
	{},
	{},
}
armor_select = menu:new(unpack(armor_select))
function armor_select:update_contents()
	self.contents = {}
	
	for c in all(armor.contents) do
		add(self.contents,{c.name,function(actor)
			local b = actor:change_equipment("armor",c)
			
			add(armor.contents, b)
			del(armor.contents, c)
			
			armor_select:update_contents()
			actor_equipment:change_to()
			end,
			function() text_box:draw(unpack(c.description)) end})
	end
	add(self.contents,{"",function(actor)
		local b = actor:change_equipment("armor",c)
		
		add(armor.contents, b)
		del(armor.contents, c)
		armor_select:update_contents()
		actor_equipment:change_to()
	end,
		function() end})
end
armor_select:update_contents()

spellbook = {0,0,51,91,
}
spellbook = menu:new(unpack(spellbook))
function spellbook:change_to(actor)
	if actor != self.action then 
		self.action = actor
		self.title = {actor.name,1}
	end
end

party_status = {
	0, 92, 127, 127,
	{"name",1,"hp",6,"mp",14,"status",22}
	--contents is currently defined after function party_status:change_to()
}
party_status = menu:new(unpack(party_status))
function party_status:change_to()
	local p = {}
	for i = 1, #party do
		add(p,{sub(party[i].name,1,4).." "..inset_number(party[i].hp).."/"..inset_number(party[i].max_hp).." "..inset_number(party[i].mp).."/"..inset_number(party[i].max_mp),
		function(submenu)
			submenu:open() end,
		function(submenu) 
			submenu:change_to(party[i])
			submenu:draw()end
		})
	end
	self.contents = p
end
party_status:change_to() --good lord is there a better way to handle this?


command = {8,
	8,
	47,
	43,
	{"command",1},
	{
		{"item",function() inventory:open() end, function() draw_panel(inventory) end},
		{"equip",function() party_status:open(actor_equipment) end},
		{"spell",function() party_status:open(spellbook) end},
		{"system",function() extcmd("pause") end}
	},
	{party_status}
}
command = menu:new(unpack(command))

battle = {
	x1 = 0,
	y1 = 0,
	x2 = 127,
	y2 = 35,
	title = {"name",1,"hp",6,"mp",14,"status",22}
}

move = {
	x1 = 0,
	y1 = 92,
	x2 = 39,
	y2 = 127,
	title = {"name",1}
}

enemy = {
	x1 = 40,
	y1 = 92,
	x2 = 127,
	y2 = 127
}

message = "the quick brown fox jumped over the lazy dog. the quick brown fox jumped over the lazy dog. the quick brown fox jumped over the lazy dog."

text_box = {
	x1 = 0,
	y1 = 92,
	x2 = 127,
	y2 = 127,
	text = {"","",""},
	text_c = 1,
	lines = {},
	line_c = 1
}

function text_box:update()
	text[text_c] = text[text_c]..sub(lines[line_c],#text[text_c]+1,#text[text_c]+1)
	if #lines[line_c] == #text[text_c] then
		if text_c < 3 and #lines > line_c then
			text_c = min(3,text_c+1)
			line_c = min(#lines,line_c+1)
		elseif btnp(4) or btnp(5) then
			if #lines > line_c then
				text = {"","",""}
				text_c = 1
				line_c += 1
			else
				text_c = 1
				line_c = 1
				text = {"","",""}
				lines = {}
				text_box_active = false
			end
		end
	elseif btnp(4) or btnp(5) then
		for i = text_c,3 do
			text[i] = lines[line_c+i-text_c]
		end
		line_c += 3-text_c
		text_c = 3
	end
end

function text_box:draw(line1,line2,line3)
	draw_panel(text_box)
	print((line1 and line1 or self.text[1]),8,100,7)
	print((line2 and line2 or self.text[2]),8,108)
	print((line3 and line3 or self.text[3]),8,116)
end

function text_box:say(message) 
	local message_c = 1
	self.lines = {}
	for i = message_c,#message do
		if ord(message,i) == 32 then
			for j = i+1,#message+1 do
				if j-message_c > 28 then
					add(self.lines,sub(message,message_c,i-1))
					message_c = i+1
					break
				elseif ord(message,j) == 32 then
					break
				end
			 
			end
			
		end
	end
	add(self.lines,sub(message,message_c,#message))
end

function draw_panel(tabl)
	local x1,y1,x2,y2,title = tabl.x1,tabl.y1,tabl.x2,tabl.y2,tabl.title
	rectfill(x1,y1,x2,y2,0)
	rect(x1+1,y1+1,x2-1,y2-1,7)
	rect(x1+2,y1+2,x2-2,y2-2)
	fillp(0x0377)
	rectfill(x1,y1,x1+3,y1+3,0x70)
	fillp(0x7730)
	rectfill(x1,y2,x1+3,y2-3)
	fillp(0x0cee)
	rectfill(x2,y1,x2-3,y1+3)
	fillp(0xeec0)
	rectfill(x2,y2,x2-3,y2-3)
	fillp()
	if title then
		for i = 1,#title,2 do
			--rectfill(title[i+1]*4+x1+3,y1,title[i+1]*4+x1+3+#title[i]*4,y1+4,0)
			print("\#0"..title[i],x1+title[i+1]*4+4,y1+1,7)
		end
	end
	if tabl.contents then
		for i = 1, #tabl.contents do
			print(tabl.contents[i][1],x1+8,y1+6*(i-1)+8,7) --Maybe change the 6 to tabl.yspacing
		end
	end
	if tabl.cursor and tabl.cursor_a < 15 then print("\14\33",x1+4,y1+8+6*(tabl.cursor-1),7) end
end




__gfx__
00000000777bb77700000000000000000000000088883333333333c333333333333333333333000000000000000000000000000000000000777bb77700000000
0000000073bbbbb70000000000000000000000008887883333333c333333333333333333333300000000000000000000000000000000000073bbbbb700000000
007007007bbbb3b70000000000000000000000008777883333330c33333333333333333333330000000000000000000000000000007007007bbbb3b700000000
00077000bbbbbbbb000000000000000000000000387778333337cc3333333333333333333333000000000000000000000000000000077000bbbbbbbb00000000
00077000bbbbbbbb0000000000000000000000003888778333334cccc9933333333333333333000000000000000000000000000000077000bbbbbbbb00000000
007007007b3bbbb700000000000000000000000033388338333344cc00ccc0888333333333330000000000000000000000000000007007007b3bbbb700000000
000000007bbbbbb7000000000000000000000000333383333833344cccccc2222883333333330000000000000000000000000000000000007bbbbbb700000000
00000000777bb77700000000000000000000000033333333333333427999c202333883333333000000000000000000000000000000000000777bb77700000000
000000000000000000000000000000000000000033333333333388879990c2208333333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333333479999900333833333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333334799090992333333333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333883333339933300093333333333333330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033c90cc8333333333c9993333331333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003c3330cc83133333390093333114113333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333399c14113333c9999c331144141333330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033333c1144141333c9999c331444144133330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033333144414441ccc0000cc11444444413330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033314444144441cc99999ccc44c4414441330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003114444147c44ccc09999ccc44c4414444130000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000344444144ccccccc999990c0c0c4441444410000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000034444144ccc0ccc9999990cc0cccc41444440000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003344144c0c070cc9000000ccccc0744144430000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033414444444cccc99999990cc444444144330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033143339444444c99999999c4444444414330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333399cc4cc909999909c0443333414330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333390ccccc9999999999cc33333333330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333399c0ccc9999999999ccc3333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333999cccc0999999990ccc3333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333390cccc9900000099ccc3333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333339cccc99999999990cc3333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333cccc099999999cccc3333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333ccc0c900000090ccc3333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333ccccc99999999cccc3333333330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033333333333ccc0c900099ccccc3333333330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033333333333cccc3000000cccc33333333330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033333333333333c333333ccccc33333333330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333333333ccc333333ccc3333333333330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333333333cc3c333333ccc333333333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333cc0c3cc333333cc333333333330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333333c33c333cc333333cc33333333330000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033333333333c33333333333ccccc333333330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333333333333333333ccccccccc3333330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333333333333333337c3333c033c333330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333333333333333333333333c333333330000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333333333333333333333333333cc33333330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333333333333333333333733333330000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
