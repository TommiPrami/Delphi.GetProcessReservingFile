object GetProcessReservingFileSimpleDemoForm: TGetProcessReservingFileSimpleDemoForm
  Left = 0
  Top = 0
  Caption = 'GetProcessReservingFileSimpleDemo'
  ClientHeight = 271
  ClientWidth = 1199
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  DesignSize = (
    1199
    271)
  TextHeight = 15
  object ComboBoxFilenameToCheck: TComboBox
    Left = 8
    Top = 17
    Width = 911
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = '..\..\..\README.md'
  end
  object ButtonCheckExternalReservation: TButton
    Left = 927
    Top = 16
    Width = 130
    Height = 25
    Action = ActionCheckExternalReservation
    Anchors = [akTop, akRight]
    TabOrder = 1
  end
  object ButtonCheckAnyReservation: TButton
    Left = 1061
    Top = 16
    Width = 130
    Height = 25
    Action = ActionCheckAnyReservation
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object MemoProcessNames: TMemo
    Left = 8
    Top = 56
    Width = 1183
    Height = 198
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvNone
    BevelOuter = bvNone
    Enabled = False
    ReadOnly = True
    TabOrder = 3
  end
  object ActionList: TActionList
    Left = 323
    Top = 82
    object ActionCheckExternalReservation: TAction
      Caption = 'External'
      Hint = 
        'Try to open the file; if that fails, another process holds it. C' +
        'annot detect a lock held by this app itself.'
      OnExecute = ActionCheckExternalReservationExecute
      OnUpdate = ActionCheckReservationUpdate
    end
    object ActionCheckAnyReservation: TAction
      Caption = 'External + self'
      Hint = 
        'Always ask the Restart Manager, even if we can open the file. Al' +
        'so catches a file locked by THIS application.'
      OnExecute = ActionCheckAnyReservationExecute
      OnUpdate = ActionCheckReservationUpdate
    end
  end
end
