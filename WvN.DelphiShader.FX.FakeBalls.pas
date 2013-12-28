unit WvN.DelphiShader.FX.FakeBalls;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TFakeBalls = class(TShader)
const
  vec2_1:vec2=(x:0;y:-1);
  vec2_2:vec2=(x:0.7;y:-0.7);
  vec2_3:vec2=(x:1;y:-1);

  function cmul( const c1, c2:vec2 ):vec2;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  FakeBalls: TShader;

implementation

uses SysUtils, Math;

constructor TFakeBalls.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TFakeBalls.PrepareFrame;
begin
// Looks oddly like a 3d shape but it isn't really
end;

function TFakeBalls.cmul( const c1, c2:vec2 ):vec2;
begin
	Result.x := c1.x * c2.x - c1.y * c2.y;
  Result.y := c1.x * c2.y + c1.y * c2.x;
end;


function TFakeBalls.Main(var gl_FragCoord: Vec2): TColor32;
var
  p, z :vec2;
  d :float;
  i :integer;
  surfacePosition: vec2;
begin
  surfacePosition := (gl_FragCoord / Resolution)-0.5;

	p  := surfacePosition*4 + vec2_1;
	z  := vec2_2;
	d  := 1;
	for i  :=  0 to 9 do
  begin
		z  := z.yx * vec2_3 + 1;
		p  := p  + z*z;
		z  := cmul(z, p);
    p := clamp(p,-100000,100000);
    z := clamp(z,-100000,100000);

		d  := math.min(d, distance(p, z));
	end;

	Result := TColor32(vec3(1 - d));
end;


initialization

FakeBalls := TFakeBalls.Create;
Shaders.Add('FakeBalls', FakeBalls);

finalization

FreeandNil(FakeBalls);

end.

