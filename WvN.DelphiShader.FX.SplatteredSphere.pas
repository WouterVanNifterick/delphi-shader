unit WvN.DelphiShader.FX.SplatteredSphere;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TSplatteredSphere = class(TShader)
  var
    rot,M,M2: Mat3;
    san,can:float;

  const
    MAGIC_BOX_MAGIC = 0.56;
    vec3_1: vec3    = (x: 0.6; y: 0.3; z: 0.4);
    vec4_2: vec4    = (x: 0.3; y: 1; z: 0.3; w: 1);
    vec3_3: vec3    = (x: - 1; y: 1; z: 1);
    vec3_4: vec3    = (x: 0; y: 0; z: 0);

    constructor Create; override;
    procedure PrepareFrame;
    function magicBox(p: vec3): float;
    function mainImage(var fragCoord: vec2): TColor32;
  end;

var
  SplatteredSphere: TShader;

implementation

uses SysUtils, Math;

constructor TSplatteredSphere.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;

  // A random 3x3 unitary matrix, used to avoid artifacts from slicing the
  // volume along the same axes as the fractal's bounding box.
  M := Mat3.Create(
          vec3.create( 0.28862355854826727,
                       0.6997227302779844,
                       0.6535170557707412),
          vec3.create( 0.06997493955670424,
                       0.6653237235314099,
                      -0.7432683571499161),
          vec3.create(-0.9548821651308448,
                       0.26025457467376617,
                       0.14306504491456504)
          );
end;

procedure TSplatteredSphere.PrepareFrame;
begin
  san := sinLarge(iGlobalTime);
  can := CosLarge(iGlobalTime);
  rot       := Mat3.Create(-san, 0, can, 0, 1, 0, can, 0, san);
  M2        := M * rot;
end;

function TSplatteredSphere.magicBox(p: vec3): float;
var
  tot, L, L2: float;
  i         : integer;

begin
  // The fractal lives in a 1x1x1 box with mirrors on all sides.
  // Take p anywhere in space and calculate the corresponding position
  // inside the box, 0<(x,y,z)<1
  p   := 1 - abs(1 - &mod(p, 2));
  tot := 0;
  L   := length(p);

  // This is the fractal.  More iterations gives a more detailed
  // fractal at the expense of more computation.
  for i := 0 to 10 do
  begin
    p   := abs(p) / (L * L) - MAGIC_BOX_MAGIC;
    L2  := length(p);
    tot := tot + (abs(L2 - L));
    L   := L2;
  end;
  Result := tot;
end;

function TSplatteredSphere.mainImage(var fragCoord: vec2): TColor32;
var
  uv       : vec2;
  sph      : vec3;
  q, a     : float;
  fragColor: vec4;
begin
  uv        := 2 * (fragCoord.xy - 0.5 * resolution.xy) / resolution.yy;
  sph       := vec3.Create(uv.x, uv.y, sqrts(1 - dot(uv, uv)));
  q         := magicBox(vec3_1 + 0.2 * M2 * sph);
  a         := 1 - smoothstep(14, 16, q);
  fragColor := vec4.Create(vec3.Create(a), 1) * (vec4_2 * (0.3 + 0.7 * dot(sph, normalize(vec3_3))));
  if dot(uv, uv) > 1 then
    fragColor := vec4.Create(vec3_4, 1);
  Result      := TColor32(fragColor);
end;

initialization

SplatteredSphere := TSplatteredSphere.Create;
Shaders.Add('SplatteredSphere', SplatteredSphere);

finalization

FreeandNil(SplatteredSphere);

end.
