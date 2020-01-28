{
Пакет             Simple Game Engine 1
Файл              sgeTaskList.pas
Версия            1.0
Создан            14.07.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Список пользовательских задач
}

unit sgeTaskList;

{$mode objfpc}{$H+}

interface

uses
  sgeTask;


type
  TsgeTaskList = class
  private
    FTaskList: array of TsgeTask;

    function  GetCount: Integer;
    function  GetTask(Index: Integer): TsgeTask;
    function  GetNamedTask(Name: String): TsgeTask;
  public
    destructor  Destroy; override;

    procedure Clear;
    function  IndexOf(Name: String): Integer;
    procedure Add(Task: TsgeTask);
    procedure Add(Name: String; Proc: TsgeTaskProc; Delay: Cardinal = 0; Times: Integer = -1; Enable: Boolean = True; AutoDelete: Boolean = True; StartDelay: Cardinal = 0);
    procedure Delete(Index: Integer);
    procedure Delete(Name: String);

    property Count: Integer read GetCount;
    property Task[Index: Integer]: TsgeTask read GetTask;
    property NamedTask[Name: String]: TsgeTask read GetNamedTask;
  end;


implementation

uses
  sgeConst, sgeTypes,
  SysUtils;


const
  _UNITNAME = 'sgeTaskList';



function TsgeTaskList.GetCount: Integer;
begin
  Result := Length(FTaskList);
end;


function TsgeTaskList.GetTask(Index: Integer): TsgeTask;
begin
  if (Index < 0) or (Index > GetCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FTaskList[Index];
end;


function TsgeTaskList.GetNamedTask(Name: String): TsgeTask;
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Result := FTaskList[Idx];
end;


destructor TsgeTaskList.Destroy;
begin
  Clear;
end;


procedure TsgeTaskList.Clear;
var
  i, c: Integer;
begin
  c := GetCount - 1;
  for i := 0 to c do
    FTaskList[i].Free;

  SetLength(FTaskList, 0);
end;


function TsgeTaskList.IndexOf(Name: String): Integer;
var
  i, c: Integer;
begin
  Result := -1;

  Name := lowercase(Name);
  c := GetCount - 1;
  for i := 0 to c do
    if lowercase(FTaskList[i].Name) = Name then
      begin
      Result := i;
      Break;
      end;
end;


procedure TsgeTaskList.Add(Task: TsgeTask);
var
  c: Integer;
begin
  c := GetCount;
  SetLength(FTaskList, c + 1);
  FTaskList[c] := Task;
end;


procedure TsgeTaskList.Add(Name: String; Proc: TsgeTaskProc; Delay: Cardinal; Times: Integer; Enable: Boolean; AutoDelete: Boolean; StartDelay: Cardinal);
var
  Tsk: TsgeTask;
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx <> -1 then
    raise EsgeException.Create(_UNITNAME, Err_TaskExist, Name);

  //Добавить задачу
  Tsk := TsgeTask.Create(Name, Proc, Delay, Times, Enable, AutoDelete, StartDelay);
  Add(Tsk);
end;


procedure TsgeTaskList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FTaskList[Index].Free;

  for i := Index to c - 1 do
    FTaskList[i] := FTaskList[i + 1];
  SetLength(FTaskList, c);
end;


procedure TsgeTaskList.Delete(Name: String);
var
  Idx: Integer;
begin
  Idx := IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  Delete(Idx);
end;


end.

