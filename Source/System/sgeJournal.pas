{
Пакет             Simple Game Engine 1
Файл              sgeJournal.pas
Версия            1.6
Создан            27.01.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс протоколирования в файл
}

unit sgeJournal;

{$mode objfpc}{$H+}

interface

uses
  sgeFile;


type
  TsgeJournal = class
  private
    FEnable: Boolean;
    FFileName: String;
    FFile: TsgeFile;

    procedure SetEnable(AEnable: Boolean);
    procedure SetFileName(AFileName: String);
    procedure CreateFileStream;
    procedure DestroyFileStream;
  public
    constructor Create(FileName: String);
    destructor  Destroy; override;

    procedure Log(Message: String);
    procedure LogBlankString(Count: Integer = 1);
    procedure LogSeparator(Liter: Char; Count: Integer = 50);
    procedure LogDetail(Message: String; Separator: String = ' ');

    property Enable: Boolean read FEnable write SetEnable;
    property FileName: String read FFileName write SetFileName;
  end;



implementation

uses
  sgeConst, sgeTypes,
  SysUtils;


const
  _UNITNAME = 'sgeJournal';



procedure TsgeJournal.SetEnable(AEnable: Boolean);
begin
  if FEnable = AEnable then Exit;

  FEnable := AEnable;
  case FEnable of
    True:
      try
        CreateFileStream;
      except
        FEnable := False;
        raise EsgeException.Create(_UNITNAME, Err_FileWriteError, FFileName);
      end;

    False:
      DestroyFileStream;
  end;
end;


procedure TsgeJournal.SetFileName(AFileName: String);
begin
  if FFileName = AFileName then Exit;
  FFileName := AFileName;

  if FEnable then
    begin
    DestroyFileStream;

    try
      CreateFileStream;
    except
      FEnable := False;
      raise EsgeException.Create(_UNITNAME, Err_FileWriteError, FFileName);
    end;

    end;
end;


procedure TsgeJournal.CreateFileStream;
begin
  ForceDirectories(ExtractFilePath(FFileName));
  FFile := TsgeFile.Create(FFileName, fmWrite);
end;


procedure TsgeJournal.DestroyFileStream;
begin
  FreeAndNil(FFile);
end;


constructor TsgeJournal.Create(FileName: String);
begin
  FFileName := FileName;
  FEnable := False;
end;


destructor TsgeJournal.Destroy;
begin
  DestroyFileStream;
end;


procedure TsgeJournal.Log(Message: String);
var
  Msg: String;
begin
  if not FEnable then Exit;

  Msg := Message + LineEnding;
  FFile.SeekEnd;
  FFile.Write(Msg[1], Length(Msg));
end;


procedure TsgeJournal.LogBlankString(Count: Integer);
var
  i: Integer;
begin
  if not FEnable then Exit;

  for i := 1 to Count do
    Log('');
end;


procedure TsgeJournal.LogSeparator(Liter: Char; Count: Integer = 50);
var
  msg: String;
begin
  if not FEnable then Exit;

  if Count < 1 then Exit;
  SetLength(msg, Count);
  FillChar(msg[1], Count, Liter);
  Log(msg);
end;


procedure TsgeJournal.LogDetail(Message: String; Separator: String);
var
  msg: String;
begin
  if not FEnable then Exit;

  msg := FormatDateTime('hh:nn:ss.zzz', Now) + Separator + Message;
  Log(msg);
end;



end.

