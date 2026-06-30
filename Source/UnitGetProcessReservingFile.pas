unit UnitGetProcessReservingFile;

interface

  function GetProcessReservingFile(const AFileName: string; out AProcessImagePath: string): Boolean;

implementation

uses
  Winapi.Windows, System.SysUtils, UnitGetProcessReservingFile.Types;

function ProcessStartTimeMatches(const AProcessHandle: THandle; const AProcessStartTime: TFileTime): Boolean;
var
  LCreateTime: TFileTime;
  LExitTime: TFileTime;
  LKernelTime: TFileTime;
  LUserTime: TFileTime;
begin
  Result := GetProcessTimes(AProcessHandle, LCreateTime, LExitTime, LKernelTime, LUserTime);

  if Result then
    Result := CompareFileTime(@AProcessStartTime, @LCreateTime) = 0;
end;

function TryGetProcessImageName(const AProcessInfo: RM_PROCESS_INFO; out AProcessImagePath: string): Boolean;
var
  LProcessHandle: THandle;
  LBufferSize: Cardinal;
  LProcessNameBuffer: array[0..MAX_PATH - 1] of Char;
begin
  Result := False;
  LProcessHandle := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, AProcessInfo.Process.dwProcessId);

  if LProcessHandle <> 0 then
  try
    if ProcessStartTimeMatches(LProcessHandle, AProcessInfo.Process.ProcessStartTime) then
    begin
      LBufferSize := MAX_PATH;

      if QueryFullProcessImageNameW(LProcessHandle, 0, LProcessNameBuffer, LBufferSize) and (LBufferSize <= MAX_PATH) then
      begin
        AProcessImagePath := LProcessNameBuffer;
        Exit(True);
      end;
    end;
  finally
    CloseHandle(LProcessHandle);
  end;
end;

function TryFindReservingProcess(const ASessionHandle: DWORD; out AProcessImagePath: string): Boolean;
var
  LIndex: Integer;
  LReason: DWORD;
  LProcInfoNeeded: UINT;
  LProcInfoCount: UINT;
  LGetListResult: DWORD;
  LProcessInfoArray: TArray<RM_PROCESS_INFO>;
begin
  Result := False;
  LProcInfoNeeded := 0;
  LProcInfoCount := 0;

  // First call with a zero-sized buffer to discover how many records are needed.
  // ERROR_MORE_DATA is the expected outcome here, not an error.
  LGetListResult := RmGetList(ASessionHandle, LProcInfoNeeded, LProcInfoCount, nil, LReason);

  if (LGetListResult <> ERROR_SUCCESS) and (LGetListResult <> ERROR_MORE_DATA) then
    Exit;

  if LProcInfoNeeded = 0 then
    Exit;

  SetLength(LProcessInfoArray, LProcInfoNeeded);
  LProcInfoCount := LProcInfoNeeded;

  if RmGetList(ASessionHandle, LProcInfoNeeded, LProcInfoCount, @LProcessInfoArray[0], LReason) = ERROR_SUCCESS then
    for LIndex := 0 to Integer(LProcInfoCount) - 1 do
      if TryGetProcessImageName(LProcessInfoArray[LIndex], AProcessImagePath) then
        Exit(True);
end;

function GetProcessReservingFile(const AFileName: string; out AProcessImagePath: string): Boolean;
var
  LSessionHandle: DWORD;
  LSessionKeyBuffer: array[0..CCH_RM_MAX_SESSION_KEY] of Char;
  LFileNamePointer: PCWSTR;
begin
  Result := False;
  FillChar(LSessionKeyBuffer, SizeOf(LSessionKeyBuffer), #0);

  if RmStartSession(LSessionHandle, 0, LSessionKeyBuffer) = ERROR_SUCCESS then
  try
    LFileNamePointer := PCWSTR(AFileName);

    if RmRegisterResources(LSessionHandle, 1, @LFileNamePointer, 0, nil, 0, nil) = ERROR_SUCCESS then
      Result := TryFindReservingProcess(LSessionHandle, AProcessImagePath);
  finally
    RmEndSession(LSessionHandle);
  end;
end;

end.
