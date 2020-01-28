{
Пакет             Simple Game Engine 1
Файл              sgePackFileList.pas
Версия            1.0
Создан            28.05.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Список подключённых архивов
}

unit sgePackFileList;

{$mode objfpc}{$H+}

interface

uses
  sgePackFileReader;


type
  TsgePackFileList = class
  private
    FPackList: array of TsgePackFileReader;

    function  GetCount: Integer;
    function  GetItem(Index: Integer): TsgePackFileReader;
  public
    destructor  Destroy; override;

    procedure Clear;
    procedure Add(PackFile: TsgePackFileReader);
    procedure Delete(Index: Integer);
    procedure Delete(Name: String);               //Удалить архив по имени без полного пути
    function  IndexOf(Name: String): Integer;     //Найти индекс по имени без полного пути

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TsgePackFileReader read GetItem;
  end;




implementation

uses
  sgeConst, sgeTypes,
  SysUtils, LazUTF8;


const
  _UNITNAME = 'sgePackFileList';



function TsgePackFileList.GetCount: Integer;
begin
  Result := Length(FPackList);
end;


function TsgePackFileList.GetItem(Index: Integer): TsgePackFileReader;
begin
  if (Index < 0) or (Index > GetCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FPackList[Index];
end;


destructor TsgePackFileList.Destroy;
begin
  Clear;
end;


procedure TsgePackFileList.Clear;
var
  i: Integer;
begin
  for i := 0 to GetCount - 1 do
    FPackList[i].Free;

  SetLength(FPackList, 0);
end;


procedure TsgePackFileList.Add(PackFile: TsgePackFileReader);
var
  c: Integer;
begin
  c := GetCount;
  SetLength(FPackList, c + 1);
  FPackList[c] := PackFile;
end;


procedure TsgePackFileList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  FPackList[Index].Free;

  for i := Index to c - 1 do
    FPackList[i] := FPackList[i + 1];
  SetLength(FPackList, c);
end;


procedure TsgePackFileList.Delete(Name: String);
begin
  Delete(IndexOf(Name));
end;


function TsgePackFileList.IndexOf(Name: String): Integer;
var
  PackName: String;
  i, c: Integer;
begin
  Result := -1;

  Name := UTF8LowerCase(ExtractFileName(Name));
  c := GetCount - 1;
  for i := 0 to c do
    begin
    PackName := UTF8LowerCase(ExtractFileName(FPackList[i].FileName));
    if Name = PackName then
      begin
      Result := i;
      Break;
      end;
    end;
end;


end.

