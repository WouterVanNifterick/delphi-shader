unit WvN.DelphiShader.FX.Riploid;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TRiploid = class(TShader)
    t: float;
    r: float;
    mid: vec2;
    ripMid: vec2;
    mod1: float;
    mt: mat2;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: vec2): TColor32;
  end;

var
  Riploid: TShader;

implementation

uses SysUtils, Math;

constructor TRiploid.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TRiploid.PrepareFrame;
begin
  t      := iGlobalTime;
  mid    := vec2.Create(0.5, 0.5);
  ripMid := vec2(iMouse.xy / Resolution.xy);
  mod1   := system.sin(t * 2.0);
  r      := t * 0.5;
  mt     := mat2.Create(system.cos(r), -system.sin(r), system.sin(r), system.cos(r));

end;

function dist(const p1: vec2; const p2: vec2): float; inline;
var
  dx: float;
  dy: float;
begin
  dx     := p2.x - p1.x;
  dy     := p2.y - p1.y;
  Result := system.sqrt(dx * dx + dy * dy);
end;

function getSin(const seed, a, f, t: float): float; inline;
begin
  Result := a * system.sin(seed * f + t);
end;

function getCos(const seed, a, f, t: float): float; inline;
begin
  Result := a * system.cos(seed * f + t);
end;

function TRiploid.RenderPixel(var gl_FragCoord: vec2): TColor32;
var
  uv       : vec2;
  mod2     : float;
  b1, b2, n: float;
  avg      : float;
  c        : vec4;
begin
  uv   := gl_FragCoord.xy / Resolution.xy;
  mod2 := system.cos(t * (0.5 + (system.sin(uv.x * 0.015))));
  n    := getCos(dist(uv, ripMid) * 10, 0.25, 2, t);
  b1   := getSin((uv.x + mod2) + system.cos(uv.y) * 15, 1, 1, t) + n;
  b2   := getSin(uv.y * mod2 * 10, 0.75 + mod1, 0.25, t) + n;
  avg  := (b1 + b2) * 0.5;

  uv := uv * mt;

  c     := texture2D(tex[0], vec2.Create(uv.x + avg, uv.y + avg));
  c.rgb := c.rgb + (clamp(avg, 0, 0.6));

  Result := TColor32(c);
end;

initialization

Riploid := TRiploid.Create;
Shaders.Add('Riploid', Riploid);

finalization

FreeandNil(Riploid);

end.
