# Delphi.GetProcessReservingFile

Method to get process that has file opened, if any.

Heavily influenced by: https://devblogs.microsoft.com/oldnewthing/20120217-00/?p=8283

## Usage

```Pascal
try
  OpenAndProcessFile(LFileName);
excpet
  on E: Exception do
  begin
    ...
    if GetProcessReservingFile(LFileName, LProcessFileName) then
      LErrorMEssage := LErrorMEssage + ' The process that is holding your file as a hostage is: "' + LProcessFileName + '"';
  end;
end;
```
