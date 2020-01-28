{
Пакет             Simple Game Engine 1
Файл              sgeGraphicColors.pas
Версия            1.7
Создан            05.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Цвет
}

unit sgeGraphicColor;

{$mode objfpc}{$H+}

interface


type
  TsgeGraphicColor = record
    Red,
    Green,
    Blue,
    Alpha: Single;
  end;


  TsgeRGBA = record
    Red,
    Green,
    Blue,
    Alpha: Byte;
  end;



const
  //Портировано из Delphi7
  GC_Black      : TsgeGraphicColor = (Red: 0;    Green: 0;    Blue: 0;    Alpha: 1);
  GC_Maroon     : TsgeGraphicColor = (Red: 0.5;  Green: 0;    Blue: 0;    Alpha: 1);
  GC_Green      : TsgeGraphicColor = (Red: 0;    Green: 0.5;  Blue: 0;    Alpha: 1);
  GC_Olive      : TsgeGraphicColor = (Red: 0.5;  Green: 0.5;  Blue: 0;    Alpha: 1);
  GC_Navy       : TsgeGraphicColor = (Red: 0;    Green: 0;    Blue: 0.5;  Alpha: 1);
  GC_Purple     : TsgeGraphicColor = (Red: 0.5;  Green: 0;    Blue: 0.5;  Alpha: 1);
  GC_Teal       : TsgeGraphicColor = (Red: 0;    Green: 0.5;  Blue: 0.5;  Alpha: 1);
  GC_Gray       : TsgeGraphicColor = (Red: 0.5;  Green: 0.5;  Blue: 0.5;  Alpha: 1);
  GC_Silver     : TsgeGraphicColor = (Red: 0.75; Green: 0.75; Blue: 0.75; Alpha: 1);
  GC_Red        : TsgeGraphicColor = (Red: 1;    Green: 0;    Blue: 0;    Alpha: 1);
  GC_Lime       : TsgeGraphicColor = (Red: 0;    Green: 1;    Blue: 0;    Alpha: 1);
  GC_Yellow     : TsgeGraphicColor = (Red: 1;    Green: 1;    Blue: 0;    Alpha: 1);
  GC_Blue       : TsgeGraphicColor = (Red: 0;    Green: 0;    Blue: 1;    Alpha: 1);
  GC_Fuchsia    : TsgeGraphicColor = (Red: 1;    Green: 0;    Blue: 1;    Alpha: 1);
  GC_Aqua       : TsgeGraphicColor = (Red: 0;    Green: 1;    Blue: 1;    Alpha: 1);
  GC_White      : TsgeGraphicColor = (Red: 1;    Green: 1;    Blue: 1;    Alpha: 1);

  //Отсебятина
  GC_Transparent: TsgeGraphicColor = (Red: 0;    Green: 0;    Blue: 0;    Alpha: 0);
  GC_LightGray  : TsgeGraphicColor = (Red: 0.75;  Green: 0.75;  Blue: 0.75;  Alpha: 1);
  GC_DarkGray   : TsgeGraphicColor = (Red: 0.25;  Green: 0.25;  Blue: 0.25;  Alpha: 1);




function sgeGraphicColor_RGBAToColor(R, G, B, A: Byte): TsgeGraphicColor;
function sgeGraphicColor_RGBAToColor(Color: TsgeRGBA): TsgeGraphicColor;
function sgeGraphicColor_ColorToRGBA(R, G, B, A: Single): TsgeRGBA;
function sgeGraphicColor_ColorToRGBA(Color: TsgeGraphicColor): TsgeRGBA;
function sgeGraphicColor_GetColor(R, G, B, A: Single): TsgeGraphicColor;
function sgeGraphicColor_GetRGBA(R, G, B, A: Byte): TsgeRGBA;
function sgeGraphicColor_ChangeAlpha(Color: TsgeGraphicColor; Alpha: Single): TsgeGraphicColor;
function sgeGraphicColor_GetRandomColor(Alpha: Single = 1): TsgeGraphicColor;


implementation

uses
  SysUtils;


function sgeGraphicColor_RGBAToColor(R, G, B, A: Byte): TsgeGraphicColor;
begin
  Result.Red := R / 255;
  Result.Green := G / 255;
  Result.Blue := B / 255;
  Result.Alpha := A / 255;
end;


function sgeGraphicColor_RGBAToColor(Color: TsgeRGBA): TsgeGraphicColor;
begin
  Result := sgeGraphicColor_RGBAToColor(Color.Red, Color.Green, Color.Blue, Color.Alpha);
end;


function sgeGraphicColor_ColorToRGBA(R, G, B, A: Single): TsgeRGBA;
begin
  Result.Red := Round(R * 255);
  Result.Green := Round(G * 255);
  Result.Blue := Round(B * 255);
  Result.Alpha := Round(A * 255);
end;


function sgeGraphicColor_ColorToRGBA(Color: TsgeGraphicColor): TsgeRGBA;
begin
  Result := sgeGraphicColor_ColorToRGBA(Color.Red, Color.Green, Color.Blue, Color.Alpha);
end;


function sgeGraphicColor_GetColor(R, G, B, A: Single): TsgeGraphicColor;
begin
  //R
  if R < 0 then R := 0;
  if R > 1 then R := 1;
  //G
  if G < 0 then G := 0;
  if G > 1 then G := 1;
  //B
  if B < 0 then B := 0;
  if B > 1 then B := 1;
  //A
  if A < 0 then A := 0;
  if A > 1 then A := 1;

  //Result
  Result.Red := R;
  Result.Green := G;
  Result.Blue := B;
  Result.Alpha := A;
end;


function sgeGraphicColor_GetRGBA(R, G, B, A: Byte): TsgeRGBA;
begin
  Result.Red := R;
  Result.Green := G;
  Result.Blue := B;
  Result.Alpha := A;
end;


function sgeGraphicColor_ChangeAlpha(Color: TsgeGraphicColor; Alpha: Single): TsgeGraphicColor;
begin
  if Alpha < 0 then Alpha := 0;
  if Alpha > 1 then Alpha := 1;
  Result := Color;
  Result.Alpha := Alpha;
end;


function sgeGraphicColor_GetRandomColor(Alpha: Single = 1): TsgeGraphicColor;
begin
  Result.Red := Random;
  Result.Green := Random;
  Result.Blue := Random;
  Result.Alpha := Alpha;
end;



end.

