pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
p = {{x=32,y=5,xv=0, yv=0, 
 hrot=.375,hrotv=0,near=0,far=2.125,fov=.12}}
--near -> ground curvature
 --far -> height?
 --fov -> viewing angle
 map_bounds_x = 128
map_bounds_y = 64

scale = -8

guys = {}
guy = {
	x = 0,
	y = 0,
	dist = 0,
	scx = 0,
	scy = 0}

function guy:new(x,y)
	local obj = {
		x = x,
		y = y,
		base = self
	}
	add(guys,obj)
	return setmetatable(obj, {__index = self})
end

function guy:draw(pn)
	local near, far, fov =
		 p[pn].near, p[pn].far, p[pn].fov
	local size = (far+1.4-near)*cos(fov)/(self.dist-near*cos(fov))+0.1
	local width = 16*size
	local height = 32*size
	sspr(16,0,16,32,self.scx-0.5*width,self.scy-height+2,width,height)
end

function _init()
	palt(0,false)
	palt(14,true)
	poke(0x5f5c,-1)

	guy:new(32,1)
	guy:new(32,4)
	guy:new(30,2)
	guy:new(38,3)
	guy:new(28,7)
	guy:new(30,6)
	guy:new(35,2)
end

function _update60()
	--controls + debug
	--[[
	if btn(4) and btn(5) then
		--if (btn(2)) hz += 1/16
		--if (btn(3)) hz -= 1/16
	elseif btn(❎) then --x
		--if (btn(⬆️)) scale_y += 1
		--if (btn(⬇️)) scale_y -= 1
		--if (btn(⬅️)) scale_x -= 1
		--if (btn(➡️)) scale_x += 1
	elseif btn(🅾️) then --z
		if (btn(⬆️)) p[1].fov +=  1/256 
		if (btn(⬇️)) p[1].fov -=  1/256
		if (btn(⬅️)) p[1].near += 1/32
		if (btn(➡️)) p[1].near -= 1/32
	else

		if btn(⬆️) then
			p[1].xv += cos(p[1].hrot)*.05
			p[1].yv += sin(p[1].hrot)*.05
		end
		if btn(⬇️) then
			p[1].xv -= cos(p[1].hrot)*.05
			p[1].yv -= sin(p[1].hrot)*.05
		end
		if (btn(⬅️))p[1].hrotv -= 0.002--1/5
		if (btn(➡️))p[1].hrotv += 0.002--1/5
	end
	--mset(p[1].x-cos(p[1].hrot)*p[1].far*1.45,p[1].y-sin(p[1].hrot)*p[1].far*1.45,17)
	--player character collision
	local fx = p[1].x+cos(p[1].hrot+p[1].hrotv)*p[1].far*1.45 + p[1].xv
	local fy = p[1].y+sin(p[1].hrot+p[1].hrotv)*p[1].far*1.45 + p[1].yv
	if fx < 0 or fx >= 128 or fget(mget(fx,p[1].y+sin(p[1].hrot)*p[1].far*1.45),0) then p[1].hrotv = 0 p[1].xv = 0 end
	if fy < 0 or fy >= 64 or fget(mget(p[1].x+cos(p[1].hrot)*p[1].far*1.45,fy),0) then p[1].hrotv = 0 p[1].yv = 0 end
	--player motion
	p[1].x += p[1].xv
	p[1].y += p[1].yv
	p[1].hrot = norm_angle(p[1].hrot+p[1].hrotv)
	p[1].xv = 0
	p[1].yv = 0
	p[1].hrotv = 0 ]]
	

	if btn(0) then
		p[1].hrot -= 0.004
	elseif btn(1) then
		p[1].hrot += 0.004
	end
	if btn(2) then
		px += cos(p[1].hrot)*0.05
		py += sin(p[1].hrot)*0.05
	elseif btn(3) then
		px -= cos(p[1].hrot)*0.05
		py -= sin(p[1].hrot)*0.05
	end
	p[1].x = -cos(p[1].hrot)*3 + px
	p[1].y = -sin(p[1].hrot)*3 + py

	--player animation
	player:update()
	cpu = stat(1)
end 

px = 30
	py = 4

function _draw()
 cls(1)
	--skybox
 	--draw_background(p[1].hrot)
	--drawing floor + other character
 	draw_track(1,0,32,128,96)
	--drawing player, always in center of room... unless???
	
	
	--debug
	print(stat(1),0,0,14)
	?p[1].hrot
	?p[1].x
	?p[1].y
end

--(index of table that represents camera info, topleft corner of screen xy, resolution in pixels xy)
function draw_track(pn,
	corner_x, corner_y, 
	xres, yres)
	 --local pl= p
		--local gx, gy, hrot, near, far, fov =
		--p[pn].x, p[pn].y, p[pn].hrot, p[pn].near, p[pn].far, p[pn].fov

	--(postion xy, angle,)
	local gx, gy, hrot,
	 near, far, fov =
		p[pn].x, p[pn].y, p[pn].hrot,
		 p[pn].near, p[pn].far, p[pn].fov
	
	local coshmf=cos(hrot-fov)
	local sinhmf=sin(hrot-fov)
	local coshpf=cos(hrot+fov)
	local sinhpf=sin(hrot+fov)
	
	local farx1 = gx+coshmf*far
	local fary1 = gy+sinhmf*far
	
	local nearx1 = gx+coshmf*near
	local neary1 = gy+sinhmf*near
	
	local farx2 = gx+coshpf*far
	local fary2 = gy+sinhpf*far
	
	local nearx2 = gx+coshpf*near
	local neary2 = gy+sinhpf*near
	
	--do as many calculations as possible outside the loop
	local v1,v2,v3,v4 = 
	farx1-nearx1,fary1-neary1,farx2-nearx2,fary2-neary2 

	local xshift = 7
	if(xres == 64) xshift = 6
	
	--draw horozontal lines top to bottom
	for y = 0, yres, 1 do
	
		local sampledepth = yres/(y-scale) -- (y-scale)	
	
		local startx = v1*sampledepth+nearx1
		local starty = v2*sampledepth+neary1
		local endx = v3*sampledepth+nearx2
		local endy = v4*sampledepth+neary2
			
		--draw distance/xres. used for mdx,mdy in tline
		local x1 = (endx-startx)>>xshift
		local y1 = (endy-starty)>>xshift

		--dont draw map tiles out of bounds
		if startx < -128 or startx >= 256 or starty < -128 or starty >= 256 or
		endx <-128 or endx >= 256 or endy < -128 or endy >= 256 then
			goto nextline
		end

		tline( 0, y+corner_y, xres, y+corner_y,
		startx, starty,
		x1, y1)
		::nextline::

		
	end

	local zsort = {player}
	for g in all(guys) do
		local dx = g.x-gx
		local dy = g.y-gy

		local theta = norm_angle(hrot - atan2(dx,dy))
		g.dist = sqrt(dx*dx+dy*dy)*cos(theta)
		g.scy = (far-near)*cos(fov)/(g.dist-near*cos(fov))*yres+scale+corner_y
		if g.scy >= corner_y and theta == mid(-fov-0.02,theta,fov+0.02) then
			local depth = (g.dist-near*cos(fov))/((far-near)*cos(fov))
			local sx = v1*depth+nearx1
			local ex = v3*depth+nearx2
			g.scx = ((g.x-sx)<<xshift)/(ex-sx)
			for i = 1, #zsort do
				if g.dist >= zsort[i].dist then
					add(zsort,g,i)
				elseif i == #zsort then
					add(zsort,g)
				end
			end
		end
	end

	for z in all(zsort) do
		z:draw(pn)
	end
	
end

function draw_background(hrot)
		--
		--spr( 76, 95, 0, 4, 4 )
		--map( 0, 35, 63, 0, 8, 4 )
		rectfill( 0, 0, 127, 14, 8 )
		rectfill( 0, 13, 127, 14, 9 )
		line(0, 15, 127, 15, 8)
		--spr( 104, 63, 17, 8, 4 )
		rotation_ratio = 8
		m=flr(hrot<<rotation_ratio)%(8*2)
		--spr( 104, 0, 15, 4, 4 )
		sspr(64+m,0, 32-m,32, 0-m,0)
		if m~=0 then
		sspr(64,0, 2*m,32, 32-2*m,0)
	end
	for i = 0, 32 do
		adder = (i)<<6 //add 64
		memcpy(0x6000+adder+16, 0x6000+adder, 16 )
	end
	
	--copis 1/2 of whats in the screen to 2/2
	for i = 0, 32 do
		adder = (i)<<6 //add 64
		memcpy(0x6000+adder+32, 0x6000+adder, 32 )
	end
	
--rectfill( 0, 0, 127, 16, 8 )
--rectfill( 0, 0, 127, 16, 8 )
end

player = {s = 2, a = 0, f = false, d = 3, dist = 3}

function player:update()
	if btn(2) then
		self.d = 2
	elseif btn(3) then
		self.d = 3
	elseif btn(1) then
		self.d = 1
	elseif btn(0) then
		self.d = 0
	end
	
	if btn(0) or btn(1) or btn(2) or btn(3) or btn(4) then
		self.a = (self.a%4)+0.1
	else
		self.a = 0
	end
	
	if self.d <= 1 then
		self.f = (self.d == 1)
		self.s = (self.a > 2 and 12 or 14)
		if self.a == 0 then 
			self.s = 10 
		end
	elseif self.d == 2 then
		self.f = (self.a > 2)
		self.s = (self.a == 0 and 6 or 8)
		
	elseif self.d == 3 then
		self.f = (self.a > 2)
		self.s = (self.a == 0 and 2 or 4)
		
	end
end

function player:draw()
	spr(self.s,56,44,2,4,self.f)
end

function norm_angle(a)
	return (a+0.5)%1-0.5
end
__gfx__
00000000f4ffffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000fffff4ffeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00700700ffffff4feeeeee04440eeeeeeeeeee000eeeeeeeeeeeee09440eeeeeeeeeee09440eeeeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00077000fffff4ffeeeeee09440eeeeeeeeee04440eeeeeeeeeeee04440eeeeeeeeeee04440eeeeeeeee09440eeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeee
00077000fff4ffffeeee000333000eeeeee0009440eeeeeeeeeeee00400eeeeeeeeeee00400eeeeeeeee0b330eeeeeeeeeeee000eeeeeeeeeee09440eeeeeeee
00700700ffffffffeee0990ff00990eeee0330333000eeeeeeee00b000300eeeeeee00b000300eeeeeee0ff30eeeeeeeeeee09440eeeeeeeeee0b330eeeeeeee
000000004fffffffeee33300f00330eeee3330ff00330eeeeee04403330440eeeee033033303f0eeeeee0f300eeeeeeeeeee0b330eeeeeeeeee0ff30eeeeeeee
00000000ffffffffee0bb330003b333ee030330f003333eeeee33bb33333b3eeee033bb3333b30eeeeeee00990eeeeeeeeee0ff30eeeeeeeeee0f300eeeeeeee
00000000ccc3ccccee033330f033330ee0b0b3000b3030eeee0b33333333330eee0003333b33330eeeeee030030eeeeeeeee0f3000eeeeeeeeee00990eeeeeee
00000000cc333ccceeb330b303b3030ee000330f030030eeee0330333330330eee0440333330330eeeee0303b00eeeeeeeeee00990eeeeeeeeee0303b0eeeeee
000000003c333c3cee0030bb3333000ee0f0333030f000eeee0000333330000eee0f00333330000eeeee0b0b330eeeeeeeeee300b30eeeeee0e0b30b330eeeee
000000003333333ce04400333330040ee0f0333330fff0eeee0440033300040eee0f00033300eeeeeeee0304440eeeeeee0ee0b30330eeee0f0033003330eeee
00000000c33333cce0ff000333300f0eee0e0333000ff0eee09f000000000f0eee4900000000eeeeeeee0300ff0eeeeee0f003330300eeee0ff033300030eeee
000000003333333ce09900499940090eeeee049944000eeee09000499440090eee0000449940eeeeeeeee000f90eeeeee0fff33033f0eeeee09000009f0eeeee
00000000c3c3c3ccee0ff0000000ff0eeeee00333000eeeeee00e0300003040eeeee030000b33eeeeeee0909f90eeeeeee09f900000eeeeeee000990f90eeeee
00000000ccc3ccccee0ff003333000eeeee33b333b30eeeeeeeee0333330e0eeeeee303333330eeeeeee303ff0eeeeeeeee0049940eeeeeeeeee000ff30eeeee
0000000000000000eeee03b330330eeeeee0b3303b30eeeeeeee033333b0eeeeeeee03333b330eeeeeee0033330eeeeeeeee0003003eeeeeeeee033330eeeeee
0000000000000000eeee033303b30eeeeee0b330b330eeeeeeee033300330eeeeeee03b300330eeeeeee3033330eeeeeeeee0333b30eeeeeeeee0b3b30eeeeee
0000000000000000eeee0b3303b30eeeeee03b30330eeeeeeeee03b303b30eeeeeee0bb3033b0eeeeeee300b30eeeeeeeee0b033330eeeeeeee0b3330eeeeeee
0000000000000000eeee33b303330eeeeee0bb303b0eeeeeeeee0b3303b30eeeeeee3b3003033eeeeeee003bb0eeeeeeee033003b30eeeeeee03bb300eeeeeee
0000000000000000eeee0bb300b30eeeeee33330003eeeeeeeee033303330eeeeeeee3300040eeeeeeee3033b0eeeeeeee033303bb0eeeeeee03330030eeeeee
0000000000000000eeee0b3000330eeeeeee0330440eeeeeeeee0b3300330eeeeeeee3330400eeeeeeeee00b30eeeeeeee0b30033b0eeeeeee0b300330eeeeee
0000000000000000eeee03330030eeeeeeee033000eeeeeeeeee033000300eeeeeeee0330440eeeeeeeee30330eeeeeeee0b330b330eeeeeee0b3003330eeeee
0000000000000000eeee00330330eeeeeeee3300eeeeeeeeeeee033003b30eeeeeeee0b3000eeeeeeeeee30b330eeeeeee0330e03b30eeeeee0333003330eeee
0000000000000000eeee03300330eeeeeeee0330eeeeeeeeeeee033300330eeeeeeee0330eeeeeeeeeeee003b30eeeeeeee030ee033300eeeee0330e00440eee
0000000000000000eeee03300300eeeeeeee0330eeeeeeeeeeeee03300330eeeeeeee3030eeeeeeeeeeee000330eeeeeeee030eee000440eeee0300eee0440ee
0000000000000000eeee000000400eeeeeee0300eeeeeeeeeeeee03300000eeeeeeeee000eeeeeeeeeeee090400eeeeeeee000eeeee0040eeee0440ee0440eee
0000000000000000eeee0400044000eeeeee04000000eeeeeeeee00400440eeeeeeeee040000eeeeeeee09404400eeeeee0440eeeeee090eeee0940ee000eeee
0000000000000000eee009400044000eeee00440000000eeeeee0094000400eeeeeee004400000eeeeee000094000eeee0440eeeeeee00eeee094000000000ee
0000000000000000eee004000000000eeee009900000000eeeee09940044000eeeeee0044000000eeeeee00944000eeee00000000000000eee0000000000000e
0000000000000000eee009900000000eeee000000000000eeeee00440000000eeeeee0000000000eeeeeee000000eeeeeee00000000000eeeee000000000eeee
0000000000000000eeee0000000000eeeeee0000000000eeeeeee000000000eeeeeeee0000000eeeeeeeeeee000eeeeeeeeee0000000eeeeeeeee00000eeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
__gff__
0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010101010101010101010111110101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010100000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010100000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
1101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
1101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
1101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
