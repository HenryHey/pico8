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
  ship.spr=3
 elseif ship.x < 120 and btn(1) then
  ship.x+=ship.spd
  ship.spr=2
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

 if #shots > 0 then
  printshot(shots[1])
 end

 if #currentenemy > 0 then
  printenemy(currentenemy[1])
 end

 p(stat(7),100,1)
end
__gfx__
000000000000100000001000000010000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000111000001110000011100a9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000011c11000111c10001c1110a9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000001ccc100011ccc000ccc1100a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000011c11000111c10001c1110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700011111110111111101111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011111110111111101111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000010000010100000101000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000989000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
