unit WvN.DelphiShader.FX.Mandel;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMandel = class(TShader)
  public const
    vec2_1: vec2 = (x: - 0.745; y: 0.186);
    vec2_2: vec2 = (x: 0; y: 0);

  var
    zoo: float;
    coa: float;
    sia: float;

    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Mandel: TShader;

implementation

uses SysUtils, Math;

constructor TMandel.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TMandel.PrepareFrame;
begin
  zoo := 0.62 + 0.38 * sinLarge(0.01 * time);
  coa := cosLarge(0.01 * (1 - zoo) * time);
  sia := sinLarge(0.01 * (1 - zoo) * time);
  zoo := pow(zoo, 8);
end;

function TMandel.Main(var gl_FragCoord: vec2): TColor32;
var
  p  : vec2;
  xy : vec2;
  cc : vec2;
  z  : vec2;
  c,co,m2,n : float;
  i  : integer;
  col: vec3;
begin
  p    := -1 + 2 * gl_FragCoord.xy / resolution.xy;
  p.x  := p.x * (resolution.x / resolution.y);
  xy.x := p.x * coa - p.y * sia;
  xy.y := p.x * sia + p.y * coa;
  cc   := vec2_1 + xy * zoo;

  z  := vec2_2;
  co := 0;
  m2 := 0;

  for i := 0 to 255 do
    if m2 < 1024 then
    begin
//      z  := cc + vec2.Create(z.x * z.x - z.y * z.y, 2 * z.x * z.y);
      z.x  := cc.x + z.x * z.x - z.y * z.y;
      z.y  := cc.y + 2 * z.x * z.y;
      m2 := dot(z, z);
      co := co + 1;
    end;

  c := 0.5 * Math.log2(m2);
  if c>0 then
    co := co + 1 - Math.log2(c);

  co := co / 256;
  if co>0 then
    co := system.sqrt(co);

  n := 2 * pi * co;
  col.r  := 0.5 + 0.5 * system.cos(n + 0.0);
  col.g  := 0.5 + 0.5 * system.cos(n + 0.4);
  col.b  := 0.5 + 0.5 * system.cos(n + 0.7);

  Result := TColor32(col);
end;

initialization

Mandel := TMandel.Create;
Shaders.Add('Mandel', Mandel);

finalization

FreeandNil(Mandel);

end.
