{
Пакет             Simple Game Engine 1
Файл              sgeShellFunctions.pas
Версия            1.23
Создан            09.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Функции оболочки
}

unit sgeShellFunctions;

{$mode objfpc}{$H+}{$Warnings Off}{$Hints Off}

interface


procedure sgeShellFunctions_RegisterCommand;


implementation

uses
  SimpleGameEngine, sgeConst, sgeTypes, sgeObjectList, sgeStringList, sgeSimpleCommand,
  sgeMemoryStream, sgeGraphicColor, sgeGraphic, sgeWindow, sgeGraphicFont, sgeGraphicSprite,
  sgeKeyTable, sgeResourceList, sgeSystemFont, sgeSoundBuffer, sgeSimpleParameters, sgeTask,
  SysUtils;


var
  SGE: TSimpleGameEngine;




//Вернуть имя файла для загрузки с учётом папки пользователя
function GetUserLoadFileName(FileName: String): String;
begin
  Result := FileName;

  if SGE.FileSystem.FileExists(SGE.DirUser + FileName) then Result := SGE.DirUser + FileName;
end;


//Вернуть имя файла для сохранения с учётом папки пользователя
function GetUserSaveFileName(FileName: String): String;
var
  Dir: String;
begin
  Result := FileName;

  try
    Dir := SGE.DirUser + ExtractFilePath(FileName);
    SGE.FileSystem.ForceDirectories(Dir);
  except
    Exit;
  end;

  Result := SGE.DirUser + FileName;
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
function sge_ShellFunctions_System_Name(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    if Command.Part[1] <> '' then SGE.UserName := Command.Part[1];
    end else SGE.Shell.LogMessage('Name = ' + SGE.UserName);
end;


{
Описание:
  Остановить движок
Синтаксис:
  Stop
}
function sge_ShellFunctions_System_Stop(Command: TsgeSimpleCommand): String;
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
function sge_ShellFunctions_System_Version(Command: TsgeSimpleCommand): String;
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
function sge_ShellFunctions_System_Run(Command: TsgeSimpleCommand): String;
var
  List: TsgeStringList;
  c, i: Integer;
  fn: String;
  Ms: TsgeMemoryStream;
begin
  Result := '';

  try
    Ms := TsgeMemoryStream.Create;
    List := TsgeStringList.Create;
    fn := GetUserLoadFileName(Command.Part[1]);

    //Загрузка из файла
    try
      SGE.FileSystem.ReadFile(fn, Ms);
      List.FromMemoryStream(Ms);
    except
      Result := sgeCreateErrorString('CmdSystemRun', Err_FileReadError, fn);
    end;

    //Выполнить список команд
    c := List.Count - 1;
    for i := 0 to c do
      SGE.Shell.DoCommand(Trim(List.Part[i]));

  finally
    Ms.Free;
    List.Free;
  end;
end;


{
Описание:
  Вывести строку в журнал
Синтаксис:
  Write <Message>
Параметры:
  Message - Сообщение
}
function sge_ShellFunctions_System_Write(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  SGE.Shell.LogMessage(Command.GetTail(1));
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
function sge_ShellFunctions_System_Writec(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  SGE.Shell.Journal.Add(sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Command)), Command.GetTail(5));
end;


{
Описание:
  Вывести информацию о команде
Синтаксис:
  Help <CmdName>
Параметры:
  CmdName - Имя команды
}
function sge_ShellFunctions_System_Help(Command: TsgeSimpleCommand): String;
var
  hInfo, hSyntax, hHint, hGroup, cName, s: String;
  PrmCnt, i: Integer;
begin
  Result := '';

  //Проверить количество параметров
  if Command.Count < 2 then
    begin
    SGE.Shell.LogHelpHint;
    Exit;
    end;

  //Начальные переменные
  hInfo := '';
  hSyntax := '';
  hHint := '';
  PrmCnt := 0;
  cName := Trim(Command.Part[1]);

  //Поиск группы
  hGroup := '';
  i := SGE.Shell.Commands.IndexOf(cName);
  if i <> -1 then hGroup := SGE.Shell.Commands.Command[i].Group;

  //Поиск языковых констант
  hInfo := SGE.Language.GetValue('Help:' + cName + '.Info', '');
  hSyntax := SGE.Language.GetValue('Help:' + cName + '.Syntax', '');
  hHint := SGE.Language.GetValue('Help:' + cName + '.Hint', '');
  PrmCnt := SGE.Language.GetValue('Help:' + cName + '.ParamCount', 0);

  //Вывод сведений
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('Help', ': ' + cName);

  if hGroup <> '' then
    begin
    SGE.Shell.LogMessageLocalized('Group', ':');
    SGE.Shell.LogMessage('  ' + hGroup);
    end;

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
      s := SGE.Language.GetValue('Help:' + cName + '.Param.' + IntToStr(i), '');
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
function sge_ShellFunctions_System_Debug(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.Debug then SGE.Shell.LogMessage('Debug = On') else SGE.Shell.LogMessage('Debug = Off');
    1: Result := sgeCreateErrorString('CmdSystemDebug', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
    2: SGE.Debug := True;
    3: SGE.Debug := False;
  end;
end;


{
Описание:
  Вывести список стартовых параметров
Синтаксис:
  StartParams
}
function sge_ShellFunctions_System_StartParams(Command: TsgeSimpleCommand): String;
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
function sge_ShellFunctions_System_LoadLanguage(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdSystemLoadLanguage';
var
  fn: String;
  Mode: TsgeLoadMode;
begin
  Result := '';

  //Подготовить имя файла
  fn := GetUserLoadFileName(Command.Part[1]);

  //Определить режим
  Mode := lmReplace;
  if Command.Count >= 3 then
    case LowerCase(Command.Part[2]) of
      'add'    : Mode := lmAdd;
      'replace': Mode := lmReplace;
      else begin
      Result := sgeCreateErrorString(PROCNAME, Err_UnableToDetermineMode, Command.Part[2]);
      Exit;
      end;
    end;

  //Загрузить
  try
    SGE.LoadLanguage(fn, Mode);
  except
    Result := sgeCreateErrorString(PROCNAME, Err_FileReadError, fn);
  end;
end;


{
Описание:
  Изменить приритет приложения
Синтаксис:
  Priority <Priotity>
Параметры:
  Priotity - Приоритет (Idle, BelowNormal, Normal, AboveNormal, High, RealTime)
}
function sge_ShellFunctions_System_Priority(Command: TsgeSimpleCommand): String;
var
  P: TsgePriority;
  S: String;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    case LowerCase(Command.Part[1]) of
      'idle'        : P := pIdle;
      'belownormal' : P := pBelowNormal;
      'normal'      : P := pNormal;
      'abovenormal' : P := pAboveNormal;
      'high'        : P := pHigh;
      'realtime'    : P := pRealTime;
      else begin
      Result := sgeCreateErrorString('CmdSystemPriority', Err_UnableToDetermineValue, Command.Part[1]);
      Exit;
      end;
    end;

    SGE.Priority := P;
    end
    else begin
    case SGE.Priority of
      pIdle        : S := 'Idle';
      pBelowNormal : S := 'BelowNormal';
      pNormal      : S := 'Normal';
      pAboveNormal : S := 'AboveNormal';
      pHigh        : S := 'High';
      pRealTime    : S := 'RealTime';
    end;

    SGE.Shell.LogMessage('Proirity = ' + S);
    end;
end;





{
Описание:
  Включить/выключить планировщик задач
Синтаксис:
  Tasks <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Tasks_Task(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.TaskEnable then SGE.Shell.LogMessage('Task = On') else SGE.Shell.LogMessage('Task = Off');
    1: Result := sgeCreateErrorString('CmdTaskTask', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
    2: SGE.TaskEnable := True;
    3: SGE.TaskEnable := False;
  end;
end;


{
Описание:
  Установить задержку планировщику задач
Синтаксис:
  TaskDelay <Delay>
Параметры:
  Delay - Задержка
}
function sge_ShellFunctions_Task_Delay(Command: TsgeSimpleCommand): String;
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 1;
    if not TryStrToInt(Command.Part[1], i) then
      Result := sgeCreateErrorString('CmdTaskDelay', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
        else SGE.TaskDelay := i;
    end
    else SGE.Shell.LogMessage('TaskDelay = ' + IntToStr(SGE.TaskDelay));
end;


{
Описание:
  Вывести список задач
Синтаксис:
  TaskList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Task_List(Command: TsgeSimpleCommand): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('TaskList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  c := SGE.TaskList.Count - 1;
  for i := 0 to c do
    begin
    //Определить название задачи
    cName := SGE.TaskList.Task[i].Name;

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
  Вывести подробную информацию о задаче
Синтаксис:
  TaskInfo [TaskName]
Параметры:
  TaskName - Имя задачи
}
function sge_ShellFunctions_Task_Info(Command: TsgeSimpleCommand): String;
var
  cOn, cOff, cInf, cName, s: String;
  Idx: Integer;
  Tsk: TsgeTask;
begin
  Result := '';

  //Определить имя
  cName := sgeGetPartFromCommand(Command, 1);

  //Найти индекс
  Idx := SGE.TaskList.IndexOf(cName);
  if Idx = -1 then
    begin
    Result := sgeCreateErrorString('CmdTaskInfo', Err_NameNotFound, cName);
    Exit;
    end;

  //Подготовить переменные
  Tsk := SGE.TaskList.Task[Idx];
  cOn := SGE.Language.GetValue('Cmd:On', 'On');
  cOff := SGE.Language.GetValue('Cmd:Off', 'Off');


  //Вывод сведений
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('TaskInfo', ': ' + cName);

  //Имя
  SGE.Shell.LogMessageLocalized('Name', ':');
  SGE.Shell.LogMessage('  ' + Tsk.Name);

  //Задержка
  SGE.Shell.LogMessageLocalized('Delay', ':');
  SGE.Shell.LogMessage('  ' + IntToStr(Tsk.Delay));

  //Активность
  if Tsk.Enable then s := cOn else s := cOff;
  SGE.Shell.LogMessageLocalized('Enable', ':');
  SGE.Shell.LogMessage('  ' + s);

  //Максимальное количество срабатываний
  if Tsk.Times = -1 then
    begin
    cInf := 'Infinity';
    cInf := SGE.Language.GetValue('Cmd:' + cInf, cInf);
    end else cInf := IntToStr(Tsk.Times);
  SGE.Shell.LogMessageLocalized('Times', ':');
  SGE.Shell.LogMessage('  ' + cInf);

  //Задержка перед запуском
  SGE.Shell.LogMessageLocalized('StartDelay', ':');
  SGE.Shell.LogMessage('  ' + IntToStr(Tsk.StartDelay));

  //Автоудаление
  if Tsk.AutoDelete then s := cOn else s := cOff;
  SGE.Shell.LogMessageLocalized('AutoDelete', ':');
  SGE.Shell.LogMessage('  ' + s);

  //Всего сработано
  SGE.Shell.LogMessageLocalized('TimesCount', ':');
  SGE.Shell.LogMessage('  ' + IntToStr(Tsk.Count));


  SGE.Shell.LogMessageLocalized('End');
end;


{
Описание:
  Удалить задачу
Синтаксис:
  TaskDelete [TaskName]
Параметры:
  TaskName - Имя задачи
}
function sge_ShellFunctions_Task_Delete(Command: TsgeSimpleCommand): String;
var
  cName: String;
begin
  Result := '';

  cName := sgeGetPartFromCommand(Command, 1);

  try
    SGE.TaskList.Delete(cName);
  except
    Result := sgeCreateErrorString('CmdTaskDelete', Err_NameNotFound, cName);
  end;
end;


{
Описание:
  Остановить задачу
Синтаксис:
  TaskStop [TaskName]
Параметры:
  TaskName - Имя задачи
}
function sge_ShellFunctions_Task_Stop(Command: TsgeSimpleCommand): String;
var
  cName: String;
begin
  Result := '';

  cName := sgeGetPartFromCommand(Command, 1);

  try
    SGE.TaskList.NamedTask[cName].Stop;
  except
    Result := sgeCreateErrorString('CmdTaskStop', Err_NameNotFound, cName);
  end;
end;


{
Описание:
  Возобновить задачу
Синтаксис:
  TaskStart [TaskName]
Параметры:
  TaskName - Имя задачи
}
function sge_ShellFunctions_Task_Start(Command: TsgeSimpleCommand): String;
var
  cName: String;
begin
  Result := '';

  cName := sgeGetPartFromCommand(Command, 1);

  try
    SGE.TaskList.NamedTask[cName].Start;
  except
    Result := sgeCreateErrorString('CmdTaskStart', Err_NameNotFound, cName);
  end;
end;


{
Описание:
  Перезапустить задачу
Синтаксис:
  TaskRestart [TaskName]
Параметры:
  TaskName - Имя задачи
}
function sge_ShellFunctions_Task_Restart(Command: TsgeSimpleCommand): String;
var
  cName: String;
begin
  Result := '';

  cName := sgeGetPartFromCommand(Command, 1);

  try
    SGE.TaskList.NamedTask[cName].Restart;
  except
    Result := sgeCreateErrorString('CmdTaskRestart', Err_NameNotFound, cName);
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
function sge_ShellFunctions_Command_List(Command: TsgeSimpleCommand): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, s, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

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
      s := SGE.Language.GetValue('Help:' + cName + '.Info', '');
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
function sge_ShellFunctions_Command_Save(Command: TsgeSimpleCommand): String;
var
  fn: String;
  Ms: TsgeMemoryStream;
begin
  Result := '';

  try
    Ms := TsgeMemoryStream.Create;
    fn := GetUserSaveFileName(Command.Part[1]);
    SGE.Shell.CommandHistory.ToMemoryStream(Ms);

    try
      SGE.FileSystem.WriteFile(fn, Ms);
    except
      Result := sgeCreateErrorString('CmdCommandSave', Err_FileWriteError, fn);
    end;

  finally
    Ms.Free;
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
function sge_ShellFunctions_Command_Load(Command: TsgeSimpleCommand): String;
var
  fn: String;
  Ms: TsgeMemoryStream;
begin
  Result := '';

  try
    Ms := TsgeMemoryStream.Create;
    fn := GetUserLoadFileName(Command.Part[1]);

    try
      SGE.FileSystem.ReadFile(fn, Ms);
    except
      Result := sgeCreateErrorString('CmdCommandLoad', Err_FileReadError, fn);
    end;

    SGE.Shell.CommandHistory.FromMemoryStream(Ms);

  finally
    Ms.Free;
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
function sge_ShellFunctions_Command_Lines(Command: TsgeSimpleCommand): String;
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 1;
    if not TryStrToInt(Command.Part[1], i) then
      Result := sgeCreateErrorString('CmdCommandLines', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
        else SGE.Shell.CommandHistory.MaxLines := i;
    end
    else SGE.Shell.LogMessage('CmdLines = ' + IntToStr(SGE.Shell.CommandHistory.MaxLines));
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
function sge_ShellFunctions_Set_Set(Command: TsgeSimpleCommand): String;
var
  sName: String;
begin
  Result := '';

  sName := Trim(Command.Part[1]);
  if Command.Count >= 3 then
    begin
    SGE.Shell.Sets.SetValue(sName, Command.GetTail(2));
    end else SGE.Shell.Sets.Delete(sName);
end;


{
Описание:
  Очистить наборы команд
Синтаксис:
  SetClear
}
function sge_ShellFunctions_Set_Clear(Command: TsgeSimpleCommand): String;
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
function sge_ShellFunctions_Set_List(Command: TsgeSimpleCommand): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

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
function sge_ShellFunctions_Set_Save(Command: TsgeSimpleCommand): String;
var
  List: TsgeStringList;
  Ms: TsgeMemoryStream;
  i, c: Integer;
  fn, s: String;
begin
  Result := '';

  try
    Ms := TsgeMemoryStream.Create;
    List := TsgeStringList.Create;
    fn := GetUserSaveFileName(Command.Part[1]);

    //Подготовить данные
    c := SGE.Shell.Sets.Count - 1;
    for i := 0 to c do
      begin
      s := SGE.Shell.Sets.Parameter[i].Name + #32 + SGE.Shell.Sets.Parameter[i].Value;
      List.Add(s);
      end;
    List.ToMemoryStream(Ms);

    //Сохранить в файл
    try
      SGE.FileSystem.WriteFile(fn, Ms);
    except
      Result := sgeCreateErrorString('CmdSetSave', Err_FileWriteError, fn);
    end;


  finally
    List.Free;
    Ms.Free;
  end;
end;





{
Описание:
  Очистить журнал оболочки
Синтаксис:
  Clear
}
function sge_ShellFunctions_Shell_Clear(Command: TsgeSimpleCommand): String;
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
function sge_ShellFunctions_Shell_Shell(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.Shell.Enable then SGE.Shell.LogMessage('Shell = On') else SGE.Shell.LogMessage('Shell = Off');
    1: Result := sgeCreateErrorString('CmdShellShell', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Shell_LogErrors(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.Shell.LogErrors then SGE.Shell.LogMessage('LogErrors = On') else SGE.Shell.LogMessage('LogErrors = Off');
    1: Result := sgeCreateErrorString('CmdShellLogErrors', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Shell_StrictSearch(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.Shell.StrictSearch then SGE.Shell.LogMessage('StrictSearch = On') else SGE.Shell.LogMessage('StrictSearch = Off');
    1: Result := sgeCreateErrorString('CmdShellStrictSearch', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Shell_SetsSearch(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.Shell.SetsSearch then SGE.Shell.LogMessage('SetsSearch = On') else SGE.Shell.LogMessage('SetsSearch = Off');
    1: Result := sgeCreateErrorString('CmdShellSetsSearch', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Shell_BGColor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case Command.Count of
    1:  SGE.Shell.LogMessage('BGColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.BGColor));
    2..4: Result := sgeCreateErrorString('CmdShellBGColor', Err_NotEnoughParameters);
    else SGE.Shell.BGColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Command));
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
function sge_ShellFunctions_Shell_EditColor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case Command.Count of
    1:  SGE.Shell.LogMessage('EditColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.EditorColor));
    2..4: Result := sgeCreateErrorString('CmdShellEditColor', Err_NotEnoughParameters);
    else SGE.Shell.EditorColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Command));
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
function sge_ShellFunctions_Shell_CurColor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case Command.Count of
    1:  SGE.Shell.LogMessage('CurColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.CursorColor));
    2..4: Result := sgeCreateErrorString('CmdShellCurColor', Err_NotEnoughParameters);
    else SGE.Shell.CursorColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Command));
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
function sge_ShellFunctions_Shell_SelColor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case Command.Count of
    1:  SGE.Shell.LogMessage('SelColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.SelectColor));
    2..4: Result := sgeCreateErrorString('CmdShellSelColor', Err_NotEnoughParameters);
    else SGE.Shell.SelectColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Command));
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
function sge_ShellFunctions_Shell_TextColor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case Command.Count of
    1:  SGE.Shell.LogMessage('TextColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.TextColor));
    2..4: Result := sgeCreateErrorString('CmdShellTextColor', Err_NotEnoughParameters);
    else SGE.Shell.TextColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Command));
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
function sge_ShellFunctions_Shell_NoteColor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case Command.Count of
    1:  SGE.Shell.LogMessage('NoteColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.NoteColor));
    2..4: Result := sgeCreateErrorString('CmdShellNoteColor', Err_NotEnoughParameters);
    else SGE.Shell.NoteColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Command));
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
function sge_ShellFunctions_Shell_ErrColor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case Command.Count of
    1:  SGE.Shell.LogMessage('ErrColor = ' + sgeGetRGBAAsStringByGraphicColor(SGE.Shell.ErrorColor));
    2..4: Result := sgeCreateErrorString('CmdShellErrColor', Err_NotEnoughParameters);
    else SGE.Shell.ErrorColor := sgeGraphicColor_RGBAToColor(sgeGetRGBAFromParam(Command));
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
function sge_ShellFunctions_Shell_LogSave(Command: TsgeSimpleCommand): String;
var
  fn: String;
  Ms: TsgeMemoryStream;
begin
  Result := '';

  try
    Ms := TsgeMemoryStream.Create;
    SGE.Shell.Journal.ToMemoryStream(Ms);
    fn := GetUserSaveFileName(Command.Part[1]);

    try
      SGE.FileSystem.WriteFile(fn, Ms);
    except;
      Result := sgeCreateErrorString('CmdShellLogSave', Err_FileWriteError, fn);
    end;

  finally
    Ms.Free;
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
function sge_ShellFunctions_Shell_LogLines(Command: TsgeSimpleCommand): String;
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 0;
    if not TryStrToInt(Command.Part[1], i) then
      Result := sgeCreateErrorString('CmdShellLogLines', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
        else SGE.Shell.Journal.MaxLines := i;
    end
    else SGE.Shell.LogMessage('LogLines = ' + IntToStr(SGE.Shell.Journal.MaxLines));
end;


{
Описание:
  Установить максимальное количество видимых строк журнала
Синтаксис:
  VisLines <Number>
Параметры:
  Number - Количество строк
}
function sge_ShellFunctions_Shell_VisLines(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdShellVisLines';
var
  i, ml: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 0;
    if not TryStrToInt(Command.Part[1], i) then Result := sgeCreateErrorString(PROCNAME, Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
      else begin
      ml := sgeGetShellMaxVisibleLines(SGE.Window.Height, SGE.Shell.Font.Height);
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
function sge_ShellFunctions_Shell_BGSprite(Command: TsgeSimpleCommand): String;
var
  idx: Integer;
  s: String;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    SGE.Shell.BGSprite := TsgeGraphicSprite(SGE.Resources.TypedObj[Command.Part[1], rtGraphicSprite]);
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
function sge_ShellFunctions_Shell_ScanMode(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.Shell.ScanMode then SGE.Shell.LogMessage('ScanMode = On') else SGE.Shell.LogMessage('ScanMode = Off');
    1: Result := sgeCreateErrorString('CmdShellScanMode', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Shell_LogPageSize(Command: TsgeSimpleCommand): String;
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 1;
    if not TryStrToInt(Command.Part[1], i) then
      Result := sgeCreateErrorString('CmdShellLogPageSize', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
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
function sge_ShellFunctions_Shell_SubstChar(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  if Command.Count >= 2 then SGE.Shell.SubstChar := Command.Part[1]
    else SGE.Shell.LogMessage('SubstChar = ' + SGE.Shell.SubstChar);
end;


{
Описание:
  Установить символ кавычки
Синтаксис:
  StapleChar <Char>
Параметры:
  Char - Символ кавычки
}
function sge_ShellFunctions_Shell_StapleChar(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  if Command.Count >= 2 then SGE.Shell.StapleChar := Command.Part[1]
    else SGE.Shell.LogMessage('StapleChar = ' + SGE.Shell.StapleChar);
end;





{
Описание:
  Переключить полноэкранный режим
Синтаксис:
  FullScreen
}
function sge_ShellFunctions_Window_FullScreen(Command: TsgeSimpleCommand): String;
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
function sge_ShellFunctions_Window_LockCursor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.Window.ClipCursor then SGE.Shell.LogMessage('LockCursor = On') else SGE.Shell.LogMessage('LockCursor = Off');
    1: Result := sgeCreateErrorString('CmdWindowLockCursor', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Window_SysCursor(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.Window.ShowCursor then SGE.Shell.LogMessage('SysCursor = On') else SGE.Shell.LogMessage('SysCursor = Off');
    1: Result := sgeCreateErrorString('CmdWindowSysCursor', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Window_Width(Command: TsgeSimpleCommand): String;
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 0;
    if not TryStrToInt(Command.Part[1], i) then
      Result := sgeCreateErrorString('CmdWindowWidth', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
        else SGE.Window.Width := i;
    end
    else SGE.Shell.LogMessage('Width = ' + IntToStr(SGE.Window.Width));
end;


{
Описание:
  Установить клиентскую высоту окна
Синтаксис:
  Height <Number>
Параметры:
  Number - Высота в пикселях
}
function sge_ShellFunctions_Window_Height(Command: TsgeSimpleCommand): String;
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 0;
    if not TryStrToInt(Command.Part[1], i) then
      Result := sgeCreateErrorString('CmdWindowHeigth', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
        else SGE.Window.Height := i;
    end
    else SGE.Shell.LogMessage('Height = ' + IntToStr(SGE.Window.Height));
end;


{
Описание:
  Установить заголовок у окна
Синтаксис:
  Caption <Str>
Параметры:
  Str - Новый заголовок
}
function sge_ShellFunctions_Window_Caption(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  if Command.Count >= 2 then SGE.Window.Caption := Command.GetTail(1) else
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
function sge_ShellFunctions_Window_StayOnTop(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if wsTopMost in SGE.Window.Style then SGE.Shell.LogMessage('StayOnTop = On') else SGE.Shell.LogMessage('StayOnTop = Off');
    1: Result := sgeCreateErrorString('CmdWindowStayOnTop', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Graphic_ScreenShot(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdGraphicScreenShot';
var
  Name: String;
begin
  Result := '';

  try
    Name := sgeGetPartFromCommand(Command, 1);

    SGE.Screenshot(Name);
  except
    on E: EsgeException do
      Result := sgeCreateErrorString(PROCNAME, Err_CantCreateScreenShot, Name);
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
function sge_ShellFunctions_Graphic_MaxFPS(Command: TsgeSimpleCommand): String;
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 0;
    if not TryStrToInt(Command.Part[1], i) then
      Result := sgeCreateErrorString('CmdGraphicMaxFPS', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
      else SGE.MaxFPS := i;
    end
    else SGE.Shell.LogMessage('MaxFPS = ' + IntToStr(SGE.MaxFPS));
end;


{
Описание:
  Включить вертикальную синхронизацию
Синтаксис:
  VSync <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Graphic_VSync(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdGraphicVSync';
begin
  Result := '';

  try
    case sgeGetOnOffFromParam(Command) of
      0: if SGE.DrawControl = dcSync then SGE.Shell.LogMessage('VSync = On') else SGE.Shell.LogMessage('VSync = Off');
      1: Result := sgeCreateErrorString(PROCNAME, Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
      2: SGE.DrawControl := dcSync;
      3: SGE.DrawControl := dcProgram;
    end;
  except
    Result := sgeCreateErrorString(PROCNAME, Err_VerticalSyncNotSupported);
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
function sge_ShellFunctions_Graphic_Info(Command: TsgeSimpleCommand): String;
begin
  Result := '';

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
function sge_ShellFunctions_Graphic_Draw(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.DrawEnable then SGE.Shell.LogMessage('Draw = On') else SGE.Shell.LogMessage('Draw = Off');
    1: Result := sgeCreateErrorString('CmdGraphicDraw', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Attach_Attach(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdAttachAttach';
  ModeDown  = 0;
  ModeUp    = 1;
  ModeBouth = 2;
var
  Mode: Byte;
  KeyIdx: Integer;
  sKey, sCmd: String;
begin
  Result := '';

  //Подготовить переменные
  sKey := Command.Part[1];

  //Проверить на пустую строку
  if sKey = '' then
    begin
    Result := sgeCreateErrorString(PROCNAME, Err_KeyNameNotFound, sKey);
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
    Result := sgeCreateErrorString(PROCNAME, Err_KeyNameNotFound, sKey);
    Exit;
    end;

  //Проверить количество параметров
  if Command.Count >= 3 then
    begin
    sCmd := Command.GetTail(2);

    case Mode of
      ModeDown : SGE.Shell.KeyTable.KeyDownCommand[KeyIdx] := sCmd;
      ModeUp   : SGE.Shell.KeyTable.KeyUpCommand[KeyIdx] := sCmd;
      ModeBouth:
        begin
        SGE.Shell.KeyTable.KeyDownCommand[KeyIdx] := sCmd;
        SGE.Shell.KeyTable.KeyUpCommand[KeyIdx] := sCmd;
        end;
    end;
    end else SGE.Shell.KeyTable.Delete(KeyIdx);   //Удалить если не хватает параметров
end;


{
Описание:
  Отвязать все клавиши от команд
Синтаксис:
  AttachClear
}
function sge_ShellFunctions_Attach_Clear(Command: TsgeSimpleCommand): String;
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
function sge_ShellFunctions_Attach_List(Command: TsgeSimpleCommand): String;
var
  i, Idx, Cnt: Integer;
  Mask, Name, D, U: String;
  isAdd: Boolean;
  List: TsgeStringList;
begin
  Result := '';

  //Создать список
  List := TsgeStringList.Create;

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

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
      if D <> '' then List.Add(Name + '.Down = ' + D);
      if U <> '' then List.Add(Name + '.Up = ' + U);
      end;
    end;

  //Вывод списка
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('AttachList', ': ' + Mask);
  Cnt := List.Count - 1;
  for i := 0 to Cnt do
    SGE.Shell.LogMessage(List.Part[i]);
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt + 1));

  //Почистить память
  List.Free;
end;


{
Описание:
  Сохранить привязку команд в файл
Синтаксис:
  AttachSave [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_Attach_Save(Command: TsgeSimpleCommand): String;
var
  Ms: TsgeMemoryStream;
  List: TsgeStringList;
  i: Integer;
  Name, fn, Up, Down: String;
begin
  Result := '';

  try
    Ms := TsgeMemoryStream.Create;
    List := TsgeStringList.Create;

    //Подготовить список
    for i := 0 to 255 do
      begin
      Name := SGE.Shell.KeyTable.GetNameByIndex(i);
      Up := SGE.Shell.KeyTable.Key[i].Up;
      Down := SGE.Shell.KeyTable.Key[i].Down;

      if (Up = '') and (Down = '') then Continue;

      if Up = Down then
        begin
        List.Add('Attach *' + Name + #32 + Up);
        Continue;
        end;

      if Up <> '' then List.Add('Attach *' + Name + #32 + Up);
      if Down <> '' then List.Add('Attach *' + Name + #32 + Down);
      end;

    List.ToMemoryStream(Ms);
    fn := GetUserSaveFileName(Command.Part[1]);

    //Сохранить
    try
      SGE.FileSystem.WriteFile(fn, Ms);
    except
      Result := sgeCreateErrorString('CmdAttachSave', Err_FileWriteError, fn);
    end;


  finally
    List.Free;
    Ms.Free;
  end;
end;





{
Описание:
  Вывести список имён клавиш
Синтаксис:
  KeyList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Key_List(Command: TsgeSimpleCommand): String;
var
  i, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

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
  Отпустить клавишу
Синтаксис:
  KeyUp [Key]
Параметры:
  Key - Имя клавиши
}
function sge_ShellFunctions_Key_Up(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdKeyUp';
var
  Idx: Integer;
  cName, S: String;
begin
  Result := '';

  //Найти индекс
  cName := Command.Part[1];
  Idx := SGE.Shell.KeyTable.IndexOf(cName);
  if Idx = -1 then
    begin
    Result := sgeCreateErrorString(PROCNAME, Err_KeyNameNotFound, cName);
    Exit;
    end;

  //Выполнить команду
  S := SGE.Shell.KeyTable.Key[Idx].Up;
  SGE.Shell.DoCommand(S);
end;


{
Описание:
  Нажать клавишу
Синтаксис:
  KeyDown [Key]
Параметры:
  Key - Имя клавиши
}
function sge_ShellFunctions_Key_Down(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdKeyDown';
var
  Idx: Integer;
  cName, S: String;
begin
  Result := '';

  //Найти индекс
  cName := Command.Part[1];
  Idx := SGE.Shell.KeyTable.IndexOf(cName);
  if Idx = -1 then
    begin
    Result := sgeCreateErrorString(PROCNAME, Err_KeyNameNotFound, cName);
    Exit;
    end;

  //Выполнить команду
  S := SGE.Shell.KeyTable.Key[Idx].Down;
  SGE.Shell.DoCommand(S);
end;


{
Описание:
  Нажать и отпустить клавишу
Синтаксис:
  KeyClick [Key]
Параметры:
  Key - Имя клавиши
}
function sge_ShellFunctions_Key_Click(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdKeyClick';
var
  Idx: Integer;
  cName, S: String;
begin
  Result := '';

  //Найти индекс
  cName := Command.Part[1];
  Idx := SGE.Shell.KeyTable.IndexOf(cName);
  if Idx = -1 then
    begin
    Result := sgeCreateErrorString(PROCNAME, Err_KeyNameNotFound, cName);
    Exit;
    end;

  //Нажать
  S := SGE.Shell.KeyTable.Key[Idx].Down;
  SGE.Shell.DoCommand(S);

  //Отпустить
  S := SGE.Shell.KeyTable.Key[Idx].Up;
  SGE.Shell.DoCommand(S);
end;





{
Описание:
  Включить/выключить опрос джойстиков
Синтаксис:
  Joysticks <On/Off>
Параметры:
  On/Off - Включить/выключить
}
function sge_ShellFunctions_Joysticks_Joysticks(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  case sgeGetOnOffFromParam(Command) of
    0: if SGE.JoysticksEnable then SGE.Shell.LogMessage('Joysticks = On') else SGE.Shell.LogMessage('Joysticks = Off');
    1: Result := sgeCreateErrorString('CmdJoysticksJoystics', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1));
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
function sge_ShellFunctions_Joysticks_Delay(Command: TsgeSimpleCommand): String;
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 1;
    if not TryStrToInt(Command.Part[1], i) then
      Result := sgeCreateErrorString('CmdJoysticksDelay', Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
        else SGE.JoysticksDelay := i;
    end
    else SGE.Shell.LogMessage('JoyDelay = ' + IntToStr(SGE.JoysticksDelay));
end;





{
Описание:
  Установить имя шрифта оболочки
Синтаксис:
  FontName <Name>
Параметры:
 NewName - Имя шрифта
}
function sge_ShellFunctions_Font_Name(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    if Command.Part[1] <> '' then SGE.Shell.Font.Name := Command.Part[1];
    end else SGE.Shell.LogMessage('FontName = ' + SGE.Shell.Font.Name);
end;


{
Описание:
  Установить размер шрифта
Синтаксис:
  FontSize <Size>
Параметры:
  Size - Размер
}
function sge_ShellFunctions_Font_Size(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdFontSize';
var
  i: Integer;
begin
  Result := '';

  if Command.Count >= 2 then
    begin
    i := 0;
    if not TryStrToInt(Command.Part[1], i) then Result := sgeCreateErrorString(PROCNAME, Err_UnableToDetermineValue, sgeGetPartFromCommand(Command, 1))
      else begin
      //Изменить высоту шрифта
      if i < 1 then i := 1;
      SGE.Shell.Font.Height := i;

      //Поправить количество видимых линий
      i := SGE.Window.Height div SGE.Shell.Font.Height;
      if SGE.Shell.VisibleLines > i - 1 then SGE.Shell.VisibleLines := i - 1;
      end;
    end else SGE.Shell.LogMessage('FontSize = ' + IntToStr(SGE.Shell.Font.Height));
end;


{
Описание:
  Установить атрибуты шрифта оболочки
Синтаксис:
  FontAttrib <[]/B/I/U/S>
Параметры:
  []/B/I/U/S - Атрибуты шрифта
}
function sge_ShellFunctions_Font_Attrib(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  if Command.Count >= 2 then
    SGE.Shell.Font.Attrib := sgeGraphicFont_StringToAttrib(Command.Part[1])
      else SGE.Shell.LogMessage('FontAttrib = [' + sgeGraphicFont_AttribToString(SGE.Shell.Font.Attrib) + ']');
end;





{
Описание:
  Очистить список параметров
Синтаксис:
  ParamClear
}
function sge_ShellFunctions_Parameters_Clear(Command: TsgeSimpleCommand): String;
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
function sge_ShellFunctions_Parameters_List(Command: TsgeSimpleCommand): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

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
function sge_ShellFunctions_Parameters_Set(Command: TsgeSimpleCommand): String;
var
  Name, Value: String;
begin
  Result := '';

  Name := Command.Part[1];
  if Command.Count >= 3 then Value := Command.Part[2] else Value := '';

  SGE.Parameters.SetValue(Name, Value);
end;


{
Описание:
  Удалить параметр
Синтаксис:
  ParamDel [Name]
Параметры:
  Name  - Имя параметра
}
function sge_ShellFunctions_Parameters_Delete(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  try
    SGE.Parameters.Delete(Command.Part[1]);
  except
    Result := sgeCreateErrorString('CmdParametersDelete', Err_ParameterNotFound, Command.Part[1]);
  end;
end;


{
Описание:
  Сохранить параметры в файл
Синтаксис:
  ParamSave [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_Parameters_Save(Command: TsgeSimpleCommand): String;
var
  fn: String;
begin
  Result := '';

  fn := GetUserSaveFileName(Command.Part[1]);

  try
    SGE.SaveParameters(fn);
  except
    Result := sgeCreateErrorString('CmdParametersSave', Err_FileWriteError, fn);
  end;
end;


{
Описание:
  Загрузить параметры из файл
Синтаксис:
  ParamLoad [FileName]
Параметры:
  FileName - Имя файла
}
function sge_ShellFunctions_Parameters_Load(Command: TsgeSimpleCommand): String;
var
  fn: String;
begin
  Result := '';

  fn := GetUserLoadFileName(Command.Part[1]);

  try
    SGE.LoadParameters(fn);
  except
    Result := sgeCreateErrorString('CmdParametersLoad', Err_FileReadError, fn);;
  end;
end;




{
Описание:
  Вывести список ресурсов
Синтаксис:
  ResList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Resources_List(Command: TsgeSimpleCommand): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName, cGroup, S: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('ResourceList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  c := SGE.Resources.Count - 1;
  for i := 0 to c do
    begin
    cName := SGE.Resources.Item[i].Name;

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
      cGroup := SGE.Resources.Item[i].Group;
      S := '[';
      if cGroup <> '' then S := S + cGroup + ': ';
      S := S + SGE.Resources.Item[i].rType + '] ';
      S := S + cName;
      SGE.Shell.LogMessage(S);
      end;
    end;

  //Вывод хвоста
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt));
end;


{
Описание:
  Перезагрузить ресурс
Синтаксис:
  ResReload [Name]
Параметры:
  Name - Имя ресурса
}
function sge_ShellFunctions_Resources_Reload(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdResourcesReload';
var
  Idx: Integer;
  cName, ErrStr: String;
begin
  Result := '';

  cName := Trim(Command.Part[1]);
  //Найти индекс
  Idx := SGE.Resources.IndexOf(cName);
  if Idx = -1 then
    begin
    Result := sgeCreateErrorString(PROCNAME, Err_ResourceNotFound, cName);
    Exit;
    end;

  //Перезагрузить ресурс
  ErrStr := sgeCreateErrorString(PROCNAME, Err_ReloadMethodDoesNotExist, cName);
  try
    case SGE.Resources.Item[Idx].rType of
      rtGraphicSprite : TsgeGraphicSprite(SGE.Resources.Item[Idx].Obj).Reload;
      rtGraphicFont   : Result := ErrStr;
      rtGraphicFrames : Result := ErrStr;
      rtSystemFont    : TsgeSystemFont(SGE.Resources.Item[Idx].Obj).Reload;
      rtSoundBuffer   : TsgeSoundBuffer(SGE.Resources.Item[Idx].Obj).Reload;
      rtParameters    : TsgeSimpleParameters(SGE.Resources.Item[Idx].Obj).Reload;
    end;
  except
    on E: EsgeException do
      Result := sgeCreateErrorString(PROCNAME, Err_LoadResourceError, cName, E.Message);
  end;
end;


{
Описание:
  Удалить ресурс по имени
Синтаксис:
  ResDelete [Name]
Параметры:
  Name - Имя ресурса
}
function sge_ShellFunctions_Resources_Delete(Command: TsgeSimpleCommand): String;
var
  cName: String;
begin
  Result := '';

  cName := Trim(Command.Part[1]);

  try
    SGE.Resources.Delete(cName);
  except
    Result := sgeCreateErrorString('CmdResourcesDelete', Err_ResourceNotFound, cName);
  end;
end;


{
Описание:
  Очистить ресурсы
Синтаксис:
  ResClear
}
function sge_ShellFunctions_Resources_Clear(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  SGE.Resources.Clear;
end;


{
Описание:
  Загрузить ресурс
Синтаксис:
  ResLoad [Type] [Name] [File] <Params>
Параметры:
  Type   - Тип ресурса
    sysfont   - Системный шрифт
    sysicon   - Системная иконка
    syscursor - Системный курсор
    sprite    - Графический спрайт
    font      - Графический шрифт
    frames    - Кадры графики
    buffer    - Звуковой буфер
    params    - Параметры
  Name   - Имя ресурса
  File   - Путь к файлу
  Params - Дополнительные параметры
}
function sge_ShellFunctions_Resources_Load(Command: TsgeSimpleCommand): String;
begin
  Result := '';

  try
    SGE.Resources.Command_LoadResource(Command);
  except
    on E: EsgeException do
      Result := sgeCreateErrorString('CmdResourcesLoad', Err_LoadResourceError, '', E.Message);
  end;
end;


{
Описание:
  Загрузить таблицу ресурсов
Синтаксис:
  ResLoadTable [FileName] <Mode>
Параметры:
  FileFile - Путь к файлу
  Mode     - Режим загрузки
    Add     - Добавить
    Replace - Заменить
}
function sge_ShellFunctions_Resources_LoadTable(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdResourcesLoadTable';
var
  fn, cMode: String;
  Mode: TsgeLoadMode;
begin
  Result := '';

  //Определить режим загрузки
  Mode := lmAdd;
  if Command.Count >= 3 then
    begin
    cMode := Trim(Command.Part[2]);
    case LowerCase(cMode) of
      'replace': Mode := lmReplace;
      'add'    : Mode := lmAdd;
      else begin
      Result := sgeCreateErrorString(PROCNAME, Err_UnableToDetermineMode, cMode);
      Exit;
      end;
    end;
    end;

  //Подготовить имя файла
  fn := GetUserLoadFileName(Command.Part[1]);

  //Загрузить
  try
    SGE.LoadResourcesFromTable(fn, Mode);
  except
    on E: EsgeException do
      Result := sgeCreateErrorString(PROCNAME, Err_LoadResourceTableError, fn, E.Message);
  end;
end;


{
Описание:
  Переименовать ресурс
Синтаксис:
  ResRename [OldName] [NewName]
Параметры:
  OldName - Старое имя
  NewName - Новое имя
}
function sge_ShellFunctions_Resources_Rename(Command: TsgeSimpleCommand): String;
const
  PROCNAME = 'CmdResourcesRename';
var
  Old, New: String;
  Idx: Integer;
  Res: TsgeResource;
begin
  Result := '';

  Old := Trim(Command.Part[1]);
  New := Trim(Command.Part[2]);

  //Найти индекс
  Idx := SGE.Resources.IndexOf(Old);
  if Idx = -1 then
    begin
    Result := sgeCreateErrorString(PROCNAME, Err_ResourceNotFound, Old);
    Exit;
    end;

  //Проверить на дубликат
  if SGE.Resources.IndexOf(New) <> -1 then
    begin
    Result := sgeCreateErrorString(PROCNAME, Err_ResourceExist, New);
    Exit;
    end;

  //Переименовать
  Res := SGE.Resources.Item[Idx];
  Res.Name := New;
  SGE.Resources.Item[Idx] := Res;
end;


{
Описание:
  Удалить группу ресурсов
Синтаксис:
  ResDeleteGroup [Group]
Параметры:
  Group - Имя группы
}
function sge_ShellFunctions_Resources_DeleteGroup(Command: TsgeSimpleCommand): String;
var
  cName: String;
begin
  Result := '';

  cName := Trim(Command.Part[1]);
  SGE.Resources.DeleteByGroup(cName);
end;





{
Описание:
  Вывести список объектов
Синтаксис:
  ObjectList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Object_List(Command: TsgeSimpleCommand): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('ObjectList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  c := ObjectList.Count - 1;
  for i := 0 to c do
    begin
    //Определить название набора команд
    cName := ObjectList.Item[i].Name;

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
      SGE.Shell.LogMessage('[' + ObjectList.Item[i].Group + '] ' + cName);
      end;
    end;

  //Вывод хвоста
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt));
end;





{
Описание:
  Вывести список архивов
Синтаксис:
  PackList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Pack_List(Command: TsgeSimpleCommand): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('PackList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  c := SGE.FileSystem.PackList.Count - 1;
  for i := 0 to c do
    begin
    cName := ChangeFileExt(ExtractFileName(SGE.FileSystem.PackList.Item[i].FileName), '');

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
  Удалить архив по имени
Синтаксис:
  PackDelete [Name]
Параметры:
  Name - Имя архива
}
function sge_ShellFunctions_Pack_Delete(Command: TsgeSimpleCommand): String;
var
  cName: String;
begin
  Result := '';

  cName := Trim(Command.Part[1]);

  try
    SGE.FileSystem.DeletePack(cName + '.' + sge_ExtPack);
  except
    Result := sgeCreateErrorString('CmdPackDelete', Err_NameNotFound, cName);
  end;
end;


{
Описание:
  Загрузить архив в систему
Синтаксис:
  PackAdd [Name]
Параметры:
  Name - Имя архива
}
function sge_ShellFunctions_Pack_Add(Command: TsgeSimpleCommand): String;
var
  cName: String;
begin
  Result := '';

  cName := Trim(Command.Part[1]);

  try
    SGE.FileSystem.AddPack(cName + '.' + sge_ExtPack);
  except
    on E: EsgeException do
      Result := E.Message;
  end;
end;


{
Описание:
  Вывести список файлов в архивах
Синтаксис:
  PackFileList <Mask>
Параметры:
  Mask - Подстрока для поиска
}
function sge_ShellFunctions_Pack_FileList(Command: TsgeSimpleCommand): String;
var
  i, c, Idx, Cnt: Integer;
  Mask, cName, PackName: String;
  isAdd: Boolean;
begin
  Result := '';

  //Подготовить маску
  Mask := sgeGetPartFromCommand(Command, 1);

  //Вывод шапки
  SGE.Shell.LogMessage('');
  SGE.Shell.LogMessageLocalized('PackFileList', ': ' + Mask);

  //Перебор массива
  Cnt := 0;
  c := SGE.FileSystem.FileList.Count - 1;
  for i := 0 to c do
    begin
    cName := SGE.FileSystem.FileList.Item[i].Name;
    PackName := ChangeFileExt(ExtractFileName(SGE.FileSystem.FileList.Item[i].Pack.FileName), '');

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
      SGE.Shell.LogMessage('[' + PackName + '] ' + cName);
      end;
    end;

  //Вывод хвоста
  SGE.Shell.LogMessageLocalized('Count', ': ' + IntToStr(Cnt));
end;










/////////////////////////////////////////////////////////////////////
//                Регистрация Функций оболочки                     //
/////////////////////////////////////////////////////////////////////
procedure sgeShellFunctions_RegisterCommand;
begin
  //Найти указатель на объект
  SGE := TSimpleGameEngine(ObjectList.NamedObject[Obj_SGE]);

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
    Add('System', 'StartParams', @sge_ShellFunctions_System_StartParams, 0);
    Add('System', 'LoadLanguage', @sge_ShellFunctions_System_LoadLanguage, 1);
    Add('System', 'Priority', @sge_ShellFunctions_System_Priority, 0);

    //Задачи
    Add('Task', 'Tasks', @sge_ShellFunctions_Tasks_Task, 0);
    Add('Task', 'TaskDelay', @sge_ShellFunctions_Task_Delay, 0);
    Add('Task', 'TaskList', @sge_ShellFunctions_Task_List, 0);
    Add('Task', 'TaskInfo', @sge_ShellFunctions_Task_Info, 1);
    Add('Task', 'TaskDelete', @sge_ShellFunctions_Task_Delete, 1);
    Add('Task', 'TaskStop', @sge_ShellFunctions_Task_Stop, 1);
    Add('Task', 'TaskStart', @sge_ShellFunctions_Task_Start, 1);
    Add('Task', 'TaskRestart', @sge_ShellFunctions_Task_Restart, 1);

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
    Add('Shell', 'StapleChar', @sge_ShellFunctions_Shell_StapleChar, 0);

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

    //Привязка клавиш
    Add('Attach', 'Attach', @sge_ShellFunctions_Attach_Attach, 1);
    Add('Attach', 'AttachClear', @sge_ShellFunctions_Attach_Clear, 0);
    Add('Attach', 'AttachList', @sge_ShellFunctions_Attach_List, 0);
    Add('Attach', 'AttachSave', @sge_ShellFunctions_Attach_Save, 1);

    //Таблица клавиш
    Add('Key', 'KeyList', @sge_ShellFunctions_Key_List, 0);
    Add('Key', 'KeyUp', @sge_ShellFunctions_Key_Up, 1);
    Add('Key', 'KeyDown', @sge_ShellFunctions_Key_Down, 1);
    Add('Key', 'KeyClick', @sge_ShellFunctions_Key_Click, 1);

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
    Add('Parameters', 'ParamDelete', @sge_ShellFunctions_Parameters_Delete, 1);
    Add('Parameters', 'ParamSave', @sge_ShellFunctions_Parameters_Save, 1);
    Add('Parameters', 'ParamLoad', @sge_ShellFunctions_Parameters_Load, 1);

    //Ресурсы
    Add('Resources', 'ResList', @sge_ShellFunctions_Resources_List, 0);
    Add('Resources', 'ResClear', @sge_ShellFunctions_Resources_Clear, 0);
    Add('Resources', 'ResReload', @sge_ShellFunctions_Resources_Reload, 1);
    Add('Resources', 'ResDelete', @sge_ShellFunctions_Resources_Delete, 1);
    Add('Resources', 'ResLoad', @sge_ShellFunctions_Resources_Load, 3);
    Add('Resources', 'ResLoadTable', @sge_ShellFunctions_Resources_LoadTable, 1);
    Add('Resources', 'ResRename', @sge_ShellFunctions_Resources_Rename, 2);
    Add('Resources', 'ResDeleteGroup', @sge_ShellFunctions_Resources_DeleteGroup, 1);

    //Список объектов
    Add('ObjectList', 'ObjectList', @sge_ShellFunctions_Object_List, 0);

    //Архивы
    Add('Pack', 'PackList', @sge_ShellFunctions_Pack_List, 0);
    Add('Pack', 'PackDelete', @sge_ShellFunctions_Pack_Delete, 1);
    Add('Pack', 'PackAdd', @sge_ShellFunctions_Pack_Add, 1);
    Add('Pack', 'PackFileList', @sge_ShellFunctions_Pack_FileList, 0);
    end;

  //Упорядочить
  SGE.Shell.Commands.Sort;
end;





end.


