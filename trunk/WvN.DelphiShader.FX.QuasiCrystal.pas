unit WvN.DelphiShader.FX.QuasiCrystal;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TQuasiCrystal = class(TShader)
  var
    t  : float;
  const
    // all of these can be played with
    scale    = 5;
    tscale   = 14;
    xpixels  = 3;
    ypixels  = 3;
    symmetry = 7;

    // Available as Mac Screensaver.  Code/Downloads here:
    // https://bitbucket.org/rallen/quasicrystalscreensaver/wiki/Home
    ra = 0 / 3 * 2 * PI;
    ga = 1 / 3 * 2 * PI;
    ba = 2 / 3 * 2 * PI;

    vec2_1: vec2 = (x: 1; y: 1);
    vec4_2: vec4 = (x:  58 / 255; y: 117 / 255; z:  78 / 255; w: 0);
    vec4_3: vec4 = (x: 175 / 255; y: 207 / 255; z:  93 / 255; w: 0);
    vec4_4: vec4 = (x: 175 / 255; y: 207 / 255; z:  93 / 255; w: 0);
    vec4_5: vec4 = (x: 255 / 255; y: 232 / 255; z: 135 / 255; w: 0);
    vec4_6: vec4 = (x: 194 / 255; y: 138 / 255; z:  79 / 255; w: 0);
    vec4_7: vec4 = (x: 255 / 255; y: 232 / 255; z: 135 / 255; w: 0);
    vec4_8: vec4 = (x: 194 / 255; y: 138 / 255; z:  79 / 255; w: 0);
    vec4_9: vec4 = (x: 145 / 255; y:  70 / 255; z:  56 / 255; w: 0);

    function adj(n, m: float): float;
    function point(const src: vec2): vec2;
    function wave(const p: vec2; th: float): float;
    function combine(const p: vec2): float;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  QuasiCrystal: TShader;

implementation

uses SysUtils, Math;

constructor TQuasiCrystal.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TQuasiCrystal.PrepareFrame;
begin
  t := fract(iGlobalTime / tscale) * 2 * pi;
end;

function TQuasiCrystal.adj(n, m: float): float;
begin
  Result := scale * ((2 * n / (m - 1)) - 1);
end;

function TQuasiCrystal.point(const src: vec2): vec2;
begin
  Result.x := adj(src.x, ypixels);
  Result.y := adj(src.y, ypixels);
end;

function TQuasiCrystal.wave(const p: vec2; th: float): float;
var
  sth: float;
  cth: float;
begin
  sth := system.sin(th);
  cth := system.cos(th);

  Result := (system.cos(cth * p.x + sth * p.y + t) + 1) / 2;
end;

function TQuasiCrystal.combine(const p: vec2): float;
var
  sum: float;
  i  : integer;

begin
  sum   := 0;
  for i := 0 to symmetry - 1 do
    sum := sum + (wave(point(p), i * PI / symmetry));

  if &mod(Math.floor(sum), 2) = 0 then
    result := fract(sum)
  else
    result := 1 - fract(sum);
end;

function TQuasiCrystal.Main(var gl_FragCoord: vec2): TColor32;
var
  vUV: vec2;
  s  : float;
  c  : vec4;
begin
  vUV := (gl_FragCoord.xy / resolution.xy) + vec2_1;
  s := combine(vec2.Create(vUV.x * xpixels, vUV.y * ypixels))*4;

  // clut select
  if s <= 1 then
    c := mix(vec4_2, vec4_3, s)
  else if s <= 2 then
    c := mix(vec4_4, vec4_5, s - 1)
  else if s <= 3 then
    c := mix(vec4_7, vec4_6, s - 2)
  else
    c := mix(vec4_8, vec4_9, s - 3);

  result := TColor32(c);
end;

initialization

QuasiCrystal := TQuasiCrystal.Create;
Shaders.Add('QuasiCrystal', QuasiCrystal);

finalization

FreeandNil(QuasiCrystal);

end.
