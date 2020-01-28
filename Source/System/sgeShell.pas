{
Пакет             Simple Game Engine 1
Файл              sgeShell.pas
Версия            1.14
Создан            09.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Оболочка для движка
}

unit sgeShell;

{$mode objfpc}{$H+}

interface

uses
  sgeTypes, sgeSimpleParameters, sgeStringList, sgeShellCommandList, sgeKeyTable, sgeCommandHistory,
  sgeLineEditor, sgeColoredLineList, sgeGraphicColor, sgeGraphicSprite, sgeGraphicFont;


type
  //Режим работы TAB
  TsgeShellTABMode = (stmSearch, stmOption);

  //Тип линии
  TsgeShellLineType = (sltError, sltText, sltNote);


  //Обработчик ошибок
  TsgeShellErrorHandle = procedure(Msg: String) of object;


  TsgeShell = class
  private
    //Классы
    FSets: TsgeSimpleParameters;          //Наборы команд
    FCommands: TsgeShellCommandList;      //Массив команд
    FKeyTable: TsgeKeyTable;              //Таблица команд на кнопках
    FCommandHistory: TsgeCommandHistory;  //История введённых команд
    FEditor: TsgeLineEditor;              //Строка ввода
    FJournal: TsgeColoredLineList;        //Протокол
    FFont: TsgeGraphicFont;               //Шрифт оболочки

    //Параметры
    FEnable: Boolean;                     //Активность
    FLogErrors: Boolean;                  //Выводить ошибки
    FVisibleLines: Word;                  //Видимых линий
    FStrictSearch: Boolean;               //Строгий поиск
    FSetsSearch: Boolean;                 //Поиск по наборам
    FSortMatchList: Boolean;              //Сортировка результата поиска
    FScanMode: Boolean;                   //Режим сканирования клавиш
    FJournalOffset: Integer;              //Смещение для прокрутки журнала
    FJournalPageSize: Byte;               //Размер прокрутки журнала
    FSubstChar: ShortString;              //Символ признака переменной
    FStapleChar: ShortString;             //Символ кавычки в команде

    //Цвета
    FBGColor: TsgeGraphicColor;           //Цвет фона
    FEditorColor: TsgeGraphicColor;       //Цвет редактора
    FCursorColor: TsgeGraphicColor;       //Цвет курсора
    FSelectColor: TsgeGraphicColor;       //Цвет выделения
    FErrorColor: TsgeGraphicColor;        //Цвет ошибки
    FTextColor: TsgeGraphicColor;         //Цвет простого текста
    FNoteColor: TsgeGraphicColor;         //Цвет заметки
    FBGSprite: TsgeGraphicSprite;         //Фоновая картинка

    //Язык
    FMsgHelpHint: String;
    FMsgScanModeOn: String;
    FMsgScanModeOff: String;
    FMsgKeyName: String;

    //Вспомогательные параметры
    FTABMode: TsgeShellTABMode;           //Режим работы TAB
    FTABList: TsgeStringList;             //Список совпадений для TAB
    FTABIndex: Integer;                   //Текущий элемент в списке совпадений

    procedure GetMatchList(List: TsgeStringList; Mask: ShortString);
    procedure PrepareTAB;
    function  GetNextTABCommand: String;
    function  GetPrevTABCommand: String;

    procedure SetScanMode(AMode: Boolean);
    procedure SetJournalOffset(AOffset: Integer);
    procedure SetJournalPageSize(ASize: Byte);
    procedure SetSubstChar(Str: ShortString);
    procedure SetStapleChar(Str: ShortString);
  public
    constructor Create;
    destructor  Destroy; override;

    procedure UpdateLanguage;
    function  GetJournalInterval: TsgeInterval;

    procedure LogMessageLocalized(LngConst: String; Postfix: ShortString = ''; rType: TsgeShellLineType = sltNote);
    procedure LogHelpHint;
    procedure LogMessage(Text: String; tType: TsgeShellLineType = sltText);

    procedure DoCommand(Command: String);

    procedure KeyChar(Chr: Char; KeyboardButtons: TsgeKeyboardButtons);
    procedure KeyDown(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);
    procedure MouseDown(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
    procedure MouseScroll(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons; Delta: Integer);

    property Sets: TsgeSimpleParameters read FSets;
    property Commands: TsgeShellCommandList read FCommands;
    property KeyTable: TsgeKeyTable read FKeyTable;
    property CommandHistory: TsgeCommandHistory read FCommandHistory;
    property Editor: TsgeLineEditor read FEditor;
    property Journal: TsgeColoredLineList read FJournal;
    property Font: TsgeGraphicFont read FFont;

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
    property ScanMode: Boolean read FScanMode write SetScanMode;
    property SubstChar: ShortString read FSubstChar write SetSubstChar;
    property StapleChar: ShortString read FStapleChar write SetStapleChar;
    property JournalOffset: Integer read FJournalOffset write SetJournalOffset;
    property JournalPageSize: Byte read FJournalPageSize write SetJournalPageSize;
  end;


implementation

uses
  sgeConst, sgeObjectList, SimpleGameEngine, sgeSimpleCommand,
  Windows, SysUtils;


const
  _UNITNAME = 'sgeShell';


var
  SGE: TSimpleGameEngine;



procedure TsgeShell.GetMatchList(List: TsgeStringList; Mask: ShortString);
var
  i, c, Idx: Integer;
  isAdd: Boolean;
  s: String;
begin
  List.Clear;
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
      List.Add(s);
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

      if isAdd then List.Add(FSets.Parameter[i].Name);
      end;
    end;

  //Проверить упорядочивание
  if FSortMatchList then List.Sort;
end;


procedure TsgeShell.PrepareTAB;
begin
  GetMatchList(FTABList, FEditor.Line);
  FTABMode := stmOption;
  FTABIndex := -1;
end;


function TsgeShell.GetNextTABCommand: String;
var
  c: Integer;
begin
  Result := '';
  c := FTABList.Count;
  if c > 0 then
    begin
    Inc(FTABIndex);
    if FTABIndex > c - 1 then FTABIndex := 0;
    Result := FTABList.Part[FTABIndex];
    end;
end;


function TsgeShell.GetPrevTABCommand: String;
var
  c: Integer;
begin
  Result := '';
  c := FTABList.Count;
  if c > 0 then
    begin
    Dec(FTABIndex);
    if FTABIndex < 0 then FTABIndex := c - 1;
    Result := FTABList.Part[FTABIndex];
    end;
end;


procedure TsgeShell.SetScanMode(AMode: Boolean);
var
  s: String;
begin
  FScanMode := AMode;

  if FScanMode then
    begin
    LogMessage('');
    s := FMsgScanModeOn;
    end else s := FMsgScanModeOff;
  LogMessage(s, sltNote);
end;


procedure TsgeShell.SetJournalOffset(AOffset: Integer);
var
  Cnt: Integer;
begin
  Cnt := FJournal.Count;
  if AOffset + FVisibleLines > Cnt then AOffset := Cnt - FVisibleLines;
  if AOffset < 0 then AOffset := 0;

  FJournalOffset := AOffset;
end;


procedure TsgeShell.SetJournalPageSize(ASize: Byte);
begin
  if ASize < 1 then ASize := 1;
  FJournalPageSize := ASize;
end;


procedure TsgeShell.SetSubstChar(Str: ShortString);
begin
  Str := Trim(Str);
  if Str = '' then FSubstChar := '@' else FSubstChar := Str[1];
end;


procedure TsgeShell.SetStapleChar(Str: ShortString);
begin
  Str := Trim(Str);
  if Str = '' then FStapleChar := #39 else FStapleChar := Str[1];
end;


constructor TsgeShell.Create;
begin
  //Указатели
  SGE := TSimpleGameEngine(ObjectList.NamedObject[Obj_SGE]);

  //Классы
  FSets := TsgeSimpleParameters.Create;
  FCommands := TsgeShellCommandList.Create;
  FKeyTable := TsgeKeyTable.Create;
  FCommandHistory := TsgeCommandHistory.Create(1024);
  FEditor := TsgeLineEditor.Create;
  FJournal := TsgeColoredLineList.Create(1024);
  FFont := TsgeGraphicFont.Create('Courier New', 14, [gfaBold]);
  FTABList := TsgeStringList.Create;

  //Переменные
  FLogErrors := True;
  FVisibleLines := 16;
  FStrictSearch := False;
  FSetsSearch := True;
  FSortMatchList := True;
  FTABMode := stmSearch;
  FTABIndex := -1;
  FScanMode := False;
  FJournalOffset := 0;
  FJournalPageSize := 5;
  FSubstChar := '@';
  FStapleChar := #39;

  //Цвета
  FBGColor     := sgeGraphicColor_RGBAToColor(0, 0, 0, 200);
  FEditorColor := sgeGraphicColor_RGBAToColor(255, 255, 255, 255);
  FCursorColor := sgeGraphicColor_RGBAToColor(255, 255, 255, 255);
  FSelectColor := sgeGraphicColor_ChangeAlpha(FCursorColor, 0.5);
  FErrorColor  := sgeGraphicColor_RGBAToColor(255, 0, 0, 255);
  FTextColor   := sgeGraphicColor_RGBAToColor(255, 255, 255, 255);
  FNoteColor   := sgeGraphicColor_RGBAToColor(255, 255, 255, 127);

  //Сообщения
  FMsgHelpHint    := 'Type "Help CmdName" for info, "CmdList" for command list';
  FMsgScanModeOn  := 'Scan mode is Enable';
  FMsgScanModeOff := 'Scan mode is Disable';
  FMsgKeyName     := 'Key name';
end;


destructor TsgeShell.Destroy;
begin
  FTABList.Free;
  FKeyTable.Free;
  FCommands.Free;
  FSets.Free;
  FCommandHistory.Free;
  FEditor.Free;
  FJournal.Free;
  FFont.Free;
end;


procedure TsgeShell.UpdateLanguage;
begin
  FMsgHelpHint := SGE.Language.GetValue('Shell:Hint', FMsgHelpHint);
  FMsgScanModeOn := SGE.Language.GetValue('Shell:ScanModeOn', FMsgScanModeOn);
  FMsgScanModeOff := SGE.Language.GetValue('Shell:ScanModeOff', FMsgScanModeOff);
  FMsgKeyName := SGE.Language.GetValue('Shell:KeyName', FMsgKeyName);
end;


function TsgeShell.GetJournalInterval: TsgeInterval;
begin
  Result.Start := FJournal.Count - 1 - FJournalOffset;
  Result.Stop  := Result.Start - FVisibleLines + 1;
  if Result.Stop < 0 then Result.Stop := 0;
end;


procedure TsgeShell.LogMessageLocalized(LngConst: String; Postfix: ShortString; rType: TsgeShellLineType);
begin
  LngConst := SGE.Language.GetValue('Cmd:' + LngConst, LngConst);
  LogMessage(LngConst + Postfix, rType);
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


procedure TsgeShell.DoCommand(Command: String);
const
  ModeEmpty = 0;
  ModeSet = 1;
  ModeCmd = 2;
  ModeAutor = 3;
var
  Cmd: TsgeSimpleCommand;
  List: TsgeStringList;
  Mode: Byte;
  cName, s: String;
  SetIdx, CmdIdx, i, c: Integer;
begin
  Command := Trim(Command);
  if Command = '' then Exit;

  try
    //Подставить переменные
    Command := sgeSubstituteParameterToString(Command, SGE.Parameters, FSubstChar);

    //Подготовить команду
    Cmd := TsgeSimpleCommand.Create;
    Cmd.Separators := #32;                                            //Разделитель между частями
    Cmd.WeakSeparator := True;                                        //Мягкий разделитель
    Cmd.Command := Command;                                           //Разобрать строку на части

    //Подготовить имя
    cName := LowerCase(Trim(Cmd.Part[0]));                            //Выделить имя команды
    if cName[1] = '#' then Exit;                                      //Проверить на заметку

    //Прокрутить журнал вниз (Заплатка)
    FJournalOffset := 0;

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
        SGE.LogError(sgeCreateErrorString(_UNITNAME, Err_CommandNotFound, Cmd.Part[0]));

      ModeSet:
        begin
        List := TsgeStringList.Create;
        List.Separator := ';';
        List.FromString(FSets.Parameter[SetIdx].Value);

        c := List.Count - 1;
        for i := 0 to c do
          DoCommand(List.Part[i]);

        List.Free;
        end;

      ModeCmd:
        //Проверить указатель
        if FCommands.Command[CmdIdx].Addr <> nil then
          begin

          //Проверить хватает ли параметров
          if Cmd.Count >= FCommands.Command[CmdIdx].MinParams + 1 then
            begin

            //Выполнить команду
            try
              s := FCommands.Command[CmdIdx].Addr(Cmd);
            except
              SGE.LogError(sgeCreateErrorString(_UNITNAME, Err_UnexpectedError, Command));
            end;

            //Проверить код выполнения
            if s <> '' then SGE.LogError(sgeCreateErrorString(_UNITNAME, Err_CommandError, Command, s));

            end
            else SGE.LogError(sgeCreateErrorString(_UNITNAME, Err_NotEnoughParameters, Command));

          end
          else SGE.LogError(sgeCreateErrorString(_UNITNAME, Err_EmptyPointer, Command));

      ModeAutor: FJournal.Add(GC_Lime, 'sge.ntlab.su  accuratealx@gmail.com');
    end;



  finally
    Cmd.Free;
  end;
end;


procedure TsgeShell.KeyChar(Chr: Char; KeyboardButtons: TsgeKeyboardButtons);
begin
  if FScanMode then Exit;

  FEditor.ProcessChar(Chr, KeyboardButtons);
end;


procedure TsgeShell.KeyDown(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);
const
  mList = 0;
  mNext = 1;
  mPrev = 2;
var
  s: String;
  List: TsgeStringList;
  i, c: Integer;
  Mode: Byte;
begin
  //Переключение режима сканирования
  if (kbLeftShift in KeyboardButtons) and (Key = VK_ESCAPE) then
    begin
    ScanMode := not ScanMode;
    FJournalOffset := 0;
    Exit;
    end;

  //Вывод имени клавиши
  if FScanMode then
    begin
    s := FKeyTable.GetNameByIndex(Key);
    if s <> '' then LogMessage(FMsgKeyName + ' = ' + s);
    Exit;
    end;




  //Обработать нажатие
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
          List := TsgeStringList.Create;
          GetMatchList(List, Trim(FEditor.Line));

          c := List.Count;
          if c > 0 then
            begin
            FJournalOffset := 0;
            LogMessage('');
            LogMessageLocalized('Found', ': ' + FEditor.Line);
            for i := 0 to c - 1 do
              LogMessage(List.Part[i]);
            LogMessageLocalized('Count', ': ' + IntToStr(c));
            end;

          List.Free;
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


    //Прокрутить вниз
    VK_NEXT: if (kbCtrl in KeyboardButtons) then JournalOffset := JournalOffset - FJournalPageSize else JournalOffset := JournalOffset - 1;


    //Прокрутить вверх
    VK_PRIOR: if (kbCtrl in KeyboardButtons) then JournalOffset := JournalOffset + FJournalPageSize else JournalOffset := JournalOffset + 1;


    //Прочие клавиши передать в редактор
    else
      begin
      if not (kbShift in KeyboardButtons) then FTABMode := stmSearch;
      FEditor.ProcessKey(Key, KeyboardButtons);
      end;

  end;
end;


procedure TsgeShell.MouseDown(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons);
var
  s: String;
begin
  //Вывод имени клавиши
  if FScanMode then
    begin
    s := FKeyTable.GetNameByIndex(sgeGetMouseButtonIdx(MouseButtons));
    if s <> '' then LogMessage(FMsgKeyName + ' = ' + s);
    end;
end;


procedure TsgeShell.MouseScroll(X, Y: Integer; MouseButtons: TsgeMouseButtons; KeyboardButtons: TsgeKeyboardButtons; Delta: Integer);
var
  i: Integer;
begin
  //Вывод имени клавиши
  if FScanMode then
    begin
    LogMessage(FMsgKeyName + ' = ' + FKeyTable.GetNameByIndex(5));
    Exit;
    end;


  //Прокрутка журнала
  if kbCtrl in KeyboardButtons then i := FJournalPageSize else i := 1;
  if Delta > 0 then JournalOffset := JournalOffset + i else JournalOffset := JournalOffset - i;
end;




end.

