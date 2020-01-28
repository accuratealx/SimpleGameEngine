{
Пакет             Simple Game Engine 1
Файл              sgeGraphicSprite.pas
Версия            1.13
Создан            11.04.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Спрайт OpenGL
                  форматы: .bmp, .jpeg, .gif, .emf, .wmf, .tif, .png, .ico
}

unit sgeGraphicSprite;

{$mode objfpc}{$H+}

interface

uses
  sgeGraphicColor, sgeMemoryStream,
  dglOpenGL,
  GDIPAPI;


type
  TByteArray = array of Byte;
  PByteArray = ^TByteArray;


  //Фильтрация текстуры (Без сглаживания, Интерполяция)
  TsgeGraphicSpriteFilter = (gsfNearest, gsfLinear);


  TsgeGraphicSprite = class
  private
    FGLHandle: GLuint;                //Номер OpenGL
    FGLTileWidth: Single;             //Ширина одной плитки в координатах OpenGL
    FGLTileHeight: Single;            //Высота одной плитки в координатах OpenGL
    FGLPixelWidth: Single;            //Ширина одного пикселя в координатах OpenGL
    FGLPixelHeight: Single;           //Высота одного пикселя в координатах OpenGL
    FFileName: String;                //Имя файла
    FWidth: Integer;                  //Ширина спрайта в пикселях
    FHeight: Integer;                 //Высота спрайта в пикселях
    FTileCols: Word;                  //Плиток по X
    FTileRows: Word;                  //Плиток по Y
    FTileWidth: Word;                 //Ширина одной плитки в пикселях
    FTileHeight: Word;                //Высота одной плитки в пикселях

    procedure SetMagFilter(AFilter: TsgeGraphicSpriteFilter);
    function  GetMagFilter: TsgeGraphicSpriteFilter;
    procedure SetMinFilter(AFilter: TsgeGraphicSpriteFilter);
    function  GetMinFilter: TsgeGraphicSpriteFilter;
    procedure SetTileCols(ACols: Word);
    procedure SetTileRows(ARows: Word);
    procedure CalcTiles;
    procedure SetWidth(AWidth: Integer);
    procedure SetHeight(AHeight: Integer);

    procedure ChangeTexture(Width, Height: Integer; PData: PByteArray);
    procedure LoadFromGPBitmap(Image: GpBitmap);
  public
    constructor Create(FileName: String; TileCols: Word = 1; TileRows: Word = 1; MagFilter: TsgeGraphicSpriteFilter = gsfNearest; MinFilter: TsgeGraphicSpriteFilter = gsfNearest);
    constructor Create(Width, Height: Integer; BGColor: TsgeGraphicColor);
    constructor Create(Stream: TsgeMemoryStream; TileCols: Word = 1; TileRows: Word = 1; MagFilter: TsgeGraphicSpriteFilter = gsfNearest; MinFilter: TsgeGraphicSpriteFilter = gsfNearest);
    destructor  Destroy; override;

    procedure SetSize(AWidth, AHeight: Integer);
    procedure FillColor(Color: TsgeGraphicColor);
    procedure FillChessBoard(CellSize: Integer);
    procedure LoadFromFile(FileName: String);
    procedure LoadFromStream(Stream: TsgeMemoryStream);

    procedure Reload;

    property GLHandle: GLuint read FGLHandle;
    property GLTileWidth: Single read FGLTileWidth;
    property GLTileHeight: Single read FGLTileHeight;
    property GLPixelWidth: Single read FGLPixelWidth;
    property GLPixelHeight: Single read FGLPixelHeight;
    property FileName: String read FFileName write FFileName;
    property MagFilter: TsgeGraphicSpriteFilter read GetMagFilter write SetMagFilter;
    property MinFilter: TsgeGraphicSpriteFilter read GetMagFilter write SetMagFilter;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property TileCols: Word read FTileCols write SetTileCols;
    property TileRows: Word read FTileRows write SetTileRows;
    property TileWidth: Word read FTileWidth;
    property TileHeight: Word read FTileHeight;
  end;



implementation

uses
  sgeConst, sgeTypes,
  Windows, SysUtils, ActiveX;



const
  _UNITNAME = 'sgeGraphicSprite';



{$Warnings Off}
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
{$Warnings On}


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


procedure TsgeGraphicSprite.SetWidth(AWidth: Integer);
begin
  if AWidth < 0 then AWidth := 0;
  FWidth := AWidth;
  CalcTiles;
  ChangeTexture(FWidth, FHeight, nil);
end;


procedure TsgeGraphicSprite.SetHeight(AHeight: Integer);
begin
  if AHeight < 0 then AHeight := 0;
  FHeight := AHeight;
  CalcTiles;
  ChangeTexture(FWidth, FHeight, nil);
end;


procedure TsgeGraphicSprite.ChangeTexture(Width, Height: Integer; PData: PByteArray);
var
  Ptr: Pointer;
begin
  if PData = nil then Ptr := nil else Ptr := @PData^[0];

  //Залить данные в OpenGL
  glBindTexture(GL_TEXTURE_2D, FGLHandle);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, Width, Height, 0, GL_BGRA, GL_UNSIGNED_BYTE, Ptr);
  glBindTexture(GL_TEXTURE_2D, 0);
end;


procedure TsgeGraphicSprite.LoadFromGPBitmap(Image: GpBitmap);
var
  W, H, i, Size, BytesPerLine, IdxBmp, IdxData: Cardinal;
  BmpData: TBitmapData;
  DATA: array of Byte;
  Rct: TGPRect;
begin
  //Прочитать ширину
  W := 0;
  if GdipGetImageWidth(Image, W) <> Ok then
    raise EsgeException.Create(_UNITNAME, Err_CantGetWidth, FFileName);

  //Прочитать высоту
  H := 0;
  if GdipGetImageHeight(Image, H) <> Ok then
    raise EsgeException.Create(_UNITNAME, Err_CantGetHeight, FFileName);

  //Заблокировать память
  Rct := MakeRect(0, 0, W, H);
  if GdipBitmapLockBits(Image, @Rct, ImageLockModeRead, PixelFormat32bppARGB, @BmpData) <> Ok then
    raise EsgeException.Create(_UNITNAME, Err_CantAccessMemory, FFileName);

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
  ChangeTexture(W, H, @DATA);

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

  //Попробовать загрузить данные из файла
  try
    LoadFromFile(FileName);
  except
    glDeleteTextures(1, @FGLHandle);
    raise;
  end;

  //Запомнить имя файла
  FFileName := FileName;

  //Применить фильтры
  SetMagFilter(MagFilter);                                                //Изменить фильтр увеличения
  SetMinFilter(MinFilter);                                                //Изменить фильтр уменьшения
end;


constructor TsgeGraphicSprite.Create(Width, Height: Integer; BGColor: TsgeGraphicColor);
begin
  //Размеры
  if Width < 0 then Width := 0;
  if Height < 0 then Height := 0;
  FWidth := Width;
  FHeight := Height;

  //Обработать информацию о плитках
  FTileCols := 1;
  FTileRows := 1;

  //Пересчитать переменные
  CalcTiles;

  //OpenGL
  glGenTextures(1, @FGLHandle);                                           //Выделить память для текстуры
  glBindTexture(GL_TEXTURE_2D, FGLHandle);                                //Сделать текстуру активной
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);  //Привязывать края к границе полигона
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);  //Привязывать края к границе полигона
  glBindTexture(GL_TEXTURE_2D, 0);                                        //Отменить выбор текстуры

  //Залить цветом
  FillColor(BGColor);

  //Фильтры
  SetMagFilter(gsfNearest);                                               //Изменить фильтр увеличения
  SetMinFilter(gsfNearest);                                               //Изменить фильтр уменьшения
end;


constructor TsgeGraphicSprite.Create(Stream: TsgeMemoryStream; TileCols: Word; TileRows: Word; MagFilter: TsgeGraphicSpriteFilter; MinFilter: TsgeGraphicSpriteFilter);
begin
  //Обработать информацию о плитках
  if TileCols < 1 then TileCols := 1;
  if TileRows < 1 then TileRows := 1;
  FTileCols := TileCols;
  FTileRows := TileRows;

  //OpenGL
  glGenTextures(1, @FGLHandle);                                           //Выделить память для текстуры
  glBindTexture(GL_TEXTURE_2D, FGLHandle);                                //Сделать текстуру активной
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);    //Привязывать края к границе полигона
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);    //Привязывать края к границе полигона
  glBindTexture(GL_TEXTURE_2D, 0);                                        //Отменить выбор текстуры

  //Загрузить из памяти
  LoadFromStream(Stream);

  //Пересчитать переменные
  CalcTiles;

  //Фильтры
  SetMagFilter(MagFilter);
  SetMinFilter(MinFilter);
end;


destructor TsgeGraphicSprite.Destroy;
begin
  if FGLHandle = 0 then Exit;
  glDeleteTextures(1, @FGLHandle);
end;


procedure TsgeGraphicSprite.SetSize(AWidth, AHeight: Integer);
begin
  if AWidth < 1 then AWidth := 1;
  FWidth := AWidth;

  if AHeight < 1 then AHeight := 1;
  FHeight := AHeight;

  ChangeTexture(FWidth, FHeight, nil);
end;


procedure TsgeGraphicSprite.FillColor(Color: TsgeGraphicColor);
var
  Data: TByteArray;
  Size, i, c, Idx: Integer;
  cl: TsgeRGBA;
begin
  //Преобразовать цвет
  cl := sgeGraphicColor_ColorToRGBA(Color);

  //Определить размер
  Size := FWidth * FHeight * 4;

  //Выделить память под буфер
  SetLength(Data, Size);

  //Подготовить массив точек с прозрачностью
  c := (Size div 4) - 1;                      //Номер последнего пиксела
  for i := 0 to c do
    begin
    Idx := i * 4;                             //Индекс начала RGBQuad
    Data[Idx + 0] := cl.Blue;                 //Blue
    Data[Idx + 1] := cl.Green;                //Green
    Data[Idx + 2] := cl.Red;                  //Red
    Data[Idx + 3] := cl.Alpha;                //Alpha
    end;

  //Залить в OpenGL
  ChangeTexture(FWidth, FHeight, @Data);

  //Почистить память
  SetLength(Data, 0);
end;


procedure TsgeGraphicSprite.FillChessBoard(CellSize: Integer);
var
  Data: TByteArray;
  Size, X, Y, i, c, Idx: Integer;
  a: Byte;
begin
  //Поправить размер клетки
  if CellSize < 1 then CellSize := 1;

  //Определить размер
  Size := FWidth * FHeight * 4;

  //Выделить память под буфер
  SetLength(Data, Size);

  //Подготовить массив точек с прозрачностью
  c := (Size div 4) - 1;                      //Номер последнего пикселя
  for i := 0 to c do
    begin
    X := i div FWidth div CellSize;           //Номер столбца с учётом ширины клетки
    Y := (i mod FWidth) div CellSize;         //Номер строки с учётом ширины клетки

    if odd(X + Y) then a := 255 else a := 0;  //Определить цвет для долей
    Idx := i * 4;                             //Индекс начала RGBQuad

    Data[Idx + 0] := a;                       //Blue
    Data[Idx + 1] := a;                       //Green
    Data[Idx + 2] := a;                       //Red
    Data[Idx + 3] := 255;                     //Alpha
    end;

  //Залить в OpenGL
  ChangeTexture(FWidth, FHeight, @Data);

  //Почистить память
  SetLength(Data, 0);
end;


procedure TsgeGraphicSprite.LoadFromFile(FileName: String);
var
  Bmp: GpBitmap;
begin
  //Попробывать загрузить файл с диска
  if GdipCreateBitmapFromFile(PWideChar(WideString(FileName)), Bmp) <> Ok then
    raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName);

  LoadFromGPBitmap(Bmp);  //Залить в OpenGL
  GdipDisposeImage(Bmp);  //Освободить память
end;


procedure TsgeGraphicSprite.LoadFromStream(Stream: TsgeMemoryStream);
var
  Size: Integer;
  HBuf: HGLOBAL;
  PBuf: Pointer;
  PStream: IStream;
  Bmp: GpBitmap;
begin
  //Размер файла
  Size := Stream.Size;

  //Выделить память для данных
  HBuf := GlobalAlloc(GMEM_MOVEABLE, Size);

  //Проверить выделение памяти
  if HBuf = 0 then
    raise EsgeException.Create(_UNITNAME, Err_CantAllocMemory, IntToStr(Size));


  try
    //Заблокировать память
    PBuf := GlobalLock(HBuf);

    //Проверить на доступ к памяти
    if PBuf = nil then
      raise EsgeException.Create(_UNITNAME, Err_CantLockMemory);

    //Скопировать в буфер Stream
    CopyMemory(PBuf, Stream.Data, Size);

    //Создать IStream
    if not CreateStreamOnHGlobal(HBuf, False, PStream) = S_OK then
      raise EsgeException.Create(_UNITNAME, Err_CantCreateIStream);

    //Создать битмап
    if GdipCreateBitmapFromStream(PStream, Bmp) <> Ok then
      raise EsgeException.Create(_UNITNAME, Err_CantCreateBitmapFromIStream);

    //Загрузить из битмапа
    LoadFromGPBitmap(Bmp);

    //Освободить память
    GdipDisposeImage(Bmp);
  finally
    GlobalUnlock(HBuf);
    GlobalFree(HBuf);
    PStream := nil;
  end;
end;


procedure TsgeGraphicSprite.Reload;
begin
  LoadFromFile(FFileName);
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


