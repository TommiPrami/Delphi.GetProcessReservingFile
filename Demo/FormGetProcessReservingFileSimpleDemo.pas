unit FormGetProcessReservingFileSimpleDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

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

{$R *.dfm}

const
  CCH_RM_SESSION_KEY = 255;
  CCH_RM_MAX_APP_NAME = 255;
  CCH_RM_MAX_SVC_NAME = 63;
  PROCESS_QUERY_LIMITED_INFORMATION = $1000;

type
  RM_UNIQUE_PROCESS = record
    dwProcessId: DWORD;
    ProcessStartTime: FILETIME;
  end;

  RM_APP_TYPE = (
    RmUnknownApp = 0, // Unknown application type.
    RmMainWindow = 1, // Application that has a top-level window.
    RmOtherWindow = 2, // Application that does not have a top-level window.
    RmService = 3, // Service.
    RmExplorer = 4, // Explorer process.
    RmConsole = 5, // Console application.
    RmCritical = 1000 // Critical process.
  );

  RM_PROCESS_INFO = record
    Process: RM_UNIQUE_PROCESS;
    strAppName: array[0..CCH_RM_MAX_APP_NAME] of WCHAR;
    strServiceShortName: array[0..CCH_RM_MAX_SVC_NAME] of WCHAR;
    ApplicationType: RM_APP_TYPE;
    AppStatus: ULONG;
    TSSessionId: DWORD;
    bRestartable: BOOL;
  end;
  PRM_PROCESS_INFO = ^RM_PROCESS_INFO;

  PRM_UNIQUE_PROCESS = ^RM_UNIQUE_PROCESS;
  PWSTR = PWideChar;
  PCWSTR = PWideChar;

  function RmStartSession(var pSessionHandle: DWORD; dwSessionFlags: DWORD;
    strSessionKey: LPCWSTR): DWORD; stdcall; external 'rstrtmgr.dll';

  function RmEndSession(dwSessionHandle: DWORD): DWORD; stdcall; external 'rstrtmgr.dll';

  function RmRegisterResources(dwSessionHandle: DWORD; nFiles: UINT;
    rgsFilenames: PWCHAR; nApplications: UINT; rgApplications: PRM_UNIQUE_PROCESS;
    nServices: UINT; rgServices: PWSTR): DWORD; stdcall; external 'rstrtmgr.dll';

  function RmGetList(dwSessionHandle: DWORD; var pnProcInfoNeeded: UINT;
    var pnProcInfo: UINT; rgAffectedApps: PRM_PROCESS_INFO;
    var lpdwRebootReasons: DWORD): DWORD; stdcall; external 'rstrtmgr.dll';

  function QueryFullProcessImageNameW(hProcess: THandle; dwFlags: DWORD;
    lpExeName: LPWSTR; var lpdwSize: DWORD): BOOL; stdcall; external 'kernel32.dll';

function GetProcessReservingFile(const AFileName: string; out AProcessNAme: string): Boolean;
var
  dwSession: DWORD;
  szSessionKey: array[0..CCH_RM_SESSION_KEY] of WCHAR;
  dwError: DWORD;
  pszFile: PCWSTR;
  dwReason: DWORD;
  LIndex: Integer;
  nProcInfoNeeded: UINT;
  nProcInfo: UINT;
  rgpi: array[0..9] of RM_PROCESS_INFO;
  hProcess: THandle;
  ftCreate, ftExit, ftKernel, ftUser: TFileTime;
  sz: array[0..MAX_PATH - 1] of Char;
  cch: Cardinal;
begin
  Result := False;

  FillChar(szSessionKey, SizeOf(szSessionKey), #0);
  dwError := RmStartSession(dwSession, 0, szSessionKey);

  if (dwError = ERROR_SUCCESS) then
  try
    pszFile := PCWSTR(AFileName);
    dwError := RmRegisterResources(dwSession, 1, @pszFile, 0, nil, 0, nil);

    if dwError = ERROR_SUCCESS then
    begin
      nProcInfo := SizeOf(rgpi) div SizeOf(RM_PROCESS_INFO);

      dwError := RmGetList(dwSession, nProcInfoNeeded, nProcInfo, @rgpi[0], dwReason);

      if dwError = ERROR_SUCCESS then
      begin
        for LIndex := 0 to nProcInfo - 1 do
        begin
          hProcess := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, rgpi[LIndex].Process.dwProcessId);

          if hProcess <> 0 then
          try
            if GetProcessTimes(hProcess, ftCreate, ftExit, ftKernel, ftUser)
              and (CompareFileTime(@rgpi[LIndex].Process.ProcessStartTime, @ftCreate) = 0) then
            begin
              cch := MAX_PATH;

              if QueryFullProcessImageNameW(hProcess, 0, sz, cch) and (cch <= MAX_PATH) then
              begin
                AProcessName := sz;
                Exit(True);
              end;
            end;
          finally
            CloseHandle(hProcess);
          end;
        end;
      end;
    end;
  finally
    RmEndSession(dwSession);
  end;
end;

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
