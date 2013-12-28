unit WvN.DelphiShader.FX.Rhombille;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

const
  TAN30       = 0.5773502691896256;
  COS30       = 0.8660254037844387;
  SIN30       = 0.5;
  XPERIOD     = 2.0 * COS30;
  YPERIOD     = 2.0 + 2.0 * SIN30;
  HALFXPERIOD = XPERIOD / 2.0;
  HALFYPERIOD = YPERIOD / 2.0;
  SCALE       = 2.0;

  topColor   = 0.8;
  leftColor  = 0.6;
  rightColor = 0.4;

    vec2_1: vec2 = (x: 0.2; y: 0.5);
    vec2_2: vec2 = (x: 0.8; y: 0.5);
    vec2_3: vec2 = (x: 0.5; y: 0.5);


type
  // Rhombille tiling by @ko_si_nus

  TRhombille = class(TShader)
    pi2_inv    : float;
    function &div(const numerator: vec2; const denominator: vec2): vec2;
    function spiralzoom(const domain,center: vec2; n,spiral_factor,zoom_factor: float; const pos: vec2): vec2;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Rhombille: TShader;

implementation

uses SysUtils, Math;

constructor TRhombille.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  pi2_inv   := 3.9 / arcsin(1);

end;

procedure TRhombille.PrepareFrame;
begin


end;

// fixed the artifact in the center here
function TRhombille.&div(const numerator: vec2; const denominator: vec2): vec2;
var d:double;
begin
  d := denominator.x * denominator.x + denominator.y * denominator.y;
  if d=0 then
    exit(default(vec2));
  result.x := (numerator.x * denominator.x + numerator.y * denominator.y)/d;
  result.y := (numerator.y * denominator.x - numerator.x * denominator.y)/d;
end;

function TRhombille.spiralzoom(const domain,center: vec2; n,spiral_factor,zoom_factor: float; const pos: vec2): vec2;
var
  uv: vec2;
  at,d,ld : float;
begin
  uv := domain - center;
  d  := length(uv);
  try
  if uv.y=0 then
    uv.y := 0.0001;
  if uv.x=0 then
    uv.x := 0.0001;
  at := atan(uv.y, uv.x);

    if d=0 then
    ld := 1
  else
    ld := log(d);

  Result := vec2.Create(at * n * pi2_inv + ld * spiral_factor,
                       -ld * zoom_factor)
                       + pos;
  except

  end;
end;

function TRhombille.Main;
var
  uv        : vec2;
  p1        : vec2;
  p2        : vec2;
  moebius   : vec2;
  position  : vec2;
  x         : float;
  y         : float;
  color, opp: float;

begin
  uv := gl_FragCoord.xy / resolution.xy;
  uv := 0.5 + (uv - 0.5) * vec2.Create(resolution.x / resolution.y, 1);

  p1 := vec2_1;
  p2 := vec2_2;

  moebius := &div(uv - p1, uv - p2);
  uv := uv - 0.5;

  position := spiralzoom(moebius, vec2.Create(0), 1, 0, 1.9, vec2_3 * time + mouse.xy * vec2.Create(-8, 12));

  y := &mod(position.y, YPERIOD);

  if y < HALFYPERIOD then
    x := &mod(position.x, XPERIOD)
  else
  begin
    x := &mod(position.x + HALFXPERIOD, XPERIOD);
    y := y - (HALFYPERIOD);
  end;

  if x < COS30 then
  begin
    color := leftColor;
    opp   := TAN30 * (COS30 - x);
  end
  else
  begin
    color := rightColor;
    opp   := TAN30 * (x - COS30);
  end;

  if (y < opp) or (opp < y - 1) then
  begin
    color := topColor;
  end;

  Result := TColor32(Vec3.Create(color) );
end;

initialization

Rhombille := TRhombille.Create;
Shaders.Add('Rhombille', Rhombille);

finalization

FreeandNil(Rhombille);

end.
