unit WvN.DelphiShader.FX.AntonalogMBlur;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // https://www.shadertoy.com/view/4slGzl
  // Shadertoy
  // Browse New Shader Sign In
  // Antonalog's Motion Blur
  // Tags: raytracing, motionblurshare this shader  947     20    6 Uploaded by TekF in 2013-Aug-20Antonalog's "Lame" motion blurred ray-tracer, with a small change to make the blur look smoother.


  TAntonalogMBlur = class(TShader)
  const
    N_SPHERE        = 12;
    vec3_1: vec3    = (x: 0; y: 0; z: 5);
    vec3_2: vec3    = (x: 0.2; y: 0.1; z: 0.1);
    vec2_3: vec2    = (x: 0.1; y: 0);
    vec2_4: vec2    = (x: 0.1; y: 0.1);
    vec3_5: vec3    = (x: 0; y: 0; z: 0);
    vec2_6: vec2    = (x: 12.9898; y: 78.233);
    vec2_7: vec2    = (x: 0.5; y: 0.5);
    iterations = 4;
    vec3_10: vec3   = (x: 1; y: 0; z: 0);

  var
    L: vec3;
    DotL:Float;
    CC          : array [0 .. N_SPHERE - 1] of vec3;
    SS          : array [0 .. N_SPHERE - 1] of vec4;
    AA          : array [0 .. N_SPHERE - 1] of vec3;
    DotAA       : array [0 .. N_SPHERE - 1] of float;
    R2          : array [0 .. N_SPHERE - 1] of float;
    R2_2        : array [0 .. N_SPHERE - 1] of float;

    constructor Create; override;
    procedure PrepareFrame;
    function Q(a, b, c: float): float;
    function Lit(const N, V, H: vec3): float;
    function trace(const P, aV, H: vec3): vec3;
    function main(var gl_FragCoord: vec2): TColor32;
  end;

var
  AntonalogMBlur: TShader;

implementation

uses SysUtils, Math;

constructor TAntonalogMBlur.Create;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := main;
  L         := normalize(vec3.Create(-2, -1, 1));
  DotL := Dot(L,L);
end;

procedure TAntonalogMBlur.PrepareFrame;
var
  RR,II,tm : float;
  aTime: float;
  t2:float;
  a:vec3;
  i:Integer;
  gb          : vec2;
begin
  aTime   := iGlobalTime;
  t2      := system.sin(aTime * 0.1) * 40;
  aTime   := aTime + (system.sin(aTime) * 0.9);
  gb      := vec2_3;

  for i   := 0 to N_SPHERE - 1 do
  begin
    II    := i * (1 / N_SPHERE);
    tm    := II * 2 * 3.1415927 + aTime;
    a     := vec3.Create(
               system.sin(tm + t2),
               system.sin(tm * 3) * 0.4,
               system.cos(tm + t2));
    RR    := (1 - II) * 0.33 + 0.1;
    SS[i] := vec4.Create(a, RR);
    CC[i] := vec3.Create(0, gb);
    gb    := vec2_4 - gb;

    AA[i]    := SS[i].xyz;
    DotAA[i] := Dot(AA[i],AA[i]);
    R2[i]   := SS[i].w;
    R2_2[i] := R2[i]*R2[i];
  end;
end;

function TAntonalogMBlur.Q(a, b, c: float): float;
var
  d, oo2a: float;
begin
  d := b * b - 4 * a * c;
  if d < 0 then
    Exit(-1);
  d    := system.sqrt(d);
  oo2a := 0.5 / a;
  Exit(Math.Min((-b - d) * oo2a, (-b + d) * oo2a));
end;

function TAntonalogMBlur.Lit(const N, V, H: vec3): float;
var
  d, s: float;
begin
  d := Math.Max(dot(N, L), 0) * 0.5;
  s := pow(Math.Max(dot(N, H), 0), 1000) * 8;

  Exit(d + s);
end;

function TAntonalogMBlur.trace(const P, aV, H: vec3): vec3;
var
  A2, E: vec3;
  N, NN       : vec3;
  R  : float;
  Rcol, Ref,nRef : vec3;
  T, TT       : float;
  V, x, XX    : vec3;
  b           : float;
  blocked     : boolean;
  c           : vec3;
  i, j        : int;
  nearest,
  nearestR    : float;

  m,DotXX,DotXXV,DotXXVn: float;


begin
  c       := vec3_2;

  nearest := 1E10;

  E       := aV;

  for i   := 0 to N_SPHERE - 1 do
  begin
    TT    := Q(dot(aV, aV), 2 * (dot(P, aV) - (dot(AA[i], aV))), dotAA[i] + dot(P, P) - R2_2[i] - (2 * (dot(AA[i], P))));
    if TT > 0 then
    begin
      if TT < nearest then
      begin
        XX       := P + TT * aV;
        DotXX    := Dot(XX,XX);
        DotXXV   := dot(XX, L);
        DotXXVn  := dot(XX, nRef);
        NN       := normalize(XX - AA[i]);

        Ref      := reflect(aV, NN);
        nRef     := normalize(Ref);

        nearestR := 1E10;
        Rcol     := vec3_5;
        blocked  := false;

        for j := 0 to N_SPHERE - 1 do
        begin
          if i <> j then
          begin
            A2        := SS[j].xyz;
            R         := SS[j].w;
            V         := L;

            m := Dot(A2,A2) + DotXX - R * R - (2 * (dot(A2, XX)));

            T         := Q(DotL, 2 * (DotXXV - (dot(A2, V))), m);
            if T > 0 then
              blocked := true;

            V         := nRef;
            T         := Q(DotL, 2 * (DotXXVn - (dot(A2, V))), m);
            if T > 0 then
            begin
              if T < nearestR then
              begin
                x        := XX + T * V;
                N        := normalize(x - A2);

                nearestR := T;
                Rcol     := CC[j] + Lit(N, E, H);
                Rcol     := Rcol * (0.5 / (1 + T * T));
              end;
            end;
          end;
        end;

        if blocked then
          b := 0
        else
          b := Lit(NN, aV, H); // d+s;

        nearest := TT;

        c := vec3.Create(b) + CC[i] + Rcol;
      end;
    end;
  end;

  Result := c;
end;


function TAntonalogMBlur.main(var gl_FragCoord: vec2): TColor32;
  procedure sampleCamera(const u: vec2; out rayOrigin, rayDir: vec3);
  var
    filmUv    : vec2;
    tx, ty, tz: float;
  begin
    filmUv    := (gl_FragCoord.xy + u) / resolution.xy;

    tx        := (2 * filmUv.x - 1) * (resolution.x / resolution.y);
    ty        := (1 - 2 * filmUv.y);
    tz        := 0;

    rayOrigin := vec3_1;
    rayDir    := normalize(vec3.Create(tx, ty, tz) - rayOrigin);
  end;

var
  HH, PP, VV, c3: vec3;
  delta         : float;
  ditheruv      : vec2;
  divider       : float;
  i             : int;
  // P,
  spread, T  : float;
begin

  sampleCamera(vec2_7, PP, VV);
  HH       := normalize(L - VV);
  c3       := vec3Black;
  ditheruv := floor(gl_FragCoord.xy) + vec2Gray;
//  P        := fract(iGlobalTime) * 123.789 + gl_FragCoord.y * resolution.x + gl_FragCoord.x;
  spread   := 1 / 2;
  divider  := gl_FragCoord.x - iMouse.x;

  T        := texture2D(tex[0], ditheruv / 256, -100).x * spread / iterations;
  delta    := spread / iterations;

  if divider < 0 then
  begin
    T     := spread * 0.5;
    delta := 0; // disable motion blur
  end;

  for i := 0 to iterations - 1 do
  begin
    c3  := c3 + trace(PP, VV, HH);
    T   := T + delta;
  end;

  c3 := c3 / iterations;

  if system.abs(divider) <= 1 then
    c3 := vec3_10;

  Result := TColor32(c3);
end;

initialization

AntonalogMBlur := TAntonalogMBlur.Create;
Shaders.Add('AntonalogMBlur', AntonalogMBlur);

finalization

FreeandNil(AntonalogMBlur);

end.
