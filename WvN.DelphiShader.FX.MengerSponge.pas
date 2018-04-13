unit WvN.DelphiShader.FX.MengerSponge;

interface

uses GR32, Types, WvN.DelphiShader.Shader, Math;

type
  TMengerSponge = class(TShader)
  const
    pi2=pi*2;
    vec3_1: vec3 = (x: 1.0; y: 0.97; z: 0.85);
    vec3_2: vec3 = (x: 1.0; y: 0.97; z: 0.85);
    vec3_3: vec3 = (x: 0.1; y: 0.15; z: 0.2);

    precis       = 0.001;
    eps100:vec3 = (x: precis; y: 0; z: 0);
    eps010:vec3 = (x: 0; y: precis; z: 0);
    eps001:vec3 = (x: 0; y: 0; z: precis);
  var
    light,light2 : vec3;
    ro, ww, uu, vv, rd, col: vec3;
    function calcNormal(const pos: vec3): vec3;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  MengerSponge: TShader;

implementation

uses SysUtils;

const
  half = 0.5;

constructor TMengerSponge.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

function maxcomp(const p: vec3): float; inline;
begin
  Result := Math.Max(p.x, Math.Max(p.y, p.z));
end;

function sdBox(const p: vec3; b: vec3): float;inline;
var
  di: vec3;
  mc: float;
begin
  di     := abs(p) - b;
  mc     := maxcomp(di);
  Result := Math.min(mc, length(Max(di, 0)));
end;

function map(const p: vec3): vec3;
var
  s               : float;
  da, db, dc, c, d: float;
  a, r            : vec3;
  m               : Integer;
begin
  d   := sdBox(p, vec3White);
  result.x := d;
  result.y := 1;
  result.z := 0;

  s     := 1.0;
  for m := 0 to 4 do
  begin
    a.x := fmods(p.x * s, 2) - 1;
    a.y := fmods(p.y * s, 2) - 1;
    a.z := fmods(p.z * s, 2) - 1;

    s := s * 3;
    r := abs(1 - 3 * abs(a));

    da := Math.Max(r.x, r.y);
    db := Math.Max(r.y, r.z);
    dc := Math.Max(r.z, r.x);
    c  := (Math.min(da, Math.min(db, dc)) - 1) / s;

    if c > d then
    begin
      d   := c;
      result.x := d;
      result.y := 0.2 * da * db * dc;
      result.z := (1 + m) / 4;
    end;
  end;
end;

function intersect(const ro, rd: vec3): vec4;
var
  t: TVecType;
  i: Integer;
  h: vec4;
begin
  t     := 0;
  for i := 0 to 63 do
  begin
    h.xyz := map(ro + rd * t);
    if (h.x < 0.005) then
    begin
      Result := h;
      Result.x := t;
      Exit;
    end;
    t := t + h.x;
  end;
  Result.x := -1;
end;

function TMengerSponge.calcNormal(const pos: vec3): vec3;
begin
  Result.x  := map(pos + eps100).x - map(pos - eps100).x;
  Result.y  := map(pos + eps010).x - map(pos - eps010).x;
  Result.z  := map(pos + eps001).x - map(pos - eps001).x;
  Result.NormalizeSelf;
end;

procedure TMengerSponge.PrepareFrame;
var
  cTime: Double;
begin
  // light
  light := normalize(vec3.Create(1.0, 0.8, -0.6));
  light2 := vec3.Create( -light.x, light.y, -light.z);

  cTime := iGlobalTime;
  // camera
  ro := 1.1 * vec3.Create(2.5 * cosLarge(0.5 * cTime), 1.5 * cosLarge(cTime * 0.23), 2.5 * sinLarge(0.5 * cTime));
  ww := normalize(vec3Black - ro);
  uu := normalize(cross(vec3Green, ww));
  vv := normalize(cross(ww, uu));

end;

function TMengerSponge.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  p                   : Vec2;
  matcol, pos, nor    : vec3;
  shadow, tmat        : vec4;
  dif1, dif2, ldis, ao: float;

begin
  p.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x;
  p.y := -1.0 + 2.0 * gl_FragCoord.y / Resolution.y;
  p.x := p.x * 1.33;

  // p.x := gl_FragCoord.x;
  // p.y := gl_FragCoord.y;

  rd := normalize(p.x * uu + p.y * vv + 1.5 * ww);

  col  := vec3Black;
  tmat := intersect(ro, rd);
  if (tmat.x > 0) then
  begin
    pos := ro + tmat.x * rd;
    nor := calcNormal(pos);

    dif1 := Max(0.4 + 0.6 * dot(nor, light), 0);
    dif2 := Max(0.4 + 0.6 * dot(nor, light2), 0.0);

    // shadow
    ldis   := 4;
    shadow := intersect(pos + light * ldis, -light);
    if ((shadow.x > 0) and (shadow.x < (ldis - 0.01))) then
      dif1 := 0;

    ao  := tmat.y;
    col := (1.0 * ao * vec3.Create(0.2, 0.2, 0.2))
         + (2   * (0.5 + 0.5 * ao) * dif1 * vec3_1)
         + (0.2 * (0.5 + 0.5 * ao) * dif2 * vec3_2)
         + (1   * (0.5 + 0.5 * ao) * (0.5 + 0.5 * nor.y) * vec3_3);

    // gamma lighting
    col.x := col.x * 0.5 + 0.5 * system.sqrt(col.x) * 1.2;
    col.y := col.y * 0.5 + 0.5 * system.sqrt(col.y) * 1.2;
    col.z := col.z * 0.5 + 0.5 * system.sqrt(col.z) * 1.2;

    matcol.x := 0.6 + 0.4 * system.cos(5.0 + pi2 * tmat.z);
    matcol.y := 0.6 + 0.4 * system.cos(5.4 + pi2 * tmat.z);
    matcol.z := 0.6 + 0.4 * system.cos(5.7 + pi2 * tmat.z);

    col := col * matcol;
    col := col * (1.5 * System.Exp(-0.5 * tmat.x));
  end;

  Result := TColor32(col);
end;

initialization

MengerSponge := TMengerSponge.Create;
Shaders.Add('MengerSponge', MengerSponge);

finalization

FreeandNil(MengerSponge);

end.
