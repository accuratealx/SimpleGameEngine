{
Пакет             Simple Game Engine 1
Файл              sgeSystemFont.pas
Версия            1.1
Создан            05.05.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс добавления шрифта из файла в папку Windows\Fonts на время работы программы
                  Доступные форматы: .fon, .fnt, .ttf, .ttc, .fot, .otf, .mmm, .pfb, .pfm
}

unit sgeSystemFont;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes,
  Windows, SysUtils;



type
  TsgeSystemFont = class
  private
    FFileName: String;

    procedure LoadFont(FileName: String);
    procedure DeleteFont;
  public
    procedure Reload;

    constructor Create(FileName: String);
    destructor  Destroy; override;

    property FileName: String read FFileName write FFileName;
  end;


implementation


const
  _UNITNAME = 'sgeSystemFont';

  FR_PRIVATE = 16;



function AddFontResourceEx(lpszFilename: LPCTSTR; fl: DWORD; pdv: PVOID): LongInt; external gdi32 name 'AddFontResourceExA';
function RemoveFontResourceEx(lpFileName: LPCTSTR; fl: DWORD; pdv: PVOID): LongBool; external gdi32 name 'RemoveFontResourceExA';




procedure TsgeSystemFont.LoadFont(FileName: String);
begin
  if AddFontResourceEx(PChar(FileName), FR_PRIVATE, nil) = 0 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantAddFontToSystem, FileName));
end;


procedure TsgeSystemFont.DeleteFont;
begin
  RemoveFontResourceEx(PChar(FFileName), FR_PRIVATE, nil);
end;


procedure TsgeSystemFont.Reload;
begin
  DeleteFont;
  LoadFont(FFileName);
end;


constructor TsgeSystemFont.Create(FileName: String);
begin
  FFileName := FileName;
  LoadFont(FFileName);
end;


destructor TsgeSystemFont.Destroy;
begin
  DeleteFont;
end;




end.

