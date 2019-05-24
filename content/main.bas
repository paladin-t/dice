REM Dice
REM A 3D dice program.
REM License: CC-BY
REM
REM Press Ctrl+R to run.

import "btnbhvr"

drv = driver()
print drv, ", detail type is: ", typeof(drv);

btn_roll = load_resource("btnbhvr.sprite")

background = load_resource("background.quantized")
face1 = load_resource("face1.quantized")
face2 = load_resource("face2.quantized")
face3 = load_resource("face3.quantized")
face4 = load_resource("face4.quantized")
face5 = load_resource("face5.quantized")
face6 = load_resource("face6.quantized")

w = 1
p0 = vec4(-1, 1, 1, w)
p1 = vec4(1, 1, 1, w)
p2 = vec4(1, -1, 1, w)
p3 = vec4(-1, -1, 1, w)
p4 = vec4(-1, 1, -1, w)
p5 = vec4(1, 1, -1, w)
p6 = vec4(1, -1, -1, w)
p7 = vec4(-1, -1, -1, w)

ms = mat4x4_from_scale(15, 15, 15)
mr = nil
mt = nil
mm = nil
mv = mat4x4_lookat(vec3(0, 40, -80), vec3(0, 0, 0), vec3(0, 1, 0))
mp = mat4x4_perspective_fov(pi * 0.5, 160 / 128, -10, 10, true)

rx = 0
ry = 0
rz = 0
ax = 0
ay = 0
az = 0
px = 0
py = 0
pz = 0
vx = 0
vy = 0
vz = 0
cy = 0
ey = 4

def roll()
	ax = rnd * 2 - 1
	ay = rnd * 2 - 1
	az = rnd * 2 - 1
	vv = normalize(vec3(ax, ay, az)) * 1000
	unpack(vv, ax, ay, az)

	vx = rnd * 2 - 1
	vy = rnd * 2 + 1
	vz = rnd * 2 - 1
	vv = normalize(vec3(vx, vy, vz)) * 1000
	unpack(vv, vx, vy, vz)

	cy = 0
enddef

def homogenize(p)
	unpack(p, x, y, z, w)
	rhw = 1 / w
	rtx = (x * rhw + 1) * 160 * 0.5
	rty = (1 - y * rhw) * 128 * 0.5
	rtz = z * rhw
	rtw = 1

	return vec4(rtx, rty, rtz, rtw)
enddef

def rasterize(p)
	q = p * (mm * mv * mp)
	q = homogenize(q)

	return q
enddef

def sound()
	play "D16"
enddef

def update(delta)
	img background, 0, 0

	px = px + vx * delta
	py = py + vy * delta
	pz = pz + vz * delta
	radius = 40
	if px < (-radius) then
		px = -radius
		vx = abs(vx)
		sound()
	elseif px > radius then
		px = radius
		vx = -abs(vx)
		sound()
	endif
	if py < (-radius) then
		py = -radius
		vy = abs(vy)
		cy = cy + 1
		sound()
	elseif py > radius then
		py = radius
		vy = -abs(vy)
		sound()
	endif
	if pz < (-radius) then
		pz = -radius
		vz = abs(vz)
		sound()
	elseif pz > radius then
		pz = radius
		vz = -abs(vz)
		sound()
	endif

	if cy < ey then
		rx = rx + ax * delta
		ry = ry + ay * delta
		rz = rz + az * delta
	else
		vx = 0
		vy = 0
		vz = 0
		ax = 0
		ay = 0
		az = 0
		rx = round(rx / 90) * 90
		ry = round(ry / 90) * 90
		rz = round(rz / 90) * 90
	endif

	mr = mat4x4_from_euler(rad(rx), rad(ry), rad(rz))
	mt = mat4x4_from_translation(px, py, pz)
	mm = mr * ms * mt

	p0_ = rasterize(p0)
	p1_ = rasterize(p1)
	p2_ = rasterize(p2)
	p3_ = rasterize(p3)
	p4_ = rasterize(p4)
	p5_ = rasterize(p5)
	p6_ = rasterize(p6)
	p7_ = rasterize(p7)

	unpack(p0_, x0, y0)
	unpack(p1_, x1, y1)
	unpack(p2_, x2, y2)
	unpack(p3_, x3, y3)
	unpack(p4_, x4, y4)
	unpack(p5_, x5, y5)
	unpack(p6_, x6, y6)
	unpack(p7_, x7, y7)

	tritex face1, vec4(x0,y0,0,0), vec4(x2,y2,1,1), vec4(x1,y1,1,0)
	tritex face1, vec4(x0,y0,0,0), vec4(x3,y3,0,1), vec4(x2,y2,1,1)
	tritex face2, vec4(x4,y4,0,0), vec4(x5,y5,1,0), vec4(x6,y6,1,1)
	tritex face2, vec4(x4,y4,0,0), vec4(x6,y6,1,1), vec4(x7,y7,0,1)
	tritex face3, vec4(x1,y1,0,0), vec4(x6,y6,1,1), vec4(x5,y5,1,0)
	tritex face3, vec4(x1,y1,0,0), vec4(x2,y2,0,1), vec4(x6,y6,1,1)
	tritex face4, vec4(x4,y4,0,0), vec4(x3,y3,1,1), vec4(x0,y0,1,0)
	tritex face4, vec4(x4,y4,0,0), vec4(x7,y7,0,1), vec4(x3,y3,1,1)
	tritex face5, vec4(x3,y3,0,0), vec4(x6,y6,1,1), vec4(x2,y2,1,0)
	tritex face5, vec4(x3,y3,0,0), vec4(x7,y7,0,1), vec4(x6,y6,1,1)
	tritex face6, vec4(x4,y4,0,0), vec4(x1,y1,1,1), vec4(x5,y5,1,0)
	tritex face6, vec4(x4,y4,0,0), vec4(x0,y0,0,1), vec4(x1,y1,1,1)

	if cy >= ey then
		if btnbhvr(btn_roll, 59,16,32,12) then
			roll()
		endif
	endif

	btnrst()
enddef

roll()

update_with(drv, call(update))
