unit WvN.DelphiShader.FX.Interstellar;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TInterstellar = class(TShader)
  const
    tau   = 6.28318530717958647692;
    GAMMA = 2.2;

    constructor Create; override;
    procedure PrepareFrame;
    function ToLinear(const col: vec3): vec3;
    function ToGamma(const col: vec3): vec3;

    function Noise(const x: ivec2): vec4;
    function Rand(const x: int): vec4;
    function main(var gl_FragCoord: vec2): TColor32;
  private
    offset: Float;
    speed2: Float;
    speed: Float;
  end;

var
  Interstellar: TShader;

implementation

uses SysUtils, Math;

constructor TInterstellar.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
end;

procedure TInterstellar.PrepareFrame;
begin

  offset := iGlobalTime * 0.5;
  speed2 := (system.cos(offset) + 1) * 2;
  speed  := speed2 + 0.1;
  offset := offset + (system.sin(offset) * 0.96);
  offset := offset * 2;

end;

function TInterstellar.ToLinear(const col: vec3): vec3;
begin
  // simulate a monitor, converting colour values into light values
  Exit(pow(col, vec3(GAMMA)));
end;

function TInterstellar.ToGamma(const col: vec3): vec3;
begin
  // convert back into colour values, so the correct light will come out of the monitor
  Exit(pow(col, vec3(1 / GAMMA)));
end;

function TInterstellar.Noise(const x: ivec2): vec4;
begin
  Result := texture2D(tex[15], (vec2.Create(x.x, x.y) + 0.5) / 256, -100);
end;

function TInterstellar.Rand(const x: int): vec4;
var
  uv: vec2;
begin
  uv.x := x + 0.5 / 256;
  uv.y := (floor(uv.x) + 0.5) / 256;
  Exit(texture2D(tex[15], uv, -100));
end;

function TInterstellar.main(var gl_FragCoord: vec2): TColor32;
var
  ray          : vec3;
  col, stp, pos: vec3;
  i            : int;
  z, d, w      : Float;
  c            : vec3;
  m            : Float;
  v            : ivec2;
begin
  ray.xy := 2 * (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.x;
  ray.z  := 1;

  col    := vec3Black;
  m      := Math.Max(System.abs(ray.x), System.abs(ray.y));

  if not IsZero(m) then
    stp := ray / m
  else
    stp := 0;

  pos   := 2 * stp + 0.5;
  for i := 0 to 19 do
  begin
    v.x := trunc(pos.x);
    v.y := trunc(pos.y);
    z   := Noise(v).x;
    z   := fract(z - offset);
    d   := 50 * z - pos.z;
    w   := pow(Math.Max(0, 1 - 8 * length(fract(pos.xy) - 0.5)), 2);
    c   := Max(vec3Black, vec3.Create(1 - System.abs(d + speed2 * 0.5) / speed, 1 - System.abs(d) / speed, 1 - System.abs(d - speed2 * 0.5) / speed));
    col := col + (1.5 * (1 - z) * c * w);
    pos := pos + stp;
  end;

  Result := TColor32(ToGamma(col));
end;

initialization

Interstellar := TInterstellar.Create;
Shaders.Add('Interstellar', Interstellar);

finalization

FreeandNil(Interstellar);

end.
