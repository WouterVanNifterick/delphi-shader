unit WvN.DelphiShader.FX.AlienTech;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

// Alien Tech by Kali
// https://www.shadertoy.com/view/XdlGDj
// 2D fractal based on Mandelbox

type

  {$DEFINE SHOWLIGHT } // comment this line if you find the moving ligth annoying like Dave :D;

  TAlienTech = class(TShader)
  public const
    BLINKINGLIGHTS = 1;

    // change this to tweak the fractal
    c: Vec2 = (x: 2; y: 4.5);

    // other cool params (comment default then uncomment one of this):
    // #define c Vec2.Create(1.,5.)
    // #define c Vec2.Create(4.,.5)
    // #define c vec2(4.-length(p)*.2)
    // #define c Vec2.Create(abs(sin(p.y*2.)),5.) //love this one with blinking

    vec2_1: Vec2 = (x: 0; y: 0.003);
    vec3_2: vec3 = (x: 0; y: 0  ; z: 1  );
    vec3_3: vec3 = (x: 0; y: 0  ; z:-1  );
    vec3_4: vec3 = (x: 0; y: 0  ; z: 0  );
    vec3_5: vec3 = (x: 1; y: 0.9; z: 0.3);

    function formula(const _p: Vec2): float;
    function light(const p: Vec2; const col: vec3): vec3;
    function Main(var gl_FragCoord: Vec2): TColor32;

  var
    ti  : float;
    ldir: vec3;
    ot  : float;
    blur: float;
    texCoord :vec2;

    st,ct: double;
    aspect, pixsize:vec2;
    lightpos:vec3;
    procedure PrepareFrame;
    constructor Create; override;
  end;

var
  AlienTech: TShader;

implementation

uses SysUtils, Math;

constructor TAlienTech.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

function TAlienTech.formula(const _p: Vec2): float;
var
  t        : Vec2;
  l, expsmo: float;
  i        : integer;
  pl       : float;
  p        : Vec2;

begin
  t.Create(system.sin(ti * 0.3) * 0.1 + ti * 0.05, ti * 0.1);
  t  := t + (iMouse.xy / resolution.xy);
  p  := abs(0.5 - fract(_p * 0.4 + t)) * 1.3; // tiling
  ot := 1000;

  l      := 0;
  expsmo := 0;
  for i  := 0 to 11 do
  begin
    p := abs(p + c) - abs(p - c) - p;
    p := p / (clamp(dot(p, p), 0.0007, 1));
    p := p * -1.5 + c;
    if &mod(i, 2) < 1 then
    begin // exponential smoothing calc, with iteration skipping
      pl     := l;
      l      := length(p);
      expsmo := expsmo + (exp(-1 / abs(l - pl)));
      ot     := Math.min(ot, l);
    end;
  end;

  Exit(expsmo);
end;

function TAlienTech.light(const p: Vec2; const col: vec3): vec3;
var
  d           : Vec2;
  d1, d2      : float;
  n1, n2, n, r: vec3;
  diff, spec  : float;
begin
  // calculate normals based on horizontal and vertical vectors being z the formula result
  d  := vec2_1;
  d1 := formula(p - d.xy) - formula(p + d.xy);
  d2 := formula(p - d.yx) - formula(p + d.yx);
  n1.Create(0, d.y * 2, -d1 * 0.05);
  n2.Create(d.y * 2, 0, -d2 * 0.05);
  n  := cross(n1, n2);
  n.NormalizeSelf;

  // lighting
  diff := pow(Math.max(0, dot(ldir, n)), 2) + 0.2;
  r    := reflect(vec3_2, ldir);
  spec := pow(Math.max(0, dot(r, n)), 30);
  Exit(diff * col + spec * 0.8);
end;

procedure TAlienTech.PrepareFrame;
begin
  ti     := iGlobalTime;
  aspect.create(resolution.x / resolution.y,1);
  st := system.sin(ti);
  ct := system.cos(ti * 0.5);
{$IFDEF SHOWLIGHT}
  lightpos.Create(st, ct, -0.7);
{$ELSE }
  lightpos := vec3_3;
{$ENDIF }
  pixsize := 0.25 / resolution.xy * aspect;
  lightpos.xy := lightpos.xy * (aspect * 0.25);
  texCoord := Vec2(ti * 0.25);
end;

function TAlienTech.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv, luv: Vec2;
  col   : vec3;
  sph, lig, titila: float;
  ax,ay           : integer;
  aacoord, p      : Vec2;
  k, star         : float;
begin
  uv      := gl_FragCoord.xy / resolution.xy - 0.5;
  sph     := length(uv);
  sph     := system.sqrt(1 - sph * sph) * 1.5;                // curve for spheric distortion
  uv      := normalize(vec3.Create(uv, sph)).xy * 1.3; // normalize back to 2D and scale (zoom level)
  pixsize := normalize(vec3.Create(pixsize, sph)).xy * 1.3; // the same with pixsize for proper AA

  col         := vec3_4;
  lig         := 0;
  titila      := texture2D(tex[11], texCoord).x;

  // AA loop
  for ay := 0 to 2 do
    for ax := 0 to 2 do
    begin
      aacoord.Create(ax, ay);
      p       := uv + aacoord * pixsize;
      ldir    := vec3.Create(p, 0) + lightpos; // get light direction
      ldir.NormalizeSelf;
      k       := clamp(formula(p) * 0.25, 0.8, 1.4);
      col     := col + (light(p, vec3.Create(k, k * k, k * k * k)));
      lig     := lig + (math.max(0, 2 - ot) / 2);
    end;

  col := col * 0.2;
  luv := uv + lightpos.xy;

  // min amb light + spotlight with falloff * varying intensity
  col := col * (0.07 + pow(max(0, 1 - length(luv) * 0.5), 9) * (1 - titila * 0.3));

  // rotating star light
{$IFDEF SHOWLIGHT}
  star := abs(1.5708 - &mod(atan(luv.x, luv.y) * 3 - ti * 10, 3.1416)) * 0.02 - 0.05;
  col := col + (pow(max(0, 0.3 - length(luv * 1.5) - star) / 0.3, 5) * (1 - titila * 0.5));
{$ENDIF }
  // yellow lights
  col := col + (pow(lig * 0.12, 15) * vec3_5 * (0.8 + BLINKINGLIGHTS * sin(ti * 5 - uv.y * 10) * 0.6));

  Result := TColor32(col);
end;

initialization

AlienTech := TAlienTech.Create;
Shaders.Add('AlienTech', AlienTech);

finalization

FreeandNil(AlienTech);

end.
