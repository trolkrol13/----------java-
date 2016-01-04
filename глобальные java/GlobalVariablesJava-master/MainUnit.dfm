object MainForm: TMainForm
  Left = 1001
  Top = 158
  Width = 635
  Height = 733
  Caption = #1052#1077#1090#1088#1080#1082#1072' '#1043#1083#1086#1073#1072#1083#1100#1085#1099#1093' '#1087#1077#1088#1077#1084#1077#1085#1085#1099#1093' (Java)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object rightPnl: TPanel
    Left = 404
    Top = 0
    Width = 215
    Height = 695
    Align = alRight
    TabOrder = 1
    object lbl1: TLabel
      Left = 8
      Top = 136
      Width = 113
      Height = 13
      Caption = ' '#1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1084#1077#1090#1086#1076#1086#1074':'
    end
    object lbl2: TLabel
      Left = 8
      Top = 152
      Width = 162
      Height = 13
      Caption = ' '#1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1075#1083#1086#1073'. '#1087#1077#1088#1077#1084#1077#1085#1085#1099#1093':'
    end
    object lbl3: TLabel
      Left = 8
      Top = 176
      Width = 26
      Height = 13
      Caption = ' Aup:'
    end
    object lbl4: TLabel
      Left = 8
      Top = 192
      Width = 25
      Height = 13
      Caption = ' Pup:'
    end
    object lbl5: TLabel
      Left = 8
      Top = 208
      Width = 26
      Height = 13
      Caption = ' Rup:'
    end
    object modulesLbl: TLabel
      Left = 184
      Top = 136
      Width = 6
      Height = 13
      Caption = '0'
    end
    object variablesLbl: TLabel
      Left = 184
      Top = 152
      Width = 6
      Height = 13
      Caption = '0'
    end
    object aupLbl: TLabel
      Left = 48
      Top = 176
      Width = 6
      Height = 13
      Caption = '0'
    end
    object pupLbl: TLabel
      Left = 48
      Top = 192
      Width = 6
      Height = 13
      Caption = '0'
    end
    object rupLbl: TLabel
      Left = 48
      Top = 208
      Width = 6
      Height = 13
      Caption = '0'
    end
    object countMetricsBtn: TButton
      Left = 8
      Top = 64
      Width = 201
      Height = 49
      Caption = #1055#1086#1089#1095#1080#1090#1072#1090#1100' '#1084#1077#1090#1088#1080#1082#1091
      TabOrder = 1
      OnClick = countMetricsBtnClick
    end
    object loadFileBtn: TButton
      Left = 8
      Top = 8
      Width = 201
      Height = 49
      Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
      TabOrder = 0
      OnClick = loadFileBtnClick
    end
  end
  object leftPnl: TPanel
    Left = 0
    Top = 0
    Width = 404
    Height = 695
    Align = alClient
    TabOrder = 0
    object globalVarsPnl: TPanel
      Left = 1
      Top = 394
      Width = 402
      Height = 300
      Align = alBottom
      Constraints.MinHeight = 300
      TabOrder = 1
      object lbl7: TLabel
        Left = 1
        Top = 1
        Width = 400
        Height = 16
        Align = alTop
        Caption = ' '#1043#1083#1086#1073#1072#1083#1100#1085#1099#1077' '#1087#1077#1088#1077#1084#1077#1085#1085#1099#1077':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object globalVarsMemo: TMemo
        Left = 1
        Top = 17
        Width = 400
        Height = 282
        Align = alClient
        Constraints.MinWidth = 400
        Lines.Strings = (
          'globalVarsMemo')
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        OnKeyPress = MemoKeyPress
      end
    end
    object srcPnl: TPanel
      Left = 1
      Top = 1
      Width = 402
      Height = 393
      Align = alClient
      TabOrder = 0
      object lbl6: TLabel
        Left = 1
        Top = 1
        Width = 400
        Height = 16
        Align = alTop
        Caption = ' '#1048#1089#1093#1086#1076#1085#1099#1081' '#1090#1077#1082#1089#1090' '#1087#1088#1086#1075#1088#1072#1084#1084#1099':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object sourceTextMemo: TMemo
        Left = 1
        Top = 17
        Width = 400
        Height = 375
        Align = alClient
        Constraints.MinHeight = 374
        Lines.Strings = (
          'sourceTextMemo')
        ScrollBars = ssBoth
        TabOrder = 0
        WantTabs = True
        OnKeyPress = MemoKeyPress
      end
    end
  end
  object fileOpenDlg: TOpenDialog
    Left = 584
    Top = 640
  end
  object XPManifest1: TXPManifest
    Left = 546
    Top = 640
  end
end
