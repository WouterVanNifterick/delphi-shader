unit WvN.DelphiShader.FX.WaterTurbulence2;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TWaterTurbulence2 = class(TShader)
const
  vec3_1:vec3=(x:1;y:1.97;z:1);
  MAX_ITER = 16;

  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  WaterTurbulence2: TShader;

implementation

uses SysUtils, Math;

constructor TWaterTurbulence2.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TWaterTurbulence2.PrepareFrame;
begin
//http://glslsandbox.com/e#10014.0
// water turbulence effect by joltz0r 2013-07-04, improved 2013-07-07
end;

function TWaterTurbulence2.Main(var gl_FragCoord: Vec2): TColor32;
var
  p :vec2;
  i :vec2;
  c :float;
  n :integer;
  t :float;
  surfacePosition:Vec2;
  l: Double;
begin
	surfacePosition := (gl_FragCoord / Resolution)-0.5;
  p  := surfacePosition*5;
	i  := p;
	c  := 0;

	for n  := 1 to  MAX_ITER do
  begin
		t  := time * (1 - (1 / n));
		i  := p + Vec2.Create(System.cos(t - i.x) + System.sin(t + i.y),System.sin(t - i.y) + System.cos(t + i.x));
    l  := length(Vec2.Create(p.x / (System.sin(i.x+t)),p.y / (System.cos(i.y+t))));
    if not isZero(l) then
  		c  := c  + (1/l);
	end;

	c  := c  / (MAX_ITER);

	Result  := TColor32(vec4.Create(Vec3.Create(pow(c,1.1))*vec3_1,1));
end;

initialization

WaterTurbulence2 := TWaterTurbulence2.Create;
Shaders.Add('WaterTurbulence2', WaterTurbulence2);

finalization

FreeandNil(WaterTurbulence2);

end.

