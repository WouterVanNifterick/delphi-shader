unit DelphiShader.Forms.Progress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, GR32_Image,
  Vcl.ExtCtrls;

type
  TfrmProgress = class(TForm)
    pb: TPaintBox32;
    Panel3: TPanel;
    Panel4: TPanel;
    Label4: TLabel;
    cmbResolution: TComboBox;
    Panel5: TPanel;
    Label5: TLabel;
    cmbAA: TComboBox;
    Button1: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    barOverall: TProgressBar;
    barFrames: TProgressBar;
    BarLines: TProgressBar;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FillResolutionInput;
    procedure FillAAInput;
  end;

var
  frmProgress: TfrmProgress;

implementation

uses Math;
{$R *.dfm}

{ TfrmProgress }

procedure TfrmProgress.FillAAInput;
var
  i: Integer;
begin
  cmbAA.Items.Add('none');
  for i := 1 to 3 do
  begin
    cmbAA.Items.Add(Round(Power(2, i)).ToString + ' x');
  end;
  cmbAA.ItemIndex := 1;
end;

procedure TfrmProgress.FillResolutionInput;
var i : integer;
begin
  for i := 6 to 24 do
  begin
    cmbResolution.Items.Add(Round(Power(2, i / 2)).ToString + ' x ' + Round(Power(2, i / 2)).ToString);
  end;
  cmbResolution.ItemIndex := 6;
end;


procedure TfrmProgress.FormCreate(Sender: TObject);
begin
  FillResolutionInput;
  FillAAInput;
end;

end.
