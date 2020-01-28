{
Пакет             Simple Game Engine 1
Файл              sgeSimpleCommand.pas
Версия            1.2
Создан            08.06.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Простой синтаксический анализатор строковой команды
}

unit sgeSimpleCommand;

{$mode objfpc}{$H+}

interface



type
  TsgeSimpleCommand = class
  private
    FPartList: array of String;                           //Массив частей команды
    FCommand: String;                                     //Строка для разбора
    FSeparators: ShortString;                             //Разделители частей
    FStaple: Char;                                        //Кавычка
    FControl: Char;                                       //Экран
    FWeakSeparator: Boolean;                              //Мягкий разделитель
    FCount: Integer;                                      //Количество частей

    procedure SetSeparators(ASeparators: ShortString);
    procedure SetStaple(AStaple: Char);
    procedure SetControl(AControl: Char);
    procedure SetWeakSeparator(AWeakSeparator: Boolean);
    procedure SetCommand(ACommand: String);
    procedure SetPart(Index: Integer; APart: String);
    function  GetPart(Index: Integer): String;
    procedure SetCount(ACount: Integer);
    function  GetSecuredCommand: String;

    function  GetFirstSeparator: Char;
    function  IsSeparator(Symbol: Char): Boolean;
    procedure AddSymbolToLastPart(S: Char);

    procedure Parse;
  public
    constructor Create(Command: String = ''; WeakSeparator: Boolean = True; Separators: ShortString = #32#9; Staple: Char = #39; Control: Char = '`');
    destructor  Destroy; override;

    //Возврат сырой части команды начиная со StartPart
    function GetTail(StartPart: Integer): String;

    property Command: String read FCommand write SetCommand;
    property SecuredCommand: String read GetSecuredCommand;
    property Separators: ShortString read FSeparators write SetSeparators;
    property Staple: Char read FStaple write SetStaple;
    property Control: Char read FControl write SetControl;
    property WeakSeparator: Boolean read FWeakSeparator write SetWeakSeparator;
    property Count: Integer read FCount write SetCount;
    property Part[Index: Integer]: String read GetPart write SetPart; //default;
  end;




implementation

uses
  sgeConst, sgeTypes,
  SysUtils;


const
  _UNITNAME = 'sgeSimpleCommand';



procedure TsgeSimpleCommand.SetSeparators(ASeparators: ShortString);
begin
  if ASeparators = '' then ASeparators := #32;
  if FSeparators = ASeparators then Exit;

  FSeparators := ASeparators;
  Parse;
end;


procedure TsgeSimpleCommand.SetStaple(AStaple: Char);
begin
  if FStaple = AStaple then Exit;

  FStaple := AStaple;
  Parse;
end;


procedure TsgeSimpleCommand.SetControl(AControl: Char);
begin
  if FControl = AControl then Exit;

  FControl := AControl;
  Parse;
end;


procedure TsgeSimpleCommand.SetWeakSeparator(AWeakSeparator: Boolean);
begin
  if FWeakSeparator = AWeakSeparator then Exit;

  FWeakSeparator := AWeakSeparator;
  Parse;
end;


procedure TsgeSimpleCommand.SetCommand(ACommand: String);
begin
  if FCommand = ACommand then Exit;

  FCommand := ACommand;
  Parse;
end;


procedure TsgeSimpleCommand.SetPart(Index: Integer; APart: String);
begin
  if (Index < 0) or (Index > FCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FPartList[Index] := APart;
end;


function TsgeSimpleCommand.GetPart(Index: Integer): String;
begin
  if (Index < 0) or (Index > FCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FPartList[Index];
end;


procedure TsgeSimpleCommand.SetCount(ACount: Integer);
begin
  if ACount < 0 then ACount := 0;
  if FCount = ACount then Exit;

  FCount := ACount;
  SetLength(FPartList, FCount);
end;


function TsgeSimpleCommand.GetSecuredCommand: String;
var
  i, c, j: Integer;
  bSeparator: Boolean;
  sPart, s, PartSeparator: String;
begin
  Result := '';
  PartSeparator := GetFirstSeparator;

  //Цикл по частям
  c := Length(FPartList) - 1;
  for i := 0 to c do
    begin
    sPart := '';
    s := FPartList[i];
    bSeparator := False;

    //Пробежать по строке
    for j := 1 to Length(s) do
      begin
      if (s[j] = FStaple) or (s[j] = FControl) then
        begin
        sPart := sPart + FControl + s[j];
        Continue;
        end;

      if IsSeparator(s[j]) then
        begin

        if not bSeparator then
          begin
          bSeparator := True;
          sPart := sPart + FStaple + s[j];
          end
          else sPart := sPart + s[j];

        Continue;
        end;

      if bSeparator then
        begin
        bSeparator := False;
        sPart := sPart + FStaple + s[j];
        end
        else sPart := sPart + s[j];

      end;//For



    //Добавить в результат
    Result := Result + sPart;
    if i <> c then Result := Result + PartSeparator;
    end;
end;


function TsgeSimpleCommand.GetFirstSeparator: Char;
begin
  Result := FSeparators[1];
end;


function TsgeSimpleCommand.IsSeparator(Symbol: Char): Boolean;
var
  c, i: Integer;
begin
  Result := False;

  c := Length(FSeparators);
  for i := 1 to c do
    if FSeparators[i] = Symbol then
      begin
      Result := True;
      Break;
      end;
end;


procedure TsgeSimpleCommand.AddSymbolToLastPart(S: Char);
var
  c, Idx: Integer;
begin
  c := Length(FPartList);
  Idx := c - 1;

  if c = 0 then
    begin
    SetLength(FPartList, 1);
    Idx := 0;
    end;

  FPartList[Idx] := FPartList[Idx] + S;
end;


procedure TsgeSimpleCommand.Parse;
const
  sNormal = 0;
  sSeparator = 1;
  sStaple = 2;
  sControl = 3;
  sControlInStaple = 4;

label
  A1;

var
  S: Char;
  i, c: Integer;
  State: Byte;
begin
  //Проверить на пустую команду
  if FCommand = '' then Exit;

  //Подготовка
  SetLength(FPartList, 0);
  State := sNormal;

  //Просмотреть символы по порядку
  for i := 1 to Length(FCommand) do
    begin
    //Определить символ
    S := FCommand[i];

    //Обработать состояние
    A1:
    case State of
      sNormal:
        begin
        if IsSeparator(S) then
          begin
          State := sSeparator;
          Continue;
          end;

        if S = FStaple then
          begin
          State := sStaple;
          Continue;
          end;

        if S = FControl then
          begin
          State := sControl;
          Continue;
          end;

        AddSymbolToLastPart(S);
        end;


      sSeparator:
        begin
        if FWeakSeparator and IsSeparator(S) then Continue;

        //Добавить новую часть
        c := Length(FPartList);
        SetLength(FPartList, c + 1);
        State := sNormal;
        goto A1;
        end;


      sStaple:
        begin
        if S = FControl then
          begin
          State := sControlInStaple;
          Continue;
          end;

        if S = FStaple then
          begin
          State := sNormal;
          Continue;
          end;

        AddSymbolToLastPart(S);
        end;


      sControl:
        begin
        AddSymbolToLastPart(S);
        State := sNormal;
        end;


      sControlInStaple:
        begin
        AddSymbolToLastPart(S);
        State := sStaple;
        end;
    end;

    end;//For


  //Запомнить длину частей
  FCount := Length(FPartList);
end;


constructor TsgeSimpleCommand.Create(Command: String; WeakSeparator: Boolean; Separators: ShortString; Staple: Char; Control: Char);
begin
  //Параметры
  FCommand := Command;
  FStaple := Staple;
  FControl := Control;
  FWeakSeparator := WeakSeparator;

  SetSeparators(Separators);
end;


destructor TsgeSimpleCommand.Destroy;
begin
  SetLength(FPartList, 0);
end;


function TsgeSimpleCommand.GetTail(StartPart: Integer): String;
const
  sNormal = 0;
  sSeparator = 1;

label
  A1;

var
  i, c, CurrentPartIdx: Integer;
  State: Byte;
begin
  Result := '';
  CurrentPartIdx := 0;
  State := sNormal;
  c := Length(FCommand);
  for i := 1 to c do

    A1:
    case State of
      sNormal:
        begin
        if IsSeparator(FCommand[i]) and (CurrentPartIdx < StartPart) then
          begin
          State := sSeparator;
          Continue;
          end;

        if CurrentPartIdx >= StartPart then Result := Result + FCommand[i];
        end;


      sSeparator:
        begin
        if IsSeparator(FCommand[i]) then Continue;

        State := sNormal;
        Inc(CurrentPartIdx);
        goto A1;
        end;
    end;

end;



end.

