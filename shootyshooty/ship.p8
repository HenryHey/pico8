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
debug=true

currentenemy={}

function p(text,x,y,color)
 if (debug) print(text,x,y,color)
end

function distance(x0, y0, x1, y1)
 return sqrt((x1-x0) * (x1-x0) + (y1-y0)*(y1-y0))
end

function distance2(x0, y0, x1, y1)
 return abs((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0))
end

function _init()
	poke(0x5f5d, 8)
 poke(0x5f5c, 8)

	ship.x=60
	ship.y=100
	ship.spd=2
	ship.spr=1
 
 add(startypes, { spd=1, col=1 })
 add(startypes, { spd=2, col=5 })
 add(startypes, { spd=3, col=6 })

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
  shot.x=ship.x
  shot.y=ship.y-2
  shot.spd=-3
  shot.spr=4
  add(shots,shot)
 end
end

function updateshots()
 for s in all(shots) do
  if s.y < 0 then
   del(shots,s)
  else
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
  add(paths, {x=10, y=100})
  add(paths, {x=100, y=100})
  add(paths, {x=100,y=50})
  addenemy(100, 0, 1, 6, paths)
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

function _update()
	updateship()
	updateshots()
 updatestars()
 updateenemies()
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

 local i=1
 for e in all(currentenemy) do
  local color=10+e.currentpath
  p(e.x, i, 8,color)
  p(e.y, i, 16,color)
  p(e.dirx, i, 24,color)
  p(e.diry, i, 30,color)
  p(distance2(e.x, e.y, e.paths[e.currentpath].x, e.paths[e.currentpath].y), i, 36,color)

  circfill(e.x,e.y,3,color)
  i+=32
 end

	p(#currentenemy,1,1)
 p(stat(7),100,1)
end
__gfx__
00000000000010000000100000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000001110000011100000111000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000011c11000111c10001c1110000a9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000001ccc100011ccc000ccc110000a9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000011c11000111c10001c11100000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700011111110111111101111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011111110111111101111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000010000010100000101000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000989000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
