unit WvN.DelphiShader.Shader;

interface

uses Classes, SysUtils, GR32, Generics.Collections, Diagnostics, types, Math, Forms;

const ThreadCount=16;
type
  TTextureCube=record
	  type
      TFace=(
        POSITIVE_X,
        NEGATIVE_X,
        POSITIVE_Y,
        NEGATIVE_Y,
        POSITIVE_Z,
        NEGATIVE_Z,
        FACE_MAX
	   );
    var
      Empty:Boolean;
      Faces:Array[TFace] of TBitmap32;
    procedure Load(Mask:string);
  end;

type
  TVecType = type double;
  int      = type Integer;
  bool     = type Boolean;
  Float    = type double;
  PVec2    = ^Vec2;
  PVec3 = ^Vec3;
  PVec4    = ^Vec4;

  Vec2 = record
    x, y: TVecType;
    function Length: TVecType;{$IFNDEF DEBUG} inline;{$ENDIF}
    function Normalize: PVec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function Cross(const b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function Dot(const b: Vec2): TVecType; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure LoadTextures;
    constructor create(ax, ay: TVecType);overload;
    constructor create(ax: TVecType);overload;
    class operator explicit(const b:TVecType):Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Add(const a, b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Add(const a: Vec2; b: TVecType): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Add(a: TVecType; const b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Subtract(const a, b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Subtract(const a: Vec2; b: TVecType): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Subtract(a: TVecType; const b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a: Vec2; const b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a: Vec2; b: TVecType): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(a: TVecType; const b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Divide(const a: Vec2; const b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Divide(const a: Vec2; b: TVecType): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Divide(a: TVecType; const b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Negative(const a: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Explicit(const a: Vec2): TPoint;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Explicit(const a: Vec2): TPointF;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Explicit(const a: TPoint): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Explicit(const a: TPointF): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}

    function rg:vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xy:vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yx:vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xx:vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yy:vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yxx:PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xyx:PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xxy:PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xyy:PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yxy:PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yyx:PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xxx:PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yyy:PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
  end;

  Vec3 = record
    function Length: TVecType;{$IFNDEF DEBUG} inline;{$ENDIF}
    function Normalize: PVec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure NormalizeSelf;{$IFNDEF DEBUG} inline;{$ENDIF}
    function Abs: Vec3; {$IFNDEF DEBUG} inline;{$ENDIF}
    function Cross(const b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function Dot(const b: Vec3): TVecType; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
    constructor create(ax, ay, az: TVecType);overload;
    constructor create(ax: TVecType);overload;
    constructor create(const xy:Vec2;az: TVecType);overload;
    constructor create(aX:TVecType;const yz:Vec2);overload;
    class operator Subtract(const a, b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Subtract(const a: Vec3; const b: Vec2): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Subtract(const a:Vec2; const b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}

    class operator Add(const a, b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Add(const a: Vec3; b: TVecType): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Negative(const a: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a: Vec3; const b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a: Vec3; b: TVecType): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(a: TVecType; const b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Divide(const a: Vec3; const b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Divide(const a: Vec3; b: TVecType): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Implicit(a: TVecType): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Explicit(const a: Vec3): TColor32;{$IFNDEF DEBUG} inline;{$ENDIF}

    class operator Equal(const a,b:Vec3):Boolean;{$IFNDEF DEBUG} inline;{$ENDIF}

    function GetXZ: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure SetXZ(const a:Vec2);{$IFNDEF DEBUG} inline;{$ENDIF}
    property xz: Vec2 read GetXZ write setXZ;

    function GetXY: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure SetXY(const a:Vec2);{$IFNDEF DEBUG} inline;{$ENDIF}
    property XY: Vec2 read GetXY write setXY;

    function GetZX: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure SetZX(const Value: Vec2);
    property ZX: Vec2 read GetZX write SetZX;

    function getyz: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure SetYZ(const Value: vec2);{$IFNDEF DEBUG} inline;{$ENDIF}
    property yz:vec2 read getYZ write SetYZ;

    function rg: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function zy: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xyz:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xyy:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yxy:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yyx:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yzx:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function zxy:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function zzx:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function zyx:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yxz:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function yxx:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xyx:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    function xxy:vec3;{$IFNDEF DEBUG} inline;{$ENDIF}

    case RecType: Byte of
      0:(x, y, z: TVecType);
      1:(r, g, b: TVecType);
  //    2:(rgb:array[0..2] of TVecType);
  end;

  Vec4 = record
    function Dot(const b: Vec4): TVecType; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
    constructor create(x: TVecType); overload;
    constructor create(x, y, z, w: TVecType); overload;
    constructor create(const x: Vec3; w: TVecType); overload;
    constructor create(w: TVecType;const ax: Vec3 ); overload;
    class operator Implicit(const a: Vec3): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Explicit(const a: Vec4): TColor32;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a: Vec4; b: TVecType): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a: TVecType; const b: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a,b: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a:vec3;const b: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a:vec4;const b: Vec3): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Divide(const a:vec4;b: TVecType): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Divide(const a:vec4;b: int64): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Add(const a, b: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Add(a:TVecType; const b: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Add(const a:Vec4; b: TVecType): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Subtract(const a,b: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Negative(const a: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}

    function getxy: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure setxy(const a:Vec2);
    property xy:Vec2 read getxy write setxy;

    function getxz: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure setxz(const a:Vec2);
    property xz:Vec2 read getxz write setxz;

    function getyw: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure setyw(const a:Vec2);
    property yw:Vec2 read getyw write setyw;

    function getyz: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure setyz(const a:Vec2);
    property yz:Vec2 read getyz write setyz;

    function getyx: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure setyx(const a:Vec2);
    property yx:Vec2 read getyx write setyx;

    function getzw: Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure setzw(const a:Vec2);
    property zw:Vec2 read getzw write setzw;


    function getrgb: Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure setrgb(const a:Vec3);
    property rgb:Vec3 read getrgb write setrgb;

    function getxyz: Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    procedure setxyz(const a:Vec3);
    property xyz:Vec3 read getxyz write setxyz;


    function yzw: Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}

    case RecType: byte of
      0:(x, y, z, w: TVecType);
      1:(r, g, b, a: TVecType);
  end;

  Mat2 = record
    r1,r2:Vec2;
    constructor Create(a1,a2,b1,b2:TVecType);
    class operator Multiply(const a:Mat2;const b:Vec2):Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const b:Vec2;const a:Mat2):Vec2;{$IFNDEF DEBUG} inline;{$ENDIF}
  end;

  Mat3 = record
    r1,r2,r3:Vec3;
    constructor Create(a1,a2,a3,b1,b2,b3,c1,c2,c3:TVecType);overload;
    constructor Create(const a,b,c:Vec3);overload;
    class operator Multiply(const a:Mat3;const b:Vec3):Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Multiply(const a:Vec3;const b:Mat3):Vec3;
    class operator Multiply(const a:Mat3;const b:Mat3):Mat3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Add(const a:Mat3;const b:Vec3):Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
    class operator Negative(const a: Mat3): Mat3;{$IFNDEF DEBUG} inline;{$ENDIF}
  end;

  Mat4 = record
    r1,r2,r3,r4:Vec4;
    constructor Create(a1,a2,a3,a4,b1,b2,b3,b4,c1,c2,c3,c4,d1,d2,d3,d4:TVecType);
    class operator Multiply(const a:Mat4;const b:Vec4):Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
  end;

function pow(x, y: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function radians(degrees: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return T(M_PI/180)*degrees; }
function degrees(radians: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return T(180/M_PI)*radians; }
function exp2(x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;        { return T(cmath::exp(x * M_LN2)); }
function log(x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;        { return T(cmath::log(x) / M_LN2); }
function log2(x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;        { return T(cmath::log(x) / M_LN2); }
function inversesqrt(x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return 1/cmath::sqrt(x); }
function sign(x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;        { return T((x>0) ? T(1) : ((x<0) ? T(-1):T(0))); }
function fract(x: Double): Double;{inline;}overload;       { return x - cmath::floor(x); }
function fract(const x: Vec2): Vec2;inline;overload;       { return x - cmath::floor(x); }
function fract(const x: Vec3): Vec3;inline;overload;       { return x - cmath::floor(x); }
function fract(const x: Vec4): Vec4;inline;overload;       { return x - cmath::floor(x); }

//function floor(x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
function floor(const x: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
function floor(const x: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
function floor(const x: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }


function clamp(x:Double; minVal:Double; maxVal: Double): Double;inline; overload; { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(x:Double): Double;inline; overload;
function distance(p0, p1: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return length(p0-p1); }
function Dot(x, y: Single): Single;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return x*y; }
function Dot(x, y: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return x*y; }
function Dot(const x, y: Vec2): Double; overload;{$IFNDEF DEBUG} inline;{$ENDIF}   { return x*y; }
function Dot(const x, y: Vec3): Double; overload;{$IFNDEF DEBUG} inline;{$ENDIF}   { return x*y; }
function Dot(const x, y: Vec4): Double; overload;{$IFNDEF DEBUG} inline;{$ENDIF}   { return x*y; }

function Reflect(I, n: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return I - T(2)*N*I*N; }
function Reflect(const I, n: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return I - T(2)*N*I*N; }

function FaceForward(const N,I,NRef:TVecType): TVecType;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function FaceForward(const N,I,NRef:Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function FaceForward(const N,I,NRef:Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function FaceForward(const N,I,NRef:Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;

function Refract(const I, N:TVecType; eta:Double):TVecType;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function Refract(const I, N:vec2; eta:Double):vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function Refract(const I, N:vec3; eta:Double):vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function Refract(const I, N:vec4; eta:Double):vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;



function Abs(const x: TVecType): TVecType; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function Abs(const x: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function Abs(const x: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function Abs(const x: Vec4): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}

function acos(x:TVecType):TVecType;{$IFNDEF DEBUG} inline;{$ENDIF}
function atan(x:TVecType):TVecType;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function atan(x,y:TVecType):TVecType;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function tan(x:TVecType):TVecType;{$IFNDEF DEBUG} inline;{$ENDIF}



function Cross(const a,b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}

function smoothstep(edge0, edge1, x: Double): Double; {$IFNDEF DEBUG} inline;{$ENDIF}  overload; { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
function smoothstep(const edge0, edge1, x: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF} { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
function smoothstep(const edge0, edge1, x: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
function smoothstep(const edge0, edge1, x: Vec4): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF} { T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }


function distance(const a,b: Vec2): double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return length(p0-p1); }
function distance(const a,b: Vec3): double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return length(p0-p1); }
function distance(const a,b: Vec4): double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return length(p0-p1); }

// function &mod(a, b: single): single;  overload;
//function fmod(a, b: extended): Extended;overload;
function fmod(a, b: single): Single;overload;
function fmod(a, b: double): Double;overload;

function &mod(a, b: Double): Double;{$IFDEF CPUx64}inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }

function &mod(const a, b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
function &mod(const a, b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
function &mod(const a, b: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }

function &mod(const a: Vec2;b:TVecType): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
function &mod(const a: Vec3;b:TVecType): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
function &mod(const a: Vec4;b:TVecType): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }


function min(x, y: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return y < x ? y : x; }
function min(const x, y: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}        { return y < x ? y : x; }
function min(const x, y: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function min(const x, y: Vec4): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}

function max(x, y: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return x < y ? y : x; }
function max(const x, y: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}        { return x < y ? y : x; }
function max(const x, y: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}       { return x < y ? y : x; }
function max(const x, y: Vec4): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}       { return x < y ? y : x; }
function maxComp(const p: Vec3): Double; overload;{$IFNDEF DEBUG} inline;{$ENDIF}

function pow(const x, y: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function pow(const a, b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function pow(const x, y: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;

function sqrt(const a: TVecType): TVecType;{$IFNDEF DEBUG} inline; {$ENDIF} overload;
function sqrt(const a: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function sqrt(const a: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function sqrts(const a: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function sqrt(const a: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;

function clamp(const x, minVal, maxVal: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(const x, minVal, maxVal: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(const x:Vec2; minVal, maxVal: Double): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(const x:Vec3; minVal, maxVal: Double): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
function clamp(const x:Vec4; minVal, maxVal: Double): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }

function mix(x, y, a: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return x*(1-a) + y*a; }
function mix(const x, y, a: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return x*(1-a) + y*a; }
function mix(const x, y, a: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return x*(1-a) + y*a; }
function mix(const x, y, a: Vec4): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return x*(1-a) + y*a; }

function mix(const x, y:Vec2; a: TVecType): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return x*(1-a) + y*a; }
function mix(const x, y:Vec3; a: TVecType): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return x*(1-a) + y*a; }
function mix(const x, y:Vec4; a: TVecType): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return x*(1-a) + y*a; }

function step(edge, x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return x<=edge ? T(0) : T(1); }
function step(const edge, x: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF} { return x<=edge ? T(0) : T(1); }
function step(const edge, x: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF} { return x<=edge ? T(0) : T(1); }
function step(const edge, x: Vec4): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF} { return x<=edge ? T(0) : T(1); }

function Length(x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return cmath::sqrt(x*x); }
function Length(const x: Vec2): Double; overload;{$IFNDEF DEBUG} inline;{$ENDIF}    { return cmath::sqrt(x*x); }
function Length(const x: Vec3): Double; overload;{$IFNDEF DEBUG} inline;{$ENDIF}    { return cmath::sqrt(x*x); }
function Length(const x: Vec4): Double; overload;{$IFNDEF DEBUG} inline;{$ENDIF}    { return cmath::sqrt(x*x); }
function length_sq(const x: Vec3): Double; overload;{$IFNDEF DEBUG} inline;{$ENDIF} { return cmath::sqrt(x*x); }

function Normalize(x:double): Double; { return T(1); } inline; overload; // this is not the most useful function in the world
function Normalize(const v: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function Normalize(const v: Vec3): Vec3;{$IFNDEF DEBUG} inline; {$ENDIF} overload;
function normalizeS(const v:Vec3) : vec3;inline;{$IFNDEF DEBUG} inline; {$ENDIF} overload;

function Normalize(const v: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;

function texture2DLQ(tex:TBitmap32;const Coords:Vec2):Vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function texture2DHQ(tex:TBitmap32;const Coords:Vec2):Vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function texture2D(tex: TBitmap32; const Coords: Vec2): Vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function texture2D(tex: TBitmap32; const Coords: Vec2; Bias:Float): Vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function textureCube(tex: TBitmap32; const Coords: Vec3): Vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function textureCube(const tex: TTextureCube; const Coords: Vec3): Vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF}


//function sin(const x: TVecType): TVecType; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function sin(const x: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function sin(const x: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function sin(const x: Vec4): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}

function cos(const x: Vec2): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function cos(const x: Vec3): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function cos(const x: Vec4): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}

procedure cos(const x: Vec2;out Result:vec2); overload;{$IFNDEF DEBUG} inline;{$ENDIF}
procedure cos(const x: Vec3;out Result:vec3); overload;{$IFNDEF DEBUG} inline;{$ENDIF}
procedure cos(const x: Vec4;out Result:vec4); overload;{$IFNDEF DEBUG} inline;{$ENDIF}

procedure Mult(const input: Vec3;out Result:vec3);inline;

function Ifthen(c:Boolean;const a,b:Vec2):Vec2;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function Ifthen(c:Boolean;const a,b:Vec3):Vec3;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
function Ifthen(c:Boolean;const a,b:Vec4):Vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF}

/// <summary>
///  Available only in the fragment shader, dFdx and dFdy return the partial derivative of expression p in x and y, respectively.
///  Deviatives are calculated using local differencing.
///  Expressions that imply higher order derivatives such as dFdx(dFdx(n)) have undefined results,
//   as do mixed-order derivatives such as dFdx(dFdy(n)).
//   It is assumed that the expression p is continuous and therefore,
//   expressions evaluated via non-uniform control flow may be undefined.
/// </summary>
//function dFdx(a:TVecType):TVecType;
//function dFdx(a:Vec2):Vec2;
//function dFdx(a:Vec3):Vec3;
//function dFdx(a:Vec4):Vec4;

function fwidth(const a: Vec2): TVecType;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function fwidth(const a: Vec3): TVecType;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function fwidth(const a: Vec4): TVecType;{$IFNDEF DEBUG} inline;{$ENDIF} overload;

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
function hash(n:Double):Double;overload;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function hash(const n:vec2):vec2;overload;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function hash(const n:vec3):vec3;overload;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
function hash(const n:vec4):vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF} overload;

type
  {$scopedenums on}
  TFrameProc   = procedure of object;
  TPixelProc   = function(var gl_FragCoord:Vec2): TColor32 of object;
  TLineProc    = procedure(y:Integer) of object;
  TProgressProc= procedure(Progress,Total:Integer) of object;

type
  TRenderMode = (Simple,Sections,Frames);

type
  TShader = class
  private
    LastFrame:Int64;
    FThreaded: TRenderMode;
    function GetFPS: Double;
  protected
    UseBackBuffer:Boolean;
    StopWatch:TStopwatch;
    FrameProc: TFrameProc;
    LineProc:TLineProc;

    Buffer,BackBuffer:TBitmap32;
  public
    iMouse:Vec4;
    Mouse:Vec3;
    PixelProc: TPixelProc;
    Frame:Int64;
    Time: double;
    Resolution:Vec2;

  class var
    tex : TArray<TBitmap32>;
    cubes:TArray<TTextureCube>;
  var
    iGlobalTime:double;
    OnProgress:TProgressProc;
    OnResize:TNotifyEvent;
    class constructor Create;
    class destructor DestroyClass;
    class procedure LoadTexture(var bitmap:TBitmap32;const FileName:String);static;

    procedure updateFrame;
    constructor Create;virtual;
    destructor Destroy; override;
    procedure RenderTo(bitmap:TBitmap32);overload;virtual;
    procedure RenderTo(bitmap:TBitmap32; const Rect:TRect);overload;
    property FPS:Double read GetFPS;
    property Mode:TRenderMode read FThreaded write FThreaded;
    procedure ResetFPS;
    procedure SetSize(aWidth,aHeight:integer);
  end;

  TThreadedShader=class(TShader)
  public
    Shaders:array[0..3] of record
      Area:Vec4;
      Shader:TShader;
      Rect:TRect;
      Thread:TThread;
    end;
    procedure RenderThreads(bitmap:TBitmap32);
    constructor Create(aShader:TShader);reintroduce;
  end;

  TShaderList=TDictionary<string,TShader>;


procedure RegisterShader(name:String;c:TShader);
function GetShader(name:string):TShader;
function Shaders:TShaderList;

const
  vec2Black:Vec2=(x:0;y:0);
  vec2White:Vec2=(x:1;y:1);
  vec2Gray:Vec2=(x:0.5;y:0.5);
  vec2_3_3:Vec2=(x:3;y:3);

  vec3Black:Vec3=(x:0;y:0;z:0);
  vec3White:Vec3=(x:1;y:1;z:1);
  vec3Gray:Vec3=(x:0.5;y:0.5;z:0.5);

  vecBlack:Vec3=(x:0;y:0;z:0);
  vecWhite:Vec3=(x:1;y:1;z:1);
  vecGray:Vec3=(x:0.5;y:0.5;z:0.5);
  vecGreen:Vec3=(x:0;y:1;z:0);

  vec4Black:Vec4=(x:0;y:0;z:0;w:0);
  vec4White:Vec4=(x:1;y:1;z:1;w:1);
  vec4Gray:Vec4=(x:0.5;y:0.5;z:0.5;w:0.5);

{
type
  TFrameThread=class(TThread)
  public
    IsDone:Boolean;
    Bitmap:TBitmap32;
    Time:Double;
    proc:TPixelProc;
    Width,Height:Integer;
  protected
    procedure Execute; override;
    procedure Resize;
  end;

type
  TFrames=record
    ItemIndex:Integer;
    Threads:Array[0..ThreadCount-1] of tframeThread;
    procedure Setproc(const Value: TPixelProc);
    property proc:TPixelProc write Setproc;
    procedure Init(p:TPixelProc;t:double);
    procedure SetSize(w,h:Integer);
    procedure Resume;
    procedure Suspend;
  end;
var
  Frames:TFrames;
 }

implementation

uses jpeg, pngimage, IoUtils;

const
  M_LN2 = 0.693147180559945309417;

var FShaders:TShaderList;

function Shaders:TShaderList;
begin
  if FShaders=nil then
    FShaders := TShaderList.Create;
  Result := FShaders;
end;

procedure RegisterShader(name:String;c:TShader);
begin
  Shaders.Add(name,c);
end;
function GetShader(name:string):TShader;
begin
  Shaders.TryGetValue(name,Result);
end;


function EnsureRange(const AValue, AMin, AMax: Single): Single;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
begin
  Result := AValue;
  assert(AMin <= AMax);
  if Result < AMin then
    Result := AMin;
  if Result > AMax then
    Result := AMax;
end;

function EnsureRange(const AValue, AMin, AMax: Double): Double;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
begin
  Result := AValue;
  assert(AMin <= AMax);
  if Result < AMin then
    Result := AMin;
  if Result > AMax then
    Result := AMax;
end;

constructor TShader.create;
begin
  inherited;
  Frame := 0;
  UseBackBuffer := False;
  StopWatch := TStopwatch.StartNew;
  Buffer := TBitmap32.create;
  Buffer.ResamplerClassName := 'TLinearResampler';
  Buffer.ResamplerClassName := 'TNearestResampler';
  Buffer.SetSize(64, 64);
  BackBuffer := TBitmap32.create;
  BackBuffer.SetSize(64,64);
  Resolution.x := Buffer.Width;
  Resolution.y := Buffer.Height;
  //Frames.Proc := PixelProc;
  Mouse.x := 0.5;
  Mouse.y := 0.5;
  iMouse.x := Resolution.x * 0.5;
  iMouse.y := Resolution.y * 0.5;
end;

class constructor TShader.Create;
var s:String; c:integer; imgpath:string;
begin
  setlength(tex,0);
  SetCurrentDir( ExtractFilePath(ParamStr(0)));

  imgpath := 'images';

  if not TDirectory.Exists('images') then
  begin
    imgPath := '../images';
    if not TDirectory.Exists('images') then
    begin
      raise EFileNotFoundException.CreateFmt('Image folder not found. Expected images in %s or %s',[ExpandFileName('images/'), ExpandFileName('../images/')]);
    end;
  end;

  for s in TDirectory.GetFiles(imgpath,'tex*.jpg') do
  begin
    setlength(tex,System.Length(tex)+1);
    tex[high(tex)] := TBitmap32.create;
    LoadTexture(tex[high(tex)],s);
  end;
  for s in TDirectory.GetFiles(imgpath,'tex*.png') do
  begin
    setlength(tex,System.Length(tex)+1);
    tex[high(tex)] := TBitmap32.create;
    LoadTexture(tex[high(tex)],s);
  end;
  setlength(cubes,6);
  for c := 0 to 5 do
  begin
    if FileExists(format(imgpath+'/cube0%d_0.jpg',[c])) then
      cubes[c].Load(format(imgpath+'/cube0%d_?.jpg',[c]));
    if FileExists(format(imgpath+'/cube0%d_0.png',[c])) then
      cubes[c].Load(format(imgpath+'/cube0%d_?.png',[c]));
  end;
end;

destructor TShader.Destroy;
begin
//  Buffer.Free;
//  BackBuffer.Free;
  inherited;
end;

class destructor TShader.DestroyClass;
// var bmp:TBitmap32;c:TTextureCube;
begin
//  for bmp in tex do
//    bmp.free;
//
//  for c in cubes do
//    for bmp in c.Faces do
//      bmp.Free;

  inherited;
end;

function TShader.GetFPS: Double;
begin
  if StopWatch.ElapsedMilliseconds=0 then
    Result := 0
  else
    Result := (Frame - LastFrame)/StopWatch.ElapsedMilliseconds*1000;
end;



class procedure TShader.LoadTexture(var bitmap: TBitmap32; const FileName: String);
var
  jpg: tjpegImage;
  png: TPngImage;
begin
  if SameText(ExtractFileExt(filename),'.jpg') then
  begin
    jpg := tjpegImage.Create;
    try
      jpg.LoadFromFile(FileName);
      Bitmap.Assign(jpg);
    finally
      jpg.Free;
    end;
  end;


  if SameText(ExtractFileExt(filename),'.png') then
  begin
    png := tpngImage.Create;
    try
      png.LoadFromFile(FileName);
      Bitmap.Assign(png);
    finally
      png.Free;
    end;
  end;

end;

{
type
  TRenderThread=class(TThread)
  public
    Buffer:TBitmap32;
    x1,x2,y1,y2:Integer;
    proc:TPixelProc;
  protected
    procedure Execute; override;
  end;

  procedure TRenderThread.Execute;
  var x,y:Integer; fracCoord:Vec2;
  begin
    FreeOnTerminate := True;
    for y := y1 to y2 do
      for x := x1 to x2 do
      begin
        fracCoord.x := x;
        fracCoord.y := y;
        Buffer.Pixel[x,y] := proc(fracCoord);
      end;
    Terminate;
  end;


  procedure TFrameThread.Execute;
  var x,y:Integer; fracCoord:Vec2;
  begin
    FreeOnTerminate := True;
    while True do
    begin
      if Suspended then
        Continue;
      if assigned(proc) then
      begin
        self.Time := time + 0.4;
        Resize;
        for y := 0 to Bitmap.Height-1 do
          for x := 0 to Bitmap.Width-1 do
          begin
            fracCoord.x := x;
            fracCoord.y := y;
            Bitmap.Pixel[x,y] := proc(fracCoord);
          end;
        IsDone := True;
      end;

        repeat
          sleep(1);
        until (IsDone=false) or (not Assigned(proc));
    end;
    Terminate;
  end;
 }

procedure TShader.RenderTo(bitmap: TBitmap32);
var
  px, py   : Integer;
  fracCoord: Vec2;
begin
//  updateFrame;
  if Assigned(FrameProc) then
    FrameProc;

  if not Assigned(PixelProc) then
    Exit;

    for py := 0 to Buffer.Height - 1 do
    begin
      if assigned(OnProgress) then
        OnProgress(py,Buffer.Height);

      if Assigned(LineProc) then
        LineProc(py);

      fracCoord.y := Buffer.Height - py - 1;
      for px := 0 to Buffer.Width - 1 do
      begin
        fracCoord.x := px;
        Buffer.Pixel[px, py] := PixelProc(fracCoord);
      end;
    end;

  Buffer.DrawTo(bitmap);

  if UseBackBuffer then
    bitmap.DrawTo(BackBuffer,0,0);

  inc(Frame);
end;


procedure TShader.RenderTo(bitmap: TBitmap32; const Rect: TRect);
var
  px, py   : Integer;
  fracCoord: Vec2;
begin
//  updateFrame;
  if Assigned(FrameProc) then
    FrameProc;

    for py := rect.Top to rect.Bottom-1 do
    begin
      if assigned(OnProgress) then
        OnProgress(py,rect.Height);

      if Assigned(LineProc) then
        LineProc(py);

      fracCoord.y := rect.Height - py - 1;
      for px := rect.Left to rect.Right-1 do
      begin
        fracCoord.x := px;
        Buffer.Pixel[px, py] := PixelProc(fracCoord);
      end;
    end;

  Buffer.DrawTo(bitmap);

  if UseBackBuffer then
    bitmap.DrawTo(BackBuffer,0,0);

  inc(Frame);
end;

procedure TShader.ResetFPS;
begin
  LastFrame := Frame;
  StopWatch.Reset;
  StopWatch.Start;
end;


procedure TShader.SetSize(aWidth, aHeight: integer);
begin
  if (aWidth  = Resolution.x) and
     (aHeight = Resolution.y)
  then
    Exit;

  Resolution := Vec2.create(aWidth,aHeight);
  Buffer.SetSize(aWidth,aHeight);
  if UseBackBuffer then
    BackBuffer.SetSize(aWidth,aHeight);

  if Assigned(OnResize) then
    OnResize(self);
end;


procedure TShader.updateFrame;
begin
  iGlobalTime := StopWatch.GetTimeStamp/2500000;

//  Time := now*100000;
  Time := iGlobalTime;

end;



{
function fmod(a, b: extended): extended;
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * floor(a / b);
end;

function fmod(a, b: double): double;
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * floor(a / b);
end;
}

function fmod(a, b: single): single;overload;
{$IFDEF CPUx86}
asm
  fld dword ptr[b]
  fld dword ptr[a]
@r:
  fprem
  fstsw ax
  sahf
  jp @r
  fstp st(1)
end;
{$ELSE}
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * math.floor(a / b);
end;
{$ENDIF}

function fmod(a, b: double): double;overload;
{$IFDEF CPUx86}
asm
  fld qword ptr[b]
  fld qword ptr[a]
@r:
  fprem
  fstsw ax
  sahf
  jp @r
  fstp st(1)
end;
{$ELSE}
begin
  if IsZero(b) then
    Exit(0);

  if a>1e10 then
    Exit(0);
  if a<-1e10 then
    Exit(0);

	Result := a - b * math.floor(a / b);
end;
{$ENDIF}


/// <summary>
/// pow returns the value of x raised to the y power. i.e., xy. Results are undefined if x0 or if x0 and y0.
/// </summary>
function pow(x,y:double):double;
begin
  if IsNaN(x) then
    Exit(0.000001);

  if x<0 then
    Exit(0.000001);
  if (x=0) and (y<0) then
    Exit(0.000001);

  Result := Math.Power(x,y)
end;
function radians(degrees: double): double;
begin
  Result := (pi / 180) * degrees;
end;

function degrees(radians: double): double;
begin
  Result := (180 / pi) * radians;
end;

function exp2(x: double): double;
begin
  Result := (System.Exp(x * M_LN2));
end;

function log(x: double): double;
begin
  Result := (Math.log2(x) / M_LN2);
end;

function log2(x: double): double;
begin
  Result := (Math.log2(x) / M_LN2);
end;

function inversesqrt(x: double): double;
begin
  Result := 1 / System.Sqrt(x);
end;

function sign(x: double): double;
begin
  if x > 0 then
    Result := 1
  else if x < 0 then
    Result := -1
  else
    Result := 0;
end;

function fract(x: double): double;
begin
//  Result := x - Math.Floor(x);
//  if IsNan(x) then  Exit(0);
  if x>1e30 then
    exit(0);
  if x<-1e30 then
    exit(0);

  Result := Trunc(X);
  if (X < 0) and (X - Result <> 0) then
    Result := Result-1;
   Result := x - Result;
end;

function fract(const x: vec2): vec2;
begin
//  Result.x := x.x - Math.Floor(x.x);
//  Result.y := x.y - Math.Floor(x.y);

  Result.x := Trunc(X.x); if (X.x < 0) and (x.x - Result.x<>0) then Result.x := Result.x -1; Result.x := x.x - Result.x;
  Result.y := Trunc(X.y); if (X.y < 0) and (x.y - Result.y<>0) then Result.y := Result.y -1; Result.y := x.y - Result.y;
end;

function fract(const x: vec3): vec3;
begin
//  Result.x := x.x - Math.Floor(x.x);
//  Result.y := x.y - Math.Floor(x.y);
//  Result.z := x.z - Math.Floor(x.z);
  Result.x := Trunc(X.x); if (X.x < 0) and (x.x - Result.x<>0) then Result.x := Result.x -1; Result.x := x.x - Result.x;
  Result.y := Trunc(X.y); if (X.y < 0) and (x.y - Result.y<>0) then Result.y := Result.y -1; Result.y := x.y - Result.y;
  Result.z := Trunc(X.z); if (X.z < 0) and (x.z - Result.z<>0) then Result.z := Result.z -1; Result.z := x.z - Result.z;


end;


function fract(const x: vec4): vec4;
begin
//  Result.x := x.x - Math.Floor(x.x);
//  Result.y := x.y - Math.Floor(x.y);
//  Result.z := x.z - Math.Floor(x.z);
//  Result.w := x.w - Math.Floor(x.w);

  Result.x := Trunc(X.x); if (X.x < 0) and (x.x - Result.x<>0) then Result.x := Result.x -1; Result.x := x.x - Result.x;
  Result.y := Trunc(X.y); if (X.y < 0) and (x.y - Result.y<>0) then Result.y := Result.y -1; Result.y := x.y - Result.y;
  Result.z := Trunc(X.z); if (X.z < 0) and (x.z - Result.z<>0) then Result.z := Result.z -1; Result.z := x.z - Result.z;
  Result.w := Trunc(X.w); if (X.w < 0) and (x.w - Result.w<>0) then Result.w := Result.w -1; Result.w := x.w - Result.w;

end;


//function floor(x: Double): Double;{$IFNDEF DEBUG} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
//begin
//  Result := Math.Floor(x);
//end;

function floor(const x: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
begin
{  Result.x :=Math.Floor(x.x);
  Result.y :=Math.Floor(x.y);}

  Result.x := Trunc(x.x); if (x.x < 0) and (x.x-Result.x<>0) then Result.x := Result.x-1;
  Result.y := Trunc(x.y); if (x.y < 0) and (x.y-Result.y<>0) then Result.y := Result.y-1;
end;

function floor(const x: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
begin
{  Result.x := Math.Floor(x.x);
  Result.y := Math.Floor(x.y);
  Result.z := Math.Floor(x.z);
  }

//  Result.x := IntegerTrunc(X.x); if Frac(X.x) < 0 then Result.x := Result.x-1;
//  Result.y := IntegerTrunc(X.y); if Frac(X.y) < 0 then Result.y := Result.y-1;
//  Result.z := IntegerTrunc(X.z); if Frac(X.z) < 0 then Result.z := Result.z-1;

  Result.x := Trunc(x.x); if (x.x < 0) and (x.x-Result.x<>0) then Result.x := Result.x-1;
  Result.y := Trunc(x.y); if (x.y < 0) and (x.y-Result.y<>0) then Result.y := Result.y-1;
  Result.z := Trunc(x.z); if (x.z < 0) and (x.z-Result.z<>0) then Result.z := Result.z-1;
end;

function floor(const x: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;       { return x - cmath::floor(x); }
begin
{
  Result.x := Math.Floor(x.x);
  Result.y := Math.Floor(x.y);
  Result.z := Math.Floor(x.z);
  Result.w := Math.Floor(x.w);
}

//  Result.x := IntegerTrunc(X.x); if Frac(X.x) < 0 then Result.x := Result.x-1;
//  Result.y := IntegerTrunc(X.y); if Frac(X.y) < 0 then Result.y := Result.y-1;
//  Result.z := IntegerTrunc(X.z); if Frac(X.z) < 0 then Result.z := Result.z-1;
//  Result.w := IntegerTrunc(X.w); if Frac(X.w) < 0 then Result.w := Result.w-1;

  Result.x := Trunc(x.x); if (x.x < 0) and (x.x-Result.x<>0) then Result.x := Result.x-1;
  Result.y := Trunc(x.y); if (x.y < 0) and (x.y-Result.y<>0) then Result.y := Result.y-1;
  Result.z := Trunc(x.z); if (x.z < 0) and (x.z-Result.z<>0) then Result.z := Result.z-1;
  Result.w := Trunc(x.w); if (x.w < 0) and (x.w-Result.w<>0) then Result.w := Result.w-1;

end;


function &mod(a, b: double): double;
{$IFDEF CPUx86}
asm
  fld qword ptr[b]
  fld qword ptr[a]
@r:
  fprem
  fstsw ax
  sahf
  jp @r
  fstp st(1)
end;
{$ELSE}
begin
  if IsZero(b) then
    Exit(0);

	Result := a - b * math.Floor(a / b);
end;
{$ENDIF}

function &mod(const a, b: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := fmod(a.x, b.x);
  Result.y := fmod(a.y, b.y);
end;

function &mod(const a, b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := fmod(a.x, b.x);
  Result.y := fmod(a.y, b.y);
  Result.z := fmod(a.z, b.z);
end;

function &mod(const a, b: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := fmod(a.x, b.x);
  Result.y := fmod(a.y, b.y);
  Result.z := fmod(a.z, b.z);
  Result.w := fmod(a.w, b.w);
end;

function &mod(const a: Vec2;b:TVecType): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
//  Result.x := fmod(a.x, b);
//  Result.y := fmod(a.y, b);
  Result.x := a.x - b * floor(a.x / b);
  Result.y := a.y - b * floor(a.y / b);
end;


function &mod(const a: Vec3;b:TVecType): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := fmod(a.x, b);
  Result.y := fmod(a.y, b);
  Result.z := fmod(a.z, b);
end;

function &mod(const a: Vec4;b:TVecType): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;     { return T(cmath::fmod(x, y)); }
begin
  Result.x := fmod(a.x, b);
  Result.y := fmod(a.y, b);
  Result.z := fmod(a.z, b);
  Result.w := fmod(a.w, b);
end;


function Cross(const a,b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF}
begin
  Result := Vec3.create(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x
  );

end;


function min(x, y: double): double;
begin
  if y < x then
    Result := y
  else
    Result := x;
end;

function max(x, y: double): double;
begin
  if x < y then
    Result := y
  else
    Result := x;
end;

function clamp(x:double): Double;
begin
  if x>1 then
    Result := 1
  else
    if x<0 then
      Result := 0
    else
      Result := x
end;

function clamp(x, minVal, maxVal: Double): Double;
begin
  //  Result := Math.min(Math.max(x, minVal), maxVal);
  if x>maxVal then
    Result := maxVal
  else
    if x<minVal then
      Result := minVal
    else
      Result := x
end;


function mix(x, y, a: Double): Double;
begin
  Result := x * (1 - a) + y * a;
end;

function step(edge, x: Double): Double;
begin
  if x <= edge then
    Result := 0
  else
    Result := 1;
end;



function distance(p0, p1: double): double;
begin
  Result := system.sqrt(system.Abs(p0 - p1));
end;

function distance(const a,b: Vec2): double;
var dx,dy:double;
begin
  dx := a.x - b.x;
  dy := a.y - b.y;
  Result := system.sqrt(dx*dx + dy*dy);
end;

function distance(const a,b: Vec3): double;
var dx,dy,dz:double;
begin
  dx := a.x - b.x;
  dy := a.y - b.y;
  dz := a.z - b.z;
  Result := system.sqrt(dx*dx + dy*dy + dz*dz);
end;

function distance(const a,b: Vec4): double;{$IFNDEF DEBUG} inline;{$ENDIF} overload; { return length(p0-p1); }
var dx,dy,dz,dw:double;
begin
  dx := a.x - b.x;
  dy := a.y - b.y;
  dz := a.z - b.z;
  dw := a.w - b.w;
  Result := system.sqrt(dx*dx + dy*dy + dz*dz + dw*dw);
end;

function Dot(x, y: Single): Single;
begin
  Result := x * y;
end;


function dot(x, y: double): double;
begin
  Result := x * y;
end;

function normalize(x:double): double;
begin
  Result := 1;
end;


function reflect(I, n: double): double;
begin
  Result := I - 2 * n * I * n;
end;

function reflect(const I, n: Vec3): Vec3;
begin
{  Result.x := I.x - 2 * n.x * I.x * n.x;
  Result.y := I.y - 2 * n.y * I.y * n.y;
  Result.z := I.z - 2 * n.z * I.z * n.z;
}
  Result.x := I.x - n.x * i.x * n.x * n.x;
  Result.y := I.y - n.y * i.y * n.y * n.y;
  Result.z := I.z - n.z * i.z * n.z * n.z;
end;



function FaceForward(const N,I,NRef:TVecType): TVecType;overload;
begin
  if dot(Nref, I) < 0 then
    Result := N
  else
    Result := -N
end;

function FaceForward(const N,I,NRef:Vec2): Vec2; overload;
begin
  if dot(Nref, I) < 0 then
    Result := N
  else
    Result := -N
end;

function FaceForward(const N,I,NRef:Vec3): Vec3; overload;
begin
  if dot(Nref, I) < 0 then
    Result := N
  else
    Result := -N
end;

function FaceForward(const N,I,NRef:Vec4): Vec4; overload;
begin
  if dot(Nref, I) < 0 then
    Result := N
  else
    Result := -N
end;


function Refract(const I, N:TVecType; eta:Double):TVecType;overload;
var k:double; d:TVecType;
begin
  d := N * I;
  k := 1.0 - eta * eta * (1.0 - d * d);
  if k < 0.0 then
    Result := 0.0
  else
    Result := eta * I - (eta * d + system.sqrt(k)) * N
end;

function Refract(const I, N:vec2; eta:Double):vec2;overload;
var k:double; d:float;
begin
  d := dot(N , I);
  k := 1.0 - eta * eta * (1.0 - d * d);
  if k < 0.0 then
    Result := vec2Black
  else
    Result := eta * I - (eta * d + system.sqrt(k)) * N
end;

function Refract(const I, N:vec3; eta:Double):vec3;overload;
var k:double; d:double;
begin
  d := dot(N , I);
  k := 1 - eta * eta * (1 - d * d);
  if k < 0 then
    Result := vec3Black
  else
    Result := eta * I - (eta * d + system.sqrt(k)) * N
end;

function Refract(const I, N:vec4; eta:Double):vec4;overload;
var k:double; d:double;
begin
  d := dot(N , I);
  k := 1.0 - eta * eta * (1.0 - d * d);
  if k < 0.0 then
    Result := vec4Black
  else
    Result := eta * I - (eta * d + system.sqrt(k)) * N
end;



{------------------------------------------------------------------------------}

function min(const x, y: vec2): vec2;
begin
  Result.x := Math.min(x.x,y.x);
  Result.y := Math.min(x.y,y.y);
end;

function min(const x, y: vec3) : vec3;
begin
  Result.x := Math.min(x.x,y.x);
  Result.y := Math.min(x.y,y.y);
  Result.z := Math.min(x.z,y.z);
end;

function min(const x, y: vec4) : vec4;
begin
  Result.x := Math.min(x.x,y.x);
  Result.y := Math.min(x.y,y.y);
  Result.z := Math.min(x.z,y.z);
  Result.w := Math.min(x.w,y.w);
end;

function max(const x, y: vec2): vec2;
begin
  Result.x := Math.max(x.x,y.x);
  Result.y := Math.max(x.y,y.y);
end;

function max(const x, y: vec3): vec3;
begin
  Result.x := Math.max(x.x,y.x);
  Result.y := Math.max(x.y,y.y);
  Result.z := Math.max(x.z,y.z);
end;

function max(const x, y: vec4): vec4;
begin
  Result.x := Math.max(x.x,y.x);
  Result.y := Math.max(x.y,y.y);
  Result.z := Math.max(x.z,y.z);
  Result.w := Math.max(x.w,y.w);
end;

function maxComp(const p: vec3) : double;
begin
  Result := Math.max(p.x,Math.max(p.y,p.z));
end;

function pow(const x, y: Vec2): Vec2;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
begin
  Result.x := Power(x.x,y.x);
  Result.y := Power(x.y,y.y);
end;
function pow(const a, b: Vec3): Vec3;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
begin
  Result.x := Power(a.x,b.x);
  Result.y := Power(a.y,b.y);
  Result.z := Power(a.z,b.z);
end;
function pow(const x, y: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
begin
  Result.x := Power(x.x,y.x);
  Result.y := Power(x.y,y.y);
  Result.z := Power(x.z,y.z);
  Result.w := Power(x.w,y.w);
end;
function sqrt(const a: TVecType): TVecType;
begin
  if a<=0 then
    Exit(0)
  else
    Result := system.Sqrt(a);
end;

function sqrt(const a: Vec2): Vec2;
begin
  result.x := System.sqrt(a.x);
  result.y := System.sqrt(a.y);
end;

function sqrt(const a: Vec3): Vec3;
begin
  result.x := System.sqrt(a.x);
  result.y := System.sqrt(a.y);
  result.z := System.sqrt(a.z);
end;

function sqrts(const a: Vec3): Vec3;
begin
  if a.x<0 then result.x := 0 else result.x := System.sqrt(a.x);
  if a.y<0 then result.y := 0 else result.y := System.sqrt(a.y);
  if a.z<0 then result.z := 0 else result.z := System.sqrt(a.z);
end;


function sqrt(const a: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
begin
  result.x := System.sqrt(a.x);
  result.y := System.sqrt(a.y);
  result.z := System.sqrt(a.z);
  result.w := System.sqrt(a.w);
end;

function clamp(const x, minVal, maxVal: vec2): vec2;
begin
  Result.x := Math.min(Math.max(x.x, minVal.x), maxVal.x);
  Result.y := Math.min(Math.max(x.y, minVal.y), maxVal.y);
end;

function clamp(const x, minVal, maxVal: vec3): vec3;
begin
  Result.x := Math.min(Math.max(x.x, minVal.x), maxVal.x);
  Result.y := Math.min(Math.max(x.y, minVal.y), maxVal.y);
  Result.z := Math.min(Math.max(x.z, minVal.z), maxVal.z);
end;

function clamp(const x:Vec2; minVal, maxVal: Double): Vec2; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
begin
  Result.x := Math.min(Math.max(x.x, minVal), maxVal);
  Result.y := Math.min(Math.max(x.y, minVal), maxVal);
end;


function clamp(const x:Vec3; minVal, maxVal: Double): Vec3; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
begin
  Result.x := Math.min(Math.max(x.x, minVal), maxVal);
  Result.y := Math.min(Math.max(x.y, minVal), maxVal);
  Result.z := Math.min(Math.max(x.z, minVal), maxVal);
end;

function clamp(const x:Vec4; minVal, maxVal: Double): Vec4; overload;{$IFNDEF DEBUG} inline;{$ENDIF}  { return glsl::min(glsl::max(x,minVal),maxVal); }
begin
  Result.x := Math.min(Math.max(x.x, minVal), maxVal);
  Result.y := Math.min(Math.max(x.y, minVal), maxVal);
  Result.z := Math.min(Math.max(x.z, minVal), maxVal);
  Result.w := Math.min(Math.max(x.w, minVal), maxVal);
end;


function mix(const x, y, a: vec2): vec2;
begin
  Result.x := x.x * (1 - a.x) + y.x * a.x;
  Result.y := x.y * (1 - a.y) + y.y * a.y;
end;

function mix(const x, y, a: vec3): vec3;
begin
  Result.x := x.x * (1 - a.x) + y.x * a.x;
  Result.y := x.y * (1 - a.y) + y.y * a.y;
  Result.z := x.z * (1 - a.z) + y.z * a.z;
end;

function mix(const x, y, a: vec4): vec4;
begin
  Result.x := x.x * (1 - a.x) + y.x * a.x;
  Result.y := x.y * (1 - a.y) + y.y * a.y;
  Result.z := x.z * (1 - a.z) + y.z * a.z;
  Result.w := x.w * (1 - a.w) + y.w * a.w;
end;

function mix(const x, y:Vec2; a: TVecType): Vec2;
begin
  Result.x := x.x * (1 - a) + y.x * a;
  Result.y := x.y * (1 - a) + y.y * a;
end;

function mix(const x, y:Vec3; a: TVecType): Vec3;
begin
  Result.x := x.x * (1 - a) + y.x * a;
  Result.y := x.y * (1 - a) + y.y * a;
  Result.z := x.z * (1 - a) + y.z * a;
end;


function mix(const x, y:Vec4; a: TVecType): Vec4;
begin
  Result.x := x.x * (1 - a) + y.x * a;
  Result.y := x.y * (1 - a) + y.y * a;
  Result.z := x.z * (1 - a) + y.z * a;
  Result.w := x.w * (1 - a) + y.w * a;
end;

function step(const edge, x: vec2): vec2;
begin
  if x.x<=edge.x then result.x := 0 else result.x := 1;
  if x.y<=edge.y then result.y := 0 else result.y := 1;
end;

function step(const edge, x: vec3): vec3;
begin
  if x.x<=edge.x then result.x := 0 else result.x := 1;
  if x.y<=edge.y then result.y := 0 else result.y := 1;
  if x.z<=edge.z then result.z := 0 else result.z := 1;
end;

function step(const edge, x: vec4): vec4;
begin
  if x.x<=edge.x then result.x := 0 else result.x := 1;
  if x.y<=edge.y then result.y := 0 else result.y := 1;
  if x.z<=edge.z then result.z := 0 else result.z := 1;
  if x.w<=edge.w then result.w := 0 else result.w := 1;
end;

function length(x: double): double;
begin
  Result := system.Abs(x)
end;

function length(const x: vec2): double;
begin
  Result := System.Sqrt( x.x * x.x
                       + x.y * x.y);
end;

function Length(const x: Vec3): Double;
begin
  Result := System.Sqrt(
                  x.x * x.x
                + x.y * x.y
                + x.z * x.z
                );
end;

function Length(const x: Vec4): Double;
begin
  Result := System.sqrt( x.x * x.x
                + x.y * x.y
                + x.z * x.z
                + x.w * x.w);
end;

function length_sq(const x: Vec3): Double;
begin
  Result := x.x * x.x
          + x.y * x.y
          + x.z * x.z;
end;


{ Vec3 }

class operator Vec3.Add(const a, b: Vec3): Vec3;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
  Result.z := a.z + b.z;
end;

function Vec3.Abs: Vec3;
begin
  x := system.Abs(x);
  y := system.Abs(y);
  z := system.Abs(z);
end;

class operator Vec3.Add(const a: Vec3; b: TVecType): Vec3;
begin
  Result.x := a.x + b;
  Result.y := a.y + b;
  Result.z := a.z + b;
end;

constructor Vec3.create(aX: TVecType; const yz: Vec2);
begin
  x := x;
  y := yz.x;
  z := yz.y;
end;

constructor Vec3.create(const xy: Vec2; az: TVecType);
begin
  x := xy.x;
  y := xy.y;
  z := az;
end;

constructor Vec3.create(ax: TVecType);
begin
  x := ax;
  y := ax;
  z := ax;
end;

constructor Vec3.create(ax, ay, az: TVecType);
begin
  x := ax;
  y := ay;
  z := az;
end;

function Vec3.Cross(const b: Vec3): Vec3;
begin
  Result := Vec3.create(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x);
end;

class operator Vec3.Divide(const a: Vec3; b: TVecType): Vec3;
begin
  Result.x := a.x / b;
  Result.y := a.y / b;
  Result.z := a.z / b;
end;

function Vec3.Dot(const b: Vec3): TVecType;
begin
  Result := x * b.x + y * b.y + z * b.z;
end;

class operator Vec3.Equal(const a, b: Vec3): Boolean;
begin
  Result := (a.x = b.x) and (a.y = b.y) and (a.z = b.z);
end;

class operator Vec3.Explicit(const a: Vec3): TColor32;
var R,G,B:Byte;
begin
//  Result := Color32(Min(255, round(a.x)),Min(255,round(a.y)),Min(255,round(a.z)))
{  Result := Color32(
              EnsureRange(round(a.x),0,255),
              EnsureRange(round(a.y),0,255),
              EnsureRange(round(a.z),0,255)
              )}

  if a.r < 0 then R := 0 else if a.r > 1 then r := 255 else R := trunc(a.r*255);
  if a.g < 0 then G := 0 else if a.g > 1 then g := 255 else G := trunc(a.g*255);
  if a.b < 0 then B := 0 else if a.b > 1 then b := 255 else B := trunc(a.b*255);

  Result := $ff000000 or (R shl 16) or (G shl 8) or B;
end;


//class operator Vec3.Explicit(a: Vec3): TColor32;
//var r,g,b:byte;
//begin
//  {$R-}
//  r := Trunc(a.x);
//  g := Trunc(a.y);
//  b := Trunc(a.z);
//  {$R+}
//  Result := Color32(r,g,b)
//end;
//
class operator Vec3.Implicit(a: TVecType): Vec3;
begin
  Result.x := a;
  REsult.y := a;
  Result.z := a;
end;

class operator Vec3.Divide(const a, b: Vec3): Vec3;
begin
  Result.x := a.x / b.x;
  Result.y := a.y / b.y;
  Result.z := a.z / b.z;
end;

function Vec3.Length: TVecType;
begin
  Result := System.sqrt(x * x + y * y + z * z)
end;

function abs(const x: TVecType) : TVecType;
begin
  Result := System.Abs(x);
end;

function abs(const x: vec2) : vec2;
begin
  Result.x := abs(x.x);
  Result.y := abs(x.y);
end;

function abs(const x: vec3) : vec3;
begin
  Result.x := abs(x.x);
  Result.y := abs(x.y);
  Result.z := abs(x.z);
end;

function abs(const x: vec4) : vec4;
begin
  Result.x := abs(x.x);
  Result.y := abs(x.y);
  Result.z := abs(x.z);
  Result.w := abs(x.w);
end;

function acos(x:TVecType):TVecType;
begin
  Result := ArcCos(x)
end;

function atan(x:TVecType):TVecType;
begin
	Result := x - (x * x * x * 0.333333333333) + (x * x * x * x * x * 0.2) - (x * x * x * x * x * x * x * 0.1428571429) + (x * x * x * x * x * x * x * x * x * 0.111111111111) - (x * x * x * x * x * x * x * x * x * x * x * 0.0909090909);
end;


function atan(x,y:TVecType):TVecType;
begin
  Result := ArcTan2(x,y)
end;

function tan(x:TVecType):TVecType;
begin
  if x=pi/2 then
    Exit(0);

  Result := System.Tangent(x);
end;

class operator Vec3.Multiply(const a: Vec3; b: TVecType): Vec3;
begin
  Result.x := a.x * b;
  Result.y := a.y * b;
  Result.z := a.z * b;
end;

class operator Vec3.Multiply(const a, b: Vec3): Vec3;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
  Result.z := a.z * b.z;
end;

class operator Vec3.Negative(const a: Vec3): Vec3;
begin
  Result.X := -a.X;
  Result.Y := -a.Y;
  Result.Z := -a.Z;
end;

function Vec3.Normalize: PVec3;
var
  s, l: TVecType;
begin
  s := System.sqrt(x * x + y * y + z * z);
  if IsZero(s) then
    Exit(@self);

  l := 1 / s;
  x := x * l;
  y := y * l;
  z := z * l;
  Result := @Self;
end;



procedure Vec3.NormalizeSelf;
var
  s, l: TVecType;
begin
  s := System.Sqrt(x * x + y * y + z * z);
  if IsZero(s) then
    Exit;
  if IsInfinite(s) then
    Exit;

  l := 1 / s;
  x := x * l;
  y := y * l;
  z := z * l;
end;

function Vec3.rg: Vec2;
begin
  Result.x := r;
  Result.y := g;
end;

class operator Vec3.Subtract(const a: Vec2; const b: Vec3): Vec3;
begin
  result.x := a.x - b.x;
  result.y := a.y - b.y;
  result.z := 0   - b.z;
end;

class operator Vec3.Subtract(const a: Vec3; const b: Vec2): Vec3;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z;
end;

function Vec3.getxy: Vec2;
begin
  Result.x := x;
  Result.y := y;
end;

procedure Vec3.SetXy(const a:Vec2);
begin
  x := a.x;
  y := a.y;
end;


function Vec3.xxy: vec3;
begin
  Result.x := x;
  Result.y := x;
  Result.z := y;
end;

function Vec3.xyx: vec3;
begin
  Result.x := x;
  Result.y := y;
  Result.z := x;
end;

function Vec3.xyy: vec3;
begin
  Result.x := x;
  Result.y := y;
  Result.z := y;
end;

function Vec3.xyz: vec3;
begin
  Result := self;
end;

function Vec3.GetXZ: Vec2;
begin
  Result.x := x;
  Result.y := z;
end;

function Vec3.getyz: Vec2;
begin
  Result.x := y;
  Result.y := z;
end;

function Vec3.GetZX: Vec2;
begin
  Result.x := z;
  Result.y := x;
end;

procedure Vec3.SetXZ(const a:Vec2);
begin
  x := a.x;
  z := a.y;
end;

procedure Vec3.SetYZ(const Value: vec2);
begin
  y := Value.x;
  z := Value.y;
end;

procedure Vec3.SetZX(const Value: Vec2);
begin
  z := Value.x;
  x := Value.y;
end;

function Vec3.yxx: vec3;
begin
  Result.x := y;
  Result.y := x;
  Result.z := x;
end;

function Vec3.yxy: vec3;
begin
  Result.x := y;
  Result.y := x;
  Result.z := y;
end;

function Vec3.yxz: vec3;
begin
  Result.x := y;
  Result.y := x;
  Result.z := z;
end;

function Vec3.yyx: vec3;
begin
  Result.x := y;
  Result.y := y;
  Result.z := x;
end;


function Vec3.yzx: vec3;
begin
  Result.x := y;
  Result.y := z;
  Result.z := x;
end;

function Vec3.zxy: vec3;
begin
  Result.x := z;
  Result.y := x;
  Result.z := y;

end;

function Vec3.zy: Vec2;
begin
  Result.x := z;
  Result.y := y;
end;

function Vec3.zyx: vec3;
begin
  Result.x := z;
  Result.y := y;
  Result.z := x;
end;

function Vec3.zzx: vec3;
begin
  Result.x := z;
  Result.y := z;
  Result.z := x;

end;

class operator Vec3.Subtract(const a, b: Vec3): Vec3;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
end;


class operator Vec3.Multiply(a: TVecType; const b: Vec3): Vec3;
begin
  Result.x := a * b.x;
  Result.y := a * b.y;
  Result.z := a * b.z;
end;

{ Vec2 }

class operator Vec2.Add(const a, b: Vec2): Vec2;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
end;

class operator Vec2.Add(const a: Vec2; b: TVecType): Vec2;
begin
  Result.x := a.x + b;
  Result.y := a.y + b;
end;

class operator Vec2.Add(a: TVecType; const b: Vec2): Vec2;
begin
  Result.x := a + b.x;
  Result.y := a + b.y;
end;

constructor Vec2.create(ax: TVecType);
begin
  x := ax;
  y := ax;
end;



constructor Vec2.create(ax, ay: TVecType);
begin
  x := ax;
  y := ay;
end;

function Vec2.Cross(const b: Vec2): Vec2;
begin
  Result := Vec2.create(y * b.x - x * b.y, x * b.y - y * b.x);
end;

class operator Vec2.Divide(const a, b: Vec2): Vec2;
begin
  Result.x := a.x / b.x;
  Result.y := a.y / b.y;
end;

class operator Vec2.Divide(const a: Vec2; b: TVecType): Vec2;
begin
  Result.x := a.x / b;
  Result.y := a.y / b;
end;

class operator Vec2.Divide(a: TVecType; const b: Vec2): Vec2;
begin
  Result.x := a / b.x;
  Result.y := a / b.y;
end;

function Vec2.Dot(const b: Vec2): TVecType;
begin
  Result := x * b.x + y * b.y;
end;

class operator Vec2.explicit(const a: Vec2): TPointF;
begin
  Result.X := a.x;
  Result.Y := a.y;
end;

class operator Vec2.explicit(const a: Vec2): TPoint;
begin
  result.X := round(a.x);
  result.Y := round(a.y);
end;

class operator Vec2.explicit(const b: TVecType): Vec2;
begin
  Result.x := b;
  Result.y := b;
end;

function Vec2.Length: TVecType;
begin
  Result := System.sqrt(x * x + y * y)
end;

procedure Vec2.LoadTextures;
begin
end;

class operator Vec2.Multiply(const a, b: Vec2): Vec2;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
end;

class operator Vec2.Multiply(const a: Vec2; b: TVecType): Vec2;
begin
  Result.x := a.x * b;
  Result.y := a.y * b;
end;

class operator Vec2.Multiply(a: TVecType; const b: Vec2): Vec2;
begin
  Result.x := a * b.x;
  Result.y := a * b.y;
end;

class operator Vec2.Negative(const a: Vec2): Vec2;
begin
  Result.x := -a.x;
  Result.y := -a.y;
end;

function Vec2.Normalize: PVec2;
var
  s, l: TVecType;
begin

    s := System.sqrt(x * x + y * y);
    if s = 0 then
      Exit(@self);

    l := 1.0 / s;
    x := x * l;
    y := y * l;

  Result := @Self;
end;

function Vec2.rg: vec2;
begin
  Result.x := x;
  Result.y := y;
end;

class operator Vec2.Subtract(const a: Vec2; b: TVecType): Vec2;
begin
  Result.x := a.x - b;
  Result.y := a.y - b;
end;

class operator Vec2.Subtract(a: TVecType; const b: Vec2): Vec2;
begin
  Result.x := a - b.x;
  Result.y := a - b.y;
end;

class operator Vec2.Subtract(const a, b: Vec2): Vec2;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
end;


function Vec2.xy: vec2;
begin
  result.x := x;
  Result.y := y;
end;

function Vec2.xx: vec2;
begin
  Result.x:=x;
  Result.y:=x;
end;

function Vec2.xxx: PVec3;
var v3:Vec3;
begin
  v3.x := x;
  v3.y := x;
  v3.z := x;
  Result := @v3;
end;


function Vec2.xxy: PVec3;
var v3:Vec3;
begin
  v3.x := x;
  v3.y := x;
  v3.z := y;
  Result := @v3;
end;


function Vec2.xyx: PVec3;
var v3:Vec3;
begin
  v3.x := x;
  v3.y := y;
  v3.z := x;
  Result := @v3;
end;

function Vec2.xyy: PVec3;
var v3:Vec3;
begin
  v3.x := x;
  v3.y := y;
  v3.z := y;
  Result := @v3;
end;

function Vec2.yx: vec2;
begin
  Result.x := y;
  result.y := x;
end;

function Vec2.yxx: PVec3;
var v3:Vec3;
begin
  v3.x := y;
  v3.y := x;
  v3.z := x;
  Result := @v3;
end;

function Vec2.yxy: PVec3;
var v3:Vec3;
begin
  v3.x := y;
  v3.y := x;
  v3.z := y;
  Result := @v3;
end;

function Vec2.yy: vec2;
begin
  Result.x := y;
  Result.y := y;
end;

function Vec2.yyx: PVec3;
var v3:Vec3;
begin
  v3.x := y;
  v3.y := y;
  v3.z := x;
  Result := @v3;
end;

function Vec2.yyy: PVec3;
var v3:Vec3;
begin
  v3.x := y;
  v3.y := y;
  v3.z := y;
  Result := @v3;
end;


function dot(const x, y: vec2) : double;     overload;
begin
  Result := x.x * y.x +
            x.y * y.y;
end;

function dot(const x, y: vec3) : double;     overload;
begin
  Result := x.x * y.x +
            x.y * y.y +
            x.z * y.z;
end;

function dot(const x, y: vec4) : double;     overload;
begin
  Result := x.x * y.x +
            x.y * y.y +
            x.z * y.z +
            x.w * y.w;
end;

      {
// @@@ just copied from texture2d.. need to figure out how to implement this one
function textureCube(tex:TBitmap32;Coords:Vec3):Vec4;
var
  x,y:Integer;
  c:TColor32;
begin
  x := round(abs(Coords.x) * tex.Width ) mod tex.Width;
  y := round(abs(Coords.y) * tex.Height) mod tex.Height;
  Assert(x>=0);
  Assert(y>=0);
  Assert(X<tex.Width);
  Assert(Y<tex.Height);
  c := tex.Pixel[x,y];
  Result.x := RedComponent(c);
  Result.y := GreenComponent(c);
  Result.z := BlueComponent(c);
  Result.m := AlphaComponent(c);
end;

                }



function texture2DHQ(tex:TBitmap32;const Coords:Vec2):Vec4;
var
  x,y:single;
  c:TColor32;
begin
  x := &mod(abs(Coords.x) * tex.Width ,tex.Width );
  y := &mod(abs(Coords.y) * tex.Height,tex.Height);
  c := tex.PixelXW[round(x*FixedOne),round((tex.Height - y -1)*FixedOne)];
  Result.r := ((c and $00FF0000) shr 16)/256;
  Result.g := ((c and $0000FF00) shr 8)/256;
  Result.b := (c and $000000FF)/256;
  Result.a := (c shr 24)/256;
end;


function texture2DLQ(tex:TBitmap32;const Coords:Vec2):Vec4;
var
  x,y:integer;
  c:TColor32;
begin
  x := round(abs(Coords.x) * tex.Width ) mod tex.Width;
  y := round(abs(Coords.y) * tex.Height) mod tex.Height;
  Assert(x>=0);
  Assert(y>=0);
  Assert(X<tex.Width);
  Assert(Y<tex.Height);
  c := tex.PixelS[x,tex.Height - y -1];
  Result.r := ((c and $00FF0000) shr 16)/256;
  Result.g := ((c and $0000FF00) shr 8)/256;
  Result.b := (c and $000000FF)/256;
  Result.a := (c shr 24)/256;
end;


function texture2D(tex:TBitmap32;const Coords:Vec2):Vec4;
var
  {$DEFINE ANTIALIASED}
  x,y:{$IFDEF ANTIALIASED}single{$ELSE}integer{$ENDIF};
  px,py:integer;
  c:TColor32;
begin
{$IFDEF ANTIALIASED}
  x := &mod(Coords.x * tex.Width ,tex.Width );
  y := &mod(Coords.y * tex.Height,tex.Height);
  px := round(x * FixedOne);
  py := round((tex.Height - y -1)* FixedOne);
  if px>1e8 then
    Exit(Default(Vec4));
  if py>1e8 then
    Exit(Default(Vec4));

  c := tex.PixelXW[px,py];
{$ELSE}
  x := round(abs(Coords.x) * tex.Width ) mod tex.Width;
  y := round(abs(Coords.y) * tex.Height) mod tex.Height;
  Assert(x>=0);
  Assert(y>=0);
  Assert(X<tex.Width);
  Assert(Y<tex.Height);
  c := tex.PixelS[x,tex.Height - y -1];
{$ENDIF}
  Result.r := ((c and $00FF0000) shr 16)/256;
  Result.g := ((c and $0000FF00) shr 8)/256;
  Result.b := (c and $000000FF)/256;
  Result.a := (c shr 24)/256;
end;

function texture2D(tex: TBitmap32; const Coords: Vec2; Bias:Float): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF}
begin
  Result := texture2DHQ(tex,Coords);
end;


     {

function textureCube(tex:TBitmap32;Coords:Vec3):Vec4;
begin
	Result.x  := texture2D( tex, Coords.yz ).x;
	Result.y  := texture2D( tex, Coords.zx ).y;
	Result.z  := texture2D( tex, Coords.xy ).z;

	Result.w  := 1;
end;

      }

function textureCube(tex:TBitmap32;const Coords:Vec3):Vec4;
var x,y,z :vec4;
begin

	x  := texture2D( tex, Coords.yz );
	y  := texture2D( tex, Coords.zx );
	z  := texture2D( tex, Coords.xy );

	Exit( (x + y + z) * 0.33 );
end;

function textureCube(const tex:TTextureCube;const Coords:Vec3):Vec4;
var
  MaxVal:Double;
  f:TTextureCube.TFace;
  c:vec2;
begin
//  Result := texture2D( tex.Faces[ ttexturecube.TFace.POSITIVE_X ], -coords.xy );

(*
  http://www.ozone3d.net/tutorials/glsl_texturing_p04.php

  the function to fetch cubemap texels is textureCube().
  The first parameter is a samplerCube and the second is a XYZ vector
  that allows the function textureCube() to select the right face of
  the cubemap and then to extract the texel.

  The functioning of textureCube() could be as follow:
    the coordinate with the largest magnitude selects the face.
    The remaining two coordinates are divided by the absolute value of the
    largest coordinate and are mapped to the range [0.0 - 1.0].

    Example: the vector R = {0.287, -0.944, 0.164}

    selects the NEG_Y face.
    The texture coordinates {s, t} are calculated as follow:
    s = (0.287/0.944*0.5) + 0.5 and
    t = (0.164/0.944*0.5) + 0.5 then
    {s, t} = {0.65, 0.58}.

    The vector R is the same as for the DPEM.
*)

   MaxVal := Math.Max(Math.Max(abs(Coords.x), abs(Coords.y)), abs(Coords.z));

   c := vec2Black;
   f := TTextureCube.TFace.POSITIVE_X;

   if (Abs(Coords.x) = maxVal) then
   begin
     if not IsZero(Coords.x) then
       if Coords.x > 0 then
       begin
         f := TTextureCube.TFace.POSITIVE_X;
         c.x := (coords.z / coords.x*0.5)+0.5;
         c.y := (coords.y / coords.x*0.5)+0.5;
       end
       else
       begin
         f := TTextureCube.TFace.NEGATIVE_X;
         c.x := (coords.z / -coords.x*0.5)+0.5;
         c.y := (coords.y / -coords.x*0.5)+0.5;
       end;
   end;

   if (Abs(Coords.y) = maxVal) then
   begin
     if not IsZero(Coords.y) then
       if Coords.y > 0 then
       begin
         f := TTextureCube.TFace.POSITIVE_Y;
         c.x := (coords.x / coords.y*0.5)+0.5;
         c.y := (coords.z / coords.y*0.5)+0.5;
       end
       else
       begin
         f := TTextureCube.TFace.NEGATIVE_Y;
         c.x := (coords.x / -coords.y*0.5)+0.5;
         c.y := (coords.z / -coords.y*0.5)+0.5;
       end;
   end;

   if (Abs(Coords.z) = maxVal) then
   begin
     if not IsZero(Coords.z) then
       if Coords.z > 0 then
       begin
         f := TTextureCube.TFace.POSITIVE_Z;
         c.x := (coords.x / coords.z*0.5)+0.5;
         c.y := (coords.y / coords.z*0.5)+0.5;
       end
       else
       begin
         f := TTextureCube.TFace.NEGATIVE_Z;
         c.x := (coords.x / -coords.z*0.5)+0.5;
         c.y := (coords.y / -coords.z*0.5)+0.5;
       end;
   end;

   // Result := texture2DHQ( tex.Faces[ f ], c );
   Result := texture2D( tex.Faces[ f ], c );
end;


function TexCube(  sam: TBitmap32; const p:vec3;const n :vec3 ):vec4;
var x,y,z :vec4;
begin
	x  := texture2D( sam, p.yz );
	y  := texture2D( sam, p.zx );
	z  := texture2D( sam, p.xy );
	Exit( x*abs(n.x) + y*abs(n.y) + z*abs(n.z) );
end;

function smoothstep(edge0, edge1, x: Double): Double;
var
  T: Double;
begin
  T := (x - edge0) / (edge1 - edge0);
  if T>1 then T := 1 else if T<0 then T := 0;
  Result := T * T * (3 - 2 * T);
end;

function smoothstep(const edge0, edge1, x: vec2): vec2;
begin
  {method 1: most readable}
//  Result.x := smoothstep(edge0.x,edge1.x,x.x);
//  Result.y := smoothstep(edge0.y,edge1.y,x.y);


  {method 2}
//  T.x := clamp((x.x - edge0.x) / (edge1.x - edge0.x), 0, 1);
//  Result.x := T.x * T.x * (3 - 2 * T.x);
//  T.y := clamp((x.y - edge0.y) / (edge1.y - edge0.y), 0, 1);
//  Result.y := T.y * T.y * (3 - 2 * T.y);

  {method 3: least readable, but almost twice as fast as method 1}
  result.x := (x.x - edge0.x) / (edge1.x - edge0.x);
  if result.x>1 then result.x := 1 else if result.x<0 then result.x := 0;
  Result.x := result.x * result.x * (3 - 2 * result.x);

  result.y := (x.y - edge0.y) / (edge1.y - edge0.y);
  if result.y>1 then result.y := 1 else if result.y<0 then result.y := 0;
  Result.y := result.y * result.y * (3 - 2 * result.y);
end;


function smoothstep(const edge0, edge1, x: vec3) : vec3;overload;{ T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
var T:vec3;
begin
{
  Result.x := smoothstep(edge0.x,edge1.x,x.x);
  Result.y := smoothstep(edge0.y,edge1.y,x.y);
  Result.z := smoothstep(edge0.z,edge1.z,x.z);
}
  T.x := (x.x - edge0.x) / (edge1.x - edge0.x);
  if T.x>1 then T.x := 1 else if T.x<0 then T.x := 0;
  Result.x := T.x * T.x * (3 - 2 * T.x);

  T.y := (x.y - edge0.y) / (edge1.y - edge0.y);
  if T.y>1 then T.y := 1 else if T.y<0 then T.y := 0;
  Result.y := T.y * T.y * (3 - 2 * T.y);

  T.z := (x.z - edge0.z) / (edge1.z - edge0.z);
  if T.z>1 then T.z := 1 else if T.z<0 then T.z := 0;
  Result.z := T.z * T.z * (3 - 2 * T.z);

end;


function smoothstep(const edge0, edge1, x: vec4) : vec4;overload;{ T t = clamp((x-edge0) / (edge1-edge0), T(0), T(1)); return t * t * (3 - 2*t); }
var T:vec4;
begin
{
  Result.x := smoothstep(edge0.x,edge1.x,x.x);
  Result.y := smoothstep(edge0.y,edge1.y,x.y);
  Result.z := smoothstep(edge0.z,edge1.z,x.z);
  Result.w := smoothstep(edge0.w,edge1.w,x.w);
  }
  T.x := (x.x - edge0.x) / (edge1.x - edge0.x);
  if T.x>1 then T.x := 1 else if T.x<0 then T.x := 0;
  Result.x := T.x * T.x * (3 - 2 * T.x);

  T.y := (x.y - edge0.y) / (edge1.y - edge0.y);
  if T.y>1 then T.y := 1 else if T.y<0 then T.y := 0;
  Result.y := T.y * T.y * (3 - 2 * T.y);

  T.z := (x.z - edge0.z) / (edge1.z - edge0.z);
  if T.z>1 then T.z := 1 else if T.z<0 then T.z := 0;
  Result.z := T.z * T.z * (3 - 2 * T.z);

  T.w := (x.w - edge0.w) / (edge1.w - edge0.w);
  if T.w>1 then T.w := 1 else if T.w<0 then T.w := 0;
  Result.w := T.w * T.w * (3 - 2 * T.w);
end;


//function sin(const x: TVecType): TVecType;
//begin
//  Result := System.sin(x);
//end;


function sin(const x: Vec2): Vec2;
begin
  result.x := System.sin(x.x);
  result.y := System.sin(x.y);
end;

function sin(const x: Vec3): Vec3;
begin
  result.x := System.sin(x.x);
  result.y := System.sin(x.y);
  result.z := System.sin(x.z);
end;

function sin(const x: Vec4): Vec4;
begin
  result.x := System.sin(x.x);
  result.y := System.sin(x.y);
  result.z := System.sin(x.z);
  result.w := System.sin(x.w);
end;

function cos(const x: Vec2): Vec2;
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
end;

function cos(const x: Vec3): Vec3;
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
  result.z := System.cos(x.z);
end;

function cos(const x: Vec4): Vec4;
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
  result.z := System.cos(x.z);
  result.w := System.cos(x.w);
end;


procedure cos(const x: Vec2;out Result:vec2);
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
end;

procedure cos(const x: Vec3;out Result:vec3);
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
  result.z := System.cos(x.z);
end;

procedure cos(const x: Vec4;out Result:vec4);
begin
  result.x := System.cos(x.x);
  result.y := System.cos(x.y);
  result.z := System.cos(x.z);
  result.w := System.cos(x.w);
end;

procedure Mult(const input: Vec3;out Result:vec3);inline;
begin
  Result.x := input.x * input.x;
  REsult.y := input.y * input.y;
  Result.z := input.z * input.z;
end;


function normalize(const v:Vec2) : vec2;{$IFNDEF DEBUG} inline;{$ENDIF}overload;
var
  m:TVecType;
begin
	m := System.sqrt(v.x * v.x + v.y * v.y);

	if(m >  0.000000001)then
		m := 1.0 / m
	else
		m := 0.0;

	Result := vec2.create(v.x * m, v.y * m);
end;

function normalizeS(const v:Vec3) : vec3;inline;
var
  m:TVecType;
begin
  if IsNan(v.x) then exit(vec3Black);
  if IsNan(v.y) then exit(vec3Black);
  if IsNan(v.z) then exit(vec3Black);

	m := System.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);

	if(m >  0.000000001)then
		m := 1.0 / m
	else
		m := 0.0;

	Result.x := v.x * m;
  Result.y := v.y * m;
  Result.z := v.z * m;
end;


function normalize(const v:Vec3) : vec3;inline;
var
  m:TVecType;
begin
	m := System.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
  m := 1.0 / m;
  Result.x := v.x * m;
  Result.y := v.y * m;
  Result.z := v.z * m;
end;

function Normalize(const v: Vec4): Vec4;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
var
  a:TVecType;
begin
	a := System.sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);

	if(a >  0.000000001)then
		a := 1.0 / a
	else
		a := 0.0;

	Result.x := v.x * a;
  Result.y := v.y * a;
  Result.z := v.z * a;
  Result.w := v.w * a;
end;


constructor Vec4.Create(x, y, z, w: TVecType);
begin
  self.x := x;
  self.y := y;
  self.z := z;
  self.w := w;
end;

class operator Vec4.Add(const a, b: Vec4): Vec4;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
  Result.z := a.z + b.z;
  Result.w := a.w + b.w;
end;

class operator Vec4.Add(a: TVecType; const b: Vec4): Vec4;
begin
  Result.x := a + b.x;
  Result.y := a + b.y;
  Result.z := a + b.z;
  Result.w := a + b.w;
end;

class operator Vec4.Subtract(const a,b: Vec4): Vec4;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
  Result.w := a.w - b.w;
end;


constructor Vec4.Create(const x: Vec3; w: TVecType);
begin
  Self.x := x.x;
  Self.y := x.y;
  Self.z := x.z;
  Self.w := w;
end;

constructor Vec4.create(x: TVecType);
begin
  self.x := x;
  self.y := x;
  self.z := x;
  self.w := x;
end;

class operator Vec4.Explicit(const a: Vec4): TColor32;
var r_,g_,b_{,w_}:byte;
begin
{
  Result := Color32(
              Math.Min(255,round(a.x)),
              Math.Min(255,round(a.y)),
              Math.Min(255,round(a.z)),
              round(a.m)
  )           }
  {
  Result := Color32(
              EnsureRange(round(a.r*256),0,255),
              EnsureRange(round(a.g*256),0,255),
              EnsureRange(round(a.b*256),0,255),
              EnsureRange(round(a.w*256),0,255)
              );
}
{
  Result := ((EnsureRange(round(a.w*256),0,255)) shl 24)
          or (EnsureRange(round(a.r*256),0,255) shl 16)
          or (EnsureRange(round(a.g*256),0,255) shl  8)
          or EnsureRange(round(a.w*256),0,255);
}

{
  including alpha channel
  if a.r < 0 then R_ := 0 else if a.r > 1 then r_ := 255 else R_ := trunc(a.r*255);
  if a.g < 0 then G_ := 0 else if a.g > 1 then g_ := 255 else G_ := trunc(a.g*255);
  if a.b < 0 then B_ := 0 else if a.b > 1 then b_ := 255 else B_ := trunc(a.b*255);
  if a.w < 0 then W_ := 0 else if a.w > 1 then w_ := 255 else W_ := trunc(a.w*255);
  Result := (W_ shl 24) or (R_ shl 16) or (G_ shl 8) or B_;
}
  if a.r < 0 then R_ := 0 else if a.r > 1 then r_ := 255 else R_ := trunc(a.r*255);
  if a.g < 0 then G_ := 0 else if a.g > 1 then g_ := 255 else G_ := trunc(a.g*255);
  if a.b < 0 then B_ := 0 else if a.b > 1 then b_ := 255 else B_ := trunc(a.b*255);
  Result := (R_ shl 16) or (G_ shl 8) or B_;
end;


class operator Vec4.Implicit(const a: Vec3): Vec4;
begin
  Result.x := a.x;
  Result.y := a.y;
  Result.z := a.z;
  Result.w := 0;
end;


class operator Vec4.Multiply(const a: vec3; const b: Vec4): Vec4;
begin
  Result.x := a.x*b.x;
  Result.y := a.y*b.y;
  Result.z := a.z*b.z;
  Result.w := 0;
end;

class operator Vec4.Multiply(const a, b: Vec4): Vec4;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
  Result.z := a.z * b.z;
  Result.w := a.w * b.w;
end;

class operator Vec4.Multiply(const a: Vec4; b: TVecType): Vec4;
begin
  Result.x := a.x * b;
  Result.y := a.y * b;
  Result.z := a.z * b;
  Result.w := a.w * b;
end;

function Vec4.getxy: Vec2;
begin
  Result.x := x;
  Result.y := y;
end;

function Vec4.getxyz: Vec3;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec4.getxz: Vec2;
begin
  Result.x := x;
  Result.y := z;
end;

function Vec4.getyw: Vec2;
begin
  Result.x := y;
  Result.y := w;
end;

function Vec4.getyx: Vec2;
begin
  Result.x := y;
  Result.y := x;

end;

function Vec4.getyz: Vec2;
begin
  Result.x := y;
  Result.y := z;
end;

function Vec4.getzw: Vec2;
begin
  Result.x := z;
  Result.y := w;
end;

function Vec4.yzw: Vec3;
begin
  Result.x := y;
  Result.y := z;
  Result.z := w;
end;

class operator Vec4.Multiply(const a: vec4; const b: Vec3): Vec4;
begin
  Result.x := a.x*b.x;
  Result.y := a.y*b.y;
  Result.z := a.z*b.z;
  Result.w := 0;
end;

class operator Vec4.Negative(const a: Vec4): Vec4;
begin
  Result.x := -a.x;
  Result.y := -a.y;
  Result.z := -a.z;
  Result.w := -a.w;
end;

function Vec4.getrgb: Vec3;
begin
  Result.r := r;
  Result.g := g;
  Result.b := b;
end;

procedure Vec4.setrgb(const a: Vec3);
begin
  r := a.r;
  g := a.g;
  b := a.b;
end;

procedure Vec4.setxy(const a: Vec2);
begin
  x := a.x;
  y := a.y;
end;

procedure Vec4.setxyz(const a: Vec3);
begin
  x := a.x;
  y := a.y;
  z := a.z;
end;

procedure Vec4.setxz(const a: Vec2);
begin
  x := a.x;
  z := a.y;
end;

procedure Vec4.setyw(const a: Vec2);
begin
  y := a.x;
  w := a.y;
end;

procedure Vec4.setyx(const a: Vec2);
begin
  y := a.x;
  x := a.y;
end;

procedure Vec4.setyz(const a: Vec2);
begin
  y := a.x;
  z := a.y;
end;

procedure Vec4.setzw(const a: Vec2);
begin
  z := a.x;
  w := a.y;
end;

class operator Vec4.Multiply(const a: TVecType; const b: Vec4): Vec4;
begin
  Result.x := a*b.x;
  Result.y := a*b.y;
  Result.z := a*b.z;
  Result.w := a*b.w;

end;


{ TFrames }
{
procedure TFrames.Init(p:TPixelProc;t:double);
var n:Integer;
begin
  Frames.ItemIndex := 0;

  for n := 0 to High(Frames.Threads) do
  begin
    Threads[n] := TFrameThread.Create(true);
    Threads[n].Bitmap := TBitmap32.Create;
    Threads[n].IsDone := False;
    Threads[n].proc := p;
    Threads[n].Time := 1+0.4*n;
    Frames.Threads[n].resume;
  end;
  Frames.SetSize(512, 512);

end;

procedure TFrames.Resume;
var n:Integer;
begin
  for n := 0 to High(Frames.Threads) do
    Frames.Threads[n].resume;
end;

procedure TFrames.Setproc(const Value: TPixelProc);
var n:Integer;
begin
  for n := 0 to High(Frames.Threads) do
    Frames.Threads[n].proc := Value;
end;

procedure TFrames.SetSize(w, h: Integer);
var n:Integer;
begin
  for n := 0 to High(Frames.Threads) do
  begin
    Frames.Threads[n].Width := w;
    Frames.Threads[n].Height := h;
//    repeat until Frames.Threads[n].IsDone;
    Frames.Threads[n].Synchronize(Frames.Threads[n].Resize);
  end;
end;

procedure TFrames.Suspend;
var n:Integer;
begin
  for n := 0 to High(Frames.Threads) do
    Frames.Threads[n].Suspend;
end;

procedure TFrameThread.Resize;
begin
  Bitmap.SetSize(Width,Height);
  isDone := False;
end;
}

function Ifthen(c:Boolean;const a,b:Vec2):Vec2;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
begin
  if c then
    Result := a
  else
    Result := b
end;

function Ifthen(c:Boolean;const a,b:Vec3):Vec3;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
begin
  if c then
    Result := a
  else
    Result := b
end;

function Ifthen(c:Boolean;const a,b:Vec4):Vec4;overload;{$IFNDEF DEBUG} inline;{$ENDIF}
begin
  if c then
    Result := a
  else
    Result := b
end;


class operator Vec4.Add(const a: Vec4; b: TVecType): Vec4;
begin
  Result.x := a.x + b;
  Result.y := a.y + b;
  Result.z := a.z + b;
  Result.w := a.w + b;
end;

constructor Vec4.create(w: TVecType; const ax: Vec3);
begin
  x := w;
  y := ax.x;
  z := ax.y;
  self.w := ax.z;
end;

class operator Vec4.Divide(const a: vec4; b: TVecType): Vec4;
var n:TVecType;
begin
  if b=0 then
    exit(default(vec4));
  n := 1/b;
  Result.x := a.x*n;
  Result.y := a.y*n;
  Result.z := a.z*n;
  Result.w := a.w*n;
end;

class operator Vec4.Divide(const a: vec4; b: int64): Vec4;
var n:TVecType;
begin
  if b=0 then
    exit(default(vec4));
  n := 1/b;
  Result.x := a.x*n;
  Result.y := a.y*n;
  Result.z := a.z*n;
  Result.w := a.w*n;
end;

function Vec4.Dot(const b: Vec4): TVecType;
begin
  Result := x * b.x + y * b.y + z * b.z + w * b.w;
end;

class operator Vec2.explicit(const a: TPoint): Vec2;
begin
  result.x := a.X;
  result.y := a.Y;
end;

class operator Vec2.explicit(const a: TPointF): Vec2;
begin
  result.x := a.X;
  result.y := a.Y;
end;

{ Mat3 }

class operator Mat3.Add(const a: Mat3; const b: Vec3): Vec3;
begin
  Result.x := a.r1.x + b.x;
  Result.y := a.r2.y + b.y;
  Result.z := a.r3.z + b.z;
end;

constructor Mat3.Create(a1, a2, a3, b1, b2, b3, c1, c2, c3: TVecType);
begin
  r1.x := a1;  r1.y := a2;  r1.z := a3;
  r2.x := b1;  r2.y := b2;  r2.z := b3;
  r3.x := c1;  r3.y := c2;  r3.z := c3;
end;

class operator Mat3.Multiply(const a: Vec3; const b: Mat3): Vec3;
begin
{//  works, but needs extra function calls
  Result.x := b.r1.Dot(a);
  Result.y := b.r2.Dot(a);
  Result.z := b.r3.Dot(a);
}

  Result.x := b.r1.x * a.x + b.r1.y * a.y + b.r1.z * a.z;
  Result.y := b.r2.x * a.x + b.r2.y * a.y + b.r2.z * a.z;
  Result.z := b.r3.x * a.x + b.r3.y * a.y + b.r3.z * a.z;

end;

class operator Mat3.Multiply(const a: Mat3; const b: Vec3): Vec3;
begin
  Result.x := a.r1.Dot(b);
  Result.y := a.r2.Dot(b);
  Result.z := a.r3.Dot(b);
end;

constructor Mat3.Create(const a, b, c: Vec3);
begin
  r1 := a;
  r2 := b;
  r3 := c;
end;

class operator Mat3.Multiply(const a, b: Mat3): Mat3;
begin
  Result.r1 := a.r1 * b.r1;
  Result.r2 := a.r2 * b.r2;
  Result.r3 := a.r3 * b.r3;
end;

class operator Mat3.Negative(const a: Mat3): Mat3;
begin
  Result.r1 := -a.r1;
  Result.r2 := -a.r2;
  Result.r3 := -a.r3;
end;

{ Mat4 }

constructor Mat4.Create(a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2,
  d3, d4: TVecType);
begin
  r1.x := a1;  r1.y := a2;  r1.z := a3; r1.w := a4;
  r2.x := b1;  r2.y := b2;  r2.z := b3; r2.w := b4;
  r3.x := c1;  r3.y := c2;  r3.z := c3; r3.w := c4;
  r4.x := d1;  r4.y := d2;  r4.z := d3; r4.w := d4;
end;

class operator Mat4.Multiply(const a: Mat4; const b: Vec4): Vec4;
begin
  Result.x := a.r1.Dot(b);
  Result.y := a.r2.Dot(b);
  Result.z := a.r3.Dot(b);
  Result.w := a.r4.Dot(b);
end;


function fwidth(const a: Vec2): TVecType;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
begin
  Result := Abs(a.x)+abs(a.y);
end;

function fwidth(const a: Vec3): TVecType;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
begin
  Result := Abs(a.x)+abs(a.y)+abs(a.z);

end;

function fwidth(const a: Vec4): TVecType;{$IFNDEF DEBUG} inline;{$ENDIF} overload;
begin
  Result := Abs(a.x)+abs(a.y)+abs(a.z)+abs(a.w);

end;






{ Mat2 }

constructor Mat2.Create(a1, a2, b1, b2: TVecType);
begin
  r1.x := a1;  r1.y := a2;
  r2.x := b1;  r2.y := b2;
end;

class operator Mat2.Multiply(const a: Mat2; const b: Vec2): Vec2;
begin
  Result.x := a.r1.Dot(b);
  Result.y := a.r2.Dot(b);
end;

class operator Mat2.Multiply(const b: Vec2; const a: Mat2): Vec2;
begin
  Result.x := b.Dot(a.r1);
  Result.y := b.Dot(a.r2);
end;

function hash(n:Double):Double;overload;
begin
  Result := fract(system.sin(n)*43758.5453123);
end;

function hash(const n:vec2):vec2;overload;
begin
  Result := fract(sin(n)*43758.5453123);
end;

function hash(const n:vec3):vec3;overload;
begin
  Result := fract(sin(n)*43758.5453123);
end;

function hash(const n:vec4):vec4;overload;
begin
  Result := fract(sin(n)*43758.5453123);
end;


{ TTextureCube }

procedure TTextureCube.Load(Mask: string);
var
  f:TFace;
  fn:string;
begin
  for f in [POSITIVE_X..NEGATIVE_Z] do
  begin
    fn := StringReplace(Mask,'?',IntToStr(ord(f)),[  ]);
    if Faces[f]=nil then
      Faces[f] := tbitmap32.Create;
    TShader.LoadTexture(Faces[f], fn);
  end;
end;

procedure SelfTest;
  procedure TestFloor(x:double);
  var v2_1,v2_2:Vec2;
  begin
    v2_1.x := x;
    v2_1.y := x;
    v2_2 := floor(v2_1);
    Assert(v2_2.x = Math.Floor(v2_1.x));
    Assert(v2_2.y = Math.Floor(v2_1.y));
  end;

begin
  TestFloor( -100);
  TestFloor( -1.9);
  TestFloor( -1.1);
  TestFloor( -1  );
  TestFloor( -0.9);
  TestFloor( -0.1);
  TestFloor( -0.0);
  TestFloor(  0.0);
  TestFloor(  0.1);
  TestFloor(  0.9);
  TestFloor(  1  );
  TestFloor(  1.1);
  TestFloor(  1.9);
  TestFloor(100);
end;


{ TThreadedShader }

constructor TThreadedShader.Create(aShader: TShader);
var i:integer;
begin
  inherited Create;
  for I := 0 to 3 do
  begin
    Shaders[I].Shader := aShader.Create;
    Shaders[I].Shader.PixelProc := aShader.PixelProc;
    Shaders[I].Shader.LineProc := aShader.LineProc;
    Shaders[I].Shader.LastFrame := aShader.LastFrame;
    Shaders[I].Shader.UseBackBuffer := aShader.UseBackBuffer;
    Shaders[I].Shader.FrameProc := aShader.FrameProc;
    Shaders[I].Shader.iMouse := aShader.iMouse;
    Shaders[I].Shader.Mouse := aShader.Mouse;
    Shaders[I].Shader.Resolution := aShader.Resolution;
    Shaders[I].Shader.Frame := aShader.Frame;
    Shaders[I].Shader.Time := aShader.Time;
    Shaders[I].Shader.iGlobalTime := aShader.iGlobalTime;

  end;

  Shaders[0].Area   := Vec4.create(0.0,0.0,0.5,0.5);
  Shaders[1].Area   := Vec4.create(0.5,0.0,1.0,0.5);
  Shaders[2].Area   := Vec4.create(0.0,0.5,0.5,1.0);
  Shaders[3].Area   := Vec4.create(0.5,0.5,1.0,1.0);

  for I := 0 to 3 do
  begin
    Shaders[I].Rect.Left   := trunc(Shaders[I].Area.x * Buffer.Width);
    Shaders[I].Rect.Top    := trunc(Shaders[I].Area.y * Buffer.Height);
    Shaders[I].Rect.Right  := trunc(Shaders[I].Area.z * Buffer.Width);
    Shaders[I].Rect.Bottom := trunc(Shaders[I].Area.w * Buffer.Height);
  end;


end;

procedure TThreadedShader.RenderThreads(bitmap: TBitmap32);
var i:integer;
  b:TBitmap32;
begin
  for I := 0 to 3 do
  begin
        Shaders[I].Shader.OnProgress := self.OnProgress;
        Shaders[I].Shader.Mouse := self.Mouse;
        Shaders[I].Shader.iMouse := self.iMouse;
        Shaders[I].Shader.SetSize(trunc(Resolution.x),trunc(Resolution.y));
        Shaders[I].Shader.iGlobalTime := self.iGlobalTime;
        Shaders[I].Shader.Time        := self.iGlobalTime;

        Shaders[I].Rect.Left   := trunc(Shaders[I].Area.x * Buffer.Width);
        Shaders[I].Rect.Top    := trunc(Shaders[I].Area.y * Buffer.Height);
        Shaders[I].Rect.Right  := trunc(Shaders[I].Area.z * Buffer.Width);
        Shaders[I].Rect.Bottom := trunc(Shaders[I].Area.w * Buffer.Height);
  end;

{
    TThread.CreateAnonymousThread(
      procedure
      begin
        b := TBitmap32.Create;
        b.SetSize(trunc(Resolution.x),trunc(Resolution.y));
        Shaders[I].Shader.RenderTo(b,Shaders[I].Rect);

        TThread.Synchronize( TThread.CurrentThread, procedure
        begin
          b.DrawTo(bitmap, Shaders[I].Rect, Shaders[I].Rect);
        end);
        b.SaveToFile(format('%s_%d.bmp',[ Shaders[I].Shader.ClassName, i]));
        b.Free;
      end).Start;
}
  Shaders[0].Thread := TThread.CreateAnonymousThread(
      procedure
      begin
        b := TBitmap32.Create;
        b.SetSize(trunc(Resolution.x),trunc(Resolution.y));
        Shaders[0].Shader.RenderTo(b,Shaders[I].Rect);

        TThread.Synchronize( TThread.CurrentThread, procedure
        begin
          b.DrawTo(bitmap, Shaders[0].Rect, Shaders[0].Rect);
        end);
        b.SaveToFile(format('%s_%d.bmp',[ Shaders[0].Shader.ClassName, 0]));
        b.Free;
        TThread.CurrentThread.Terminate;
      end);

  Shaders[0].Thread.Start;

  repeat
    
  until (Shaders[0].Thread.Finished);    


end;

initialization
//  Frames.Init(nil,0);
//  Frames.Resume;
 {$IFDEF DEBUG}
 SelfTest;
 {$ENDIF}
finalization
//  FreeAndNil(FShaders);

end.
