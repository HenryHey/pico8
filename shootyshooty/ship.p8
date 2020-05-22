pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
ship={}
shots={}
stars={}
maxstars=30
distbetweenenemies = 20
disttopath2 = 2
startypes={}
debug=false

currentenemy={}
explosions={}

function p(text,x,y,color)
 if (debug) print(text,x,y,color)
end

function printshot(s)
 p(s.x..','..s.y, 1, 8, 7)
 p(s.x+s.width..','..s.y+s.height, 1, 16, 7)
end

function printenemy(e)
 p(e.x..','..e.y, 1, 32, 7)
 p(e.x+e.width..','..e.y+e.height, 1, 40, 7)
end

function distance(x0, y0, x1, y1)
 return sqrt((x1-x0) * (x1-x0) + (y1-y0)*(y1-y0))
end

function distance2(x0, y0, x1, y1)
 return abs((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0))
end

function _init()
	poke(0x5f5d, 4)
 poke(0x5f5c, 8)

	ship.x=60
	ship.y=100
	ship.spd=2
	ship.spr=1
 
 add(startypes, { spd=0.5, col=1 })
 add(startypes, { spd=1, col=5 })
 add(startypes, { spd=1.5, col=6 })

 for i=1,maxstars do
  local star={}
  star.x=rnd(128)
  star.y=rnd(128)
  star.type=flr(rnd(3)+1)
  add(stars,star)
 end
end

function updateship()
 if ship.x > 2 and btn(0) then
  ship.x-=ship.spd
  ship.spr=2
 elseif ship.x < 120 and btn(1) then
  ship.x+=ship.spd
  ship.spr=3
 else
  ship.spr=1
 end
 
 if ship.y > 2 and btn(2) then
  ship.y-=ship.spd
 elseif ship.y < 120 and btn(3) then
  ship.y+=ship.spd
 end
 
 if btnp(4) then
  shot={}
  shot.x=ship.x+4
  shot.y=ship.y-2
  shot.spd=-3
  shot.spr=4
  shot.width=3
  shot.height=4
  add(shots,shot)
 end
end

function updateshots()
 for s in all(shots) do
  if s.y < 0 then
   del(shots,s)
  else
   for e in all(currentenemy) do
    if s.x + s.width >= e.x and s.x <= e.x + e.width and
       s.y <= e.y + e.height and s.y + s.height >= e.y then
     e.state = 1
     explosion = {}
     explosion.x = e.x - 4
     explosion.y = e.y - 4
     explosion.spr = 5
     explosion.flipx = rnd({true, false})
     explosion.flipy = rnd({true, false})
     add(explosions, explosion)
     del(shots,s)
    end
   end
   s.y+=shot.spd
  end
 end
end

function updatestars()
 for s in all(stars) do
  if s.y > 128 then
   s.y=5
  else
   s.y+=startypes[s.type].spd
  end
 end
end

function updateexplosions()
 for e in all(explosions) do
  if e.spr < 13 then 
   e.spr+=2
  else
   del(explosions, e)
  end
 end
end

function addenemy(x, y, spd, number, paths)
 local e = {}
 e.number = number
 e.x=x
 e.y=y
 e.spd=spd
 e.width=6
 e.height=7
 e.state=0
 e.paths={}
 for p in all(paths) do
  add(e.paths, p)
 end
 e.pathdistance = distance(e.x, e.y, e.paths[1].x, e.paths[1].y)
 e.dirx= (e.paths[1].x - e.x) / e.pathdistance;
 e.diry= (e.paths[1].y - e.y) / e.pathdistance;
 e.currentpath=1
 add(currentenemy, e)
 for i=2,number do
  local e2 = {}
  for k,v in pairs(e) do
   e2[k] = v
  end
  e2.x += - (i-1) * e.dirx * distbetweenenemies
  e2.y += - (i-1) * e.diry * distbetweenenemies
  e2.currentpath = 1
  add(currentenemy, e2)
 end
end

function updateenemies()
 if #currentenemy == 0 then
  paths = {}
  add(paths, {x=30, y=100})
  add(paths, {x=100, y=100})
  add(paths, {x=100,y=-10})
  addenemy(30, -10, 0.5, 6, paths)
 else
  for e in all(currentenemy) do
   if distance2(e.x, e.y, e.paths[e.currentpath].x, e.paths[e.currentpath].y) > disttopath2 then
    e.x += e.dirx * e.spd
    e.y += e.diry * e.spd
   else if e.currentpath < #e.paths then
     e.currentpath+=1
     e.pathdistance=distance(
      e.x, e.y, e.paths[e.currentpath].x, e.paths[e.currentpath].y
     )
     e.dirx= (e.paths[e.currentpath].x - e.x) / e.pathdistance;
     e.diry= (e.paths[e.currentpath].y - e.y) / e.pathdistance;
    else
     del(currentenemy,e)
    end
   end
  end
 end
end

function _update60()
	updateship()
	updateshots()
 updatestars()
 updateenemies()
 updateexplosions()
end

function drawenemy()
 for e in all(currentenemy) do
  if e.state == 0 then
   local col=10+e.currentpath
   rectfill(e.x,e.y,e.x+e.width,e.y+e.height,col)
  elseif e.state == 1 then
   del(currentenemy, e)
  end
 end
end

function drawexplosions()
 for e in all(explosions) do
  spr(e.spr, e.x, e.y, 2, 2, e.flipx, e.flipy)
 end
end

function _draw()
	cls()
 
 for s in all(stars) do
  pset(s.x,s.y,startypes[s.type].col)
 end

	for s in all(shots) do
		spr(s.spr,s.x,s.y)
	end
	spr(ship.spr,ship.x,ship.y)

 drawenemy()
 drawexplosions()

end
__gfx__
000000000000100000001000000010000a0000000000000000000000000aa0000000000000000000000000000000000001100000009900000100000000000000
00000000000111000001110000011100a9a000000000000000000000000aaa000000000a00099900000000000009990011110000049000001100000000000000
00700700000131000001110000011100a9a0000000000077777000000000aaaa000000aa009aaa9000000000009aaa9001100000094000000100900000000000
000770000063b36000331160006113300a000000000007777777000000000aaaaaa00aa0009a999000000000009a019000000000040001000000990000000000
00077000001bbb1000b36610001663b000000000000077777777700000000a7aaaaaaaa000999a99990000000099011000000000000000100000044000000000
00700700061bbb1606b31116061113b60000000000077777777777000000aaa77aa7aa00000999aa999999000009000000099900000000000000004000000000
00000000016666610166666101666661000000000007777777777700aaaaa777777aa9000000099aa99aa9900100000aa00aa990010000000900000000000000
000000000101110101011101010111010000000000077777777777000aaaaa7777aaa0000000099aaaaaaa90111000000a000a90011000000090000000000000
00000000000000000000000000000000000000000007777777777700000aaaa77aaaa0000000099a77aa99901110000107a00990110000010000000000000000
000000000000000000000000000000000000000000077777777777000009aa77aaaaa0000000009aaa999900010000111a009900000000110000000000000000
0000000098900000000000000000000000000000000077777777700000009a7aaaaa9000000009aa990000000000091a99000000000000100000000000000000
0000000099900000000000000000000000000000000007777777000000000aaaaaa9000000009aaa900000000000900190011000000000010000000000000000
000000000900000000000000000000000000000000000077777000000000aaa90000000000009a9a900000000001900000111100009100000000010000000000
00000000000000000000000000000000000000000000000000000000000aaa000000000000009999900000000001999090111100000994040001010000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000999000000000000199900011000000499900000100000000000
