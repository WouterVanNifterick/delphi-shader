unit DelphiShader.Forms.Progress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, GR32_Image;

type
  TfrmProgress = class(TForm)
    barOverall: TProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    barFrames: TProgressBar;
    Label3: TLabel;
    BarLines: TProgressBar;
    pb: TPaintBox32;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProgress: TfrmProgress;

implementation

{$R *.dfm}

end.
