unit WvN.DelphiShader.FX.Displacement;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TDisplacement = class(TShader)
    vuv, vrp, prp, vpn,vcv,u, v :Vec3;

    constructor Create; override;
    procedure PrepareFrame;
    function opDisplace(const p:vec3 ):float;inline;
    function _displacement(const p:vec3):float;inline;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
    function sceneDistance (const p:vec3):Float;
  end;

var
  Displacement: TShader;

implementation

uses SysUtils, Math;

const
  NaN:integer=256;
  c2:vec3=(x:0.1;y:0.1;z:1);
  e:vec3=(x:0.1;y:0;z:0);
  e_xyy:vec3=(x:0.1;y:0;z:0);
  e_yxy:vec3=(x:0;y:0.1;z:0);
  e_yyx:vec3=(x:0;y:0;z:0.1);
  maxd=64.0; //Max depth

constructor TDisplacement.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

function udRoundBox( const p,b:vec3;r:float):float;inline;
begin
  Result := length(max(abs(p)-b,0.0))-r;
end;
                               {
       http://glsl.heroku.com/e#6254.0 // cool blobs!
http://glsl.heroku.com/e#9118.1
http://glsl.heroku.com/e#9135.0
http://glsl.heroku.com/e#9027.0
http://glsl.heroku.com/e#8865.0
http://glsl.heroku.com/e#8806.1
http://glsl.heroku.com/e#8733.3
http://glsl.heroku.com/e#8338.3
http://glsl.heroku.com/e#8770.0 // raytrace
http://glsl.heroku.com/e#8566.0 // kleurtjes!
http://glsl.heroku.com/e#8305.2 // raytrace

                              }


const
vb:vec3=(x:0.75;y:0.2;z:0.5);
vc:vec3=(x:3;y:3;z:2.5);
v1:vec3=(x:0;y:1;z:0);

function TDisplacement._displacement(const p:vec3):float;
begin
  Result := ( system.sin((1.75 * p.x) *
              system.cos(iGlobalTime * pi)) *
              system.sin((1.75 * p.y) *
             -system.sin(iGlobalTime * pi)) *
              system.sin(0.75 * p.z));
end;

function TDisplacement.opDisplace(const p:vec3 ):float;
var d1,d2:Float;

begin
    d1 := udRoundBox(p, vec3.create(0.75,0.2,0.5), 0.15);
    d2 := _displacement(p);
    Result := d1+d2;
end;

function TDisplacement.sceneDistance (const p:vec3):Float;
var xx:Vec3;
begin
	// repeater
	xx := &mod (p,vc)-0.5*vc;

	Result := opDisplace(xx);
end;






procedure TDisplacement.PrepareFrame;
begin
  //Camera animation
  vuv:=v1;//Change camere up vector here
  vrp:=v1; //Change camere view here
  prp:=vec3.create(0,2,iGlobalTime); //Change camera path position here

  //Camera setup
  vpn:=normalize(vrp-prp);
  u:=normalize(cross(vuv,vpn));
  v:=cross(vpn,u);
  vcv:=(prp+vpn);
end;

function TDisplacement.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var vPos:Vec2;
  scrCoord, scp,c,p,n,fc:Vec3;
  f,objDist,b:float;
  I: Integer;
begin
  vPos:=-1.0+2.0*gl_FragCoord.xy/resolution.xy;
  vPos.x := vPos.x - 0.5;


  scrCoord:=vcv+vPos.x*u*resolution.x / resolution.y+vPos.y*v;
  scp:=normalize(scrCoord-prp);

  //Raymarching



  f:=0.0;
  objDist:=1.0;
  for I := 0 to NaN-1 do
  begin
    if (abs(objDist)<0.005) or (f>maxd) then
      break;
    f:=f +objDist;
    p:=prp+scp*f;
    objDist:=sceneDistance(p);

  end;

  if (f<maxd) then
  begin
    c := c2;
    n:=normalize(
      vec3.create(objDist-sceneDistance(p-e_xyy),
                  objDist-sceneDistance(p-e_yxy),
                  objDist-sceneDistance(p-e_yyx)));
    b:=dot(n,-scp);
	  fc := b*c;
    Result := TColor32((b*c+pow(b,8))*(1-f*0.01));//simple phong LightPosition=CameraPosition
  end
  else
    Result := clBlack32; //background color
end;

initialization

Displacement := TDisplacement.Create;
Shaders.Add('Displacement', Displacement);

finalization

FreeandNil(Displacement);

end.
