unit WvN.DelphiShader.FX.Nautilus2;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // Nautilus 1k ... by Weyland Yutani
  // http://www.pouet.net/prod.php?which=55469

  TNautilus2 = class(TShader)
  public const
    vec3_1: vec3 = (x: 1;   y: 1;   z: 1   );
    vec3_2: vec3 = (x: 0.1; y: 0;   z: 0   );
    r_xyy : vec3 = (x: 0.1; y: 0;   z: 0   );
    r_yxy : vec3 = (x: 0;   y: 0.1; z: 0   );
    r_yyx : vec3 = (x: 0;   y: 0;   z: 0.1 );
    vec3_3: vec3 = (x: 0;   y:-0.5; z:  0.5);
    vec3_4: vec3 = (x: 0;   y: 0  ; z: -0.5);

    function e(const _c: vec3): float;
    function Main(var gl_FragCoord: Vec2): TColor32;

  var
    time: float;
    ct,
    ct2,ct3,ct14,
    ct7,t7,t8,t9:float;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Nautilus2: TShader;

implementation

uses SysUtils, Math;

constructor TNautilus2.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TNautilus2.PrepareFrame;
begin
  time := iGlobalTime;
  t7 := time/7;
  t8 := time/8;
  t9 := time/9;
  ct := system.cos(time) / 30;
  ct2 := system.cos(time/2) / 30;
  ct7 := system.cos(t7);
  ct3 := system.cos(time/3) / 19;
  ct14 := system.cos(time/14) / 8;
end;

function TNautilus2.e(const _c: vec3): float;
var
  c: vec3;
begin
  c := _c;
  c.r := system.cos(c.r + t8) * c.r - system.cos(c.g + t9) * c.g;
  c.g := c.b / 3 * c.r - ct7 * c.g;
  c.b := c.r + c.g + c.b / 1.25 + time;
  cos(c,c);
  mult(c,c);
  Result := dot(c, vec3_1) - 1;
end;

function TNautilus2.Main(var gl_FragCoord: Vec2): TColor32;
var
  c      : Vec2;
  o, g   : vec3;
  m, t   : float;
  j      : integer;
  n, v, ogt: vec3;
  col:vec3;
begin
  c     := -1 + 2 * gl_FragCoord.xy / resolution.xy;
  o     := vec3.Create(c.x, c.y + ct2, 0);
  g     := vec3.Create(c.x + ct, c.y, 1) / 64;
  m     := 1;
  t     := 0;

  for j := 1 to 332 do
    if m > 0.4 then
    begin
      t := j * 2;
      ogt := o + g * t;
      m := e(ogt);
    end;


  n.x    := e(ogt + r_xyy);
  n.y    := e(ogt + r_yxy);
  n.z    := e(ogt + r_yyx);
  n      := m - n;
  v      := dot(vec3_4, n) +
            dot(vec3_3, n);

  col.r  := 0.1 + ct14;
  col.g  := 0.1;
  col.b  := 0.1 - ct3;
  col    := v + col * (t / 41);
  Result := TColor32(col);
end;

initialization

Nautilus2 := TNautilus2.Create;
Shaders.Add('Nautilus2', Nautilus2);

finalization

FreeandNil(Nautilus2);

end.
