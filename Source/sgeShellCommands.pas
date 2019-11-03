{
Пакет             Simple Game Engine 1
Файл              sgeShellCommands.pas
Версия            1.2
Создан            09.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Хранилище указателей на команды оболочки
}

unit sgeShellCommands;

{$mode objfpc}{$H+}

interface

uses
  StringArray,
  sgeConst, sgeTypes,
  SysUtils;

type
  //Указатель на функцию
  TsgeShellCommandProc = function(Cmd: PStringArray): Integer;


  //Запись для хранения одной команды
  TsgeShellCommand = record
    Group: ShortString;         //Группа
    Name: ShortString;          //Имя команды
    Addr: TsgeShellCommandProc; //Указатель на функцию
    MinParams: Byte;            //Минимальное количество параметров
  end;


  //Массив команд
  TsgeShellCommandArray = array of TsgeShellCommand;



  TsgeShellCommands = class
  private
    FCommands: TsgeShellCommandArray;

    function  GetCount: Integer;
    procedure SetCommand(Index: Integer; Cmd: TsgeShellCommand);
    function  GetCommand(Index: Integer): TsgeShellCommand;
  public
    destructor Destroy; override;

    procedure Sort;
    function  IndexOf(Name: ShortString): Integer;
    procedure Clear;
    procedure Add(Cmd: TsgeShellCommand);
    procedure Add(Group, Name: ShortString; Adr: TsgeShellCommandProc; MinPrm: Byte);
    procedure Insert(Index: Integer; Cmd: TsgeShellCommand);
    procedure Delete(Index: Integer);
    procedure Delete(Name: ShortString);
    procedure DeleteByGroup(Group: ShortString);

    property Count: Integer read GetCount;
    property Command[Index: Integer]: TsgeShellCommand read GetCommand write SetCommand;
  end;



implementation


function TsgeShellCommands.GetCount: Integer;
begin
  Result := Length(FCommands);
end;


procedure TsgeShellCommands.SetCommand(Index: Integer; Cmd: TsgeShellCommand);
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(Err_sgeShellCommands + Err_Separator + Err_sgeShellCommands_IndexOutOfBounds + Err_Separator + IntToStr(Index));

  FCommands[Index] := Cmd;
end;


function TsgeShellCommands.GetCommand(Index: Integer): TsgeShellCommand;
var
  c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(Err_sgeShellCommands + Err_Separator + Err_sgeShellCommands_IndexOutOfBounds + Err_Separator + IntToStr(Index));

  Result := FCommands[Index];
end;


destructor TsgeShellCommands.Destroy;
begin
  Clear;
end;


procedure TsgeShellCommands.Sort;
var
  i, j, ci, cj: Integer;
  cm: TsgeShellCommand;
begin
  ci := GetCount - 1;
  cj := ci - 1;
  for i := 0 to ci do
    for j := 0 to cj do
      if FCommands[j].Name > FCommands[j + 1].Name then
        begin
        cm := FCommands[j];
        FCommands[j] := FCommands[j + 1];
        FCommands[j + 1] := cm;
        end;
end;


function TsgeShellCommands.IndexOf(Name: ShortString): Integer;
var
  i, c: Integer;
begin
  Result := -1;
  Name := LowerCase(Name);
  c := GetCount - 1;
  for i := 0 to c do
    if Name = LowerCase(FCommands[i].Name) then
      begin
      Result := i;
      Break;
      end;
end;


procedure TsgeShellCommands.Clear;
begin
  SetLength(FCommands, 0);
end;


procedure TsgeShellCommands.Add(Cmd: TsgeShellCommand);
var
  Idx: Integer;
begin
  //Проверить на существование
  Idx := IndexOf(Cmd.Name);
  if Idx <> -1 then
    raise EsgeException.Create(Err_sgeShellCommands + Err_Separator + Err_sgeShellCommands_CommandExist + Err_Separator + Cmd.Name);

  //Добавить
  Idx := GetCount;
  SetLength(FCommands, Idx + 1);
  FCommands[Idx] := Cmd;
end;


procedure TsgeShellCommands.Add(Group, Name: ShortString; Adr: TsgeShellCommandProc; MinPrm: Byte);
var
  cmd: TsgeShellCommand;
begin
  cmd.Group := Group;
  cmd.Name := Name;
  cmd.Addr := Adr;
  cmd.MinParams := MinPrm;

  Add(cmd);
end;


procedure TsgeShellCommands.Insert(Index: Integer; Cmd: TsgeShellCommand);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(Err_sgeShellCommands + Err_Separator + Err_sgeShellCommands_IndexOutOfBounds + Err_Separator + IntToStr(Index));

  SetLength(FCommands, c + 1);
  for i := c downto Index + 1 do
    FCommands[i] := FCommands[i - 1];

  FCommands[Index] := Cmd;
end;


procedure TsgeShellCommands.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(Err_sgeShellCommands + Err_Separator + Err_sgeShellCommands_IndexOutOfBounds + Err_Separator + IntToStr(Index));

  for i := Index to c - 1 do
    FCommands[i] := FCommands[i + 1];

  SetLength(FCommands, c);
end;


procedure TsgeShellCommands.Delete(Name: ShortString);
begin
  Delete(IndexOf(Name));
end;


procedure TsgeShellCommands.DeleteByGroup(Group: ShortString);
var
  i: Integer;
begin
  Group := LowerCase(Group);
  i := 0;
  while i < GetCount do
    begin
    if Group = LowerCase(FCommands[i].Group) then
      begin
      Delete(i);
      Dec(i);
      end;
    Inc(i);
    end;
end;



end.

