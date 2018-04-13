unit WvN.DelphiShader.FX.RoadOfRibbon;

interface

uses GR32, Types, WvN.DelphiShader.Shader, Math
;

type
  TRoadOfRibbon=class(TShader)

  const
    k:Vec3=(x:0.01;y:0.00;z:0.00);
    l:Vec3=(x:0.00;y:0.01;z:0.00);
    m:Vec3=(x:0.00;y:0.00;z:0.01);
    v:Vec3=(x:0.1; y:0.1; z:0.0);
    w:Vec4=(x:1; y:0.8; z:0.7;w:1);
    Vec4One:vec4=(x:1;y:1;z:1);
    Vec0 :vec3 =(x:0;y:0;z:0);
  var
    cc:TPointF;
    vt,q,org:Vec3;
    v4:vec4;
    res,ht:Double;
    function oa(const q:vec3):TVecType;//inline;
    function ob(const q:Vec3):TVecType;//inline;
    function o(const q:vec3):TVecType;//inline;
    function gn(const q:vec3):Vec3;//inline;
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  RoadOfRibbon:TShader;

implementation

uses SysUtils;

constructor TRoadOfRibbon.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;



//Object A (tunnel)
function TRoadOfRibbon.oa(const q:vec3):TVecType;
begin
 Result := System.cos(q.x)+System.cos(q.y*1.5)+System.cos(fmod(q.z,2*pi))+System.cos(q.y*20.0)*0.05;
end;


//Object B (ribbon)
function TRoadOfRibbon.ob(const q:Vec3):TVecType;
begin
  result := length(
              max(
                abs(
                  q-vec3.create(
                      cosLarge(q.z*1.5)*0.3,
                      -0.5+cosLarge(q.z)*0.2,
                      0.0)
                )
                -
                vt
                ,
                Vec0
              )
              );
end;

//Scene
function TRoadOfRibbon.o(const q:vec3):TVecType;
begin
  Result := Math.Min(oa(q),ob(q));
end;


//Get Normal
function TRoadOfRibbon.gn(const q:vec3):Vec3;
begin
  Result.x := o(q+k);
  Result.y := o(q+l);
  Result.z := o(q+m);
  if Result.x=0 then
  if Result.y=0 then
  if Result.z=0 then
    Exit(Vec3Black);

  Result.NormalizeSelf;
end;


procedure TRoadOfRibbon.PrepareFrame;
begin
  ht := iGlobalTime * 0.5;
  org:=vec3.create(
          sinLarge(iGlobalTime)*0.5,
          cosLarge(ht)*0.25+0.25,
          iGlobalTime);
  res := resolution.x/resolution.y;
  vt := vec3.create(0.125,0.02,time+3.0);

  v4.x := 0.3;
  v4.y := System.cos(ht) * 0.5 + 0.5;
  v4.z := System.sin(ht) * 0.5 + 0.5;
  v4.w := 1;
end;



function TRoadOfRibbon.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  p      : vec2;
  dir, pp: Vec3;
  c      : vec4;
  d, f   : TVecType;
  i      : Integer;
const
  depth = 64;
begin
  p.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x;
  p.y := -1.0 + 2.0 * gl_FragCoord.y / Resolution.y;
  p.x := p.x * res;
  c   := Vec4One;
  dir := normalize(Vec3.Create(p.x * 1.6, p.y, 1));
  q   := org;

  // First raymarching
  for i := 0 to pred(depth) do
  begin
    d := oa(q);
    q := q + (d * dir);
  end;

  pp := q;
  f  := length(q - org) * 0.02;

  // Second raymarching (reflection)
  dir   := reflect(dir, gn(q));
  q     := q + dir;
  for i := 0 to pred(depth) do
  begin
    d := oa(q);
    q := q + (d * dir);
  end;

  c := Math.max(dot(gn(q), v), 0) + v4 * Min(length(q - org) * 0.04, 1);

  // Ribbon Color
//  if (oa(pp) > ob(pp)) then
//    c := mix(c, vec4.Create(cos(time * 0.3) * 0.5 + 0.5, cos(time * 0.2) * 0.5 + 0.5, sin(time * 0.3) * 0.5 + 0.5, 1.0), vec4.Create(0.3));

  // Final Color
  Result  := TColor32(((c + vec4.Create(f)) + (1.0 - Min(pp.y + 1.9, 1)) * w) * Math.Min(ht, 1));
end;


initialization
  RoadOfRibbon := TRoadOfRibbon.Create;
  Shaders.Add('RoadOfRibbon',RoadOfRibbon);
finalization
  FreeandNil(RoadOfRibbon);
end.
