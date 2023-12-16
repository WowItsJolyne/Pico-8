pico-8 cartridge // http://www.pico-8.com
version 33
__lua__

function _init()
	poke4(0x5600,0x0005.0803)
	poke4(0x5708,0x307.0301,0x.0001)
	poke4(0x5710,0x0700,0x.0002)
	poke4(0x5718,0x.0702,0)
	poke4(0x5720,0x0707.0300)
	poke4(0x5728,0x000f.0f00)
	poke4(0x5730,0x0007.0700)

    active_menus = {}

    --on opening save
    party_status:init()
	party_cast:init() 
    weapons:init()
    armor:init()
	inventory:init()
end

function _update60()
	if #active_menus > 0 then
		active_menus[#active_menus]:update()
		
	elseif say_active then
		if #say_string == say_counter then
			if (btnp(4) or btnp(5)) say_active = false
		else
			say_counter += .5
		end
	else
		if btnp(5) then
			command:open()
		end
		if btnp(4) then
			say("this is a test for a text box\n\nwith scrolling text\n\nand more...?")
		end
	end

end

say_active = false
say_counter = 0
say_string = ""

function say(string)
	say_active = true
	say_counter = 1
	say_string = string
end

function _draw()
	cls(6)
	--map(0,0,0,0,16,16)
	
	for m in all(active_menus) do
		m:draw()
	end
	if say_active then
		text_box:draw(sub(say_string,1,say_counter))
	end
	
print("\#0"..stat(1),0,0,7)
end

wayne = {
	name = "wayne",
	maxhp = 100,
	hp = 75,
	maxmp = 100,
	mp = 100,
	power = 30,
	speed = 30,
	weapon = "w01",
	armor = "a01",
	spells = {"s01","s02"},
	status = {}

}
dedesmuln = {
	name = "dedesmuln",
	maxhp = 90,
	hp = 80,
	maxmp = 100,
	mp = 100,
	power = 30,
	speed = 30,
	weapon = nil,
	armor = nil,
	spells = {"s02"},
	status = {},
}
pongorma = {
	name = "pongorma",
	maxhp = 100,
	hp = 100,
	maxmp = 90,
	mp = 90,
	power = 30,
	speed = 30,
	weapon = nil,
	armor = nil,
	spells = {"s02","s03"},
	status = {},
}
somsnosa = {
	name = "somsnosa",
	maxhp = 90,
	hp = 90,
	maxmp = 90,
	mp = 90,
	power = 30,
	speed = 30,
	weapon = nil,
	armor = nil,
	spells = {},
	status = {},
}

party = {wayne,dedesmuln,pongorma,somsnosa}

weapon_data = {w01 = {name = "penny", description = "penny (pow +1):\n\nworth one cent in a\n\nforeign currency.", stats = {0,0,1,0}},
            w02 = {name = "big fork", description = "big fork (pow +20): don't\n\ntry to eat a salad with\n\nthis, you may hurt yourself.",stats = {0,0,20,0}}}

armor_data = {a01 = {name = "galoshes", description = "galoshes (hp +10):\nprotects you against wet\nfeet, but not much else.",stats = {10,0,0,0}},
            a02 = {name = "stinky hat", description = "stinky hat (hp +10) (spd +5):\nvaluable looking, if\nit weren't for the smell...\n...what is it?",stats = {10,0,0,5}}}

spell_data = {s01 = {name = "heal", cost = 30, description = "heals you for 30% and guards", target = "single", cost = 10,
	out_battle = function(party_m)
		party_m.hp = min(flr(party_m.maxhp*0.3)+party_m.hp,party_m.maxhp)
		--party_m.mp -= spell_data["s01"].cost
	end},
			s02 = {name = "sneeze", cost = 1, description = "does nothing", 
	out_battle = function(party_m)
	end},
			s03 = {name = "group heal", cost = 80, description = "heals the whole party\nfor 30%", target = "group", cost = 90,
	out_battle = function(party_m)
		for p in all(party) do
			p.hp = min(flr(p.maxhp*0.3)+p.hp,p.maxhp)
		end
	end}
	}

item_data = {i01 = {name = "peach", description = "it's a good kind of fuzzy.\nheals for 20 pts", target = "single", 
	out_battle = function(party_m) 
		if (not find_index_id("i01",inventory)) return --this kinda stuff could be set in inventory:init
		party_m.hp = min(party_m.hp+20,party_m.maxhp) 
		use_item("i01") --also can be set in inventory:init
	end},
			i02 = {name = "grape", description = "where are your\nfriends, little guy?\nheals 1 pt", target = "single", 
	out_battle = function(party_m) 
		if (not find_index_id("i02",inventory)) return 
		party_m.hp = min(party_m.hp+1,party_m.maxhp) 
		use_item("i02") 
	end},
			i03 = {name = "pizza", description = "topped with papaya, pork\nrinds, boysenberry yogurt\nand marshmallows.\nheals whole party 30 pts", target = "group", 
	out_battle = function() 
		if (not find_index_id("i03",inventory)) return 
		for p in all(party) do
			p.hp = min(p.hp+30,p.maxhp)
		end
		use_item("i03")
	end}
	}

function use_item(id)
	inventory:remove_item(id) 
	inventory:init() 
	party_status:init() 
end
-->
--menu

cursor_misstroke = 0

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
	local obj = self
	add(active_menus, obj)
	obj.action = action or self.action
	obj.cursor_a = 0
	if (cursor_misstroke != 0) obj.cursor = cursor_misstroke
end

function menu:close()
	deli(active_menus)
	if (#active_menus != 0) cursor_misstroke = self.cursor
	self.cursor = 1
	self.cursor_a = 15
end

function menu:add_item(b) --for menus with quantized items
	local a = find_index_id(b,self)
	if a != false then
		self.contents[a].q += 1
	else
		add(self.contents,{id = b, q = 1})
	end
end

function menu:remove_item(b)
 	local i = find_index_id(b,self)
	self.contents[i].q -= 1
	if (self.contents[i].q == 0) deli(self.contents,i)
end

function menu:update()
	self.cursor_a = (self.cursor_a+1)%30
	if btnp(2) and #self.contents > 0 then
		self.cursor = (self.cursor-2)%#self.contents+1
		self.cursor_a = 0
		cursor_misstroke = 0
	elseif btnp(3) and #self.contents > 0 then
		self.cursor = self.cursor%#self.contents+1
		self.cursor_a = 0
		cursor_misstroke = 0
	elseif btnp(5) then
		self:close()
	elseif btnp(4) and #self.contents > 0 and self.contents[self.cursor].on_click then
		self.contents[self.cursor].on_click(self.action)
		self.cursor = min(self.cursor,#self.contents)
		self.cursor_a = 0
		cursor_misstroke = 0
	end
end

function menu:draw()
	for s in all(self.sub_panels) do
		draw_panel(s)
	end
	draw_panel(self)
	if #self.contents > 0 and self.contents[self.cursor].mouse_over and active_menus[#active_menus] == self then 
        self.contents[self.cursor].mouse_over(self.action) 
    end
end

armor = menu:new(72,0,127,91,
	{"armor",1},
	{{id = "a02",q=2}}
)
function armor:init()
	local cont = {}
	for c in all(self.contents) do
		if c.id == nil then
			del(self.contents,c)
		else
		add(cont,{text = string_value(armor_data[c.id].name,c.q,11),
		id = c.id,
		q = c.q,
        on_click = function(actor)
			local a_con = armor.contents
            local b = actor.armor
			actor.armor = c.id
			
			if b != nil then
				armor:add_item(b)
			end
			
			armor:remove_item(c.id)

			armor:init()
			equipment:init()
			end,
			
        mouse_over = function() text_box:draw(armor_data[c.id].description) end})
		end
	end
	
	add(cont,{text = "",
        on_click = function(actor)
		local b = actor.armor
		actor.armor = nil
		
		if b != nil then
			armor:add_item(b)
		end

		armor:init()
		equipment:init()
	end,
	mouse_over = function() end})
	self.contents = cont
end

weapons = menu:new(72,0,127,91,
	{"weapons",1},
    {{id = "w02", q = 1},
	{id = "w01", q = 1}}--very necessary. null option for removing equipment
)
function weapons:init()
	local cont = {}
	for c in all(self.contents) do
		if c.id == nil then
			del(self.contents,c)
		else
		add(cont,{text = string_value(weapon_data[c.id].name,c.q,11),
		id = c.id,
		q = c.q,
        on_click = function(actor)
			local w_con = weapons.contents
            local b = actor.weapon
			actor.weapon = c.id
			
			if b != nil then
				weapons:add_item(b)
			end
			
			weapons:remove_item(c.id)

			weapons:init()
			equipment:init()
			end,
			
        mouse_over = function() text_box:draw(weapon_data[c.id].description) end})
		end
	end
	
	add(cont,{text = "",
        on_click = function(actor)
		local b = actor.weapon
		actor.weapon = nil
		
		if b != nil then
			weapons:add_item(b)
		end

		weapons:init()
		equipment:init()
	end,
	mouse_over = function() end})
	self.contents = cont
end

actor_stats = menu:new(0,0,55,35)
function actor_stats:init(actor)
	if actor and actor != self.action then 
		self.action = actor or self.action
	end
	local a = self.action
	local t0 = {0,0,0,0}
	local t1 = (a.weapon and weapon_data[a.weapon].stats or t0)
	local t2 = (a.armor and armor_data[a.armor].stats or t0)
	local h,m,p,s = a.maxhp,a.maxmp,a.power,a.speed
	h += t1[1] + t2[1]
	m += t1[2] + t2[2]
	p += t1[3] + t2[3]
	s += t1[4] + t2[4]

	self.title = {self.action.name,1}
	self.contents = {{text = "maxhp: "..h},
					{text = "maxmp: "..m},
					{text = "power: "..p},
					{text = "speed: "..s}}
end

equipment = menu:new(0, 36, 55, 59,
	{"equipment",1},
	{},
	{actor_stats}
)
function equipment:init(actor)
    if actor and actor != self.action then
        self.action = actor
	end
	self.contents = {{text = (self.action.weapon and weapon_data[self.action.weapon].name or ""), 
					on_click = function() 
						weapons:open(self.action) end,
					mouse_over = function() 
						weapons:draw() 
						if (self.action.weapon) text_box:draw(weapon_data[self.action.weapon].description) 
					end},
				{text = (self.action.armor and armor_data[self.action.armor].name or ""), 
					on_click = function() 
						armor:open(self.action) end,
					mouse_over = function() 
						armor:draw() 
						if (self.action.armor) text_box:draw(armor_data[self.action.armor].description)
					end}
	}
	for s in all(self.sub_panels) do --do NOT let this circular reference
		s:init(self.action)
	end
end

spellbook = menu:new(0,0,51,91)
function spellbook:init(actor)
    if actor and actor != self.action then 
        self.action = actor
        self.title = {actor.name,1}
    end
	local cont = {}
	for s in all(self.action.spells) do
		local item = {
			text = string_value(spell_data[s].name,spell_data[s].cost,10),
			id = s,
			mouse_over = function() text_box:draw(spell_data[s].description) end
		}

		if self.action.mp < spell_data[s].cost then
			item.c = 6
		end

		local cast_spell = function(party_l)
			if (self.action.mp < spell_data[s].cost) return
			self.action.mp -= spell_data[s].cost
			spell_data[s].out_battle(party_l)
			spellbook:init()
			party_cast:init()
		end

		if spell_data[s].target == "single" then
			item.on_click = function(party_m)
				party_cast:open({
					on_click = cast_spell, mouse_over = function() end})
			end
		elseif spell_data[s].target == "group" then
			item.on_click = function(party_m)
				party_cast:open({
					on_click = cast_spell, 
					mouse_over = function()
						if party_cast.cursor_a < 15 then 
							for i = 1, #party do
								print("\14\33",4,94+6*i,7)
							end
						end
					end
				})
			end
		else
			item.on_click = cast_spell
		end
		add(cont,item)
	end
	self.contents = cont
	self.cursor = mid(self.cursor,#self.contents,1)
end

inventory = menu:new(48, 8, 95, 43, 
    {"items",1},
	{{id = "i01", q = 2},
	--{id = "i03", q = 1},
	{id = "i02", q = 2}}
)
function inventory:init()
	local cont = {}
	for c in all(self.contents) do
		local item = {
			text = string_value(item_data[c.id].name,c.q,9),
			id = c.id,
			q = c.q,
			mouse_over = function()
				text_box:draw(item_data[c.id].description)
			end
		}
		if item_data[c.id].target == "single" then
			item.on_click = function(party_m)
				party_status:open({on_click = item_data[c.id].out_battle, mouse_over = function() end})
			end
		elseif item_data[c.id].target == "group" then
			item.on_click = function(party_m)
				party_status:open({
					on_click = item_data[c.id].out_battle, 
					mouse_over = function()
						if party_status.cursor_a < 15 then 
							for i = 1, #party do
								print("\14\33",4,94+6*i,7)
							end
						end
					end
				})
			end
		end
		add(cont,item)
	end
	self.contents = cont
	self.cursor = mid(self.cursor,#self.contents,1)
end

party_status = menu:new(0, 92, 127, 127,
	{"name",1,"hp",6,"mp",14,"status",22}
)
function party_status:init()
    local p = {}
    for i = 1, #party do
        add(p,{text = sub(party[i].name,1,4).." "..inset_number(party[i].hp).."/"..inset_number(party[i].maxhp).." "..inset_number(party[i].mp).."/"..inset_number(party[i].maxmp),
        on_click = function(action)
            action.on_click(party[i]) end,
        mouse_over = function(action) 
            action.mouse_over(party[i]) end
        })
    end
    self.contents = p
end

party_cast = menu:new(0, 92, 127, 127, --same shi as party_status because i had issues where i overwrote party_status while casting a spell and that messed up earlier stuff in the menu chain
{"name",1,"hp",6,"mp",14,"status",22}
)

function party_cast:init()
    local p = {}
    for i = 1, #party do
        add(p,{text = sub(party[i].name,1,4).." "..inset_number(party[i].hp).."/"..inset_number(party[i].maxhp).." "..inset_number(party[i].mp).."/"..inset_number(party[i].maxmp),
        on_click = function(action)
            action.on_click(party[i]) end,
        mouse_over = function(action) 
            action.mouse_over(party[i]) end
        })
    end
    self.contents = p
end

equipment_sel = {on_click = function()
			equipment:open() end,
		mouse_over = function(party_m) 
			equipment:init(party_m)
			equipment:draw() end}

spellbook_sel = {on_click = function()
			spellbook:open() end,
		mouse_over = function(party_m) 
			spellbook:init(party_m)
			spellbook:draw() end}

command = menu:new(8,8,47,43,
	{"command",1},
	{   {text = "item", on_click = function() inventory:open() end, mouse_over = function() draw_panel(inventory) end},
		{text = "equip", on_click = function() party_status:open(equipment_sel) end},
		{text = "spell", on_click = function() party_status:open(spellbook_sel) end},
		{text = "system", on_click = function() extcmd("pause") end}
	},
    {party_status}
)

function find_index_id(id,table)
    for i = 1, #table.contents do
        if (table.contents[i].id == id) return i
    end
    return false
end

--battle menus 
--[[
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
}]]

--display helper functions

text_box = {
	x1 = 0,
	y1 = 84,
	x2 = 127,
	y2 = 127,
	text = {"","",""},
	text_c = 1,
	lines = {},
	line_c = 1
}

function text_box:draw(text)
	draw_panel(self)
    print(text,8,92,7)
end

function inset_number(value) --makes a number always take 3 characters
	local z = "00"
	return sub(z,#tostr(value))..value
end

function string_value(string,value,length)
	local z = "                "
	local e = max(0,length-#tostr(value)-1)
	local s = max(1,length-#string-#tostr(value))
	return sub(string,1,e)..sub(z,1,s)..value
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
	local contents = tabl.contents
	if contents then
		for i = 1, #contents do
			print(contents[i].text,x1+8,y1+6*(i-1)+8,(contents[i].c or 7)) --Maybe change the 6 to tabl.yspacing
		end
	end
	if tabl.cursor and tabl.cursor_a < 15 then print("\14\33",x1+4,y1+2+6*tabl.cursor,7) end
end

function d_b(table,p)
	print("\#1length: "..#table)
	for i in all(table) do
		print("\#1"..i[p])
	end
end

__gfx__
000000006666666677777777000000000000000088883333333333c333333333333333333333000000000000000000000000000000000000777bb77700000000
00000000666666667777777700000000000000008887883333333c333333333333333333333300000000000000000000000000000000000073bbbbb700000000
00700700666666667777777700000000000000008777883333330c33333333333333333333330000000000000000000000000000007007007bbbb3b700000000
0007700066666666777777770000000000000000387778333337cc3333333333333333333333000000000000000000000000000000077000bbbbbbbb00000000
00077000666666667777777700000000000000003888778333334cccc9933333333333333333000000000000000000000000000000077000bbbbbbbb00000000
007007006666666677777777000000000000000033388338333344cc00ccc0888333333333330000000000000000000000000000007007007b3bbbb700000000
0000000066666666777777770000000000000000333383333833344cccccc2222883333333330000000000000000000000000000000000007bbbbbb700000000
000000006666666677777777000000000000000033333333333333427999c202333883333333000000000000000000000000000000000000777bb77700000000
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
0201020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020102010201020102010201020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
