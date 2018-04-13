unit WvN.DelphiShader.FX.MouseTrail;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMouseTrail = class(TShader)
  var
    m      : vec2;
    size   : float;
    r, g, b: float;

    function maru(const pos, me: vec2): vec3;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  MouseTrail: TShader;

implementation

uses SysUtils, Math;

constructor TMouseTrail.Create;
begin
  inherited;
  UseBackBuffer := True;
  SetBufferCount(1);

  PixelProc := Main;
  FrameProc := PrepareFrame;
end;

procedure TMouseTrail.PrepareFrame;
begin
  size := 10;
  r    := 1 - system.sin(time * 1) / 4;
  g    := 0.2 + system.cos(time * 1) / 4;
  b    := 1 - system.cos(time * 3) / 2;
  m    := vec2.Create(mouse.x * resolution.x, mouse.y * resolution.y)
end;

function TMouseTrail.maru(const pos, me: vec2): vec3;
var
  dist     : float;
  intensity: float;
  color    : vec3;
begin
  dist := length(pos - me);
  if dist = 0 then
    intensity := 1
  else
    intensity := pow(size / dist, 3);

  color.r := r * intensity;
  color.g := g * intensity;
  color.b := b * intensity;
  Result := color;
end;

function TMouseTrail.Main(var gl_FragCoord: vec2): TColor32;
var
  texPos: vec2;
  zenkai: vec4;
begin
  texPos := vec2(gl_FragCoord.xy / resolution);
  zenkai := texture2D(Buffers[0].Bitmap, texPos) * 0.95;
  Result := TColor32(zenkai + maru(m, gl_FragCoord.xy));
end;

initialization

MouseTrail := TMouseTrail.Create;
Shaders.Add('MouseTrail', MouseTrail);

finalization

FreeandNil(MouseTrail);

end.
