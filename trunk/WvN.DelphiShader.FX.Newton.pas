unit WvN.DelphiShader.FX.Newton;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

const
  SPHERES      = 5;
  SkyColor: vec3 = (x: 0.3 * 1.75; y: 0.4 * 1.75; z: 0.8 * 1.75);
  vec3_2: vec3 = (x: 0.3; y: 0.35; z: 0.8);
  vec3_3: vec3 = (x: 2.5; y: 3; z: 0);
  vec3_4: vec3 = (x:1; y:2; z:0);
  vec3_5: vec3 = (x:0; y:1; z:0);
  vec3_6: vec3 = (x:0; y:3; z:10);

type

  TNewton = class(TShader)
    function environment(const dir: vec3): vec3;
    function traceSphere(const pos: vec3; const dir: vec3; const spos: vec3; const rr: float): float;
    function trace(pos: vec3; dir: vec3): vec4;
    function Main(var gl_FragCoord: Vec2): TColor32;

  var
    skyBottomColor: vec3;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Newton: TShader;

implementation

uses SysUtils, Math;

constructor TNewton.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TNewton.PrepareFrame;
begin
  skyBottomColor := SkyColor;
end;

(*
  * A scene from 'Den Tredje Bart' by Carl B (http://www.pouet.net/prod.php?which=54115)
  * Code by Kusma
  * Requires GL_OES_standard_derivatives to look good, but Google Chrome doesn't seem
  * to support it. Oh well.
  *
  * Any kind of mouse control and/or time-based animation seems to make ANGLE cry, so
  * I've removed it for now.
*)

(*
  No angle to suffer here, so I put some time-based animation in. Sorry if it
  makes your machine cry Kusma :D
  I should make the end balls follow an arc. But I should sleep too. Sleep wins.
  - psonice
*)

// const fwidth = (x) vec2(0.0001);

function TNewton.environment(const dir: vec3): vec3;
var
  bg: vec3;
begin
  bg := mix(skyBottomColor, vec3_2 * 0.8, pow(max(0.0, dir.y), 0.6));
  Exit(bg + pow(max(0.0, dot(dir, normalize(vec3_4))), 100.0) * vec3_3 * 0.5);
end;

function TNewton.traceSphere(const pos: vec3; const dir: vec3; const spos: vec3; const rr: float): float;
var
  dst: vec3;
  a  : float;
  b  : float;
  c  : float;
  d  : float;

begin
  dst := pos - spos;
  a   := dot(dst, dst);
  b   := dot(dst, dir);
  c   := a - rr;
  d   := b * b - c;

  if d > 0.0 then
    Exit(-b - system.sqrt(d))
  else
    Exit(-1.0);
end;

function TNewton.trace(pos: vec3; dir: vec3): vec4;
var
  spos        : array [0 .. SPHERES - 1] of vec3;
  i, j        : integer; // loop variables
  th          : float;
  mint        : float;
  sphereHit   : vec4;
  t           : float;
  totalt      : float;
  n           : vec3;
  newSphereHit: vec4;
  dist        : float;
  fw          : Vec2;
  fuzz        : Vec2;
  fuzzMax     : float;
  checkPos    : Vec2;
  pp          : Vec2;
  p           : float;
  ao          : float;
  c           : vec3;

begin

  for i := 0 to SPHERES - 1 do
  begin
    th := i * (2.0 * pi / SPHERES);
    // spos[i]  := Vec3.Create(sin(th + (time * .34))* 4.,0.0,cos(th + (time*.55)) * 4.);
    spos[i] := vec3.Create((i * 2) - 4, 0, 0);

    if i = 0 then
      spos[i] := spos[i] + (vec3.Create(Math.min(system.sin(time * 2), 0), -Math.min(system.sin(time * 2), 0), 0));

    if i = SPHERES - 1 then
      spos[i] := spos[i] + (vec3.Create(Math.max(system.sin(time * 2), 0), Math.max(system.sin(time * 2), 0), 0));
  end;

  mint      := 999999.0;
  sphereHit := vec4.Create(0.0);

  for i := 0 to SPHERES - 1 do
  begin
    t := traceSphere(pos, dir, spos[i], 1.0);
    if (t > 0) and (t < mint) then
    begin
      sphereHit := vec4.Create(spos[i], 1.0);
      mint      := t;
    end;
  end;

  totalt := 0.0;
  if sphereHit.w > 0 then
  begin
    pos    := pos + (dir * mint);
    totalt := totalt + (mint);
    n      := pos - sphereHit.xyz;
    dir    := reflect(dir, n);

    for i := 0 to 3 do
    begin
      mint         := 999999.0;
      newSphereHit := default(vec4);
      for j := 0 to SPHERES - 1 do
      begin
        if spos[j] = sphereHit.xyz then
          continue;

        t := traceSphere(pos, dir, spos[j], 1.0);
        if (t > 0.0) and (t < mint) then
        begin
          newSphereHit := vec4.Create(spos[j], 1.0);
          mint         := t;
        end;
      end;

      if newSphereHit.w <= 0.0 then
        break;

      pos       := pos + (dir * mint);
      totalt    := totalt + (mint);
      sphereHit := newSphereHit;
      n         := pos - sphereHit.xyz;
      dir       := reflect(dir, n);
    end;
  end;

  dist := 1.0;
  if dir.y = 0 then
    t := 0
  else
    t := -(pos.y + dist) / dir.y;

  // fw  := fwidth(pos.xz + dir.xz * vec2.create(t));
  fw := Vec2(0.0001);

  if (dir.y < 0) and (t > 0) then
  begin
    pos      := pos + (dir * t);
    totalt   := totalt + t;
    fuzz     := fw * 2;
    fuzzMax  := Math.max(fw.x, fw.y);
    checkPos := fract(pos.xz + fuzz * 0.5);
    pp       := smoothstep(Vec2.Create(0.5), Vec2.Create(0.5) + fuzz, checkPos) + (1.0 - smoothstep(Vec2.Create(0.0), fuzz, checkPos));
    p        := pp.x * pp.y + (1.0 - pp.x) * (1.0 - pp.y);
    p        := mix(p, 0.5, smoothstep(0.125, 0.5, fuzzMax));
    n        := vec3_5;
    ao       := 2;

    for i := 0 to SPHERES - 1 do
    begin
      ao := ao - (max(0, -normalize(pos - spos[i]).y) * pow(1 / distance(pos, spos[i]), 2) * ao);
    end;

    p := p * (ao * ao * ao);
    c := mix(skyBottomColor, vec3.Create(p, p, p), 1.0 / max(1, 0.75 + totalt * 0.035));
    Exit(vec4.Create(c, 1));
  end
  else
    Exit(vec4.Create(environment(dir), 1));
end;

function TNewton.Main;
var
  pos: vec3;
  dir: vec3;
begin
  pos    := vec3_6;
  dir    := normalize(vec3.Create((gl_FragCoord.xy - resolution.xx * 0.5) / resolution.yy, -1.0));
  Result := TColor32(sqrt(trace(pos, dir)) ); // fake sRGB conversion; assumes a gamma of 2.0
end;

initialization

Newton := TNewton.Create;
Shaders.Add('Newton', Newton);

finalization

FreeandNil(Newton);

end.
