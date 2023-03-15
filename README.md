# Delphi.GetProcessReservingFile

Method to get process that has file opened, if any.

Taken influence from this: https://devblogs.microsoft.com/oldnewthing/20120217-00/?p=8283

## Usage
    if GetProcessReservingFile(LFileName, LProcessFileName) then
      MemoPpocessNames.Lines.Add('The process that is holding your file as a hostage is: "' + LProcessFileName + '"');
