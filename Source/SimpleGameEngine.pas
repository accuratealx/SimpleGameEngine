{
Пакет             Simple Game Engine 1
Файл              SimpleGameEngine.pas
Версия            1.19
Создан            07.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Главный класс движка
}

unit SimpleGameEngine;

{$mode objfpc}{$H+}

interface

uses
  StringArray,
  sgeConst, sgeTypes, sgeParameters, sgeStartParameters, sgeWindow, sgeJournal, sgeGraphic, sgeEvent,
  sgeResources, sgeSystemIcon, sgeSystemCursor, sgeGraphicSprite, sgeGraphicFont,
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

  //Режим обработки сообщения
  TsgeMessageMode = (mmShell, mmCommand, mmNormal);

  //Режим клавиш нажатие/отпускание
  TsgeCommandKeyMethod = (ckmUp, ckmDowm);


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
    FDrawCurrentTime: Int64;                                                            //Время текущего вывода графики
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
    function  GetLocalizedErrorString(ErrorString: String): String;                     //Вернуть подготовленную строку ошибки с учётом языка
    procedure SetMouseTrackEvent;                                                       //Запустить слежение за нестандартными сообщениями мыши
    procedure CorrectViewport;                                                          //Изменить область вывода графики
    procedure CorrectShellVisibleLines;                                                 //Поправить количетво видимых линий в оболочке
    function  GetKeyboardButtons: TsgeKeyboardButtons;                                  //Определить функциональные клавиши
    function  GetMouseButtons(wParam: WPARAM): TsgeMouseButtons;                        //Узнать нажатые клавиши
    function  GetMouseScrollDelta(wParam: WPARAM): Integer;                             //Определить значение прокрутки
    procedure SendTranslateMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM);          //Послать самому себе сообщение WM_Char
    function  GetMessageMode(Key: Byte; Method: TsgeCommandKeyMethod): TsgeMessageMode; //Определить режим обработки сообщений
    function  GetMouseKeyIdx(wParam: WPARAM): Byte;                                     //Определить индекс кнопки

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


const
  _UNITNAME = 'SGE';


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
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantChangePriority));
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
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_CantReadPriority));
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
        raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantChangeDrawControl), E.Message));
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
        raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantChangeDebug), E.Message));
    end;
    end else FJournal.Enable := False;
end;


function TSimpleGameEngine.GetLocalizedErrorString(ErrorString: String): String;
var
  aUnitName, aErrorMessage, aInfo: String;
begin
  sgeDecodeErrorString(ErrorString, aUnitName, aErrorMessage, aInfo); //Разобрать строку на части
  FShell.Language.GetString('Unit:' + aUnitName, aUnitName);          //Найти имя модуля
  FShell.Language.GetString('Error:' + aErrorMessage, aErrorMessage); //Найти информацию об ошибке

  Result := aUnitName + ': ' + aErrorMessage;
  if aInfo <> '' then Result := Result + ' (' + aInfo + ')';
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


procedure TSimpleGameEngine.CorrectShellVisibleLines;
var
  i: Integer;
begin
  if FWindow.ViewMode = wvmMinimize then Exit;

  i := sgeGetShellMaxVisibleLines(FWindow.ClientHeight, FShellFont.Height);
  if FShell.VisibleLines > i then FShell.VisibleLines := i;
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


procedure TSimpleGameEngine.SendTranslateMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM);
var
  Message: TMSG;
begin
  Message.hwnd := FWindow.Handle;
  Message.message := Msg;
  Message.wParam := wParam;
  Message.lParam := lParam;
  TranslateMessage(Message);
end;


function TSimpleGameEngine.GetMessageMode(Key: Byte; Method: TsgeCommandKeyMethod): TsgeMessageMode;
begin
  Result := mmNormal;

  case Method of
    ckmUp   : if FShell.KeyTable.Key[Key].Up <> '' then Result := mmCommand;
    ckmDowm : if FShell.KeyTable.Key[Key].Down <> '' then Result := mmCommand;
  end;

  if FShell.Enable then Result := mmShell;
end;


function TSimpleGameEngine.GetMouseKeyIdx(wParam: WPARAM): Byte;
begin
  Result := sgeGetMouseButtonIdx(GetMouseButtons(wParam));
end;


procedure TSimpleGameEngine.ProcessMessage;
begin
  while PeekMessage(_MSG, 0, 0, 0, PM_REMOVE) do
    case _MSG.message of

      WM_LBUTTONUP:
        begin
        _MSG.wParam := MK_LBUTTON;
        DispatchMessage(_MSG);
        end;

      WM_MBUTTONUP:
        begin
        _MSG.wParam := MK_MBUTTON;
        DispatchMessage(_MSG);
        end;

      WM_RBUTTONUP:
        begin
        _MSG.wParam := MK_RBUTTON;
        DispatchMessage(_MSG);
        end;

      WM_XBUTTONUP:
        begin
        if SmallInt(HIWORD(_MSG.wParam)) = 1 then _MSG.wParam := MK_XBUTTON1 else _MSG.wParam := MK_XBUTTON2;
        DispatchMessage(_MSG);
        end;

      else DispatchMessage(_MSG);
    end;
end;


procedure TSimpleGameEngine.DrawShell;
var
  shWidth, shHeight, lnHeight, X, Y, X2, Y2, i: Integer;
  Rct: TsgeRect;
  Interval: TsgeInterval;
begin
  //Подготовить графику
  FGraphic.Reset;
  FGraphic.PushAttrib;
  FGraphic.PoligonMode := gpmFill;
  FGraphic.LineWidth := 1;
  FGraphic.Capabilities[gcLineSmooth] := False;
  FGraphic.Capabilities[gcColorBlend] := True;

  //Размеры оболочки
  lnHeight := FShellFont.Height;             //Высота строки
  shWidth := FWindow.ClientWidth;               //Ширина окна
  shHeight := (FShell.VisibleLines * lnHeight) + lnHeight + sge_ShellIndent * 3;

  //Вывод фонового цвета
  FGraphic.Color := FShell.BGColor;
  FGraphic.DrawRect(0, 0, shWidth, shHeight);

  //Вывод Фоновай картинки
  if FShell.BGSprite <> nil then
    begin
    FGraphic.Capabilities[gcTexture] := True;
    Rct := sgeGetShellBGRect(shWidth, shHeight, FShell.BGSprite.Width, FShell.BGSprite.Height);
    FGraphic.DrawSpritePart(0, 0, shWidth, shHeight, Rct.X1, Rct.Y1, Rct.X2, Rct.Y2, FShell.BGSprite, gdmClassic);
    FGraphic.Capabilities[gcTexture] := False;
    end;

  //Вывод строки редактора
  X := sge_ShellIndent;
  Y := shHeight - sge_ShellIndent - lnHeight;
  FGraphic.Color := FShell.EditorColor;
  FGraphic.DrawText(X, Y, FShellFont, FShell.Editor.Line);

  //Координаты курсора и выделения
  Y := shHeight - sge_ShellIndent - lnHeight + 2;
  Y2 := shHeight - sge_ShellIndent + 2;

  //Выделение строки редактора
  if FShell.Editor.SelectCount > 0 then
    begin
    X := sge_ShellIndent + FShellFont.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.SelectBeginPos));
    X2 := sge_ShellIndent + FShellFont.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.SelectEndPos));
    FGraphic.Color := FShell.SelectColor;
    FGraphic.DrawRect(X, Y, X2, Y2, gdmClassic);
    end;

  //Курсор строки редактора
  X := sge_ShellIndent + FShellFont.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.CursorPos));
  FGraphic.Color := FShell.CursorColor;
  FGraphic.DrawLine(X, Y, X, Y2);

  //Журнал
  if FShell.Journal.Count > 0 then
    begin
    X := sge_ShellIndent;
    Y := shHeight - lnHeight * 2 - sge_ShellIndent * 2;
    Interval := FShell.GetJournalInterval;
    for i := Interval.iBegin downto Interval.iEnd do
      begin
      FGraphic.Color := FShell.Journal.Line[i].Color;
      FGraphic.DrawText(X, Y, FShellFont, FShell.Journal.Line[i].Text);
      Dec(Y, lnHeight);
      end;
    end;

  //Восстановить графику
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
  Idx: Byte;
  Delta: Integer;
  KeyMethod: TsgeCommandKeyMethod;
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
      CorrectShellVisibleLines;
      ResizeWindow;
      end;

    WM_SIZING:
      begin
      CorrectShellVisibleLines;
      ResizingWindow;
      end;

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
      if FShell.Enable then FShell.KeyChar(chr(wParam), GetKeyboardButtons) else KeyChar(chr(wParam), GetKeyboardButtons);

    WM_KEYDOWN, WM_SYSKEYDOWN:
      case GetMessageMode(wParam, ckmDowm) of
        mmCommand:
          if (lParam shr 30 <> 1) then FShell.DoCommand(FShell.KeyTable.Key[wParam].Down);
        mmShell:
          begin
          SendTranslateMessage(Msg, wParam, lParam);
          FShell.KeyDown(wParam, GetKeyboardButtons);
          end;
        mmNormal:
          begin
          SendTranslateMessage(Msg, wParam, lParam);
          KeyDown(wParam, GetKeyboardButtons);
          end;
      end;

    WM_KEYUP, WM_SYSKEYUP:
      case GetMessageMode(wParam, ckmUp) of
        mmCommand: FShell.DoCommand(FShell.KeyTable.Key[wParam].Up);
        mmShell  : ;
        mmNormal : KeyUp(wParam, GetKeyboardButtons);
      end;

    WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN, WM_XBUTTONDOWN:
      begin
      Idx := GetMouseKeyIdx(wParam);
      case GetMessageMode(Idx, ckmDowm) of
        mmCommand: FShell.DoCommand(FShell.KeyTable.Key[Idx].Down);
        mmShell  : FShell.MouseDown(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons);
        mmNormal : MouseDown(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons);
      end;
      end;

    WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
      begin
      Idx := GetMouseKeyIdx(wParam);
      case GetMessageMode(Idx, ckmUp) of
        mmCommand: FShell.DoCommand(FShell.KeyTable.Key[Idx].Up);
        mmShell  : ;
        mmNormal : MouseUp(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons);
      end;
      end;

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
      begin
      Idx := GetMouseKeyIdx(wParam);
      case GetMessageMode(Idx, ckmDowm) of
        mmCommand: FShell.DoCommand(FShell.KeyTable.Key[Idx].Down);
        mmShell  : FShell.MouseDown(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons);
        mmNormal : MouseDoubleClick(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons);
      end;
      end;

    WM_MOUSEWHEEL:
      begin
      Delta := GetMouseScrollDelta(wParam);
      if Delta > 0 then KeyMethod := ckmUp else KeyMethod := ckmDowm;
      case GetMessageMode(5, KeyMethod) of
        mmCommand:
          case KeyMethod of
            ckmUp  : FShell.DoCommand(FShell.KeyTable.Key[5].Up);
            ckmDowm: FShell.DoCommand(FShell.KeyTable.Key[5].Down);
          end;
        mmShell  : FShell.MouseScroll(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons, GetMouseScrollDelta(wParam));
        mmNormal : MouseScroll(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam), GetMouseButtons(wParam), GetKeyboardButtons, GetMouseScrollDelta(wParam));
      end;
      end;

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
  FJournal := TsgeJournal.Create('');                                       //Журналирование
  FStartParameters := TsgeStartParameters.Create;                           //Стартовые параметры
  FParameters := TsgeParameters.Create;                                     //Настройки
  FShell := TsgeShell.Create(FParameters, @ProcessError);                   //Оболочка
  FResources := TsgeResources.Create;                                       //Хранилище ресурсов
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
    if LogS then if i = 0 then FShell.LogMessage(Str, sltError) else FShell.LogMessage('  ' + Str, sltNote);
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
    FShell.LoadLanguage(FileName, Mode);
  except
    on E:EsgeException do
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantLoadLanguage), E.Message));
  end;
end;


procedure TSimpleGameEngine.InitWindow;
begin
  try
    FWindow := TsgeWindow.Create(SGE_Name + SGE_Version, '', 100, 100, 800, 600);
    FWindow.SetWindowProc(@sgeWndProc);
    SetMouseTrackEvent;
  except
    on E: EsgeException do
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantInitWindow), E.Message));
  end;
end;


procedure TSimpleGameEngine.InitGraphic;
var
  gf: TsgeGraphicFrameArray;
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
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantInitGraphic), E.Message));
  end;
end;


procedure TSimpleGameEngine.InitSound;
begin
  try
    FSound := TsgeSound.Create;
    FDefSoundBuffer := TsgeSoundBuffer.CreateBlank;
  except
    on E: EsgeException do
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantInitSound), E.Message));
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
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantLoadParameters), E.Message));
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
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantSaveParameters), E.Message));
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
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_WindowNotInitialized, Name));

  Ico := nil;
  try
    case From of
      lfHinstance:
        begin
        FDefSystemIcon.LoadFromHinstance(Name);
        Ico := FDefSystemIcon;
        end;

      lfResource:
        begin
        Ico := TsgeSystemIcon(FResources.TypedObj[Name, rtSystemIcon]);
        if Ico = nil then
          raise EsgeException.Create(sgeCreateErrorString('sgeSystemIcon', Err_CantLoadFromResource, Name));
        end;

      lfFile:
        begin
        FDefSystemIcon.LoadFromFile(Name);
        Ico := FDefSystemIcon;
        end;
    end;
  except
    on E: EsgeException do
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantLoadAppIcon), E.Message));
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
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_WindowNotInitialized, Name));

  Cur := nil;
  try
    case From of
      lfHinstance:
        begin
        FDefSystemCursor.LoadFromHinstance(Name);
        Cur := FDefSystemCursor;
        end;

      lfResource:
        begin
        Cur := TsgeSystemCursor(FResources.TypedObj[Name, rtSystemCursor]);
        if Cur = nil then
          raise EsgeException.Create(sgeCreateErrorString('sgeSystemCursor', Err_CantLoadFromResource, Name));
        end;

      lfFile:
        begin
        FDefSystemCursor.LoadFromFile(Name);
        Cur := FDefSystemCursor;
        end;
    end;
  except
    on E: EsgeException do
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantLoadAppCursor), E.Message));
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
    raise EsgeException.Create(sgeCreateErrorString(_UNITNAME, Err_GraphicNotInitialized));

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
      raise EsgeException.Create(sgeFoldErrorString(sgeCreateErrorString(_UNITNAME, Err_CantCreateScreenShot), E.Message));
  end;
end;


procedure TSimpleGameEngine.LoadResourcesFromTable(FileName: String; Mode: TsgeLoadMode);
begin
  if Mode = lmReplace then FResources.Clear;
  FResources.LoadFromTable(FileName);
end;


function TSimpleGameEngine.GetGraphicSprite(Name: String): TsgeGraphicSprite;
begin
  Result := TsgeGraphicSprite(FResources.TypedObj[Name, rtGraphicSprite]);
  if Result = nil then
    begin
    ProcessError(sgeCreateErrorString(_UNITNAME, Err_SpriteNotFound, Name));
    Result := FDefGraphicSprite;
    end;
end;


function TSimpleGameEngine.GetGraphicFont(Name: String): TsgeGraphicFont;
begin
  Result := TsgeGraphicFont(FResources.TypedObj[Name, rtGraphicFont]);
  if Result = nil then
    begin
    ProcessError(sgeCreateErrorString(_UNITNAME, Err_FontNotFound, Name));
    Result := FDefGraphicFont;
    end;
end;


function TSimpleGameEngine.GetSoundBuffer(Name: String): TsgeSoundBuffer;
begin
  Result := TsgeSoundBuffer(FResources.TypedObj[Name, rtSoundBuffer]);
  if Result = nil then
    begin
    ProcessError(sgeCreateErrorString(_UNITNAME, Err_BufferNotFound, Name));
    Result := FDefSoundBuffer;
    end;
end;


function TSimpleGameEngine.GetGraphicFrames(Name: String): TsgeGraphicFrames;
begin
  Result := TsgeGraphicFrames(FResources.TypedObj[Name, rtGraphicFrames]);
  if Result = nil then
    begin
    ProcessError(sgeCreateErrorString(_UNITNAME, Err_FramesNotFound, Name));
    Result := FDefGraphicFrames;
    end;
end;


function TSimpleGameEngine.GetParameters(Name: String): TsgeParameters;
begin
  Result := TsgeParameters(FResources.TypedObj[Name, rtParameters]);
  if Result = nil then
    begin
    ProcessError(sgeCreateErrorString(_UNITNAME, Err_ParametersNotFound, Name));
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



