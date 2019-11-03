{
Пакет             Simple Game Engine 1
Файл              SimpleGameEngine.pas
Версия            1.18
Создан            07.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Главный класс движка
}

unit SimpleGameEngine;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleCommand,
  sgeConst, sgeTypes, sgeParameters, sgeStartParameters, sgeWindow, sgeJournal, sgeGraphic, sgeEvent,
  sgeResources, sgeSystemIcon, sgeSystemCursor, sgeSystemFont, sgeGraphicSprite, sgeGraphicFont,
  sgeFade, sgeGraphicColor, sgeSound, sgeSoundBuffer, sgeCounter, sgeGraphicFrames, sgeShell,
  sgeShellFunctions, sgeJoysticks,
  Windows, SysUtils;


type
  //Приоритет основного процесса
  TsgePriority = (pIdle, pBelowNormal, pNormal, pAboveNormal, pHigh, pRealTime);

  //Режимы загрузки (Ресурсы приложения, Хранилище ресурсов, Файл)
  TsgeLoadFrom = (lfHinstance, lfResource, lfFile);

  //Тип диалогового окна
  TsgeMessageType = (mtError, mtInfo);

  //Режим работы параметров (Замена, Обновление, Обновление и добавление)
  TsgeParameterWorkMode = (pwmReplace, pwmUpdate, pwmUpdateAndAdd);

  //Режим ограничения кадров (Вертикальная синхронизация, Програмный способ)
  TsgeDrawControl = (dcSync, dcProgram);

  //Способ опроса клавиш клавиатуры
  TsgeKeyDownMethod = (kdmSync, kdmAsync);


  TSimpleGameEngine = class
  private
    _AppWorking: Boolean;                                                               //Флаг работы главного цикла
    _MSG: TMSG;                                                                         //Переменная для хранения номера сообщения
    _MouseOut: Boolean;                                                                 //Флаг мыши за окном

    FUserName: ShortString;                                                             //Имя пользователя

    FDirMain: String;                                                                   //Главный каталог проекта
    FDirJournal: String;                                                                //Каталог журналов
    FDirShots: String;                                                                  //Каталог снимков
    FDirUser: String;                                                                   //Каталог пользователя

    FDebug: Boolean;                                                                    //Режим отладки
    FDrawEnable: Boolean;                                                               //Флаг вывода графики
    FDrawControl: TsgeDrawControl;                                                      //Режим ограничения кадров
    FOneSecondFrequency: Int64;                                                         //Количество аппаратных тиков процессора в секунду
    FDrawLastTime: Int64;                                                               //Время прошлого вывода графики
    FDrawCurrentTime: Int64;                                                            //Время текущого вывода графики
    FDrawDelay: Int64;                                                                  //Задержка между выводами графики в тиках процессора
    FMaxFramesPerSecond: Word;                                                          //Максимально кадров в секунду
    FAutoEraseBG: Boolean;                                                              //Автоочистка фона перед рисованием
    FCursorPos: Tsgepoint;                                                              //Координаты курсора
    FAutoScanJoysticks: Boolean;                                                        //Сканирование джойстиков при подключении

    FStartParameters: TsgeStartParameters;                                              //Стартовые параметры
    FParameters: TsgeParameters;                                                        //Массив с параметрами
    FJournal: TsgeJournal;                                                              //Система протоколирования
    FWindow: TsgeWindow;                                                                //Главное окно
    FGraphic: TsgeGraphic;                                                              //OpenGL
    FSound: TsgeSound;                                                                  //Звук
    FResources: TsgeResources;                                                          //Хранилище ресурсов
    FLanguage: TsgeParameters;                                                          //Массив языковых строк
    FTickEvent: TsgeEvent;                                                              //Таймер обработки мира
    FFPSCounter: TsgeCounter;                                                           //Счётчик кадров
    FShell: TsgeShell;                                                                  //Оболочка
    FShellFont: TsgeGraphicFont;                                                        //Шрифт оболочки
    FJoysticks: TsgeJoysticks;                                                          //Хранилище джойстиков
    FJoystickEvent: TsgeEvent;                                                          //Таймер опроса джойстиков
    FFade: TsgeFade;                                                                    //Затемнение экрана

    FDefSystemIcon: TsgeSystemIcon;                                                     //Иконка приложения
    FDefSystemCursor: TsgeSystemCursor;                                                 //Курсор приложения
    FDefGraphicSprite: TsgeGraphicSprite;                                               //Графический спрайт по умолчанию
    FDefGraphicFont: TsgeGraphicFont;                                                   //Графический шрифт по умолчанию
    FDefSoundBuffer: TsgeSoundBuffer;                                                   //Звуковой буфер по умолчанию
    FDefGraphicFrames: TsgeGraphicFrames;                                               //Кадры анимации по умолчанию

    procedure SetPriority(APriotity: TsgePriority);                                     //Изменить приоритет процесса
    function  GetPriority: TsgePriority;                                                //Узнать приоритет процесса
    procedure SetTickDelay(ADelay: Cardinal);                                           //Задать задержку системных тиков
    function  GetTickDelay: Cardinal;                                                   //Узнать задержку системных тиков
    procedure SetTickEnable(AEnable: Boolean);                                          //Запустить работу системных тиков
    function  GetTickEnable: Boolean;                                                   //Узнать работу системных тиков
    procedure SetTickCount(ACount: Cardinal);                                           //Изменить количество системных тиков
    function  GetTickCount: Cardinal;                                                   //Узнать количество тиков
    procedure SetJoysticksDelay(ADelay: Cardinal);                                      //Задать задержку опросов джойстиков
    function  GetJoysticksDelay: Cardinal;                                              //Узнать задержку джойстиков
    procedure SetJoysticksEnable(AEnable: Boolean);                                     //Запустить работу джойстиков
    function  GetJoysticksEnable: Boolean;                                              //Узнать работу джойстиков
    procedure SetDrawControl(AMetod: TsgeDrawControl);                                  //Изменить метод контроля кадров
    procedure SetMaxFramesPerSecond(ACount: Word);                                      //Изменить потолок кадров в секунду
    function  GetFramesPerSecond: Cardinal;                                             //Узнать счётчик кадров
    function  GetStrFramesPerSecond: String;                                            //Узнать счётчик кадров в виде строки
    procedure SetDirJournal(ADir: String);                                              //Изменить каталог журналов
    procedure SetDirShots(ADir: String);                                                //Изменить каталог скиншотов
    procedure SetDirUser(ADir: String);                                                 //Изменить каталог пользователя
    procedure SetDebug(AEnable: Boolean);                                               //Изменить режим отладки
    function  GetLocalizedErrorString(ErrStr: String): String;                          //Вернуть подготовленную строку ошибки с учётом языка
    procedure SetMouseTrackEvent;                                                       //Запустить слежение за нестандартными сообщениями мыши
    procedure CorrectViewport;                                                          //Изменить область вывода графики
    function  GetKeyboardButtons: TsgeKeyboardButtons;                                  //Определить функциональные клавиши
    function  GetMouseButtons(wParam: WPARAM): TsgeMouseButtons;                        //Узнать нажатые клавиши
    function  GetMouseScrollDelta(wParam: WPARAM): Integer;                             //Определить значение прокрутки
    function  ProcessMouseDownCommand(wParam: WPARAM): Boolean;                         //Выполнить команду по нажатию клавиши мыши
    function  ProcessMouseUpCommand(wParam: WPARAM): Boolean;                           //Выполнить команду по отпусканию клавиши мыши
    function  ProcessMouseScrollCommand(wParam: WPARAM): Boolean;                       //Выполнить команду по прокрутке колеса мыши
    procedure ProcessMessage;                                                           //Заглушка для обработки сообщений
    procedure DrawShell;                                                                //Нарисовать оболочку
    procedure DrawFade;                                                                 //Нарисовать затемнение
    procedure RealDraw;                                                                 //Вывод одного кадра
    procedure ProcessDraw;                                                              //Заглушка для метода рисования
    procedure JoystickEvent;
    procedure WMDeviceChange;                                                           //Изменение оборудования компьютера
    function  WndProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;  //Обработчик сообщений системы
  public
    constructor Create; virtual;
    destructor  Destroy; override;

    procedure ProcessError(Msg: String);                                                //Обработать ошибку
    procedure ShowMessage(Msg: String; AType: TsgeMessageType = mtError);               //Вывод диолгового окна
    function  IsKeyDown(Key: Integer; Method: TsgeKeyDownMethod = kdmSync): Boolean;    //Узнать нажата ли клавиша
    procedure LoadLanguage(FileName: String; Mode: TsgeLoadMode = lmReplace);           //Загрузить язык

    procedure InitWindow;                                                               //Создание окна
    procedure InitGraphic;                                                              //Подключение графики
    procedure InitSound;                                                                //Инициализация звука

    procedure LoadParameters(FileName: String; Mode: TsgeParameterWorkMode);            //Загрузка параметров из файла
    procedure SaveParameters(FileName: String; Mode: TsgeParameterWorkMode);            //Сохранить параметры в файл
    procedure OverrideParameters;                                                       //Переопределить параметры из командной строки

    procedure LoadAppIcon(Name: String; From: TsgeLoadFrom = lfHinstance);              //Изменить иконку
    procedure LoadAppCursor(Name: String; From: TsgeLoadFrom = lfHinstance);            //Изменить курсор

    procedure FullScreen;                                                               //Переход в полноэкранный режим
    procedure Screenshot(FileName: String = '');                                        //Снимок окна

    procedure LoadResourcesFromTable(FileName: String; Mode: TsgeLoadMode = lmAdd);     //Загрузка ресурсов по таблице
    function  GetGraphicSprite(Name: String): TsgeGraphicSprite;                        //Безопасная загрузка графического спрайта
    function  GetGraphicFont(Name: String): TsgeGraphicFont;                            //Безопасная загрузка графического шрифта
    function  GetSoundBuffer(Name: String): TsgeSoundBuffer;                            //Безопасная загрузка звукового буфера
    function  GetGraphicFrames(Name: String): TsgeGraphicFrames;                        //Безопасная загрузка кадров анимации
    function  GetParameters(Name: String): TsgeParameters;                              //Безопасная загрузка таблицы параметров

    procedure FadeStart(Mode: TsgeFadeMode; Color: TsgeGraphicColor; Time: Cardinal);   //Запустить затемнение
    procedure FadeStop;

    procedure Stop;                                                                     //Прибить бесконечный цикл
    procedure Run;                                                                      //Бесконечный цикл
    procedure Tick; virtual;                                                            //Пересчёт мира
    procedure Draw; virtual;                                                            //Рисование
    function  CloseWindow: Boolean; virtual;                                            //Перехват закрытия окна
    procedure LostWindowFocus; virtual;                                                 //Потеря фокуса окном
    procedure SetWindowFocus; virtual;                                                  //Восстановление фокуса окна
    procedure ShowWindow; virtual;                                                      //Показ окна
    procedure HideWindow; virtual;                                                      //Сокрытие окна
    procedure ResizeWindow; virtual;                                                    //Новые размеры окна
    procedure ResizingWindow; virtual;                                                  //Изменение размеров окна
    procedure ActivateWindow; virtual;                                                  //Активация окна
    procedure DeactivateWindow; virtual;                                                //Деактивация окна
    procedure MouseLeave; virtual;                                                      //Уход мыши за клиентскую область окна
    procedure MouseReturn; virtual;                                                     //Возврат мыши в клиентскую область окна
    procedure JoystickInput; virtual;                                                   //Опрос состояния джойстиков
    procedure JoystickScan; virtual;                                                    //Функция после сканирования джойстиков
    procedure KeyChar(Key: Char; KeyboardButtons: TsgeKeyboardButtons); virtual;
    procedure KeyDown(Key: Byte; KeyboardButtons: TsgeKeyboardButtons); virtual;
    procedure KeyUp(Key: Byte; KeyboardButtons: TsgeKeyboardButtons); virtual;
    procedure MouseDown(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons); virtual;
    procedure MouseUp(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons); virtual;
    procedure MouseMove(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons); virtual;
    procedure MouseDoubleClick(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons); virtual;
    procedure MouseScroll(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons; Delta: Integer); virtual;

    property UserName: ShortString read FUserName write FUserName;
    property Debug: Boolean read FDebug write SetDebug;
    property DirMain: String read FDirMain;
    property DirJournal: String read FDirJournal write SetDirJournal;
    property DirShots: String read FDirShots write SetDirShots;
    property DirUser: String read FDirUser write SetDirUser;
    property OneSecondFrequency: Int64 read FOneSecondFrequency;

    property Priority: TsgePriority read GetPriority write SetPriority;
    property TickDelay: Cardinal read GetTickDelay write SetTickDelay;
    property TickEnable: Boolean read GetTickEnable write SetTickEnable;
    property JoysticksDelay: Cardinal read GetJoysticksDelay write SetJoysticksDelay;
    property JoysticksEnable: Boolean read GetJoysticksEnable write SetJoysticksEnable;
    property TickCount: Cardinal read GetTickCount write SetTickCount;
    property DrawControl: TsgeDrawControl read FDrawControl write SetDrawControl;
    property DrawEnable: Boolean read FDrawEnable write FDrawEnable;
    property MaxFPS: Word read FMaxFramesPerSecond write SetMaxFramesPerSecond;
    property FPS: Cardinal read GetFramesPerSecond;
    property StrFps: String read GetStrFramesPerSecond;
    property AutoEraseBG: Boolean read FAutoEraseBG write FAutoEraseBG;
    property CursorPos: Tsgepoint read FCursorPos;
    property AutoScanJoysticks: Boolean read FAutoScanJoysticks write FAutoScanJoysticks;

    property Shell: TsgeShell read FShell;
    property ShellFont: TsgeGraphicFont read FShellFont;
    property StartParameters: TsgeStartParameters read FStartParameters;
    property Parameters: TsgeParameters read FParameters;
    property Journal: TsgeJournal read FJournal;
    property Window: TsgeWindow read FWindow;
    property Graphic: TsgeGraphic read FGraphic;
    property Sound: TsgeSound read FSound;
    property Resources: TsgeResources read FResources;
    property Joysticks: TsgeJoysticks read FJoysticks;

    property DefSystemIcon: TsgeSystemIcon read FDefSystemIcon;
    property DefSystemCursor: TsgeSystemCursor read FDefSystemCursor;
    property DefGraphicSprite: TsgeGraphicSprite read FDefGraphicSprite;
    property DefGraphicFont: TsgeGraphicFont read FDefGraphicFont;
    property DefGraphicFrames: TsgeGraphicFrames read FDefGraphicFrames;
    property DefSoundBuffer: TsgeSoundBuffer read FDefSoundBuffer;
  end;



implementation

var
  _SGEGlobalPtr: TSimpleGameEngine;


function sgeWndProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := _SGEGlobalPtr.WndProc(hWnd, Msg, wParam, lParam);
end;





procedure TSimpleGameEngine.SetPriority(APriotity: TsgePriority);
var
  mode: DWORD;
begin
  case APriotity of
    pIdle       : mode := $40;   //IDLE_PRIORITY_CLASS
    pBelowNormal: mode := $4000; //BELOW_NORMAL_PRIORITY_CLASS
    pNormal     : mode := $20;   //NORMAL_PRIORITY_CLASS
    pAboveNormal: mode := $8000; //ABOVE_NORMAL_PRIORITY_CLASS
    pHigh       : mode := $80;   //HIGH_PRIORITY_CLASS
    pRealTime   : mode := $100;  //REALTIME_PRIORITY_CLASS
  end;

  if not SetPriorityClass(GetCurrentProcess, mode) then
    ProcessError(Err_SGE + Err_Separator + Err_SGE_SetPriority_CantChangePriority);
end;


function TSimpleGameEngine.GetPriority: TsgePriority;
var
  mode: DWORD;
begin
  mode := GetPriorityClass(GetCurrentProcess);
  case mode of
    $40   : Result := pIdle;        //IDLE_PRIORITY_CLASS
    $4000 : Result := pBelowNormal; //BELOW_NORMAL_PRIORITY_CLASSend;
    $20   : Result := pNormal;      //NORMAL_PRIORITY_CLASS      d;
    $8000 : Result := pAboveNormal; //ABOVE_NORMAL_PRIORITY_CLASS
    $80   : Result := pHigh;        //HIGH_PRIORITY_CLASS
    $100  : Result := pRealTime;    //REALTIME_PRIORITY_CLASS
  end;

  if mode = 0 then
    ProcessError(Err_SGE + Err_Separator + Err_SGE_GetPriority_CantReadPriority);
end;


procedure TSimpleGameEngine.SetTickDelay(ADelay: Cardinal);
begin
  FTickEvent.Delay := ADelay;
end;


function TSimpleGameEngine.GetTickDelay: Cardinal;
begin
  Result := FTickEvent.Delay;
end;


procedure TSimpleGameEngine.SetTickEnable(AEnable: Boolean);
begin
  FTickEvent.Enable := AEnable;
end;


function TSimpleGameEngine.GetTickEnable: Boolean;
begin
  Result := FTickEvent.Enable;
end;


procedure TSimpleGameEngine.SetTickCount(ACount: Cardinal);
begin
  FTickEvent.Count := ACount;
end;


function TSimpleGameEngine.GetTickCount: Cardinal;
begin
  Result := FTickEvent.Count;
end;


procedure TSimpleGameEngine.SetJoysticksDelay(ADelay: Cardinal);
begin
  FJoystickEvent.Delay := ADelay;
end;


function TSimpleGameEngine.GetJoysticksDelay: Cardinal;
begin
  Result := FJoystickEvent.Delay;
end;


procedure TSimpleGameEngine.SetJoysticksEnable(AEnable: Boolean);
begin
  if FJoystickEvent.Enable = AEnable then Exit;

  if AEnable then
    begin
    Joysticks.Scan;                     //Поиск джойстиков
    JoystickScan;                       //Пользовательская функция
    end;

  FJoystickEvent.Enable := AEnable;     //Переключить состояние

  if not AEnable then FJoysticks.Reset; //Сбросить значения осей и кнопок
end;


function TSimpleGameEngine.GetJoysticksEnable: Boolean;
begin
  Result := FJoystickEvent.Enable;
end;


procedure TSimpleGameEngine.SetDrawControl(AMetod: TsgeDrawControl);
begin
  FDrawControl := AMetod;
  if FGraphic <> nil then
    try
      FGraphic.VerticalSync := (FDrawControl = dcSync);
    except
      on E:EsgeException do
        ProcessError(Err_SGE + Err_Separator + Err_SGE_SetDrawControl_CantChangeVertSync + Err_StrSeparator + E.Message);
    end;
end;


procedure TSimpleGameEngine.SetMaxFramesPerSecond(ACount: Word);
begin
  if ACount = 0 then ACount := 1;
  FMaxFramesPerSecond := ACount;
  FDrawDelay := Round(FOneSecondFrequency / FMaxFramesPerSecond);
end;


function TSimpleGameEngine.GetFramesPerSecond: Cardinal;
begin
  Result := FFPSCounter.Count;
end;


function TSimpleGameEngine.GetStrFramesPerSecond: String;
begin
  Result := FFPSCounter.StrCount;
end;


procedure TSimpleGameEngine.SetDirJournal(ADir: String);
begin
  ADir := IncludeTrailingBackslash(ADir);
  FDirJournal := ADir;
end;


procedure TSimpleGameEngine.SetDirShots(ADir: String);
begin
  ADir := IncludeTrailingBackslash(ADir);
  FDirShots := ADir;
end;


procedure TSimpleGameEngine.SetDirUser(ADir: String);
begin
  ADir := IncludeTrailingBackslash(ADir);
  FDirUser := ADir;
end;


procedure TSimpleGameEngine.SetDebug(AEnable: Boolean);
var
  fn: String;
begin
  if FDebug = AEnable then Exit;
  FDebug := AEnable;

  if FDebug then
    begin
    fn := FDirJournal + sgeGetUniqueFileName + '.' + sge_ExtJournal;
    try
      FJournal.FileName := fn;
      FJournal.Enable := True;
    except
      on E:EsgeException do
        ProcessError(Err_SGE + Err_Separator + Err_SGE_SetDebug_CantStartJournal + Err_Separator + fn + Err_StrSeparator + E.Message);
    end;
    end else FJournal.Enable := False;
end;


function TSimpleGameEngine.GetLocalizedErrorString(ErrStr: String): String;
var
  aName, aCode, aInfo: String;
  Name, Message: String;
begin
  //Разобрать строку на части
  sgeDecodeErrorString(ErrStr, aName, aCode, aInfo);

  //Преобразовать в человеческий язык
  Name := aName;                                              //Имя модуля по умолчанию
  FLanguage.GetString(aName, Name);                           //Найти имя модуля
  Message := aCode;                                           //Код ошибки по умолчанию
  FLanguage.GetString(aName + '.' + aCode, Message);          //Найти информацию об ошибке

  //Подготовить результат
  Result := Name + ' - ' + Message;
  if aInfo <> '' then Result := Result + ' (' + aInfo + ')';  //Если есть подробности, то добавить
end;


procedure TSimpleGameEngine.SetMouseTrackEvent;
var
  tme: TTrackMouseEvent;
begin
  tme.cbSize := SizeOf(TTrackMouseEvent); //Размер структуры
  tme.hwndTrack := FWindow.Handle;        //Хэндл окна
  tme.dwFlags := TME_LEAVE;               //Вызывать сообщение только ухода мыши
  tme.dwHoverTime := 0;                   //Таймаут нависания (в моём случае не используется)
  TrackMouseEvent(tme);                   //Запустить КОСТЫЛЬ!
end;


procedure TSimpleGameEngine.CorrectViewport;
var
  Rct: TRect;
begin
  if FGraphic = nil then Exit;
  GetClientRect(FWindow.Handle, Rct);             //Текущие размеры окна
  FGraphic.ChangeViewArea(Rct.Right, Rct.Bottom); //Изменить ViewPort OpenGL
end;


function TSimpleGameEngine.GetKeyboardButtons: TsgeKeyboardButtons;
begin
  Result := [];
  if (GetKeyState(VK_LMENU) and $8000) <> 0 then Include(Result, kbLeftAlt);
  if (GetKeyState(VK_RMENU) and $8000) <> 0 then Include(Result, kbRightAlt);
  if (GetKeyState(VK_LCONTROL) and $8000) <> 0 then Include(Result, kbLeftCtrl);
  if (GetKeyState(VK_RCONTROL) and $8000) <> 0 then Include(Result, kbRightCtrl);
  if (GetKeyState(VK_LSHIFT) and $8000) <> 0 then Include(Result, kbLeftShift);
  if (GetKeyState(VK_RSHIFT) and $8000) <> 0 then Include(Result, kbRightShift);
  if (GetKeyState(VK_CAPITAL) and 1) = 1 then Include(Result, kbCapsLock);
  if (GetKeyState(VK_NUMLOCK) and 1) = 1 then Include(Result, kbNumLock);
  if (GetKeyState(VK_SCROLL) and 1) = 1 then Include(Result, kbScrollLock);
  if (GetKeyState(VK_INSERT) and 1) = 1 then Include(Result, kbInsert);
  if (kbLeftAlt in Result) or (kbRightAlt in Result) then Include(Result, kbAlt);
  if (kbLeftCtrl in Result) or (kbRightCtrl in Result) then Include(Result, kbCtrl);
  if (kbLeftShift in Result) or (kbRightShift in Result) then Include(Result, kbShift);
end;


function TSimpleGameEngine.GetMouseButtons(wParam: WPARAM): TsgeMouseButtons;
begin
  Result := [];

  {$R-}
  wParam := LOWORD(wParam);
  {$R+}

  if (wParam and MK_LBUTTON) = MK_LBUTTON then Include(Result, mbLeft);
  if (wParam and MK_MBUTTON) = MK_MBUTTON then Include(Result, mbMiddle);
  if (wParam and MK_RBUTTON) = MK_RBUTTON then Include(Result, mbRight);
  if (wParam and MK_XBUTTON1) = MK_XBUTTON1 then Include(Result, mbExtra1);
  if (wParam and MK_XBUTTON2) = MK_XBUTTON2 then Include(Result, mbExtra2);
end;


function TSimpleGameEngine.GetMouseScrollDelta(wParam: WPARAM): Integer;
begin
  {$R-}
  Result := SmallInt(HIWORD(wParam)) div 120;
  {$R+}
end;


function TSimpleGameEngine.ProcessMouseDownCommand(wParam: WPARAM): Boolean;
var
  mb: TsgeMouseButtons;
  Btn: TsgeMouseButton;
  Idx: Byte;
begin
  Result := False;
  mb := GetMouseButtons(wParam);

  for Btn := Low(TsgeMouseButtons) to High(TsgeMouseButtons) do
    begin
    Idx := Ord(Btn);
    if (Btn in mb) and (FShell.KeyTable.Key[Idx].Down <> '') then
      begin
      Result := True;
      FShell.DoCommand(FShell.KeyTable.Key[Idx].Down);
      end;
    end;
end;


function TSimpleGameEngine.ProcessMouseUpCommand(wParam: WPARAM): Boolean;
var
  mb: TsgeMouseButtons;
  Btn: TsgeMouseButton;
  Idx: Byte;
begin
  Result := False;
  mb := GetMouseButtons(wParam);

  for Btn := Low(TsgeMouseButtons) to High(TsgeMouseButtons) do
    begin
    Idx := Ord(Btn);
    if (Btn in mb) and (FShell.KeyTable.Key[Idx].Up <> '') then
      begin
      Result := True;
      FShell.DoCommand(FShell.KeyTable.Key[Idx].Up);
      end;
    end;
end;


function TSimpleGameEngine.ProcessMouseScrollCommand(wParam: WPARAM): Boolean;
var
  Delta: SmallInt;
begin
  Result := False;
  Delta := GetMouseScrollDelta(wParam);

  //Up
  if (Delta > 0) and (FShell.KeyTable.Key[5].Up <> '') then
    begin
    Result := True;
    FShell.DoCommand(FShell.KeyTable.Key[5].Up);
    end;

  //Down
  if (Delta < 0) and (FShell.KeyTable.Key[5].Down <> '') then
    begin
    Result := True;
    FShell.DoCommand(FShell.KeyTable.Key[5].Down);
    end;
end;


procedure TSimpleGameEngine.ProcessMessage;
const
  ModeDefault = 0;
  ModeKey     = 1;
  ModeShell   = 2;
var
  Mode: Byte;
  I: Cardinal;
begin
  while PeekMessage(_MSG, 0, 0, 0, PM_REMOVE) do

    case _MSG.message of
      //Нажатие клавиши клавиатуры
      WM_KEYDOWN, WM_SYSKEYDOWN:
        begin
        Mode := ModeDefault;
        if FShell.KeyTable.Key[_MSG.wParam].Down <> '' then Mode := ModeKey;
        if FShell.Enable then Mode := ModeShell;
        case mode of
          ModeDefault:
            begin
            TranslateMessage(_MSG);
            DispatchMessage(_MSG);
            end;
          ModeShell:
            begin
            TranslateMessage(_MSG);
            FShell.ProcessKey(_MSG.wParam, GetKeyboardButtons);
            end;
          ModeKey:
            if (_MSG.lParam shr 30 <> 1) then FShell.DoCommand(FShell.KeyTable.Key[_MSG.wParam].Down);
        end;
        end;

      //Отпускание клавиши клавиатуры
      WM_KEYUP, WM_SYSKEYUP:
        begin
        Mode := ModeDefault;
        if FShell.KeyTable.Key[_MSG.wParam].Up <> '' then Mode := ModeKey;
        if FShell.Enable then Mode := ModeShell;
        case mode of
          ModeDefault:
            begin
            TranslateMessage(_MSG);
            DispatchMessage(_MSG);
            end;
          ModeShell:
            TranslateMessage(_MSG);
          ModeKey:
            FShell.DoCommand(FShell.KeyTable.Key[_MSG.wParam].Up);
        end;
        end;

      //Нажатие клавиши мыши
      WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN, WM_XBUTTONDOWN:
        if not ProcessMouseDownCommand(_MSG.wParam) then DispatchMessage(_MSG);

      //Двойной клик мыши
      WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_XBUTTONDBLCLK:
        if not ProcessMouseDownCommand(_MSG.wParam) then DispatchMessage(_MSG);

      //Отпускание левой клавиши мыши
      WM_LBUTTONUP:
        if not ProcessMouseUpCommand(MK_LBUTTON) then
          begin
          _MSG.wParam := MK_LBUTTON;
          DispatchMessage(_MSG);
          end;

      //Отпускание средней клавиши мыши
      WM_MBUTTONUP:
        if not ProcessMouseUpCommand(MK_MBUTTON) then
          begin
          _MSG.wParam := MK_MBUTTON;
          DispatchMessage(_MSG);
          end;

      //Отпускание правой клавиши мыши
      WM_RBUTTONUP:
        if not ProcessMouseUpCommand(MK_RBUTTON) then
          begin
          _MSG.wParam := MK_RBUTTON;
          DispatchMessage(_MSG);
          end;

      //Отпускание дополнительных клавишь мыши
      WM_XBUTTONUP:
        begin
        if SmallInt(HIWORD(_MSG.wParam)) = 1 then I := MK_XBUTTON1 else I := MK_XBUTTON2;
        if not ProcessMouseUpCommand(I) then
          begin
          _MSG.wParam := I;
          DispatchMessage(_MSG);
          end;
        end;

      //Прокрутка колеса мыши
      WM_MOUSEWHEEL:
        if not ProcessMouseScrollCommand(_MSG.wParam) then DispatchMessage(_MSG);

      else begin
        TranslateMessage(_MSG);
        DispatchMessage(_MSG);
      end;
    end;
end;


procedure TSimpleGameEngine.DrawShell;
var
  w, h, hline, X1, Y1, X2, Y2: Single;
  i, c, lc: Integer;
  Rct: TsgeRect;
begin
  //Определить параметры вывода
  w := FWindow.ClientWidth;               //Ширина окна
  hline := FShellFont.Height;             //Высота строки
  h := hline * (FShell.VisibleLines + 1); //Область вывода оболочки
  X1 := 3;

  //Подготовить графику
  FGraphic.Reset;
  FGraphic.PushAttrib;
  FGraphic.PoligonMode := gpmFill;
  FGraphic.LineWidth := 1;
  FGraphic.Capabilities[gcLineSmooth] := False;
  FGraphic.Capabilities[gcColorBlend] := True;

  //Фон
  FGraphic.Color := FShell.BGColor;
  FGraphic.DrawRect(0, 0, w, h);

  //Фоновая картинка
  if FShell.BGSprite <> nil then
    begin
    FGraphic.Capabilities[gcTexture] := True;
    Rct := sgeGetShellBGRect(w, h, FShell.BGSprite.Width, FShell.BGSprite.Height);
    FGraphic.DrawSpritePart(0, 0, w, h, Rct.X1, Rct.Y1, Rct.X2, Rct.Y2, FShell.BGSprite, gdmClassic);
    FGraphic.Capabilities[gcTexture] := False;
    end;

  //Редактор
  Y1 := h - hline - 5;
  FGraphic.Color := FShell.EditorColor;
  FGraphic.DrawText(X1, Y1, FShellFont, FShell.Editor.Line);

  //Координаты Y и Y1 для курсора и выделения
  Y1 := h - hline - 4;
  Y2 := h - 2;

  //Выделение
  if FShell.Editor.SelectCount > 0 then
    begin
    X1 := 3 + FShellFont.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.SelectBeginPos));
    X2 := 3 + FShellFont.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.SelectEndPos));
    FGraphic.Color := FShell.SelectColor;
    FGraphic.DrawRect(X1, Y1, X2, Y2, gdmClassic);
    end;

  //Курсор
  X1 := 3 + FShellFont.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.CursorPos));
  FGraphic.Color := FShell.CursorColor;
  FGraphic.DrawLine(X1, Y1, X1, Y2);

  //Журнал
  lc := FShell.Journal.Count - 1;
  c := min(lc, FShell.VisibleLines);
  X1 := 3;
  for i := c downto 0 do
    begin
    Y1 := h - (hline * (i + 2)) - hline / 1.5;
    FGraphic.Color := FShell.Journal.Line[lc - i].Color;
    FGraphic.DrawText(X1, Y1, FShellFont, FShell.Journal.Line[lc - i].Text);
    end;

  //Отключить смешивание цветов
  FGraphic.Capabilities[gcColorBlend] := False;
  FGraphic.PopAttrib;
end;


procedure TSimpleGameEngine.DrawFade;
begin
  //Подготовить графику
  FGraphic.PushAttrib;
  FGraphic.Reset;
  FGraphic.PoligonMode := gpmFill;
  FGraphic.Capabilities[gcColorBlend] := True;

  //Задать цвет
  FGraphic.Color := FFade.GetColor;

  //Вывод прямоугольника
  FGraphic.DrawRect(0, 0, FWindow.Width, FWindow.Height, gdmClassic);

  //Восстановить графику
  FGraphic.PopAttrib;
end;


procedure TSimpleGameEngine.RealDraw;
begin
  //Обработать счётчик
  FFPSCounter.Process;

  if FAutoEraseBG then FGraphic.EraseBG;  //Стереть фон
  if FDrawEnable then Draw;               //Вывод кадра
  if FFade.Enable then DrawFade;          //Вывод затемнения
  if FShell.Enable then DrawShell;        //Вывод оболочки

  //Смена кадров
  case FGraphic.RenderBuffer of
    grbBack : FGraphic.SwapBuffers;
    grbFront: FGraphic.Finish;
  end;
end;


procedure TSimpleGameEngine.ProcessDraw;
begin
  if FGraphic = nil then Exit;

  case FDrawControl of
    dcSync: RealDraw;

    dcProgram:
      begin
      QueryPerformanceCounter(FDrawCurrentTime);
      if (FDrawCurrentTime - FDrawLastTime) >= FDrawDelay then
        begin
        FDrawLastTime := FDrawCurrentTime;
        RealDraw;
        end;
      end;
  end;
end;


procedure TSimpleGameEngine.JoystickEvent;
begin
  FJoysticks.Process; //Опросить состояние джойстиков
  JoystickInput;      //Выполнить пользовательскую функцию
end;


procedure TSimpleGameEngine.WMDeviceChange;
var
  b: Boolean;
begin
  if not FAutoScanJoysticks then Exit;

  b := FJoystickEvent.Enable;       //Запомнить состояние опроса
  FJoystickEvent.Enable := False;   //Отключить опрос
  FJoysticks.Scan;                  //Определить джойстики
  JoystickScan;                     //Выполнить пользовательсккую функцию
  FJoystickEvent.Enable := b;       //Вернуть прежнее состояние опроса
end;


function TSimpleGameEngine.WndProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  ps: TPAINTSTRUCT;
begin
  Result := 0;
  case Msg of

    WM_DESTROY:
      Stop;

    WM_CLOSE:
      if CloseWindow then DestroyWindow(hWnd);

    WM_ERASEBKGND: ;

    WM_SIZE:
      begin
      CorrectViewport;
      ResizeWindow;
      end;

    WM_SIZING:
      ResizingWindow;

    WM_PAINT:
      begin
      BeginPaint(hWnd, ps);
      RealDraw;
      EndPaint(hWnd, ps);
      end;

    WM_MOVING:
      FWindow.Update;

    WM_MOUSELEAVE:
      begin
      _MouseOut := True;
      MouseLeave;
      end;

    WM_SYSCOMMAND:
      if wParam <> SC_KEYMENU then Result := DefWindowProc(hWnd, Msg, wParam, lParam);

    WM_SETFOCUS:
      SetWindowFocus;

    WM_KILLFOCUS:
      LostWindowFocus;

    WM_SHOWWINDOW:
      if wParam = 1 then ShowWindow else HideWindow;

    WM_ACTIVATE:
      if wParam = WA_INACTIVE then DeActivateWindow else ActivateWindow;

    WM_CHAR:
      if FShell.Enable then FShell.ProcessChar(chr(wParam), GetKeyboardButtons) else KeyChar(chr(wParam), GetKeyboardButtons);

    WM_KEYDOWN, WM_SYSKEYDOWN:
      KeyDown(wParam, GetKeyboardButtons);

    WM_KEYUP, WM_SYSKEYUP:
      KeyUp(wParam, GetKeyboardButtons);

    WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN, WM_XBUTTONDOWN:
      MouseDown(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons);

    WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
      MouseUp(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons);

    WM_MOUSEMOVE:
      begin
      //Обработать возврат мыши на форму
      if _MouseOut then
        begin
        _MouseOut := False;
        SetMouseTrackEvent;
        MouseReturn;
        end;

      //Запомнить координаты курсора
      FCursorPos.X := GET_X_LPARAM(lParam);
      FCursorPos.Y := GET_Y_LPARAM(lParam);

      //Пользовательская функция
      MouseMove(FCursorPos.X, FCursorPos.Y, GetMouseButtons(wParam), GetKeyboardButtons);
      end;

    WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_XBUTTONDBLCLK:
      MouseDoubleClick(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons);

    WM_MOUSEWHEEL:
      MouseScroll(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons, GetMouseScrollDelta(wParam));

    WM_DEVICECHANGE:
      WMDeviceChange;

    else Result := DefWindowProc(hWnd, Msg, wParam, lParam);
  end;
end;


constructor TSimpleGameEngine.Create;
begin
  //Важные вещи
  Randomize;                                                                //Изменить смещение таблицы рандома
  DefaultFormatSettings.DecimalSeparator := '.';                            //Установить точку разделителем дробной части
  QueryPerformanceFrequency(FOneSecondFrequency);                           //Узнать частоту процессора
  _SGEGlobalPtr := Self;                                                    //Глобальная переменная на этот класс
  _AppWorking := True;                                                      //Флаг работы приложения
  _MouseOut := False;                                                       //Мышь внутри окна
  FUserName := 'User';                                                      //Имя пользователя
  FDirMain := AnsiToUtf8(ExtractFilePath(ParamStr(0)));                     //Подготовить главный каталог проекта
  FDirJournal := FDirMain + sge_DirJournal + '\';                           //Определить каталог журналов
  FDirShots := FDirMain + sge_DirShoots + '\';                              //Определить каталог снимков
  FDirUser := FDirMain + sge_DirUser + '\';                                 //Определить каталог пользователя

  //Классы
  FShell := TsgeShell.Create;                                               //Оболочка
  FJournal := TsgeJournal.Create('');                                       //Журналирование
  FStartParameters := TsgeStartParameters.Create;                           //Стартовые параметры
  FParameters := TsgeParameters.Create;                                     //Настройки
  FResources := TsgeResources.Create;                                       //Хранилище ресурсов
  FLanguage := TsgeParameters.Create;                                       //Языковые строки
  FJoysticks := TsgeJoysticks.Create;                                       //Хранилище джойстиков
  FTickEvent := TsgeEvent.Create(50, False, @Tick, -1);                     //Таймер обработки мира
  FJoystickEvent := TsgeEvent.Create(10, False, @JoystickEvent, -1);        //Таймер обработки джойстиков
  FFPSCounter := TsgeCounter.Create;                                        //Счётчик кадров
  FFade := TsgeFade.Create;                                                 //Затемнение
  FDefSystemIcon := TsgeSystemIcon.Create;                                  //Создать иконку
  FDefSystemCursor := TsgeSystemCursor.Create;                              //Создать курсор

  //Команды оболочки
  sgeShellFunctions_RegisterCommand(Self);                                  //Регистрация команд оболочки

  //Настройка системы
  SetDrawControl(dcProgram);                                                //Изменить режим ограничения кадров
  SetMaxFramesPerSecond(100);                                               //Установить предел кадров
  FAutoEraseBG := True;                                                     //Стирать фон перед рисованием
  FDrawEnable := True;                                                      //Включить вывод графики
  FAutoScanJoysticks := False;                                              //Не сканировать при подключении джойстика

  //Проверить стартовые параметры
  if FStartParameters.Exist[sge_PrmDebug] then SetDebug(True);              //Если есть отладка, то включить
end;


destructor TSimpleGameEngine.Destroy;
begin
  FDefGraphicFrames.Free;   //Кадры анимации
  FDefGraphicFont.Free;     //Шрифт по умолчанию
  FDefGraphicSprite.Free;   //Спрайт по умолчанию
  FDefSystemCursor.Free;    //Курсор по умолчанию
  FDefSystemIcon.Free;      //Иконка по умолчанию
  FDefSoundBuffer.Free;     //Звуковой буфер по умолчанию

  FFade.Free;               //Затемнение
  FShellFont.Free;          //Шрифт оболочки
  FShell.Free;              //Оболочка
  FResources.Free;          //Ресурсы
  FSound.Free;              //Звук
  FGraphic.Free;            //OpenGL
  FWindow.Free;             //Окно
  FTickEvent.Free;          //Таймер обработки мира
  FJoystickEvent.Free;      //Таймер обработки джойстиков
  FFPSCounter.Free;         //Счётчик кадров
  FParameters.Free;         //Параметры приложения
  FStartParameters.Free;    //Стартовые параметры
  FLanguage.Free;           //Языковые строки
  FJoysticks.Free;          //Хранилище джойстиков
  FJournal.Free;            //Журналирование
end;


procedure TSimpleGameEngine.ProcessError(Msg: String);
var
  sa: TStringArray;
  i, c: Integer;
  Str: String;
  LogJ, LogS: Boolean;
begin
  //Предусмотреть протоколирование
  LogJ := FJournal.Enable;
  LogS := FShell.LogErrors;
  if not (LogJ or LogS) then Exit;

  //Разбить на строки
  StringArray_StringToArray(@sa, Msg);

  //Цикл по строкам
  c := StringArray_GetCount(@sa) - 1;
  for i := 0 to c do
    begin
    //Локализовать строку
    Str := GetLocalizedErrorString(sa[i]);
    //Вывод в журнал
    if LogJ then if i = 0 then FJournal.LogDetail(Str) else FJournal.Log('             ' + Str);
    //Вывод в оболочку
    if LogS then if i = 0 then FShell.LogMessage('Error: ' + Str, sltError) else FShell.LogMessage('       ' + Str, sltNote);
    end;

  //Почистить память
  StringArray_Clear(@sa);
end;


procedure TSimpleGameEngine.ShowMessage(Msg: String; AType: TsgeMessageType);
var
  d: UINT;
begin
  case AType of
    mtError: d := MB_ICONERROR;
    mtInfo : d := MB_ICONINFORMATION;
  end;
  d := MB_OK or d;
  MessageBox(0, PChar(Msg), PChar(SGE_Name), d);
end;


function TSimpleGameEngine.IsKeyDown(Key: Integer; Method: TsgeKeyDownMethod): Boolean;
begin
  case Method of
    kdmAsync: Result := (GetAsyncKeyState(Key) and $8000) <> 0;
    kdmSync : Result := (GetKeyState(Key) and $8000) <> 0;
  end;
end;


procedure TSimpleGameEngine.LoadLanguage(FileName: String; Mode: TsgeLoadMode);
begin
  try
    case Mode of
      lmReplace: FLanguage.LoadFromFile(FileName);
      lmAdd    : FLanguage.UpdateFromFile(FileName, True);
    end;
  except
    on E:EsgeException do
      ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadLanguage_CantLoadLanguage + Err_Separator + FileName + Err_StrSeparator + E.Message);
  end;
end;


procedure TSimpleGameEngine.InitWindow;
var
  s: String;
begin
  try
    FWindow := TsgeWindow.Create(SGE_Name + SGE_Version, '', 100, 100, 800, 600);
    FWindow.SetWindowProc(@sgeWndProc);
    SetMouseTrackEvent;
  except
    on E: EsgeException do
      begin
      s := Err_SGE + Err_Separator + Err_SGE_InitWindow_CantInitWindow;
      ProcessError(s + Err_StrSeparator + E.Message);
      raise EsgeException.Create(s);
      end;
  end;
end;


procedure TSimpleGameEngine.InitGraphic;
var
  gf: TsgeGraphicFrameArray;
  s: String;
begin
  try
    FGraphic := TsgeGraphic.Create(FWindow.DC, FWindow.ClientWidth, FWindow.ClientHeight);
    FGraphic.Activate;
    FDefGraphicSprite := TsgeGraphicSprite.CreateChessBoard(32, 32, 4);
    FDefGraphicFont := TsgeGraphicFont.Create('Courier New', 12);
    FShellFont := TsgeGraphicFont.Create('Courier New', 12);

    //Создать кадры анимации
    SetLength(gf, 1);
    gf[0].SpriteName := 'Default';
    gf[0].Sprite := FDefGraphicSprite;
    gf[0].Col := 0;
    gf[0].Row := 0;
    gf[0].Time := FOneSecondFrequency;
    FDefGraphicFrames := TsgeGraphicFrames.Create(gf);
    SetLength(gf, 0);

  except
    on E: EsgeException do
      begin
      s := Err_SGE + Err_Separator + Err_SGE_InitGraphic_CantInitGraphic;
      ProcessError(s + Err_StrSeparator + E.Message);
      raise EsgeException.Create(E.Message);
      end;
  end;
end;


procedure TSimpleGameEngine.InitSound;
var
  s: String;
begin
  try
    FSound := TsgeSound.Create;
    FDefSoundBuffer := TsgeSoundBuffer.CreateBlank;
  except
    on E: EsgeException do
      begin
      s := Err_SGE + Err_Separator + Err_SGE_InitSound_CantInitSound;
      ProcessError(s + Err_StrSeparator + E.Message);
      raise EsgeException.Create(s);
      end;
  end;
end;


procedure TSimpleGameEngine.LoadParameters(FileName: String; Mode: TsgeParameterWorkMode);
begin
  if not FileExists(FileName) then FileName := FDirMain + FileName;
  try
    case Mode of
      pwmReplace     : Parameters.LoadFromFile(FileName);
      pwmUpdate      : Parameters.UpdateFromFile(FileName);
      pwmUpdateAndAdd: Parameters.UpdateFromFile(FileName, True);
    end;
  except
    on E:EsgeException do
      ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadParameters_CantLoadFromFile + Err_Separator + FileName + Err_StrSeparator + E.Message);
  end;
end;


procedure TSimpleGameEngine.SaveParameters(FileName: String; Mode: TsgeParameterWorkMode);
begin
  if not FileExists(FileName) then FileName := FDirMain + FileName;
  try
    case Mode of
      pwmReplace     : Parameters.SaveToFile(FileName);
      pwmUpdate      : Parameters.UpdateInFile(FileName);
      pwmUpdateAndAdd: Parameters.UpdateInFile(FileName, True);
    end;
  except
    on E:EsgeException do
      ProcessError(Err_SGE + Err_Separator + Err_SGE_SaveParameters_CantSaveToFile + Err_Separator + FileName + Err_StrSeparator + E.Message);
  end;
end;


procedure TSimpleGameEngine.OverrideParameters;
var
  i, c: Integer;
begin
  c := FStartParameters.Count - 1;
  for i := 0 to c do
    FParameters.SetString(FStartParameters.Parameter[i].Name, FStartParameters.Parameter[i].Value);
end;


procedure TSimpleGameEngine.LoadAppIcon(Name: String; From: TsgeLoadFrom);
var
  Ico: TsgeSystemIcon;
begin
  if FWindow = nil then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadAppIcon_WindowNotInitialized + Err_Separator + Name);
    Exit;
    end;

  Ico := nil;

  case From of
    lfHinstance:
      try
        FDefSystemIcon.LoadFromHinstance(Name);
        Ico := FDefSystemIcon;
      except
        on E:EsgeException do
          ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadAppIcon_CantLoadFromHinstance + Err_Separator + Name + Err_StrSeparator + E.Message);
      end;

    lfResource:
      begin
      Ico := TsgeSystemIcon(FResources.TypedObj[Name, rtSystemIcon]);
      if Ico = nil then
        ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadAppIcon_CantLoadFromResource + Err_Separator + Name);
      end;

    lfFile:
      try
        FDefSystemIcon.LoadFromFile(Name);
        Ico := FDefSystemIcon;
      except
        on E:EsgeException do
          ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadAppIcon_CantLoadFromFile + Err_Separator + Name + Err_StrSeparator + E.Message);
      end;
  end;

  if Ico <> nil then
    begin
    FWindow.Icon := Ico.Handle;
    FWindow.StatusBarIcon := Ico.Handle;
    end;
end;


procedure TSimpleGameEngine.LoadAppCursor(Name: String; From: TsgeLoadFrom);
var
  Cur: TsgeSystemCursor;
begin
  if FWindow = nil then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadAppCursor_WindowNotInitialized + Err_Separator + Name);
    Exit;
    end;

  Cur := nil;

  case From of
    lfHinstance:
      try
        FDefSystemCursor.LoadFromHinstance(Name);
        Cur := FDefSystemCursor;
      except
        on E:EsgeException do
          ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadAppCursor_CantLoadFromHinstance + Err_Separator + Name + Err_StrSeparator + E.Message);
      end;

    lfResource:
      begin
      Cur := TsgeSystemCursor(FResources.TypedObj[Name, rtSystemCursor]);
      if Cur = nil then
        ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadAppCursor_CantLoadFromResource + Err_Separator + Name);
      end;

    lfFile:
      try
        FDefSystemCursor.LoadFromFile(Name);
        Cur := FDefSystemCursor;
      except
        on E:EsgeException do
          ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadAppCursor_CantLoadFromFile + Err_Separator + Name + Err_StrSeparator + E.Message);
      end;
  end;

  if Cur <> nil then FWindow.Cursor := Cur.Handle;
end;


procedure TSimpleGameEngine.FullScreen;
begin
  FWindow.FullScreen;
  SendMessage(FWindow.Handle, WM_SIZE, 0, 0);
end;


procedure TSimpleGameEngine.Screenshot(FileName: String);
begin
  //Проверить графику
  if FGraphic = nil then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_Screenshot_GraphicNotInitialized);
    Exit;
    end;

  //Если особый случай, то задать имя по умолчанию
  if FileName = '' then
    begin
    FileName := FDirShots + sgeGetUniqueFileName + '.' + sge_ExtShots;
    ForceDirectories(FDirShots);
    end;

  //Сохранить
  try
    FGraphic.ScreenShot(FileName);
  except
    on E:EsgeException do
      ProcessError(Err_SGE + Err_Separator + Err_SGE_Screenshot_SaveError + Err_Separator + FileName + Err_StrSeparator + E.Message);
  end;
end;


procedure TSimpleGameEngine.LoadResourcesFromTable(FileName: String; Mode: TsgeLoadMode);
var
  sa, Line: TStringArray;
  BasePath: String;
  c, i, sCols, sRows: Integer;
  Obj: TObject;
  sMagFilter, sMinFilter: TsgeGraphicSpriteFilter;
  fAttr: TsgeGraphicFontAttrib;
begin
  //Поправить путь на абсолютный
  FileName := FDirMain + FileName;

  //Проверить есть ли файл
  if not FileExists(FileName) then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_FileNotFound + Err_Separator + FileName);
    Exit;
    end;

  //Прочитать файл
  if not StringArray_LoadFromFile(@sa, FileName) then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_ReadError + Err_Separator + FileName);
    Exit;
    end;

  //Предусмотреть очистку ресурсов
  if Mode = lmReplace then FResources.Clear;

  //Обработать таблицу
  BasePath := ExtractFilePath(FileName);              //Записать путь к таблице
  c := StringArray_GetCount(@sa) - 1;                 //Сколько всего строк
  for i := 0 to c do
    begin
    Obj := nil;                                       //Почистить адрес
    sa[i] := Trim(sa[i]);                             //Убрать лишние пробелы
    if sa[i] = '' then Continue;                      //Пустая строка
    if sa[i][1] = '#' then Continue;                  //Символ заметки

    SimpleCommand_Disassemble(@Line, sa[i]);          //Разобрать на части
    if not StringArray_Equal(@Line, 3) then Continue; //Проверить на наличие 3 частей

    //Проверить на совпадение имени
    if FResources.IndexOf(Line[1]) <> -1 then
      begin
      ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_DuplicateResource + Err_Separator + Line[1]);
      end;

    case LowerCase(Line[0]) of
      //Иконка
      rtSystemIcon:
        begin
        try
          Obj := TsgeSystemIcon.CreateFromFile(BasePath + Line[2]);
        except
          on E:EsgeException do
            ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_SystemIconNotLoaded + Err_Separator + Line[2] + Err_StrSeparator + E.Message);
        end;
        if Obj <> nil then FResources.AddItem(Line[1], rtSystemIcon, Obj);
        end;

      //Курсор
      rtSystemCursor:
        begin
        try
          Obj := TsgeSystemCursor.CreateFromFile(BasePath + Line[2]);
        except
          on E:EsgeException do
            ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_SystemCursorNotLoaded + Err_Separator + Line[2] + Err_StrSeparator + E.Message);
        end;
        if Obj <> nil then FResources.AddItem(Line[1], rtSystemCursor, Obj);
        end;

      //Системный шрифт
      rtSystemFont:
        begin
        try
          Obj := TsgeSystemFont.Create(BasePath + Line[2]);
        except
          on E:EsgeException do
            ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_SystemFontNotLoaded + Err_Separator + Line[2] + Err_StrSeparator + E.Message);
        end;
        if Obj <> nil then FResources.AddItem(Line[1], rtSystemFont, Obj);
        end;

      //Спрайт
      rtGraphicSprite:
        begin
        //Cols
        sCols := 1;
        if StringArray_Equal(@Line, 4) then
          if not TryStrToInt(Line[3], sCols) then sCols := 1;
        if sCols < 1 then sCols := 1;
        //Rows
        sRows := 1;
        if StringArray_Equal(@Line, 5) then
          if not TryStrToInt(Line[4], sRows) then sRows := 1;
        if sRows < 1 then sRows := 1;
        //MagFilter
        sMagFilter := gsfNearest;
        if StringArray_Equal(@Line, 6) then
          if LowerCase(Line[5]) = 'linear' then sMagFilter := gsfLinear;
        //MinFilter
        sMinFilter := gsfNearest;
        if StringArray_Equal(@Line, 7) then
          if LowerCase(Line[6]) = 'linear' then sMinFilter := gsfLinear;
        //Создать и добавить в хранилище
        try
          Obj := TsgeGraphicSprite.Create(BasePath + Line[2], sCols, sRows, sMagFilter, sMinFilter);
        except
          on E:EsgeException do
            ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_GraphicSpriteNotLoaded + Err_Separator + Line[2] + Err_StrSeparator + E.Message);
        end;
        if Obj <> nil then FResources.AddItem(Line[1], rtGraphicSprite, Obj);
        end;

      //Графический шрифт
      rtGraphicFont:
        begin
        //Size
        sCols := 12;
        if StringArray_Equal(@Line, 4) then
          if not TryStrToInt(Line[3], sCols) then sCols := 1;
        if sCols < 1 then sCols := 1;
        //Attrib
        fAttr := [];
        if StringArray_Equal(@Line, 5) then
          begin
          Line[4] := LowerCase(Line[4]);
          if Pos('b', Line[4]) <> 0 then Include(fAttr, gfaBold);
          if Pos('i', Line[4]) <> 0 then Include(fAttr, gfaItalic);
          if Pos('u', Line[4]) <> 0 then Include(fAttr, gfaUnderline);
          if Pos('s', Line[4]) <> 0 then Include(fAttr, gfaStrikeOut);
          end;
        //Создать и добавить в хранилище
        try
          Obj := TsgeGraphicFont.Create(Line[2], sCols, fAttr);
        except
          on E:EsgeException do
            ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_GraphicFontNotLoaded + Err_Separator + Line[2] + Err_StrSeparator + E.Message);
        end;
        if Obj <> nil then FResources.AddItem(Line[1], rtGraphicSprite, Obj);
        end;

      //Звуковой буфер
      rtSoundBuffer:
        begin
        try
          Obj := TsgeSoundBuffer.Create(BasePath + Line[2]);
        except
          on E:EsgeException do
            ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_SoundBufferNotLoaded + Err_Separator + Line[2] + Err_StrSeparator + E.Message);
        end;
        if Obj <> nil then FResources.AddItem(Line[1], rtSoundBuffer, Obj);
        end;

      //Кадры анимации
      rtGraphicFrames:
        begin
        try
          Obj := TsgeGraphicFrames.Create(BasePath + Line[2], FResources);
        except
          on E:EsgeException do
            ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_GraphicFramesNotLoaded + Err_Separator + Line[2] + Err_StrSeparator + E.Message);
        end;
        if Obj <> nil then FResources.AddItem(Line[1], rtGraphicFrames, Obj);
        end;

      //Таблица параметров
      rtParameters:
        begin
        try
          Obj := TsgeParameters.Create;
          TsgeParameters(Obj).LoadFromFile(BasePath + Line[2]);
        except
          on E:EsgeException do
            begin
            FreeAndNil(Obj);
            ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_ParametersNotLoaded + Err_Separator + Line[2] + Err_StrSeparator + E.Message);
            end;
        end;
        if Obj <> nil then FResources.AddItem(Line[1], rtParameters, Obj);
        end;


      //Если не удалось определить тип
      else ProcessError(Err_SGE + Err_Separator + Err_SGE_LoadResource_CantBeDetermined + Err_Separator + Line[0]);
    end;

    end;//for i := 0

  //Почистить память
  StringArray_Clear(@Line);
  StringArray_Clear(@sa);
end;


function TSimpleGameEngine.GetGraphicSprite(Name: String): TsgeGraphicSprite;
begin
  Result := TsgeGraphicSprite(FResources.TypedObj[Name, rtGraphicSprite]);
  if Result = nil then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_GetGraphicSprite_SpriteNotFound + Err_Separator + Name);
    Result := FDefGraphicSprite;
    end;
end;


function TSimpleGameEngine.GetGraphicFont(Name: String): TsgeGraphicFont;
begin
  Result := TsgeGraphicFont(FResources.TypedObj[Name, rtGraphicFont]);
  if Result = nil then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_GetGraphicFont_FontNotFound + Err_Separator + Name);
    Result := FDefGraphicFont;
    end;
end;


function TSimpleGameEngine.GetSoundBuffer(Name: String): TsgeSoundBuffer;
begin
  Result := TsgeSoundBuffer(FResources.TypedObj[Name, rtSoundBuffer]);
  if Result = nil then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_GetSoundBuffer_BufferNotFound + Err_Separator + Name);
    Result := FDefSoundBuffer;
    end;
end;


function TSimpleGameEngine.GetGraphicFrames(Name: String): TsgeGraphicFrames;
begin
  Result := TsgeGraphicFrames(FResources.TypedObj[Name, rtGraphicFrames]);
  if Result = nil then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_GetGraphicFrames_FramesNotFound + Err_Separator + Name);
    Result := FDefGraphicFrames;
    end;
end;


function TSimpleGameEngine.GetParameters(Name: String): TsgeParameters;
begin
  Result := TsgeParameters(FResources.TypedObj[Name, rtParameters]);
  if Result = nil then
    begin
    ProcessError(Err_SGE + Err_Separator + Err_SGE_GetParameters_ParametersNotFound + Err_Separator + Name);
    Result := FParameters;
    end;
end;


procedure TSimpleGameEngine.FadeStart(Mode: TsgeFadeMode; Color: TsgeGraphicColor; Time: Cardinal);
begin
  FFade.Start(Mode, Color, Time);
end;


procedure TSimpleGameEngine.FadeStop;
begin
  FFade.Stop;
end;


procedure TSimpleGameEngine.Stop;
begin
  SetTickEnable(False);
  SetJoysticksEnable(False);
  _AppWorking := False;
end;


procedure TSimpleGameEngine.Run;
begin
  while _AppWorking do
    begin
    ProcessMessage;
    ProcessDraw;
    end;
end;


procedure TSimpleGameEngine.Tick;
begin
end;


procedure TSimpleGameEngine.Draw;
begin
end;


function TSimpleGameEngine.CloseWindow: Boolean;
begin
  Result := True;
end;


procedure TSimpleGameEngine.LostWindowFocus;
begin
end;


procedure TSimpleGameEngine.SetWindowFocus;
begin
end;


procedure TSimpleGameEngine.ShowWindow;
begin
end;


procedure TSimpleGameEngine.HideWindow;
begin
end;


procedure TSimpleGameEngine.ResizeWindow;
begin
end;


procedure TSimpleGameEngine.ResizingWindow;
begin
end;


procedure TSimpleGameEngine.ActivateWindow;
begin
end;


procedure TSimpleGameEngine.DeactivateWindow;
begin
end;


procedure TSimpleGameEngine.MouseLeave;
begin
end;


procedure TSimpleGameEngine.MouseReturn;
begin
end;


procedure TSimpleGameEngine.JoystickInput;
begin
end;


procedure TSimpleGameEngine.JoystickScan;
begin
end;


procedure TSimpleGameEngine.KeyChar(Key: Char; KeyboardButtons: TsgeKeyboardButtons);
begin
end;


procedure TSimpleGameEngine.KeyDown(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);
begin
end;


procedure TSimpleGameEngine.KeyUp(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);
begin
end;


procedure TSimpleGameEngine.MouseDown(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
begin
end;


procedure TSimpleGameEngine.MouseUp(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
begin
end;


procedure TSimpleGameEngine.MouseMove(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
begin
end;


procedure TSimpleGameEngine.MouseDoubleClick(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
begin
end;


procedure TSimpleGameEngine.MouseScroll(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons; Delta: Integer);
begin
end;




end.



