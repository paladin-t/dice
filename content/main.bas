REM Dice
REM A 3D dice program.
REM License: CC-BY
REM
REM Press Ctrl+R to run.

drv = driver()
print drv, ", detail type is: ", typeof(drv);

background = load_resource("background.quantized")
face1 = load_resource("face1.quantized")
face2 = load_resource("face2.quantized")
face3 = load_resource("face3.quantized")
face4 = load_resource("face4.quantized")
face5 = load_resource("face5.quantized")
face6 = load_resource("face6.quantized")

p0 = vec4(-1, 1, 1, 1)
p1 = vec4(1, 1, 1, 1)
p2 = vec4(1, -1, 1, 1)
p3 = vec4(-1, -1, 1, 1)
p4 = vec4(-1, 1, -1, 1)
p5 = vec4(1, 1, -1, 1)
p6 = vec4(1, -1, -1, 1)
p7 = vec4(-1, -1, -1, 1)

ms = mat4x4_from_scale(15, 15, 15) ' Scaling matrix.
mr = nil ' Rotation matrix.
mt = nil ' Translation matrix.
mm = nil ' Multiplied matrix.
mv = mat4x4_lookat(vec3(0, 40, -80), vec3(0, 0, 0), vec3(0, 1, 0)) ' View matrix.
mp = mat4x4_perspective_fov(pi * 0.5, 160 / 128, -10, 10, true) ' Projection matrix.

rot_x = 0 ' Rotation.
rot_y = 0
rot_z = 0
ang_x = 0 ' Angular velocity.
ang_y = 0
ang_z = 0
pos_x = 0 ' Position.
pos_y = 0
pos_z = 0
vel_x = 0 ' Velocity.
vel_y = 0
vel_z = 0
col_n = 0 ' Collision counter.
col_end = 4 ' Collision condition.

def roll()
	ang_x = rnd * 2 - 1
	ang_y = rnd * 2 - 1
	ang_z = rnd * 2 - 1
	tmp = normalize(vec3(ang_x, ang_y, ang_z)) * 1000
	unpack(tmp, ang_x, ang_y, ang_z)

	vel_x = rnd * 2 - 1
	vel_y = rnd * 2 + 1
	vel_z = rnd * 2 - 1
	tmp = normalize(vec3(vel_x, vel_y, vel_z)) * 1000
	unpack(tmp, vel_x, vel_y, vel_z)

	col_n = 0
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

	pos_x = pos_x + vel_x * delta
	pos_y = pos_y + vel_y * delta
	pos_z = pos_z + vel_z * delta
	radius = 40
	if pos_x < (-radius) then
		pos_x = -radius
		vel_x = abs(vel_x)
		sound()
	elseif pos_x > radius then
		pos_x = radius
		vel_x = -abs(vel_x)
		sound()
	endif
	if pos_y < (-radius) then
		pos_y = -radius
		vel_y = abs(vel_y)
		col_n = col_n + 1
		sound()
	elseif pos_y > radius then
		pos_y = radius
		vel_y = -abs(vel_y)
		sound()
	endif
	if pos_z < (-radius) then
		pos_z = -radius
		vel_z = abs(vel_z)
		sound()
	elseif pos_z > radius then
		pos_z = radius
		vel_z = -abs(vel_z)
		sound()
	endif

	if col_n < col_end then
		rot_x = rot_x + ang_x * delta
		rot_y = rot_y + ang_y * delta
		rot_z = rot_z + ang_z * delta
	else
		vel_x = 0
		vel_y = 0
		vel_z = 0
		ang_x = 0
		ang_y = 0
		ang_z = 0
		rot_x = round(rot_x / 90) * 90
		rot_y = round(rot_y / 90) * 90
		rot_z = round(rot_z / 90) * 90
	endif

	mr = mat4x4_from_euler(rad(rot_x), rad(rot_y), rad(rot_z))
	mt = mat4x4_from_translation(pos_x, pos_y, pos_z)
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

	if col_n >= col_end then
		text 2, 2, "Touch to roll", rgba(0, 0, 0)
		text 1, 1, "Touch to roll", rgba(255, 255, 255)
		touch 0, _1, _2, m0
		if m0 then
			roll()
		endif
	endif
enddef

roll()

update_with(drv, call(update))
