unit WvN.DelphiShader.FX.DubstepMyAss;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TDubstepMyAss = class(TShader)
const
  vec2_1:vec2=    (x:12.9898;y:78.2333);
  vec2_2:vec2=    (x:0.005;y:-0.005);
  vec2_3_xyy:vec3=(x:0.005;y:-0.005;z:-0.005);
  vec2_3_yxx:vec3=(x:-0.005;y:0.005;z:0.005);
  vec2_3_yyx:vec3=(x:-0.005;y:-0.005;z:0.005);

  function rand( const p:vec2;const t, v:float ):float;
  function rotate( const k:vec2; t:float ):vec2;
  function scene( const p:vec3 ):float;
  function Main(var gl_FragCoord: Vec2): TColor32;

var
  speed :float;
  ground_x :float;
  ground_y :float;
  ground_z :float;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  DubstepMyAss: TShader;

implementation

uses SysUtils, Math;

constructor TDubstepMyAss.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TDubstepMyAss.PrepareFrame;
begin
 speed  := iGlobalTime;
 ground_x  := 0;//+0.125*sin(PI*speed*0.25);
 ground_y  := 0;//+0.125*cos(PI*speed*0.25);
 ground_z  := 4*system.sin(PI*speed*0.0625);//+speed*0.5;


end;

function TDubstepMyAss.rand( const p:vec2;const t, v:float ):float;
begin
	Exit( fract(system.sin(dot(p+&mod(t,1),vec2_1))*v) );
end;


function TDubstepMyAss.rotate( const k:vec2; t:float ):vec2;
begin
	Exit( Vec2.Create(system.cos(t)*k.x-system.sin(t)*k.y,system.sin(t)*k.x+system.cos(t)*k.y) );
end;


function TDubstepMyAss.scene( const p:vec3 ):float;
var
  bar_p:float;
  bar_w:float;
  bar_x:float;
  bar_y:float;
  bar_z:float;
  tube_p:float;
  tube_w:float;
//  tube_x:float;
  tube_y:float;
  tube_z:float;

begin
	bar_p := 1;
	bar_w := bar_p*(0.125+0.03125*1+2*system.sin(PI*p.z*2-PI*0.5));
	bar_x := length(max(abs(&mod(p.yz,bar_p)-bar_p*0.5)-bar_w,vec2(0)));
	bar_y := length(max(abs(&mod(p.xz,bar_p)-bar_p*0.5)-bar_w,vec2(0)));
	bar_z := length(max(abs(&mod(p.xy,bar_p)-bar_p*0.5)-bar_w,vec2(0)));
	tube_p := 0.125;
	tube_w := tube_p*0.375;
//	tube_x := length(&mod(p.yz,tube_p)-tube_p*0.5)-tube_w;
	tube_y := length(&mod(p.xz,tube_p)-tube_p*0.5)-tube_w;
	tube_z := length(&mod(p.xy,tube_p)-tube_p*0.5)-tube_w;
	Exit( -min(min(max(max(-bar_x,-bar_y),-bar_z),tube_y),tube_z) );
end;


function TDubstepMyAss.Main(var gl_FragCoord: Vec2): TColor32;
var
  position:vec2;
  p:vec2;
  dir:vec3;
  ray:vec3;
  t:float;
  ray_n :int;
    i:integer;
k:float;
  hit:vec3;
  n:vec3;
  c:float;
  color:vec3;
begin
	position := (gl_FragCoord.xy/resolution.xy);
	p := -1+2*position;
	dir := normalize(Vec3.Create(p*Vec2.Create(1/resolution.y*resolution.x,1),1));
	dir.yz:=rotate(dir.yz,PI*0.5*system.sin(speed*0.25));	// rotation x
	//dir.zx=rotate(dir.zx,speed*0.5);				// rotation y
	dir.xy:=rotate(dir.xy,PI*1*system.cos(speed*0.25));	// rotation z
	ray := Vec3.Create(ground_x,ground_y,ground_z);
	t := 0;
 ray_n  := 64;
	for i := 0 to ray_n-1 do
	begin
		k := scene(ray+dir*t);
		t := t + (k*0.7);
	end;

	hit := ray+dir*t;
	n := normalizeS(Vec3.Create(scene(hit+vec2_3_xyy),scene(hit+vec2_3_yxx),scene(hit+vec2_3_yyx)));
	c := (n.x*2+n.y+n.z)*0.25-t*0.025;
	color := Vec3.Create(c*t*0.625-p.x*0.125,c*t*0.25+t*0.03125,c*0.375+t*0.0625+p.y*0.125);
	color := smoothstep(0.4,0.7,c)+color*color;
	{ post process }
	color := color * (0.6+0.4*rand(p,iGlobalTime,43758.5453));
	color := Vec3.Create(color.x*0.9-0.1*system.cos(p.x*resolution.x),color.y*0.95+0.05*system.sin(p.y*resolution.x/2),color.z*0.9+0.1*system.cos(PI/2+p.x*resolution.x));
	{ return color }
	Result := TColor32(color);
end;


initialization

DubstepMyAss := TDubstepMyAss.Create;
Shaders.Add('DubstepMyAss', DubstepMyAss);

finalization

FreeandNil(DubstepMyAss);

end.

