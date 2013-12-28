unit WvN.DelphiShader.FX.MetaBlob;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMetaBlob=class(TShader)
    move1, move2: vec2;
    p: vec2;
    constructor Create;override;
    procedure PrepareFrame;inline;
    procedure PrePareLine(y:integer);inline;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;inline;
  end;

var
  MetaBlob:TShader;

implementation

uses SysUtils, Math;


constructor TMetaBlob.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
  LineProc := PrePareLine;
end;

procedure TMetaBlob.PrepareFrame;
begin
   //the centre point for each blob
  move1.x := system.cos(iGlobalTime)*0.4;
  move1.y := system.sin(iGlobalTime*1.5)*0.4;
  move2.x := system.cos(iGlobalTime*2.0)*0.4;
  move2.y := system.sin(iGlobalTime*3.0)*0.4;
end;


procedure TMetaBlob.PrePareLine(y: integer);
begin
  p.y := -1.0 + 2.0 * y / Resolution.y;
end;

function TMetaBlob.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  col,metaball,r1,r2  : double;
begin
  p.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x;
  //radius for each blob
  r1 :=(dot(p-move1,p-move1))*8.0;
  r2 :=(dot(p+move2,p+move2))*16.0;

  if (r1<0.01) or (r2<0.01) then
    Exit(clWhite32);

  //sum the meatballs
  metaball :=1.0 / r1 + 1.0 / r2;

  //alter the cut-off power
  col := pow(metaball,8.0);

  //set the output color
  Result := tcolor32(Vec3(col));
end;


initialization
  MetaBlob := TMetaBlob.Create;
  Shaders.Add('MetaBlob',MetaBlob);
finalization
  FreeandNil(MetaBlob);
end.
