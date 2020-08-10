{
Пакет             Simple Game Engine 1
Файл              sgeGraphic.pas
Версия            1.24
Создан            26.02.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс графики
}

unit sgeGraphic;

{$mode objfpc}{$H+}{$Warnings Off}{$Hints Off}{$Inline On}

interface

uses
  sgeTypes, sgeMemoryStream, sgeGraphicFont, sgeGraphicSprite, sgeGraphicColor, sgeGraphicAnimation,
  Windows;


type
  //Информация о драйвере (Производитель, Название видеокарты, Версия OpenGL, Расширения, Версия шейдеров)
  TsgeGraphicInfo = (giVendor, giRenderer, giVersion, giExtensions, giShading);

  //Штриховка линий
  TsgeGraphicLineStipple = (glsSolid, glsDash, glsNarrowDash, glsWideDash, glsDot, glsDashDot, glsDashDotDot);

  //Режим вывода полигонов (Заливка, Линия, Точки)
  TsgeGraphicPolygonMode = (gpmFill, gpmLine, gpmDot);

  //Режим затенения (Последний цвет, Градиент)
  TsgeGraphicShadeModel = (gsmFlat, gsmSmooth);

  //Режимы работы (Сглаживание точек, Сглаживание линий, Сглаживание полигонов, Смешение цвета, Штриховка линий, Текстурирование)
  TsgeGraphicState = (gsPointSmooth, gsLineSmooth, gsPolygonSmooth, gsColorBlend, gsLineStipple, gsTexture, gsScissor);

  //Режим вывода спрайтов (Обычный, Классический, По центру)
  TsgeGraphicDrawMode = (gdmNormal, gdmClassic, gdmCentered);

  //Активный буфер рисования (Передний, Задний)
  TsgeGraphicRenderBuffer = (grbFront, grbBack);

  //Место для отрисовки
  TsgeGraphicRenderPlace = (grpScreen, grpSprite);

  //Запрос констант
  TsgeGraphicMetrics = (gmContextWidth, gmContextHeight, gmAliasedPointMinSize, gmAliasedPointMaxSize, gmSmoothPointMinSize,
                        gmSmoothPointMaxSize, gmSmoothPointGranularitySize, gmAliasedLineMinSize, gmAliasedLineMaxSize,
                        gmSmoothLineMinSize, gmSmoothLineMaxSize, gmSmoothLineGranularitySize);



  TsgeGraphic = class
  private
    FDC: HDC;                                               //Хэндл окна
    FGLRC: HGLRC;                                           //Контекст OpenGL
    FWidth: Integer;                                        //Ширина окна
    FHeight: Integer;                                       //Высота окна

    FRenderBuffer: TsgeGraphicRenderBuffer;                 //Активный буфер

    FRenderPlace: TsgeGraphicRenderPlace;                   //Место отрисовки
    FRenderSprite: TsgeGraphicSprite;                       //Спрайт вывода
    FFrameBuffer: Cardinal;                                 //Кадровый буфер

    function  GetInfo(Index: TsgeGraphicInfo): String;
    function  GetMetrix(Index: TsgeGraphicMetrics): Single;
    procedure SetColor(AColor: TsgeGraphicColor);
    function  GetColor: TsgeGraphicColor;
    procedure SetBGColor(Acolor: TsgeGraphicColor);
    function  GetBGColor: TsgeGraphicColor;
    procedure SetPointSize(ASize: Single);
    function  GetPointSize: Single;
    procedure SetLineWidth(AWidth: Single);
    function  GetLineWidth: Single;
    procedure SetPoligonMode(AMode: TsgeGraphicPolygonMode);
    function  GetPoligonMode: TsgeGraphicPolygonMode;
    procedure SetShadeModel(AMode: TsgeGraphicShadeModel);
    function  GetShadeModel: TsgeGraphicShadeModel;
    procedure SetState(AState: TsgeGraphicState; AEnable: Boolean);
    function  GetState(AState: TsgeGraphicState): Boolean;
    procedure SetRenderBuffer(ABuffer: TsgeGraphicRenderBuffer);
    procedure SetVerticalSync(AEnable: Boolean);
    function  GetVerticalSync: Boolean;

    procedure SetView(AWidth, AHeight: Integer);
    procedure SetRenderSprite(ASprite: TsgeGraphicSprite);
    procedure SetRenderPlace(APlace: TsgeGraphicRenderPlace);

    function  GetNormalRect(X, Y, W, H: Single; Mode: TsgeGraphicDrawMode): TsgeGraphicRect; inline;
    function  GetTransformedRect(X, Y, W, H: Single; Mode: TsgeGraphicDrawMode): TsgeGraphicRect; inline;
    function  GetTextureRect(Sprite: TsgeGraphicSprite; Xs, Ys, Ws, Hs: Single): TsgeGraphicRect; inline;
    function  GetTileRect(Sprite: TsgeGraphicSprite; Col, Row: Word): TsgeGraphicRect; inline;
    procedure ShowSprite(Sprite: TsgeGraphicSprite; Rect, sRect: TsgeGraphicRect); inline;
  public
    constructor Create(DC: HDC; Width, Height: Integer);
    destructor  Destroy; override;

    procedure ChangeViewArea(AWidth, AHeight: Integer);
    procedure Activate;
    procedure Deactivate;
    procedure Reset;
    procedure SwapBuffers;
    procedure Finish;
    procedure Flush;
    procedure EraseBG;
    procedure PushMatrix;
    procedure PopMatrix;
    procedure PushAttrib;
    procedure PopAttrib;

    procedure SetScale(X, Y: Single);
    procedure SetRotate(Angle: Single);
    procedure SetPos(X, Y: Single);
    procedure SetScissor(X, Y, W, H: Integer);

    procedure SetLineStipple(Scale: Integer; Pattern: Word);
    procedure SetLineStipple(Scale: Integer; Mode: TsgeGraphicLineStipple);

    procedure DrawPoint(X, Y: Single);

    procedure DrawLine(X1, Y1, X2, Y2: Single);

    procedure DrawTriangle(X1, Y1, X2, Y2, X3, Y3: Single);

    procedure DrawCircle(X, Y: Single; Radius: Single; Quality: Word = 16);
    procedure DrawCircle(X, Y: Single; Radius: Single; Angle, Scale: Single; Quality: Word = 16);

    procedure DrawRect(X, Y, W, H: Single; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawRect(X, Y, W, H: Single; Angle, Scale: Single; Mode: TsgeGraphicDrawMode = gdmNormal);

    procedure DrawRectGradient(X, Y, W, H: Single; Col1, Col2: TsgeGraphicColor; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawRectGradient(X, Y, W, H: Single; Col1, Col2: TsgeGraphicColor; Angle, Scale: Single; Mode: TsgeGraphicDrawMode = gdmNormal);

    procedure DrawSprite(X, Y, W, H: Single; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSprite(X, Y, W, H: Single; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSprite(X, Y: Single; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSprite(X, Y: Single; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode = gdmNormal);

    procedure DrawSpritePart(X, Y, W, H: Single; Xs, Ys, Ws, Hs: Single; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSpritePart(X, Y, W, H: Single; Xs, Ys, Ws, Hs: Single; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSpritePart(X, Y: Single; Xs, Ys, Ws, Hs: Single; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSpritePart(X, Y: Single; Xs, Ys, Ws, Hs: Single; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode = gdmNormal);

    procedure DrawSpriteTiled(X, Y, W, H: Single; Col, Row: Word; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSpriteTiled(X, Y, W, H: Single; Col, Row: Word; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSpriteTiled(X, Y: Single; Col, Row: Word; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawSpriteTiled(X, Y: Single; Col, Row: Word; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode = gdmNormal);

    procedure DrawAnimation(X, Y, W, H: Single; Animation: TsgeGraphicAnimation; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawAnimation(X, Y, W, H: Single; Animation: TsgeGraphicAnimation; Angle, Scale: Single;  Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawAnimation(X, Y: Single; Animation: TsgeGraphicAnimation; Mode: TsgeGraphicDrawMode = gdmNormal);
    procedure DrawAnimation(X, Y: Single; Animation: TsgeGraphicAnimation; Angle, Scale: Single;  Mode: TsgeGraphicDrawMode = gdmNormal);

    procedure DrawText(X, Y: Single; Font: TsgeGraphicFont; Text: String = '');

    procedure ScreenShot(Stream: TsgeMemoryStream);

    property Info[Index: TsgeGraphicInfo]: String read GetInfo;
    property Metrix[Index: TsgeGraphicMetrics]: Single read GetMetrix;
    property Color: TsgeGraphicColor read GetColor write SetColor;
    property BGColor: TsgeGraphicColor read GetBGColor write SetBGColor;
    property PointSize: Single read GetPointSize write SetPointSize;
    property LineWidth: Single read GetLineWidth write SetLineWidth;
    property PoligonMode: TsgeGraphicPolygonMode read GetPoligonMode write SetPoligonMode;
    property ShadeModel: TsgeGraphicShadeModel read GetShadeModel write SetShadeModel;
    property State[Index: TsgeGraphicState]: Boolean read GetState write SetState;
    property RenderBuffer: TsgeGraphicRenderBuffer read FRenderBuffer write SetRenderBuffer;
    property VerticalSync: Boolean read GetVerticalSync write SetVerticalSync;
    property RenderPlace: TsgeGraphicRenderPlace read FRenderPlace write SetRenderPlace;
    property RenderSprite: TsgeGraphicSprite read FRenderSprite write SetRenderSprite;
  end;




implementation

uses
  sgeConst, sgeGraphicFrameList,
  dglOpenGL, Math;


const
  _UNITNAME = 'sgeGraphic';



function TsgeGraphic.GetInfo(Index: TsgeGraphicInfo): String;
begin
  case Index of
    giVendor     : Result := glGetString(GL_VENDOR);
    giRenderer   : Result := glGetString(GL_RENDERER);
    giVersion    : Result := glGetString(GL_VERSION);
    giExtensions : Result := glGetString(GL_EXTENSIONS);
    giShading    : Result := glGetString(GL_SHADING_LANGUAGE_VERSION);
    else Result := '';
  end;
end;


function TsgeGraphic.GetMetrix(Index: TsgeGraphicMetrics): Single;
var
  Dt: array[0..3] of Single;
begin
  case Index of
    gmContextWidth:
      begin
      glGetFloatv(GL_VIEWPORT, @Dt[0]);
      Result := Dt[2];
      end;
    gmContextHeight:
      begin
      glGetFloatv(GL_VIEWPORT, @Dt[0]);
      Result := Dt[3];
      end;
    gmAliasedPointMinSize:
      begin
      glGetFloatv(GL_ALIASED_POINT_SIZE_RANGE, @Dt[0]);
      Result := Dt[0];
      end;
    gmAliasedPointMaxSize:
      begin
      glGetFloatv(GL_ALIASED_POINT_SIZE_RANGE, @Dt[0]);
      Result := Dt[1];
      end;
    gmSmoothPointMinSize:
      begin
      glGetFloatv(GL_SMOOTH_POINT_SIZE_RANGE, @Dt[0]);
      Result := Dt[0];
      end;
    gmSmoothPointMaxSize:
      begin
      glGetFloatv(GL_SMOOTH_POINT_SIZE_RANGE, @Dt[0]);
      Result := Dt[1];
      end;
    gmSmoothPointGranularitySize:
      begin
      glGetFloatv(GL_SMOOTH_POINT_SIZE_GRANULARITY, @Dt[0]);
      Result := Dt[0];
      end;
   gmAliasedLineMinSize:
      begin
      glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, @Dt[0]);
      Result := Dt[0];
      end;
    gmAliasedLineMaxSize:
      begin
      glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, @Dt[0]);
      Result := Dt[1];
      end;
    gmSmoothLineMinSize:
      begin
      glGetFloatv(GL_SMOOTH_LINE_WIDTH_RANGE, @Dt[0]);
      Result := Dt[0];
      end;
    gmSmoothLineMaxSize:
      begin
      glGetFloatv(GL_SMOOTH_LINE_WIDTH_RANGE, @Dt[0]);
      Result := Dt[1];
      end;
    gmSmoothLineGranularitySize:
      begin
      glGetFloatv(GL_SMOOTH_LINE_WIDTH_GRANULARITY, @Dt[0]);
      Result := Dt[0];
      end;
  end;
end;


procedure TsgeGraphic.SetColor(AColor: TsgeGraphicColor);
begin
  glColor4fv(@Acolor);
end;


function TsgeGraphic.GetColor: TsgeGraphicColor;
begin
  glGetFloatv(GL_CURRENT_COLOR, @Result);
end;


procedure TsgeGraphic.SetBGColor(Acolor: TsgeGraphicColor);
begin
  glClearColor(Acolor.Red, Acolor.Green, Acolor.Blue, Acolor.Alpha);
end;


function TsgeGraphic.GetBGColor: TsgeGraphicColor;
begin
  glGetFloatv(GL_COLOR_CLEAR_VALUE, @Result);
end;


procedure TsgeGraphic.SetPointSize(ASize: Single);
begin
  glPointSize(ASize);
end;


function TsgeGraphic.GetPointSize: Single;
begin
  glGetFloatv(GL_POINT_SIZE, @Result);
end;


procedure TsgeGraphic.SetLineWidth(AWidth: Single);
begin
  glLineWidth(AWidth);
end;


function TsgeGraphic.GetLineWidth: Single;
begin
  glGetFloatv(GL_LINE_WIDTH, @Result);
end;


procedure TsgeGraphic.SetPoligonMode(AMode: TsgeGraphicPolygonMode);
begin
  case AMode of
    gpmDot  : glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
    gpmLine : glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    gpmFill : glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
  end;
end;


function TsgeGraphic.GetPoligonMode: TsgeGraphicPolygonMode;
var
  rs: array[0..1] of Integer;
begin
  //rs[0] - Front
  //rs[1] - Back
  glGetIntegerv(GL_POLYGON_MODE, @rs[0]);
  if rs[0] = GL_POINT then Result := gpmDot;
  if rs[0] = GL_LINE then Result := gpmLine;
  if rs[0] = GL_FILL then Result := gpmFill;
end;


procedure TsgeGraphic.SetShadeModel(AMode: TsgeGraphicShadeModel);
begin
  case AMode of
    gsmFlat: glShadeModel(GL_FLAT);
    gsmSmooth: glShadeModel(GL_SMOOTH);
  end;
end;


function TsgeGraphic.GetShadeModel: TsgeGraphicShadeModel;
var
  rs: Integer;
begin
  glGetIntegerv(GL_SHADE_MODEL, @rs);
  if rs = GL_FLAT then Result := gsmFlat;
  if rs = GL_SMOOTH then Result := gsmSmooth;
end;


procedure TsgeGraphic.SetState(AState: TsgeGraphicState; AEnable: Boolean);
begin
  case AState of
    gsPointSmooth  : if AEnable then glEnable(GL_POINT_SMOOTH) else glDisable(GL_POINT_SMOOTH);
    gsLineSmooth   : if AEnable then glEnable(GL_LINE_SMOOTH) else glDisable(GL_LINE_SMOOTH);
    gsPolygonSmooth: if AEnable then glEnable(GL_POLYGON_SMOOTH) else glDisable(GL_POLYGON_SMOOTH);
    gsColorBlend   : if AEnable then glEnable(GL_BLEND) else glDisable(GL_BLEND);
    gsLineStipple  : if AEnable then glEnable(GL_LINE_STIPPLE) else glDisable(GL_LINE_STIPPLE);
    gsTexture      : if AEnable then glEnable(GL_TEXTURE_2D) else glDisable(GL_TEXTURE_2D);
    gsScissor      : if AEnable then glEnable(GL_SCISSOR_TEST) else glDisable(GL_SCISSOR_TEST);
  end;
end;


function TsgeGraphic.GetState(AState: TsgeGraphicState): Boolean;
begin
  case AState of
    gsPointSmooth  : Result := glIsEnabled(GL_POINT_SMOOTH);
    gsLineSmooth   : Result := glIsEnabled(GL_LINE_SMOOTH);
    gsPolygonSmooth: Result := glIsEnabled(GL_POLYGON_SMOOTH);
    gsColorBlend   : Result := glIsEnabled(GL_BLEND);
    gsLineStipple  : Result := glIsEnabled(GL_LINE_STIPPLE);
    gsTexture      : Result := glIsEnabled(GL_TEXTURE_2D);
    gsScissor      : Result := glIsEnabled(GL_SCISSOR_TEST);
  end;
end;


procedure TsgeGraphic.SetRenderBuffer(ABuffer: TsgeGraphicRenderBuffer);
begin
  FRenderBuffer := ABuffer;

  case FRenderBuffer of
    grbFront: glDrawBuffer(GL_FRONT);
    grbBack: glDrawBuffer(GL_BACK);
  end;
end;


procedure TsgeGraphic.SetVerticalSync(AEnable: Boolean);
begin
  if wglSwapIntervalEXT = nil then
    raise EsgeException.Create(_UNITNAME, Err_VerticalSyncNotSupported);

  if AEnable then wglSwapIntervalEXT(1) else wglSwapIntervalEXT(0);
end;


function TsgeGraphic.GetVerticalSync: Boolean;
begin
  if wglGetSwapIntervalEXT = nil then
    raise EsgeException.Create(_UNITNAME, Err_VerticalSyncNotSupported);

  Result := (wglGetSwapIntervalEXT() = 1);
end;


procedure TsgeGraphic.SetView(AWidth, AHeight: Integer);
begin
  glViewport(0, 0, AWidth, AHeight);      //Задать область вывода
  glMatrixMode(GL_PROJECTION);            //Выбрать матрицу проекций
  glLoadIdentity;                         //Изменить проекцию на эталонную
  glOrtho(0, AWidth, AHeight, 0, -1, 1);  //Изменить проекцию на ортографическую
  glMatrixMode(GL_MODELVIEW);             //Выбрать матрицу модели
  glLoadIdentity;                         //Изменить проекцию на эталонную
end;


procedure TsgeGraphic.SetRenderSprite(ASprite: TsgeGraphicSprite);
begin
  //Установить спрайт для вывода
  FRenderSprite := ASprite;

  //Если режим вывода в спрайт, то изменить привязку
  if FRenderPlace = grpSprite then SetRenderPlace(grpSprite);
end;


procedure TsgeGraphic.SetRenderPlace(APlace: TsgeGraphicRenderPlace);
begin
  case APlace of
    grpScreen:
      begin
      glBindFramebuffer(GL_FRAMEBUFFER, 0); //Отвязать буфер от вывода
      SetView(FWidth, FHeight);             //Вернуть размеры окна
      end;

    grpSprite:
      begin
      if FRenderSprite = nil then
        raise EsgeException.Create(_UNITNAME, Err_SpriteIsEmpty);

      glBindFramebuffer(GL_FRAMEBUFFER, FFrameBuffer);                                                        //Установить временный буфер для вывода
      glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, FRenderSprite.GLHandle, 0); //Связать буфер кадра текстурой
      SetView(FRenderSprite.Width, FRenderSprite.Height);                                                     //Изменить размеры области вывода на размеры спрайта
      end;
  end;

  FRenderPlace := APlace;
end;


function TsgeGraphic.GetNormalRect(X, Y, W, H: Single; Mode: TsgeGraphicDrawMode): TsgeGraphicRect;
var
  HalfWidth, HalfHeight: Single;
begin
  case Mode of
    gdmClassic:
      begin
      Result.X1 := X;
      Result.Y1 := Y;
      Result.X2 := W;
      Result.Y2 := H;
      end;
    gdmNormal:
      begin
      Result.X1 := X;
      Result.Y1 := Y;
      Result.X2 := X + W;
      Result.Y2 := Y + H;
      end;
    gdmCentered:
      begin
      HalfWidth := W / 2;
      HalfHeight := H / 2;
      Result.X1 := X - HalfWidth;
      Result.Y1 := Y - HalfHeight;
      Result.X2 := X + HalfWidth;
      Result.Y2 := Y + HalfHeight;
      end;
  end;
end;


function TsgeGraphic.GetTransformedRect(X, Y, W, H: Single; Mode: TsgeGraphicDrawMode): TsgeGraphicRect;
var
  HalfWidth, HalfHeight: Single;
begin

  case Mode of
    gdmClassic:
      begin
      Result.X1 := 0;
      Result.Y1 := 0;
      Result.X2 := W - X;
      Result.Y2 := H - Y;
      end;
    gdmNormal:
      begin
      Result.X1 := 0;
      Result.Y1 := 0;
      Result.X2 := W;
      Result.Y2 := H;
      end;
    gdmCentered:
      begin
      HalfWidth := W / 2;
      HalfHeight := H / 2;
      Result.X1 := -HalfWidth;
      Result.Y1 := -HalfHeight;
      Result.X2 := HalfWidth;
      Result.Y2 := HalfHeight;
      end;
  end;
end;


function TsgeGraphic.GetTextureRect(Sprite: TsgeGraphicSprite; Xs, Ys, Ws, Hs: Single): TsgeGraphicRect;
begin
  Result.X1 := Xs * Sprite.GLPixelWidth;
  Result.Y1 := 1 - Ys * Sprite.GLPixelHeight;
  Result.X2 := Result.X1 + Ws * Sprite.GLPixelWidth;
  Result.Y2 := Result.Y1 - Hs * Sprite.GLPixelHeight;
end;


function TsgeGraphic.GetTileRect(Sprite: TsgeGraphicSprite; Col, Row: Word): TsgeGraphicRect;
begin
  Result.X1 := Col * Sprite.GLTileWidth;
  Result.Y1 := 1 - Row * Sprite.GLTileHeight;
  Result.X2 := Result.X1 + Sprite.GLTileWidth;
  Result.Y2 := Result.Y1 - Sprite.GLTileHeight;
end;


procedure TsgeGraphic.ShowSprite(Sprite: TsgeGraphicSprite; Rect, sRect: TsgeGraphicRect);
begin
  glBindTexture(GL_TEXTURE_2D, Sprite.GLHandle);
  glBegin(GL_QUADS);
    glTexCoord2f(sRect.X1, sRect.Y1);
    glVertex2f(Rect.X1, Rect.Y1);
    glTexCoord2f(sRect.X1, sRect.Y2);
    glVertex2f(Rect.X1, Rect.Y2);
    glTexCoord2f(sRect.X2, sRect.Y2);
    glVertex2f(Rect.X2, Rect.Y2);
    glTexCoord2f(sRect.X2, sRect.Y1);
    glVertex2f(Rect.X2, Rect.Y1);
  glEnd;
  glBindTexture(GL_TEXTURE_2D, 0);
end;


constructor TsgeGraphic.Create(DC: HDC; Width, Height: Integer);
var
  PFD: TPIXELFORMATDESCRIPTOR;
  PixelFormat: Integer;
begin
  //Загрузить библиотеку
  if GL_LibHandle = nil then InitOpenGL;

  //Проверить загрузилась ли Opengl32.dll
  if not Assigned(GL_LibHandle) then
    raise EsgeException.Create(_UNITNAME, Err_CantLoadOpenGLLib);

  //Прочитать адреса функций
  ReadOpenGLCore;

  //Запомнить DC WIndows
  FDC := DC;

  //Заполнить Pixel format
  ZeroMemory(@PFD, SizeOf(PFD));
  with PFD do
    begin
    nSize := SizeOf(PFD);
    dwFlags := PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW or PFD_TYPE_RGBA; //Поддержка OpenGL, двойной буфер, рисуем на окне, альфаканал
    iPixelType := PFD_TYPE_RGBA;  //Формат цвета 32 бита на точку
    iLayerType := PFD_MAIN_PLANE; //Основная плоскость
    cColorBits := 24;             //Количество бит для одного цвета без альфаканала
    end;

  //Попросить Windows подобрать запрошенный формат пикселя
  PixelFormat := ChoosePixelFormat(FDC, @PFD);

  //Проверить подобрался ли формат пикселя
  if PixelFormat = 0 then
    raise EsgeException.Create(_UNITNAME, Err_CantSelectPixelFormal);

  //Попробовать установить нужный формат пикселя и проверить
  if SetPixelFormat(FDC, PixelFormat, @PFD) = LongBool(0) then
    raise EsgeException.Create(_UNITNAME, Err_CantSetPixelFormat);

  //Создать контекст OpenGL
  FGLRC := wglCreateContext(FDC);

  //Проверить создался ли контекст
  if FGLRC = 0 then
    raise EsgeException.Create(_UNITNAME, Err_CantCreateContext);

  //Установка начальных значений
  wglMakeCurrent(FDC, FGLRC);                                 //Выбрать контекст OpenGL
  ReadExtensions;                                             //Найти адреса всех расширений
  ChangeViewArea(Width, Height);                              //Изменить вывод OpenGL
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);          //Задать режим смешивания
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE); //Задать текстурную среду, цвет точки текстуры заменяет цвет примитива
  FRenderBuffer := grbBack;                                   //По умолчанию задний буфер
  SetVerticalSync(True);                                      //Включить вертикальную синхронизацию
  glGenFramebuffers(1, @FFrameBuffer);                        //Выделить память для буфера кадра
  wglMakeCurrent(0, 0);                                       //Отменить выбор контекста
end;



destructor TsgeGraphic.Destroy;
begin
  glDeleteFramebuffers(1, @FFrameBuffer); //Удалить буфер кадра
  wglMakeCurrent(0, 0);                   //Отменить выбор контекста
  wglDeleteContext(FGLRC);                //Удалить контекст
end;


procedure TsgeGraphic.ChangeViewArea(AWidth, AHeight: Integer);
begin
  //Запомнить размеры окна
  if AWidth < 1 then AWidth := 1;
  FWidth := AWidth;

  if AHeight < 1 then AHeight := 1;
  FHeight := AHeight;

  //Установить область вывода
  SetView(FWidth, FHeight);
end;


procedure TsgeGraphic.Activate;
begin
  if not wglMakeCurrent(FDC, FGLRC) then
    raise EsgeException.Create(_UNITNAME, Err_CantActivateContext);
end;


procedure TsgeGraphic.Deactivate;
begin
  wglMakeCurrent(0, 0);
end;


procedure TsgeGraphic.Reset;
begin
  glLoadIdentity;
end;


procedure TsgeGraphic.SwapBuffers;
begin
  Windows.SwapBuffers(FDC);
end;


procedure TsgeGraphic.Finish;
begin
  glFinish;
end;


procedure TsgeGraphic.Flush;
begin
  glFlush;
end;


procedure TsgeGraphic.EraseBG;
begin
  glClear(GL_COLOR_BUFFER_BIT);
end;


procedure TsgeGraphic.PushMatrix;
begin
  glPushMatrix;
end;


procedure TsgeGraphic.PopMatrix;
begin
  glPopMatrix;
end;


procedure TsgeGraphic.PushAttrib;
begin
  glPushAttrib(GL_ALL_ATTRIB_BITS);
end;


procedure TsgeGraphic.PopAttrib;
begin
  glPopAttrib;
end;


procedure TsgeGraphic.SetScale(X, Y: Single);
begin
  glScalef(X, Y, 0);
end;


procedure TsgeGraphic.SetRotate(Angle: Single);
begin
  glRotatef(Angle, 0, 0, 1);
end;


procedure TsgeGraphic.SetPos(X, Y: Single);
begin
  glTranslatef(X, Y, 0);
end;


procedure TsgeGraphic.SetScissor(X, Y, W, H: Integer);
begin
  glScissor(X, trunc(GetMetrix(gmContextHeight)) - Y - H, W, H);
end;


procedure TsgeGraphic.SetLineStipple(Scale: Integer; Pattern: Word);
begin
  glLineStipple(Scale, Pattern);
end;


procedure TsgeGraphic.SetLineStipple(Scale: Integer; Mode: TsgeGraphicLineStipple);
var
  w: Word;
begin
  case Mode of
    glsSolid      : w := $FFFF; //1111111111111111
    glsDash       : w := $0F0F; //0000111100001111
    glsNarrowDash : w := $7777; //0111011101110111
    glsWideDash   : w := $3F3F; //0011111100111111
    glsDot        : w := $5555; //0101010101010101
    glsDashDot    : w := $2727; //0010011100100111
    glsDashDotDot : w := $5757; //0101011101010111
  end;
  glLineStipple(Scale, w);
end;


procedure TsgeGraphic.DrawPoint(X, Y: Single);
begin
  glBegin(GL_POINTS);
    glVertex2f(X, Y);
  glEnd;
end;


procedure TsgeGraphic.DrawLine(X1, Y1, X2, Y2: Single);
begin
  glBegin(GL_LINES);
    glVertex2f(X1, Y1);
    glVertex2f(X2, Y2);
  glEnd;
end;


procedure TsgeGraphic.DrawTriangle(X1, Y1, X2, Y2, X3, Y3: Single);
begin
  glBegin(GL_TRIANGLES);
    glVertex2f(X1, Y1);
    glVertex2f(X2, Y2);
    glVertex2f(X3, Y3);
  glEnd;
end;


procedure TsgeGraphic.DrawCircle(X, Y: Single; Radius: Single; Quality: Word);
var
  i, c: Integer;
  aCos, aSin, da: Single;
begin
  da := (Pi * 2) / Quality;
  c := Quality - 1;

  glBegin(GL_POLYGON);

  for i := 0 to c do
    begin
    SinCos(da * i, aSin, aCos);
    glVertex2f(X + Radius * aCos, Y + Radius * aSin);
    end;

  glEnd;
end;


procedure TsgeGraphic.DrawCircle(X, Y: Single; Radius: Single; Angle, Scale: Single; Quality: Word);
begin
  glPushMatrix;
  glTranslatef(X, Y, 0);
  glRotatef(Angle, 0, 0, 1);
  glScalef(Scale, Scale, 0);

  DrawCircle(0, 0, Radius, Quality);

  glPopMatrix;
end;


procedure TsgeGraphic.DrawRect(X, Y, W, H: Single; Mode: TsgeGraphicDrawMode);
var
  Rect: TsgeGraphicRect;
begin
  Rect := GetNormalRect(X, Y, W, H, Mode);

  glBegin(GL_QUADS);
    glVertex2f(Rect.X1, Rect.Y1);
    glVertex2f(Rect.X1, Rect.Y2);
    glVertex2f(Rect.X2, Rect.Y2);
    glVertex2f(Rect.X2, Rect.Y1);
  glEnd;
end;
 

procedure TsgeGraphic.DrawRect(X, Y, W, H: Single; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
var
  Rect: TsgeGraphicRect;
begin
  Rect := GetTransformedRect(X, Y, W, H, Mode);

  glPushMatrix;
  glTranslatef(X, Y, 0);
  glRotatef(Angle, 0, 0, 1);
  glScalef(Scale, Scale, 0);
  glBegin(GL_QUADS);
    glVertex2f(Rect.X1, Rect.Y1);
    glVertex2f(Rect.X1, Rect.Y2);
    glVertex2f(Rect.X2, Rect.Y2);
    glVertex2f(Rect.X2, Rect.Y1);
  glEnd;
  glPopMatrix;
end;


procedure TsgeGraphic.DrawRectGradient(X, Y, W, H: Single; Col1, Col2: TsgeGraphicColor; Mode: TsgeGraphicDrawMode);
var
  Rect: TsgeGraphicRect;
begin
  Rect := GetNormalRect(X, Y, W, H, Mode);

  glPushAttrib(GL_CURRENT_BIT);
  glBegin(GL_QUADS);
    glColor4fv(@Col1);
    glVertex2f(Rect.X1, Rect.Y1);
    glVertex2f(Rect.X1, Rect.Y2);
    glColor4fv(@Col2);
    glVertex2f(Rect.X2, Rect.Y2);
    glVertex2f(Rect.X2, Rect.Y1);
  glEnd;
  glPopAttrib;
end;


procedure TsgeGraphic.DrawRectGradient(X, Y, W, H: Single; Col1, Col2: TsgeGraphicColor; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
var
  Rect: TsgeGraphicRect;
begin
  Rect := GetTransformedRect(X, Y, W, H, Mode);

  glPushMatrix;
  glPushAttrib(GL_CURRENT_BIT);
  glTranslatef(X, Y, 0);
  glRotatef(Angle, 0, 0, 1);
  glScalef(Scale, Scale, 0);
  glBegin(GL_QUADS);
    glColor4fv(@Col1);
    glVertex2f(Rect.X1, Rect.Y1);
    glVertex2f(Rect.X1, Rect.Y2);
    glColor4fv(@Col2);
    glVertex2f(Rect.X2, Rect.Y2);
    glVertex2f(Rect.X2, Rect.Y1);
  glEnd;
  glPopAttrib;
  glPopMatrix;
end;


procedure TsgeGraphic.DrawSprite(X, Y, W, H: Single; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode);
var
  Rect, sRect: TsgeGraphicRect;
begin
  Rect := GetNormalRect(X, Y, W, H, Mode);

  sRect.X1 := 0;
  sRect.Y1 := 1;
  sRect.X2 := 1;
  sRect.Y2 := 0;

  ShowSprite(Sprite, Rect, sRect);
end;


procedure TsgeGraphic.DrawSprite(X, Y, W, H: Single; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
var
  Rect, sRect: TsgeGraphicRect;
begin
  Rect := GetTransformedRect(X, Y, W, H, Mode);

  sRect.X1 := 0;
  sRect.Y1 := 1;
  sRect.X2 := 1;
  sRect.Y2 := 0;

  glPushMatrix;
  glTranslatef(X, Y, 0);
  glRotatef(Angle, 0, 0, 1);
  glScalef(Scale, Scale, 0);
  ShowSprite(Sprite, Rect, sRect);
  glPopMatrix;
end;


procedure TsgeGraphic.DrawSprite(X, Y: Single; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode);
begin
  if Mode = gdmClassic then Mode := gdmNormal;
  DrawSprite(X, Y, Sprite.Width, Sprite.Height, Sprite, Mode);
end;


procedure TsgeGraphic.DrawSprite(X, Y: Single; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
begin
  if Mode = gdmClassic then Mode := gdmNormal;
  DrawSprite(X, Y, Sprite.Width, Sprite.Height, Sprite, Angle, Scale, Mode);
end;


procedure TsgeGraphic.DrawSpritePart(X, Y, W, H: Single; Xs, Ys, Ws, Hs: Single; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode);
var
  Rect, sRect: TsgeGraphicRect;
begin
  Rect := GetNormalRect(X, Y, W, H, Mode);
  sRect := GetTextureRect(Sprite, Xs, Ys, Ws, Hs);
  ShowSprite(Sprite, Rect, sRect);
end;


procedure TsgeGraphic.DrawSpritePart(X, Y, W, H: Single; Xs, Ys, Ws, Hs: Single; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
var
  Rect, sRect: TsgeGraphicRect;
begin
  Rect := GetTransformedRect(X, Y, W, H, Mode);
  sRect := GetTextureRect(Sprite, Xs, Ys, Ws, Hs);

  glPushMatrix;
  glTranslatef(X, Y, 0);
  glRotatef(Angle, 0, 0, 1);
  glScalef(Scale, Scale, 0);
  ShowSprite(Sprite, Rect, sRect);
  glPopMatrix;
end;


procedure TsgeGraphic.DrawSpritePart(X, Y: Single; Xs, Ys, Ws, Hs: Single; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode);
begin
  if Mode = gdmClassic then Mode := gdmNormal;
  DrawSpritePart(X, Y, Sprite.Width, Sprite.Height, Xs, Ys, Ws, Hs, Sprite, Mode);
end;


procedure TsgeGraphic.DrawSpritePart(X, Y: Single; Xs, Ys, Ws, Hs: Single; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
begin
  if Mode = gdmClassic then Mode := gdmNormal;
  DrawSpritePart(X, Y, Sprite.Width, Sprite.Height, Xs, Ys, Ws, Hs, Sprite, Angle, Scale, Mode);
end;


procedure TsgeGraphic.DrawSpriteTiled(X, Y, W, H: Single; Col, Row: Word; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode);
var
  Rect, sRect: TsgeGraphicRect;
begin
  Rect := GetNormalRect(X, Y, W, H, Mode);
  sRect := GetTileRect(Sprite, Col, Row);
  ShowSprite(Sprite, Rect, sRect);
end;


procedure TsgeGraphic.DrawSpriteTiled(X, Y, W, H: Single; Col, Row: Word; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
var
  Rect, sRect: TsgeGraphicRect;
begin
  Rect := GetTransformedRect(X, Y, W, H, Mode);
  sRect := GetTileRect(Sprite, Col, Row);

  glPushMatrix;
  glTranslatef(X, Y, 0);
  glRotatef(Angle, 0, 0, 1);
  glScalef(Scale, Scale, 0);
  ShowSprite(Sprite, Rect, sRect);
  glPopMatrix;
end;


procedure TsgeGraphic.DrawSpriteTiled(X, Y: Single; Col, Row: Word; Sprite: TsgeGraphicSprite; Mode: TsgeGraphicDrawMode);
begin
  if Mode = gdmClassic then Mode := gdmNormal;
  DrawSpriteTiled(X, Y, Sprite.Width, Sprite.Height, Col, Row, Sprite, Mode);
end;


procedure TsgeGraphic.DrawSpriteTiled(X, Y: Single; Col, Row: Word; Sprite: TsgeGraphicSprite; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
begin
  if Mode = gdmClassic then Mode := gdmNormal;
  DrawSpriteTiled(X, Y, Sprite.Width, Sprite.Height, Col, Row, Sprite, Angle, Scale, Mode);
end;


procedure TsgeGraphic.DrawAnimation(X, Y, W, H: Single; Animation: TsgeGraphicAnimation; Mode: TsgeGraphicDrawMode);
var
  Frame: TsgeGraphicFrame;
begin
  Frame := Animation.CurrentFrame;
  DrawSpriteTiled(X, Y, W, H, Frame.Col, Frame.Row, Frame.Sprite, Mode);
end;


procedure TsgeGraphic.DrawAnimation(X, Y, W, H: Single; Animation: TsgeGraphicAnimation; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
var
  Frame: TsgeGraphicFrame;
begin
  Frame := Animation.CurrentFrame;
  DrawSpriteTiled(X, Y, W, H, Frame.Col, Frame.Row, Frame.Sprite, Angle, Scale, Mode);
end;


procedure TsgeGraphic.DrawAnimation(X, Y: Single; Animation: TsgeGraphicAnimation; Mode: TsgeGraphicDrawMode);
begin
  if Mode = gdmClassic then Mode := gdmNormal;
  DrawAnimation(X, Y, Animation.Width, Animation.Height, Animation, Mode);
end;


procedure TsgeGraphic.DrawAnimation(X, Y: Single; Animation: TsgeGraphicAnimation; Angle, Scale: Single; Mode: TsgeGraphicDrawMode);
begin
  if Mode = gdmClassic then Mode := gdmNormal;
  DrawAnimation(X, Y, Animation.Width, Animation.Height, Animation, Angle, Scale, Mode);
end;


procedure TsgeGraphic.DrawText(X, Y: Single; Font: TsgeGraphicFont; Text: String);
begin
  if Text = '' then Exit;
  glPushAttrib(GL_LIST_BIT);                                    //Сохранить настройки дисплейных списков
  glRasterPos2f(X, Y + Font.Height);                            //Указать координаты вывода растров
  glListBase(Font.GLHandle);                                    //Выбрать первый дисплейный список
  glCallLists(Length(Text), GL_UNSIGNED_BYTE, PAnsiChar(Text)); //Вывести списки с номерами равным коду символа
  glPopAttrib;                                                  //Вернуть настройки
end;


procedure TsgeGraphic.ScreenShot(Stream: TsgeMemoryStream);
var
  BFH: TBitmapFileHeader;
  BIH: TBITMAPINFOHEADER;
  Width, Height, BytesPerLine, Trash, Size, szFileHeader, szInfoHeader: Integer;
  Dt: array[0..3] of Integer;
  DATA: array of Byte;
begin
  //Узнать размер области просмотра
  glGetIntegerv(GL_VIEWPORT, @Dt[0]);                       //Запросить размеры
  Width := Dt[2];                                           //Ширина контекста
  Height := Dt[3];                                          //Высота контекста

  //Байтов в одной строке
  BytesPerLine := Width * 3;

  //Определить количество байт для выравнивания
  Trash := 4 - (BytesPerLine mod 4);

  //Определить размер данных с мусором
  Size := (BytesPerLine + Trash) * Height;

  //Чтение данных из OpenGL
  SetLength(DATA, Size);                                    //Буфер для OpenGL
  glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);            //Запомнить настройки выравнивания битов
  glPixelStorei(GL_PACK_ALIGNMENT, 4);                      //Выравнивание по dword
  glReadBuffer(GL_FRONT);                                   //Указать передний буфер кадра
  glReadPixels(0, 0, Width, Height, GL_BGR, GL_UNSIGNED_BYTE, @DATA[0]); //Прочесть в буфер цвета точек без прозрачности
  glPopClientAttrib;                                        //Вернуть настройки выравнивания

  //Определить размеры структур
  szFileHeader := SizeOf(TBitmapFileHeader);
  szInfoHeader := SizeOf(TBITMAPINFOHEADER);

  //Описатель BMP файла
  BFH.bfType := $4D42;                                      //Волшебное слово от микрософта - BM
  BFH.bfReserved1 := 0;
  BFH.bfReserved2 := 0;
  BFH.bfOffBits := szFileHeader + szInfoHeader;             //Смещение от начала файла до самих данных
  BFH.bfSize := BFH.bfOffBits + Size;                       //Размер файла целиком со структурами и мусором

  //Описатель BMP
  BIH.biSize := szInfoHeader;                               //Размер этой структуры. Интересно зачем
  BIH.biWidth := Width;                                     //Ширина битмапа
  BIH.biHeight := Height;                                   //Высота битмапа
  BIH.biPlanes := 1;                                        //Сколько слоёв
  BIH.biBitCount := 24;                                     //Бит на пиксель
  BIH.biCompression := BI_RGB;                              //Без сжатия
  BIH.biSizeImage := 0;                                     //Не используется без сжатия
  BIH.biXPelsPerMeter := 0;                                 //Разрешение по X
  BIH.biYPelsPerMeter := 0;                                 //Разрешение по Y
  BIH.biClrUsed := 0;                                       //Сколько цветов в таблице индексов
  BIH.biClrImportant := 0;                                  //0 - все индексы цветов доступны

  //Записать в поток
  Stream.Size := 0;                                         //Обнулить память
  Stream.Write(BFH, 0, SizeOf(BFH));                        //Заголовок файла
  Stream.Write(BIH, szFileHeader, SizeOf(BIH));             //Описание битмапа
  Stream.Write(DATA[0], szFileHeader + szInfoHeader, Size); //Записать данные

  //Очистить буфер
  SetLength(DATA, 0);
end;




end.
