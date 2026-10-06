unit FormGetProcessReservingFileSimpleDemo;

interface

uses
  Winapi.Messages, Winapi.Windows, System.Classes, System.SysUtils, System.IOUtils, System.Variants, Vcl.Controls,
  Vcl.Dialogs, Vcl.Forms, Vcl.Graphics, Vcl.StdCtrls, System.Actions, Vcl.ActnList;

type
  TGetProcessReservingFileSimpleDemoForm = class(TForm)
    ActionCheckAnyReservation: TAction;
    ActionCheckExternalReservation: TAction;
    ActionList: TActionList;
    ButtonCheckAnyReservation: TButton;
    ButtonCheckExternalReservation: TButton;
    ComboBoxFilenameToCheck: TComboBox;
    MemoProcessNames: TMemo;
    procedure ActionCheckAnyReservationExecute(ASender: TObject);
    procedure ActionCheckExternalReservationExecute(ASender: TObject);
    procedure ActionCheckReservationUpdate(ASender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure AddWellKnownReservedFilesToList;
    procedure LogFileReservation(const AFileReserved: Boolean; const AFileName, AProcessFileName: string);
  end;

var
  GetProcessReservingFileSimpleDemoForm: TGetProcessReservingFileSimpleDemoForm;

implementation

uses
  UnitGetProcessReservingFile;

{$R *.dfm}

procedure TGetProcessReservingFileSimpleDemoForm.FormCreate(Sender: TObject);
begin
  AddWellKnownReservedFilesToList;
end;

procedure TGetProcessReservingFileSimpleDemoForm.AddWellKnownReservedFilesToList;

  procedure AddIfExists(const AFileName: string);
  begin
    if FileExists(AFileName) and (ComboBoxFilenameToCheck.Items.IndexOf(AFileName) < 0) then
      ComboBoxFilenameToCheck.Items.Add(AFileName);
  end;

var
  LLocalAppData: string;
begin
  ComboBoxFilenameToCheck.Text := ExpandFileName(ComboBoxFilenameToCheck.Text);
  AddIfExists(ComboBoxFilenameToCheck.Text);

  LLocalAppData := GetEnvironmentVariable('LOCALAPPDATA');

  // Files reliably held open by a normal user-session process (not the kernel), so the
  // Restart Manager can resolve a readable image path for whoever is holding them.
  // Kernel-held files such as pagefile.sys or the registry hives (NTUSER.DAT) are not
  // listed here, because the owning System process cannot be opened by a normal user.
  AddIfExists(TPath.Combine(LLocalAppData, 'Microsoft\Windows\Explorer\thumbcache_idx.db')); // held by explorer.exe
  AddIfExists(TPath.Combine(LLocalAppData, 'Microsoft\Windows\Explorer\iconcache_idx.db'));  // held by explorer.exe
  AddIfExists(TPath.Combine(LLocalAppData, 'Microsoft\Windows\WebCache\WebCacheV01.dat'));   // held by taskhostw.exe
end;

procedure TGetProcessReservingFileSimpleDemoForm.LogFileReservation(const AFileReserved: Boolean; const AFileName, AProcessFileName: string);
begin
  MemoProcessNames.Lines.Add('File: ' + AFileName);

  if AFileReserved then
    MemoProcessNames.Lines.Add('  - Reserved by process: ' + AProcessFileName)
  else
    MemoProcessNames.Lines.Add('  - File is NOT reserved by any process');

  MemoProcessNames.Lines.Add('');
end;

procedure TGetProcessReservingFileSimpleDemoForm.ActionCheckExternalReservationExecute(ASender: TObject);
var
  LProcessFileName: string;
  LFileName: string;
  LFileStream: TFileStream;
begin
  LProcessFileName := '';
  LFileName := ComboBoxFilenameToCheck.Text;

  { The intuitive check: try to open the file exclusively ourselves.
      - If that succeeds, no OTHER process is holding it -> report it as free.
      - If it fails with a sharing/access error, another process has it open, so ask the
        Restart Manager which process that is.
    This is simple, but it can NOT detect a file that THIS application itself has locked,
    because opening it again from the same process still succeeds. Use the other button
    ("External + self") for that case. }
  LFileStream := nil;
  try
    try
      LFileStream := TFileStream.Create(LFileName, fmOpenReadWrite or fmShareExclusive);
    except
      on EFOpenError do
        LFileStream := nil;
    end;

    if LFileStream <> nil then
      LogFileReservation(False, LFileName, '')
    else if GetProcessReservingFile(LFileName, LProcessFileName) then
      LogFileReservation(True, LFileName, LProcessFileName)
    else
      LogFileReservation(False, LFileName, ''); // could not open it, yet no holder found (e.g. a read-only file)
  finally
    LFileStream.Free;
  end;
end;

procedure TGetProcessReservingFileSimpleDemoForm.ActionCheckAnyReservationExecute(ASender: TObject);
var
  LProcessFileName: string;
  LFileName: string;
  LFileStream: TFileStream;
begin
  LProcessFileName := '';
  LFileName := ComboBoxFilenameToCheck.Text;

  { The thorough check: ALWAYS ask the Restart Manager who reserves the file, even when we
    can open it ourselves. This catches the non-obvious case: if your own application has the
    file locked exclusively somewhere, opening it again from the same process still "works",
    so the simple check ("External") would wrongly report it as free. Asking the Restart
    Manager regardless reveals that THIS process is the holder - so when a 3rd-party tool
    cannot open a file your app produced, you find the lock in your own code instead of
    blaming another application.

    To play the part of "your app already holding the file", the demo opens it exclusively
    here before querying. If another process already holds it, that open simply fails and we
    still report the real external holder. }
  LFileStream := nil;
  try
    try
      LFileStream := TFileStream.Create(LFileName, fmOpenReadWrite or fmShareExclusive);
    except
      on EFOpenError do
        LFileStream := nil; // another process holds it; the query below still finds the holder
    end;

    if GetProcessReservingFile(LFileName, LProcessFileName) then
      LogFileReservation(True, LFileName, LProcessFileName)
    else
      LogFileReservation(False, LFileName, '');
  finally
    LFileStream.Free;
  end;
end;

procedure TGetProcessReservingFileSimpleDemoForm.ActionCheckReservationUpdate(ASender: TObject);
var
  LAction: TAction;
  LFileName: string;
  LFileExists: Boolean;
begin
  if ASender is TAction then
  begin
    LAction := TAction(ASender);

    LFileName := ComboBoxFilenameToCheck.Text;
    LFileExists := not LFileName.IsEmpty and FileExists(LFileName);

    LAction.Enabled := LFileExists;
    MemoProcessNames.Enabled := LFileExists;

    if LFileExists then
      ComboBoxFilenameToCheck.Color := clWindow
    else
      ComboBoxFilenameToCheck.Color := TColor($00E1E1FF); // light red: entered file does not exist
  end;
end;

end.
