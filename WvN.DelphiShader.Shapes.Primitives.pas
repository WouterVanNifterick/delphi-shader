unit WvN.DelphiShader.Shapes.Primitives;

interface

uses WvN.DelphiShader.Shader;


implementation

uses Math;

function Sphere(p:Vec3;s:TVecType):double;
begin
  Result := length(p)-s;
end;

function udBox( p, b:vec3 ):TVecType;
begin
  Result := length(max(abs(p)-b,0.0));
end;

function sdBox( p,b:vec3 ):Double;
var di:vec3;mc:Double;
begin
  di := abs(p) - b;
  mc := math.MaxComp;
  Result := math.min(mc,length(max(di,0.0)));
end;

function udRoundBox( p, b:vec3; r:Double ):TVecType;
begin
  Result := length(max(abs(p)-b,0.0))-r;
end;

function sdTorus( p:vec3; t:vec2 ):TVecType;
var
  q:vec2;
begin
  q := vec2.create(length(p.xz)-t.x,p.y);
  Result := length(q)-t.y;
end;

function sdCone( p:vec3; c:vec2 ):TVecType;
var q:Double;
begin
  // c must be normalized
  q := length(p.xy);
  Result := dot(c,vec2.create(q,p.z));
end;


function Union(d1,d2:Double): double;
begin
  Result := math.min(d1, d2);
end;

function Subtraction(d1,d2:Double): double;
begin
  Result := max(-d1, d2);
end;

function map( p:vec3  ):Vec4;
var m:Integer;
d:Double;
begin
   d := sdBox(p,vec3(1.0));
   Result  := vec4.create( d, 1.0, 0.0, 0.0 );
   for m:=0 to 2 do
   begin
{      a := fmod( p*s, 2.0 )-1.0;
      s *= 3.0;
      vec3 r = abs(1.0 - 3.0*abs(a));

      float da = max(r.x,r.y);
      float db = max(r.y,r.z);
      float dc = max(r.z,r.x);
      float c = (min(da,min(db,dc))-1.0)/s;

      if( c>d ) then
      begin
          d = c;
          res = vec4( d, 0.2*da*db*dc, (1.0+float(m))/4.0, 0.0 );
      end;
}
   end;
end;

function Intersection(d1,d2:Double): double;
begin
  Result := math.max(d1, d2);
end;




end.
