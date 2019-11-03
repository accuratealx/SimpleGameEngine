{
Пакет             Simple Game Engine 1
Файл              sgeWindow.pas
Версия            1.12
Создан            24.01.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание					Окно на WinAPI
}

unit sgeWindow;

{$mode objfpc}{$H+}

interface

uses
  sgeConst, sgeTypes,
  Windows;


type
  TsgeWindowStyle = set of (wsCaption, wsSizeable, wsSystemMenu, wsTopMost, wsDoubleClick);

  TsgeWindowButtons = set of (wbClose, wbMinimize, wbMaximize);

  TsgeWindowViewMode = (wvmNormal, wvmMinimize, wvmMaximize);

  TsgeWindowCenterPos = (wcpScreen, wcpClientArea, wcpVirtualScreen);


  TsgeWindow = class
  private
    FHandle: HWND;
    FWindowClass: TWNDClassEx;
    FSystemMenu: HMENU;
    FButtons: TsgeWindowButtons;
    FClipCursor: Boolean;
    FStyle: TsgeWindowStyle;
    FOldStyle: TsgeWindowStyle;

    function  GetHWNDPos: HWND;
    function  GetDC: HDC;
    function  GetCaption: String;
    procedure SetCaption(ACaption: String);
    procedure SetStatusBarVisible(AEnable: Boolean);
    function  GetStatusBarVisible: Boolean;
    function  GetRect: TRect;
    procedure SetRect(ARect: TRect);
    function  GetClientRect: TRect;
    procedure SetEnable(AEnable: Boolean);
    function  GetEnable: Boolean;
    function  GetLeft: Integer;
    procedure SetLeft(ALeft: Integer);
    function  GetTop: Integer;
    procedure SetTop(ATop: Integer);
    function  GetWidth: Integer;
    procedure SetWidth(AWidth: Integer);
    function  GetHeight: Integer;
    procedure SetHeight(AHeight: Integer);
    function  GetClientWidth: Integer;
    procedure SetClientWidth(AWidth: Integer);
    function  GetClientHeight: Integer;
    procedure SetClientHeight(AHeight: Integer);
    procedure SetStyle(AStyle: TsgeWindowStyle);
    procedure SetButtons(AButtons: TsgeWindowButtons);
    procedure SetIcon(AIcon: HICON);
    function  GetIcon: HICON;
    procedure SetStatusBarIcon(AIcon: HICON);
    function  GetStatusBarIcon: HICON;
    procedure SetCursor(ACursor: HCURSOR);
    function  GetCursor: HCURSOR;
    procedure SetShowCursor(AShow: Boolean);
    function  GetShowCursor: Boolean;
    procedure SetVisible(AVisible: Boolean);
    function  GetVisible: Boolean;
    procedure SetViewMode(AMode: TsgeWindowViewMode);
    function  GetViewMode: TsgeWindowViewMode;
    procedure SetClipCursor(AClip: Boolean);
    procedure ChangeWindowStyle;
  public
    constructor Create(WndClassName, Caption: String; Left, Top: Integer; Width, Height: Integer);
    destructor  Destroy; override;

    procedure Show;
    procedure Hide;
    procedure Activate;
    procedure Minimize;
    procedure Maximize;
    procedure Restore;
    procedure Update;
    procedure SetWindowProc(Proc: Pointer);
    procedure FullScreen;
    procedure Center(APos: TsgeWindowCenterPos = wcpClientArea);

    property DC: HDC read GetDC;
    property Handle: HWND read FHandle;
    property Caption: String read GetCaption write SetCaption;
    property Style: TsgeWindowStyle read FStyle write SetStyle;
    property ViewMode: TsgeWindowViewMode read GetViewMode write SetViewMode;
    property Buttons: TsgeWindowButtons read FButtons write SetButtons;
    property Enable: Boolean read GetEnable write SetEnable;
    property Visible: Boolean read GetVisible write SetVisible;
    property Icon: HICON read GetIcon write SetIcon;
    property StatusBarIcon: HICON read GetStatusBarIcon write SetStatusBarIcon;
    property StatusBarVisible: Boolean read GetStatusBarVisible write SetStatusBarVisible;
    property Cursor: HCURSOR read GetCursor write SetCursor;
    property ShowCursor: Boolean read GetShowCursor write SetShowCursor;
    property ClipCursor: Boolean read FClipCursor write SetClipCursor;
    property Rect: TRect read GetRect write SetRect;
    property ClientRect: TRect read GetClientRect;
    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property ClientWidth: Integer read GetClientWidth write SetClientWidth;
    property ClientHeight: Integer read GetClientHeight write SetClientHeight;
  end;



implementation


function TsgeWindow.GetHWNDPos: HWND;
begin
  if wsTopMost in FStyle then Result := HWND_TOPMOST else Result := HWND_NOTOPMOST;
end;


function TsgeWindow.GetDC: HDC;
begin
  Result := Windows.GetDC(FHandle);
end;


function TsgeWindow.GetCaption: String;
var
  B: array of Char;
  Count: Integer;
begin
  Count := GetWindowTextLength(FHandle) + 1;
  SetLength(B, Count);
  GetWindowText(FHandle, @B[0], Count);
  SetString(Result, @B[0], Count);
  SetLength(B, 0);
end;


procedure TsgeWindow.SetCaption(ACaption: String);
begin
  SetWindowText(FHandle, PChar(ACaption));
end;


procedure TsgeWindow.SetStatusBarVisible(AEnable: Boolean);
var
  i: HWND;
begin
  if AEnable then i := 0 else i := GetDesktopWindow;
  SetWindowLongPtr(FHandle, GWLP_HWNDPARENT, i);
end;


function TsgeWindow.GetStatusBarVisible: Boolean;
begin
  Result := GetWindowLongPtr(FHandle, GWL_HWNDPARENT) = 0;
end;


function TsgeWindow.GetRect: TRect;
begin
  Windows.GetWindowRect(FHandle, @Result);
end;


procedure TsgeWindow.SetRect(ARect: TRect);
begin
  SetWindowPos(FHandle, GetHWNDPos, ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, SWP_FRAMECHANGED or SWP_NOACTIVATE);
end;


function TsgeWindow.GetClientRect: TRect;
begin
  Windows.GetClientRect(FHandle, @Result);
end;


procedure TsgeWindow.SetEnable(AEnable: Boolean);
begin
  EnableWindow(FHandle, AEnable);
end;


function TsgeWindow.GetEnable: Boolean;
begin
  Result := IsWindowEnabled(FHandle) <> LongBool(0);
end;


function TsgeWindow.GetLeft: Integer;
begin
  Result := Rect.Left;
end;


procedure TsgeWindow.SetLeft(ALeft: Integer);
begin
  SetWindowPos(FHandle, GetHWNDPos, ALeft, Top, 0, 0, SWP_NOSIZE or SWP_NOACTIVATE);
end;


function TsgeWindow.GetTop: Integer;
begin
  Result := Rect.Top;
end;


procedure TsgeWindow.SetTop(ATop: Integer);
begin
  SetWindowPos(FHandle, GetHWNDPos, Left, ATop, 0, 0, SWP_NOSIZE or SWP_NOACTIVATE);
end;


function TsgeWindow.GetWidth: Integer;
begin
  Result := Rect.Right - Rect.Left;
end;


procedure TsgeWindow.SetWidth(AWidth: Integer);
begin
  SetWindowPos(FHandle, GetHWNDPos, 0, 0, AWidth, Height, SWP_NOMOVE or SWP_NOACTIVATE);
end;


function TsgeWindow.GetHeight: Integer;
begin
  Result := Rect.Bottom - Rect.Top;
end;


procedure TsgeWindow.SetHeight(AHeight: Integer);
begin
  SetWindowPos(FHandle, GetHWNDPos, 0, 0, Width, AHeight, SWP_NOMOVE or SWP_NOACTIVATE);
end;


function TsgeWindow.GetClientWidth: Integer;
begin
  Result := ClientRect.Right;
end;


procedure TsgeWindow.SetClientWidth(AWidth: Integer);
var
  NewWidth: Integer;
begin
  NewWidth := AWidth + (Width - ClientWidth);
  SetWindowPos(FHandle, GetHWNDPos, 0, 0, NewWidth, Height, SWP_NOMOVE or SWP_NOACTIVATE);
end;


function TsgeWindow.GetClientHeight: Integer;
begin
  Result := ClientRect.Bottom;
end;


procedure TsgeWindow.SetClientHeight(AHeight: Integer);
var
  NewHeight: Integer;
begin
  NewHeight := AHeight + (Height - ClientHeight);
  SetWindowPos(FHandle, GetHWNDPos, 0, 0, Width, NewHeight, SWP_NOMOVE or SWP_NOACTIVATE);
end;


procedure TsgeWindow.SetStyle(AStyle: TsgeWindowStyle);
begin
  if FStyle = AStyle then Exit;
  FStyle := AStyle;
  ChangeWindowStyle;
end;


procedure TsgeWindow.SetButtons(AButtons: TsgeWindowButtons);
begin
  if FButtons = AButtons then Exit;
  FButtons := AButtons;
  ChangeWindowStyle;
end;


procedure TsgeWindow.SetIcon(AIcon: HICON);
begin
  SetClassLongPtr(FHandle, GCLP_HICONSM, AIcon);
end;


function TsgeWindow.GetIcon: HICON;
begin
  Result := GetClassLongPtr(FHandle, GCLP_HICONSM);
end;


procedure TsgeWindow.SetStatusBarIcon(AIcon: HICON);
begin
  SetClassLongPtr(FHandle, GCLP_HICON, AIcon);
end;


function TsgeWindow.GetStatusBarIcon: HICON;
begin
  Result := GetClassLongPtr(FHandle, GCLP_HICON);
end;


procedure TsgeWindow.SetCursor(ACursor: HCURSOR);
begin
  SetClassLongPtr(FHandle, GCLP_HCURSOR, ACursor);
end;


function TsgeWindow.GetCursor: HCURSOR;
begin
  Result := GetClassLongPtr(FHandle, GCLP_HCURSOR);
end;


procedure TsgeWindow.SetShowCursor(AShow: Boolean);
var
  Cnt: Integer;
begin
  if AShow then
    begin
      repeat
      Cnt := Windows.ShowCursor(True);
      until Cnt >= 0;
    end
    else begin
      repeat
      Cnt := Windows.ShowCursor(False);
      until Cnt < 0;
    end;
end;


function TsgeWindow.GetShowCursor: Boolean;
var
  ci: TCURSORINFO;
begin
  ci.cbSize := SizeOf(TCURSORINFO);
  GetCursorInfo(ci);
  Result := (ci.flags = 1);
end;


procedure TsgeWindow.SetVisible(AVisible: Boolean);
begin
  if AVisible then Show else Hide;
end;


function TsgeWindow.GetVisible: Boolean;
begin
  Result := IsWindowVisible(FHandle) = LongBool(1);
end;


procedure TsgeWindow.SetViewMode(AMode: TsgeWindowViewMode);
begin
  case AMode of
    wvmNormal: Restore;
    wvmMinimize: Minimize;
    wvmMaximize: Maximize;
  end;
end;


function TsgeWindow.GetViewMode: TsgeWindowViewMode;
begin
  Result := wvmNormal;
  if IsIconic(FHandle) = LongBool(1) then Result := wvmMinimize;
  if IsZoomed(FHandle) = LongBool(1) then Result := wvmMaximize;
end;


procedure TsgeWindow.SetClipCursor(AClip: Boolean);
var
  Pt: TPoint;
  Rct: TRect;
begin
  if AClip = FClipCursor then Exit;
  FClipCursor := AClip;
  if FClipCursor then
    begin
    Pt.x := 0;
    Pt.y := 0;
    ClientToScreen(FHandle, Pt);              //Преобразовать координаты нулевой точки окна в координаты на экране
    Rct.Left := Pt.x;
    Rct.Top := Pt.y;
    Rct.Right := Rct.Left + GetClientWidth;
    Rct.Bottom := Rct.Top + GetClientHeight;
    Windows.ClipCursor(Rct);                  //Заблокировать куроср в прямоугольнике
    end else Windows.ClipCursor(nil);
end;


procedure TsgeWindow.ChangeWindowStyle;
var
  NewStyle: DWORD;
begin
  //Изменить стандартный стиль окна
  NewStyle := 0;                                                      //Обнулить, при в ходе имеет уже значение
  if GetVisible then NewStyle := WS_VISIBLE;                          //Если окно видимо, то учесть флаг
  NewStyle := NewStyle or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;         //Для OpenGL
  if wsCaption in FStyle then NewStyle := NewStyle or WS_CAPTION;     //Заголовок окна
  if wsSystemMenu in FStyle then NewStyle := NewStyle or WS_SYSMENU;  //Системное меню с кнопками
  if wsSizeable in FStyle then NewStyle := NewStyle + WS_SIZEBOX;     //Изменение размеров

  //Кнопки
  if wbMaximize in FButtons then NewStyle := NewStyle or WS_MAXIMIZEBOX;
  if wbMinimize in FButtons then NewStyle := NewStyle or WS_MINIMIZEBOX;

  //Затенить/показать "закрыть" через MenuItem
  if wbClose in FButtons then EnableMenuItem(FSystemMenu, SC_CLOSE, MF_ENABLED)
      else EnableMenuItem(FSystemMenu, SC_CLOSE, MF_GRAYED or MF_DISABLED);

  //Применить изменения
  SetWindowLongPtr(FHandle, GWL_STYLE, NewStyle);

  //Двойной клик на окне
  NewStyle := CS_HREDRAW or CS_VREDRAW;
  if wsDoubleClick in FStyle then NewStyle := NewStyle or CS_DBLCLKS;
  SetClassLongPtr(FHandle, GCL_STYLE, NewStyle);

  //Пошевелить окно
  SetWindowPos(FHandle, GetHWNDPos, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_FRAMECHANGED or SWP_NOACTIVATE);
end;


constructor TsgeWindow.Create(WndClassName, Caption: String; Left, Top: Integer; Width, Height: Integer);
begin
  //Подготовительные работы
  FStyle := [wsCaption, wsSizeable, wsSystemMenu];    //Заполняем начальный стиль окна
  FOldStyle := FStyle;                                //Запомнить старый стиль
  FButtons := [wbClose, wbMinimize, wbMaximize];      //Заполняем системные кнопки

  //Заполняем класс окна
  with FWindowClass do
    begin
    cbSize := SizeOf(TWNDClassEx);                    //Размер структуры
    style := CS_HREDRAW or CS_VREDRAW;                //Стиль окна
    lpfnWndProc := @DefWindowProc;                    //Обработчик событий окна
    cbClsExtra := 0;                                  //Дополнительная память
    cbWndExtra := 0;                                  //Дополнительная память для всех потомков
    hInstance := System.HINSTANCE;                    //Адрес начала данных приложения Win32
    hIcon := LoadIcon(0, IDI_APPLICATION);            //Загрузка стандартного значка приложения
    hCursor := LoadCursor(0, IDC_ARROW);              //Загрузка стандартного курсора Win32
    hbrBackground := GetStockObject(BLACK_BRUSH);     //Заливка стандартной чёрной кистью
    lpszMenuName := nil;                              //Имя строки-ресурса системного меню
    lpszClassName := PChar(WndClassName);             //Уникальное имя класса
    hIconSm := hIcon;                                 //Ссылка на маленькую иконку
    end;

  //Регистрация окна
  if RegisterClassEx(FWindowClass) = 0 then
    raise EsgeException.Create(Err_sgeWindow + Err_Separator + Err_sgeWindow_CantRegisterClass);

  //Создание окна
  FHandle := CreateWindow(FWindowClass.lpszClassName, PChar(Caption), WS_OVERLAPPEDWINDOW, Left, Top, Width, Height, 0, 0, FWindowClass.hInstance, nil);
  if FHandle = 0 then
    raise EsgeException.Create(Err_sgeWindow + Err_Separator + Err_sgeWindow_CantCreateWindow);

  //Ссылка на системное меню формы
  FSystemMenu := GetSystemMenu(FHandle, False);

  //Поправить стиль
  ChangeWindowStyle;
end;



destructor TsgeWindow.Destroy;
begin
  DestroyWindow(FHandle);                                                       //Удаляем окно
  Windows.UnregisterClass(FWindowClass.lpszClassName, FWindowClass.hInstance);  //Удаляем класс окна
end;


procedure TsgeWindow.Show;
begin
  ShowWindow(FHandle, SW_SHOWNORMAL);
end;


procedure TsgeWindow.Hide;
begin
  ShowWindow(FHandle, SW_HIDE);
end;


procedure TsgeWindow.Activate;
begin
  if IsIconic(FHandle) = LongBool(1) then Restore else SetForegroundWindow(FHandle);
end;


procedure TsgeWindow.Minimize;
begin
  ShowWindow(FHandle, SW_MINIMIZE);
end;


procedure TsgeWindow.Maximize;
begin
  ShowWindow(FHandle, SW_MAXIMIZE);
end;


procedure TsgeWindow.Restore;
begin
  ShowWindow(FHandle, SW_RESTORE);
end;


procedure TsgeWindow.Update;
begin
  InvalidateRect(FHandle, nil, True);
end;


procedure TsgeWindow.SetWindowProc(Proc: Pointer);
begin
  if Proc = nil then Exit;
  SetWindowLongPtr(FHandle, GWLP_WNDPROC,  LONG_PTR(Proc));
end;


procedure TsgeWindow.FullScreen;
begin
  if not GetVisible then Exit;            //Пока окно невидимо изменение состояния не сработает

  if IsZoomed(FHandle) = LongBool(1) then
    begin
    Restore;
    Style := FOldStyle;
    end
    else begin
    FOldStyle := Style;
    Style := [];
    Maximize;
    end;
end;


procedure TsgeWindow.Center(APos: TsgeWindowCenterPos);
var
  W, H: Integer;
begin
  //Определить размеры центрирования
  case APos of
    wcpScreen:
      begin
      W := GetSystemMetrics(SM_CXSCREEN);         //Размер первого экрана
      H := GetSystemMetrics(SM_CYSCREEN);
      end;
    wcpClientArea:
      begin
      W := GetSystemMetrics(SM_CXFULLSCREEN);     //Клиенстская область рабочего стола
      H := GetSystemMetrics(SM_CYFULLSCREEN);
      end;
    wcpVirtualScreen:
      begin
      W := GetSystemMetrics(SM_CXVIRTUALSCREEN);  //Размер всех мониторов
      H := GetSystemMetrics(SM_CYVIRTUALSCREEN);
      end;
  end;

  //Изменить положение
  Left := W div 2 - Width div 2;
  Top := H div 2 - Height div 2;
end;




end.

