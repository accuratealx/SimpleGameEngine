{
Пакет             Simple Game Engine 1
Файл              sgeFileSystemPackFileList.pas
Версия            1.1
Создан            28.05.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Список файлов в подключённых архивах.
}

unit sgeFileSystemPackFileList;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes, sgePackFileReader;


type
  TsgeFileSystemPackFile = record
    Pack: TsgePackFileReader;           //Ссылка на архив
    Index: Cardinal;                    //Номер блока
    Name: String;                       //Имя файла
    Size: Cardinal;                     //Размер
  end;


  TsgeFileSystemPackFileList = class
  private
    FFileList: array of TsgeFileSystemPackFile;

    function GetCount: Integer;
    function GetItem(Index: Integer): TsgeFileSystemPackFile;
    function GetName(Index: Integer): String;
  public
    destructor Destroy; override;

    procedure Clear;
    procedure Add(AFile: TsgeFileSystemPackFile);
    function  IndexOf(AName: String): Integer;
    procedure Delete(Index: Integer);
    procedure Delete(Pack: TsgePackFileReader);

    property Count: Integer read GetCount;
    property Item[Index: Integer]: TsgeFileSystemPackFile read GetItem;
    property Name[Index: Integer]: String read GetName;
  end;



implementation

uses
  SysUtils, LazUTF8;


const
  _UNITNAME = 'sgeFileSystemPackFileList';



function TsgeFileSystemPackFileList.GetCount: Integer;
begin
  Result := Length(FFileList);
end;


function TsgeFileSystemPackFileList.GetItem(Index: Integer): TsgeFileSystemPackFile;
begin
  if (Index < 0) or (Index > GetCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FFileList[Index];
end;


function TsgeFileSystemPackFileList.GetName(Index: Integer): String;
begin
  if (Index < 0) or (Index > GetCount - 1) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  Result := FFileList[Index].Name;
end;


destructor TsgeFileSystemPackFileList.Destroy;
begin
  Clear;
end;


procedure TsgeFileSystemPackFileList.Clear;
begin
  SetLength(FFileList, 0);
end;


procedure TsgeFileSystemPackFileList.Add(AFile: TsgeFileSystemPackFile);
var
  c: Integer;
begin
  c := GetCount;
  SetLength(FFileList, c + 1);
  FFileList[c] := AFile;
end;


function TsgeFileSystemPackFileList.IndexOf(AName: String): Integer;
var
  i, c: Integer;
begin
  Result := -1;

  AName := UTF8LowerCase(AName);
  c := GetCount - 1;
  for i := c downto 0 do
    if AName = UTF8LowerCase(FFileList[i].Name) then
      begin
      Result := i;
      Break;
      end;
end;


procedure TsgeFileSystemPackFileList.Delete(Index: Integer);
var
  i, c: Integer;
begin
  c := GetCount - 1;
  if (Index < 0) or (Index > c) then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutOfBounds, IntToStr(Index));

  for i := Index to c - 1 do
    FFileList[i] := FFileList[i + 1];
  SetLength(FFileList, c);
end;


procedure TsgeFileSystemPackFileList.Delete(Pack: TsgePackFileReader);
var
  i: Integer;
begin
  i := -1;
  while i < GetCount - 1 do
    begin
    Inc(i);

    if FFileList[i].Pack = Pack then
      begin
      Delete(i);
      Dec(i)
      end;
    end;
end;


end.

