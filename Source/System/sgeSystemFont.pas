{
Пакет             Simple Game Engine 1
Файл              sgeSystemFont.pas
Версия            1.4
Создан            05.05.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс добавления шрифта в папку Windows\Fonts на время работы программы
                  Доступные форматы: .fon, .fnt, .ttf, .ttc, .fot, .otf, .mmm, .pfb, .pfm
}

unit sgeSystemFont;

{$mode objfpc}{$H+}

interface

uses
  sgeMemoryStream;


type
  TsgeSystemFont = class
  private
    FFileName: String;
    FHandle: THandle;

    procedure DeleteFont;
  public
    procedure Reload;

    constructor Create(FileName: String);
    constructor Create(Stream: TsgeMemoryStream);
    destructor  Destroy; override;

    procedure LoadFromFile(FileName: String);
    procedure FromMemoryStream(Stream: TsgeMemoryStream);

    property FileName: String read FFileName write FFileName;
  end;


implementation

uses
  sgeConst, sgeTypes,
  Windows;


const
  _UNITNAME = 'sgeSystemFont';



//ЗЛО
function AddFontMemResourceEx(pFileView: Pointer; cjSize: DWORD; pvResrved: pointer; pNumFonts: LPDWORD): THandle; stdcall; external gdi32 name 'AddFontMemResourceEx';
function RemoveFontMemResourceEx(H: THandle): BOOL; stdcall; external gdi32 name 'RemoveFontMemResourceEx';




procedure TsgeSystemFont.DeleteFont;
begin
  RemoveFontMemResourceEx(FHandle);
  FHandle := 0;
end;


procedure TsgeSystemFont.Reload;
begin
  DeleteFont;
  LoadFromFile(FFileName);
end;


constructor TsgeSystemFont.Create(FileName: String);
begin
  FFileName := FileName;
  LoadFromFile(FFileName);
end;


constructor TsgeSystemFont.Create(Stream: TsgeMemoryStream);
begin
  FromMemoryStream(Stream);
end;


destructor TsgeSystemFont.Destroy;
begin
  DeleteFont;
end;


procedure TsgeSystemFont.LoadFromFile(FileName: String);
var
  Ms: TsgeMemoryStream;
begin
  try
    try
      Ms := TsgeMemoryStream.Create;
      Ms.LoadFromFile(FileName);
      FromMemoryStream(Ms);

    except
      on E: EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName, E.Message);
    end;

  finally
    Ms.Free;
  end;
end;


procedure TsgeSystemFont.FromMemoryStream(Stream: TsgeMemoryStream);
var
  I: Cardinal;
begin
  FHandle := AddFontMemResourceEx(Stream.Data, Stream.Size, nil, @I);
  if FHandle = 0 then
    raise EsgeException.Create(_UNITNAME, Err_CantCreateFontFromMemory);
end;




end.

