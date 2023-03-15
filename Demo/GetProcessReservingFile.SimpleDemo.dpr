program GetProcessReservingFile.SimpleDemo;

uses
  Vcl.Forms,
  FormGetProcessReservingFileSimpleDemo in 'FormGetProcessReservingFileSimpleDemo.pas' {GetProcessReservingFileSimpleDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm8, Form8);
  Application.Run;
end.
