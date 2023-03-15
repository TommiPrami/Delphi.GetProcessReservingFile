# Delphi.GetProcessReservingFile

Method to get process that has file opened, if any.

## Usage
    if GetProcessReservingFile(LFileName, LProcessFileName) then
      MemoPpocessNames.Lines.Add('The process that is holding your file as a hostage is: "' + LProcessFileName + '"');
