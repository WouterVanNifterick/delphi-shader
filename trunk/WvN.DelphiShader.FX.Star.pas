unit WvN.DelphiShader.FX.Star;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TStar = class(TShader)
    t:double;
    p_ar,uv_ar:array of array of vec2;
    w2_ar,w_ar,r_ar,a_ar:array of array of double;

    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  Star: TShader;

implementation

uses SysUtils, Math;

constructor TStar.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TStar.PrepareFrame;
var x,y,w,h:integer;
begin
  t := (1 + 0.8 * System.cos(iGlobalTime));

  if system.Length(p_ar)<>resolution.y then
  begin
    w := trunc(Resolution.x);
    h := trunc(Resolution.y);
    SetLength(p_ar, w, h);
    SetLength(a_ar, w, h);
    SetLength(r_ar, w, h);
    SetLength(w_ar, w, h);
    for y := 0 to high(p_ar) do
      for x := 0 to high(p_ar[0]) do
      begin
        p_ar[x,y] := -0.5 + vec2.create(x,y) / Resolution;
        a_ar[x,y] := arctan2(p_ar[x,y].y, p_ar[x,y].x);;
        r_ar[x,y] := System.sqrt(dot(p_ar[x,y], p_ar[x,y]));
        w_ar[x,y] := 0.9 + power(max(1.5 - r_ar[x,y], 0.0), 4);;
      end;
  end;
end;

function TStar.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  p, uv     : vec2;
  a, r, s, w: Double;
  Col:Vec4;
  x,y:integer;
begin
  x := trunc(gl_FragCoord.x);
  y := trunc(gl_FragCoord.y);

  p := p_ar[x,y];
  a := a_ar[x,y];
  r := r_ar[x,y];
  s := r * t;

  if s > 0 then
  begin
    uv.x :=                     0.02 * p.y + 0.03 * System.cos(-iGlobalTime + a * 3) / s;
    uv.y := 0.1 * iGlobalTime + 0.02 * p.x + 0.03 * System.sin(-iGlobalTime + a * 3) / s;
  end
  else
  begin
    uv.x := 60;
    uv.y := 60;
  end;

  w := w_ar[x,y] * (0.6 + 0.4 * System.cos(iGlobalTime + a * 3));
  Col := texture2D(tex[0], uv);
  Result := TColor32(Col*w);
end;

initialization

Star := TStar.Create;
Shaders.Add('Star',Star);

finalization

FreeandNil(Star);

end.
