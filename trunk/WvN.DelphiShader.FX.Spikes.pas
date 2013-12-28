unit WvN.DelphiShader.FX.Spikes;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TSpikes = class(TShader)
  const
    MAX_ITER = 48;

  var
    st, ct, csty, res: double;
    surfacePos       : Vec2;
    sp, cstx         : array of double;

    function Main(var gl_FragCoord: Vec2): TColor32;
    constructor Create; override;
    procedure PrepareFrame;
    procedure PrepareLine(y: integer);
  end;

var
  Spikes: TShader;

implementation

uses SysUtils, Math;

constructor TSpikes.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  LineProc  := PrepareLine;
end;

procedure TSpikes.PrepareFrame;
var
  I: integer;
begin
  res := Resolution.x / Resolution.y;
  ct  := system.cos(time);
  st  := system.sin(time);
  setlength(cstx, round(Resolution.x));
  setlength(sp, round(Resolution.x));

  for I := Low(cstx) to High(cstx) do
  begin
    sp[I]   := ((I / High(cstx) * res) - 0.5) * 4;
    cstx[I] := (system.sin(sp[I] - time) * 5);
  end;
end;

procedure TSpikes.PrepareLine(y: integer);
begin
  surfacePos.y := ((y / Resolution.y) - 0.5) * 4;
  csty         := system.cos(surfacePos.y - time) * 5;
end;

function TSpikes.Main(var gl_FragCoord: Vec2): TColor32;
var
  I   : Vec2;
  c   : float;
  f   : bool;
  ni  : int;
  n, x: integer;
  v1  : Vec2;
begin
  x            := round(gl_FragCoord.x);
  surfacePos.x := sp[x];
  I            := surfacePos;

  c     := 0;
  f     := true;
  ni    := 0;
  for n := 0 to MAX_ITER - 1 do
  begin
    if not f then
    begin
      I    := Vec2.Create(dot(I, Vec2.Create(I.x, -I.y)) - st, 2 * I.x * I.y - ct);
      v1.x := surfacePos.x - csty;
      v1.y := -surfacePos.y - cstx[x];
      c    := c + system.sqrt(abs(dot(v1, I)));
    end;
    Inc(ni);
    if c > MAX_ITER - n then
      break;
    f := not f;
  end;
  c      := pow((ni * ni) / c, 1.5);
  Result := TColor32(Vec3.Create((c * 3.5) - 0.5, c, c * 0.3));
end;

initialization

Spikes := TSpikes.Create;
Shaders.Add('Spikes', Spikes);

finalization

FreeandNil(Spikes);

end.
