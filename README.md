# Delphi.GetProcessReservingFile

Returns the process that currently has a given file open, if any.

Heavily influenced by: https://devblogs.microsoft.com/oldnewthing/20120217-00/?p=8283

## Usage

```Pascal
try
  OpenAndProcessFile(LFileName); // your code that opens the file
except
  on E: Exception do
  begin
    ...
    if GetProcessReservingFile(LFileName, LProcessFileName) then
      LErrorMessage := LErrorMessage + ' The process that is holding your file hostage is: "' + LProcessFileName + '"';
  end;
end;
```
