object GetProcessReservingFileSimpleDemoForm: TGetProcessReservingFileSimpleDemoForm
  Left = 0
  Top = 0
  Caption = 'GetProcessReservingFileSimpleDemo'
  ClientHeight = 154
  ClientWidth = 659
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    659
    154)
  TextHeight = 15
  object ButtonGetProcess: TButton
    Left = 543
    Top = 16
    Width = 108
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Get process'
    TabOrder = 0
    OnClick = ButtonGetProcessClick
  end
  object MemoPpocessNames: TMemo
    Left = 8
    Top = 56
    Width = 643
    Height = 81
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object EditFilenameToCheck: TEdit
    Left = 8
    Top = 17
    Width = 529
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    Text = 'C:\Temp\branch.txt'
  end
end
