{
Пакет             Simple Game Engine 1
Файл              sgeShellFunctions.pas
Версия            1.9
Создан            09.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Функции оболочки
}

unit sgeShellFunctions;

{$mode objfpc}{$H+}

interface


procedure sgeShellFunctions_RegisterCommand(SGEPtr: TObject);


implementation

uses
  StringArray, SimpleCommand,
  SimpleGameEngine, sgeConst, sgeTypes, sgeGraphicColor, sgeShell, sgeGraphic, sgeWindow,
  sgeGraphicFont, sgeGraphicSprite, sgeKeyTable, sgeResources,
  SysUtils;


var
  SGE: TSimpleGameEngine;





function GetUserLoadFileName(FileName: String): String;
begin
  Result := FileName;
  if FileExists(SGE.DirMain + FileName) then Result := SGE.DirMain + FileName;
  if FileExists(SGE.DirUser + FileName) then Result := SGE.DirUser + FileName;
end;


function GetUserSaveFileName(FileName: String): String;
var
  Dir: String;
begin
  Dir := ExtractFilePath(FileName);
  try
    ForceDirectories(Dir);
    Result := FileName;
  except
    Result := SGE.DirUser + FileName;
  end;
end;





/////////////////////////////////////////////////////////////////////
//                       Функции оболочки                          //
/////////////////////////////////////////////////////////////////////
{
Описание:
  Установить имя пользователя
Синтаксис:
  Name <NewName>
Параметры:
 NewName - Новое имя
}
function sge_ShellFunctions_System_Name(Cmd: PStringArray): String;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    if Cmd^[1] <> '' then SGE.UserName := Cmd^[1];
    end else SGE.Shell.LogMessage('Name = ' + SGE.UserName);
end;


{
Описание:
  Остановить движок
Синтаксис:
  Stop
}
function sge_ShellFunctions_System_Stop(Cmd: PStringArray): String;
begin
  Result := '';

  SGE.Stop;
end;


{
Описание:
  Вывести версию движка
Синтаксис:
  Version
}
function sge_ShellFunctions_System_Version(Cmd: PStringArray): String;
begin
  Result := '';

  SGE.Shell.LogMessage(SGE_Name + ' ' + SGE_Version);
end;


{
Описание:
  Выполнить скрипт
Синтаксис:
  Run [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_System_Run(Cmd: PStringArray): String;
var
  sa: TStringArray;
  c, i: Integer;
  fn: String;
begin
  Result := '';

  //Подготовить имя файла
  fn := GetUserLoadFileName(Cmd^[1]);

  //Загрузка из файла
  if not StringArray_LoadFromFile(@sa, fn) then
    begin
    Result := sgeCreateErrorString('CmdSystemRun', Err_FileReadError, fn);
    Exit;
    end;

  //Выполнить список команд
  c := StringArray_GetCount(@sa) - 1;
  for i := 0 to c do
    begin
    sa[i] := Trim(sa[i]);
    if sa[i] = '' then Continue;
    if sa[i][1] = '#' then Continue;
    SGE.Shell.DoCommand(sa[i]);
    end;

  //Почистить память
  StringArray_Clear(@sa);
end;


{
Описание:
  Вывести строку в журнал
Синтаксис:
  Write <Message>
Параметры:
  Message - Сообщение
}
function sge_ShellFunctions_System_Write(Cmd: PStringArray): String;
var
  i, c: Integer;
  s: String;
begin
  Result := '';

  s := '';
  c := StringArray_GetCount(Cmd) - 1;
  for i := 1 to c do
    begin
    s := s + Cmd^[i];
    if c <> i then s := s + #32;
    end;
  SGE.Shell.LogMessage(s);
end;


{
Описание:
  Вывести цветную строку в журнал
Синтаксис:
  Writec [R G B A] <Message>
Параметры:
  R G B A - Цвет строки
  Message - Сообщение
}
function sge_ShellFunctions_System_Writec(Cmd: PStringArray): String;
var
  i, c: Integer;
  s: String;
begin
  Result := '';

  s := '';
  c := StringArray_GetCount(Cmd) - 1;
  for i := 5 to c do
    begin
    s := s + Cmd^[i];
    if c <> i then s := s + #32;
    end;

  SGE.Shell.Journal.Add(sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Cmd)), s);
end;


{
Описание:
  Вывести информацию о команде
Синтаксис:
  Help <CmdName>
Параметры:
  CmdName - Имя команды
}
function sge_ShellFunctions_System_Help(Cmd: PStringArray): String;
var
  hInfo, hSyntax, hHint, cName, s: String;
  PrmCnt, i: Integer;
begin
  Result := '';

  //Проверить количество параметров
  if not StringArray_Equal(Cmd, 2) then
    begin
    SGE.Shell.LogHelpHint;
    Exit;
    end;

  //Начальные переменные
  hInfo := '';
  hSyntax := '';
  hHint := '';
  PrmCnt := 0;
  cName := LowerCase(Cmd^[1]);

  //Поиск языковых констант
  SGE.Shell.Language.GetString('Help:' + cName + '.Info', hInfo);
  SGE.Shell.Language.GetString('Help:' + cName + '.Syntax', hSyntax);
  SGE.Shell.Language.GetString('Help:' + cName + '.Hint', hHint);
  SGE.Shell.Language.GetInteger('Help:' + cName + '.ParamCount', PrmCnt);

  //Вывод сведений
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('Help', ': ' + Cmd^[1]);
  if hInfo <> '' then
    begin
    SGE.Shell.LogMessageLocalized('Info', ':');
    SGE.Shell.LogMessage('  ' + hInfo);
    end;
  if hSyntax <> '' then
    begin
    SGE.Shell.LogMessageLocalized('Syntax', ':');
    SGE.Shell.LogMessage('  ' + hSyntax);
    end;
  if PrmCnt > 0 then
    begin
    SGE.Shell.LogMessageLocalized('Parameters', ':');
    for i := 0 to PrmCnt do
      begin
      s := '';
      SGE.Shell.Language.GetString('Help:' + cName + '.Param.' + IntToStr(i), s);
      if s <> '' then SGE.Shell.LogMessage('  ' + s);
      end;
    end;
  if hHint <> '' then
    begin
    SGE.Shell.LogMessageLocalized('Hint', ':');
    SGE.Shell.LogMessage('  ' + hHint);
    end;
  SGE.Shell.LogMessageLocalized('End');
end;


{
Описание:
  Включить/выключить режим отладки
Синтаксис:
  Debug <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_System_Debug(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.Debug then SGE.Shell.LogMessage('Debug = On') else SGE.Shell.LogMessage('Debug = Off');
    1: Result := sgeCreateErrorString('CmdSystemDebug', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Debug := True;
    3: SGE.Debug := False;
  end;
end;


{
Описание:
  Включить/выключить системные тики
Синтаксис:
  Tick <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_System_Tick(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.TickEnable then SGE.Shell.LogMessage('Tick = On') else SGE.Shell.LogMessage('Tick = Off');
    1: Result := sgeCreateErrorString('CmdSystemTick', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.TickEnable := True;
    3: SGE.TickEnable := False;
  end;
end;


{
Описание:
  Установить задержку между системными тиками
Синтаксис:
  TickDelay <Number>
Параметры:
  Number - Задержка
}
function sge_ShellFunctions_System_TickDelay(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 1;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdSystemTickDelay', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else SGE.TickDelay := i;
    end else SGE.Shell.LogMessage('TickDelay = ' + IntToStr(SGE.TickDelay));
end;


{
Описание:
  Вывести список стартовых параметров
Синтаксис:
  StartParams
}
function sge_ShellFunctions_System_StartParams(Cmd: PStringArray): String;
var
  i, c: Integer;
  s, Value: String;
begin
  Result := '';

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('StartParameters', ':');

  //Перебор параметров
  c := SGE.StartParameters.Count - 1;
  for i := 0 to c do
    begin
    s := SGE.StartParameters.Parameter[i].Name;
    Value := SGE.StartParameters.Parameter[i].Value;
    if Value <> '' then s := s + ' = ' + Value;
    SGE.Shell.LogMessage(s);
    end;

  //Вывод хвоста
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(c + 1));
end;


{
Описание:
  Загрузить файл языка
Синтаксис:
  LoadLanguage [FileName] <Mode>
Параметры:
  FileName - Имя файла
  Mode     - Режим загрузки
    Add     - Добавить строки
    Replace - Заменить строки
}
function sge_ShellFunctions_System_LoadLanguage(Cmd: PStringArray): String;
var
  fn: String;
  Mode: TsgeLoadMode;
begin
  Result := '';

  //Подготовить имя файла
  fn := GetUserLoadFileName(Cmd^[1]);

  //Определить режим
  Mode := lmReplace;
  if StringArray_Equal(Cmd, 3) then
    case LowerCase(Cmd^[2]) of
      'add'    : Mode := lmAdd;
      'replace': Mode := lmReplace;
      else begin
      Result := sgeCreateErrorString('CmdSystemLoadLanguage', Err_UnableToDetermineMode, Cmd^[2]);
      Exit;
      end;
    end;

  //Загрузить
  try
    SGE.LoadLanguage(fn, Mode);
  except
    Result := sgeCreateErrorString('CmdSystemLoadLanguage', Err_FileReadError, fn);
  end;
end;





{
Описание:
  Вывести список команд
Синтаксис:
  CmdList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Command_List(Cmd: PStringArray): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, s, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  if StringArray_Equal(Cmd, 2) then Mask := LowerCase(Cmd^[1]) else Mask := '';

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('CommandList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  c := SGE.Shell.Commands.Count - 1;
  for i := 0 to c do
    begin
    //Определить название команды
    cName := SGE.Shell.Commands.Command[i].Name;

    //Поиск соответствия
    if Mask = '' then isAdd := True
      else begin
      Idx := Pos(Mask, LowerCase(cName));

      isAdd := False;
      case SGE.Shell.StrictSearch of
        True : if Idx = 1 then isAdd := True;
        False: if Idx > 0 then isAdd := True;
      end;
      end;

    //Вывод в оболочку
    if isAdd then
      begin
      Inc(Cnt);
      s := '';
      SGE.Shell.Language.GetString('Help:' + cName + '.Info', s);
      SGE.Shell.LogMessage(cName + ' - ' + s);
      end;
    end;

  //Вывод хвоста
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt));
end;


{
Описание:
  Сохранить историю введённых команд в файл
Синтаксис:
  CmdSave [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_Command_Save(Cmd: PStringArray): String;
var
  fn: String;
begin
  Result := '';

  //Определить имя файла
  fn := GetUserSaveFileName(Cmd^[1]);

  //Сохранить в файл
  try
    SGE.Shell.CommandHistory.SaveToFile(fn);
  except
    Result := sgeCreateErrorString('CmdCommandSave', Err_FileWriteError, fn);
  end;
end;


{
Описание:
  Загрузить историю введённых команд из файл
Синтаксис:
  CmdLoad [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_Command_Load(Cmd: PStringArray): String;
var
  fn: String;
begin
  Result := '';

  //Подготовить имя файла
  fn := GetUserLoadFileName(Cmd^[1]);

  //Загрузить
  try
    SGE.Shell.CommandHistory.LoadFromFile(fn);
  except
    Result := sgeCreateErrorString('CmdCommandLoad', Err_FileReadError, fn);;
  end;
end;


{
Описание:
  Установить максимальное количество введённых команд
Синтаксис:
  CmdLines <Number>
Параметры:
  Number - Количество строк
}
function sge_ShellFunctions_Command_Lines(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 1;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdCommandLines', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else SGE.Shell.CommandHistory.MaxLines := i;
    end else SGE.Shell.LogMessage('CmdLines = ' + IntToStr(SGE.Shell.CommandHistory.MaxLines));
end;





{
Описание:
  Создать/удалить набор команд
Синтаксис:
  Set [Name] <Cmd1; Cmd2; CmdN>
Параметры:
  Name - Имя набора
  Cmd1; Cmd2; CmdN - Последовательность команд
Дополнительно:
  При отсутсвии параметров, набор удаляется
  При повторной установке содержимое заменяется
}
function sge_ShellFunctions_Set_Set(Cmd: PStringArray): String;
var
  Idx: Integer;
  sName, sPrm: String;
begin
  Result := '';

  sName := Trim(Cmd^[1]);
  if StringArray_Equal(Cmd, 3) then
    begin
    sPrm := Trim(Cmd^[2]);
    Idx := SGE.Shell.Sets.IndexOf(sName);
    if Idx = -1 then SGE.Shell.Sets.Add(sName, sPrm) else SGE.Shell.Sets.SetString(sName, sPrm);
    end else SGE.Shell.Sets.Delete(sName);
end;


{
Описание:
  Очистить наборы команд
Синтаксис:
  SetClear
}
function sge_ShellFunctions_Set_Clear(Cmd: PStringArray): String;
begin
  Result := '';

  SGE.Shell.Sets.Clear;
end;


{
Описание:
  Вывести список наборов
Синтаксис:
  SetList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Set_List(Cmd: PStringArray): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  if StringArray_Equal(Cmd, 2) then Mask := LowerCase(Cmd^[1]) else Mask := '';

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('SetList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  c := SGE.Shell.Sets.Count - 1;
  for i := 0 to c do
    begin
    //Определить название набора команд
    cName := SGE.Shell.Sets.Parameter[i].Name;

    //Поиск соответствия
    if Mask = '' then isAdd := True
      else begin
      Idx := Pos(Mask, LowerCase(cName));

      isAdd := False;
      case SGE.Shell.StrictSearch of
        True : if Idx = 1 then isAdd := True;
        False: if Idx > 0 then isAdd := True;
      end;
      end;

    //Вывод в оболочку
    if isAdd then
      begin
      Inc(Cnt);
      SGE.Shell.LogMessage(cName + ' = ' + SGE.Shell.Sets.Parameter[i].Value);
      end;
    end;

  //Вывод хвоста
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt));
end;


{
Описание:
  Сохранить наборы команд в файл
Синтаксис:
  SetSave [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_Set_Save(Cmd: PStringArray): String;
var
  sa: TStringArray;
  i, c: Integer;
  fn: String;
begin
  Result := '';

  //Задать имя файла
  fn := GetUserSaveFileName(Cmd^[1]);

  //Подготовить массив строк
  c := SGE.Shell.Sets.Count - 1;
  for i := 0 to c do
    StringArray_Add(@sa, 'Set ' + SGE.Shell.Sets.Parameter[i].Name + ' '#39 + SimpleCommand_SecureString(SGE.Shell.Sets.Parameter[i].Value, #1) + #39);

  //Сохранить в файл
  if not StringArray_SaveToFile(@sa, fn) then Result := sgeCreateErrorString('CmdSetSave', Err_FileWriteError, fn);

  //Почистить память
  StringArray_Clear(@sa);
end;





{
Описание:
  Очистить журнал оболочки
Синтаксис:
  Clear
}
function sge_ShellFunctions_Shell_Clear(Cmd: PStringArray): String;
begin
  Result := '';

  SGE.Shell.Journal.Clear;
end;


{
Описание:
  Включить/выключить оболочку
Синтаксис:
  Shell <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Shell_Shell(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.Shell.Enable then SGE.Shell.LogMessage('Shell = On') else SGE.Shell.LogMessage('Shell = Off');
    1: Result := sgeCreateErrorString('CmdShellShell', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Shell.Enable := True;
    3: SGE.Shell.Enable := False;
  end;
end;


{
Описание:
  Включить/выключить вывод ошибок
Синтаксис:
  LogErrors <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Shell_LogErrors(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.Shell.LogErrors then SGE.Shell.LogMessage('LogErrors = On') else SGE.Shell.LogMessage('LogErrors = Off');
    1: Result := sgeCreateErrorString('CmdShellLogErrors', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Shell.LogErrors := True;
    3: SGE.Shell.LogErrors := False;
  end;
end;


{
Описание:
  Включить/выключить строгий поис
Синтаксис:
  StrictSearch <On/Off>
Параметры:
  On/Off - Включить/выключить
Ошибки:
  1 - Невозможно определить значение
}
function sge_ShellFunctions_Shell_StrictSearch(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.Shell.StrictSearch then SGE.Shell.LogMessage('StrictSearch = On') else SGE.Shell.LogMessage('StrictSearch = Off');
    1: Result := sgeCreateErrorString('CmdShellStrictSearch', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Shell.StrictSearch := True;
    3: SGE.Shell.StrictSearch := False;
  end;
end;


{
Описание:
  Включить/выключить поиск среди наборов
Синтаксис:
  SetsSearch <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Shell_SetsSearch(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.Shell.SetsSearch then SGE.Shell.LogMessage('SetsSearch = On') else SGE.Shell.LogMessage('SetsSearch = Off');
    1: Result := sgeCreateErrorString('CmdShellSetsSearch', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Shell.SetsSearch := True;
    3: SGE.Shell.SetsSearch := False;
  end;
end;


{
Описание:
  Установить цвет фона
Синтаксис:
  BGColor <R G B A>
Параметры:
  R G B A - Цвет
}
function sge_ShellFunctions_Shell_BGColor(Cmd: PStringArray): String;
begin
  Result := '';

  case StringArray_GetCount(Cmd) of
    1:  SGE.Shell.LogMessage('BGColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.BGColor));
    2..4: Result := sgeCreateErrorString('CmdShellBGColor', Err_NotEnoughParameters);
    else SGE.Shell.BGColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Cmd));
  end;
end;


{
Описание:
  Установить цвет редактора
Синтаксис:
  EditColor <R G B A>
Параметры:
  R G B A - Цвет
}
function sge_ShellFunctions_Shell_EditColor(Cmd: PStringArray): String;
begin
  Result := '';

  case StringArray_GetCount(Cmd) of
    1:  SGE.Shell.LogMessage('EditColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.EditorColor));
    2..4: Result := sgeCreateErrorString('CmdShellEditColor', Err_NotEnoughParameters);
    else SGE.Shell.EditorColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Cmd));
  end;
end;


{
Описание:
  Установить цвет курсора
Синтаксис:
  CurColor <R G B A>
Параметры:
  R G B A - Цвет
}
function sge_ShellFunctions_Shell_CurColor(Cmd: PStringArray): String;
begin
  Result := '';

  case StringArray_GetCount(Cmd) of
    1:  SGE.Shell.LogMessage('CurColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.CursorColor));
    2..4: Result := sgeCreateErrorString('CmdShellCurColor', Err_NotEnoughParameters);
    else SGE.Shell.CursorColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Cmd));
  end;
end;


{
Описание:
  Установить цвет выделения
Синтаксис:
  SelColor <R G B A>
Параметры:
  R G B A - Цвет
}
function sge_ShellFunctions_Shell_SelColor(Cmd: PStringArray): String;
begin
  Result := '';

  case StringArray_GetCount(Cmd) of
    1:  SGE.Shell.LogMessage('SelColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.SelectColor));
    2..4: Result := sgeCreateErrorString('CmdShellSelColor', Err_NotEnoughParameters);
    else SGE.Shell.SelectColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Cmd));
  end;
end;


{
Описание:
  Установить цвет текста
Синтаксис:
  TextColor <R G B A>
Параметры:
  R G B A - Цвет
}
function sge_ShellFunctions_Shell_TextColor(Cmd: PStringArray): String;
begin
  Result := '';

  case StringArray_GetCount(Cmd) of
    1:  SGE.Shell.LogMessage('TextColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.TextColor));
    2..4: Result := sgeCreateErrorString('CmdShellTextColor', Err_NotEnoughParameters);
    else SGE.Shell.TextColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Cmd));
  end;
end;


{
Описание:
  Установить цвет заметки
Синтаксис:
  NoteColor <R G B A>
Параметры:
  R G B A - Цвет
}
function sge_ShellFunctions_Shell_NoteColor(Cmd: PStringArray): String;
begin
  Result := '';

  case StringArray_GetCount(Cmd) of
    1:  SGE.Shell.LogMessage('NoteColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.NoteColor));
    2..4: Result := sgeCreateErrorString('CmdShellNoteColor', Err_NotEnoughParameters);
    else SGE.Shell.NoteColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Cmd));
  end;
end;


{
Описание:
  Установить цвет ошибки
Синтаксис:
  ErrColor <R G B A>
Параметры:
  R G B A - Цвет
}
function sge_ShellFunctions_Shell_ErrColor(Cmd: PStringArray): String;
begin
  Result := '';

  case StringArray_GetCount(Cmd) of
    1:  SGE.Shell.LogMessage('ErrColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.ErrorColor));
    2..4: Result := sgeCreateErrorString('CmdShellErrColor', Err_NotEnoughParameters);
    else SGE.Shell.ErrorColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Cmd));
  end;
end;


{
Описание:
  Сохранить журнал в файл
Синтаксис:
  LogSave [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_Shell_LogSave(Cmd: PStringArray): String;
var
  fn: String;
begin
  Result := '';

  //Опредлить имя файла
  fn := GetUserSaveFileName(Cmd^[1]);

  //Запись в файл
  try
    SGE.Shell.Journal.SaveToFile(fn);
  except
    Result := sgeCreateErrorString('CmdShellLogSave', Err_FileWriteError, fn);
  end;
end;


{
Описание:
  Установить максимальное количество строк журнала
Синтаксис:
  LogLines <Number>
Параметры:
  Number - Количество строк
}
function sge_ShellFunctions_Shell_LogLines(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 0;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdShellLogLines', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else SGE.Shell.Journal.MaxLines := i;
    end else SGE.Shell.LogMessage('LogLines = ' + IntToStr(SGE.Shell.Journal.MaxLines));
end;


{
Описание:
  Установить максимальное количество видимых строк журнала
Синтаксис:
  VisLines <Number>
Параметры:
  Number - Количество строк
}
function sge_ShellFunctions_Shell_VisLines(Cmd: PStringArray): String;
var
  i, ml: Integer;
begin
  Result := '';

  if SGE.Graphic = nil then
    begin
    Result := sgeCreateErrorString('CmdShellVisLines', Err_GraphicNotInitialized);
    Exit;
    end;

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 0;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdShellVisLines', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else begin
      ml := sgeGetShellMaxVisibleLines(SGE.Window.ClientHeight, SGE.ShellFont.Height);
      if i > ml then i := ml;
      SGE.Shell.VisibleLines := i;
      end;
    end else SGE.Shell.LogMessage('VisLines = ' + IntToStr(SGE.Shell.VisibleLines));
end;


{
Описание:
  Установить фоновое изображение оболочки
Синтаксис:
  BGSprite <SprName>
Параметры:
  SprName - Имя спрайта в таблице ресурсов
}
function sge_ShellFunctions_Shell_BGSprite(Cmd: PStringArray): String;
var
  idx: Integer;
  s: String;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    SGE.Shell.BGSprite := TsgeGraphicSprite(SGE.Resources.TypedObj[Cmd^[1], rtGraphicSprite]);
    end
    else begin
    idx := SGE.Resources.IndexOf(SGE.Shell.BGSprite);
    if idx = -1 then s := '' else s := SGE.Resources.Item[idx].Name;
    SGE.Shell.LogMessage('BGSprite = ' + s);
    end;
end;


{
Описание:
  Включить/выключить режим сканирования клавиш
Синтаксис:
  ScanMode <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Shell_ScanMode(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.Shell.ScanMode then SGE.Shell.LogMessage('ScanMode = On') else SGE.Shell.LogMessage('ScanMode = Off');
    1: Result := sgeCreateErrorString('CmdShellScanMode', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Shell.ScanMode := True;
    3: SGE.Shell.ScanMode := False;
  end;
end;


{
Описание:
  Установить размер страницы прокрутки для журнала
Синтаксис:
  LogPageSize <Number>
Параметры:
  Number - Количество строк
}
function sge_ShellFunctions_Shell_LogPageSize(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 1;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdShellLogPageSize', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else begin
      if i < 1 then i := 1;
      SGE.Shell.JournalPageSize := i;
      end;
    end else SGE.Shell.LogMessage('LogPageSize = ' + IntToStr(SGE.Shell.JournalPageSize));
end;


{
Описание:
  Установить символ признака переменной
Синтаксис:
  SubstChar <Char>
Параметры:
  Char - Символ признака
}
function sge_ShellFunctions_Shell_SubstChar(Cmd: PStringArray): String;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then SGE.Shell.SubstChar := Cmd^[1]
    else SGE.Shell.LogMessage('SubstChar = ' + SGE.Shell.SubstChar);
end;





{
Описание:
  Переключить полноэкранный режим
Синтаксис:
  FullScreen
}
function sge_ShellFunctions_Window_FullScreen(Cmd: PStringArray): String;
begin
  Result := '';

  SGE.FullScreen;
end;


{
Описание:
  Ограничить перемещение курсора
Синтаксис:
  LockCursor <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Window_LockCursor(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.Window.ClipCursor then SGE.Shell.LogMessage('LockCursor = On') else SGE.Shell.LogMessage('LockCursor = Off');
    1: Result := sgeCreateErrorString('CmdWindowLockCursor', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Window.ClipCursor := True;
    3: SGE.Window.ClipCursor := False;
  end;
end;


{
Описание:
  Видимость системного курсора
Синтаксис:
  SysCursor <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Window_SysCursor(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.Window.ShowCursor then SGE.Shell.LogMessage('SysCursor = On') else SGE.Shell.LogMessage('SysCursor = Off');
    1: Result := sgeCreateErrorString('CmdWindowSysCursor', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Window.ShowCursor := True;
    3: SGE.Window.ShowCursor := False;
  end;
end;


{
Описание:
  Установить клиентскую ширину окна
Синтаксис:
  Width <Number>
Параметры:
  Number - Ширина в пикселях
}
function sge_ShellFunctions_Window_Width(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 0;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdWindowWidth', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else SGE.Window.ClientWidth := i;
    end
    else SGE.Shell.LogMessage('Width = ' + IntToStr(SGE.Window.ClientWidth));
end;


{
Описание:
  Установить клиентскую высоту окна
Синтаксис:
  Height <Number>
Параметры:
  Number - Высота в пикселях
}
function sge_ShellFunctions_Window_Height(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 0;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdWindowHeigth', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else SGE.Window.ClientHeight := i;
    end
    else SGE.Shell.LogMessage('Height = ' + IntToStr(SGE.Window.ClientHeight));
end;


{
Описание:
  Установить заголовок у окна
Синтаксис:
  Caption <Str>
Параметры:
  Str - Новый заголовок
}
function sge_ShellFunctions_Window_Caption(Cmd: PStringArray): String;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then SGE.Window.Caption := Cmd^[1] else
    SGE.Shell.LogMessage('Caption = ' + SGE.Window.Caption);
end;


{
Описание:
  Включить/выключить поверх всех окон
Синтаксис:
  StayOnTop <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Window_StayOnTop(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if wsTopMost in SGE.Window.Style then SGE.Shell.LogMessage('StayOnTop = On') else SGE.Shell.LogMessage('StayOnTop = Off');
    1: Result := sgeCreateErrorString('CmdWindowStayOnTop', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.Window.Style := SGE.Window.Style + [wsTopMost];
    3: SGE.Window.Style := SGE.Window.Style - [wsTopMost];
  end;
end;





{
Описание:
  Сделать снимок экрана
Синтаксис:
  ScreenShot <Name>
Параметры:
  Name - Имя файла
}
function sge_ShellFunctions_Graphic_ScreenShot(Cmd: PStringArray): String;
var
  Name, Fn, Dir: String;
begin
  Result := '';

  //Подготовить имя
  if StringArray_Equal(Cmd, 2) then Name := Cmd^[1] else Name := sgeGetUniqueFileName;
  Fn := SGE.DirShots + Name + '.' + sge_ExtShots;

  //Проверить класс графики
  if SGE.Graphic = nil then
    begin
    Result := sgeCreateErrorString('CmdGraphicScreenShot', Err_GraphicNotInitialized, Fn);
    Exit;
    end;

  //Попробывать создать каталог
  Dir := ExtractFilePath(Fn);
  try
    ForceDirectories(Dir)
  except
    Result := sgeCreateErrorString('CmdGraphicScreenShot', Err_UnableToCreateDirectory, Dir);
    Exit;
  end;

  //Запись в файл
  try
    SGE.Graphic.ScreenShot(SGE.DirShots + sgeGetUniqueFileName + '.' + sge_ExtShots);
  except
    Result := sgeCreateErrorString('CmdGraphicScreenShot', Err_FileWriteError, Fn);
  end;
end;


{
Описание:
  Установить максимальное количество кадров в секунду
Синтаксис:
  MaxFPS <Number>
Параметры:
  Number - Количество строк
}
function sge_ShellFunctions_Graphic_MaxFPS(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 0;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdGraphicMaxFPS', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else SGE.MaxFPS := i;
    end else SGE.Shell.LogMessage('MaxFPS = ' + IntToStr(SGE.MaxFPS));
end;


{
Описание:
  Включить вертикальную синхронизацию
Синтаксис:
  VSync <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Graphic_VSync(Cmd: PStringArray): String;
begin
  Result := '';

  if SGE.Graphic = nil then
    begin
    Result := sgeCreateErrorString('CmdGraphicVSync', Err_GraphicNotInitialized);
    Exit;
    end;

  try
    case sgeGetOnOffFromParam(Cmd) of
      0: if SGE.DrawControl = dcSync then SGE.Shell.LogMessage('VSync = On') else SGE.Shell.LogMessage('VSync = Off');
      1: Result := sgeCreateErrorString('CmdGraphicVSync', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
      2: SGE.DrawControl := dcSync;
      3: SGE.DrawControl := dcProgram;
    end;
  except
    Result := sgeCreateErrorString('CmdGraphicVSync', Err_VerticalSyncNotSupported);
  end;
end;


{
Описание:
  Вывести онформацию о видеодрайвере
Синтаксис:
  GraphInfo
Ошибки:
  1 - Графика не инициализирована
}
function sge_ShellFunctions_Graphic_Info(Cmd: PStringArray): String;
begin
  Result := '';

  if SGE.Graphic = nil then
    begin
    Result := sgeCreateErrorString('CmdGraphicInfo', Err_GraphicNotInitialized);
    Exit;
    end;

  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('GraphicInfo', ':');
  SGE.Shell.LogMessageLocalized('Vendor', ':');
  SGE.Shell.LogMessage('  ' + SGE.Graphic.Info[giVendor]);
  SGE.Shell.LogMessageLocalized('Renderer', ':');
  SGE.Shell.LogMessage('  ' + SGE.Graphic.Info[giRenderer]);
  SGE.Shell.LogMessageLocalized('Version', ':');
  SGE.Shell.LogMessage('  ' + SGE.Graphic.Info[giVersion]);
  SGE.Shell.LogMessageLocalized('Shader', ':');
  SGE.Shell.LogMessage('  ' + SGE.Graphic.Info[giShading]);
  SGE.Shell.LogMessageLocalized('End');
end;


{
Описание:
  Включить/выключить отрисовку
Синтаксис:
  Draw <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Graphic_Draw(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.DrawEnable then SGE.Shell.LogMessage('Draw = On') else SGE.Shell.LogMessage('Draw = Off');
    1: Result := sgeCreateErrorString('CmdGraphicDraw', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.DrawEnable := True;
    3: SGE.DrawEnable := False;
  end;
end;





{
Описание:
  Привязать команду к клавише
Синтаксис:
  Attach [Key] <Command>
Параметры:
  Key - Название кнопки
  Command - Команда
}
function sge_ShellFunctions_Attach_Attach(Cmd: PStringArray): String;
const
  ModeDown  = 0;
  ModeUp    = 1;
  ModeBouth = 2;
var
  Mode: Byte;
  KeyIdx: Integer;
  sKey, sCmd: String;
  K: TsgeCommandKey;
begin
  Result := '';

  //Подготовить переменные
  sKey := Cmd^[1];

  //Проверить на пустую строку
  if sKey = '' then
    begin
    Result := sgeCreateErrorString('CmdAttachAttach', Err_KeyNameNotFound, sKey);
    Exit;
    end;

  //Определить режим
  Mode := ModeDown;
  case sKey[1] of
    '+': Mode := ModeDown;
    '-': Mode := ModeUp;
    '*': Mode := ModeBouth;
    else
      begin
      sKey := '+' + sKey; //Добавить ключ
      Mode := ModeDown;
      end;
  end;

  //Убрать ключ из строки
  Delete(sKey, 1, 1);

  //Найти индекс
  KeyIdx := SGE.Shell.KeyTable.IndexOf(sKey);
  if KeyIdx = -1 then
    begin
    Result := sgeCreateErrorString('CmdAttachAttach', Err_KeyNameNotFound, sKey);
    Exit;
    end;

  //Проверить количество параметров
  if StringArray_Equal(Cmd, 3) then
    begin
    //Узнать текущие настройки кнопки
    K := SGE.Shell.KeyTable.Key[KeyIdx];

    //Подготовить параметр
    sCmd := Trim(Cmd^[2]);

    //Привязать
    case Mode of
      ModeDown : K.Down := sCmd;
      ModeUp   : K.Up := sCmd;
      ModeBouth:
        begin
        K.Down := sCmd;
        K.Up := sCmd;
        end;
    end;

    //Изменить значение
    SGE.Shell.KeyTable.Key[KeyIdx] := K;
    end else SGE.Shell.KeyTable.Delete(KeyIdx);   //Удалить если нехватает параметров
end;


{
Описание:
  Отвязать все клавиши от команд
Синтаксис:
  AttachClear
}
function sge_ShellFunctions_Attach_Clear(Cmd: PStringArray): String;
begin
  Result := '';

  SGE.Shell.KeyTable.Clear;
end;


{
Описание:
  Вывести список привязанных клавиш
Синтаксис:
  AttachList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Attach_List(Cmd: PStringArray): String;
var
  i, Idx, Cnt: Integer;
  Mask, Name, D, U: String;
  isAdd: Boolean;
  sa: TStringArray;
begin
  Result := '';

  //Подготовить маску
  if StringArray_Equal(Cmd, 2) then Mask := LowerCase(Cmd^[1]) else Mask := '';

  //Пробежать по массиву
  for i := 0 to 255 do
    begin
    //Пропуск пустых имён
    Name := SGE.Shell.KeyTable.GetNameByIndex(i);
    if Name = '' then Continue;

    //Пропуск если нет команд, даже если подходит под маску
    D := SGE.Shell.KeyTable.Key[i].Down;
    U := SGE.Shell.KeyTable.Key[i].Up;
    if (D = '') and (U = '') then Continue;

    //Поиск совпадения
    if Mask = '' then isAdd := True
      else begin
      isAdd := False;
      Idx := Pos(Mask, LowerCase(Name));
      case SGE.Shell.StrictSearch of
        True : if Idx = 1 then isAdd := True;
        False: if Idx > 0 then isAdd := True;
      end;
      end;

    //Добавить в массив
    if isAdd then
      begin
      if D <> '' then StringArray_Add(@sa, Name + '.Down = ' + D);
      if U <> '' then StringArray_Add(@sa, Name + '.Up = ' + U);
      end;
    end;

  //Вывод списка
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('AttachList', ': ' + Mask);
  Cnt := StringArray_GetCount(@sa) - 1;
  for i := 0 to Cnt do
    SGE.Shell.LogMessage(sa[i]);
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt + 1));

  //Почистить память
  StringArray_Clear(@sa);
end;


{
Описание:
  Сохранить привязку команд в файл
Синтаксис:
  AttachSave [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_Attach_Save(Cmd: PStringArray): String;
var
  sa: TStringArray;
  i: Integer;
  Name, s, fn: String;
begin
  Result := '';

  //Подготовить имя файла
  fn := GetUserSaveFileName(Cmd^[1]);

  //Подготовить массив строк
  for i := 0 to 255 do
    begin
    Name := SGE.Shell.KeyTable.GetNameByIndex(i);

    //Нажатие
    s := SGE.Shell.KeyTable.Key[i].Down;
    if s <> '' then StringArray_Add(@sa, 'Attach +' + Name + ' '#39 + s + #39);

    //Отпускание
    s := SGE.Shell.KeyTable.Key[i].Up;
    if s <> '' then StringArray_Add(@sa, 'Attach -' + Name + ' '#39 + s + #39);
    end;

  //Сохранить в файл
  if not StringArray_SaveToFile(@sa, fn) then Result := sgeCreateErrorString('CmdAttachSave', Err_FileWriteError, fn);

  //Почистить память
  StringArray_Clear(@sa);
end;


{
Описание:
  Вывести список имён клавиш
Синтаксис:
  KeyList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Attach_KeyList(Cmd: PStringArray): String;
var
  i, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  if StringArray_Equal(Cmd, 2) then Mask := LowerCase(Cmd^[1]) else Mask := '';

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('KeyList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  for i := 0 to $FF do
    begin
    //Определить название кнопки
    cName := SGE.Shell.KeyTable.GetNameByIndex(i);
    if cName = '' then Continue;


    //Поиск соответствия
    if Mask = '' then isAdd := True
      else begin
      Idx := Pos(Mask, LowerCase(cName));

      isAdd := False;
      case SGE.Shell.StrictSearch of
        True : if Idx = 1 then isAdd := True;
        False: if Idx > 0 then isAdd := True;
      end;
      end;

    //Вывод в оболочку
    if isAdd then
      begin
      Inc(Cnt);
      SGE.Shell.LogMessage(cName);
      end;
    end;

  //Вывод хвоста
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt));
end;





{
Описание:
  Включить/выключить опрос джойстиков
Синтаксис:
  Joysticks <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Joysticks_Joysticks(Cmd: PStringArray): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Cmd) of
    0: if SGE.JoysticksEnable then SGE.Shell.LogMessage('Joysticks = On') else SGE.Shell.LogMessage('Joysticks = Off');
    1: Result := sgeCreateErrorString('CmdJoysticksJoystics', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1));
    2: SGE.JoysticksEnable := True;
    3: SGE.JoysticksEnable := False;
  end;
end;


{
Описание:
  Установить задержку между опросами джойстиков
Синтаксис:
  JoyDelay <Number>
Параметры:
  Number - Задержка
}
function sge_ShellFunctions_Joysticks_Delay(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 1;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdJoysticksDelay', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else SGE.JoysticksDelay := i;
    end else SGE.Shell.LogMessage('JoyDelay = ' + IntToStr(SGE.JoysticksDelay));
end;





{
Описание:
  Установить имя шрифта оболочки
Синтаксис:
  FontName <Name>
Параметры:
 NewName - Имя шрифта
}
function sge_ShellFunctions_Font_Name(Cmd: PStringArray): String;
begin
  Result := '';

  if SGE.Graphic = nil then
    begin
    Result := sgeCreateErrorString('CmdFontName', Err_GraphicNotInitialized);
    Exit;
    end;

  if StringArray_Equal(Cmd, 2) then
    begin
    if Cmd^[1] <> '' then SGE.ShellFont.Name := Cmd^[1];
    end else SGE.Shell.LogMessage('FontName = ' + SGE.ShellFont.Name);
end;


{
Описание:
  Установить размер шрифта
Синтаксис:
  FontSize <Size>
Параметры:
  Size - Размер
}
function sge_ShellFunctions_Font_Size(Cmd: PStringArray): String;
var
  i: Integer;
begin
  Result := '';

  if SGE.Graphic = nil then
    begin
    Result := sgeCreateErrorString('CmdFontSize', Err_GraphicNotInitialized);
    Exit;
    end;

  if StringArray_Equal(Cmd, 2) then
    begin
    i := 0;
    if not TryStrToInt(Cmd^[1], i) then Result := sgeCreateErrorString('CmdFontSize', Err_UnableToDetermineValue, StringArray_GetPart(Cmd, 1))
      else begin
      //Изменить высоту шрифта
      if i < 1 then i := 1;
      SGE.ShellFont.Height := i;

      //Поправить количество видимых линий
      i := SGE.Window.ClientHeight div SGE.ShellFont.Height;
      if SGE.Shell.VisibleLines > i - 1 then SGE.Shell.VisibleLines := i - 1;
      end;
    end else SGE.Shell.LogMessage('FontSize = ' + IntToStr(SGE.ShellFont.Height));
end;


{
Описание:
  Установить атрибуты шрифта оболочки
Синтаксис:
  FontAttrib <[]/B/I/U/S>
Параметры:
  []/B/I/U/S - Атрибуты шрифта
}
function sge_ShellFunctions_Font_Attrib(Cmd: PStringArray): String;
var
  fa: TsgeGraphicFontAttrib;
  s: String;
begin
  Result := '';

  if SGE.Graphic = nil then
    begin
    Result := sgeCreateErrorString('CmdFontAttrib', Err_GraphicNotInitialized);
    Exit;
    end;

  if StringArray_Equal(Cmd, 2) then
    begin
    fa := [];
    s := LowerCase(Cmd^[1]);
    if Pos('b', s) > 0 then Include(fa, gfaBold);
    if Pos('i', s) > 0 then Include(fa, gfaItalic);
    if Pos('u', s) > 0 then Include(fa, gfaUnderline);
    if Pos('s', s) > 0 then Include(fa, gfaStrikeOut);
    if Pos('[]', s) > 0 then fa := [];
    SGE.ShellFont.Attrib := fa;
    end
    else begin
    s := '';
    if (gfaBold in SGE.ShellFont.Attrib) then s := s + 'B';
    if (gfaItalic in SGE.ShellFont.Attrib) then s := s + 'I';
    if (gfaUnderline in SGE.ShellFont.Attrib) then s := s + 'U';
    if (gfaStrikeOut in SGE.ShellFont.Attrib) then s := s + 'S';
    s := '[' + s + ']';
    SGE.Shell.LogMessage('FontAttrib = ' + s);
    end;
end;





{
Описание:
  Очистить список параметров
Синтаксис:
  ParamClear
}
function sge_ShellFunctions_Parameters_Clear(Cmd: PStringArray): String;
begin
  Result := '';

  SGE.Parameters.Clear;
end;


{
Описание:
  Вывести список параметров
Синтаксис:
  ParamList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Parameters_List(Cmd: PStringArray): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  if StringArray_Equal(Cmd, 2) then Mask := LowerCase(Cmd^[1]) else Mask := '';

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('ParameterList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  c := SGE.Parameters.Count - 1;
  for i := 0 to c do
    begin
    cName := SGE.Parameters.Parameter[i].Name;

    //Поиск соответствия
    if Mask = '' then isAdd := True
      else begin
      Idx := Pos(Mask, LowerCase(cName));

      isAdd := False;
      case SGE.Shell.StrictSearch of
        True : if Idx = 1 then isAdd := True;
        False: if Idx > 0 then isAdd := True;
      end;
      end;

    //Вывод в оболочку
    if isAdd then
      begin
      Inc(Cnt);
      SGE.Shell.LogMessage(cName + ' = ' + SGE.Parameters.Parameter[i].Value);
      end;
    end;

  //Вывод хвоста
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt));
end;


{
Описание:
  Изменить параметр
Синтаксис:
  ParamSet [Name] <Value>
Параметры:
  Name  - Имя параметра
  Value - Значение параметра
Дополнительно:
  Параметр добавляется при отсутствии в массиве
}
function sge_ShellFunctions_Parameters_Set(Cmd: PStringArray): String;
var
  Idx: Integer;
  Name, Value: String;
begin
  Result := '';

  //Подготовить имя и значение
  Name := Cmd^[1];
  if StringArray_Equal(Cmd, 3) then Value := Cmd^[2] else Value := '';

  //Найти индекс
  Idx := SGE.Parameters.IndexOf(Name);

  //Изменить параметр
  if Idx <> -1 then
    begin
    Name := SGE.Parameters.Parameter[Idx].Name;
    SGE.Parameters.SetString(Name, Value);
    end else SGE.Parameters.Add(Name, Value);
end;


{
Описание:
  Удалить параметр
Синтаксис:
  ParamDel [Name]
Параметры:
  Name  - Имя параметра
}
function sge_ShellFunctions_Parameters_Delete(Cmd: PStringArray): String;
begin
  Result := '';

  if not SGE.Parameters.Delete(Cmd^[1]) then Result := sgeCreateErrorString('CmdParametersDelete', Err_ParameterNotFound, Cmd^[1]);
end;


{
Описание:
  Сохранить параметры в файл
Синтаксис:
  ParamSave [FileName] <U/A>
Параметры:
  FileName - Имя файла
  U/A      - Модификаторы ("U" Обновить, "A" Обновить и добавить)
}
function sge_ShellFunctions_Parameters_Save(Cmd: PStringArray): String;
const
  mSave = 0;
  mUpdate = 1;
  mUpdateAdd = 2;
var
  fn, s: String;
  Mode: Byte;
begin
  Result := '';

  //Определить имя файла
  fn := GetUserSaveFileName(Cmd^[1]);

  //Определить режим
  Mode := mSave;
  if StringArray_Equal(Cmd, 3) then
    begin
    s := LowerCase(Cmd^[2]);
    if s = 'u' then Mode := mUpdate;
    if s = 'a' then Mode := mUpdateAdd;
    end;

  //Сохранить в файл
  try
    case Mode of
      mSave: SGE.Parameters.SaveToFile(fn);
      mUpdate: SGE.Parameters.UpdateInFile(fn);
      mUpdateAdd: SGE.Parameters.UpdateInFile(fn, True);
    end;
  except
    Result := sgeCreateErrorString('CmdParametersSave', Err_FileWriteError, fn);
  end;
end;


{
Описание:
  Загрузить параметры из файл
Синтаксис:
  ParamLoad [FileName] <U/A>
Параметры:
  FileName - Имя файла
  U/A      - Модификаторы ("U" Обновить, "A" Обновить и добавить)
}
function sge_ShellFunctions_Parameters_Load(Cmd: PStringArray): String;
const
  mLoad = 0;
  mUpdate = 1;
  mUpdateAdd = 2;
var
  fn, s: String;
  Mode: Byte;
begin
  Result := '';

  //Определить имя файла
  fn := GetUserLoadFileName(Cmd^[1]);

  //Определить режим
  Mode := mLoad;
  if StringArray_Equal(Cmd, 3) then
    begin
    s := LowerCase(Cmd^[2]);
    if s = 'u' then Mode := mUpdate;
    if s = 'a' then Mode := mUpdateAdd;
    end;

  //Прочитать из файла
  try
    case Mode of
      mLoad: SGE.Parameters.LoadFromFile(fn);
      mUpdate: SGE.Parameters.UpdateFromFile(fn);
      mUpdateAdd: SGE.Parameters.UpdateFromFile(fn, True);
    end;
  except
    Result := sgeCreateErrorString('CmdParametersLoad', Err_FileReadError, fn);;
  end;
end;










/////////////////////////////////////////////////////////////////////
//                Регистрация Функций оболочки                     //
/////////////////////////////////////////////////////////////////////
procedure sgeShellFunctions_RegisterCommand(SGEPtr: TObject);
begin
  //Запомнить указатель на объект
  SGE := TSimpleGameEngine(SGEPtr);

  //Добавить команды в хранилище
  with SGE.Shell.Commands do
    begin
    //Системные
    Add('System', 'Name', @sge_ShellFunctions_System_Name, 0);
    Add('System', 'Stop', @sge_ShellFunctions_System_Stop, 0);
    Add('System', 'Close', @sge_ShellFunctions_System_Stop, 0);
    Add('System', 'Quit', @sge_ShellFunctions_System_Stop, 0);
    Add('System', 'Version', @sge_ShellFunctions_System_Version, 0);
    Add('System', 'Run', @sge_ShellFunctions_System_Run, 1);
    Add('System', 'Exec', @sge_ShellFunctions_System_Run, 1);
    Add('System', 'Write', @sge_ShellFunctions_System_Write, 0);
    Add('System', 'Echo', @sge_ShellFunctions_System_Write, 0);
    Add('System', 'Print', @sge_ShellFunctions_System_Write, 0);
    Add('System', 'Writec', @sge_ShellFunctions_System_Writec, 5);
    Add('System', 'Echoc', @sge_ShellFunctions_System_Writec, 5);
    Add('System', 'Printc', @sge_ShellFunctions_System_Writec, 5);
    Add('System', 'Help', @sge_ShellFunctions_System_Help, 0);
    Add('System', 'Debug', @sge_ShellFunctions_System_Debug, 0);
    Add('System', 'Tick', @sge_ShellFunctions_System_Tick, 0);
    Add('System', 'TickDelay', @sge_ShellFunctions_System_TickDelay, 0);
    Add('System', 'StartParams', @sge_ShellFunctions_System_StartParams, 0);
    Add('System', 'LoadLanguage', @sge_ShellFunctions_System_LoadLanguage, 1);

    //Команды
    Add('Command', 'CmdList', @sge_ShellFunctions_Command_List, 0);
    Add('Command', 'CmdSave', @sge_ShellFunctions_Command_Save, 1);
    Add('Command', 'CmdLoad', @sge_ShellFunctions_Command_Load, 1);
    Add('Command', 'CmdLines', @sge_ShellFunctions_Command_Lines, 0);

    //Наборы
    Add('Set', 'Set', @sge_ShellFunctions_Set_Set, 1);
    Add('Set', 'SetClear', @sge_ShellFunctions_Set_Clear, 0);
    Add('Set', 'SetList', @sge_ShellFunctions_Set_List, 0);
    Add('Set', 'SetSave', @sge_ShellFunctions_Set_Save, 1);

    //Оболочка
    Add('Shell', 'Clear', @sge_ShellFunctions_Shell_Clear, 0);
    Add('Shell', 'Shell', @sge_ShellFunctions_Shell_Shell, 0);
    Add('Shell', 'LogErrors', @sge_ShellFunctions_Shell_LogErrors, 0);
    Add('Shell', 'StrictSearch', @sge_ShellFunctions_Shell_StrictSearch, 0);
    Add('Shell', 'SetsSearch', @sge_ShellFunctions_Shell_SetsSearch, 0);
    Add('Shell', 'BGColor', @sge_ShellFunctions_Shell_BGColor, 0);
    Add('Shell', 'EditColor', @sge_ShellFunctions_Shell_EditColor, 0);
    Add('Shell', 'CurColor', @sge_ShellFunctions_Shell_CurColor, 0);
    Add('Shell', 'SelColor', @sge_ShellFunctions_Shell_SelColor, 0);
    Add('Shell', 'TextColor', @sge_ShellFunctions_Shell_TextColor, 0);
    Add('Shell', 'NoteColor', @sge_ShellFunctions_Shell_NoteColor, 0);
    Add('Shell', 'ErrColor', @sge_ShellFunctions_Shell_ErrColor, 0);
    Add('Shell', 'LogSave', @sge_ShellFunctions_Shell_LogSave, 1);
    Add('Shell', 'LogLines', @sge_ShellFunctions_Shell_LogLines, 0);
    Add('Shell', 'VisLines', @sge_ShellFunctions_Shell_VisLines, 0);
    Add('Shell', 'BGSprite', @sge_ShellFunctions_Shell_BGSprite, 0);
    Add('Shell', 'ScanMode', @sge_ShellFunctions_Shell_ScanMode, 0);
    Add('Shell', 'LogPageSize', @sge_ShellFunctions_Shell_LogPageSize, 0);
    Add('Shell', 'SubstChar', @sge_ShellFunctions_Shell_SubstChar, 0);

    //Окно
    Add('Window', 'FullScreen', @sge_ShellFunctions_Window_FullScreen, 0);
    Add('Window', 'LockCursor', @sge_ShellFunctions_Window_LockCursor, 0);
    Add('Window', 'SysCursor', @sge_ShellFunctions_Window_SysCursor, 0);
    Add('Window', 'Width', @sge_ShellFunctions_Window_Width, 0);
    Add('Window', 'Height', @sge_ShellFunctions_Window_Height, 0);
    Add('Window', 'Caption', @sge_ShellFunctions_Window_Caption, 0);
    Add('Window', 'StayOnTop', @sge_ShellFunctions_Window_StayOnTop, 0);

    //Графика
    Add('Graphic', 'ScreenShot', @sge_ShellFunctions_Graphic_ScreenShot, 0);
    Add('Graphic', 'MaxFPS', @sge_ShellFunctions_Graphic_MaxFPS, 0);
    Add('Graphic', 'VSync', @sge_ShellFunctions_Graphic_VSync, 0);
    Add('Graphic', 'GraphInfo', @sge_ShellFunctions_Graphic_Info, 0);
    Add('Graphic', 'Draw', @sge_ShellFunctions_Graphic_Draw, 0);

    //Клавиши
    Add('Attach', 'Attach', @sge_ShellFunctions_Attach_Attach, 1);
    Add('Attach', 'AttachClear', @sge_ShellFunctions_Attach_Clear, 0);
    Add('Attach', 'AttachList', @sge_ShellFunctions_Attach_List, 0);
    Add('Attach', 'AttachSave', @sge_ShellFunctions_Attach_Save, 1);
    Add('Attach', 'KeyList', @sge_ShellFunctions_Attach_KeyList, 0);

    //Джойстики
    Add('Joysticks', 'Joysticks', @sge_ShellFunctions_Joysticks_Joysticks, 0);
    Add('Joysticks', 'JoyDelay', @sge_ShellFunctions_Joysticks_Delay, 0);

    //Шрифт
    Add('Font', 'FontName', @sge_ShellFunctions_Font_Name, 0);
    Add('Font', 'FontSize', @sge_ShellFunctions_Font_Size, 0);
    Add('Font', 'FontAttrib', @sge_ShellFunctions_Font_Attrib, 0);

    //Параметры
    Add('Parameters', 'ParamClear', @sge_ShellFunctions_Parameters_Clear, 0);
    Add('Parameters', 'ParamList', @sge_ShellFunctions_Parameters_List, 0);
    Add('Parameters', 'ParamSet', @sge_ShellFunctions_Parameters_Set, 1);
    Add('Parameters', 'ParamDel', @sge_ShellFunctions_Parameters_Delete, 1);
    Add('Parameters', 'ParamSave', @sge_ShellFunctions_Parameters_Save, 1);
    Add('Parameters', 'ParamLoad', @sge_ShellFunctions_Parameters_Load, 1);
    end;
end;





end.


