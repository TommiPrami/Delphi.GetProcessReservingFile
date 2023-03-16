unit UnitGetProcessReservingFile;

interface

  function GetProcessReservingFile(const AFileName: string; out AProcessName: string): Boolean;

implementation

uses
  Winapi.Windows, System.SysUtils, UnitGetProcessReservingFile.Types;

function CheckProcessTime(const AProcessHandle: THandle; const AProcessStartTime: TFileTime): Boolean;
var
  LCreateTime: TFileTime;
  LExitTile: TFileTime;
  LKernelTime: TFileTime;
  LUserTime: TFileTime;
begin
  Result := GetProcessTimes(AProcessHandle, LCreateTime, LExitTile, LKernelTime, LUserTime);

  if Result then
    Result := CompareFileTime(@AProcessStartTime, @LCreateTime) = 0;
end;

function CheckProcess(const AProcessInfo: RM_PROCESS_INFO; out AProcessName: string): Boolean;
var
  LProcessHandle: THandle;
  LBufferSize: Cardinal;
  LProcessNameBuffer: array[0..MAX_PATH - 1] of Char;
begin
  Result := False;
  LProcessHandle := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, AProcessInfo.Process.dwProcessId);

  if LProcessHandle <> 0 then
  try
    if CheckProcessTime(LProcessHandle, AProcessInfo.Process.ProcessStartTime) then
    begin
      LBufferSize := MAX_PATH;

      if QueryFullProcessImageNameW(LProcessHandle, 0, LProcessNameBuffer, LBufferSize) and (LBufferSize <= MAX_PATH) then
      begin
        AProcessName := LProcessNameBuffer;
        Exit(True);
      end;
    end;
  finally
    CloseHandle(LProcessHandle);
  end;
end;

function CheckProcessList(const ASessionHandle: DWORD; out AProcessName: string): Boolean;
var
  LIndex: Integer;
  LReason: DWORD;
  LProcInfoNeeded: UINT;
  LProcInfoCount: UINT;
  LProcessInfoArray: array[0..9] of RM_PROCESS_INFO;
begin
  Result := False;
  LProcInfoCount := SizeOf(LProcessInfoArray) div SizeOf(RM_PROCESS_INFO);

  if RmGetList(ASessionHandle, LProcInfoNeeded, LProcInfoCount, @LProcessInfoArray[0], LReason) = ERROR_SUCCESS then
  begin
    for LIndex := 0 to LProcInfoCount - 1 do
      Result := CheckProcess(LProcessInfoArray[LIndex], AProcessName);
  end;
end;

function GetProcessReservingFile(const AFileName: string; out AProcessName: string): Boolean;
var
  LSessionHandle: DWORD;
  LSessionKeyBuffer: array[0..CCH_RM_MAX_SESSION_KEY] of Char;
  LFilenamePointer: PCWSTR;
begin
  Result := False;
  FillChar(LSessionKeyBuffer, SizeOf(LSessionKeyBuffer), #0);

  if RmStartSession(LSessionHandle, 0, LSessionKeyBuffer) = ERROR_SUCCESS then
  try
    LFilenamePointer := PCWSTR(AFileName);

    if RmRegisterResources(LSessionHandle, 1, @LFilenamePointer, 0, nil, 0, nil) = ERROR_SUCCESS then
      Result := CheckProcessList(LSessionHandle, AProcessName);
  finally
    RmEndSession(LSessionHandle);
  end;
end;

end.
