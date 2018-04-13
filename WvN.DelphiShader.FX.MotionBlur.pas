unit WvN.DelphiShader.FX.MotionBlur;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // https://www.shadertoy.com/view/MsBGDW

  TMotionBlur = class(TShader)
  public const
    maxDist       = 1E5;
    epsilon       = 0.001;
    mblur_count   = 3; // How many motion blur rays we trace.
    bounce_count  = 3; // How many scene rays we trace.
    exposureTime  = 1.0 / 15.0;

    vec3_1: vec3  = (x: 0.5; y: 0.8; z: 1);
    vec3_2: vec3  = (x: 1; y: 0.8; z: 1);
    vec3_3: vec3  = (x: 0.5; y: 0.8; z: 0.5);
    vec3_4: vec3  = (x: 2; y: 1.6; z: 1);
    vec3_5: vec3  = (x: 0.5; y: 0.6; z: 0.7);
    vec3_6: vec3  = (x: 0; y: 1; z: 0);
    vec3_7: vec3  = (x: 0; y: 1; z: 0);
    vec3_8: vec3  = (x: 0; y: 0; z: 0);
    vec3_9: vec3  = (x: 0; y: 0; z: - 6);
    vec3_10: vec3 = (x: 1; y: 1; z: 1);

    function sphere(const ray, dir, center: vec3; radius: float; const color: vec3; out nml, mat: vec3; closestHit: float): float;
    function scene(t: float; const ro, rd: vec3; out nml, mat: vec3; dist: float): float;
    function background(t: float; const rd: vec3): vec3;
    function Main(var gl_FragCoord: Vec2): TColor32;

  var
    res: Vec2;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  MotionBlur: TShader;

implementation

uses SysUtils, Math;

constructor TMotionBlur.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

function TMotionBlur.sphere(const ray, dir, center: vec3; radius: float; const color: vec3; out nml, mat: vec3; closestHit: float): float;
var
  rc: vec3;
  c : float;
  b : float;
  d : float;
  t : float;
  st: float;

begin
  rc := ray - center;
  c  := dot(rc, rc) - (radius * radius);
  b  := dot(dir, rc);
  d  := b * b - c;

  if d <= 0 then
    t        := -b
  else
    t        := -b - system.sqrt(d);

  st         := step(0, Math.min(t, d)) * step(t, closestHit);
  closestHit := mix(closestHit, t, st);
  nml        := mix(nml, (center - (ray + dir * t)) / radius, st);
  mat        := mix(mat, color, st);
  Exit(closestHit);
end;

function TMotionBlur.scene(t: float; const ro, rd: vec3; out nml, mat: vec3; dist: float): float;
begin
  dist := sphere(ro, rd, vec3.Create(0), 1, vec3_1, nml, mat, dist);
  dist := sphere(ro, rd, vec3.Create(system.sin(t * 3) * 3, system.cos(t * 3) * 3, system.cos(t) * 8), 1.5, vec3_2, nml, mat, dist);
  dist := sphere(ro, rd, vec3.Create(system.sin(t * 3) * -3, system.cos(t * 3) * -3, system.sin(t) * 8), 1.5, vec3_3, nml, mat, dist);
  Exit(dist);
end;

function TMotionBlur.background(t: float; const rd: vec3): vec3;
var
  sunColor: vec3;
  skyColor: vec3;
  sunDir  : vec3;

begin
  sunColor := vec3_4;
  skyColor := vec3_5;
  sunDir   := normalize(vec3.Create(system.sin(t), system.sin(t * 1.2), system.cos(t)));

  Exit(pow(Math.max(0, dot(sunDir, rd)), 128) * sunColor + 0.2 * pow(Math.max(0, dot(sunDir, rd)), 2) * sunColor + pow(Math.max(0, -dot(vec3_7, rd)), 1) * (1 - skyColor) +
    pow(Math.max(0, dot(vec3_6, rd)), 1) * skyColor);
end;

procedure TMotionBlur.PrepareFrame;
begin
  res := Vec2.Create(resolution.x / resolution.y, 1);
end;

function TMotionBlur.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv      : Vec2;
  light   : vec3;
  tuv     : Vec2;
  j       : integer;
  rand    : float;
  t       : float;
  ro      : vec3;
  rd      : vec3;
  transmit: vec3;
  i       : integer;
  mat, nml: vec3;
  dist    : float;

begin
  uv         := (-1 + 2 * gl_FragCoord.xy / resolution.xy) * res;
  light      := vec3_8;
  tuv        := Vec2.Create(mblur_count, 1) * (gl_FragCoord.xy / 256);

  for j      := 0 to mblur_count - 1 do
  begin
    rand     := texture2D(tex[0], tuv + Vec2.Create((j) / 256, 0), -100).r;
    t        := iGlobalTime + exposureTime * ((j + 2 * (0.5 - rand)) / mblur_count);
    ro       := vec3_9;
    rd       := normalize(vec3.Create(uv, 1));
    transmit := vec3_10;

    for i    := 0 to bounce_count - 1 do
    begin
      dist   := scene(t, ro, rd, nml, mat, maxDist);
      if dist < maxDist then
      begin // Object hit.
        transmit := transmit * (mat);
        ro       := ro + (rd * dist);
        rd       := reflect(rd, nml); // Reflect the ray.
        // Move the ray off the surface to avoid hitting the same point twice.
        ro       := ro + (rd * epsilon);
      end
      else
      begin // Background hit.
        // Put the background light through the ray
        // and add it to the light seen by the eye.
        light := light + (transmit * background(t, rd));
        break; // Don't bounce off the background.
      end;

    end;

  end;

  light  := light / mblur_count;
  Result := TColor32(light);
end;

initialization

MotionBlur := TMotionBlur.Create;
Shaders.Add('MotionBlur', MotionBlur);

finalization

FreeandNil(MotionBlur);

end.
