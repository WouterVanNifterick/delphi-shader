unit WvN.DelphiShader.FX.ShadowBall;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TShadowBall = class(TShader)
const
  vec3_1:vec3=(x:0.745;y:0.294;z:0.156);

  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  ShadowBall: TShader;

implementation

uses SysUtils, Math;

constructor TShadowBall.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TShadowBall.PrepareFrame;
begin
// http://glsl.heroku.com/e#15382.3
end;

function TShadowBall.Main(var gl_FragCoord: Vec2): TColor32;
var
  res :vec2;
  cen :vec2;
  p :vec2;
  m :vec2;
  radius :float;
  lheight :float;
  normal :vec3;
  lightDir :vec3;
  shad :float;
  spec :float;
  col :vec3;
  tmp: Float;

begin
	res  := Vec2.Create(resolution.x/resolution.y,1);
	cen  := res / 2;
	p  := ( gl_FragCoord.xy / resolution.y ) - cen;
	m  := mouse.xy*res - cen;
	radius  := 0.4;
  tmp := radius*radius -(p.x*p.x) - (p.y*p.y);
  if tmp<=0 then
    exit(0);

	lheight  := system.sqrt(tmp);
	normal  := normalize(Vec3.Create(p.x,p.y,lheight));
	lightDir  := normalize(vec3.create(m,1));
	shad  := dot(normal,vec3.create(mouse.xy*res-cen,1));
	spec  := pow(math.max(0,dot(lightDir,normalizeS(reflect(-lightDir,normal)))),10)*0.7;
	col  := vec3_1*math.max(smoothstep(radius,radius-0.01,length(p)),0.9)*shad+spec;

	Result := TColor32( col );
 end;


initialization

ShadowBall := TShadowBall.Create;
Shaders.Add('ShadowBall', ShadowBall);

finalization

FreeandNil(ShadowBall);

end.

