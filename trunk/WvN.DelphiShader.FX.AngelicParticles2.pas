unit WvN.DelphiShader.FX.AngelicParticles2;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TAngelicParticles2 = class(TShader)
  const
    STEPS        = 60;
    vec3_2: vec3 = (x: 0.9; y: 0.3; z: 0.1);
    vec3_3: vec3 = (x: 1.2; y: 1.2; z: 1.2);

    function rotate(const p: vec2; a: float): vec2;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  AngelicParticles2: TShader;

implementation

uses SysUtils, Math;

constructor TAngelicParticles2.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TAngelicParticles2.PrepareFrame;
begin
  // by srtuss, 2013
  // did some research on kali's "comsos" and came up with this.
  // as always, not optimized, just pretty :)
  //
  // name & inspiration was taken from here:
  // http://www.youtube.com/watch?v=BzQmeeXcDwQ

end;

function TAngelicParticles2.rotate(const p: vec2; a: float): vec2;
var sa,ca:double;
begin
  sa := system.Sin(a);
  ca := system.Cos(a);
  Result := vec2.Create(
               p.x * ca - p.y * sa,
               p.x * sa + p.y * ca
  );
end;

function TAngelicParticles2.Main(var gl_FragCoord: vec2): TColor32;
var
  uv  : vec2;
  v   : float;
  ray : vec3;
  dir : vec3;
  inc : float;
  acc : vec3;
  i, j: integer;
  p   : vec3;
  it  : float;
  br  : float;
  col : vec3;

begin
  uv   := gl_FragCoord.xy / resolution.xy;
  uv   := uv * 2 - 1;
  uv.x := uv.x * (resolution.x / resolution.y);

  v := 0;

  ray := vec3.Create(system.sin(iGlobalTime * 0.1) * 0.2, system.cos(iGlobalTime * 0.13) * 0.2, 1.5);
  dir := normalize(vec3.Create(uv, 1));

  ray.z  := ray.z + (iGlobalTime * 0.1 - 20);
  dir.xz := rotate(dir.xz, system.sin(iGlobalTime * 0.1) * 2);
  dir.xy := rotate(dir.xy, iGlobalTime * 0.2);

  // very little steps for the sake of a good framerate

  inc := 0.35 / STEPS;

  acc := vec3Black;

  for i := 0 to STEPS - 1 do
  begin
    p := ray * 0.1;

    // fractal from "cosmos"
    for j := 0 to 13 do
      p   := abs(p) / dot(p, p) * 2 - 1;

    it := 0.001 * length(p * p);
    v  := v + it;

    // cheap coloring
    acc := acc + system.sqrt(it) * texture2D(tex[8], ray.xy * 0.1 + ray.z * 0.1).rgb;

    ray := ray + dir * inc;
  end;

  br     := pow(v * 4, 3) * 0.1;
  col    := pow(acc * 0.5, vec3_3) + br;
  Result := TColor32(col);
end;

initialization

AngelicParticles2 := TAngelicParticles2.Create;
Shaders.Add('AngelicParticles2', AngelicParticles2);

finalization

FreeandNil(AngelicParticles2);

end.
