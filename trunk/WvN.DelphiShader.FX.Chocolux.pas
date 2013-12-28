unit WvN.DelphiShader.FX.Chocolux;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TChocolux = class(TShader)
    s : array [0 .. 3] of Vec3;
    const
      v01:Vec3=(x:0.1;y:0.1;z:0.1);

    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  Chocolux: TShader;

implementation

uses SysUtils, Math;

const
  half: single = 0.5;

constructor TChocolux.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TChocolux.PrepareFrame;
begin
  s[0] := Vec3(0);
  s[3] := Vec3.Create(System.sin(iGlobalTime),
                      System.cos(iGlobalTime), 0);
  s[1] := s[3].zxy;
  s[2] := s[3].zzx;
end;

function TChocolux.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  t, b, c, h: TVecType;
  m, n, p, d: Vec3;
  i, j      : Integer;
begin
  h:=0;
  p := v01;
  d := normalize(gl_FragCoord/Resolution - p);

  for j := 0 to 3 do
  begin
    t := 2;
    for i := 0 to 3 do
    begin
      n := s[i] - p;
      b := dot(d, n);
      c := b * b + 0.2 - dot(n, n);
      if (b - c < t) and (c > 0.0) then
      begin
        m := s[i];
        t := b - c;
      end;
    end;

    p := p + (t * d);
    n := normalize(p - m);
    d := reflect(d, n);
    h := h + (pow(n.x * n.x, 44) + n.x * n.x * 0.2);
  end;
  Result := TColor32(Vec3.Create(h, h * h, h * h * h * h));
end;

initialization

Chocolux := TChocolux.Create;
Shaders.Add('Chocolux', Chocolux);

finalization

FreeandNil(Chocolux);

end.
