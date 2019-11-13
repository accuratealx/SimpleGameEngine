{
Пакет             Simple Game Engine 1
Файл              sgeGraphicFont.pas
Версия            1.7
Создан            04.04.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс битового шрифта для вывода посредством OpenGL.
                  Данный механизм имеет один недостаток - это вывод
                  только в кодировке CP1251 и не более 255 символов.
                  Для перевода в Utf8 нужен другой механизм.

                  ВНИМАНИЕ! Только векторные шрифты будут точной высоты,
                  при использовании растровых шрифтов, выбираеться первый
                  подходящий по размеру, но не больше чем указанная высота.
                  Если в конструктор передать шрифт System, 14, то реальная
                  высота быдет выбрана 16, как наиболее близкая. А вообще
                  никаких растровых шрифтов.
}

unit sgeGraphicFont;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes, Windows, dglOpenGL;


type
  //Атрибуты шрифта (Жирный, Наклонный, Подчеркнутый, Перечёркнутый)
  TsgeGraphicFontAttrib = set of (gfaBold, gfaItalic, gfaUnderline, gfaStrikeOut);


  TsgeGraphicFont = class
  private
    FGLHandle: GLuint;
    FHeight: Word;
    FName: String;
    FAttrib: TsgeGraphicFontAttrib;

    FDC: HDC;
    FFont: HFONT;

    procedure BuildFont;
    procedure SetName(AName: String);
    procedure SetHeight(AHeight: Word);
    procedure SetAttrib(AAttrib: TsgeGraphicFontAttrib);
  public
    constructor Create(Name: String; Height: Word; Attrib: TsgeGraphicFontAttrib = []);
    destructor  Destroy; override;

    function GetStringWidth(Str: String): Integer;
    function GetStringHeight(Str: String): Integer;

    property GLHandle: GLuint read FGLHandle;
    property Height: Word read FHeight write SetHeight;
    property Name: String read FName write SetName;
    property Attrib: TsgeGraphicFontAttrib read FAttrib write SetAttrib;
  end;



implementation


const
  _UNITNAME = 'sgeGraphicFont';



procedure TsgeGraphicFont.BuildFont;
var
  Fnt: HFONT;
  LogFont: TLOGFONT;
begin
  //Структура логического шрифта
  LogFont.lfHeight := -FHeight;                   //Высота
  LogFont.lfWidth := 0;                           //Автоподбор ширины
  LogFont.lfEscapement := 0;                      //Угол в десятых долях между вектором спуска и осью x устройства
  LogFont.lfOrientation := 0;                     //Угол в градусах
  if (gfaBold in FAttrib) then LogFont.lfWeight := FW_BOLD else LogFont.lfWeight := FW_NORMAL; //Толщина шрифта
  if (gfaItalic in FAttrib) then LogFont.lfItalic := 1 else LogFont.lfItalic := 0;             //Наклон
  if (gfaUnderline in FAttrib) then LogFont.lfUnderline := 1 else LogFont.lfUnderline := 0;    //Подчёркивание
  if (gfaStrikeOut in FAttrib) then LogFont.lfStrikeOut := 1 else LogFont.lfStrikeOut := 0;    //Перечёркивание
  LogFont.lfCharSet := DEFAULT_CHARSET;           //Набор символов
  LogFont.lfOutPrecision := OUT_TT_PRECIS;        //Точность вывода
  LogFont.lfClipPrecision := CLIP_DEFAULT_PRECIS; //Точность отсечения
  LogFont.lfQuality := DRAFT_QUALITY;             //Качество вывода (ANTIALIASED_QUALITY)
  LogFont.lfPitchAndFamily := DEFAULT_PITCH;      //Настройки вида шрифта, если не найдено точное совпадение
  LogFont.lfFaceName := PAnsiChar(FName);         //Имя шрифта

  //Создать шрифт и проверить
  Fnt := CreateFontIndirect(LogFont);
  if Fnt = 0 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantCreateWindowsFont, FName));

  //выбрать шрифт
  SelectObject(FDC, Fnt);

  //Создать дисплейные списки и проверить
  if wglUseFontBitmaps(FDc, 0, 256, FGLHandle) = False then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantCreateGLFont, FName));

  //Почистить память
  DeleteObject(FFont);

  //Запомнить новый шрифт
  FFont := Fnt;
end;


procedure TsgeGraphicFont.SetName(AName: String);
begin
  if FName = AName then Exit;
  FName := AName;
  BuildFont;
end;


procedure TsgeGraphicFont.SetHeight(AHeight: Word);
begin
  if AHeight < 1 then AHeight := 1;
  if FHeight = AHeight then Exit;
  FHeight := AHeight;
  BuildFont;
end;


procedure TsgeGraphicFont.SetAttrib(AAttrib: TsgeGraphicFontAttrib);
begin
  if FAttrib = AAttrib then Exit;
  FAttrib := AAttrib;
  BuildFont;
end;


constructor TsgeGraphicFont.Create(Name: String; Height: Word; Attrib: TsgeGraphicFontAttrib);
begin
  //Если вдруг особо одарённые будут неправильно использовать
  if (not Assigned(glGenLists)) then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_GraphicNotInitialized, Name));

  if Height < 1 then Height := 1; //Поправить размер
  FHeight := Height;              //Запомнить высоту шрифта
  FName := Name;                  //Запомнить имя шрифта
  FAttrib := Attrib;              //Атрибуты шрифта

  //Выделить 256 дисплейных списков и проверить
  FGLHandle := glGenLists(256);
  if FGLHandle = 0 then
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantAllocGLMemory, Name));

  //Создать совместимый контекст в памяти
  FDC := CreateCompatibleDC(0);

  //Построить шрифт
  BuildFont;
end;


destructor TsgeGraphicFont.Destroy;
begin
  if FGLHandle = 0 then Exit;
  DeleteObject(FFont);            //Удалить логический шрифт
  DeleteDC(FDC);                  //Удалить контекс
  glDeleteLists(FGLHandle, 256);  //Удалить дисплейные списки
end;


function TsgeGraphicFont.GetStringWidth(Str: String): Integer;
var
  Sz: tagSIZE;
begin
  GetTextExtentPoint32(FDC, PChar(Str), Length(Str), Sz);
  Result := Sz.Width;
end;


function TsgeGraphicFont.GetStringHeight(Str: String): Integer;
var
  Sz: tagSIZE;
begin
  GetTextExtentPoint32(FDC, PChar(Str), Length(Str), Sz);
  Result := Sz.Height;

end;



end.

