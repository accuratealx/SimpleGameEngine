{
Пакет             Simple Game Engine 1
Файл              sgeFileStream.pas
Версия            1.1
Создан            15.05.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс доступа к набору байт в памяти
}

unit sgeMemoryStream;

{$mode objfpc}{$H+}{$Warnings Off}{$Hints Off}

interface



type
  TsgeMemoryStream = class
  private
    FData: Pointer;
    FSize: Int64;

    procedure SetSize(ASize: Int64);
  public
    destructor Destroy; override;

    procedure Clear;
    procedure Write(const Buffer; Offset: Int64; Size: Int64);
    procedure Read(out Buffer; Offset: Int64; Size: Int64);
    procedure FromString(Str: String);
    function  ToString: String; override;
    procedure SaveToFile(FileName: String);
    procedure LoadFromFile(FileName: String);

    property Data: Pointer read FData;
    property Size: Int64 read FSize write SetSize;
  end;





implementation

uses
  sgeConst, sgeTypes, sgeFile,
  SysUtils;


const
  _UNITNAME = 'sgeMemoryStream';



procedure TsgeMemoryStream.SetSize(ASize: Int64);
begin
  FSize := ASize;
  FData := ReAllocMem(FData, FSize);
end;


destructor TsgeMemoryStream.Destroy;
begin
  Clear;
end;


procedure TsgeMemoryStream.Clear;
begin
  Freemem(FData, FSize);
  FSize := 0;
  FData := nil;
end;


procedure TsgeMemoryStream.Write(const Buffer; Offset: Int64; Size: Int64);
var
  Sz: Int64;
begin
  if Size = 0 then Exit;

  //Проверить длину памяти что бы влез буфер
  try
    Sz := Offset + Size;
    if Sz > FSize then
      begin
      FData := ReAllocMem(FData, Sz);
      FSize := Sz;
      end;
  except
    raise EsgeException.Create(_UNITNAME, Err_CantReallocMemory, IntToStr(Sz));
  end;

  //Записать буфер
  Move(Buffer, (FData + Offset)^, Size);
end;


procedure TsgeMemoryStream.Read(out Buffer; Offset: Int64; Size: Int64);
var
  sz: Int64;
begin
  if Size = 0 then Exit;

  //Проверить возможность скопировать
  sz := Offset + Size;
  if sz > FSize then
    raise EsgeException.Create(_UNITNAME, Err_IndexOutsideTheData, IntToStr(Sz));

  //Скопировать данные
  Move((FData + Offset)^, Buffer, Size);
end;


procedure TsgeMemoryStream.FromString(Str: String);
var
  Sz: Int64;
begin
  Sz := Length(Str);                //Узнать длину
  FData := ReAllocMem(FData, Sz);   //Подготовить память
  Move(Str[1], FData^, Sz);         //Скопировать данные
  FSize := Sz;                      //Запомнить размер
end;


function TsgeMemoryStream.ToString: String;
begin
  Result := '';
  if FSize = 0 then Exit;

  SetLength(Result, FSize);
  Read(Result[1], 0, FSize);
end;


procedure TsgeMemoryStream.SaveToFile(FileName: String);
var
  F: TsgeFile;
begin
  try

    try
      F := TsgeFile.Create(FileName, fmWrite);
      F.Size := 0;
      F.Write(Data^, FSize);
      F.Flush;
    except
      on E: EsgeException do
        EsgeException.Create(_UNITNAME, Err_FileWriteError, FileName, E.Message);
    end;

  finally
    F.Free;
  end;
end;


procedure TsgeMemoryStream.LoadFromFile(FileName: String);
var
  F: TsgeFile;
begin
  //Проверить на существование файла
  if not FileExists(FileName) then
    raise EsgeException.Create(_UNITNAME, Err_FileNotFound, FileName);

  //Загрузка из файла
  try
    try
      F := TsgeFile.Create(FileName, fmRead);
      F.Seek(0, foBegin);
      FSize := F.Size;                          //Запомнить размер
      FData := ReAllocMem(FData, F.Size);       //Выделить память на куче
      F.Read(FData^, FSize);                    //Прочитать из файла
    except
      on E: EsgeException do
        EsgeException.Create(_UNITNAME, Err_FileReadError, FileName, E.Message);
    end;


  finally
    F.Free;
  end;
end;



end.

