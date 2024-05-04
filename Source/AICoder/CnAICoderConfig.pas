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

unit CnAICoderConfig;
{ |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵ����ô洢���뵥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�������ʽ
* �޸ļ�¼��2024.04.30 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Contnrs, CnJSON, CnNative, CnBase64, CnSM4;

type
  TCnAIEngineOption = class(TPersistent)
  {* һ�� AI ���������}
  private
    FURL: string;
    FSystemMessage: string;
    FApiKey: string;
    FModel: string;
    FEngineName: string;
    FTemperature: Extended;
    FExplainCodePrompt: string;
    FWebAddress: string;
  protected

  published
    property EngineName: string read FEngineName write FEngineName;
    {* AI ��������}

    property URL: string read FURL write FURL;
    {* �����ַ}
    property ApiKey: string read FApiKey write FApiKey;
    {* ���õ���Ȩ�룬�洢ʱ�����}
    property Model: string read FModel write FModel;
    {* ģ������}
    property Temperature: Extended read FTemperature write FTemperature;
    {* �¶Ȳ���}
    property SystemMessage: string read FSystemMessage write FSystemMessage;
    {* ϵͳԤ����Ϣ}

    property WebAddress: string read FWebAddress write FWebAddress;
    {* �������� APIKEY ����ַ}

    property ExplainCodePrompt: string read FExplainCodePrompt write FExplainCodePrompt;
    {* ���ʹ������ʾ����}
  end;

  TCnAIEngineOptionManager = class(TPersistent)
  {* AI �������ù����࣬���в�������� TCnAIEngineOption ����}
  private
    FOptions: TObjectList; // ���ɶ�� TCnAIEngineOption ���󣬿�����������
    FActiveEngine: string;
    function GetOptionCount: Integer;
    function GetOption(Index: Integer): TCnAIEngineOption;
    function GetActiveEngineIndex: Integer;
    {* ���ݻ�������Ʋ���������}
  protected
    // SM4 ��ʮ�����Ƽӽ���
    function EncryptKey(const Key: string): string;
    function DecryptKey(const Text: string): string;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;

    function GetOptionByEngine(const EngineName: string): TCnAIEngineOption;
    {* �������������Ҷ�Ӧ�����ö���}
    procedure RemoveOptionByEngine(const EngineName: string);
    {* ����������ɾ����Ӧ�����ö���}

    procedure AddOption(Option: TCnAIEngineOption);
    {* ����һ����紴�������úõ� AI �������ö����ڲ����ж��� EngineName �Ƿ��ظ�}

    procedure LoadFromFile(const FileName: string);
    {* �� JSON �ļ��м���}
    procedure SaveToFile(const FileName: string);
    {* ������ JSON �ļ���}

    procedure LoadFromJSON(const JSON: AnsiString);
    {* �� UTF8 ��ʽ�� JSON �ַ����м���}
    function SaveToJSON: AnsiString;
    {* ������ UTF8 ��ʽ�� JSON �ַ�����}

    property ActiveEngineIndex: Integer read GetActiveEngineIndex;
    {* ���ݻ�������Ʋ��ҵ��������ţ�������������}

    property OptionCount: Integer read GetOptionCount;
    {* ���е����ö�����}
    property Options[Index: Integer]: TCnAIEngineOption read GetOption;
    {* ���������Ż�ȡ���еĶ���}
  published
    property ActiveEngine: string read FActiveEngine write FActiveEngine;
    {* ��������ƣ����洢��������û����}
  end;

function CnAIEngineOptionManager: TCnAIEngineOptionManager;
{* ����һȫ�ֵ� AI �������ù�������}

implementation

const
  SM4_KEY: TCnSM4Key = ($43, $6E, $50, $61, $63, $6B, $20, $41, $49, $20, $43, $72, $79, $70, $74, $21);
  SM4_IV: TCnSM4Iv   = ($18, $40, $19, $21, $19, $31, $19, $37, $19, $45, $19, $49, $19, $53, $19, $78);

var
  FAIEngineOptionManager: TCnAIEngineOptionManager = nil;

function CnAIEngineOptionManager: TCnAIEngineOptionManager;
begin
  if FAIEngineOptionManager = nil then
    FAIEngineOptionManager := TCnAIEngineOptionManager.Create;
  Result := FAIEngineOptionManager;
end;

{ TCnAIEngineOptionManager }

procedure TCnAIEngineOptionManager.AddOption(Option: TCnAIEngineOption);
begin
  if (Option.EngineName = '') or (GetOptionByEngine(Option.EngineName) <> nil) then
    Exit;

  FOptions.Add(Option);
end;

procedure TCnAIEngineOptionManager.Clear;
begin
  FOptions.Clear;
end;

constructor TCnAIEngineOptionManager.Create;
begin
  inherited;
  FOptions := TObjectList.Create(True);
end;

function TCnAIEngineOptionManager.DecryptKey(const Text: string): string;
var
  K, Iv, Res: TBytes;
begin
  if Text = '' then
  begin
    Result := '';
    Exit;
  end;

  SetLength(K, SizeOf(SM4_KEY));
  Move(SM4_KEY[0], K[0], SizeOf(SM4_KEY));

  SetLength(Iv, SizeOf(SM4_IV));
  Move(SM4_IV[0], Iv[0], SizeOf(SM4_Iv));

  Res := SM4DecryptCbcBytesFromHex(K, Iv, Text);
  Result := Trim(BytesToAnsi(Res)); // ע��û�������룬�����Ҫ Trim ��β���Ͽ����е� #0
end;

destructor TCnAIEngineOptionManager.Destroy;
begin
  FOptions.Free;
  inherited;
end;

function TCnAIEngineOptionManager.EncryptKey(const Key: string): string;
var
  K, Iv: TBytes;
begin
  if Key = '' then
  begin
    Result := '';
    Exit;
  end;

  SetLength(K, SizeOf(SM4_KEY));
  Move(SM4_KEY[0], K[0], SizeOf(SM4_KEY));

  SetLength(Iv, SizeOf(SM4_IV));
  Move(SM4_IV[0], Iv[0], SizeOf(SM4_Iv));

  Result := SM4EncryptCbcBytesToHex(K, Iv, AnsiToBytes(Key));
end;

function TCnAIEngineOptionManager.GetActiveEngineIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  if FActiveEngine = '' then
    Exit;

  for I := 0 to FOptions.Count - 1 do
  begin
    if FActiveEngine = TCnAIEngineOption(FOptions[I]).EngineName then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TCnAIEngineOptionManager.GetOption(Index: Integer): TCnAIEngineOption;
begin
  Result := TCnAIEngineOption(FOptions[Index]);
end;

function TCnAIEngineOptionManager.GetOptionByEngine(const EngineName: string): TCnAIEngineOption;
var
  I: Integer;
begin
  for I := 0 to FOptions.Count - 1 do
  begin
    if EngineName = TCnAIEngineOption(FOptions[I]).EngineName then
    begin
      Result := TCnAIEngineOption(FOptions[I]);
      Exit;
    end;
  end;
  Result := nil;
end;

function TCnAIEngineOptionManager.GetOptionCount: Integer;
begin
  Result := FOptions.Count;
end;

procedure TCnAIEngineOptionManager.LoadFromFile(const FileName: string);
begin
  LoadFromJSON(TCnJSONReader.FileToJSON(FileName));
end;

procedure TCnAIEngineOptionManager.LoadFromJSON(const JSON: AnsiString);
var
  Root: TCnJSONObject;
  V: TCnJSONValue;
  Arr: TCnJSONArray;
  I: Integer;
  Option: TCnAIEngineOption;
begin
  Root := CnJSONParse(JSON);
  if Root = nil then
    Exit;

  TCnJSONReader.Read(Self, Root);

  V := Root.ValueByName['Engines'];
  if (V <> nil) and (V is TCnJSONArray) then
  begin
    Arr := TCnJSONArray(V);
    Clear;

    for I := 0 to Arr.Count - 1 do
    begin
      if Arr[I] is TCnJSONObject then
      begin
        Option := TCnAIEngineOption.Create;
        TCnJSONReader.Read(Option, TCnJSONObject(Arr[I]));

        // �����ԭ�ؽ��� APIKey
        Option.ApiKey := DecryptKey(Option.ApiKey);
        AddOption(Option);
      end;
    end;
  end;
end;

procedure TCnAIEngineOptionManager.RemoveOptionByEngine(const EngineName: string);
var
  I: Integer;
begin
  for I := FOptions.Count - 1 downto 0 do
  begin
    if EngineName = TCnAIEngineOption(FOptions[I]).EngineName then
      FOptions.Delete(I);
  end;
end;

procedure TCnAIEngineOptionManager.SaveToFile(const FileName: string);
begin
  TCnJSONWriter.JSONToFile(SaveToJSON, FileName);
end;

function TCnAIEngineOptionManager.SaveToJSON: AnsiString;
var
  Root, Obj: TCnJSONObject;
  Arr: TCnJSONArray;
  I: Integer;
  PlainKey: string;
begin
  Root := TCnJSONObject.Create;
  try
    TCnJSONWriter.Write(Self, Root);

    Arr := Root.AddArray('Engines');
    for I := 0 to OptionCount - 1 do
    begin
      Obj := TCnJSONObject.Create;

      PlainKey := Options[I].ApiKey;
      try
        // ԭ�ؼ��� APIKey
        Options[I].ApiKey := EncryptKey(Options[I].ApiKey);
        TCnJSONWriter.Write(Options[I], Obj);
      finally
        // �ڴ����ٻ�ԭ
        Options[I].ApiKey := PlainKey;
      end;
      Arr.AddValue(Obj);
    end;

    Result := CnJSONConstruct(Root);
  finally
    Root.Free;
  end;
end;

initialization

finalization
  FAIEngineOptionManager.Free;

end.