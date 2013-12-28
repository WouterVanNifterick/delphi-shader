unit WvN.DelphiShader.FX.FastSmallPT;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  Ray = record
    o, d: vec3;
  end;

  Sphere = record
    r: float;
    p, e, c: vec3;
    refl: int;
    constructor Create(_r: float; _p, _e, _c: vec3; _refl: int);
  end;

  TFastSmallPT = class(TShader)
    function rand: float;
    function intersect(s: Sphere; const r: Ray): float; overload;
    function intersect(const r: Ray; out t: float; out s: Sphere; avoid: int): int; overload;
    function jitter(const d: vec3; phi, sina, cosa: float): vec3;
    function radiance(r: Ray): vec3;
    function Main(var gl_FragCoord: Vec2): TColor32;

  const
    NUM_SPHERES = 9;

  var
    seed   : float;
    spheres: array [0 .. NUM_SPHERES] of Sphere;

  const
    // Play with the two following values to change quality.
    // You want as many samples as your GPU can bear. :)
    SAMPLES  = 3;
    MAXDEPTH = 3;

    // Not used for now
    DEPTH_RUSSIAN = 1;
    PI            = 3.14159265359;
    DIFF          = 0;
    SPEC          = 1;
    REFR          = 2;

    vec3_1: vec3              = (x: 50; y: 81.6; z: 81.6);
    vec3_2: vec3              = (x: 1.2126; y: 0.7152; z: 0.0722);
    vec3_3: vec3              = (x: 0.75; y: 0.25; z: 0.25);
    vec3_4: vec3              = (x: 0.25; y: 0.25; z: 0.75);
    vec3_5: vec3              = (x: 27; y: 16.5; z: 47);
    vec3_6: vec3              = (x: 0.7; y: 1; z: 0.9);
    vec3_7: vec3              = (x: 73; y: 16.5; z: 78);
    vec3_8: vec3              = (x: 50; y: 681.33; z: 81.6);
    vec2_9: Vec2              = (x: 50; y: 40.8);
    vec2_10: Vec2             = (x: 48; y: 40);
    vec3_11: vec3             = (x: 50; y: 40; z: 81.6);
    vec3_12: vec3             = (x: 1; y: 0; z: 0);
    lightSourceVolume: Sphere = (r: 20; p: (x: 50; y: 81.6; z: 81.6); e: (x: 12; y: 12; z: 12); c: (x: 0; y: 0; z: 0); refl: DIFF);

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  FastSmallPT: TShader;

implementation

uses SysUtils, Math;

constructor TFastSmallPT.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  seed      := 0;
end;

procedure TFastSmallPT.PrepareFrame;
begin
  spheres[0] := Sphere.Create(1E5, vec3.Create(-1E5 + 1, 40.8, 81.6), vec3.Create(0), vec3_3, DIFF);
  spheres[1] := Sphere.Create(1E5, vec3.Create(1E5 + 99, 40.8, 81.6), vec3.Create(0), vec3_4, DIFF);
  spheres[2] := Sphere.Create(1E5, vec3.Create(50, 40.8, -1E5), vec3.Create(0), vec3(0.75), DIFF);
  spheres[3] := Sphere.Create(1E5, vec3.Create(50, 40.8, 1E5 + 170), vec3.Create(0), vec3(0), DIFF);
  spheres[4] := Sphere.Create(1E5, vec3.Create(50, -1E5, 81.6), vec3.Create(0), vec3(0.75), DIFF);
  spheres[5] := Sphere.Create(1E5, vec3.Create(50, 1E5 + 81.6, 81.6), vec3.Create(0), vec3(0.75), DIFF);
  spheres[6] := Sphere.Create(16.5, vec3_5, vec3.Create(0), vec3(1), SPEC);
  spheres[7] := Sphere.Create(16.5, vec3_7, vec3.Create(0), vec3_6, REFR);
  spheres[8] := Sphere.Create(600, vec3_8, vec3.Create(12), vec3(0), DIFF);
end;

{

  This shader is an attempt at porting smallpt to GLSL.

  See what it's all about here:
  http://www.kevinbeason.com/smallpt/

  The code is based in particular on the slides by David Cline.

  Some differences:

  - For optimization purposes, the code considers there is
  only one light source (see the commented loop)
  - Russian roulette and tent filter are not implemented

  I spent quite some time pulling my hair over inconsistent
  behavior between Chrome and Firefox, Angle and native. I
  expect many GLSL related bugs to be lurking, on top of
  implementation errors. Please Let me know if you find any.

  --
  Zavie

}

function TFastSmallPT.rand: float;
begin
  Result := fract(system.sin(seed) * 43758.5453123);
  seed   := seed + 1;
end;

function TFastSmallPT.intersect(s: Sphere; const r: Ray): float;
var
  op     : vec3;
  t      : float;
  epsilon: float;
  b      : float;
  det    : float;

begin
  op := s.p - r.o;

  epsilon := 1E-3;
  b       := dot(op, r.d);
  det     := b * b - dot(op, op) + s.r * s.r;
  if det < 0 then
    Exit(0)
  else
    det := system.sqrt(det);

  t := b - det;
  if t > epsilon then
    Exit(t)
  else
  begin
    t := b + det;
    if t > epsilon then
      Exit(t)
    else
      Exit(0)
  end;

end;

function TFastSmallPT.intersect(const r: Ray; out t: float; out s: Sphere; avoid: int): int;
var
  id: int;
  i : integer; // loop variable
  Sp: Sphere;
  d : float;

begin
  id    := -1;
  t     := 1E5;
  s     := spheres[0];
  for i := 0 to NUM_SPHERES - 1 do
  begin
    Sp := spheres[i];
    d  := intersect(s, r);
    if (i <> avoid) and (d <> 0) and (d < t) then
    begin
      t  := d;
      id := i;
      s  := Sp;
    end;

  end;

  Exit(id);
end;

function TFastSmallPT.jitter(const d: vec3; phi, sina, cosa: float): vec3;
var
  w: vec3;
  u: vec3;
  v: vec3;

begin
  w := normalize(d);
  u := normalize(cross(w.yzx, w));
  v := cross(w, u);
  Exit((u * cos(phi) + v * sin(phi)) * sina + w * cosa);
end;

function TFastSmallPT.radiance(r: Ray): vec3;
var
  acc      : vec3;
  mask     : vec3;
  id       : int;
  depth    : integer; // loop variable
  t        : float;
  obj      : Sphere;
  x        : vec3;
  n        : vec3;
  nt       : float;
  nl       : vec3;
  r2       : float;
  d        : vec3;
  e        : vec3;
  s        : Sphere;
  i        : int;
  l0       : vec3;
  cos_a_max: float;
  cosa     : float;
  l        : vec3;
  omega    : float;
  EE       : float;
  a        : float;
  ddn      : float;
  nc       : float;
  nnt      : float;
  cos2t    : float;
  tdir     : vec3;
  R0       : float;
  c        : float;
  Re       : float;
  p        : float;
  RP       : float;
  TP       : float;
  itrs     : int;
  rrr      : Ray;

begin
  acc       := vec3Black;
  mask      := vec3White;
  id        := -1;
  for depth := 0 to MAXDEPTH - 1 do
  begin
    id := intersect(r, t, obj, id);
    if id < 0 then
      break;

    x  := t * r.d + r.o;
    n  := normalize(x - obj.p);
    nl := n * sign(-dot(n, r.d));

    if obj.refl = DIFF then
    begin
      r2 := rand();
      d  := jitter(nl, 2 * PI * rand(), system.sqrt(r2), system.sqrt(1 - r2));
      e  := vec3Black;

      begin
        s         := lightSourceVolume;
        i         := 8;
        l0        := s.p - x;
        cos_a_max := system.sqrt(1 - clamp(s.r * s.r / dot(l0, l0)));
        cosa      := mix(cos_a_max, 1, 0.5);
        l         := jitter(l0, PI, system.sqrt(1 - cosa * cosa), cosa);
        rrr.o     := x;
        rrr.d     := l;
        itrs      := intersect(rrr, t, s, id);
        if itrs = i then
        begin
          omega := 2 * PI * (1 - cos_a_max);
          e     := e + ((s.e * clamp(dot(l, n), 0, 1) * omega) / PI);
        end;

      end;

      EE   := 1;
      acc  := acc + (mask * obj.e * EE + mask * obj.c * e);
      mask := mask * (obj.c);
      r.o  := x;
      r.d  := d;
    end
    else if obj.refl = SPEC then
    begin
      acc  := acc + (mask * obj.e);
      mask := mask * (obj.c);
      r.o  := x;
      r.d  := reflect(r.d, n);
    end
    else
    begin
      a     := dot(n, r.d);
      ddn   := abs(a);
      nc    := 1;
      nt    := 1.5;
      nnt   := mix(nc / nt, nt / nc, ifthen(a > 0, 1, 0));
      cos2t := 1 - nnt * nnt * (1 - ddn * ddn);
      r.o   := x;
      r.d   := reflect(r.d, n);
      if cos2t > 0 then
      begin
        tdir := normalize(r.d * nnt + Math.sign(a) * n * (ddn * nnt + system.sqrt(cos2t)));
        R0   := (nt - nc) * (nt - nc) / ((nt + nc) * (nt + nc));
        c    := 1 - mix(ddn, dot(tdir, n), integer(a > 0));
        Re   := R0 + (1 - R0) * c * c * c * c * c;
        p    := 0.25 + 0.5 * Re;
        RP   := Re / p;
        TP   := (1 - Re) / (1 - p);
        if (rand()<P) then
          mask := mask * RP
        else
        begin
          mask := mask * (obj.c * TP);
          r.o  := x;
          r.d  := tdir;
        end;
      end;

    end;

  end;

  Exit(acc);
end;

function TFastSmallPT.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv    : Vec2;
  m     : Vec2;
  camPos: vec3;
  cz    : vec3;
  cx    : vec3;
  cy    : vec3;
  color : vec3;
  i     : integer;
  r     : Ray; // loop variable

begin
  seed := iGlobalTime + resolution.y * gl_FragCoord.x / resolution.x + gl_FragCoord.y / resolution.y;
  uv   := 2 * gl_FragCoord.xy / resolution.xy - 1;
  if (iMouse.x = 0) and (iMouse.y = 0) then
    m := 5 * resolution.xy
  else
    m    := iMouse.xy;
  camPos := vec3.Create((2 * m / resolution.xy - 1) * vec2_10 + vec2_9, 169);
  cz     := normalize(vec3_11 - camPos);
  cx     := vec3_12;
  cy     := normalize(cross(cx, cz));
  cx     := cross(cz, cy);
  color  := vec3Black;
  for i  := 0 to SAMPLES - 1 do
  begin
    r.o   := camPos;
    r.d   := normalize(0.53135 * (resolution.x / resolution.y * uv.x * cx + uv.y * cy) + cz);
    color := color + radiance(r);
  end;
  Result := TColor32(pow(clamp(color / SAMPLES, 0, 1), vec3(1 / 2.2)));
end;

constructor Sphere.Create(_r: float; _p, _e, _c: vec3; _refl: int);
begin
  r    := _r;
  p    := _p;
  e    := _e;
  c    := _c;
  refl := _refl;

end;

initialization

FastSmallPT := TFastSmallPT.Create;
Shaders.Add('FastSmallPT', FastSmallPT);

finalization

FreeandNil(FastSmallPT);

end.
