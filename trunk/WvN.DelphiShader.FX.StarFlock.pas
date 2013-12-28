unit WvN.DelphiShader.FX.StarFlock;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TStarFlock = class(TShader)
    const
      c1:Vec3=(x:1.5;y:1.2;z:0.86);
      STAR_COUNT=60;
    var
      rnd:array[0..STAR_COUNT-1] of Vec2;
      rndf:array[0..STAR_COUNT-1] of Vec2;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  StarFlock: TShader;

implementation

uses SysUtils, Math;


function rand(const co:vec2):float; inline;
const v:Vec2=(x:12.9898;y:78.233);
begin
  Result := fract(system.sin(dot(co ,v)) * 43758.5453);
end;

constructor TStarFlock.Create;
var i:integer;
begin
  inherited;
  PixelProc := RenderPixel;
  FrameProc := PrepareFrame;

  for I := low(rnd) to high(rnd) do
    rnd[I] := vec2.create(rand(vec2.create(i, i)), rand(vec2.create(i, i+10)));
end;


procedure TStarFlock.PrepareFrame;
var i:integer;
begin
  for I := 0 to STAR_COUNT-1 do
  begin
		rndf[i] := rnd[I];
		rndf[i].x := (rndf[i].x + system.sin(time + rndf[i].y * rndf[i].y))*2-1;
		rndf[i].y := (rndf[i].y + system.sin(time + rndf[i].x * 2.0))*2-1;
  end;
end;

function TStarFlock.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  I: Integer;
  position:vec2;
  color: float; c:vec3;
begin
	position := ( gl_FragCoord.xy / resolution.xy ) * 2.0 - 1.0;
	position.x := position.x * (resolution.x / resolution.y);
	position := position * 3.0;

	color := 0.7;
  for I := 0 to STAR_COUNT-1 do
		color := color + (1 / distance(position, rndf[i]) * 0.5);

	color := pow(color* 0.02, 0.7);
	c := vec3.create(color);
	Result := Tcolor32(pow(c, c1));
end;

initialization

StarFlock := TStarFlock.Create;
Shaders.Add('StarFlock', StarFlock);

finalization

FreeandNil(StarFlock);

end.
