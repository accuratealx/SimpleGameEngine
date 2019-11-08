{
Пакет             Simple Game Engine 1
Файл              sgeParameters.pas
Версия            1.3
Создан            07.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Параметры приложения
}

unit sgeParameters;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleParameters, SimpleCommand,
  sgeConst, sgeTypes, SysUtils;


type
  TsgeParameter = TSimpleParam;


  TsgeParameters = class
  private
    FParameters: TSimpleParameters;
    FIndent: Boolean;
    FOptions: TSearchOptions;

    function  GetCount: Integer;
    function  GetExist(Name: String): Boolean;
    procedure SetParameter(Index: Integer; Param: TsgeParameter);
    function  GetParameter(Index: Integer): TsgeParameter;
    procedure SetValue(Name: String; Value: String);
    function  GetValue(Name: String): String;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;
    function  IndexOf(Name: String): Integer;
    function  Add(Name: String; Value: String): Boolean;
    function  Add(Param: TsgeParameter): Boolean;
    procedure Add(Params: TsgeParameters);
    function  Insert(Index: Integer; Name: String; Value: String): Boolean;
    function  Insert(Index: Integer; Param: TsgeParameter): Boolean;
    procedure Insert(Index: Integer; Params: TsgeParameters);
    function  Delete(Index: Integer): Boolean;
    function  Delete(Name: String): Boolean;
    function  SetString(Name: String; Value: String): Boolean;
    function  SetInteger(Name: String; Value: Integer): Boolean;
    function  SetReal(Name: String; Value: Real): Boolean;
    function  SetBoolean(Name: String; Value: Boolean; TrueStr: String = 'True'; FalseStr: String = 'False'): Boolean;
    function  GetString(Name: String; var ResultValue: String): Boolean;
    function  GetInteger(Name: String; var ResultValue: Integer): Boolean;
    function  GetReal(Name: String; var ResultValue: Real): Boolean;
    function  GetBoolean(Name: String; var ResultValue: Boolean; TrueStr: String = 'True'): Boolean;
    procedure SaveToFile(FileName: String = ''; StrDivider: String = sa_StrDivider);
    procedure LoadFromFile(FileName: String = ''; StrDivider: String = sa_StrDivider);
    procedure UpdateInFile(FileName: String = ''; AutoAdd: Boolean = False; StrDivider: String = sa_StrDivider);
    procedure UpdateFromFile(FileName: String = ''; AutoAdd: Boolean = False; StrDivider: String = sa_StrDivider);
    function  Substitute(Str: String; OpenQuote: String = '@'; CloseQuote: String = ''): String;

    property Count: Integer read GetCount;
    property Parameter[Index: Integer]: TsgeParameter read GetParameter write SetParameter;
    property Exist[Name: String]: Boolean read GetExist;
    property Value[Name: String]: String read GetValue write SetValue;
    property Options: TSearchOptions read FOptions write FOptions;
    property Indent: Boolean read FIndent write FIndent;
  end;


implementation


const
  _UNITNAME = 'sgeParameters';


function TsgeParameters.GetCount: Integer;
begin
  Result := SimpleParameters_GetCount(@FParameters);
end;


function TsgeParameters.GetExist(Name: String): Boolean;
var
  Idx: Integer;
begin
  Idx := SimpleParameters_GetIdxByName(@FParameters, Name, FOptions);
  if Idx = -1 then Result := False else Result := True;
end;


procedure TsgeParameters.SetParameter(Index: Integer; Param: TsgeParameter);
var
  c: Integer;
begin
  c := Count - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  FParameters[Index] := Param;
end;


function TsgeParameters.GetParameter(Index: Integer): TsgeParameter;
var
  c: Integer;
begin
  c := Count - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  Result := FParameters[Index];
end;


procedure TsgeParameters.SetValue(Name: String; Value: String);
begin
  if not SimpleParameters_Set(@FParameters, Name, Value, FOptions) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ParameterNotFound, Name));
end;


function TsgeParameters.GetValue(Name: String): String;
begin
  if not SimpleParameters_Get(@FParameters, Name, Result, FOptions) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ParameterNotFound, Name));
end;


constructor TsgeParameters.Create;
begin
  FIndent := True;
end;


destructor TsgeParameters.Destroy;
begin
  Clear;
end;


procedure TsgeParameters.Clear;
begin
  SimpleParameters_Clear(@FParameters);
end;


function TsgeParameters.IndexOf(Name: String): Integer;
begin
  Result := SimpleParameters_GetIdxByName(@FParameters, Name, FOptions);
end;


function TsgeParameters.Add(Name: String; Value: String): Boolean;
begin
  Result := SimpleParameters_Add(@FParameters, Name, Value, FOptions);
end;


function TsgeParameters.Add(Param: TsgeParameter): Boolean;
begin
  Result := SimpleParameters_Add(@FParameters, Param, FOptions);
end;


procedure TsgeParameters.Add(Params: TsgeParameters);
begin
  SimpleParameters_Add(@FParameters, @Params, FOptions);
end;


function TsgeParameters.Insert(Index: Integer; Name: String; Value: String): Boolean;
begin
  Result := SimpleParameters_Insert(@FParameters, Index, Name, Value, FOptions);
end;


function TsgeParameters.Insert(Index: Integer; Param: TsgeParameter): Boolean;
begin
  Result := SimpleParameters_Insert(@FParameters, Index, Param, FOptions);
end;


procedure TsgeParameters.Insert(Index: Integer; Params: TsgeParameters);
begin
  SimpleParameters_Insert(@FParameters, @Params, Index, Options);
end;


function TsgeParameters.Delete(Index: Integer): Boolean;
begin
  Result := SimpleParameters_Delete(@FParameters, Index);
end;


function TsgeParameters.Delete(Name: String): Boolean;
begin
  Result := SimpleParameters_Delete(@FParameters, Name, FOptions);
end;


function TsgeParameters.SetString(Name: String; Value: String): Boolean;
begin
  Result := SimpleParameters_Set(@FParameters, Name, Value, FOptions);
end;


function TsgeParameters.SetInteger(Name: String; Value: Integer): Boolean;
begin
  Result := SimpleParameters_Set(@FParameters, Name, Value, FOptions);
end;


function TsgeParameters.SetReal(Name: String; Value: Real): Boolean;
begin
  Result := SimpleParameters_Set(@FParameters, Name, Value, FOptions);
end;


function TsgeParameters.SetBoolean(Name: String; Value: Boolean; TrueStr: String; FalseStr: String): Boolean;
begin
  Result := SimpleParameters_Set(@FParameters, Name, Value, TrueStr, FalseStr, FOptions);
end;


function TsgeParameters.GetString(Name: String; var ResultValue: String): Boolean;
begin
  Result := SimpleParameters_Get(@FParameters, Name, ResultValue, FOptions);
end;


function TsgeParameters.GetInteger(Name: String; var ResultValue: Integer): Boolean;
begin
  Result := SimpleParameters_Get(@FParameters, Name, ResultValue, FOptions);
end;


function TsgeParameters.GetReal(Name: String; var ResultValue: Real): Boolean;
begin
  Result := SimpleParameters_Get(@FParameters, Name, ResultValue, FOptions);
end;


function TsgeParameters.GetBoolean(Name: String; var ResultValue: Boolean; TrueStr: String): Boolean;
begin
  Result := SimpleParameters_Get(@FParameters, Name, ResultValue, TrueStr, FOptions);
end;


procedure TsgeParameters.SaveToFile(FileName: String; StrDivider: String);
begin
  if not SimpleParameters_SaveToFile(@FParameters, FileName, FIndent, StrDivider) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileWriteError, FileName));
end;


procedure TsgeParameters.LoadFromFile(FileName: String; StrDivider: String);
begin
  if not SimpleParameters_LoadFromFile(@FParameters, FileName, StrDivider) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileReadError, FileName));
end;


procedure TsgeParameters.UpdateInFile(FileName: String; AutoAdd: Boolean; StrDivider: String);
begin
  if not SimpleParameters_UpdateInFile(@FParameters, FileName, FIndent, FOptions, StrDivider, AutoAdd) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileWriteError, FileName));
end;


procedure TsgeParameters.UpdateFromFile(FileName: String; AutoAdd: Boolean; StrDivider: String);
begin
  if not SimpleParameters_UpdateFromFile(@FParameters, FileName, FOptions, StrDivider, AutoAdd) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_FileReadError, FileName));
end;


function TsgeParameters.Substitute(Str: String; OpenQuote: String; CloseQuote: String): String;
var
  i, c: Integer;
  s: String;
begin
  c := GetCount - 1;
  for i := 0 to c do
    begin
    s := SimpleCommand_SecureString(FParameters[i].Value);
    Str := StringReplace(Str, OpenQuote + FParameters[i].Name + CloseQuote, s, [rfIgnoreCase, rfReplaceAll]);
    end;

  Result := Str;
end;





end.

