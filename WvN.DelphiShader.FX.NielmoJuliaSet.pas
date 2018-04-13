unit WvN.DelphiShader.FX.NielmoJuliaSet;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TNielmoJuliaSet = class(TShader)
  const
{x $DEFINE antialias}
    sr           = 0.13;
    depth        = 128;
    vec4_1: vec4 = (x: 0; y: 0; z: 0; w: 1);
    vec2_2: vec2 = (x: 0.000; y: 0.333);
    vec2_3: vec2 = (x: 0.000; y: 0.666);
    vec2_4: vec2 = (x: 0.333; y: 0.000);
    vec2_5: vec2 = (x: 0.333; y: 0.333);
    vec2_6: vec2 = (x: 0.333; y: 0.666);
    vec2_7: vec2 = (x: 0.666; y: 0.000);
    vec2_8: vec2 = (x: 0.666; y: 0.333);
    vec2_9: vec2 = (x: 0.666; y: 0.666);

  var
    scale: float;
    lr: float;
    l : vec2;
    rr: float;
    r : vec2;
    constructor Create; override;
    procedure PrepareFrame;
    function mandelbrot(const p: vec2; depth: float; const l, r: vec2; scale: float): vec4;
    function mainImage(var fragCoord: vec2): TColor32;
  end;

var
  NielmoJuliaSet: TShader;

implementation

uses SysUtils, Math;

constructor TNielmoJuliaSet.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;

procedure TNielmoJuliaSet.PrepareFrame;
begin
  lr := 1.57;
  l  := vec2.Create(0.7071 * sinLarge(0.717 * sinLarge(0.17 * iGlobalTime * lr) + 0.017 * iGlobalTime), 0.7071 * cosLarge(0.717 * sinLarge(0.17 * iGlobalTime * lr) + 0.017 * iGlobalTime));
  rr := 1.37;
  r  := vec2.Create(0.7071 * sinLarge(0.717 * sinLarge(0.17 * iGlobalTime * rr) + 0.017 * iGlobalTime), 0.7071 * cosLarge(0.717 * sinLarge(0.17 * iGlobalTime * rr) + 0.017 * iGlobalTime));
  scale := 0.10 + 0.003 * sinLarge(iGlobalTime * sr);
  scale := 4 * scale;
end;

function TNielmoJuliaSet.mandelbrot(const p: vec2; depth: float; const l, r: vec2; scale: float): vec4;
var
  re, im    : float;
  loc, c, z : vec2;
  n         : float;
  nn        : integer;
  cr, cg, cb: float;
begin
  re     := -0.8 + 0.03 * sinLarge(iGlobalTime * 0.117) + 0.009 * sinLarge(iGlobalTime * 0.716);
  im     := 0.15 + 0.03 * sinLarge(iGlobalTime * 0.073) + 0.009 * sinLarge(iGlobalTime * 0.332);
  loc    := vec2.Create(re, im);
  c      := (p.xy - resolution.xy / 2) / resolution.y * scale;
  c      := vec2.Create(c.x * r.x - c.y * r.y, c.x * r.y + r.x * c.y) - l / 1.5;
  z      := c;
  n      := 0;
  for nn := 0 to 1024 do
  begin
    z := vec2.Create(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + loc;
    n := n + 1;
    if dot(z, z) >= 256 then
      break;

    if n >= depth then
      break;
  end;

  if n >= depth then
    Exit(vec4_1);

  n  := n - Math.log2(Math.log2(dot(z, z)));
  n  := n * 0.01;
  n  := System.sqrt(n);
  cr := 0.5 + 0.5 * cosLarge(n * 7 + iGlobalTime);
  cg := 0.5 + 0.5 * cosLarge(n * 11 + iGlobalTime * 1.111);
  cb := 0.5 + 0.5 * cosLarge(n * 13 + iGlobalTime * 2.567);
  Exit(vec4.Create(cr, cg, cb, 1));
end;

function TNielmoJuliaSet.mainImage(var fragCoord: vec2): TColor32;

var
{$IFDEF antialias}
  c0,c1, c2, c3, c4, c5, c6, c7, c8: vec4;
{$ENDIF}
  fragColor: vec4;
begin

{$IFDEF antialias}
  c0  := mandelbrot(fragCoord.xy, depth, l, r, scale);
  c1  := mandelbrot(fragCoord.xy+vec2_2,depth,l,r,scale);
  c2  := mandelbrot(fragCoord.xy+vec2_3,depth,l,r,scale);
  c3  := mandelbrot(fragCoord.xy+vec2_4,depth,l,r,scale);
  c4  := mandelbrot(fragCoord.xy+vec2_5,depth,l,r,scale);
  c5  := mandelbrot(fragCoord.xy+vec2_6,depth,l,r,scale);
  c6  := mandelbrot(fragCoord.xy+vec2_7,depth,l,r,scale);
  c7  := mandelbrot(fragCoord.xy+vec2_8,depth,l,r,scale);
  c8  := mandelbrot(fragCoord.xy+vec2_9,depth,l,r,scale);
  fragColor := (c0 + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8) * 0.11111111;
{$ELSE}
  fragColor := mandelbrot(fragCoord.xy, depth, l, r, scale);
{$ENDIF}
  Result := TColor32(fragColor);
end;

initialization

NielmoJuliaSet := TNielmoJuliaSet.Create;
Shaders.Add('NielmoJuliaSet', NielmoJuliaSet);

finalization

FreeandNil(NielmoJuliaSet);

end.
