unit FormGetProcessReservingFileSimpleDemo;

interface

uses
  Winapi.Messages, Winapi.Windows, System.Classes, System.SysUtils, System.Variants, Vcl.Controls, Vcl.Dialogs,
  Vcl.Forms, Vcl.Graphics, Vcl.StdCtrls;

type
  TGetProcessReservingFileSimpleDemoForm = class(TForm)
    ButtonGetProcess: TButton;
    MemoPpocessNames: TMemo;
    EditFilenameToCheck: TEdit;
    procedure ButtonGetProcessClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GetProcessReservingFileSimpleDemoForm: TGetProcessReservingFileSimpleDemoForm;

implementation

uses
  UnitGetProcessReservingFile;

{$R *.dfm}

procedure TGetProcessReservingFileSimpleDemoForm.ButtonGetProcessClick(Sender: TObject);
var
  LProcess: string;
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(EditFilenameToCheck.Text, fmOpenReadWrite or fmShareExclusive);
  try
    if GetProcessReservingFile(LFileStream.FileName, LProcess) then
      MemoPpocessNames.Lines.Add(LProcess);
  finally
    LFileStream.Free;
  end;
end;

end.
