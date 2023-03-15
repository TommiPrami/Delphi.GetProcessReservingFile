unit UnitGetProcessReservingFile.Types;

interface

uses
  Winapi.Windows, Winapi.Messages;

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


implementation

end;