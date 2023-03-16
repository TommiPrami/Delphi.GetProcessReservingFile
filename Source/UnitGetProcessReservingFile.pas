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

function GetProcessReservingFile(const AFileName: string; out AProcessName: string): Boolean;
var
  LSessionHandle: DWORD;
  LSessionKeyBuffer: array[0..CCH_RM_MAX_SESSION_KEY] of Char;
  LApiResult: DWORD;
  LFilenamePointer: PCWSTR;
  LReason: DWORD;
  LIndex: Integer;
  LProcInfoNeeded: UINT;
  LProcInfoCount: UINT;
  LProcessInfoArray: array[0..9] of RM_PROCESS_INFO;
  LProcessHandle: THandle;
  LProcessNameBuffer: array[0..MAX_PATH - 1] of Char;
  LBufferSize: Cardinal;
begin
  Result := False;

  FillChar(LSessionKeyBuffer, SizeOf(LSessionKeyBuffer), #0);
  LApiResult := RmStartSession(LSessionHandle, 0, LSessionKeyBuffer);

  if LApiResult = ERROR_SUCCESS then
  try
    LFilenamePointer := PCWSTR(AFileName);
    LApiResult := RmRegisterResources(LSessionHandle, 1, @LFilenamePointer, 0, nil, 0, nil);

    if LApiResult = ERROR_SUCCESS then
    begin
      LProcInfoCount := SizeOf(LProcessInfoArray) div SizeOf(RM_PROCESS_INFO);

      LApiResult := RmGetList(LSessionHandle, LProcInfoNeeded, LProcInfoCount, @LProcessInfoArray[0], LReason);

      if LApiResult = ERROR_SUCCESS then
      begin
        for LIndex := 0 to LProcInfoCount - 1 do
        begin
          LProcessHandle := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, LProcessInfoArray[LIndex].Process.dwProcessId);

          if LProcessHandle <> 0 then
          try
            if CheckProcessTime(LProcessHandle, LProcessInfoArray[LIndex].Process.ProcessStartTime) then
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
      end;
    end;
  finally
    RmEndSession(LSessionHandle);
  end;
end;

end.
