unit WvN.DelphiShader.FX.TruchetTentacles;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TTruchetTentacles = class(TShader)

  const
    eps = 0.001;
    Iterations     = 32;
    Thickness      = 0.1;
    SuperQuadPower = 8.0;
    Fisheye        = 0.5;

    eps_100 : vec3 = (x:eps; y:0.000;z:0.000);
    eps_010 : vec3 = (x:0.000; y:eps;z:0.000);
    eps_001 : vec3 = (x:0.000; y:0.000;z:eps);

  var
    rp,
    ray_pos  : vec3;
    s2t:Float;
    a, t: Float;
    m   : Mat3;

    function rand(const r: vec3): Float;
    function gradient(const pos: vec3): vec3;
    function truchetarc(const pos: vec3): Float;
    function truchetcell(const pos: vec3): Float;
    function distfunc(const pos: vec3): Float;

    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  TruchetTentacles: TShader;

implementation

uses SysUtils, Math;

constructor TTruchetTentacles.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

function TTruchetTentacles.rand(const r: vec3): Float;
begin
  Result := fract(sinLarge(dot(r.xy, Vec2.Create(1.38984 * sinLarge(r.z), 1.13233 * cosLarge(r.z)))) * 653758.5453);
end;

function TTruchetTentacles.truchetarc(const pos: vec3): Float;
var
  r: Float;
begin
  r := length(pos.xy);
  // return max(abs(r-0.5),abs(pos.z-0.5))-Thickness;
  // return length(Vec2.Create(r-0.5,pos.z-0.5))-Thickness;
  Result := pow(pow(system.abs(r - 0.5), SuperQuadPower) + pow(system.abs(pos.z - 0.5), SuperQuadPower), 1.0 / SuperQuadPower) - Thickness;
end;

function TTruchetTentacles.truchetcell(const pos: vec3): Float;
begin
  Exit(
    Math.min(
    Math.min(truchetarc(pos),
    truchetarc(vec3.Create(pos.z, 1 - pos.x, pos.y))),
    truchetarc(vec3.Create(1 - pos.y, 1 - pos.z, pos.x))));
end;

function TTruchetTentacles.distfunc(const pos: vec3): Float;
var
  cellpos: vec3;
  gridpos: vec3;
  rnd    : Float;
begin
  cellpos := fract(pos);
  gridpos := floor(pos);

  rnd := rand(gridpos);

  if rnd < 1 / 8 then Exit(truchetcell(vec3.Create(cellpos.x, cellpos.y, cellpos.z)));
  if rnd < 2 / 8 then Exit(truchetcell(vec3.Create(cellpos.x, 1 - cellpos.y, cellpos.z)));
  if rnd < 3 / 8 then Exit(truchetcell(vec3.Create(1 - cellpos.x, cellpos.y, cellpos.z)));
  if rnd < 4 / 8 then Exit(truchetcell(vec3.Create(1 - cellpos.x, 1 - cellpos.y, cellpos.z)));
  if rnd < 5 / 8 then Exit(truchetcell(vec3.Create(cellpos.y, cellpos.x, cellpos.z)));
  if rnd < 6 / 8 then Exit(truchetcell(vec3.Create(cellpos.y, 1 - cellpos.x, cellpos.z)));
  if rnd < 7 / 8 then Exit(truchetcell(vec3.Create(1 - cellpos.y, cellpos.x, cellpos.z)));
                      Exit(truchetcell(vec3.Create(1 - cellpos.y, 1 - cellpos.x, cellpos.z)));
end;

function TTruchetTentacles.gradient(const pos: vec3): vec3;
var
  mid: Float;
begin
  mid := distfunc(pos);
  Result.x := distfunc(pos + eps_100) - mid;
  Result.y := distfunc(pos + eps_010) - mid;
  Result.z := distfunc(pos + eps_001) - mid;
end;


procedure TTruchetTentacles.PrepareFrame;
var
  s, c: double;
begin
  a := iGlobalTime / 3;
  s := sinLarge(a);
  c := cosLarge(a);
  m := Mat3.Create(0.0, 1, 0,
                    -s, 0, c,
                     c, 0, s);
  m := m * m;
  m := m * m;

  t := iGlobalTime / 3;
  s2t := sinLarge(2 * t);
  rp.x := 2 * (sinLarge(t + s2t * 0.5) / 2 + 0.5);
  rp.y := 2 * (sinLarge(t - s2t * 0.5 - pi * 0.5) * 0.5 + 0.5);
  rp.z := 2 * ((-2 * (t - sinLarge(4 * t) * 0.25) / pi) + 0.5 + 0.5);
end;


function TTruchetTentacles.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  coords   : Vec2;
  ray_dir  : vec3;
  i, dist  : Float;
  normal   : vec3;
  ao       : Float;
  what     : Float;
  vignette : Float;
  light    : Float;
  z        : Float;
  col      : vec3;
  reflected: vec3;
  env      : vec3;
  j        : integer;
begin
  coords  := (2 * gl_FragCoord.xy - Resolution.xy) / length(Resolution.xy);
  ray_dir := m * normalize(vec3.Create(1.4 * coords, -1 + Fisheye * (coords.x * coords.x + coords.y * coords.y)));

  i     := Iterations;
  Ray_pos := rp;
  for j := 0 to Iterations - 1 do
  begin
    dist    := distfunc(ray_pos);
    ray_pos.x := ray_pos.x + dist * ray_dir.x;
    ray_pos.y := ray_pos.y + dist * ray_dir.y;
    ray_pos.z := ray_pos.z + dist * ray_dir.z;

    if (system.abs(dist) < 0.001) then
    begin
      i := j;
      break;
    end;
  end;

  normal := gradient(ray_pos);
  normal.NormalizeSelf;

  ao       := 1 - i / Iterations;
  what     := power(Math.max(0, dot(normal, -ray_dir)), 2);
  vignette := power(1 - length(coords), 0.3);
  light    := ao * what * vignette * 1.4;

  z   := ray_pos.z / 2;
  col := (sin(vec3.Create(z, z + pi / 3, z + pi * 2 / 3)) + 2) / 3;
  col := (cos(ray_pos / 2) + 2) / 3;

  reflected := reflect(ray_dir, normal);
  env       := textureCube(TShader.cubes[0], reflected * reflected * reflected).rgb;
  Result    := TColor32(-0.3 + (col * light + env));
end;

initialization

TruchetTentacles := TTruchetTentacles.Create;
Shaders.Add('TruchetTentacles', TruchetTentacles);

finalization

FreeandNil(TruchetTentacles);

end.
