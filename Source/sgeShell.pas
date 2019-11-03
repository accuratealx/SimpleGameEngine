{
Пакет             Simple Game Engine 1
Файл              sgeShell.pas
Версия            1.7
Создан            09.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Оболочка для движка
}

unit sgeShell;

{$mode objfpc}{$H+}

interface

uses
  StringArray, SimpleCommand,
  sgeConst, sgeTypes, sgeShellCommands, sgeCommandHistory, sgeColoredLines,
  sgeLineEditor, sgeGraphicColor, sgeGraphicSprite, sgeParameters, sgeKeyTable,
  Windows, SysUtils;


type
  //Режим работы TAB
  TsgeShellTABMode = (stmSearch, stmOption);

  //Тип линии
  TsgeShellLineType = (sltError, sltText, sltNote);


  TsgeShell = class
  private
    FSets: TsgeParameters;                //Наборы команд
    FCommands: TsgeShellCommands;         //Массив команд
    FKeyTable: TsgeKeyTable;              //Таблица команд на кнопках
    FCommandHistory: TsgeCommandHistory;  //История введённых команд
    FEditor: TsgeLineEditor;              //Строка ввода
    FJournal: TsgeColoredLines;           //Протокол
    FLanguage: TsgeParameters;            //Таблица языка

    FEnable: Boolean;                     //Активность
    FLogErrors: Boolean;                  //Выводить ошибки
    FVisibleLines: Word;                  //Видимых линий
    FStrictSearch: Boolean;               //Строгий поиск
    FSetsSearch: Boolean;                 //Поиск по наборам
    FSortMatchList: Boolean;              //Сортировка результата поиска

    FTABMode: TsgeShellTABMode;           //Режим работы TAB
    FTABList: TStringArray;               //Список совпадений для TAB
    FTABIndex: Integer;                   //Текущий элемент в списке совпадений

    FBGColor: TsgeGraphicColor;           //Цвет фона
    FEditorColor: TsgeGraphicColor;       //Цвет редактора
    FCursorColor: TsgeGraphicColor;       //Цвет курсора
    FSelectColor: TsgeGraphicColor;       //Цвет выделения
    FErrorColor: TsgeGraphicColor;        //Цвет ошибки
    FTextColor: TsgeGraphicColor;         //Цвет простого текста
    FNoteColor: TsgeGraphicColor;         //Цвет заметки
    FBGSprite: TsgeGraphicSprite;         //Фоновая картинка

    FmsgCommandNotFound: String;          //Не найдена команда
    FmsgEmptyPointer: String;             //Пустой указатель на функцию
    FmsgWrongParamCount: String;          //Неправильное количество параметров
    FmsgCommandError: String;             //Ошибка выполнения команды
    FmsgCommandException: String;         //Непредвиденная ошибка
    FmsgNoData: String;                   //Не найдены сведения
    FMsgHelpHint: String;                 //Подсказка для помощи

    procedure GetMatchList(List: PStringArray; Mask: ShortString);
    procedure PrepareTAB;
    function  GetNextTABCommand: String;
    function  GetPrevTABCommand: String;
  public
    constructor Create;
    destructor  Destroy; override;



    procedure LogHelpHint;
    procedure LogMessage(Text: String; tType: TsgeShellLineType = sltText);
    procedure LoadLanguage(FileName: String; Mode: TsgeLoadMode = lmReplace);
    procedure DoCommand(Cmd: String);
    procedure ProcessChar(Chr: Char; KeyboardButtons: TsgeKeyboardButtons);
    procedure ProcessKey(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);

    property Sets: TsgeParameters read FSets;
    property Commands: TsgeShellCommands read FCommands;
    property KeyTable: TsgeKeyTable read FKeyTable;
    property CommandHistory: TsgeCommandHistory read FCommandHistory;
    property Editor: TsgeLineEditor read FEditor;
    property Journal: TsgeColoredLines read FJournal;
    property Language: TsgeParameters read FLanguage;

    property Enable: Boolean read FEnable write FEnable;
    property VisibleLines: Word read FVisibleLines write FVisibleLines;
    property LogErrors: Boolean read FLogErrors write FLogErrors;
    property StrictSearch: Boolean read FStrictSearch write FStrictSearch;
    property SetsSearch: Boolean read FSetsSearch write FSetsSearch;
    property SortMatchList: Boolean read FSortMatchList write FSortMatchList;
    property BGColor: TsgeGraphicColor read FBGColor write FBGColor;
    property EditorColor: TsgeGraphicColor read FEditorColor write FEditorColor;
    property CursorColor: TsgeGraphicColor read FCursorColor write FCursorColor;
    property SelectColor: TsgeGraphicColor read FSelectColor write FSelectColor;
    property ErrorColor: TsgeGraphicColor read FErrorColor write FErrorColor;
    property TextColor: TsgeGraphicColor read FTextColor write FTextColor;
    property NoteColor: TsgeGraphicColor read FNoteColor write FNoteColor;
    property BGSprite: TsgeGraphicSprite read FBGSprite write FBGSprite;
  end;


implementation



procedure TsgeShell.GetMatchList(List: PStringArray; Mask: ShortString);
var
  i, c, Idx: Integer;
  isAdd: Boolean;
  s: String;
begin
  StringArray_Clear(List);
  Mask := LowerCase(Trim(Mask));

  //Перебор по командам
  c := FCommands.Count - 1;
  for i := 0 to c do
    begin
    isAdd := False;
    if Mask = '' then isAdd := True
      else begin
      Idx := Pos(Mask, LowerCase(FCommands.Command[i].Name));
      case FStrictSearch of
        True : if Idx = 1 then isAdd := True;
        False: if Idx > 0 then isAdd := True;
      end;
      end;

    if isAdd then
      begin
      s := FCommands.Command[i].Name;
      if FCommands.Command[i].MinParams > 0 then s := s + ' ';
      StringArray_Add(List, s);
      end;
    end;

  //Перебор по наборам
  if FSetsSearch then
    begin
    c := FSets.Count - 1;
    for i := 0 to c do
      begin
      isAdd := False;
      if Mask = '' then isAdd := True
        else begin
        Idx := Pos(Mask, LowerCase(FSets.Parameter[i].Name));
        case FStrictSearch of
          True : if Idx = 1 then isAdd := True;
          False: if Idx > 0 then isAdd := True;
        end;
        end;

      if isAdd then StringArray_Add(List, FSets.Parameter[i].Name);
      end;
    end;

  //Проверить упорядочивание
  if FSortMatchList then StringArray_Sort(List);
end;


procedure TsgeShell.PrepareTAB;
begin
  GetMatchList(@FTABList, FEditor.Line);
  FTABMode := stmOption;
  FTABIndex := -1;
end;


function TsgeShell.GetNextTABCommand: String;
var
  c: Integer;
begin
  Result := '';
  c := StringArray_GetCount(@FTABList);
  if c > 0 then
    begin
    Inc(FTABIndex);
    if FTABIndex > c - 1 then FTABIndex := 0;
    Result := FTABList[FTABIndex];
    end;
end;


function TsgeShell.GetPrevTABCommand: String;
var
  c: Integer;
begin
  Result := '';
  c := StringArray_GetCount(@FTABList);
  if c > 0 then
    begin
    Dec(FTABIndex);
    if FTABIndex < 0 then FTABIndex := c - 1;
    Result := FTABList[FTABIndex];
    end;
end;


constructor TsgeShell.Create;
begin
  //Классы
  FSets := TsgeParameters.Create;
  FCommands := TsgeShellCommands.Create;
  FKeyTable := TsgeKeyTable.Create;
  FCommandHistory := TsgeCommandHistory.Create(50);
  FEditor := TsgeLineEditor.Create;
  FJournal := TsgeColoredLines.Create;
  FLanguage := TsgeParameters.Create;

  //Переменные
  FLogErrors := True;
  FVisibleLines := 32;
  FStrictSearch := False;
  FSetsSearch := True;
  FSortMatchList := True;
  FTABMode := stmSearch;
  FTABIndex := -1;

  //Цвета
  FBGColor     := sgeGraphicColor_RGBAToColor(0, 0, 0, 127);
  FEditorColor := sgeGraphicColor_RGBAToColor(255, 255, 255, 255);
  FCursorColor := sgeGraphicColor_RGBAToColor(255, 255, 255, 255);
  FSelectColor := sgeGraphicColor_ChangeAlpha(FCursorColor, 0.5);
  FErrorColor  := sgeGraphicColor_RGBAToColor(255, 0, 0, 255);
  FTextColor   := sgeGraphicColor_RGBAToColor(255, 255, 255, 255);
  FNoteColor   := sgeGraphicColor_RGBAToColor(255, 255, 255, 127);

  //Сообщения
  FmsgCommandNotFound  := 'Command not found "$CmdName$"';
  FmsgEmptyPointer     := 'Empty pointer "$CmdName$"';
  FmsgWrongParamCount  := 'Wrong param count "$Cmd$", must be "$PrmCnt$"';
  FmsgCommandError     := 'Command error "$Cmd$"  "$ErrStr$"';
  FmsgCommandException := 'Command exception "$Cmd$"';
  FmsgNoData           := 'No data';
  FMsgHelpHint         := 'Type "Help CmdName" for info, "CmdList" for command list';
end;


destructor TsgeShell.Destroy;
begin
  StringArray_Clear(@FTABList);
  FKeyTable.Free;
  FCommands.Free;
  FSets.Free;
  FCommandHistory.Free;
  FEditor.Free;
  FJournal.Free;
  FLanguage.Free;
end;


procedure TsgeShell.LogHelpHint;
begin
  LogMessage(FMsgHelpHint);
end;


procedure TsgeShell.LogMessage(Text: String; tType: TsgeShellLineType);
begin
  case tType of
    sltError: if FLogErrors then FJournal.Add(FErrorColor, Text);
    sltText: FJournal.Add(FTextColor, Text);
    sltNote: FJournal.Add(FNoteColor, Text);
  end;
end;


procedure TsgeShell.LoadLanguage(FileName: String; Mode: TsgeLoadMode);
begin
  if not FileExists(FileName) then
    raise EsgeException.Create(Err_sgeShell + Err_Separator + Err_sgeShell_FileNotExist + Err_Separator + FileName);

  //Попробывать загрузить
  try
    case Mode of
      lmReplace: FLanguage.LoadFromFile(FileName);
      lmAdd: FLanguage.UpdateFromFile(FileName, True);
    end;
  except
    raise EsgeException.Create(Err_sgeShell + Err_Separator + Err_sgeShell_ErrorLoadingFile + Err_Separator + FileName);
  end;

  //Заменить константы, если есть
  FLanguage.GetString(sge_ShellMessage_CommandNotFound, FmsgCommandNotFound);
  FLanguage.GetString(sge_ShellMessage_EmptyPointer, FmsgEmptyPointer);
  FLanguage.GetString(sge_ShellMessage_WrongParamCount, FmsgWrongParamCount);
  FLanguage.GetString(sge_ShellMessage_CommandError, FmsgCommandError);
  FLanguage.GetString(sge_ShellMessage_CommandException, FmsgCommandException);
  FLanguage.GetString(sge_ShellMessage_NoData, FmsgNoData);
  FLanguage.GetString(sge_ShellMessage_HelpHint, FMsgHelpHint);
end;


procedure TsgeShell.DoCommand(Cmd: String);
const
  ModeEmpty = 0;
  ModeSet = 1;
  ModeCmd = 2;
  ModeAutor = 3;
var
  sa, sb: TStringArray;
  Mode: Byte;
  cName, ErrStr, s: String;
  SetIdx, CmdIdx, i, c: Integer;
begin
  Cmd := Trim(Cmd);                           //Отпилить лишнее
  SimpleCommand_Disassemble(@sa, Cmd);        //Разобрать на части

  if not StringArray_Equal(@sa, 1) then Exit; //Пустая строка
  cName := LowerCase(sa[0]);                  //Выделить имя команды

  //Определить режим работы
  Mode := ModeEmpty;
  if cName = 'autor' then Mode := ModeAutor;
  SetIdx := FSets.IndexOf(cName);
  if SetIdx <> -1 then Mode := ModeSet;
  CmdIdx := FCommands.IndexOf(cName);
  if CmdIdx <> -1 then Mode := ModeCmd;

  //Обработать
  case Mode of
    ModeEmpty:
      begin
      ErrStr := StringReplace(FmsgCommandNotFound, '$CmdName$', sa[0], [rfIgnoreCase, rfReplaceAll]);
      LogMessage(ErrStr, sltError);
      end;

    ModeSet:
      begin
      StringArray_StringToArray(@sb, Trim(FSets.Parameter[SetIdx].Value), ';');
      c := StringArray_GetCount(@sb) - 1;
      for i := 0 to c do
        DoCommand(sb[i]);
      StringArray_Clear(@sb);
      end;

    ModeCmd:
      begin
      //Проверить указатель
      if FCommands.Command[CmdIdx].Addr <> nil then
        begin
        //Проверить хватает ли параметров
        if StringArray_Equal(@sa, FCommands.Command[CmdIdx].MinParams + 1) then
          begin
          //Выполнить команду
          try
            i := FCommands.Command[CmdIdx].Addr(@sa);
          except
            //Непредвиденная ошибка
            ErrStr := StringReplace(FmsgCommandException, '$Cmd$', Cmd, [rfIgnoreCase, rfReplaceAll]);
            LogMessage(ErrStr, sltError);
          end;
          //Проверить код выполнения
          if i <> 0 then
            begin
            s := FmsgNoData;
            if not FLanguage.GetString(cName + ':Error.' + IntToStr(i), s) then s := IntToStr(i) + ' - ' + s;
            ErrStr := StringReplace(FmsgCommandError, '$Cmd$', Cmd, [rfIgnoreCase, rfReplaceAll]);
            ErrStr := StringReplace(ErrStr, '$ErrStr$', s, [rfIgnoreCase, rfReplaceAll]);
            LogMessage(ErrStr, sltError);
            end;
          end
          else begin
          //Не хватает параметров
          ErrStr := StringReplace(FmsgWrongParamCount, '$Cmd$', Cmd, [rfIgnoreCase, rfReplaceAll]);
          ErrStr := StringReplace(ErrStr, '$PrmCnt$', IntToStr(FCommands.Command[CmdIdx].MinParams), [rfIgnoreCase, rfReplaceAll]);
          LogMessage(ErrStr, sltError);
          end;
        end
        else begin
        //Пустой указатель
        ErrStr := StringReplace(FmsgEmptyPointer, '$CmdName$', sa[0], [rfIgnoreCase, rfReplaceAll]);
        LogMessage(ErrStr, sltError);
        end;
      end;

    ModeAutor: FJournal.Add(GC_Lime, 'sge.ntlab.su  accuratealx@gmail.com');
  end;

  StringArray_Clear(@sa);
end;


procedure TsgeShell.ProcessChar(Chr: Char; KeyboardButtons: TsgeKeyboardButtons);
begin
  FEditor.ProcessChar(Chr, KeyboardButtons);
end;


procedure TsgeShell.ProcessKey(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);
const
  mList = 0;
  mNext = 1;
  mPrev = 2;
var
  s: String;
  List: TStringArray;
  i, c: Integer;
  Mode: Byte;
begin
  case Key of
    //Закрыть оболочку
    VK_ESCAPE: FEnable := False;


    //Вывод подходящих команд
    VK_TAB:
      begin
      //Определить режим работы
      Mode := mNext;
      if kbShift in KeyboardButtons then Mode := mPrev;
      if kbCtrl in KeyboardButtons then Mode := mList;

      //Обработать режим
      case Mode of
        mList:
          begin
          GetMatchList(@List, Trim(FEditor.Line));
          c := StringArray_GetCount(@List);
          if c > 0 then
            begin
            LogMessage('');
            LogMessage('Found:', sltNote);
            for i := 0 to c - 1 do
              LogMessage(List[i]);
            LogMessage('Count: ' + IntToStr(c), sltNote);
            end;
          StringArray_Clear(@List);
          end;

        mNext:
          begin
          if FTABMode = stmSearch then PrepareTAB;
          s := GetNextTABCommand;
          if s <> '' then FEditor.Line := s;
          end;

        mPrev:
          begin
          if FTABMode = stmSearch then PrepareTAB;
          s := GetPrevTABCommand;
          if s <> '' then FEditor.Line := s;
          end;
      end;
      end;//VK_TAB


    //Ввод команды
    VK_RETURN:
      begin
      FTABMode := stmSearch;
      s := Trim(FEditor.Line);
      if s <> '' then
        begin
        FEditor.Line := '';
        FCommandHistory.AddCommand(s);
        DoCommand(s);
        end;
      end;


    //Установить предыдущую команду в поле редактора
    VK_UP: FEditor.Line := FCommandHistory.GetPreviousCommand;

    //Установить следующую команду в поле редактора
    VK_DOWN: FEditor.Line := FCommandHistory.GetNextCommand;

    //Очистить журнал оболочки
    VK_L: if (kbCtrl in KeyboardButtons) then FJournal.Clear;

    //Прочие клавиши передать в редактор
    else
      begin
      if not (kbShift in KeyboardButtons) then FTABMode := stmSearch;
      FEditor.ProcessKey(Key, KeyboardButtons);
      end;
  end;
end;


end.

