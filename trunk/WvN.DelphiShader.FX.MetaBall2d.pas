unit WvN.DelphiShader.FX.MetaBall2d;

interface

uses GR32, Types, WvN.DelphiShader.Shader, Math;

type

  METABALL = record
    pos: vec2;
    size: float;
  end;

  TMetaBall2d = class(TShader)
  const
    vec3_1: vec3 = (x: 0.3; y: 0.3; z: 0.3);
    vec3_2: vec3 = (x: 0.9; y: - 0.9; z: 1);
    vec3_3: vec3 = (x: 0; y: 1; z: 0.3);
  var
    fbm : array[0..7] of METABALL;
    ratio:double;
    light: vec3;
    h    : vec3;
    function rand1(x: float): float;
    function noise1(x: float): float;
    function fbm1(x: float): float;
    function field(const pos: vec2): float;
    function height(const pos: vec2): float;inline;
    function normal_and_height(const pos: vec2): vec4;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  MetaBall2d: TShader;

implementation

uses SysUtils;

constructor TMetaBall2d.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;

  light := normalize(vec3_2);        // light direction
end;

procedure TMetaBall2d.PrepareFrame;
var
  i  : integer;
  x  : float;
begin
  Ratio := (resolution.x / resolution.y);
  h := vec3.Create(1 / resolution.xy, 0);

  for i := 0 to 7 do
  begin
    x := i * 0.5 + iGlobalTime - 68;
    fbm[I].pos.x := fbm1(x)*1.5;
    fbm[I].pos.y := fbm1(x+10) * 1.5;
    fbm[I].size := fbm1(x + 20) * 0.1 + 0.1;
  end;
end;


// by srtuss, 2013

function TMetaBall2d.rand1(x: float): float;
begin
  Result := fract(system.sin(x) * 4358.5453123);
end;

function TMetaBall2d.noise1(x: float): float;
var
  fl: float;
  fc: float;
begin
  fl := Math.floor(x);
  fc := fract(x);
  Result := mix(rand1(fl), rand1(fl + 1), smoothstep(0, 1, fc)) * 2 - 1;
end;

function TMetaBall2d.fbm1(x: float): float;
begin
  Result := noise1(x) * 0.5 + noise1(x * 2) * 0.25;
end;

// calculate a field of metaballs
function TMetaBall2d.field(const pos: vec2): float;
var
  v  : float;
  i  : integer;
  p : vec2;
begin
  v     := 0;
  for i := 0 to 7 do
  begin
    // classic metaball term
    p := pos - Self.fbm[i].pos;
    v := v + fbm[i].size / dot(p, p);
  end;
  Exit(v);
end;

// calculate proper metaball height
function TMetaBall2d.height(const pos: vec2): float;
const
  treshold = 2;
begin
  // we need to get rid of the pole in the field function.
  // by taking the reciproc of the intensity, we end up with some
  // sort of quadratic function. we could now flatten or sharpen    /
  // this using a pow(), but i think the result is great already.
  Result := 1 - 1 / math.max(field(pos) - treshold, 0.01);

  // maybe add some bump mapping
  // h  := //h  + (texture2D(iChannel1, pos.xy * 1.0).y * 0.06);
end;

// fetch field normal and height
function TMetaBall2d.normal_and_height(const pos: vec2): vec4;
var
  c    : float;
  delta: vec3;
const
  treshold=2;
begin
  c := height(pos);

  // evaluate the gradient
  delta.x := (height(pos + h.xz) - c) / h.x;
  delta.y := (height(pos + h.zy) - c) / h.y;
  delta.z := 2; // this controls the peak size of the metaballs

  Result := vec4.Create(normalize(delta), c);
end;

function TMetaBall2d.Main(var gl_FragCoord: vec2): TColor32;
var
  uv   : vec2;
  nh   : vec4;
  bgCol: vec3;
  alpha: float;
  ref  : vec3;
  diff : float;
  spec : float;
  cube : vec3;
  brd  : float;
  col  : vec3;
begin

  uv   := (gl_FragCoord.xy / resolution.xy)* 2 - 1;
  uv.x := uv.x * ratio;
  nh   := normal_and_height(uv);

  bgCol := vec3_1;

  if nh.w < 0 then
    Exit(TColor32(bgCol));

  alpha := smoothstep(0, 0.3, nh.w); // smooth border
  ref   := reflect(normalize(vec3.Create(uv, -1)), nh.xyz); // reflected light vector
  diff  := dot(nh.xyz, light) * 0.6 + 0.4; // diffuse light term
  spec  := Math.max(dot(ref, light), 0);   // specular light term
  spec  := pow(spec, 8);
  cube  := textureCube(TShader.cubes[1], ref).xyz*16; // cubemap to simulate complex reflections (optional)
  brd   := 1 - exp(-4 * nh.w);         // an ambient occulsion'ish black border

  // combine colors
  col := vec3_3 * (diff + spec + cube * 0.05) * brd;

  Result := TColor32(mix(bgCol, col, alpha));
end;

initialization

MetaBall2d := TMetaBall2d.Create;
Shaders.Add('MetaBall2d', MetaBall2d);

finalization

FreeandNil(MetaBall2d);

end.
