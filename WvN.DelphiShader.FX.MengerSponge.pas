unit WvN.DelphiShader.FX.MengerSponge;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMengerSponge=class(TShader)
    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  MengerSponge:TShader;

implementation

uses SysUtils, Math;


const
  half=0.5;

constructor TMengerSponge.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TMengerSponge.PrepareFrame;
begin

end;

function maxcomp(const p:vec3):float;
begin
  Result := Math.Max(p.x,Math.Max(p.y,p.z));
end;

function sdBox( const p:vec3; b:vec3):float;
var di:vec3; mc:float;
begin
  di := abs(p) - b;
  mc := maxcomp(di);
  Result := Math.min(mc,length(max(di,0.0)));
end;

function map(const p:vec3):vec3;
var
  s:float;
  res:vec4;
  da,db,dc,c,d:float;
  a,r:vec3 ;
  m:Integer;
begin
   d := sdBox(p,vec3(1.0));
   res := vec4.create( d, 1.0, 0.0, 0.0 );

   s := 1.0;
   for m:=0 to 4 do
   begin
      a.x := fmod( p.x * s, 2.0 )-1.0;
      a.y := fmod( p.y * s, 2.0 )-1.0;
      a.z := fmod( p.z * s, 2.0 )-1.0;

      s := s * 3.0;
      r := abs(1.0 - 3.0*abs(Vec3(a)));

      da := Math.max(r.x,r.y);
      db := Math.max(r.y,r.z);
      dc := Math.max(r.z,r.x);
      c := (Math.min(da,Math.min(db,dc))-1.0)/s;

      if c > d then
      begin
          d := c;
          res := vec4.create( d, 0.2*da*db*dc, (1.0+m)/4.0, 0.0 );
      end;
   end;

   Result := res.xyz;
end;


function intersect( const ro,rd:vec3):vec4;
var t:TVecType;i:Integer;h:vec4;
begin
    t := 0.0;
    for I := 0 to 63 do
    begin
        h := vec4(map(ro + rd * t));
        if( h.x<0.005 )then
            exit(vec4.create(t,h.yzw));
        t := t + h.x;
     end;
    Result := vec4.create(-1.0);
end;


function calcNormal(const pos:vec3):vec3;
var eps,nor:vec3;
begin
    eps := vec3.Create(0.001,0.0,0.0);
    nor.x := map(pos+eps.xyy).x - map(pos-eps.xyy).x;
    nor.y := map(pos+eps.yxy).x - map(pos-eps.yxy).x;
    nor.z := map(pos+eps.yyx).x - map(pos-eps.yyx).x;
    Result := normalize(nor);
end;

function TMengerSponge.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var p : vec2;
matcol,ro,ww,uu,vv,rd,light,col, pos,nor:vec3;
cTime:Double;
shadow,tmat:vec4;
dif1,dif2,ldis,ao:float;

begin
  p.x := -1.0 + 2.0 * gl_FragCoord.x / Resolution.x;
  p.y := -1.0 + 2.0 * gl_FragCoord.y / Resolution.y;
  p.x := p.x * 1.33;

//    p.x := gl_FragCoord.x;
//    p.y := gl_FragCoord.y;

    // light
    light := normalize(vec3.create(1.0,0.8,-0.6));

    ctime := iGlobalTime;
    // camera
    ro := 1.1*vec3.create(
                2.5*system.cos(0.5*ctime),
                1.5*system.cos(ctime*0.23),
                2.5*system.sin(0.5*ctime));
    ww := normalize(vec3(0.0) - ro);
    uu := normalize(cross( vec3.create(0.0,1.0,0.0), ww ));
    vv := normalize(cross(ww,uu));
    rd := normalize( p.x*uu + p.y*vv + 1.5*ww );

    col := vec3(0.0);
    tmat := intersect(ro,rd);
    if( tmat.x>0.0 ) then
    begin
        pos := ro + tmat.x*rd;
        nor := calcNormal(pos);

        dif1 := max(0.4 + 0.6*dot(nor,light),0.0);
        dif2 := max(0.4 + 0.6*dot(nor,vec3.create(-light.x,light.y,-light.z)),0.0);

        // shadow
         ldis := 4.0;
        shadow := intersect( pos + light*ldis, -light );
        if( (shadow.x>0.0) and (shadow.x<(ldis-0.01)) ) then
          dif1:=0.0;

        ao  := tmat.y;
        col := 1.0*ao*vec3.create(0.2,0.2,0.2);
        col := col + (2.0*(0.5+0.5*ao)*dif1*vec3.create(1.0,0.97,0.85));
        col := col + (0.2*(0.5+0.5*ao)*dif2*vec3.create(1.0,0.97,0.85));
        col := col + (1.0*(0.5+0.5*ao)*(0.5+0.5*nor.y)*vec3.create(0.1,0.15,0.2));

        // gamma lighting
        col.x := col.x*0.5+0.5*system.sqrt(col.x)*1.2;
        col.y := col.y*0.5+0.5*system.sqrt(col.y)*1.2;
        col.z := col.z*0.5+0.5*system.sqrt(col.z)*1.2;

        matcol := vec3.create(
            0.6+0.4*system.cos(5.0+6.2831*tmat.z),
            0.6+0.4*system.cos(5.4+6.2831*tmat.z),
            0.6+0.4*system.cos(5.7+6.2831*tmat.z) );

        col := col * matcol;
        col := col * (1.5*exp(-0.5*tmat.x));
    end;

    Result := Tcolor32(col);
end;


initialization
  MengerSponge := TMengerSponge.Create;
  Shaders.Add('MengerSponge',MengerSponge);
finalization
  FreeandNil(MengerSponge);
end.


