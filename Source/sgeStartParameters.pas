{
Пакет             Simple Game Engine 1
Файл              sgeStartParameters.pas
Версия            1.4
Создан            31.05.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Удобные стартовые параметры приложения
}

unit sgeStartParameters;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleCommand, SimpleParameters,
  sgeConst, sgeTypes,
  SysUtils;


type
  TsgeStartParameter = TSimpleParam;


  TsgeStartParameters = class
  private
    FParamSeparator: Char;            //Разделитель между параметрами
    FValueSeparator: Char;            //Разделитель между именем параметра и значением
    FParamLine: String;               //Строка параметров без ParamStr(0)
    FParameters: TSimpleParameters;   //Массив параметров

    procedure SetParamSeparator(ASeparator: Char);
    procedure SetValueSeparator(ASeparator: Char);
    function  GetCount: Integer;
    function  GetValue(Name: String): String;
    function  GetExist(Name: String): Boolean;
    function  GetParameter(Index: Integer): TsgeStartParameter;
    procedure FindParametersFromString(Str: String);
    function  GetNormalParamString: String;
  public
    constructor Create;
    destructor  Destroy; override;

    property ParamSeparator: Char read FParamSeparator write SetParamSeparator;
    property ValueSeparator: Char read FValueSeparator write SetValueSeparator;
    property Count: Integer read GetCount;
    property Parameter[Index: Integer]: TsgeStartParameter read GetParameter;
    property Value[Name: String]: String read GetValue;
    property Exist[Name: String]: Boolean read GetExist;
    property ParamString: String read GetNormalParamString;
  end;



implementation


const
  _UNITNAME = 'sgeStartParameters';


function GetCommandLine: PWideChar; stdcall; external 'kernel32.dll' name 'GetCommandLineW';



procedure TsgeStartParameters.SetParamSeparator(ASeparator: Char);
begin
  FParamSeparator := ASeparator;
  FindParametersFromString(FParamLine);
end;


procedure TsgeStartParameters.SetValueSeparator(ASeparator: Char);
begin
  FValueSeparator := ASeparator;
  FindParametersFromString(FParamLine);
end;


function TsgeStartParameters.GetCount: Integer;
begin
  Result := SimpleParameters_GetCount(@FParameters);
end;


function TsgeStartParameters.GetValue(Name: String): String;
begin
  if not SimpleParameters_Get(@FParameters, Name, Result) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_ParameterNotFound, Name));
end;


function TsgeStartParameters.GetExist(Name: String): Boolean;
var
  Idx: Integer;
begin
  Idx := SimpleParameters_GetIdxByName(@FParameters, Name);
  if Idx = -1 then Result := False else Result := True;
end;


function TsgeStartParameters.GetParameter(Index: Integer): TsgeStartParameter;
var
  Name: String;
begin
  if not SimpleParameters_GetNameByIdx(@FParameters, Index, Name) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index)));

  Result := FParameters[Index];
end;


procedure TsgeStartParameters.FindParametersFromString(Str: String);
var
  i, c: Integer;
  sa, sstr: TStringArray;
  s, pName, pValue: String;
begin
  SimpleParameters_Clear(@FParameters);                                           //Очистить выходной массив
  SimpleParameters_Add(@FParameters, ParamStr(0), '');                            //Добавить исполняемый файл
  SimpleCommand_Disassemble(@sa, Str, FParamSeparator);                           //Разбить на массив через пробелы учитывая спец символы
  c := StringArray_GetCount(@sa) - 1;                                             //Индекс последнего параметра
  for i := 0 to c do
    begin
    s := TrimLeft(sa[i]);                                                         //Обрезать пробелы слева
    SimpleCommand_Disassemble(@sstr, s, FValueSeparator, sp_Staple, sp_Control);  //Разобрать строку
    pName := Trim(sstr[0]);                                                       //Подготовить имя
    if pName = '' then Continue;                                                  //Если имя пустое, то не добавлять параметр
    pValue := '';                                                                 //Подготовить значение, потому как может не быть
    if StringArray_Equal(@sstr, 2) then pValue := Trim(sstr[1]);                  //Проверить 2 части у параметра или нет
    SimpleParameters_Add(@FParameters, pName, pValue);                            //Добавить в массив
    end;
  StringArray_Clear(@sstr);                                                       //Почистить память
  StringArray_Clear(@sa);                                                         //Почистить память
end;


function TsgeStartParameters.GetNormalParamString: String;
var
  Prm: String;
  i, c: Integer;
  Quote: Boolean;
begin
  Result := '';

  //Узнать строку запуска
  {$Warnings Off}
  Prm := WideString(GetCommandLine);
  {$Warnings On}
  if Prm = '' then Exit;

  //Определить длину первого параметра
  c := Length(Prm);
  Quote := False;
  for i := 1 to c do
    begin
    if Prm[i] = '"' then Quote := not Quote;
    if (Prm[i] = ' ') and (not Quote) then Break;
    end;

  //Отрезать первый параметр
  Delete(Prm, 1, i);

  //Вернуть результат
  Result := Trim(Prm);
end;


constructor TsgeStartParameters.Create;
begin
  //Задать способ обработки
  FParamSeparator := ' ';
  FValueSeparator := '=';

  //Запомнить строку параметров
  FParamLine := GetNormalParamString;

  //Найти параметры в строке
  FindParametersFromString(FParamLine);
end;


destructor TsgeStartParameters.Destroy;
begin
  SimpleParameters_Clear(@FParameters);
end;




end.

