unit WvN.DelphiShader.FX.Gears;

interface

uses GR32, Types, WvN.DelphiShader.Shader;


type
Gear=record
	pos:vec2 ;
	tn,ts,r,ang:float;
  constructor Create(aPos:vec2;aTn,aTs,aR,aAng:float);
end;

const
  vec2_1:vec2=(x:-0.4;y:0.0);
  vec2_2:vec2=(x:-0.4;y:0.34);
  vec2_3:vec2=(x:-0.4;y:-0.34);
  vec2_4:vec2=(x:-0.06;y:0.0);
  vec2_5:vec2=(x:0.12;y:0.0);
  vec2_6:vec2=(x:0.595;y:0.0);

  vec3_1:vec3=(x:0.8;y:0.0;z:0.0);
  vec3_2:vec3=(x:1.0;y:1.0;z:0.0);
  vec3_3:vec3=(x:1.0;y:0.0;z:1.0);
  vec3_4:vec3=(x:0.0;y:0.0;z:1.0);
  vec3_5:vec3=(x:1.0;y:1.0;z:1.0);
  vec3_6:vec3=(x:0.0;y:1.0;z:1.0);


type
TGears = class(TShader)
  drive:Gear;
  f,g:Array[1..5] of Gear;
procedure gearAngle( const p:Gear;var c:Gear );
function cnorm( const v:vec2 ):vec2;
function inGear(const g:Gear; p:vec2 ):float;
function Main(var gl_FragCoord: Vec2): TColor32;

var
  res :vec2;
  pi :float;
  pos:vec2;
  tn,ts,r,ang:float;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
Gears: TShader;

implementation

uses SysUtils, Math;

{ Gear }

constructor Gear.Create(aPos: vec2; aTn, aTs, aR, aAng: float);
begin
  pos := apos;
  tn := atn;
  ts := ats;
  r := aR;
  ang := aAng;
end;

{ Gears }

constructor TGears.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  pi := arctan(1)*4;
end;

procedure TGears.PrepareFrame;
begin
	drive  := Gear.Create(Vec2_1,16,0.03,0.2,time);
	f[1] := Gear.Create(Vec2_2, 8,0.025,0.10,0);	gearAngle(drive,f[1]);
	f[2] := Gear.Create(Vec2_3, 8,0.025,0.10,0);	gearAngle(drive,f[2]);
	f[3] := Gear.Create(Vec2_4, 8,0.025,0.10,0);	gearAngle(drive,f[3]);
	f[4] := Gear.Create(Vec2_5, 4,0.025,0.04,0);	gearAngle(f[3],f[4]);
	f[5] := Gear.Create(Vec2_6,32,0.025,0.40,0);	gearAngle(f[4],f[5]);

	drive  := Gear.Create(Vec2_1,16,0.03,0.2,time);
  Move(f,g,SizeOf(f));

	gearAngle(drive,g[1]);
	gearAngle(drive,g[2]);
	gearAngle(drive,g[3]);
	gearAngle(g[3],g[4]);
	gearAngle(g[4],g[5]);
	res  := Vec2.Create(resolution.x/resolution.y,1)/2;

end;



procedure TGears.gearAngle( const p:Gear;var c:Gear );
var
  ratio :float;
  off :float;
begin
	ratio  := p.tn/c.tn;
	off  := pi/c.tn;
	c.ang  := -p.ang*ratio+off;
end;


function TGears.cnorm( const v:vec2 ):vec2;
begin
	Exit( v/max(System.abs(v.x),System.abs(v.y)) );
end;


function TGears.inGear(const g:Gear; p:vec2 ):float;
var
  an :float;
  ra :float;
  cs :vec2;

begin
	p := p - (g.pos);
	an  := atan(p.x,p.y)+g.ang;
	ra  := length(p);

	cs  := Vec2.Create(system.cos(an*g.tn),system.sin(an*g.tn));
	cs  := cnorm(cs);

	Exit( smoothstep(0.018, 0.02, distance(p, Vec2.Create(0, 0)))*
        smoothstep(g.r+0.005,g.r,ra-(cs.x*0.5+0.5)*g.ts) );
end;


function TGears.main;
var
  p :vec2;
  a :float;
  r :float;
  c :vec3;
begin
	p  := ( gl_FragCoord.xy / resolution.y )-res;
	a  := atan(p.x,p.y)+time;
	r  := length(p);
	c  := vecBlack;
	c  := inGear(drive,p)*vec3_1;
	c  := c  + (inGear(g[1],p)*vec3_2);
	c  := c  + (inGear(g[2],p)*vec3_3);
	c  := c  + (inGear(g[3],p)*vec3_4);
	c  := c  + (inGear(g[4],p)*vec3_5);
	c  := c  + (inGear(g[5],p)*vec3_6);

	Result := TColor32(c);

end;




initialization

Gears := TGears.Create;
Shaders.Add('Gears', Gears);

finalization

FreeandNil(Gears);

end.

