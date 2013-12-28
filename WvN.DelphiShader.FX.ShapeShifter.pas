unit WvN.DelphiShader.FX.ShapeShifter;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
// https://www.shadertoy.com/view/lds3DH

// {$define noise_use_smoothstep}
TShapeShifter = class(TShader)
public const
  vec2_1:vec2=(x:2.31;y:53.21);
  vec3_2:vec3=(x:1;y:1;z:1);
  vec4_3:vec4=(x:1;y:1;z:1;w:1);
  vec4_4:vec4=(x:0;y:0;z:0;w:0);
  vec2_5:vec2=(x:1;y:1);
  vec3_6:vec3=(x:1;y:1;z:1);
  vec4_7:vec4=(x:1;y:1;z:1;w:1);
  vec2_8:vec2=(x:2;y:2);
  vec2_9:vec2=(x:1;y:1);
  vec3_10:vec3=(x:0;y:0;z:0);
  vec3_11:vec3=(x:0;y:0;z:0);
  vec3_12:vec3=(x:0;y:1;z:0);
  vec3_13:vec3=(x:0.3;y:0.4;z:0.7);
  vec3_14:vec3=(x:0;y:1;z:0);
  vec3_15:vec3=(x:0.4;y:0.4;z:0.4);
  vec3_16:vec3=(x:2.4;y:0.4;z:0.4);
  var
  light:vec3; //global variable that holds light direction

  function hash(  x:float ):float;overload;
  function hash( const x:vec2 ):float;overload;
  function hashmix(  x0, x1, interp:float ):float;overload;
  function hashmix( const p0, p1:vec2; interp:vec2 ):float;overload;
  function hashmix( const p0, p1, interp:vec3 ):float;overload;
  function hashmix( const p0, p1, interp:vec4 ):float;overload;
  function noise(  p:float ):float;overload;
  function noise( const p:vec2 ):float;overload;
  function noise( const p:vec3 ):float;overload;
  function noise( const p:vec4 ):float;overload;
  function rotate( const v:vec2; angle:float ):vec2;
  function rotate_z( const v:vec2; angle:float ):vec2;overload;
  function rotate_z( const v:vec3; angle:float ):vec3;overload;
  function rotate_y( const v:vec3; angle:float ):vec3;
  function rotate_x( const v:vec3; angle:float ):vec3;
  function cc( const color:vec3; factor, factor2:float ):vec3;
  function material0( const uv:vec2 ):vec2;
  function dist( const p:vec3 ):float;
  function normal( const p:vec3; e:float ):vec3;
  function plane( const p, d:vec3 ):vec3;
  function sun( const d:vec3 ):float;
  function stars( const _d:vec3 ):vec3;
  function backdrop( const p, d:vec3 ):vec3;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  ShapeShifter: TShader;

implementation

uses SysUtils, Math;

constructor TShapeShifter.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TShapeShifter.PrepareFrame;
begin
{by mu6k, Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

 A shape changing object. Use mouse to move the camera around the object.

 The original idea was to make a box that bends its shape, but then I though it's
 a lot more interesting if there are more shapes involved. I also implemented a
 plane itersection for the background. I'll be needing more of that plane intersection
 for another idea I had.

 The plane and background are done 100% seperately from the distance field. This allows
 me to calculate the shadow cast on the plane separately from the long loop and I don't
 run out of instructions.

 This should run at high framerates, even at fullscreen...

 25/05/2013:
 - published
 - added comments

 30/05/2013:
 - added the fix which was suggested by iq

 muuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuusk not }

end;

function TShapeShifter.hash(  x:float ):float;
begin
	Exit( fract(system.sin(x*0.0127863)*17143.321) );
end;


function TShapeShifter.hash( const x:vec2 ):float;
begin
	Exit( fract(system.cos(dot(x.xy,vec2_1)*124.123)*412) );
end;


function TShapeShifter.hashmix(  x0, x1, interp:float ):float;
begin
	x0  := hash(x0);
	x1  := hash(x1);
	{$ifdef noise_use_smoothstep}
	interp  := smoothstep(0,1,interp);
	{$endif }
	Exit( mix(x0,x1,interp) );
end;


function TShapeShifter.hashmix( const p0, p1:vec2; interp:vec2 ):float;
var
  v0 :float;
  v1 :float;
begin
	v0  := hashmix(p0.x+p0.y*128,p1.x+p0.y*128,interp.x);
	v1  := hashmix(p0.x+p1.y*128,p1.x+p1.y*128,interp.x);
	{$ifdef noise_use_smoothstep}
	interp  := smoothstep(vec2Black,vec2White,interp);
	{$endif }
	Exit( mix(v0,v1,interp.y) );
end;


function TShapeShifter.hashmix( const p0, p1, interp:vec3 ):float;
var
  v0 :float;
  v1 :float;
begin
	v0  := hashmix(p0.xy+Vec2.Create(p0.z*143,0),p1.xy+Vec2.Create(p0.z*143,0),interp.xy);
	v1  := hashmix(p0.xy+Vec2.Create(p1.z*143,0),p1.xy+Vec2.Create(p1.z*143,0),interp.xy);
	{$ifdef noise_use_smoothstep}
	interp  := smoothstep(Vec3Black,vec3_2,interp);
	{$endif }
	Exit( mix(v0,v1,interp.z) );
end;


function TShapeShifter.hashmix( const p0, p1, interp:vec4 ):float;
var
  v0 :float;
  v1 :float;
begin
	v0  := hashmix(p0.xyz+Vec3.Create(p0.w*17,0,0),p1.xyz+Vec3.Create(p0.w*17,0,0),interp.xyz);
	v1  := hashmix(p0.xyz+Vec3.Create(p1.w*17,0,0),p1.xyz+Vec3.Create(p1.w*17,0,0),interp.xyz);
	{$ifdef noise_use_smoothstep}
	interp  := smoothstep(vec4_4,vec4_3,interp);
	{$endif }
	Exit( mix(v0,v1,interp.w) );
end;


function TShapeShifter.noise(  p:float ):float; // 1D noise
var
  pm :float;
  pd :float;

begin
	pm  := &mod(p,1);
	pd  := p-pm;
	Exit( hashmix(pd,pd+1,pm) );
end;


function TShapeShifter.noise( const p:vec2 ):float; // 2D noise
var
  pm :vec2;
  pd :vec2;

begin
	pm  := &mod(p,1);
	pd  := p-pm;
	Exit( hashmix(pd,(pd+vec2_5), pm) );
end;


function TShapeShifter.noise( const p:vec3 ):float; // 3D noise
var
  pm :vec3;
  pd :vec3;

begin
	pm  := &mod(p,1);
	pd  := p-pm;
	Exit( hashmix(pd,(pd+vec3_6), pm) );
end;


function TShapeShifter.noise( const p:vec4 ):float; // 4D noise
var
  pm :vec4;
  pd :vec4;

begin
	pm  := &mod(p,1);
	pd  := p-pm;
	Exit( hashmix(pd,(pd+vec4_7), pm) );
end;



function TShapeShifter.rotate( const v:vec2; angle:float ):vec2;
var
  cosa :float;
  sina :float;
begin
  cosa  := system.cos(angle);
  sina  := system.sin(angle);
	Result.x  := cosa*v.x - sina*v.y;
	Result.y  := sina*v.x + cosa*v.y;
end;


function TShapeShifter.rotate_z( const v:vec2; angle:float ):vec2;
var
  cosa :float;
  sina :float;
begin
  cosa  := system.cos(angle);
  sina  := system.sin(angle);
	Result.x  := cosa*v.x - sina*v.y;
	Result.y  := sina*v.x + cosa*v.y;
end;


function TShapeShifter.rotate_z( const v:vec3; angle:float ):vec3;
var
  cosa :float;
  sina :float;

begin
        cosa  := system.cos(angle);
        sina  := system.sin(angle);
	Result.x  := cosa*v.x - sina*v.y;
	Result.y  := sina*v.x + cosa*v.y;
	Exit( v );
end;


function TShapeShifter.rotate_y( const v:vec3; angle:float ):vec3;
var
  cosa :float;
  sina :float;

begin
        cosa  := system.cos(angle);
        sina  := system.sin(angle);
	Result.x  := cosa*v.x - sina*v.z;
	Result.z  := sina*v.x + cosa*v.z;
	Exit( v );
end;


function TShapeShifter.rotate_x( const v:vec3; angle:float ):vec3;
var
  cosa :float;
  sina :float;
begin
        cosa  := system.cos(angle);
        sina  := system.sin(angle);
	Result.y  := cosa*v.y - sina*v.z;
	Result.z  := sina*v.y + cosa*v.z;
	Exit( v );
end;


function TShapeShifter.cc( const color:vec3; factor, factor2:float ):vec3; //a wierd color modifier
var
  w :float;

begin
	w  := color.x+color.y+color.z;
	Exit( mix(color,vec3(w)*factor,w*factor2) );
end;


function TShapeShifter.material0( const uv:vec2 ):vec2; //material used for the infinite plane
var
  uv2 :vec2;
  d :float;
  s :float;

begin
	//make a checkerboard pattern
	uv2  := &mod(uv,vec2_8);
	uv2  := uv2  - (&mod(uv,vec2_9));
	d  := uv2.x+uv2.y;
	d  := pow(d-1,2)*0.4;

	//sample the texture
	s  := texture2D(tex[6],uv*0.3).y+0.5-d;
	d  := d  + (s*0.2);

	//d - diffuse, s - specular
	Exit( Vec2.Create(d,s*s*0.5+0.1) );
end;


function TShapeShifter.dist( const p:vec3 ):float; //the distance function for raymarching
var
  time :float;
  bp :vec3;
  diamond :float;
  box :float;
  torus :float;
  sphere :float;
  change :float;
  change2 :float;
  set0 :float;
  set1 :float;

begin
	//warp time to get that crazy bending efect
	time  :=
    p.x*system.sin(iGlobalTime*2.312)*system.sin(iGlobalTime)*0.9+
		p.z*system.cos(iGlobalTime*3.120)*system.sin(iGlobalTime)*0.9+
		iGlobalTime +
    math.max(&mod(iGlobalTime * 0.1,1.0),
             &mod(-iGlobalTime* 0.1,1.0));

	//rotate the space, bp <- transform(p)
	bp  := rotate_z(p,time*0.6);
	bp  := rotate_y(bp,time*0.7);
	bp  := rotate_x(bp,time*0.5);

	//now we have the distance function for 4 shapes
	diamond  := abs(bp.x)+abs(bp.y)+abs(bp.z)-0.6;//length(p+vec3_10)-0.5;
	box  := math.max(abs(bp.x),math.max(abs(bp.y),abs(bp.z)))-0.35;//length(p+vec3_11)-0.5;
	torus  := pow((0.4-length(bp.xy)),2)+pow(bp.z,2)-0.02;
	sphere  := length(bp)-0.5;

	//these values are used to blend them together
	change  := system.sin(iGlobalTime)*0.99;
	change2  := system.sin(iGlobalTime*0.4)*0.99;

	//set0 <- mix(sphere,diamond), set1 <- mix(torus,box)
	set0  := mix(sphere,diamond,smoothstep(-1,1,change));
	set1  := mix(torus,box,smoothstep(-1,1,change));

	//return mix(sphere,diamond,torus,box)
	Exit( mix(set0,set1,smoothstep(-1,1,change2)) );
end;


function TShapeShifter.normal( const p:vec3; e:float ):vec3; //returns the normal, uses the distance function
var
  d:float;

begin
	d := dist(p);
	Exit( normalize(Vec3.Create(dist(p+Vec3.Create(e,0,0))-d,dist(p+Vec3.Create(0,e,0))-d,dist(p+Vec3.Create(0,0,e))-d)) );
end;

function TShapeShifter.plane( const p, d:vec3 ):vec3; //returns the intersection with a predefined plane
var
  n :vec3;
  p0 :vec3;
  f:float;
  dnd:float;
begin
	//http://en.wikipedia.org/wiki/Line-plane_intersection
	n  := vec3_12;
	p0  := -n*0.8;
  dnd := dot(n,d);
  if dnd<>0 then
  	f := dot(p0-p,n)/dnd
  else
    f := 0;
 	Exit( p+d*f );
end;


function TShapeShifter.sun( const d:vec3 ):float; //makes a bright dot on the sky
var
  s :float;

begin
	s  := dot(d,light);
	s := s + (1);
        s := s * (0.5);
	s := pow(s*1.001,100);
	Exit( s );
end;

function TShapeShifter.stars( const _d:vec3 ):vec3; //render stars using 3d noise
var
  s :float;
  d : vec3;
begin
  d.x := _d.x;
	d.y := abs(d.y);
	s  := noise(d*364)*noise(d*699);
	s := pow(s,13)*10;
	Exit( s );
end;


function TShapeShifter.backdrop( const p, d:vec3 ):vec3; //render background layer, also used for reflection
var
  s :float;
  a :vec3;
  n :vec3;
  diffuse :float;
  alpha :float;
  pp :vec3;
  lpp:float;
  mat :vec2;
  c :vec3;

begin
	s  := sun(d);
	a  := vec3_13*(1-abs(d.y))*1.5;
	n  := vec3_14;

	diffuse  := dot(n,light)*0.5+0.5;

	alpha  := dot(d,-n);
	if alpha<0 then
    alpha:=0;  //to blend the plane with the sky

	pp  := plane(p,d);
	lpp := length(pp);
	mat  := material0(pp.xz);
	//mat.x = diffuse coefficient, mat.y = specular coefficient

	//calculate the planes color
	c  := mat.x*vec3_15*diffuse + (mat.y*0.7)*(a*0.2+vec3(sun(reflect(d,n))));

	alpha:=pow(alpha,0.5); //make the scene less foggy

	Exit( mix(a+s,c,alpha) ); //mix the plane with the sky
end;


function TShapeShifter.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv :vec2;
  mouse :vec3;
  p :vec3;
  d :vec3;
  back :vec3;
  alpha:float;
  s :float;
    i:integer;
ss :float;
di :float;
  n :vec3;
  ao :float;
  diffuse :float;
	c :vec3; //color

begin
	uv  := gl_FragCoord.xy / resolution.xy - 0.5;
	uv.x  := uv.x  * (resolution.x/resolution.y);
	mouse  := vec3.create(iMouse.xy/resolution.xy - 0.5,iMouse.z-0.5);

	mouse.x := mouse.x + (iGlobalTime*0.00015);

	p.x  := system.sin(mouse.x*7)*2.1;
  p.y  := 0;
  p.z  := system.cos(mouse.x*7)*2.1;

	d  := rotate_y(Vec3.Create(uv,1),3.14159-7*mouse.x);
	d := normalize(d); //ray direction

	light.x  := system.sin(iGlobalTime);
	light.y  := system.sin(iGlobalTime*0.44)+1.2;
	light.z  := system.sin(iGlobalTime*0.24);
  light.NormalizeSelf;

	//first we calculate the background

	back  := backdrop(p,d);
	c := back;

	if d.y<0 then  //ground
	begin
		p  := plane(p,d);
		alpha := 0.3/length(p);
		s  := 1;
		for i := 0 to 19 do  //cast shadows for the shapeshifting object
		begin
			ss  := dist(p);
      if ss>1000 then
        ss := 1000;
			p := p + (light*ss);
			ss := ss * (2);
			ss  := math.min(ss,1);
			s := s * ss;
		end;

		c := mix(c,c*s,alpha)+stars(d)*0.2; //mix + add star reflection
	end
	else
	begin
		c := c + (stars(d));
	end;


	//now we do the raymarch, if the ray hits the object, the color
	//is overwritten, otherwise the background color stays . . .

	for i := 0 to 99 do  //raymarching
	begin
		di  := dist(p);
		p := p + (d*(di*(hash(p.xy+uv.xy)*0.3+0.7))*0.4);

		if di>5 then  //too far away from the object, escape from this long loop
		begin
			break;
		end;

		if di<0.01 then  //close enough to the object
		begin
			n  := normal(p,0.002);
			ao  := dist(p+n)*0.5+0.5;

			// a bit more wierd diffuse lighting, but looks great
			diffuse  := (dot(light,n)*0.5+0.5);
			diffuse:=pow(diffuse,2);

			c := vec3_16 * diffuse; //object color

			//now we add the beautiful raytraced reflection
			c := mix(c,backdrop(p,reflect(d,n)),(1+dot(d,n))*0.6+0.2);
			c  := c  * (ao);
			break; //escape the loop
		end;

	end;


	c := c - (vec3(length(uv)*0.1));
	Result := TColor32(cc(c*0.4+hash(uv.xy+c.xy)*0.007,0.8,0.9)); //post process
	//Result = vec4(c,1.0); //uncomment this to remove post processing
end;


initialization

ShapeShifter := TShapeShifter.Create;
Shaders.Add('ShapeShifter', ShapeShifter);

finalization

FreeandNil(ShapeShifter);

end.

