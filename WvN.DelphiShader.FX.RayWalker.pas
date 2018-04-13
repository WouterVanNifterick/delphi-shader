unit WvN.DelphiShader.FX.RayWalker;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TRayWalker=class(TShader)
    Time4:Double;
    stime, ctime: Double;
    Ratio:Double;
    vuv, ViewReferencePoint,
    vpn, u, v,w,vcv,
    CameraPos:Vec3;
    vPos:Vec2;
    tf:TVecType;
    const
     maxd: TVecType = 150.0;
     e: Vec3      = (x: 0.1; y: 0.0; z: 0.0);
    function inObj(p: Vec3): TVecType;
    constructor Create;override;
    procedure PrepareFrame;
    procedure PrepareLine(y:integer);inline;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;inline;
  end;

var
  RayWalker:TShader;

implementation

uses SysUtils, Math;


procedure TRayWalker.PrepareLine(y:integer);
begin
  vPos.y := (-0.8 + ((Resolution.x - y) / Resolution.x));
end;

function TRayWalker.inObj(p: Vec3): TVecType;
var
  oP: TVecType;
begin
  oP     := p.Length;
  p.x    := System.sin(p.x) + stime;
  p.z    := System.sin(p.z) + ctime;
  Result := min(p.Length - 1.5 - System.sin(oP - time4), p.y + 3.0);
end;


constructor TRayWalker.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
  LineProc := PrepareLine;
end;

procedure TRayWalker.PrepareFrame;
begin
  time4        := iGlobalTime * 4;
  stime        := sinLarge(iGlobalTime);
  ctime        := cosLarge(iGlobalTime);

  Ratio := Resolution.x / Resolution.y;

  // Camera animation
  vuv                := Vec3.create(stime                 , 1, 0); // view up vector
  ViewReferencePoint := Vec3.create(sinLarge(iGlobalTime * 0.7) * 10.0, 0, cosLarge(iGlobalTime * 0.9) * 10.0);
  CameraPos          := Vec3.create(
                           sinLarge(iGlobalTime  * 0.7) * 20 + ViewReferencePoint.x + 20,
                                          stime  * 4.0  +  4 + ViewReferencePoint.y +  3,
                           cosLarge(iGlobalTime  * 0.6) * 20 + ViewReferencePoint.z + 14);
  // Camera setup
  vpn      := Vec3(ViewReferencePoint - CameraPos).Normalize^;
  u        := vuv.Cross(vpn);
  u.NormalizeSelf;

  v        := vpn.Cross(u);
  w        := u * Ratio;
  vcv      := CameraPos + vpn;
end;


function TRayWalker.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  scrcoord, scp,
  ObjectColor, p, n, col: Vec3;
  b, D, f     : TVecType;
  i           : Integer;
  s           : TVecType;
const
  planePos=2.5;
begin
  s     := 0.1;
  vPos.x := -0.8 + (gl_FragCoord.x / Resolution.x);

  scrcoord := vcv + vPos.x * w + vPos.y * v;
  scp      := scrcoord - CameraPos;
  scp.NormalizeSelf;

  // Raymarching
  // speed optimization -advance ray (simple raytracing) until plane y=2.5

  if IsZero(scp.y) then
    f := 0
  else
    f := -(CameraPos.y - planePos) / scp.y * 0.5;
  if (f > 0) then
    p := CameraPos + scp * f
  else
    f := maxd;

  for i := 0 to 255 do
  begin
    if (System.abs(s) < 0.1) or (f > maxd) then
      break;
    f := f + s;
    // p := CameraPos + scp * f;
    p.x := CameraPos.x + scp.x * f;
    p.y := CameraPos.y + scp.y * f;
    p.z := CameraPos.z + scp.z * f;
    s := inObj(p);
  end;

  if (f < maxd) then
  begin

    if (p.y < -planePos) then
    begin
      if ((round(p.x) mod 2) = 0) xor
         ((round(p.z) mod 2) = 0) then
        ObjectColor := vec3Black
      else
        ObjectColor := vec3White;

      n := vec3Green;
    end
    else
    begin
      D := p.Length;

      ObjectColor.r := (sinLarge(D * 0.25 - time4) + 1) * 0.5;
      ObjectColor.g := (stime + 1) * 0.5;
      ObjectColor.b := (sinLarge(D - time4) + 1) * 0.5;

      n.x := s - inObj(p - e.xyy);
      n.y := s - inObj(p - e.yxy);
      n.z := s - inObj(p - e.yyx);
      n.NormalizeSelf;
    end;
    b := n.Dot((CameraPos - p).Normalize^);
    col    := (b * ObjectColor + power(b, 54)) * (1 - f * 0.01);
    Result :=  TColor32(col);
  end
  else
    Result := clBlack32;
end;



initialization
  RayWalker := TRayWalker.Create;
  Shaders.Add('RayWalker',RayWalker);

finalization
  FreeandNil(RayWalker);
end.

