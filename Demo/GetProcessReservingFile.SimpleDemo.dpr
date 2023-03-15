program GetProcessReservingFile.SimpleDemo;

uses
  Vcl.Forms,
  UnitGetProcessReservingFile.Types in'..\Source\UnitGetProcessReservingFile.Types.pas',
  UnitGetProcessReservingFile in '..\Source\UnitGetProcessReservingFile.pas',
  FormGetProcessReservingFileSimpleDemo in 'FormGetProcessReservingFileSimpleDemo.pas' {GetProcessReservingFileSimpleDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGetProcessReservingFileSimpleDemoForm, GetProcessReservingFileSimpleDemoForm);
  Application.Run;
end.
