{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnAICoderWizard;
{ |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵ�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7/10/11 + Delphi + C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�������ʽ
* �޸ļ�¼��2024.04.29 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles,ComCtrls, StdCtrls, CnConsts, CnWizClasses, CnWizUtils,
  CnWizConsts, CnCommon, CnAICoderConfig, CnThreadPool, CnAICoderEngine,
  CnFrmAICoderOption, CnAICoderChatFrm;

type
  TCnAICoderConfigForm = class(TForm)
    lblActiveEngine: TLabel;
    cbbActiveEngine: TComboBox;
    pgcAI: TPageControl;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkProxy: TCheckBox;
    edtProxy: TEdit;
  private
    FTabsheets: array of TTabSheet;
    FOptionFrames: array of TCnAICoderOptionFrame;
  public
    procedure LoadFromOptions;
    procedure SaveToOptions;
  end;
 
//==============================================================================
// AI ���������Ӳ˵�ר��
//==============================================================================

{ TCnAICoderWizard }

  TCnAICoderWizard = class(TCnSubMenuWizard)
  private
    FIdExplainCode: Integer;
    FIdShowChatWindow: Integer;
    FIdConfig: Integer;
    function ValidateAIEngines: Boolean;
    {* ���ø�������ǰ��� AI ���漰����}
    procedure ExplainCodeAnswer(Success: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal);
    procedure EnsureChatWindowVisible;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

{$R *.DFM}

uses
  CnWizOptions {$IFDEF DEBUG} , CnDebug {$ENDIF};

//==============================================================================
// AI ��������˵�ר��
//==============================================================================

{ TCnAICoderWizard }

procedure TCnAICoderWizard.Config;
begin
  with TCnAICoderConfigForm.Create(nil) do
  begin
    LoadFromOptions;
    if ShowModal = mrOK then
    begin
      SaveToOptions;

      DoSaveSettings;
    end;
  end;
end;

constructor TCnAICoderWizard.Create;
begin
  inherited;

end;

destructor TCnAICoderWizard.Destroy;
begin
  inherited;

end;

// �������ظ÷����������Ӳ˵�ר����
procedure TCnAICoderWizard.AcquireSubActions;
begin
  FIdExplainCode := RegisterASubAction(SCnAICoderWizardExplainCode,
    SCnAICoderWizardExplainCodeCaption, 0,
    SCnAICoderWizardExplainCodeHint, SCnAICoderWizardExplainCode);

  // �����ָ��˵�
  AddSepMenu;

  FIdShowChatWindow := RegisterASubAction(SCnAICoderWizardChatWindow,
    SCnAICoderWizardChatWindowCaption, 0,
    SCnAICoderWizardChatWindowHint, SCnAICoderWizardChatWindow);

  FIdConfig := RegisterASubAction(SCnAICoderWizardConfig,
    SCnAICoderWizardConfigCaption, 0, SCnAICoderWizardConfigHint, SCnAICoderWizardConfig);
end;

function TCnAICoderWizard.GetCaption: string;
begin
  Result := SCnAICoderWizardMenuCaption;
end;

function TCnAICoderWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnAICoderWizard.GetHint: string;
begin
  Result := SCnAICoderWizardMenuHint;
end;

function TCnAICoderWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnAICoderWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnAICoderWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnAICoderWizardComment;
end;

procedure TCnAICoderWizard.LoadSettings(Ini: TCustomIniFile);
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnAICoderEngineOptionFile, True);
  if FileExists(F) then
  begin
    CnAIEngineOptionManager.LoadFromFile(F);
    // ������Ҫ���ֶ����ô洢�Ļ��������
    CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('CnAIEngineOptionManager Load %d Options.', [CnAIEngineOptionManager.OptionCount]);
{$ENDIF}
end;

procedure TCnAICoderWizard.SaveSettings(Ini: TCustomIniFile);
var
  F: string;
begin
  F := WizOptions.GetUserFileName(SCnAICoderEngineOptionFile, False);
  CnAIEngineOptionManager.SaveToFile(F);
  WizOptions.CheckUserFile(SCnAICoderEngineOptionFile);
end;

procedure TCnAICoderWizard.SubActionExecute(Index: Integer);
var
  S: string;
begin
  if not Active then Exit;

  if Index = FIdConfig then
    Config
  else if Index = FIdShowChatWindow then
  begin
    if CnAICoderChatForm = nil then
      CnAICoderChatForm := TCnAICoderChatForm.Create(Application);

    CnAICoderChatForm.Visible := not CnAICoderChatForm.Visible;
  end
  else
  begin
    if not ValidateAIEngines then
    begin
      Config;
      Exit;
    end;

    if Index = FIdExplainCode then
    begin
      S := CnOtaGetCurrentSelection;
      if Trim(S) <> '' then
        CnAIEngineManager.CurrentEngine.AskAIEngineExplainCode(S, ExplainCodeAnswer);
    end;
  end;
end;

procedure TCnAICoderWizard.SubActionUpdate(Index: Integer);
begin
  if Index = FIdConfig then
    SubActions[Index].Enabled := Active
  else if Index = FIdShowChatWindow then
    SubActions[Index].Checked := (CnAICoderChatForm <> nil) and CnAICoderChatForm.Visible
  else
    SubActions[Index].Enabled := Active and (CnOtaGetCurrentSelection <> '');
end;

function TCnAICoderWizard.ValidateAIEngines: Boolean;
begin
  Result := False;
  if (CnAIEngineManager.CurrentEngine = nil) or
    (CnAIEngineManager.CurrentEngine.Option = nil) then
  begin
    ErrorDlg(SCnAICoderWizardErrorNoEngine);
    Exit;
  end;
  if (Trim(CnAIEngineManager.CurrentEngine.Option.URL) = '') then
  begin
    ErrorDlg(Format(SCnAICoderWizardErrorURLFmt, [CnAIEngineManager.CurrentEngine.EngineName]));
    Exit;
  end;
  if (Trim(CnAIEngineManager.CurrentEngine.Option.ApiKey) = '') then
  begin
    ErrorDlg(Format(SCnAICoderWizardErrorAPIKeyFmt, [CnAIEngineManager.CurrentEngine.EngineName]));
    Exit;
  end;

  Result := True;
end;

procedure TCnAICoderConfigForm.LoadFromOptions;
var
  I: Integer;
begin
  chkProxy.Checked := CnAIEngineOptionManager.UseProxy;
  edtProxy.Text := CnAIEngineOptionManager.ProxyServer;

  cbbActiveEngine.Items.Clear;
  for I := 0 to CnAIEngineManager.EngineCount - 1 do
    cbbActiveEngine.Items.Add(CnAIEngineManager.Engines[I].EngineName);

  cbbActiveEngine.ItemIndex := CnAIEngineManager.CurrentIndex;

  // ��ÿ�� Options ����һ�� Tab��ÿ�� Tab ����һ�� Frame���� Frame ��Ķ����� Option ����
  SetLength(FTabsheets, CnAIEngineOptionManager.OptionCount);
  SetLength(FOptionFrames, CnAIEngineOptionManager.OptionCount);

  for I := 0 to CnAIEngineOptionManager.OptionCount - 1 do
  begin
    // ��ÿ�� Options ����һ�� Tab
    FTabsheets[I] := TTabSheet.Create(pgcAI);
    FTabsheets[I].Caption := CnAIEngineOptionManager.Options[I].EngineName + Format(' (&%d)', [I + 1]);
    FTabsheets[I].PageControl := pgcAI;

    // ��ÿ�� Tab ����һ�� Frame
    FOptionFrames[I] := TCnAICoderOptionFrame.Create(FTabsheets[I]);
    FOptionFrames[I].Name := 'CnAICoderOptionFrame' + IntToStr(I);
    FOptionFrames[I].Parent := FTabsheets[I];
    FOptionFrames[I].Top := 0;
    FOptionFrames[I].Left := 0;
    FOptionFrames[I].Align := alClient;

    // ��ÿ�� Frame ��Ķ����� Option ����
    FOptionFrames[I].edtURL.Text := CnAIEngineOptionManager.Options[I].URL;
    FOptionFrames[I].edtAPIKey.Text := CnAIEngineOptionManager.Options[I].APIKey;
    FOptionFrames[I].edtModel.Text := CnAIEngineOptionManager.Options[I].Model;

    // ��ַ��������Ϲ������
    FOptionFrames[I].WebAddr := CnAIEngineOptionManager.Options[I].WebAddress;
  end;
end;

procedure TCnAICoderConfigForm.SaveToOptions;
var
  I: Integer;
begin
  for I := 0 to Length(FOptionFrames) - 1 do
  begin
    CnAIEngineOptionManager.Options[I].URL := FOptionFrames[I].edtURL.Text;
    CnAIEngineOptionManager.Options[I].APIKey := FOptionFrames[I].edtAPIKey.Text;
    CnAIEngineOptionManager.Options[I].Model := FOptionFrames[I].edtModel.Text;
  end;

  CnAIEngineOptionManager.ActiveEngine := cbbActiveEngine.Text;
  CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;

  CnAIEngineOptionManager.UseProxy := chkProxy.Checked;
  CnAIEngineOptionManager.ProxyServer := edtProxy.Text;
end;

procedure TCnAICoderWizard.ExplainCodeAnswer(Success: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal);
begin
  EnsureChatWindowVisible;

  if Success then
    CnAICoderChatForm.mmoContent.Lines.Add(Answer)
  else
    CnAICoderChatForm.mmoContent.Lines.Add(Format('%d %s', [ErrorCode, Answer]));
end;

procedure TCnAICoderWizard.EnsureChatWindowVisible;
begin
  if CnAICoderChatForm = nil then
    CnAICoderChatForm := TCnAICoderChatForm.Create(Application);

  CnAICoderChatForm.Visible := True;
  CnAICoderChatForm.BringToFront;
end;

initialization
  RegisterCnWizard(TCnAICoderWizard); // ע��ר��

end.