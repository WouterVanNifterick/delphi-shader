unit WvN.DelphiShader.FX.TruchetTentacles;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TTruchetTentacles = class(TShader)
    a,t: Float;
    m: Mat3;

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

procedure TTruchetTentacles.PrepareFrame;
begin
  a := iGlobalTime / 3.0;
  m := Mat3.Create(0.0, 1.0, 0.0, -system.sin(a), 0.0, system.cos(a), system.cos(a), 0.0, system.sin(a));
  m := m * m;
  m := m * m;

  t  := iGlobalTime / 3.0;

end;

function rand(const r: vec3): Float;
begin
  Result := fract(system.sin(dot(r.xy, Vec2.Create(1.38984 * system.sin(r.z), 1.13233 * system.cos(r.z)))) * 653758.5453);
end;

const
  Iterations     = 64;
  Thickness      = 0.1;
  SuperQuadPower = 8.0;
  Fisheye        = 0.5;

function truchetarc(const pos: vec3): Float;
var
  r: Float;
begin
  r := length(pos.xy);
  // return max(abs(r-0.5),abs(pos.z-0.5))-Thickness;
  // return length(Vec2.Create(r-0.5,pos.z-0.5))-Thickness;
  Result := pow(pow(abs(r - 0.5), SuperQuadPower) + pow(abs(pos.z - 0.5), SuperQuadPower), 1.0 / SuperQuadPower) - Thickness;
end;

function truchetcell(const pos: vec3): Float;
begin
  Exit(Math.min(Math.min(truchetarc(pos), truchetarc(vec3.Create(pos.z, 1.0 - pos.x, pos.y))), truchetarc(vec3.Create(1.0 - pos.y, 1.0 - pos.z, pos.x))));
end;

function distfunc(const pos: vec3): Float;
var
  cellpos: vec3;
  gridpos: vec3;
  rnd    : Float;
begin
  cellpos := fract(pos);
  gridpos := floor(pos);

  rnd := rand(gridpos);

  if rnd < 1 / 8 then Exit(truchetcell(vec3.Create(cellpos.x, cellpos.y, cellpos.z)));
  if rnd < 2 / 8 then Exit(truchetcell(vec3.Create(cellpos.x, 1.0 - cellpos.y, cellpos.z)));
  if rnd < 3 / 8 then Exit(truchetcell(vec3.Create(1.0 - cellpos.x, cellpos.y, cellpos.z)));
  if rnd < 4 / 8 then Exit(truchetcell(vec3.Create(1.0 - cellpos.x, 1.0 - cellpos.y, cellpos.z)));
  if rnd < 5 / 8 then Exit(truchetcell(vec3.Create(cellpos.y, cellpos.x, cellpos.z)));
  if rnd < 6 / 8 then Exit(truchetcell(vec3.Create(cellpos.y, 1.0 - cellpos.x, cellpos.z)));
  if rnd < 7 / 8 then Exit(truchetcell(vec3.Create(1.0 - cellpos.y, cellpos.x, cellpos.z)));
                      Exit(truchetcell(vec3.Create(1.0 - cellpos.y, 1.0 - cellpos.x, cellpos.z)));
end;

function gradient(const pos: vec3): vec3;
var
  eps: Float;
  mid: Float;
begin
  eps := 0.0001;
  mid := distfunc(pos);
  Exit(vec3.Create(distfunc(pos + vec3.Create(eps, 0.0, 0.0)) - mid, distfunc(pos + vec3.Create(0.0, eps, 0.0)) - mid, distfunc(pos + vec3.Create(0.0, 0.0, eps)) - mid));
end;

function TTruchetTentacles.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  coords   : Vec2;
  ray_pos  : vec3;
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
  coords := (2 * gl_FragCoord.xy - Resolution.xy) / length(Resolution.xy);
  ray_dir := m * normalize(vec3.Create(1.4 * coords, -1 + Fisheye * (coords.x * coords.x + coords.y * coords.y)));

  ray_pos := vec3.Create(
               2 * (system.sin(t + system.sin(2 * t) / 2) / 2 + 0.5),
               2 * (system.sin(t - system.sin(2 * t) / 2 - pi / 2) / 2 + 0.5),
               2 * ((-2 * (t - system.sin(4 * t) / 4) / pi) + 0.5 + 0.5));

  i     := Iterations;
  for j := 0 to Iterations - 1 do
  begin
    dist    := distfunc(ray_pos);
    ray_pos := ray_pos + (dist * ray_dir);

    if (abs(dist) < 0.001) then
    begin
      i := j;
      break;
    end;
  end;

  normal := gradient(ray_pos);
  normal.NormalizeSelf;

  ao       := 1.0 - i / Iterations;
  what     := pow(max(0.0, dot(normal, -ray_dir)), 2.0);
  vignette := pow(1.0 - length(coords), 0.3);
  light    := ao * what * vignette * 1.4;

  z   := ray_pos.z / 2.0;
  col := (sin(vec3.Create(z, z + pi / 3.0, z + pi * 2.0 / 3.0)) + 2.0) / 3.0;
  col := (cos(ray_pos / 2.0) + 2.0) / 3.0;

  reflected := reflect(ray_dir, normal);
  env       := textureCube(TShader.cubes[0], reflected * reflected * reflected).rgb;
  Result := TColor32(-0.3+(col * light + env));
end;

initialization

TruchetTentacles := TTruchetTentacles.Create;
Shaders.Add('TruchetTentacles', TruchetTentacles);

finalization

FreeandNil(TruchetTentacles);

end.
