unit WvN.DelphiShader.FX.Space;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TSpace = class(TShader)
  const
    vec3_1: vec3 = (x: 0; y: 0; z: 0);

  var
    initvar              : vec3;
    offset, speed2, speed: double;

    constructor Create; override;
    procedure PrepareFrame;
    function main(var gl_FragCoord: Vec2): TColor32;
  end;

var
  Space: TShader;

implementation

uses SysUtils, Math;

constructor TSpace.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
  offset    := 0;
end;

procedure TSpace.PrepareFrame;
begin
  offset  := time * time / 200;
  speed2  := (cosLarge(offset) + 1) * 2;
  speed   := speed2 + 0.1;
  offset  := offset + (sinLarge(offset) * 0.96);
  offset  := offset * (2);
  initvar := vec3.Create(sinLarge(offset * 0.002) * 0.3, 0.35 + cosLarge(offset * 0.005) * 0.3, offset * 0.2);
end;

function TSpace.main(var gl_FragCoord: Vec2): TColor32;
var
  uv       : Vec2;
  s, v     : float;
  col, init: vec3;
  r        : int;
  p        : vec3;
  i        : int;
  uv5      : vec3;
begin
  // from Mr Hoskins ST;
  uv := gl_FragCoord.xy / resolution.xy * 2 - 1;
  s  := 0;
  v  := 0;

  col   := vec3_1;
  init  := initvar;
  uv5   := vec3.Create(uv, 0.05);
  for r := 0 to 89 do
  begin
    p   := init + s * uv5;
    p.z := fract(p.z);
    // Thanks to Kali's little chaotic loop...
    for i := 0 to 8 do
      p   := abs(p * 2.04) / dot(p, p) - 0.9;

    v   := v + (pow(dot(p, p), 0.7) * 0.06);
    col := col + (vec3.Create(v * 0.2 + 0.4, 12 - s * 2, 0.1 + v) * v * 0.00003);
    s   := s + 0.025;
  end;
  Result := TColor32(clamp(col, 0, 1));
end;

initialization

Space := TSpace.Create;
Shaders.Add('Space', Space);

finalization

FreeandNil(Space);

end.
