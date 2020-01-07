{
Пакет             Simple Game Engine 1
Файл              sgeScreenSaver.pas
Версия            1.1
Создан            07.01.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Класс для создания хранителей экрана в ОС Windows

}
unit sgeScreenSaver;

{$mode objfpc}{$H+}

interface

uses
  SimpleGameEngine, sgeTypes,
  Windows;


type
  TsgeScreenStartMode = (sssmShow, sssmConfigure, sssmPreview);



  TsgeScreenSaver = class(TSimpleGameEngine)
  private
    FStartMode: TsgeScreenStartMode;        //Режим запуска
    FParentHWND: HWND;                      //Хэндл родителя
    FStartMousePos: TPoint;                 //Стартовые координаты мыши
  public
    constructor Create; override;

    procedure LoadSaverSettings; virtual;   //Загрузка настроек
    procedure StartSaverConfigBox; virtual; //Вызов функции диалога настроек
    procedure StartSaver;                   //Запуск хранителя

    procedure DeactivateWindow; override;
    procedure MouseDown(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons); override;
    procedure MouseMove(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons); override;
    procedure KeyDown(Key: Byte; KeyboardButtons: TsgeKeyboardButtons); override;

    property StartMode: TsgeScreenStartMode read FStartMode;
    property ParentHWND: HWND read FParentHWND;
  end;


implementation


{$R SaverName.rc}


uses
  SysUtils;


constructor TsgeScreenSaver.Create;
var
  Prm1, s: String;
  pw: Integer;
  Rct: TRect;
begin
  //Предусмотреть только одну копию
  if hprevinst <> 0 then Halt;

  //Конструктор предка
  inherited Create;

  //Координаты мыши при запуске
  GetCursorPos(FStartMousePos);

  //Определить режим запуска
  FStartMode := sssmConfigure;
  FParentHWND := 0;
  Prm1 := LowerCase(ParamStr(1));
  s := Copy(Prm1, 1, 2);
  if s = '/s' then FStartMode := sssmShow;
  if s = '/c' then
    begin
    FStartMode := sssmConfigure;
    Delete(Prm1, 1, 3);
    if TryStrToInt(Prm1, pw) then FParentHWND := pw;
    end;
  if s = '/p' then
    begin
    FStartMode := sssmPreview;
    if TryStrToInt(ParamStr(2), pw) then FParentHWND := pw;
    end;

  //Подготовить систему
  Ignition();

  //Настроить систему
  Window.Style := [];
  Window.Left := 0;
  Window.Top := 0;
  DrawControl := dcSync;

  //Поправить форму
  case FStartMode of
    sssmPreview:
      begin
      GetWindowRect(FParentHWND, Rct);
      Window.Width := Rct.Right - Rct.Left;
      Window.Height := Rct.Bottom - Rct.Top;
      SetParent(Window.Handle, FParentHWND);
      SetWindowLongPtr(Window.Handle, GWL_STYLE, GetWindowLongPtr(Window.Handle, GWL_STYLE) or WS_CHILD);
      end;

    sssmShow:
      begin
      Window.Width := GetSystemMetrics(SM_CXVIRTUALSCREEN);
      Window.Height := GetSystemMetrics(SM_CYVIRTUALSCREEN);
      Window.ShowCursor := False;
      end;
  end;

  //Загрузить параметры
  LoadSaverSettings;
end;


procedure TsgeScreenSaver.LoadSaverSettings;
begin
end;


procedure TsgeScreenSaver.StartSaverConfigBox;
var
  s: String;
  BoxPrm: TMSGBOXPARAMS;
begin
  s := Utf8ToAnsi('Хранитель экрана не содержит диалога настройки.');
  if FParentHWND = 0 then FParentHWND := Window.Handle;

  with BoxPrm do
    begin
    cbSize := SizeOf(TMSGBOXPARAMS);
    hwndOwner := FParentHWND;
    hInstance := hInstance;
    lpszText := PChar(s);
    lpszCaption := 'Screen saver';
    dwStyle := MB_OK or MB_ICONINFORMATION;
    end;
  MessageBoxIndirect(BoxPrm);
end;


procedure TsgeScreenSaver.StartSaver;
begin
  case FStartMode of
    sssmConfigure:
      begin
      StartSaverConfigBox;
      Exit;
      end;

    else begin
    Window.Show;
    Run;
    end;
  end;
end;


procedure TsgeScreenSaver.DeactivateWindow;
begin
  if FStartMode = sssmShow then Stop;
end;


procedure TsgeScreenSaver.MouseDown(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
begin
  if FStartMode = sssmShow then Stop;
end;


procedure TsgeScreenSaver.MouseMove(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
var
  pt: TPoint;
begin
  if FStartMode = sssmShow then
    begin
    GetCursorPos(pt);
    if pt <> FStartMousePos then Stop;
    end;
end;


procedure TsgeScreenSaver.KeyDown(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);
begin
  if FStartMode = sssmShow then Stop;
end;



end.

