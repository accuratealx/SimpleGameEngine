{
Пакет             Simple Game Engine 1
Файл              sgeGraphicSprite.pas
Версия            1.6
Создан            11.04.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Спрайт OpenGL
                  форматы: .bmp, .jpeg, .gif, .emf, .wmf, .tif, .png, .ico
}

unit sgeGraphicSprite;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes,
  dglOpenGL, GDIPAPI, Windows;


type
  //Фильтрация текстуры (Без сглаживания, Интерполяция)
  TsgeGraphicSpriteFilter = (gsfNearest, gsfLinear);


  TsgeGraphicSprite = class
  private
    FGLHandle: GLuint;      //Номер OpenGL
    FGLTileWidth: Single;   //Ширина одной плитки в координатах OpenGL
    FGLTileHeight: Single;  //Высота одной плитки в координатах OpenGL
    FGLPixelWidth: Single;  //Ширина одного пикселя в координатах OpenGL
    FGLPixelHeight: Single; //Высота одного пикселя в координатах OpenGL
    FFileName: String;      //Имя файла
    FWidth: Integer;        //Ширина спрайта в пикселях
    FHeight: Integer;       //Высота спрайта в пикселях
    FTileCols: Word;        //Плиток по X
    FTileRows: Word;        //Плиток по Y
    FTileWidth: Word;       //Ширина одной плитки в пикселях
    FTileHeight: Word;      //Высота одной плитки в пикселях

    procedure SetMagFilter(AFilter: TsgeGraphicSpriteFilter);
    function  GetMagFilter: TsgeGraphicSpriteFilter;
    procedure SetMinFilter(AFilter: TsgeGraphicSpriteFilter);
    function  GetMinFilter: TsgeGraphicSpriteFilter;
    procedure SetTileCols(ACols: Word);
    procedure SetTileRows(ARows: Word);
    procedure CalcTiles;

    procedure LoadFromGPBitmap(Image: GpBitmap);
  public
    constructor Create(FileName: String; TileCols: Word = 1; TileRows: Word = 1; MagFilter: TsgeGraphicSpriteFilter = gsfNearest; MinFilter: TsgeGraphicSpriteFilter = gsfNearest);
    constructor CreateChessBoard(Width: Integer; Height: Integer; CellSize: Integer);
    destructor  Destroy; override;

    procedure LoadFromFile(FileName: String);
    procedure LoadChessBoard(Width: Integer; Height: Integer; CellSize: Integer);
    procedure Reload;

    property GLHandle: GLuint read FGLHandle;
    property GLTileWidth: Single read FGLTileWidth;
    property GLTileHeight: Single read FGLTileHeight;
    property GLPixelWidth: Single read FGLPixelWidth;
    property GLPixelHeight: Single read FGLPixelHeight;
    property FileName: String read FFileName write FFileName;
    property MagFilter: TsgeGraphicSpriteFilter read GetMagFilter write SetMagFilter;
    property MinFilter: TsgeGraphicSpriteFilter read GetMagFilter write SetMagFilter;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property TileCols: Word read FTileCols write SetTileCols;
    property TileRows: Word read FTileRows write SetTileRows;
    property TileWidth: Word read FTileWidth;
    property TileHeight: Word read FTileHeight;
  end;



implementation


procedure TsgeGraphicSprite.SetMagFilter(AFilter: TsgeGraphicSpriteFilter);
var
  Filter: Integer;
begin
  case AFilter of
    gsfNearest: Filter := GL_NEAREST;
    gsfLinear : Filter := GL_LINEAR;
  end;

  glBindTexture(GL_TEXTURE_2D, FGLHandle);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, Filter);
  glBindTexture(GL_TEXTURE_2D, 0);
end;


function TsgeGraphicSprite.GetMagFilter: TsgeGraphicSpriteFilter;
var
  Filter: Integer;
begin
  glBindTexture(GL_TEXTURE_2D, FGLHandle);
  glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, @Filter);
  glBindTexture(GL_TEXTURE_2D, 0);

  case Filter of
    GL_NEAREST: Result := gsfNearest;
    GL_LINEAR : Result := gsfLinear;
  end;
end;


procedure TsgeGraphicSprite.SetMinFilter(AFilter: TsgeGraphicSpriteFilter);
var
  Filter: Integer;
begin
  case AFilter of
    gsfNearest: Filter := GL_NEAREST;
    gsfLinear : Filter := GL_LINEAR;
  end;

  glBindTexture(GL_TEXTURE_2D, FGLHandle);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, Filter);
  glBindTexture(GL_TEXTURE_2D, 0);
end;


function TsgeGraphicSprite.GetMinFilter: TsgeGraphicSpriteFilter;
var
  Filter: Integer;
begin
  glBindTexture(GL_TEXTURE_2D, FGLHandle);
  glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, @Filter);
  glBindTexture(GL_TEXTURE_2D, 0);

  case Filter of
    GL_NEAREST: Result := gsfNearest;
    GL_LINEAR : Result := gsfLinear;
  end;
end;


procedure TsgeGraphicSprite.SetTileCols(ACols: Word);
begin
  if ACols < 1 then ACols := 1;
  FTileCols := ACols;
  CalcTiles;
end;


procedure TsgeGraphicSprite.SetTileRows(ARows: Word);
begin
  if ARows < 1 then ARows := 1;
  FTileRows := ARows;
  CalcTiles;
end;


procedure TsgeGraphicSprite.CalcTiles;
begin
  //Размеры плитки в координатах OpenGL
  FGLTileWidth := 1 / FTileCols;
  FGLTileHeight := 1 / FTileRows;

  //Размеры одной плитки
  FTileWidth := FWidth div FTileCols;
  FTileHeight := FHeight div FTileRows;

  //Размеры одного пикселя в координатах OpenGL
  FGLPixelWidth := 1 / FWidth;
  FGLPixelHeight := 1 / FHeight;
end;


procedure TsgeGraphicSprite.LoadFromGPBitmap(Image: GpBitmap);
var
  W, H, i, Size, BytesPerLine, IdxBmp, IdxData: Cardinal;
  BmpData: TBitmapData;
  DATA: array of Byte;
  Rct: TGPRect;
begin
  //Проверить наличие изображения
  if Image = nil then
    raise EsgeException.Create(Err_sgeGraphicSprite + Err_Separator + Err_sgeGraphicSprite_ImageIsEmpty);

  //Прочитать ширину
  W := 0;
  if GdipGetImageWidth(Image, W) <> Ok then
    raise EsgeException.Create(Err_sgeGraphicSprite + Err_Separator + Err_sgeGraphicSprite_CantGetWidth + Err_Separator + FileName);

  //Прочитать высоту
  H := 0;
  if GdipGetImageHeight(Image, H) <> Ok then
    raise EsgeException.Create(Err_sgeGraphicSprite + Err_Separator + Err_sgeGraphicSprite_CantGetHeight + Err_Separator + FileName);

  //Заблокировать память
  Rct := MakeRect(0, 0, W, H);
  if GdipBitmapLockBits(Image, @Rct, ImageLockModeRead, PixelFormat32bppARGB, @BmpData) <> Ok then
    raise EsgeException.Create(Err_sgeGraphicSprite + Err_Separator + Err_sgeGraphicSprite_CantAccessMemory + Err_Separator + FileName);

  //Подготовка буфера
  BytesPerLine := W * 4;    //Байтов в строке
  Size := BytesPerLine * H; //Всего данных
  SetLength(DATA, Size);    //Выделить память

  //Переворачивание рисунка
  for i := 0 to H - 1 do
    begin
    IdxBmp := i * BytesPerLine;                                           //Смещение линии GPBitmap
    IdxData := Size - (i * BytesPerLine) - BytesPerLine;                  //Смещение буфера для OpenGL
    Move(Pointer(BmpData.Scan0 + IdxBmp)^, DATA[IdxData], BytesPerLine);  //Копирование из GPBitmap в буфер
    end;

  //Разблокировать память
  GdipBitmapUnlockBits(Image, @BmpData);

  //OpenGL
  glBindTexture(GL_TEXTURE_2D, FGLHandle);                                                //Сделать текстуру активной
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, W, H, 0, GL_BGRA, GL_UNSIGNED_BYTE, @DATA[0]);  //Залить данные
  glBindTexture(GL_TEXTURE_2D, 0);                                                        //Отменить выбор текстуры

  //Почистить память
  SetLength(DATA, 0);

  //Запомнить размеры
  FWidth := W;
  FHeight := H;

  //Пересчитать переменные
  CalcTiles;
end;



constructor TsgeGraphicSprite.Create(FileName: String; TileCols: Word; TileRows: Word; MagFilter: TsgeGraphicSpriteFilter; MinFilter: TsgeGraphicSpriteFilter);
begin
  //Если вдруг особо одарённые будут неправильно использовать
  if (not Assigned(glGenTextures)) then
    raise EsgeException.Create(Err_sgeGraphicSprite + Err_Separator + Err_sgeGraphicSprite_GraphicNotInitialized);

  //Обработать информацию о плитках
  if TileCols < 1 then TileCols := 1;                                     //Поправить количество плиток
  if TileRows < 1 then TileRows := 1;
  FTileCols := TileCols;                                                  //Запомнить количество плиток
  FTileRows := TileRows;

  //OpenGL
  glGenTextures(1, @FGLHandle);                                           //Выделить память для текстуры
  glBindTexture(GL_TEXTURE_2D, FGLHandle);                                //Сделать текстуру активной
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);    //Привязывать края к границе полигона
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);    //Привязывать края к границе полигона
  glBindTexture(GL_TEXTURE_2D, 0);                                        //Отменить выбор текстуры

  //Попробывать загрузить данные из файла
  LoadFromFile(FileName);

  //Запомнить имя файла
  FFileName := FileName;

  //Применить фильтры
  SetMagFilter(MagFilter);                                                //Изменить фильтр увеличения
  SetMinFilter(MinFilter);                                                //Изменить фильтр уменьшения
end;


constructor TsgeGraphicSprite.CreateChessBoard(Width: Integer; Height: Integer; CellSize: Integer);
begin
  //Если вдруг особо одарённые будут неправильно использовать
  if (not Assigned(glGenTextures)) then
    raise EsgeException.Create(Err_sgeGraphicSprite + Err_Separator + Err_sgeGraphicSprite_GraphicNotInitialized);

  //Обработать информацию о плитках
  FTileCols := 1;                                                         //Запомнить количество плиток
  FTileRows := 1;

  //OpenGL
  glGenTextures(1, @FGLHandle);                                           //Выделить память для текстуры
  glBindTexture(GL_TEXTURE_2D, FGLHandle);                                //Сделать текстуру активной
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);  //Привязывать края к границе полигона
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);  //Привязывать края к границе полигона
  glBindTexture(GL_TEXTURE_2D, 0);                                        //Отменить выбор текстуры

  //Попробывать создать шахматную доску
  LoadChessBoard(Width, Height, CellSize);

  //Фильтры
  SetMagFilter(gsfNearest);                                               //Изменить фильтр увеличения
  SetMinFilter(gsfNearest);                                               //Изменить фильтр уменьшения
end;


destructor TsgeGraphicSprite.Destroy;
begin
  if FGLHandle = 0 then Exit;
  glDeleteTextures(1, @FGLHandle);
end;


procedure TsgeGraphicSprite.LoadFromFile(FileName: String);
var
  Bmp: GpBitmap;
begin
  //Попробывать загрузить файл с диска
  if GdipCreateBitmapFromFile(PWideChar(WideString(FileName)), Bmp) <> Ok then
    raise EsgeException.Create(Err_sgeGraphicSprite + Err_Separator + Err_sgeGraphicSprite_CantLoadFromFile + Err_Separator + FileName);

  LoadFromGPBitmap(Bmp);  //Залить в OpenGL
  GdipDisposeImage(Bmp);  //Освободить память
end;


procedure TsgeGraphicSprite.LoadChessBoard(Width: Integer; Height: Integer; CellSize: Integer);
var
  Bmp: GpBitmap;
  Data: array of Byte;
  Size, X, Y, i, c, Idx: Integer;
  a: Byte;
begin
  //Определить размер
  Size := Width * Height * 4;

  //Выделить память под буфер
  SetLength(Data, Size);

  //Подготовить массив точек с прозрачностью
  c := (Size div 4) - 1;                      //Номер последнего пиксела
  for i := 0 to c do
    begin
    X := i div Width div CellSize;            //Номер столбца с учётом ширины клетки
    Y := (i mod Width) div CellSize;          //Номер строки с учётом ширины клетки

    if odd(X + Y) then a := 255 else a := 0;  //Определить цвет для долей
    Idx := i * 4;                             //Индекс начала RGBQuad

    Data[Idx + 0] := a;                       //Blue
    Data[Idx + 1] := a;                       //Green
    Data[Idx + 2] := a;                       //Red
    Data[Idx + 3] := 255;                     //Alpha
    end;

  //Создать GPBitmap из набора данных 32 бита на точку
  if GdipCreateBitmapFromScan0(Width, Height, Width * 4, PixelFormat32bppPARGB, @Data[0], Bmp) <> Ok then
    begin
    SetLength(Data, 0);
    raise EsgeException.Create(Err_sgeGraphicSprite + Err_Separator + Err_sgeGraphicSprite_CantLoadFromScanLine + Err_Separator + FileName);
    end;

  //Почистить память
  SetLength(Data, 0);

  //Залить в OpenGL
  LoadFromGPBitmap(Bmp);

  //Удалить битмап
  GdipDisposeImage(Bmp);
end;


procedure TsgeGraphicSprite.Reload;
begin
  LoadFromFile(FileName); //Попробывать загрузить данные из файла
end;










/////////////////////////////////////////////////////////////////////////
var
  StartupInput: TGDIPlusStartupInput;
  gdiplusToken: Cardinal;

initialization
begin
  //Заполнение полей рекорда инициализации GDI+
  StartupInput.DebugEventCallback := nil;
  StartupInput.SuppressBackgroundThread := False;
  StartupInput.SuppressExternalCodecs := False;
  StartupInput.GdiplusVersion := 1;

  //Запуск GDI+
  if GdiplusStartup(gdiplusToken, @StartupInput, nil) <> Ok then
    begin
    MessageBox(0, 'Cant initialize GDI+', 'Fatal error', MB_ICONERROR or MB_OK);
    halt;
    end;
end;


finalization
begin
  //Удалить GDI+
  GdiplusShutdown(gdiplusToken);
end;


end.


