{
Пакет             Simple Game Engine 1
Файл              sgeFile.pas
Версия            1.3
Создан            15.05.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс доступа к файлу
}

unit sgeFile;

{$mode objfpc}{$H+}

interface


type
  //Начало отступа
  TsgeFileOrigin = (foBegin, foCurrent, foEnd);


  //Режим открытия файла
  TsgeFileMode = (fmRead, fmWrite, fmReadWrite);


  TsgeFile = class
  private
    FHandle: THandle;
    FSize: Int64;
    FMode: TsgeFileMode;
    FPosition: Int64;
    FFileName: String;

    procedure OpenFile(FileName: String);
    procedure CloseFile;

    procedure SetFileName(AFileName: String);
    procedure SetSize(ASize: Int64);
    procedure SetMode(AMode: TsgeFileMode);
  public
    constructor Create(FileName: String; Mode: TsgeFileMode);
    destructor  Destroy; override;

    procedure Flush;
    procedure SeekEnd;
    procedure Seek(Offset: Int64; Origin: TsgeFileOrigin = foBegin);
    procedure Write(const Buffer; Size: Int64);
    procedure Read(out Buffer; Size: Int64);

    function  AsString: String;

    property Handle: THandle read FHandle;
    property FileName: String read FFileName write SetFileName;
    property Size: Int64 read FSize write SetSize;
    property Mode: TsgeFileMode read FMode write SetMode;
    property Position: Int64 read FPosition;
  end;



implementation


uses
  sgeConst, sgeTypes,
  SysUtils, FileUtil, Windows;


const
  _UNITNAME = 'sgeFile';



procedure TsgeFile.OpenFile(FileName: String);
const
  MCreate = 0;
  MOpen = 1;
var
  Method: Byte;
  s: String;
  H: THandle;
  Sz: Int64;
  Md: Integer;
begin
  //Определить как открывать файл
  if FileExists(FileName) then Method := MOpen else Method := MCreate;

  //Определить режим доступа
  Md := Ord(FMode);

  //Подключиться к файлу
  H := 0;
  case Method of
    MOpen   : H := FileOpen(FileName,  Md);
    MCreate : H := FileCreate(FileName, Md);
  end;

  //Проверить
  s := '';
  if H = feInvalidHandle then
    begin
    case Method of
      MCreate: s := Err_CantCreateFile;
      MOpen  : s := Err_CantOpenFile;
    end;

    raise EsgeException.Create(_UNITNAME, s, FileName);
    end;

  //Прочитать размер
  Sz := FileUtil.FileSize(FileName);

  //Применить параметры
  CloseFile;                //Закрыть текущий файл
  FPosition := 0;
  FFileName := FileName;
  FHandle := H;
  FSize := Sz;
end;


procedure TsgeFile.CloseFile;
begin
  FileClose(FHandle);
  FHandle := feInvalidHandle;
  FPosition := 0;
  FSize := 0;
end;


procedure TsgeFile.SetFileName(AFileName: String);
begin
  if FFileName = AFileName then Exit;

  OpenFile(AFileName);
end;


procedure TsgeFile.SetSize(ASize: Int64);
begin
  if FHandle = feInvalidHandle then Exit;
  if FSize = ASize then Exit;

  if not FileTruncate(FHandle, ASize) then
    raise EsgeException.Create(_UNITNAME, Err_CantSetFileSize, IntToStr(Size));

  //Применить параметры
  FSize := ASize;
  FPosition := ASize;
end;


procedure TsgeFile.SetMode(AMode: TsgeFileMode);
begin
  if FMode = AMode then Exit;

  FMode := AMode;
  CloseFile;
  OpenFile(FFileName);
end;


constructor TsgeFile.Create(FileName: String; Mode: TsgeFileMode);
begin
  FHandle := feInvalidHandle;
  FMode := Mode;

  OpenFile(FileName);
end;


destructor TsgeFile.Destroy;
begin
  CloseFile;
end;


procedure TsgeFile.Flush;
begin
  if FHandle = feInvalidHandle then Exit;

  if not FileFlush(FHandle) then
    raise EsgeException.Create(_UNITNAME, Err_CantFlushFile, FileName);
end;


procedure TsgeFile.SeekEnd;
begin
  Seek(0, foEnd);
end;


procedure TsgeFile.Seek(Offset: Int64; Origin: TsgeFileOrigin);
begin
  if FHandle = feInvalidHandle then Exit;

  FPosition := FileSeek(FHandle, Offset, Ord(Origin));
end;


procedure TsgeFile.Write(const Buffer; Size: Int64);
begin
  if FHandle = feInvalidHandle then Exit;

  if FileWrite(FHandle, Buffer, Size) = feInvalidHandle then
    raise EsgeException.Create(_UNITNAME, Err_CantWriteBuffer, FileName);
end;


procedure TsgeFile.Read(out Buffer; Size: Int64);
begin
  if FHandle = feInvalidHandle then Exit;

  if FileRead(FHandle, Buffer, Size) = feInvalidHandle then
    raise EsgeException.Create(_UNITNAME, Err_CantReadBuffer, FileName);
end;


function TsgeFile.AsString: String;
begin
  Result := '';
  if FSize = 0 then Exit;

  SetLength(Result, FSize);
  Seek(0, foBegin);
  Read(Result[1], FSize);
end;



end.

