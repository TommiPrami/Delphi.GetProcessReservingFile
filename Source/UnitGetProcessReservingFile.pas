unit UnitGetProcessReservingFile;

interface

  function GetProcessReservingFile(const AFileName: string; out AProcessName: string): Boolean;

implementation

uses
  Winapi.Windows, System.SysUtils, UnitGetProcessReservingFile.Types;

function GetProcessReservingFile(const AFileName: string; out AProcessName: string): Boolean;
var
  dwSession: DWORD;
  szSessionKey: array[0..CCH_RM_SESSION_KEY] of Char;
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

end.
