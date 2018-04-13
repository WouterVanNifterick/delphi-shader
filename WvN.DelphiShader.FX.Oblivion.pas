unit WvN.DelphiShader.FX.Oblivion;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
{x $DEFINE PENTAGRAM_ONLY}
  TOblivion = class(TShader)
  public const
    ITR      = 50;
    &FAR     = 25;
    MSPEED   = 5.0;
    ROTSPEED = 0.3;
    VOLSTEPS = 20;

    vec4_1: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec3_2: vec3 = (x: 0; y: 0.1; z: 0.5);
    vec3_3: vec3 = (x: 0.7; y: 0.5; z: 0.1);
    vec3_4: vec3 = (x: 1; y: 1; z: 1);
    vec3_5: vec3 = (x: 0.3; y: 0.5; z: 0.45);
    vec3_6: vec3 = (x: 1; y: 0.5; z: 0.25);
    vec3_7: vec3 = (x: 0; y: 1; z: 0);
    vec3_8: vec3 = (x: 0.5; y: 0.5; z: 0.5);

    m2: Mat2 = (r1: (x: 0.970; y: 0.242); r2: (x: - 0.242; y: 0.970));

  var
    time: double;

    constructor Create; override;
    procedure PrepareFrame;
    function hash(n: TVecType): float;
    function mm2(a: TVecType): Mat2;
    function tri(x: TVecType): float;
    function tri3(const p: vec3): vec3;
    function path(t: TVecType): vec3;
    function triNoise3d(p: vec3): float;
    function map(p: vec3): float;
    function march(const ro, rd: vec3): float;
    function mapVol(p: vec3): float;
    function marchVol(const ro, rd: vec3): vec4;
    function tri2(p: vec2): vec2;
    function triNoise2d(p: vec2): float;
    function shadePenta(p: vec2; const rd: vec3): vec3;
    function mainImage(var FragCoord: vec2):TColor32;
  end;

var
  Oblivion: TShader;

implementation

uses SysUtils, Math;

constructor TOblivion.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;

procedure TOblivion.PrepareFrame;
begin
  time := iGlobalTime * 2;
end;

function TOblivion.hash(n: TVecType): float;
begin
  Result := fract(sin(n) * 43758.5453);
end;

function TOblivion.mm2(a: TVecType): Mat2;
var
  c, s: float;
begin
  c      := cos(a);
  s      := sin(a);
  Result := Mat2.Create(c, -s, s, c);
end;

function TOblivion.tri(x: TVecType): float;
begin
  Result := System.abs(fract(x) - 0.5);
end;

function TOblivion.tri3(const p: vec3): vec3;
begin
  Result := vec3.Create(tri(p.z + tri(p.y * 1)), tri(p.z + tri(p.x * 1)), tri(p.y + tri(p.x * 1)));
end;

function TOblivion.path(t: TVecType): vec3;
begin
  Result := vec3.Create(sin(t * 0.3), (t * 0.25), 0.0) * 0.3;
end;

function TOblivion.triNoise3d(p: vec3): float;
var
  z, rz: float;
  bp   : vec3;
  i    : int;
  dg   : vec3;
begin
  z     := 0.5;
  rz    := 0;
  bp    := p;
  for i := 0 to 3 do
  begin
    dg   := tri3(bp * 2) * 1;
    p    := p + ((dg + time * 0.25));
    bp   := bp * (1.8);
    z    := z * (1.5);
    p    := p * (1.1);
    p.xz := p.xz * (m2);
    rz   := rz + ((tri(p.z + tri(p.x + tri(p.y)))) / z);
    bp   := bp + (0.14);
  end;
  Result := rz;
end;

function TOblivion.map(p: vec3): float;
var
  d: float;
begin
  p      := p - (path(p.z));
  d      := 1 - length(p.xy);
  Result := d;
end;

function TOblivion.march(const ro, rd: vec3): float;
var
  precis, h, d: float;
  i           : int;
  res         : float;
begin
  precis := 0.001;
  h      := precis * 2;
  d      := 0;
  // id  :=  0;;
  for i := 0 to ITR - 1 do
  begin
    if (System.abs(h) < precis) or (d > &FAR) then
      break;
    d   := d + (h);
    res := map(ro + rd * d);
    h   := res;
  end;
  Result := d;
end;

function TOblivion.mapVol(p: vec3): float;
var
  d: float;
begin
  p      := p - (path(p.z));
  d      := 1 - length(p.xy);
  d      := d - (triNoise3d(p * 0.15) * 1.2);
  Result := d * 0.55;
end;

function TOblivion.marchVol(const ro, rd: vec3): vec4;
var
  rz   : vec4;
  t    : float;
  i    : int;
  pos  : vec3;
  r, gr: float;
  lg   : vec3;
  col  : vec4;
begin
  rz    := vec4_1;
  t     := 0.3;
  for i := 0 to VOLSTEPS - 1 do
  begin
    if rz.a > 0.99 then
      break;
    pos     := ro + t * rd;
    r       := mapVol(pos);
    gr      := clamp((r - mapVol(pos + vec3_2)) / 0.5, 0, 1);
    lg      := vec3_3 * 1.2 + 3 * vec3_4 * gr;
    col     := vec4.Create(lg, r + 0.55);
    col.a   := col.a * (0.2);
    col.rgb := col.rgb * (col.a);
    rz      := rz + col * (1 - rz.a);
    t       := t + (0.05);
  end;
  rz.b   := rz.b + (rz.w * 0.2);
  rz.rg  := rz.rg * (mm2(-rd.z * 0.09));
  rz.rb  := rz.rb * (mm2(-rd.z * 0.13));
  Result := clamp(rz, 0, 1);
end;

function TOblivion.tri2(p: vec2): vec2;
var
  m: float;
begin
  m      := 1.5;
  Result := vec2.Create(tri(p.x + tri(p.y * m)), (p.y + tri(p.x * m)));
end;

function TOblivion.triNoise2d(p: vec2): float;
var
  z, z2, rz: float;
  bp       : vec2;
  i        : int;
  dg       : vec2;
begin
  z     := 2;
  z2    := 1.5;
  rz    := 0;
  bp    := p;
  rz    := rz + ((tri(-time * 0.5 + p.x * (sin(-time) * 0.3 + 0.9) + tri(p.y - time * 0.2))) * 0.7 / z);
  for i := 0 to 2 do
  begin
    dg := tri2(bp * 2) * 0.8;
    dg := dg * (mm2(time * 2));
    p  := p + (dg / z2);
    bp := bp * (1.7);
    z2 := z2 * (0.7);
    z  := z * (2);
    p  := p * (1.5);
    p  := p * (m2);
    rz := rz + ((tri(p.x + tri(p.y))) / z);
  end;
  Result := rz;
end;

function TOblivion.shadePenta(p: vec2; const rd: vec3): vec3;
var
  rz             : float;
  q              : vec2;
  pen1, pen2, d  : float;
  col1, col2, col: vec3;
begin
  p      := p * 2.5;
  rz     := triNoise2d(p) * 2;
  q      := abs(p);
  pen1   := max(max(q.x * 1.176 + p.y * 0.385, q.x * 0.727 - p.y), p.y * 1.237);
  pen2   := max(max(q.x * 1.176 - p.y * 0.385, q.x * 0.727 + p.y), -p.y * 1.237);
  d      := abs(min(pen1, pen1 - pen2 * 0.619) * 4.28 - 0.95) * 1.2;
  d      := min(d, abs(length(p) - 1) * 3);
  d      := min(d, abs(pen2 - 0.37) * 4);
  d      := pow(d, 0.7 + sin(sin(time * 4.1) + time) * 0.15);
  rz     := max(rz, d / (rz));
  col1   := vec3_5 / (rz * rz);
  col2   := vec3_6 / (rz * rz);
  col    := mix(col1, col2, clamp(rd.z, 0, 1));
  Result := col;
end;

function TOblivion.mainImage(var FragCoord: vec2):TColor32;
var
  p                        : vec2;
  dz                       : float;
  ro, tgt, eye, rgt, up, rd: vec3;
  rz                       : float;
  pos                      : vec3;
  ligt                     : vec3;
  spi                      : vec2;
  flick                    : float;
{$IFNDEF PENTAGRAM_ONLY}
  col: vec4;
{$ELSE}
  col: vec3;
{$ENDIF}
begin
  p    := FragCoord.xy / resolution.xy - 0.5;
  p.x  := p.x * (resolution.x / resolution.y);
  p    := p + (vec2.Create(hash(time), (time + 1)) * 0.008);
  dz   := sin(time * ROTSPEED) * 8 + 1;
  ro   := path(time * MSPEED + dz) * 0.7 + vec3.Create(0, 0, time * MSPEED);
  ro.z := ro.z + (dz);
  ro.y := ro.y + (cos(time * ROTSPEED) * 0.4);
  ro.x := ro.x + (cos(time * ROTSPEED * 2) * 0.4);
  tgt  := vec3.Create(0, 0, time * MSPEED + 1);
  eye  := normalize(tgt - ro);
  rgt  := normalize(cross(vec3_7, eye));
  up   := normalize(cross(eye, rgt));
  rd   := normalize(p.x * rgt + p.y * up + 0.75 * eye);
{$IFNDEF PENTAGRAM_ONLY}
  rz      := march(ro, rd);
  pos     := ro + rz * rd;
  col     := marchVol(pos, rd);
  ligt    := normalize(vec3.Create(-0, 0, -1));
  spi     := vec2.Create(sin(time), (time)) * 1;
  flick   :=((clamp(1 - abs(((pos.z - time * MSPEED) * 0.3 + fmod(time * 5, 30)) - 15), 0, 1) * clamp(dot(pos.xy, spi), 0, 1) * 1.7))
          + ((clamp(1 - abs(((pos.z - time * MSPEED) * 0.3 + fmod(time * 5 + 10, 30)) - 15), 0, 1) * clamp(dot(pos.xy, spi), 0, 1) * 2))
          + ((clamp(1 - abs(((pos.z - time * MSPEED) * 0.3 + fmod(time * 5 + 20, 30)) - 15), 0, 1) * clamp(dot(pos.xy, spi), 0, 1) * 2));
  col.rgb := (flick * (step(fmod(time, 2.5), 0.2)) * 0.4)
           + (flick * (step(fmod(time * 1.5, 3.2), 0.2)) * 0.4);
  col.rgb := mix(col.rgb * col.rgb,
                 col.rgb * shadePenta(p, rd) * 1.2,
                (1 - col.w) * step(tri(time * 0.25), 0.1) * smoothstep(0.5, 1, 2 * tri(time)));
{$ELSE}
  col := shadePenta(p, rd);
  col := pow(col, vec3_8) * 0.4;
{$ENDIF}
  Result := TColor32(col.rgb);
end;

initialization

Oblivion := TOblivion.Create;
Shaders.Add('Oblivion', Oblivion);

finalization

FreeandNil(Oblivion);

end.
