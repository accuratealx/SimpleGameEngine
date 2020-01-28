{
Пакет             Simple Game Engine 1
Файл              SimpleGameEngine.pas
Версия            1.19.10
Создан            07.06.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Главный класс движка
}

unit SimpleGameEngine;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes, sgeSimpleParameters, sgeStartParameterList, sgeWindow, sgeJournal,
  sgeEvent, sgeSystemIcon, sgeSystemCursor, sgeResourceList, sgeCounter, sgeShell,
  sgeFade, sgeGraphic, sgeGraphicColor, sgeGraphicSprite, sgeGraphicFont,
  sgeGraphicFrameList, sgeGraphicAnimation, sgeJoystickList, sgeSound, sgeSoundBuffer,
  sgeShellFunctions, sgeFileSystem, sgeTaskList,
  Windows, Classes;


type
  //Режимы загрузки (Ресурсы приложения, Хранилище ресурсов, Файл)
  TsgeLoadFrom = (lfHinstance, lfFile);

  //Тип диалогового окна
  TsgeMessageType = (mtError, mtInfo);

  //Режим ограничения кадров (Вертикальная синхронизация, Програмный способ)
  TsgeDrawControl = (dcSync, dcProgram);

  //Способ опроса клавиш клавиатуры
  TsgeKeyDownMethod = (kdmNormal, kdmAlways);

  //Режим обработки сообщения
  TsgeMessageMode = (mmShell, mmCommand, mmNormal);

  //Режим клавиш нажатие/отпускание
  TsgeCommandKeyMethod = (ckmUp, ckmDowm);


  TSimpleGameEngine = class(TPersistent)
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
    FDrawLastTime: Int64;                                                               //Время прошлого вывода графики
    FDrawCurrentTime: Int64;                                                            //Время текущего вывода графики
    FDrawDelay: Int64;                                                                  //Задержка между выводами графики в тиках процессора
    FMaxFramesPerSecond: Word;                                                          //Максимально кадров в секунду
    FAutoEraseBG: Boolean;                                                              //Автоочистка фона перед рисованием
    FCursorPos: Tsgepoint;                                                              //Координаты курсора
    FAutoScanJoysticks: Boolean;                                                        //Сканирование джойстиков при подключении

    FFileSystem: TsgeFileSystem;                                                        //Файловая система с поддержкой архивов
    FStartParameters: TsgeStartParameterList;                                           //Стартовые параметры
    FParameters: TsgeSimpleParameters;                                                  //Массив с параметрами
    FJournal: TsgeJournal;                                                              //Система протоколирования
    FWindow: TsgeWindow;                                                                //Главное окно
    FGraphic: TsgeGraphic;                                                              //OpenGL
    FSound: TsgeSound;                                                                  //Звук
    FResources: TsgeResourceList;                                                       //Хранилище ресурсов
    FTaskList: TsgeTaskList;                                                            //Список задач
    FTaskEvent: TsgeEvent;                                                              //Таймер обработки задач
    FFPSCounter: TsgeCounter;                                                           //Счётчик кадров
    FShell: TsgeShell;                                                                  //Оболочка
    FJoysticks: TsgeJoystickList;                                                       //Хранилище джойстиков
    FJoystickEvent: TsgeEvent;                                                          //Таймер опроса джойстиков
    FFade: TsgeFade;                                                                    //Затемнение экрана
    FLanguage: TsgeSimpleParameters;                                                    //Таблица языка

    FDefSystemIcon: TsgeSystemIcon;                                                     //Иконка приложения
    FDefSystemCursor: TsgeSystemCursor;                                                 //Курсор приложения
    FDefGraphicSprite: TsgeGraphicSprite;                                               //Графический спрайт по умолчанию
    FDefGraphicFont: TsgeGraphicFont;                                                   //Графический шрифт по умолчанию
    FDefSoundBuffer: TsgeSoundBuffer;                                                   //Звуковой буфер по умолчанию
    FDefGraphicFrames: TsgeGraphicFrameList;                                            //Кадры анимации по умолчанию
    FDefGraphicAnimation: TsgeGraphicAnimation;                                         //Анимация по умолчанию

    procedure SetPriority(APriotity: TsgePriority);                                     //Изменить приоритет процесса
    function  GetPriority: TsgePriority;                                                //Узнать приоритет процесса

    procedure SetJoysticksDelay(ADelay: Cardinal);                                      //Задать задержку опросов джойстиков
    function  GetJoysticksDelay: Cardinal;                                              //Узнать задержку джойстиков
    procedure SetJoysticksEnable(AEnable: Boolean);                                     //Запустить работу джойстиков
    function  GetJoysticksEnable: Boolean;                                              //Узнать работу джойстиков

    procedure SetTaskEnable(AEnable: Boolean);                                          //Запустить обработку задач
    function  GetTaskEnable: Boolean;                                                   //Узнать состояние обработчика задач
    procedure SetTaskDelay(ADelay: Cardinal);                                           //Установить задержку между опросами задач
    function  GetTaskDelay: Cardinal;                                                   //Узнать задержку между опросами задач

    procedure SetDrawControl(AMetod: TsgeDrawControl);                                  //Изменить метод контроля кадров
    procedure SetMaxFramesPerSecond(ACount: Word);                                      //Изменить потолок кадров в секунду
    function  GetFramesPerSecond: Cardinal;                                             //Узнать счётчик кадров
    function  GetStrFramesPerSecond: String;                                            //Узнать счётчик кадров в виде строки

    procedure SetDirMain(ADir: String);                                                 //Изменить каталог системы
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

    procedure SendTranslateMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM);          //Послать оконной функции сообщение WM_Char
    procedure TaskManager;                                                              //Диспетчер задач
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
    constructor Create(InitSound: Boolean = False); virtual;
    destructor  Destroy; override;

    procedure LogError(Msg: String; MessageType: TsgeMessageType = mtError);            //Обработать ошибку
    procedure ShowMessage(Msg: String; AType: TsgeMessageType = mtError);               //Вывод диолгового окна
    function  IsKeyDown(Key: Integer; Method: TsgeKeyDownMethod = kdmNormal): Boolean;  //Узнать нажата ли клавиша
    procedure LoadLanguage(FileName: String; Mode: TsgeLoadMode = lmReplace);           //Загрузить язык
    procedure LoadPackFromDirectory(Directory: String = ''; Ext: String = sge_ExtPack); //Добавить архивы в систему из папки

    procedure LoadParameters(FileName: String);                                         //Загрузка параметров из файла
    procedure SaveParameters(FileName: String);                                         //Сохранить параметры в файл
    procedure OverrideParameters;                                                       //Переопределить параметры из командной строки
    procedure LoadAppIcon(Name: String; From: TsgeLoadFrom = lfHinstance);              //Изменить иконку
    procedure LoadAppCursor(Name: String; From: TsgeLoadFrom = lfHinstance);            //Изменить курсор
    procedure FullScreen;                                                               //Переход в полноэкранный режим
    procedure Screenshot(FileName: String = '');                                        //Снимок окна

    procedure LoadResourcesFromTable(FileName: String; Mode: TsgeLoadMode = lmAdd);     //Загрузка ресурсов по таблице
    function  GetGraphicSprite(Name: String): TsgeGraphicSprite;                        //Безопасная загрузка графического спрайта
    function  GetGraphicFont(Name: String): TsgeGraphicFont;                            //Безопасная загрузка графического шрифта
    function  GetSoundBuffer(Name: String): TsgeSoundBuffer;                            //Безопасная загрузка звукового буфера
    function  GetGraphicFrames(Name: String): TsgeGraphicFrameList;                     //Безопасная загрузка кадров анимации
    function  GetGraphicAnimation(Name: String): TsgeGraphicAnimation;                  //Безопасная загрузка анимации
    function  GetParameters(Name: String): TsgeSimpleParameters;                        //Безопасная загрузка таблицы параметров

    procedure FadeStart(Mode: TsgeFadeMode; Color: TsgeGraphicColor; Time: Cardinal);   //Запустить затемнение
    procedure FadeStop;                                                                 //Остановка затемнения
    procedure FadePassTime(Time: TsgeFadePassedTime); virtual;                          //События затемнения

    procedure Stop;                                                                     //Прибить бесконечный цикл
    procedure Run; virtual;                                                             //Бесконечный цикл
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

    property Priority: TsgePriority read GetPriority write SetPriority;
    property TaskEnable: Boolean read GetTaskEnable write SetTaskEnable;
    property TaskDelay: Cardinal read GetTaskDelay write SetTaskDelay;
    property JoysticksDelay: Cardinal read GetJoysticksDelay write SetJoysticksDelay;
    property JoysticksEnable: Boolean read GetJoysticksEnable write SetJoysticksEnable;
    property DrawControl: TsgeDrawControl read FDrawControl write SetDrawControl;
    property DrawEnable: Boolean read FDrawEnable write FDrawEnable;
    property MaxFPS: Word read FMaxFramesPerSecond write SetMaxFramesPerSecond;
    property FPS: Cardinal read GetFramesPerSecond;
    property StrFps: String read GetStrFramesPerSecond;
    property AutoEraseBG: Boolean read FAutoEraseBG write FAutoEraseBG;
    property CursorPos: Tsgepoint read FCursorPos;
    property AutoScanJoysticks: Boolean read FAutoScanJoysticks write FAutoScanJoysticks;

    property FileSystem: TsgeFileSystem read FFileSystem;
    property Shell: TsgeShell read FShell;
    property StartParameters: TsgeStartParameterList read FStartParameters;
    property Parameters: TsgeSimpleParameters read FParameters;
    property Journal: TsgeJournal read FJournal;
    property Window: TsgeWindow read FWindow;
    property Graphic: TsgeGraphic read FGraphic;
    property Sound: TsgeSound read FSound;
    property Resources: TsgeResourceList read FResources;
    property TaskList: TsgeTaskList read FTaskList;
    property Joysticks: TsgeJoystickList read FJoysticks;
    property Language: TsgeSimpleParameters read FLanguage;

    property DefSystemIcon: TsgeSystemIcon read FDefSystemIcon;
    property DefSystemCursor: TsgeSystemCursor read FDefSystemCursor;
    property DefGraphicSprite: TsgeGraphicSprite read FDefGraphicSprite;
    property DefGraphicFont: TsgeGraphicFont read FDefGraphicFont;
    property DefGraphicFrames: TsgeGraphicFrameList read FDefGraphicFrames;
    property DefGraphicAnimation: TsgeGraphicAnimation read FDefGraphicAnimation;
    property DefSoundBuffer: TsgeSoundBuffer read FDefSoundBuffer;
  end;



implementation

uses
  sgeObjectList, sgeStringList, sgeMemoryStream, sgeTask,
  SysUtils;


const
  _UNITNAME = 'SGE';
  WM_SGETASK = WM_USER + 1;


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
  mode := $20;

  case APriotity of
    pIdle       : mode := $40;   //IDLE_PRIORITY_CLASS
    pBelowNormal: mode := $4000; //BELOW_NORMAL_PRIORITY_CLASS
    pNormal     : mode := $20;   //NORMAL_PRIORITY_CLASS
    pAboveNormal: mode := $8000; //ABOVE_NORMAL_PRIORITY_CLASS
    pHigh       : mode := $80;   //HIGH_PRIORITY_CLASS
    pRealTime   : mode := $100;  //REALTIME_PRIORITY_CLASS
  end;

  if not SetPriorityClass(GetCurrentProcess, mode) then
    raise EsgeException.Create(_UNITNAME, Err_CantChangePriority);
end;


{$Warnings Off}
function TSimpleGameEngine.GetPriority: TsgePriority;
var
  mode: DWORD;
begin
  mode := GetPriorityClass(GetCurrentProcess);

  if mode = 0 then
    raise EsgeException.Create(_UNITNAME, Err_CantReadPriority);

  case mode of
    $40   : Result := pIdle;        //IDLE_PRIORITY_CLASS
    $4000 : Result := pBelowNormal; //BELOW_NORMAL_PRIORITY_CLASSend;
    $20   : Result := pNormal;      //NORMAL_PRIORITY_CLASS      d;
    $8000 : Result := pAboveNormal; //ABOVE_NORMAL_PRIORITY_CLASS
    $80   : Result := pHigh;        //HIGH_PRIORITY_CLASS
    $100  : Result := pRealTime;    //REALTIME_PRIORITY_CLASS
  end;
end;
{$Warnings On}


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


procedure TSimpleGameEngine.SetTaskEnable(AEnable: Boolean);
begin
  FTaskEvent.Enable := AEnable;
end;


function TSimpleGameEngine.GetTaskEnable: Boolean;
begin
  Result := FTaskEvent.Enable;
end;


procedure TSimpleGameEngine.SetTaskDelay(ADelay: Cardinal);
begin
  FTaskEvent.Delay := ADelay;
end;


function TSimpleGameEngine.GetTaskDelay: Cardinal;
begin
  Result := FTaskEvent.Delay;
end;


procedure TSimpleGameEngine.SetDrawControl(AMetod: TsgeDrawControl);
begin
  FDrawControl := AMetod;
  if FGraphic <> nil then
    try
      FGraphic.VerticalSync := (FDrawControl = dcSync);
    except
      on E:EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_CantChangeDrawControl, '', E.Message);
    end;
end;


procedure TSimpleGameEngine.SetMaxFramesPerSecond(ACount: Word);
begin
  if ACount = 0 then ACount := 1;

  FMaxFramesPerSecond := ACount;
  FDrawDelay := Round(OneSecondFrequency / FMaxFramesPerSecond);
end;


function TSimpleGameEngine.GetFramesPerSecond: Cardinal;
begin
  Result := FFPSCounter.Count;
end;


function TSimpleGameEngine.GetStrFramesPerSecond: String;
begin
  Result := FFPSCounter.StrCount;
end;


procedure TSimpleGameEngine.SetDirMain(ADir: String);
begin
  ADir := IncludeTrailingBackslash(ADir);
  if FDirMain = ADir then Exit;

  FDirMain := ADir;
  FFileSystem.MainDir := FDirMain;
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
begin
  if FDebug = AEnable then Exit;
  FDebug := AEnable;

  if FDebug then
    try
      FJournal.FileName := FDirJournal + sgeGetUniqueFileName + '.' + sge_ExtJournal;
      FJournal.Enable := True;
    except
      raise EsgeException.Create(_UNITNAME, Err_CantEnableDebug);
    end
    else FJournal.Enable := False;
end;


function TSimpleGameEngine.GetLocalizedErrorString(ErrorString: String): String;
var
  aUnitName, aErrorMessage, aInfo: String;
  Line: TsgeStringList;
begin
  //Создать список
  Line := TsgeStringList.Create;
  Line.Separator := ';';

  //Разобрать строку
  Line.FromString(ErrorString);

  //Выделить части
  if Line.Count >= 1 then aUnitName := Line.Part[0] else aUnitName := '';
  if Line.Count >= 2 then aErrorMessage := Line.Part[1] else aErrorMessage := '';
  if Line.Count >= 3 then aInfo := Line.Part[2] else aInfo := '';

  //Найти языковое представление
  if aUnitName <> '' then
    aUnitName := FLanguage.GetValue('Unit:' + aUnitName, aUnitName);

  if aErrorMessage <> '' then
    aErrorMessage := FLanguage.GetValue('Error:' + aErrorMessage, aErrorMessage);

  //Подготовить результат
  Result := aUnitName;
  if aErrorMessage <> '' then Result := Result + ': ' + aErrorMessage;
  if aInfo <> '' then Result := Result + ' (' + aInfo + ')';

  //Удалить список
  Line.Free;
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

  i := sgeGetShellMaxVisibleLines(FWindow.Height, FShell.Font.Height);
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

  wParam := LOWORD(wParam);

  if (wParam and MK_LBUTTON) = MK_LBUTTON then Include(Result, mbLeft);
  if (wParam and MK_MBUTTON) = MK_MBUTTON then Include(Result, mbMiddle);
  if (wParam and MK_RBUTTON) = MK_RBUTTON then Include(Result, mbRight);
  if (wParam and MK_XBUTTON1) = MK_XBUTTON1 then Include(Result, mbExtra1);
  if (wParam and MK_XBUTTON2) = MK_XBUTTON2 then Include(Result, mbExtra2);
end;


function TSimpleGameEngine.GetMouseScrollDelta(wParam: WPARAM): Integer;
begin
  Result := SmallInt(HIWORD(wParam)) div 120;
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


procedure TSimpleGameEngine.TaskManager;
var
  i, Cnt: Integer;
  Task: TsgeTask;
begin
  i := -1;
  while i < FTaskList.Count - 1 do
    begin
    Inc(i);

    //Получить указатель
    Task := FTaskList.Task[i];

    //Определить количество срабатываний
    Cnt := Task.GetExecuteCount;

    //Отправить событие срабатывания задачи
    if Cnt <> 0 then SendMessage(FWindow.Handle, WM_SGETASK, i, Cnt);

    //Проверить на автозавершение задачи
    if Task.AutoDelete and (Task.Count >= Task.Times) then
      begin
      FTaskList.Delete(i);
      Dec(i);
      end;
    end;
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
  FGraphic.State[gsTexture] := False;
  FGraphic.State[gsLineSmooth] := False;
  FGraphic.State[gsColorBlend] := True;

  //Размеры оболочки
  lnHeight := FShell.Font.Height;
  shWidth := FWindow.Width;
  shHeight := (FShell.VisibleLines * lnHeight) + lnHeight + sge_ShellIndent * 3;

  //Вывод фонового цвета
  FGraphic.Color := FShell.BGColor;
  FGraphic.DrawRect(0, 0, shWidth, shHeight);

  //Вывод Фоновой картинки
  if FShell.BGSprite <> nil then
    begin
    FGraphic.State[gsTexture] := True;
    Rct := sgeGetShellBGRect(shWidth, shHeight, FShell.BGSprite.Width, FShell.BGSprite.Height);
    FGraphic.DrawSpritePart(0, 0, shWidth, shHeight, Rct.X1, Rct.Y1, Rct.X2, Rct.Y2, FShell.BGSprite, gdmClassic);
    FGraphic.State[gsTexture] := False;
    end;

  //Вывод строки редактора
  X := sge_ShellIndent;
  Y := shHeight - sge_ShellIndent - lnHeight;
  FGraphic.Color := FShell.EditorColor;
  FGraphic.DrawText(X, Y, FShell.Font, FShell.Editor.Line);

  //Координаты курсора и выделения
  Y := shHeight - sge_ShellIndent - lnHeight + 2;
  Y2 := shHeight - sge_ShellIndent + 2;

  //Выделение строки редактора
  if FShell.Editor.SelectCount > 0 then
    begin
    X := sge_ShellIndent + FShell.Font.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.SelectBeginPos));
    X2 := sge_ShellIndent + FShell.Font.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.SelectEndPos));
    FGraphic.Color := FShell.SelectColor;
    FGraphic.DrawRect(X, Y, X2, Y2, gdmClassic);
    end;

  //Курсор строки редактора
  X := sge_ShellIndent + FShell.Font.GetStringWidth(FShell.Editor.GetTextBeforePos(FShell.Editor.CursorPos));
  FGraphic.Color := FShell.CursorColor;
  FGraphic.DrawLine(X, Y, X, Y2);

  //Журнал
  if FShell.Journal.Count > 0 then
    begin
    X := sge_ShellIndent;
    Y := shHeight - lnHeight * 2 - sge_ShellIndent * 2;
    Interval := FShell.GetJournalInterval;
    for i := Interval.Start downto Interval.Stop do
      begin
      FGraphic.Color := FShell.Journal.Line[i].Color;
      FGraphic.DrawText(X, Y, FShell.Font, FShell.Journal.Line[i].Text);
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
  FGraphic.State[gsColorBlend] := True;

  //Вывод
  FGraphic.Color := FFade.GetColor;
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
    WM_SGETASK:
      for Idx := 0 to lParam - 1 do
        FTaskList.Task[wParam].Execute;


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
          case FShell.ScanMode of
            True :
              if (lParam shr 30 <> 1) then FShell.KeyDown(wParam, GetKeyboardButtons);

            False:
              begin
              SendTranslateMessage(Msg, wParam, lParam);
              FShell.KeyDown(wParam, GetKeyboardButtons);
              end;
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


constructor TSimpleGameEngine.Create(InitSound: Boolean);
var
  AppCaption: String;
  gf: TsgeGraphicFrameArray;
begin
  try
    //Переменные
    Randomize;                                                                //Изменить смещение таблицы рандома
    DefaultFormatSettings.DecimalSeparator := '.';                            //Установить точку разделителем дробной части
    _SGEGlobalPtr := Self;                                                    //Глобальная переменная на этот класс
    _AppWorking := True;                                                      //Флаг работы приложения
    _MouseOut := False;                                                       //Мышь внутри окна
    FUserName := 'User';                                                      //Имя пользователя
    FDirMain := AnsiToUtf8(ExtractFilePath(ParamStr(0)));                     //Подготовить главный каталог проекта
    FDirJournal := sge_DirJournal + '\';                                      //Относительный путь журналов
    FDirShots := sge_DirShoots + '\';                                         //Относительный путь снимков
    FDirUser := sge_DirUser + '\';                                            //Относительный путь папки пользователя
    AppCaption := SGE_Name + ' ' + SGE_Version;                               //Название приложения по умолчанию


    //Добавить указатели в список объектов
    ObjectList.Add(Obj_SGE, Self, Group_SGE);


    //Создание классов
    FJournal := TsgeJournal.Create('');                                       //Журналирование
    FTaskList := TsgeTaskList.Create;                                         //Список задач
    FFileSystem := TsgeFileSystem.Create(FDirMain);                           //Файловая система
    FResources := TsgeResourceList.Create;                                    //Хранилище ресурсов
    FStartParameters := TsgeStartParameterList.Create;                        //Стартовые параметры
    FParameters := TsgeSimpleParameters.Create;                               //Настройки
    FFPSCounter := TsgeCounter.Create;                                        //Счётчик кадров
    FJoysticks := TsgeJoystickList.Create;                                    //Хранилище джойстиков
    FFade := TsgeFade.Create;                                                 //Затемнение
    FLanguage := TsgeSimpleParameters.Create;                                 //Таблица языка


    //Таймеры
    FTaskEvent := TsgeEvent.Create(1, False, @TaskManager, -1);               //Таймер обработки задач
    FJoystickEvent := TsgeEvent.Create(10, False, @JoystickEvent, -1);        //Таймер обработки джойстиков


    //Параметры запуска
    if FStartParameters.Exist[sge_PrmDebug] then SetDebug(True);              //Проверить командную строку


    //Окно
    FWindow := TsgeWindow.Create(AppCaption, AppCaption, 100, 100, 800, 600); //Окно
    FWindow.SetWindowProc(@sgeWndProc);                                       //Изменить оконную функцию
    SetMouseTrackEvent;                                                       //Запуск отлова ухода мыши из области формы


    //Графика
    FGraphic := TsgeGraphic.Create(FWindow.DC, FWindow.Width, FWindow.Height);//Графика
    FGraphic.Activate;                                                        //Активировать контекст

    //Шрифт по умолчанию
    FDefGraphicFont := TsgeGraphicFont.Create('Courier New', 12);             //Графический шрифт

    //Спрайт по умолчанию
    FDefGraphicSprite := TsgeGraphicSprite.Create(8, 8, GC_Black);            //Спрайт
    FDefGraphicSprite.FillChessBoard(2);                                      //Залить шахмотной доской

    //Кадры анимации по умолчанию
    SetLength(gf, 1);                                                         //Создать один кадр
    gf[0].SpriteName := 'Default';                                            //Имя спрайта
    gf[0].Sprite := FDefGraphicSprite;                                        //Указатель на спрайт
    gf[0].Col := 0;                                                           //Плитка по X
    gf[0].Row := 0;                                                           //Плитка по Y
    gf[0].Time := 1000;                                                       //Время видимости на экране
    FDefGraphicFrames := TsgeGraphicFrameList.Create(gf);                     //Создать кадры из массива
    SetLength(gf, 0);                                                         //Почистить память

    //Анимация по умолчанию
    FDefGraphicAnimation := TsgeGraphicAnimation.Create(FDefGraphicFrames, 16, 16); //Анимация


    //Оболочка
    FShell := TsgeShell.Create;                                               //Оболочка
    sgeShellFunctions_RegisterCommand;                                        //Регистрация команд оболочки


    //Звук
    if InitSound then
      begin
      FSound := TsgeSound.Create;                                             //Звук
      FDefSoundBuffer := TsgeSoundBuffer.CreateBlank;                         //Звуковой буфер
      end;


    //Иконка по умолчанию
    FDefSystemIcon := TsgeSystemIcon.Create;                                  //Иконка


    //Курсор по умолчанию
    FDefSystemCursor := TsgeSystemCursor.Create;                              //Курсор


    //Настройка системы
    SetMaxFramesPerSecond(100);                                               //Установить предел кадров
    FAutoEraseBG := True;                                                     //Стирать фон перед рисованием
    FDrawEnable := True;                                                      //Включить вывод графики
    FAutoScanJoysticks := False;                                              //Не сканировать при подключении джойстика

  except
    on E: EsgeException do
      begin
      LogError(sgeCreateErrorString(_UNITNAME, Err_CantInitSimpleGameEngine, '', E.Message));
      if not FDebug then ShowMessage('Run game with "DEBUG" parameter for detail');
      halt;
      end;
  end;
end;


destructor TSimpleGameEngine.Destroy;
begin
  FDefGraphicAnimation.Free;  //Анимация
  FDefGraphicFrames.Free;     //Кадры анимации
  FDefGraphicFont.Free;       //Шрифт по умолчанию
  FDefGraphicSprite.Free;     //Спрайт по умолчанию
  FDefSystemCursor.Free;      //Курсор по умолчанию
  FDefSystemIcon.Free;        //Иконка по умолчанию
  FDefSoundBuffer.Free;       //Звуковой буфер по умолчанию

  FLanguage.Free;             //Таблица языка
  FFade.Free;                 //Затемнение
  FShell.Free;                //Оболочка
  FResources.Free;            //Ресурсы
  FSound.Free;                //Звук
  FGraphic.Free;              //OpenGL
  FWindow.Free;               //Окно
  FTaskEvent.Free;            //Таймер обработки задач
  FJoystickEvent.Free;        //Таймер обработки джойстиков
  FFPSCounter.Free;           //Счётчик кадров
  FParameters.Free;           //Параметры приложения
  FStartParameters.Free;      //Стартовые параметры
  FJoysticks.Free;            //Хранилище джойстиков
  FJournal.Free;              //Журналирование
  FFileSystem.Free;           //Файловая система
  FTaskList.Free;             //Список задач
end;


procedure TSimpleGameEngine.LogError(Msg: String; MessageType: TsgeMessageType);
var
  i, c: Integer;
  Lines: TsgeStringList;
  Str: String;
  J, S: Boolean;
begin
  try
    J := FJournal.Enable;
    S := FShell.LogErrors;

    //Подготовить список
    Lines := TsgeStringList.Create;
    Lines.FromString(Msg);

    try
      c := Lines.Count - 1;
      for i := 0 to c do

        case MessageType of
          mtInfo:
            begin
            if J then FJournal.LogDetail(Lines.Part[i]);
            if S then FShell.LogMessage(Lines.Part[i], sltNote);
            end;

          mtError:
            begin
            Str := GetLocalizedErrorString(Lines.Part[i]);

            case i of
              0:
                begin
                if J then FJournal.LogDetail(Str);
                if S then FShell.LogMessage(Str, sltError);
                end;

              else
                begin
                if J then FJournal.Log('             ' + Str);
                if S then FShell.LogMessage('  ' + Str, sltNote);
                end;
            end;
            end;
        end;//MessagType


    except
      //Что делать тут пока не ясно
      //Ошибка при обработке ошибки
    end;


  finally
    Lines.Free;
  end;
end;


procedure TSimpleGameEngine.ShowMessage(Msg: String; AType: TsgeMessageType);
var
  d: UINT;
begin
  d := MB_OK;

  case AType of
    mtError: d := d or MB_ICONERROR;
    mtInfo : d := d or MB_ICONINFORMATION;
  end;

  MessageBox(0, PChar(Msg), PChar(SGE_Name), d);
end;


function TSimpleGameEngine.IsKeyDown(Key: Integer; Method: TsgeKeyDownMethod): Boolean;
begin
  Result := False;

  if (Method = kdmNormal) and not FWindow.IsFocused then Exit;
  Result := (GetKeyState(Key) and $8000) <> 0;
end;


procedure TSimpleGameEngine.LoadLanguage(FileName: String; Mode: TsgeLoadMode);
var
  Ms: TsgeMemoryStream;
  Params: TsgeSimpleParameters;
begin
  try
    Ms := TsgeMemoryStream.Create;
    Params := TsgeSimpleParameters.Create;

    //Загрузить файл
    try
      FFileSystem.ReadFile(FileName, Ms);
    except
      on E: EsgeException do
        LogError(sgeCreateErrorString(_UNITNAME, Err_CantLoadLanguage, '', E.Message));
    end;

    //Залить
    Params.FromMemoryStream(Ms);

    //Обновить данные
    if Mode = lmReplace then FLanguage.CopyFrom(Params) else FLanguage.Add(Params);

    //Поправить данные в оболочке
    FShell.UpdateLanguage;

  finally
    Params.Free;
    Ms.Free;
  end;
end;


procedure TSimpleGameEngine.LoadPackFromDirectory(Directory: String; Ext: String);
var
  List: TsgeStringList;
  i, c: Integer;
begin
  List := TsgeStringList.Create;
  FFileSystem.FindFiles(Directory, List, Ext);

  c := List.Count - 1;
  for i := 0 to c do
    try
      FFileSystem.AddPack(List.Part[i]);
    except
      on E: EsgeException do
        LogError(sgeCreateErrorString(_UNITNAME, Err_CantLoadPackFile, List.Part[i], E.Message));
    end;

  List.Free;
end;


procedure TSimpleGameEngine.LoadParameters(FileName: String);
var
  Ms: TsgeMemoryStream;
begin
  try
    Ms := TsgeMemoryStream.Create;

    try
      FileSystem.ReadFile(FileName, Ms);
    except
      on E:EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_CantLoadParameters, '', E.Message);
    end;

    FParameters.FromMemoryStream(Ms);

  finally
    Ms.Free;
  end;
end;


procedure TSimpleGameEngine.SaveParameters(FileName: String);
var
  Ms: TsgeMemoryStream;
begin
  try
    Ms := TsgeMemoryStream.Create;
    FParameters.ToMemoryStream(Ms);

    try
      FileSystem.WriteFile(FileName, Ms);
    except
      on E:EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_CantSaveParameters, '', E.Message);
    end;

  finally
    Ms.Free;
  end;
end;


procedure TSimpleGameEngine.OverrideParameters;
var
  i, c: Integer;
begin
  c := FStartParameters.Count - 1;
  for i := 0 to c do
    FParameters.SetValue(FStartParameters.Parameter[i].Name, FStartParameters.Parameter[i].Value);
end;


procedure TSimpleGameEngine.LoadAppIcon(Name: String; From: TsgeLoadFrom);
var
  Ico: TsgeSystemIcon;
begin
  if FWindow = nil then
    raise EsgeException.Create(_UNITNAME, Err_WindowNotInitialized, Name);

  //Загрузить
  Ico := nil;
  try
    case From of
      lfHinstance:
        begin
        FDefSystemIcon.LoadFromHinstance(Name);
        Ico := FDefSystemIcon;
        end;

      lfFile:
        begin
        FDefSystemIcon.LoadFromFile(Name);
        Ico := FDefSystemIcon;
        end;
    end;
  except
    on E: EsgeException do
      raise EsgeException.Create(_UNITNAME, Err_CantLoadAppIcon, '', E.Message);
  end;


  //Изменить иконку
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
    raise EsgeException.Create(_UNITNAME, Err_WindowNotInitialized, Name);

  //Загрузить курсоры
  Cur := nil;
  try
    case From of
      lfHinstance:
        begin
        FDefSystemCursor.LoadFromHinstance(Name);
        Cur := FDefSystemCursor;
        end;

      lfFile:
        begin
        FDefSystemCursor.LoadFromFile(Name);
        Cur := FDefSystemCursor;
        end;
    end;
  except
    on E: EsgeException do
      raise EsgeException.Create(_UNITNAME, Err_CantLoadAppCursor, '', E.Message);
  end;

  //Изменить иконку
  if Cur <> nil then FWindow.Cursor := Cur.Handle;
end;


procedure TSimpleGameEngine.FullScreen;
begin
  FWindow.FullScreen;
  SendMessage(FWindow.Handle, WM_SIZE, 0, 0);
end;


procedure TSimpleGameEngine.Screenshot(FileName: String);
var
  ms: TsgeMemoryStream;
  fn: String;
begin
  try
    ms := TsgeMemoryStream.Create;

    //Подготовить имя файла
    if FileName = '' then fn := FDirShots + sgeGetUniqueFileName else fn := FDirShots + FileName;
    fn := fn + '.' + sge_ExtShots;

    //Взять данные
    FGraphic.ScreenShot(ms);

    //Записать в файл
    try
      FFileSystem.ForceDirectories(ExtractFilePath(fn));
      FFileSystem.WriteFile(fn, ms);
    except
      on E:EsgeException do
        raise EsgeException.Create(_UNITNAME, Err_CantCreateScreenShot, '', E.Message);
    end;

  finally
    ms.Free;
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
    LogError(sgeCreateErrorString(_UNITNAME, Err_SpriteNotFound, Name));
    Result := FDefGraphicSprite;
    end;
end;


function TSimpleGameEngine.GetGraphicFont(Name: String): TsgeGraphicFont;
begin
  Result := TsgeGraphicFont(FResources.TypedObj[Name, rtGraphicFont]);
  if Result = nil then
    begin
    LogError(sgeCreateErrorString(_UNITNAME, Err_FontNotFound, Name));
    Result := FDefGraphicFont;
    end;
end;


function TSimpleGameEngine.GetSoundBuffer(Name: String): TsgeSoundBuffer;
begin
  Result := TsgeSoundBuffer(FResources.TypedObj[Name, rtSoundBuffer]);
  if Result = nil then
    begin
    LogError(sgeCreateErrorString(_UNITNAME, Err_BufferNotFound, Name));
    Result := FDefSoundBuffer;
    end;
end;


function TSimpleGameEngine.GetGraphicFrames(Name: String): TsgeGraphicFrameList;
begin
  Result := TsgeGraphicFrameList(FResources.TypedObj[Name, rtGraphicFrames]);
  if Result = nil then
    begin
    LogError(sgeCreateErrorString(_UNITNAME, Err_FramesNotFound, Name));
    Result := FDefGraphicFrames;
    end;
end;


function TSimpleGameEngine.GetGraphicAnimation(Name: String): TsgeGraphicAnimation;
begin
  Result := TsgeGraphicAnimation(FResources.TypedObj[Name, rtGraphicAnimations]);
  if Result = nil then
    begin
    LogError(sgeCreateErrorString(_UNITNAME, Err_AnimationNotFound, Name));
    Result := FDefGraphicAnimation;
    end;
end;


function TSimpleGameEngine.GetParameters(Name: String): TsgeSimpleParameters;
begin
  Result := TsgeSimpleParameters(FResources.TypedObj[Name, rtParameters]);
  if Result = nil then
    begin
    LogError(sgeCreateErrorString(_UNITNAME, Err_ParametersNotFound, Name));
    Result := FParameters;
    end;
end;


procedure TSimpleGameEngine.FadeStart(Mode: TsgeFadeMode; Color: TsgeGraphicColor; Time: Cardinal);
begin
  FFade.Start(Mode, Color, Time, @FadePassTime);
end;


procedure TSimpleGameEngine.FadeStop;
begin
  FFade.Stop;
end;


procedure TSimpleGameEngine.FadePassTime(Time: TsgeFadePassedTime);
begin
end;


procedure TSimpleGameEngine.Stop;
begin
  SetTaskEnable(False);
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



