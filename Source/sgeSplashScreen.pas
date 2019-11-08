{
Пакет             Simple Game Engine 1
Файл              sgeSplashScreen.pas
Версия            1.1
Создан            04.04.2019
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс простой формы-заставки
}

unit sgeSplashScreen;

{$mode objfpc}{$H+}

interface


uses
  sgeTypes, sgeConst, sgeWindow,
  Windows;



type
  //Варианты загрузки фоновой картики
  TsgeLoadBitmapFrom = (lbfHinstance, lbfFile);


  TsgeSplashScreen = class
  private
    FWindow: TsgeWindow;
    FBrush: HBRUSH;
  public
    constructor Create(BmpName: String; LoadFrom: TsgeLoadBitmapFrom = lbfHinstance);
    destructor  Destroy; override;

    procedure Show;
    procedure Hide;
  end;


implementation


const
  _UNITNAME = 'sgeSplashScreen';


constructor TsgeSplashScreen.Create(BmpName: String; LoadFrom: TsgeLoadBitmapFrom);
var
  b: TBITMAP;
  Bmp: HBITMAP;
begin
  //Загрузить картинку
  case LoadFrom of
    lbfHinstance: Bmp := LoadBitmap(HINSTANCE, PChar(BmpName));
    lbfFile     : Bmp := LoadImage(0, PChar(BmpName), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION or LR_LOADFROMFILE);
  end;

  //Проверить загрузку
  if Bmp = 0 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantLoadBitmap, BmpName));

  //Узнать размеры
  if GetObject(Bmp, SizeOf(TBITMAP), @b) = 0 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantGetBitmapData, BmpName));

  //Создать узорную кисть из битмапа
  FBrush := CreatePatternBrush(Bmp);

  //Удалить лишние объекты
  DeleteObject(Bmp);

  //Создать окно
  try
    FWindow := TsgeWindow.Create('sgeSplashScreen', 'SplashScreen', 10, 10, 100, 100);
  except
    on E: EsgeException do
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantCreateWindow), E.Message));
  end;

  //Установить кисть в качестве узорной заливки окна
  SetClassLongPtr(FWindow.Handle, GCLP_HBRBACKGROUND, FBrush);

  //Настроить окно
  FWindow.StatusBarVisible := False;
  FWindow.Style := [wsTopMost];
  FWindow.ClientWidth := b.bmWidth;
  FWindow.ClientHeight := b.bmHeight;
  FWindow.Center;
end;


destructor TsgeSplashScreen.Destroy;
begin
  FWindow.Hide;
  FWindow.Free;
  DeleteObject(FBrush);
end;


procedure TsgeSplashScreen.Show;
begin
  FWindow.Show;
end;


procedure TsgeSplashScreen.Hide;
begin
  FWindow.Hide;
end;


end.

