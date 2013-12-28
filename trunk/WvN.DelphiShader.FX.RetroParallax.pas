unit WvN.DelphiShader.FX.RetroParallax;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TRetroParallax = class(TShader)
  const
    vec3_1: vec3 = (x: 0.4; y: 0.6; z: 0.7);
  var
    offset   : Vec2;
    pixelSize:float;
    pixelSizeQ:float;

    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  RetroParallax: TShader;

implementation

uses SysUtils, Math;

constructor TRetroParallax.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;

  pixelSize := 2;
  pixelSizeQ := pixelSize / 4;
end;

procedure TRetroParallax.PrepareFrame;
begin
  offset := Vec2.Create(iGlobalTime * 3000, pow(max(-system.sin(iGlobalTime * 0.2), 0), 2) * 16000) / pixelSize;
end;

function TRetroParallax.Main(var gl_FragCoord: Vec2): TColor32;
var
  pixel    : Vec2;
  col      : vec3;
  i        : integer;
  depth    : float;
  uv       : Vec2;
begin
  pixel := gl_FragCoord.xy - resolution.xy * 0.5;

  for i := 0 to 7 do
  begin
    // parallax position, whole pixels for retro feel
    depth := 20 + i;
    uv    := pixel + floor(offset / depth);
    uv := uv / resolution.y;
    uv := uv * (depth / 20);
    uv := uv * pixelSizeQ;

    col := texture2D(tex[6], uv + 0.5).rgb;

    if 1 - col.y < (i + 1) / 8 then
    begin
      col := mix(vec3_1, col, exp2(-i * 0.1) );
      break;
    end;
  end;
  Result := TColor32(col);
end;

initialization

RetroParallax := TRetroParallax.Create;
Shaders.Add('RetroParallax', RetroParallax);

finalization

FreeandNil(RetroParallax);

end.
