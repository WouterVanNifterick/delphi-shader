unit WvN.DelphiShader.FX.GlowingGrid;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TGlowingGrid = class(TShader)
  const
    rpm = 1;
    MIN_DIST=0.005;
    eps=0.001;
    background: vec3 = (x: 0.1; y: 0.1; z: 0.7);
    light_1: vec3    = (x: 4.0; y: 8.0; z: 3.0);
    light_2: vec3    = (x: - 4.0; y: 8.0; z: - 7.0);
//    eps: vec2        = (x: 0.001; y: 0.0);
    eps100:vec3 = (x: eps; y: 0; z: 0);
    eps010:vec3 = (x: 0; y: eps; z: 0);
    eps001:vec3 = (x: 0; y: 0; z: eps);

    maxSteps         = 64;

    vec3_1: vec3  = (x: 0.1; y: 0.1; z: 0.7);
    vec3_2: vec3  = (x: 4; y: 8; z: 3);
    vec3_3: vec3  = (x: - 4; y: 8; z: - 7);
    vec2_4: vec2  = (x: 0.001; y: 0);
    vec3_5: vec3  = (x: 0.5; y: 0.5; z: - 3);
    vec3_6: vec3  = (x: 0.5; y: 0.5; z: 0.5);
    vec3_7: vec3  = (x: 0; y: 0; z: - 3.5);
    vec3_8: vec3  = (x: 0; y: 1; z: 0);
    vec3_9: vec3  = (x: 0; y: 0; z: 0);
    vec3_10: vec3 = (x: 0.35; y: 0.05; z: 0);
    vec3_11: vec3 = (x: 0.8; y: 0.8; z: 0.8);

  var
    t                            : float;
    tv, pp,
    ta, ro, cw,cp, cu, cv:vec3;
//    time: float;

    constructor Create; override;
    procedure PrepareFrame;
    function shade(const color, point, normal, rd: vec3): vec3;
    function distanceEstimator(p: vec3): float;
    function mainImage(var fragCoord: vec2): TColor32;
  end;

var
  GlowingGrid: TShader;

implementation

uses SysUtils, Math;

constructor TGlowingGrid.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;

procedure TGlowingGrid.PrepareFrame;
begin
  t        := &mod(time, 70);
  tv := vec3.Create(t, t * 0.5, t * 0.3);

  // camera setup taken from iq's raymarching box: https://www.shadertoy.com/view/Xds3zN
  ta  := vec3_7;
  ro  := vec3.Create(-0.5 + 3.2 * cosLarge(0.1 * time + 6), 3, 0.5 + 3.2 * sinLarge(0.1 * time + 6));
  cw  := normalize(ta - ro);
  cp  := vec3_8;
  cu  := normalize(cross(cw, cp));
  cv  := normalize(cross(cu, cw));

  pp := vec3.Create(rpm * 1.6, rpm, rpm);
end;

function TGlowingGrid.shade(const color, point, normal, rd: vec3): vec3;
var
  dtl              : vec3;
  diffuse, specular: float;
  c                : vec3;
begin
  dtl      := normalize(light_1 - point);
  diffuse  := dot(dtl, normal);
  specular := 0.75 * pow(Math.max(dot(reflect(dtl, normal), rd), 0), 64);
  c        := (diffuse + specular) * color * 0.85;
  dtl      := normalize(light_2 - point);
  diffuse  := dot(dtl, normal); // more diffuse
  specular := 0.9 * pow(Math.max(dot(reflect(dtl, normal), rd), 0), 128); // more specular
  Exit(clamp(c + (diffuse + specular) * 0.25 * color, 0, 1));
end;

// estimates the distance from Point p to implicit given geometry

function TGlowingGrid.distanceEstimator(p: vec3): float;
var
  holeP                        : vec3;
  repeater                     : vec3;
  sphere, cylinder, grid, eater: float;
begin
  holeP    := p - vec3_5;
  p        := p - tv ;
  repeater := &mod(p, pp) - 0.5 * vec3.Create(rpm * 1.6, rpm, rpm);
  repeater := fract(p) - vec3_6;
  sphere   := length(repeater) - 0.06 * rpm;
  cylinder := length(repeater.xz) - 0.015 * rpm;
  cylinder := min(cylinder, length(repeater.zy) - 0.015 * rpm);
  cylinder := min(cylinder, length(repeater.xy) - 0.015 * rpm);
  grid     := Math.min(cylinder, sphere);
  // just a big sphere, everything outside the sphere is not shown
  eater := length(holeP) - 3.3;
  Exit(Math.max(grid, eater));
end;

function TGlowingGrid.mainImage(var fragCoord: vec2): TColor32;
var
  ratio              : float;
  fragment, uv       : vec2;
  rd, col: vec3;
  t                  : float;
  p                  : vec3;
  steps, addAll      : float;
  i                  : int;
  distanceEstimation : float;
  c                  : vec3;
  normal             : vec3;
  glow               : float;
begin
  ratio    := resolution.x / resolution.y;
  fragment := fragCoord.xy / resolution.xy;
  uv       := -1 + 2 * fragment;
  uv.x     := uv.x * (ratio);

  rd  := normalize(uv.x * cu + uv.y * cv + 2.5 * cw);

  col := background;
  t   := 0;
  p   := vec3_9;
  // march
  steps  := 0;
  addAll := 0;
  for i  := 0 to maxSteps - 1 do
  begin
    p   := ro + t * rd;
    distanceEstimation := distanceEstimator(p);

    if distanceEstimation > MIN_DIST then
    begin
      t      := t + distanceEstimation;
      addAll := addAll + smoothstep(0, 1, distanceEstimation);
      steps  := steps + 1;
    end
    else
      break;
  end;

  // c  := i / maxSteps;
  // c  := pow(c, 0.25);
  // col   := vec4.Create(c,c,c,1.0);
  c      := vec3_10; // (cos(p * 0.5) + 1.0) / 2.0;
  normal.x := distanceEstimator(p + eps100) - distanceEstimator(p - eps100);
  normal.y := distanceEstimator(p + eps010) - distanceEstimator(p - eps010);
  normal.z := distanceEstimator(p + eps001) - distanceEstimator(p - eps001);
  normal.NormalizeSelf;
  col    := shade(c, p, normal, rd);
  col    := mix(col, background, steps / maxSteps);
  col    := pow(col, vec3_11);
  glow   := smoothstep(steps, 0, addAll) * 1.4;
  col    := vec3(glow) * col;
  Result := TColor32(col);
end;

initialization

GlowingGrid := TGlowingGrid.Create;
Shaders.Add('GlowingGrid', GlowingGrid);

finalization

FreeandNil(GlowingGrid);

end.
