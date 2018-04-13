unit WvN.DelphiShader.FX.WeirdBalls;

interface

uses GR32, Types, WvN.DelphiShader.Shader, classes;

type

{$define occlusion_enabled}
{$define noise_use_smoothstep}


TWeirdBalls = class(TShader)
  public
  const
    occlusion_pass1_quality =9;
    occlusion_pass2_quality =8;
    object_count = 8;
    object_speed_modifier = 1.0;
    render_steps = 40;

    vec2_1:vec2=(x:2.31;y:53.21);
    vec3_2:vec3=(x:1;y:1;z:1);
    vec3_3:vec3=(x:1;y:1;z:1);
    vec3_4:vec3=(x:0.1;y:0.4;z:0.8);
    vec3_5:vec3=(x:0.9;y:0.6;z:0.2);
    vec3_6:vec3=(x:0.2;y:0.4;z:0.6);
    vec2_7:vec2=(x:1;y:1);
    vec3_8:vec3=(x:0;y:0;z:0);
    vec3_9:vec3=(x:0.6;y:0.6;z:0.6);
    vec3_10:vec3=(x:0;y:0;z:-2);

  var
    res,t:double;
    lmouse :vec3;

  function hash(  x:float ):float;overload;
  function hash( const x:vec2 ):float;overload;
  function hashmix(  x0, x1, interp:float ):float;overload;
  function hashmix( const p0, p1: vec2; var interp:vec2 ):float;overload;
  function hashmix( const p0, p1, interp:vec3 ):float;overload;

  function cc( const color:vec3; factor, factor2:float ):vec3;
  function rotate_z( const v:vec3; angle:float ):vec3;
  function rotate_y( const v:vec3; angle:float ):vec3;
  function rotate_x( const v:vec3; angle:float ):vec3;
  function dist( p:vec3 ):float;
  function amb_occ( const p:vec3 ):float;
  function occ( const start, light_pos:vec3; size:float ):float;overload;
  function occ( const start, light_pos:vec3; size, dist_to_scan:float ):float;overload;
  function normal( const p:vec3):vec3;
  function background( const p, d:vec3 ):vec3;
  function noise( const p:vec3 ):float;overload;
  function noise(  p:float ):float;overload;
  function noise( const p:vec2 ):float;overload;
  function object_material( const p, d:vec3 ):vec3;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  WeirdBalls: TShader;

implementation

uses SysUtils, Math;

constructor TWeirdBalls.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;


function TWeirdBalls.hash(  x:float ):float;
begin
	Result := fract(sinLarge(x*0.0127863)*17143.321); //decent hash for noise generation
end;


function TWeirdBalls.hash( const x:vec2 ):float;
begin
	Result := fract(cosLarge(dot(x.xy,vec2_1)*124.123)*412);
end;


function TWeirdBalls.hashmix(  x0, x1, interp:float ):float;
begin
	x0  := hash(x0);
	x1  := hash(x1);
	{$ifdef noise_use_smoothstep}
	interp  := smoothstep(0,1,interp);
	{$endif }
	Exit( mix(x0,x1,interp) );
end;


function TWeirdBalls.hashmix( const p0, p1: vec2; var interp:vec2 ):float;
var
  v0 :float;
  v1 :float;
begin
	v0  := hashmix(p0.x+p0.y*128,p1.x+p0.y*128,interp.x);
	v1  := hashmix(p0.x+p1.y*128,p1.x+p1.y*128,interp.x);
	{$ifdef noise_use_smoothstep}
	interp  := smoothstep(Vec2Black,Vec2White,interp);
	{$endif }
	Result := mix(v0,v1,interp.y);
end;


function TWeirdBalls.hashmix( const p0, p1, interp:vec3 ):float;
var
  erp :vec3;
  v0,v1 :float;
  p0z,p1z,ixy:vec2;
begin
  ixy := interp.XY;
  p0z := Vec2.Create(p0.z*143,0); v0 := hashmix(p0.xy+p0z, p1.xy+p0z, ixy );
  p1z := Vec2.Create(p1.z*143,0); v1 := hashmix(p0.xy+p1z, p1.xy+p1z, ixy);

	{$ifdef noise_use_smoothstep}
	erp  := smoothstep(Vec3Black,vec3_2,interp);
	{$endif }
	Exit( mix(v0,v1, interp.z) );
end;


function TWeirdBalls.noise( const p:vec3 ):float; // 3D noise
var
  pm :vec3;
  pd :vec3;

begin
	pm  := &mod(p,1);
	pd  := p-pm;
	Result := hashmix(pd,(pd+vec3_3), pm)
end;


function TWeirdBalls.cc( const color:vec3; factor, factor2:float ):vec3; // color modifier
var
  w :float;
begin
	w  := color.x+color.y+color.z;
	Result := mix(color,vec3(w)*factor,w*factor2);
end;



function TWeirdBalls.rotate_z( const v:vec3; angle:float ):vec3;
var
  ca,sa:float;
begin
	ca := system.cos(angle);
  sa := system.sin(angle);
	Result := v * mat3.Create(+ca, -sa, +0,
                            +sa, +ca, +0,
                            + 0, + 0, +1);
end;


function TWeirdBalls.rotate_y( const v:vec3; angle:float ):vec3;
var
  ca,sa:float;
begin
	ca := system.cos(angle);
  sa := system.sin(angle);
	Result := v * mat3.Create(
                   +ca, +0, -sa,
 		               + 0, +1, + 0,
		               +sa, +0, +ca);
end;


function TWeirdBalls.rotate_x( const v:vec3; angle:float ):vec3;
var
  ca,sa:float;
begin
	ca := system.cos(angle);
  sa := system.sin(angle);
	Result := v * mat3.Create(
		+1, + 0, + 0,
		+0, +ca, -sa,
		+0, +sa, +ca) ;
end;


function TWeirdBalls.dist( p:vec3 ):float;//distance function
var
  t :float;
  i:integer;
  tof:float;
  offs :vec3;
  v :vec3;
begin
	t  := iGlobalTime+4;
	Result := 1000;//p.y+2.0;
	p.y := p.y + (system.sin(t*0.5)*0.2);
	Result := min(length(p)-1,Result);

	for i := 0 to object_count-1 do
	begin
		tof := 1442.530/object_count*i;
		offs  := Vec3.Create(
			sinLarge(t*0.7+tof*6),
			sinLarge(t*0.8+tof*4),
			sinLarge(t*0.9+tof*3));
		v  := p+normalize(offs)*1.3;
		Result  := min(Result,length(v)-0.3);
	end;
end;


function TWeirdBalls.amb_occ( const p:vec3 ):float;
var
  acc:float;
const
  ambocce  = 0.2;
  v1: vec3 = (x:-ambocce; y:-ambocce; z:-ambocce);
  v2: vec3 = (x:-ambocce; y:-ambocce; z:+ambocce);
  v3: vec3 = (x:-ambocce; y:+ambocce; z:-ambocce);
  v4: vec3 = (x:-ambocce; y:+ambocce; z:+ambocce);
  v5: vec3 = (x:+ambocce; y:-ambocce; z:-ambocce);
  v6: vec3 = (x:+ambocce; y:-ambocce; z:+ambocce);
  v7: vec3 = (x:+ambocce; y:+ambocce; z:-ambocce);
  v8: vec3 = (x:+ambocce; y:+ambocce; z:+ambocce);
begin
  acc := 0;
  acc := acc +
     (dist(p + v1))
   + (dist(p + v2))
   + (dist(p + v3))
   + (dist(p + v4))
   + (dist(p + v5))
   + (dist(p + v6))
   + (dist(p + v7))
   + (dist(p + v8));

  Result := 0.5 + acc / (16 * ambocce);
end;


function TWeirdBalls.occ(const start, light_pos: vec3; size: float): float;
var
  dir          : vec3;
  total_dist   : float;
  travel       : float;
  p            : vec3;
  search_travel: float;
  search_o     : float;
  e            : float;
  i            : integer;
  cd           : float;
  co           : float;
  tr           : float;
  oc           : float;
begin
  dir        := light_pos - start;
  total_dist := length(dir);
  dir        := dir / total_dist;

  p := start;

  search_travel := 0;
  search_o      := 1;

  e := 0.5 * total_dist / occlusion_pass1_quality;

  // pass 1 fixed step search

  for i := 0 to occlusion_pass1_quality - 1 do
  begin
    travel := (i + 0.5) * total_dist / occlusion_pass1_quality;
    cd     := dist(start + travel * dir);
    co     := cd / travel * total_dist * size;
    if co < search_o then
    begin
      search_o      := co;
      search_travel := travel;
      if co < 0 then
        break;
    end;
  end;

  // pass 2 tries to find a better match in close proximity to the result from the
  // previous pass

  for i := 0 to occlusion_pass2_quality - 1 do
  begin
    tr := search_travel + e;
    oc := dist(start + tr * dir) / tr * total_dist * size;
    if (tr < 0) or (tr > total_dist) then
      break;

    if oc < search_o then
    begin
      search_o      := oc;
      search_travel := tr;
    end;
    e := e * -0.75;
  end;

  Result := Math.max(search_o, 0);
end;


function TWeirdBalls.occ( const start, light_pos:vec3; size, dist_to_scan:float ):float;
var
  dir :vec3;
  total_dist :float;
  travel :float;
  p:vec3;
  search_travel:float;
  search_o:float;
  e :float;
  i:integer;
  cd :float;
  co :float;
  tr :float;
  oc :float;

begin
	dir  := light_pos-start;
	total_dist  := length(dir);
	dir  := dir/total_dist;

	p := start;

	search_travel := 0;
	search_o := 1;

	e  := 0.5*dist_to_scan/occlusion_pass1_quality;

	//pass 1 fixed step search

	for i := 0 to occlusion_pass1_quality-1 do
	begin
		travel  := (i+0.5)*dist_to_scan/occlusion_pass1_quality;
		cd  := dist(start+travel*dir);
		co  := cd/travel*total_dist*size;
		if co<search_o then
		begin
			search_o := co;
			search_travel := travel;
			if co<0 then
				break;
		end;
	end;

	//pass 2 tries to find a better match in close proximity to the result from the
	//previous pass
	for i := 0 to occlusion_pass2_quality-1 do
	begin
		tr  := search_travel+e;
		oc  := dist(start+tr*dir)/tr*total_dist*size;
		if (tr<0) or (tr>total_dist) then
		begin
			break;
		end;

		if oc<search_o then
		begin
			search_o  := oc;
			search_travel  := tr;
		end;

		e := e*-0.75;
	end;

	result := math.max(search_o,0)
end;


function TWeirdBalls.normal( const p:vec3 ):vec3; //returns the normal, uses the distance function
var
  d:float;
const
  v1:vec3=(x:0.001;y:0.000;z:0.000);
  v2:vec3=(x:0.000;y:0.001;z:0.000);
  v3:vec3=(x:0.000;y:0.000;z:0.001);
begin
	d := dist(p);
	Result.x := dist(p+v1)-d;
  Result.y := dist(p+v2)-d;
  Result.z := dist(p+v3)-d;
  Result.NormalizeSelf
end;


function TWeirdBalls.background( const p, d:vec3 ):vec3;//render background
var
  color :vec3;
begin
	color  := mix(vec3_5,vec3_4,d.y*0.5+0.5);
	Result := color*(noise(d)+0.3*pow(noise(d*4),4));
//	Result := textureCube(TShader.cubes[0],d).xyz*vec3_6;
end;


function TWeirdBalls.noise( p:float ):float;
var
  pm, pd :float;
begin
	pm  := &mod(p,1);
	pd  := p-pm;
	Exit( hashmix(pd,pd+1,pm) );
end;


function TWeirdBalls.noise( const p:vec2 ):float;
var
  pm, pd :vec2;

begin
	pm  := &mod(p,1);
	pd  := p-pm;
	Result := hashmix(pd,(pd+vec2_7), pm);
end;

//computes the material for the object
function TWeirdBalls.object_material( const p, d:vec3 ):vec3;
var
  i:integer;
  n, oldn:vec3;
  nns, nna :float;
  r,color :vec3;
  ao, &or,od :float;
  reflectance :float;
  offs, lp, ld :vec3;
  diffuse, spec :float;
  icolor :vec3;
begin
	n  := normal(p);
	oldn := n;
  nns  := 64;
  nna  := 0.1;
	n.x := n.x + (noise(oldn.yz*nns)-0.5)*nna;
	n.y := n.y + (noise(oldn.zx*nns)-0.5)*nna;
	n.z := n.z + (noise(oldn.xy*nns)-0.5)*nna;
	n := normalize(n);
	r  := reflect(d,n);
	ao  := amb_occ(p);
	color  := vec3_8;
	reflectance  := 1+dot(d,n);
	//return vec3(reflectance);

	&or  := occ(p,p+r*10,0.5,2);

	for i := 1 to 3 do
	begin
		offs.x := -system.sin(5*i*123.4);
		offs.y := -system.sin(4*i*723.4);
		offs.z := -system.sin(3*i*413.4);

		lp     := offs*100;
		ld     := normalize(lp-p);

		diffuse  := dot(ld,n);
		od := 0;
		if diffuse>0 then
		begin
			od  := occ(p,lp,0.05,2);
		end;

		spec  := pow(dot(r,ld)*0.5+0.5,100);

		icolor := vec3_9*diffuse*od*0.6 + vec3(spec)*od*reflectance;
		color  := color  + icolor;
	end;

	color  := color  + background(p,r)*(0.1+&or*reflectance);

	Exit( color*ao*1.2 );
end;


procedure TWeirdBalls.PrepareFrame;
begin
{by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

 Some wierd balls.... umh... enjoy...

 06/08/13:
	published

 09/08/13:
 	implemented an occlusion function where you can specify a range where you want to
	scan for minimum distance. This allows me to only scan in the proximity of the
	balls and I don't have to go all the way till the lightsource.
	The result is that the shadows look better with only 10 iterations so you also get
	a performance boost.

muuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuusk not }
  res := resolution.x/resolution.y;
	t  := iGlobalTime*0.5*object_speed_modifier + 30;
	lmouse  := vec3.create(
                iMouse.xy/resolution.xy - 0.5,
                iMouse.z-0.5)
                +
                Vec3.Create(
                  system.sin(t)*0.1,
                  system.sin(t)*0.1,
                  0);
end;


function TWeirdBalls.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv :vec2;
  p, d :vec3;
  sp :vec3;
  color:vec3;
  dd:float;
  i:integer;
begin
	uv  := gl_FragCoord.xy / resolution.xy - 0.5;
	uv.x  := uv.x  * res;

	//setup the camera
	p  := vec3_10;
	p  := rotate_x(p,lmouse.y*9);
	p  := rotate_y(p,lmouse.x*9);
	// p.y*0.2;
	d  := vec3.create(uv,1);
	d.z  := d.z  - (length(d)*0.6);
	d  := normalize(d);
	d  := rotate_x(d,lmouse.y*9);
	d  := rotate_y(d,lmouse.x*9);

	sp  := p;

	//raymarcing
	for i := 0 to render_steps-1 do
	begin
		dd  := dist(p);
		p := p + (d*dd);
		if (dd<0.001) or (dd>2) then
      break;
	end;


	if dd<0.03 then
		color  := object_material(p,d)
	else
		color  := background(p,d);

	color  := mix(color*color,color,1.4)*0.8;
	color  := color  - length(uv)*0.1;
	color  := cc(color,0.5,0.5);
	color  := color  + hash(uv.xy+color.xy)*0.02;
	Result := TColor32(color);
end;

initialization

WeirdBalls := TWeirdBalls.Create;
Shaders.Add('WeirdBalls', WeirdBalls);

finalization

FreeandNil(WeirdBalls);

end.
