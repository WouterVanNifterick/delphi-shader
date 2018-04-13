unit WvN.DelphiShader.FX.VoronoiDistances;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TVoronoiDistances = class(TShader)
  const
    vec3_1: vec3 = (x: 1; y: 1; z: 1);
    vec3_2: vec3 = (x: 1; y: 0.6; z: 0);
    vec3_3: vec3 = (x: 1; y: 0.6; z: 0.1);
    vec3_4: vec3 = (x: 1; y: 0.6; z: 0.1);

    constructor Create; override;
    procedure PrepareFrame;
    function hash2(const p: vec2): vec2;
    function voronoi(const x: vec2): vec3;
    function mainImage(var fragCoord: vec2): TColor32;
  end;

var
  VoronoiDistances: TShader;

implementation

uses SysUtils, Math;

{$DEFINE ANIMATE}

constructor TVoronoiDistances.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;

procedure TVoronoiDistances.PrepareFrame;
begin
end;

function TVoronoiDistances.hash2(const p: vec2): vec2;
begin
  // texture based white noise

  Result := texture2D(tex[18], (p + 0.5) / 256, -100).xy;

  // procedural white noise
  // return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
end;

function TVoronoiDistances.voronoi(const x: vec2): vec3;
var
  n, f, mg, mr: vec2;
  md          : float;
  j, i        : int;
  g, o, r     : vec2;
  d           : float;
begin
  n := floor(x);
  f := fract(x);
  // ----------------------------------
  // first pass: regular voronoi
  // ----------------------------------
  md      := 8;
  for j   := -1 to 1 do
    for i := -1 to 1 do
    begin
      g.x := i;
      g.y := j;
      o := hash2(n + g);
{$IFDEF ANIMATE}
      o := 0.5 + 0.5 * sinLarge(iGlobalTime + 6.2831 * o);
{$ENDIF }
      r := g + o - f;
      d := dot(r, r);
      if d < md then
      begin
        md := d;
        mr := r;
        mg := g;
      end;
    end;
  // ----------------------------------
  // second pass: distance to borders
  // ----------------------------------
  md      := 8;
  for j   := -2 to 2 do
    for i := -2 to 2 do
    begin
      g.x := i;
      g.y := j;
      o := hash2(n + g);
{$IFDEF ANIMATE}
      o := 0.5 + 0.5 * sinLarge(iGlobalTime + 6.2831 * o);
{$ENDIF }
      r := g + o - f;
      if dot(mr - r, mr - r) > 0.00001 then
        md := Math.min(md, dot(0.5 * (mr + r), normalize(r - mr)));
    end;
  Result.x := md;
  Result.y := mr.x;
  Result.z := mr.y;
end;

function TVoronoiDistances.mainImage(var fragCoord: vec2): TColor32;
var
  p     : vec2;
  c, col: vec3;
  dd    : float;
begin
  p := fragCoord.xy / resolution.xx;
  c := voronoi(8 * p);
  // isolines
  col := c.x * (0.5 + 0.5 * sin(64 * c.x)) * vec3_1;
  // borders
  col := mix(vec3_2, col, smoothstep(0.04, 0.07, c.x));
  // feature points
  dd     := length(c.yz);
  col    := mix(vec3_3, col, smoothstep(0, 0.12, dd))
         + (vec3_4 * (1 - smoothstep(0, 0.04, dd)));
  Result := TColor32(col);
end;

initialization

VoronoiDistances := TVoronoiDistances.Create;
Shaders.Add('VoronoiDistances', VoronoiDistances);

finalization

FreeandNil(VoronoiDistances);

end.
