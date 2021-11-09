inherited CnUsesIdentForm: TCnUsesIdentForm
  Caption = 'Search Identifier in Units to Uses'
  ClientHeight = 491
  ClientWidth = 730
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlHeader: TPanel
    Width = 730
    inherited lblProject: TLabel
      Left = 631
      Visible = False
    end
    object lblAddTo: TLabel [2]
      Left = 329
      Top = 12
      Width = 36
      Height = 13
      Caption = '&Add to:'
    end
    inherited cbbProjectList: TComboBox
      Left = 672
      Width = 51
      Visible = False
    end
    object rbImpl: TRadioButton
      Left = 476
      Top = 11
      Width = 109
      Height = 17
      Caption = 'Implementation'
      TabOrder = 3
    end
    object rbIntf: TRadioButton
      Left = 388
      Top = 12
      Width = 85
      Height = 17
      Caption = 'Interface'
      Checked = True
      TabOrder = 2
      TabStop = True
    end
  end
  inherited lvList: TListView
    Width = 730
    Height = 406
    Columns = <
      item
        Caption = 'Identifier'
        Width = 210
      end
      item
        Caption = 'Unit'
        Width = 140
      end
      item
        Caption = 'Path'
        Width = 260
      end
      item
        Caption = 'Project'
        Width = 90
      end>
    OwnerData = True
    OnData = lvListData
  end
  inherited StatusBar: TStatusBar
    Top = 472
    Width = 730
    Panels = <
      item
        Style = psOwnerDraw
        Width = 340
      end
      item
        Width = 110
      end>
  end
  inherited ToolBar: TToolBar
    Width = 730
    inherited btnSep3: TToolButton
      Visible = False
    end
  end
  inherited ActionList: TActionList
    inherited actAttribute: TAction
      Visible = False
    end
    inherited actSelectAll: TAction
      Visible = False
    end
    inherited actSelectNone: TAction
      Visible = False
    end
    inherited actSelectInvert: TAction
      Visible = False
    end
    inherited actHookIDE: TAction
      Visible = False
    end
    inherited actQuery: TAction
      Visible = False
    end
  end
end