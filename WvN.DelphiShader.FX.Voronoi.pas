unit WvN.DelphiShader.FX.Voronoi;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TVoronoi = class(TShader)
  const
    vec2_1: vec2 = (x: 269.5; y: 183.3);
    vec2_2: vec2 = (x: 127.1; y: 311.7);
    vec2_3: vec2 = (x: 8; y: 8);
    vec2_4: vec2 = (x: 7; y: 113);
    vec3_5: vec3 = (x: 0; y: 0.8; z: 1);

    function hash(n: float): float; overload;
    function hash(p: vec2): vec2; overload;
    function Voronoi(const x: vec2): vec2;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Voronoi: TShader;

implementation

uses SysUtils, Math;

constructor TVoronoi.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TVoronoi.PrepareFrame;
begin
  // Created by inigo quilez - iq/2013
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

end;

function TVoronoi.hash(n: float): float;
begin
  Exit(fract(system.sin(n) * 43758.5453));
end;

function TVoronoi.hash(p: vec2): vec2;
begin
  p := vec2.Create(dot(p, vec2_2), dot(p, vec2_1));
  Exit(fract(sin(p) * 43758.5453));
end;

function TVoronoi.Voronoi(const x: vec2): vec2;
var
  n: vec2;
  f: vec2;
  m: vec2;
  j: integer;
  i: integer;
  g: vec2;
  o: vec2;
  r: vec2;
  d: float;

begin
  n := floor(x);
  f := fract(x);
  m := vec2_3;

  for j   := -1 to 1 do
    for i := -1 to 1 do
    begin
      g.x := i;
      g.y := j;
      o := hash(n + g);
      o := 0.5 + 0.5 * sin(iGlobalTime + 6.2831 * o);
      r := g - f + o;

      d := dot(r, r);
      if d < m.x then
      begin
        m.x := d;
        m.y := hash(dot(n + g, vec2_4));
      end;
    end;

  Exit(vec2.Create(system.sqrt(m.x), m.y));
end;

function TVoronoi.Main(var gl_FragCoord: vec2): TColor32;
var
  p  : vec2;
  c  : vec2;
  col: vec3;
begin
  p := gl_FragCoord.xy / resolution.xx;
  c := Voronoi(8 * p);

  col := 0.5 + 0.5 * sin(c.y * 100 + vec3_5);
  col := col * (0.8 - 0.4 * c.x);
  col := col + (0.4 * (2 - smoothstep(0, 0.12, c.x) - smoothstep(0, 0.04, c.x)));

  Result := TColor32(col);
end;

initialization

Voronoi := TVoronoi.Create;
Shaders.Add('Voronoi', Voronoi);

finalization

FreeandNil(Voronoi);

end.
