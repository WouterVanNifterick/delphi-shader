unit WvN.DelphiShader.FX.FractalPlasma;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TFractalPlasma = class(TShader)
  const
    vec3_1: vec3 = (x: 1.2; y: 0.999; z: 0.9);

  var
    m: Vec2;
    n: Vec3;

    constructor Create; override;
    procedure PrepareFrame;
    function main(var gl_FragCoord: Vec2): TColor32;
  end;

var
  FractalPlasma: TShader;

implementation

uses SysUtils, Math;

constructor TFractalPlasma.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
end;

procedure TFractalPlasma.PrepareFrame;
begin
  m.x := sinLarge(time)*0.5+0.5;
  m.y := cosLarge(time)*0.3+0.5;
  n := vec3.Create(1, 1, m.y * 0.4);
end;

function TFractalPlasma.main(var gl_FragCoord: Vec2): TColor32;
var
  p: vec3;
  i: int;
begin
  // Originally created by Robert Schütze (http://glslsandbox.com/e#29611.0)
  p     := vec3.Create((gl_FragCoord.xy) / (resolution.y), m.x);
  for i := 0 to 99 do
    p.xzy := vec3_1 * (abs((abs(p) / dot(p, p) - n)));

  Result := TColor32(p);
end;

initialization

FractalPlasma := TFractalPlasma.Create;
Shaders.Add('FractalPlasma', FractalPlasma);

finalization

FreeandNil(FractalPlasma);

end.
