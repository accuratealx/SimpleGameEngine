{
Пакет             Simple Game Engine 1
Файл              sgeStartParameterList.pas
Версия            1.8
Создан            31.05.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Удобные стартовые параметры приложения
}

unit sgeStartParameterList;

{$mode objfpc}{$H+}

interface


type
  TsgeStartParameter = record
    Name: String;
    Value: String;
  end;


  TsgeStartParameterList = class
  private
    FParamList: array of TsgeStartParameter;    //Массив параметров
    FParamSeparator: Char;                      //Разделитель между параметрами
    FValueSeparator: Char;                      //Разделитель между именем параметра и значением
    FParamLine: String;                         //Строка параметров без ParamStr(0)
    FCmdLine: String;                           //Сырая строка параметров от системы

    procedure SetParamSeparator(ASeparator: Char);
    procedure SetValueSeparator(ASeparator: Char);

    procedure Clear;
    procedure Add(Name, Value: String);
    function  GetCount: Integer;
    function  IndexOf(Name: string): Integer;

    function  GetValue(Name: String): String;
    function  GetExist(Name: String): Boolean;
    function  GetParameter(Index: Integer): TsgeStartParameter;

    procedure GetNameAndValueFromString(Str: String; var pName, pValue: String);
    procedure FindParametersFromString(Str: String);
    function  GetRawParamString: String;
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
    property ParamString: String read FParamLine;
    property CmdLine: String read FCmdLine;
  end;



implementation

uses
  sgeConst, sgeTypes, sgeSimpleCommand,
  SysUtils, LazUTF8;


const
  _UNITNAME = 'sgeStartParameters';



function GetCommandLine: PWideChar; stdcall; external 'kernel32.dll' name 'GetCommandLineW';



procedure TsgeStartParameterList.SetParamSeparator(ASeparator: Char);
begin
  FParamSeparator := ASeparator;
  FindParametersFromString(FParamLine);
end;


procedure TsgeStartParameterList.SetValueSeparator(ASeparator: Char);
begin
  FValueSeparator := ASeparator;
  FindParametersFromString(FParamLine);
end;


procedure TsgeStartParameterList.Clear;
begin
  SetLength(FParamList, 0);
end;


procedure TsgeStartParameterList.Add(Name, Value: String);
var
  c, Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    begin
    c := GetCount;
    SetLength(FParamList, c + 1);
    FParamList[c].Name := Name;
    FParamList[c].Value := Value;
    end
    else FParamList[Idx].Value := Value;
end;


function TsgeStartParameterList.GetCount: Integer;
begin
  Result := Length(FParamList);
end;


{$Hints Off}
function TsgeStartParameterList.IndexOf(Name: string): Integer;
var
  i, c: Integer;
begin
  Result := -1;

  Name := UTF8LowerCase(Name);
  c := GetCount - 1;
  for i := 0 to c do
    if Name = UTF8LowerCase(FParamList[i].Name) then
      begin
      Result := i;
      Break;
      end;
end;
{$Hints on}


function TsgeStartParameterList.GetValue(Name: String): String;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_ParameterNotFound, Name);

  Result := FParamList[Idx].Value;
end;


function TsgeStartParameterList.GetExist(Name: String): Boolean;
begin
  Result := (IndexOf(Name) <> -1);
end;


function TsgeStartParameterList.GetParameter(Index: Integer): TsgeStartParameter;
begin
  if (Index < 0) or (Index > GetCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FParamList[Index];
end;


procedure TsgeStartParameterList.GetNameAndValueFromString(Str: String; var pName, pValue: String);
var
  IsName: Boolean;
  i, c: Integer;
  Symbol: Char;
begin
  pName := '';
  pValue := '';
  IsName := True;

  //Цикл по символам
  c := Length(Str);
  for i := 1 to c do
    begin
    //Выделить символ
    Symbol := Str[i];

    //Проверить на разделитель
    if (Symbol = FValueSeparator) and IsName then
      begin
      IsName := False;
      Continue;
      end;

    //Добавить символ
    case IsName of
      True : pName := pName + Symbol;
      False: pValue := pValue + Symbol;
    end;
    end;

  //Поправить результат
  pName := UTF8Trim(pName);
  pValue := UTF8Trim(pValue);
end;


{$Hints Off}
procedure TsgeStartParameterList.FindParametersFromString(Str: String);
var
  i, c: Integer;
  List: TsgeSimpleCommand;
  pName, pValue: String;
begin
  //Очистить список
  Clear;

  //Добавить путь к файлу в качестве первого параметра
  Add(ParamStr(0), '');

  //Подготовить список
  List := TsgeSimpleCommand.Create;                       //Создать список
  List.Separators := #32;                                 //Изменить разделитель на пробел
  List.WeakSeparator := True;                             //Мягкий разделитель
  List.Command := Str;                                    //Разбить строку на части через пробелы

  //Цикл по частям
  c := List.Count - 1;
  for i := 0 to c do
    begin
    GetNameAndValueFromString(List.Part[i], pName, pValue); //Вернуть из строки имя и значение
    if pName = '' then Continue;                            //Пропуск, если нет имени
    Add(pName, pValue);                                     //Добавить в массив
    end;

  //Очистить список
  List.Free;
end;
{$Hints On}


{$Warnings Off}
function TsgeStartParameterList.GetRawParamString: String;
begin
  Result := WideString(GetCommandLine);
end;
{$Warnings On}


{$Warnings Off}
function TsgeStartParameterList.GetNormalParamString: String;
var
  i, c: Integer;
  Quote: Boolean;
begin
  Result := FCmdLine;
  if Result = '' then Exit;

  //Определить длину первого параметра
  c := Length(Result);
  Quote := False;
  for i := 1 to c do
    begin
    if Result[i] = '"' then Quote := not Quote;
    if (Result[i] = ' ') and (not Quote) then Break;
    end;

  //Отрезать первый параметр
  Delete(Result, 1, i);

  //Вернуть результат
  Result := UTF8Trim(Result);
end;
{$Warnings On}


constructor TsgeStartParameterList.Create;
begin
  //Задать способ обработки
  FParamSeparator := ' ';
  FValueSeparator := '=';

  //Запоминть сырую строку параметров
  FCmdLine := GetRawParamString;

  //Запомнить строку параметров
  FParamLine := GetNormalParamString;

  //Найти параметры в строке
  FindParametersFromString(FParamLine);
end;


destructor TsgeStartParameterList.Destroy;
begin
  Clear;
end;




end.

