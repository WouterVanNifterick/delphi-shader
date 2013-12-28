unit WvN.DelphiShader.FX.ReliefTunnel;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TReliefTunnel = class(TShader)
  var
    Ratio:double;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  ReliefTunnel: TShader;

implementation

uses SysUtils, Math;

constructor TReliefTunnel.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TReliefTunnel.PrepareFrame;
begin
end;

function TReliefTunnel.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  p, uv: vec2;

  col           : Vec4;
  a, r, s, w, ao,t: Double;
begin
  p.x := -1 + 2 * gl_FragCoord.x / Resolution.x;
  p.y := -1 + 2 * gl_FragCoord.y / Resolution.y;
  r := System.sqrt(dot(p, p));
  a := arctan2(p.y, p.x) + 0.5 * System.sin(0.5 * r - 0.5 * iGlobalTime);
  s := 0.5 + 0.5 * System.cos(7 * a);
  ao := s;
  s := smoothstep(0, 1, s);
  s := smoothstep(0, 1, s);
  s := smoothstep(0, 1, s);
  s := smoothstep(0, 1, s);
  if abs(s)<0.0001 then
    s := 0;

//  s := clamp(s,0,1);

  t := (r + 0.2 * s);

  // Woute van Nifterick, 2013:
  // sometimes at the end of the tunnel, t gets rounded to 0,
  // because the tunnel is basically infinite. It's usually a single pixel.
  // We can safely paint that black.
  if t=0 then
    exit(clBlack32);
  uv.x := iGlobalTime + 1 / t;
  uv.y := 3 * a / pi;

  w := (0.5 + 0.5 * s) * r * r;

  col := texture2D(tex[0], uv);

  ao := smoothstep(0, 0.4, ao) - smoothstep(0.4, 0.7, ao);
  ao := 1 - 0.5 * ao * r;

  Result := TColor32(col * w * ao);
end;

initialization

ReliefTunnel := TReliefTunnel.Create;
Shaders.Add('ReliefTunnel',ReliefTunnel);

finalization

FreeandNil(ReliefTunnel);

end.
