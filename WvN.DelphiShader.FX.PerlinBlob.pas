unit WvN.DelphiShader.FX.PerlinBlob;

interface

uses Math,GR32, Types, WvN.DelphiShader.Shader;

type
  { playing with perlin... and with ba... }
  { v2 }
  { http://glsl.heroku.com/e#13025.0 }

  TPerlinBlob = class(TShader)
  public const
    SOFT_SHADOW_ITERATIONS = 15;
    maxSteps = 50;
    treshold = 0.001;
    maxdist  = 10;
    oid1     = 1;
    oid2     = 2;

    vec4_1: vec4 = (x: 0; y: 57; z: 21; w: 78);
    vec3_2: vec3 = (x: 1; y: 57; z: 21);
    vec2_3: vec2 = (x: 0.97; y: 1.1);
    vec2_4: vec2 = (x: 1.0; y: 1.0);
    vec3_5: vec3 = (x: 0.001; y: 0; z: 0);
    e_xyy: vec3  = (x: 0.001; y: 0; z: 0);
    e_yxy: vec3  = (x: 0; y: 0.001; z: 0);
    e_yyx: vec3  = (x: 0; y: 0; z: 0.001);

    vec2_6: vec2  = (x: 1; y: 1);
    vec3_7: vec3  = (x: 0; y: 0; z: - 3);
    vec3_8: vec3  = (x: 1; y: 1; z: - 1);
    vec3_9: vec3  = (x: 0; y: 0; z: 0);
    vec3_10: vec3 = (x: 0.10; y: 0.10; z: 0.10);
    vec3_11: vec3 = (x: 0.15; y: 0.15; z: 0.15);
    vec3_12: vec3 = (x: 0.80; y: 0.80; z: 0.80);
    vec3_13: vec3 = (x: 0.4; y: 0.4; z: 0.4);
    vec3_14: vec3 = (x: 0.2; y: 0.4; z: 0.8);
    vec3_15: vec3 = (x: 1; y: 1; z: 1);

    COS_TABLE_SIZE=1024;

  var
    var CosTab:array[0..pred(COS_TABLE_SIZE)] of double;

    speed      : float;
    ro, lig, nlig, rd: vec3;
    mx,my:float;
    function rot(const k: vec2; t: float): vec2;inline;
    function perlin(const p: vec3): float;
    function opU(const d1, d2: vec2): vec2;inline;
    function sdCylinder(const p: vec3; const h: vec2): float;inline;
    function mapf(const p: vec3): Float;
    //function map(const p: vec3): vec2;inline;
    function cNor(const p: vec3): vec3;
    function calcAO(const pos, nor: vec3): float;
    function calcSoftShadow(const ro, rd: vec3; mint, maxt, k: float): float;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  PerlinBlob: TShader;

implementation

uses SysUtils;

{$EXCESSPRECISION OFF}

constructor TPerlinBlob.Create;
var i : integer;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  nLig := Normalize(lig);
  for I := 0 to COS_TABLE_SIZE-1 do
  begin
    CosTab[I] := sin(pi*i/COS_TABLE_SIZE);
  end;

end;

function TPerlinBlob.rot(const k: vec2; t: float): vec2;
var sint,cost:double;
begin
{$EXCESSPRECISION OFF}
  sint := System.Sin(t);
  cost := System.Cos(t);
  Result.x := Cost * k.x - Sint * k.y;
  Result.y := Sint * k.x + Cost * k.y;
end;

function TPerlinBlob.perlin(const p: vec3): float;
var i: vec3;
    ad:Float;
    a: vec4;
    f: vec3;
begin
//  exit(sin((p.x+p.y+p.z)*2));
//  i      := floor(p);
  i.x    := Math.floor(p.x);
  i.y    := Math.floor(p.y);
  i.z    := Math.floor(p.z);

//  a    := dot(i, vec3_2) + vec4_1;
  ad := i.x * vec3_2.x +
        i.y * vec3_2.y +
        i.z * vec3_2.z;

  a.x := vec4_1.x + ad;
  a.y := vec4_1.y + ad;
  a.z := vec4_1.z + ad;

//  f    := cos((p - i)*pi) * -0.5 + 0.5;
  f.x    := cos((p.x - i.x) * pi) * -0.5 + 0.5;
  f.y    := cos((p.y - i.y) * pi) * -0.5 + 0.5;
  f.z    := cos((p.z - i.z) * pi) * -0.5 + 0.5;
//  a    := mix(sin(cos(a) * a), sin(cos(1 + a) * (1 + a)), f.x);
  a.x    := mix(sin(cos(a.x) * a.x), sin(cos(1 + a.x) * (1 + a.x)), f.x);
  a.y    := mix(sin(cos(a.y) * a.y), sin(cos(1 + a.y) * (1 + a.y)), f.x);
  a.z    := mix(sin(cos(a.z) * a.z), sin(cos(1 + a.z) * (1 + a.z)), f.x);
  a.w    := mix(sin(cos(a.w) * a.w), sin(cos(1 + a.w) * (1 + a.w)), f.x);

  a.xy := mix(a.xz, a.yw, f.y);
  Exit(mix(a.x, a.y, f.z));
end;

function TPerlinBlob.opU(const d1, d2: vec2): vec2;
begin
  if d1.x < d2.x then
    Result := d1
  else
    Result := d2
end;

function TPerlinBlob.sdCylinder(const p: vec3; const h: vec2): float;
begin
  Result := max(length(p.xz) - h.x, System.Abs(p.y) - h.y);
end;

function TPerlinBlob.mapf(const p: vec3): Float;
begin
  Result := math.max( sdCylinder(p,vec2_4), -sdCylinder(p,vec2_3) );
//  Result := length(p) - length(cos(perlin(p + speed))) - 0.5;
end;

function TPerlinBlob.cNor(const p: vec3): vec3;
begin
  Result.x := mapf(p + e_xyy) - mapf(p - e_xyy);
  Result.y := mapf(p + e_yxy) - mapf(p - e_yxy);
  Result.z := mapf(p + e_yyx) - mapf(p - e_yyx);
  Result.NormalizeSelf;
end;

function TPerlinBlob.calcAO(const pos, nor: vec3): float;
var
  totao: float;
  sca  : float;
  aoi  : integer;
  hr   : float;
  aopos: vec3;
  dd   : float;

begin
  totao   := 0;
  sca     := 1;
  for aoi := 0 to 4 do
  begin
    hr    := 0.01 + 0.05 * aoi;
    aopos := nor * hr + pos;
    dd    := mapf(aopos);
    totao := totao + (-(dd - hr) * sca);
    sca   := sca * 0.75;
  end;

  Result := clamp(1 - 4 * totao);
end;

// softshadow
function TPerlinBlob.calcSoftShadow(const ro, rd: vec3; mint, maxt, k: float): float;
var
  res: float;
  t  : float;
  i  : integer;
  h  : float;

begin
  res   := 1;
  t     := mint;
  for i := 0 to SOFT_SHADOW_ITERATIONS-1 do
  begin
    if t > maxt then
      break;
    h   := mapf(ro + rd * t);
    res := min(res, k * h / t);
    t   := t + (0.6/SOFT_SHADOW_ITERATIONS);
  end;

  Exit(clamp(res, 0, 1));
end;

procedure TPerlinBlob.PrepareFrame;
begin

  speed := time * 0.4321;
  ro    := vec3_7;
  lig   := vec3_8;

  mx := mouse.x * 8;
  my := mouse.y * 8;

  lig.xz := rot(lig.xz, mx);
  lig.xy := rot(lig.xy, my);
  ro.xz  := rot(ro.xz, mx);
  ro.xy  := rot(ro.xy, my);

end;

function TPerlinBlob.Main(var gl_FragCoord: vec2): TColor32;
var
  tx,ty:float;
//  t:vec2;
  ps            : vec2;
  oc               : vec3;
  f                : float;
  i                : integer;
  col, pos, nor    : vec3;
  ao, amb, dif, bac: float;
  sh, spe, rim     : float;
begin
  ps    := (gl_FragCoord.xy / resolution.xy);
  rd.xy := (-1 + 2 * ps) * vec2_6;
  rd.z  := 1;
  rd.NormalizeSelf;
  rd.xz := rot(rd.xz, mx);
  rd.xy := rot(rd.xy, my);

  // march
  f    := 0;
  tx   := treshold;
  for i := 1 to maxSteps do
  begin
    tx  := mapf(ro + rd * tx);
    ty  := oid2;
    f   := f + tx;
    tx  := f;
    if (System.Abs(tx) < treshold) or (tx > maxdist) then
      break;
  end;

  if tx > maxdist then
    ty := 0;

  // draw
  col := vec3_9;
  if ty > 0.5 then
  begin
    lig := normalize(lig);
    pos := ro + rd * tx;
    nor := cNor(pos);
    ao  := calcAO(pos, nor);

    amb := clamp(0.5 + 0.5 * nor.y);
    dif := clamp(dot(nor, lig));
    bac := clamp(dot(nor, -lig));

    sh := calcSoftShadow(pos, lig, 0.001, 1, 0.5);

    col :=       (0.20 * amb * vec3_10 * ao) // 0.02
               + (0.20 * bac * vec3_11 * ao)
               + (1.00 * dif * vec3_12);

    spe := sh * power(clamp(dot(lig, reflect(rd, nor)), 0, 1), 16);
    rim := ao * power(clamp(1 + dot(nor, rd), 0, 5), 2);

    if ty = oid1 then
      oc := vec3_13
    else
    if ty = oid2 then
      oc := vec3_14;

    col := oc * col + vec3_15 * col * spe + 0.2 * rim * (0.5 + 0.5 * col);
  end;

  Result := TColor32(col);
end;

initialization

PerlinBlob := TPerlinBlob.Create;
Shaders.Add('PerlinBlob', PerlinBlob);

finalization

FreeandNil(PerlinBlob);

end.
