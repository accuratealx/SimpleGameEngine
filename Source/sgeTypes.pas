{
Пакет             Simple Game Engine 1
Файл              sgeTypes.pas
Версия            1.16
Создан            24.01.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Типы простого игрового движка плюс пару функций
}

unit sgeTypes;

{$mode objfpc}{$H+}

interface

uses
  StringArray,
  sgeConst, sgeGraphicColor,
  SysUtils;


type
  EsgeException = class(Exception);


  //Кнопки мыши
  TsgeMouseButton = (mbLeft, mbMiddle, mbRight, mbExtra1, mbExtra2);
  TsgeMouseButtons = set of TsgeMouseButton;


  //Специальные кнопки клавиатуры
  TsgeKeyboardButton = (kbLeftAlt, kbRightAlt, kbLeftCtrl, kbRightCtrl, kbLeftShift, kbRightShift,
                        kbAlt, kbCtrl, kbShift, kbCapsLock, kbNumLock, kbScrollLock, kbInsert);
  TsgeKeyboardButtons = set of TsgeKeyboardButton;


  //Режим загрузки строк из файла языка
  TsgeLoadMode = (lmReplace, lmAdd);


  TsgeGraphicPoint = record
    X: Single;
    Y: Single;
  end;


  TsgeGraphicRect = record
    X1: Single;
    Y1: Single;
    X2: Single;
    Y2: Single;
  end;


  TsgePoint = record
    X: Integer;
    Y: Integer;
  end;


  TsgeRect = record
    X1: Integer;
    Y1: Integer;
    X2: Integer;
    Y2: Integer;
  end;



function  sgeGetShellBGRect(ScreenW, ScreenH: Single; ImageW, ImageH: Single): TsgeRect;

function  sgeGetGraphicPoint(X, Y: Single): TsgeGraphicPoint;
function  sgeGetGraphicRect(X1, Y1, X2, Y2: Single): TsgeGraphicRect;
function  sgeGetPoint(X, Y: Integer): TsgePoint;
function  sgeGetRect(X1, Y1, X2, Y2: Integer): TsgeRect;
function  sgeGetUniqueFileName: String;
procedure sgeDecodeErrorString(ErrStr: String; var EName: String; var ECode: String; var EInfo: String);
function  sgeGetErrorCodeByString(ErrStr:String): Integer;

function  sgeGetOnOffFromParam(Cmd: PStringArray): Byte;
function  sgeGetRGBAFromParam(Cmd: PStringArray; StartIdx: Byte = 1): TsgeRGBA;
function  sgeGetRGBAAsStringByGraphicColor(Col: TsgeGraphicColor): String;


implementation


//Возврат размеров фоновой картинки
function sgeGetShellBGRect(ScreenW, ScreenH: Single; ImageW, ImageH: Single): TsgeRect;
var
  scrR, imgR: Single;
begin
  scrR := ScreenW / ScreenH;
  imgR := ImageW / ImageH;

  if imgR > scrR then
    begin
    Result.Y1 := 0;
    Result.Y2 := Round(ImageH);
    Result.X2 := Round(ScreenW * ImageH / ScreenH);
    Result.X1 := Round((ImageW - Result.X2) / 2);
    end
    else begin
    Result.X1 := 0;
    Result.X2 := Round(ImageW);
    Result.Y2 := Round(ScreenH * ImageW / ScreenW);
    Result.Y1 := Round((ImageH - Result.Y2) / 2);
    end;
end;


function sgeGetGraphicPoint(X, Y: Single): TsgeGraphicPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;


function sgeGetGraphicRect(X1, Y1, X2, Y2: Single): TsgeGraphicRect;
begin
  Result.X1 := X1;
  Result.Y1 := Y1;
  Result.X2 := X2;
  Result.Y2 := Y2;
end;


function sgeGetPoint(X, Y: Integer): TsgePoint;
begin
  Result.X := X;
  Result.Y := Y;
end;


function sgeGetRect(X1, Y1, X2, Y2: Integer): TsgeRect;
begin
  Result.X1 := X1;
  Result.Y1 := Y1;
  Result.X2 := X2;
  Result.Y2 := Y2;
end;


function sgeGetUniqueFileName: String;
begin
  Result := FormatDateTime('yyyy.mm.dd-hh.nn.ss', Now);
end;


procedure sgeDecodeErrorString(ErrStr: String; var EName: String; var ECode: String; var EInfo: String);
var
  sa: TStringArray;
begin
  StringArray_StringToArray(@sa, ErrStr, Err_Separator);
  EName := '';
  if StringArray_Equal(@sa, 1) then EName := sa[0];
  ECode := '0';
  if StringArray_Equal(@sa, 2) then ECode := sa[1];
  EInfo := '';
  if StringArray_Equal(@sa, 3) then EInfo := sa[2];
  StringArray_Clear(@sa);
end;


function sgeGetErrorCodeByString(ErrStr:String): Integer;
var
  sa: TStringArray;
begin
  Result := 0;
  StringArray_StringToArray(@sa, ErrStr, Err_Separator);
  if StringArray_Equal(@sa, 2) then TryStrToInt(sa[1], Result);
  StringArray_Clear(@sa);
end;


{
Результат:
  0 - Нет прараметра
  1 - Невозможно определить значение
  2 - Включено
  3 - Выключено
}
function sgeGetOnOffFromParam(Cmd: PStringArray): Byte;
var
  s: String;
begin
  Result := 0;
  if StringArray_Equal(Cmd, 2) then
    begin
    Result := 1;
    s := LowerCase(Cmd^[1]);
    if (s = 'on') or (s = 'yes') or (s = '1') or (s = 'true') or (s = 'enable') then Result := 2;
    if (s = 'off') or (s = 'no') or (s = '0') or (s = 'false') or (s = 'disable') then Result := 3;
    end;
end;


function sgeGetRGBAFromParam(Cmd: PStringArray; StartIdx: Byte = 1): TsgeRGBA;
var
  i: Integer;
begin
  Result.Red := 0;
  Result.Green := 0;
  Result.Blue := 0;
  Result.Alpha := 255;
  if StringArray_Equal(Cmd, 2) then if TryStrToInt(Cmd^[StartIdx + 0], i) then Result.Red := i;
  if StringArray_Equal(Cmd, 3) then if TryStrToInt(Cmd^[StartIdx + 1], i) then Result.Green := i;
  if StringArray_Equal(Cmd, 4) then if TryStrToInt(Cmd^[StartIdx + 2], i) then Result.Blue := i;
  if StringArray_Equal(Cmd, 5) then if TryStrToInt(Cmd^[StartIdx + 3], i) then Result.Alpha := i;
end;


function sgeGetRGBAAsStringByGraphicColor(Col: TsgeGraphicColor): String;
var
  cl: TsgeRGBA;
begin
  cl := sgeGraphicColor_ColorToRGBA(Col);
  Result := IntToStr(cl.Red) + ' ' + IntToStr(cl.Green) + ' ' + IntToStr(cl.Blue) + ' ' + IntToStr(cl.Alpha);
end;


end.

