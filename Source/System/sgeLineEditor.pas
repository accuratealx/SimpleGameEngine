{
Пакет             Simple Game Engine 1
Файл              sgeLineEditor.pas
Версия            1.3
Создан            08.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Однострочный редактор текста
}

unit sgeLineEditor;

{$mode objfpc}{$H+}

interface

uses
  sgeTypes;


type
  TsgeLineEditor = class
  private
    FLine: String;                                            //Строка введённого текста
    FStopChars: String;                                       //Стоповые символы
    FCursorPos: Integer;                                      //Текущее положение курсора
    FSelecting: Boolean;                                      //Режим выделения
    FSelectBeginPos: Integer;                                 //Начальное положение курсора выделения
    FSelectEndPos: Integer;                                   //Конечное положение курсора выделения

    procedure GetSelectionIdxAndSize(out Idx, Size: Integer);
    procedure InsertString(APos: Integer; Str: String);
    function  IsStopChar(Chr: Char): Boolean;
    procedure SetLine(ALine: String);
    function  GetSelectCount: Integer;
    procedure SetCursorPos(APos: Integer);
    procedure SetSelectBeginPos(APos: Integer);
    procedure SetSelectEndPos(APos: Integer);
    function  GetLeftStopCharIndex: Integer;
    function  GetRightStopCharIndex: Integer;
    procedure CursorToBegin;
    procedure CursorToEnd;
    procedure CursorToRight;
    procedure CursorToLeft;
    procedure CursorToRightStopChar;
    procedure CursorToLeftStopChar;
    procedure DeleteSymbolRight;
    procedure DeleteSymbolLeft;
    procedure DeleteSymbolRightToStopChar;
    procedure DeleteSymbolLeftToStopChar;
    procedure ClipboardCopy;
    procedure ClipboardPaste;
    procedure ClipboardCut;
  public
    constructor Create;

    procedure SelectAll;
    procedure ClearSelection;
    procedure DeleteSelection;
    function  GetTextBeforePos(APos: Integer): String;
    procedure ProcessChar(Chr: Char; KeyboardButtons: TsgeKeyboardButtons);
    procedure ProcessKey(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);

    property CursorPos: Integer read FCursorPos write SetCursorPos;
    property SelectBeginPos: Integer read FSelectBeginPos write SetSelectBeginPos;
    property SelectEndPos: Integer read FSelectEndPos write SetSelectEndPos;
    property SelectCount: Integer read GetSelectCount;
    property StopChars: String read FStopChars write FStopChars;
    property Line: String read FLine write SetLine;
  end;


implementation

uses
  Windows;



{
Описание
  Вставить строку в буфер обмена
Параметры
  Str - Строка для вставки
Результат
  0 - Успешно
  1 - Пустая строка
  2 - Невозможно выделить память
  3 - Невозможно заблокировать память
  4 - Невозможно открыть буфер обмена
  5 - Невозможно очистить буфер обмена
  6 - Невозможно записать строку в буфер обмена
  7 - Невозможно закрыть буфер обмена
}
function Win32CopyStringToClipboard(Str: String): Integer;
var
  ptr: Pointer;
  Handle: HGLOBAL;
  Size: Integer;
  WS: WideString;
begin
  Result := 0;

  if Str = '' then                            //Нечего передавать
    begin
    Result := 1;
    Exit;
    end;

  {$Warnings Off}
  WS := Str;                                  //В микрософте юникод 2 байтный, преобразовать
  {$Warnings On}

  Size := (Length(WS) + 1) * 2;               //Определить длину на конце символ #0

  Handle := GlobalAlloc(GMEM_MOVEABLE, Size); //Выделить память из глобальной кучи
  if Handle = 0 then
    begin
    Result := 2;
    Exit;
    end;

  ptr := GlobalLock(Handle);                  //Заблокировать память от перемещения
  if ptr = nil then
    begin
    Result := 3;
    GlobalFree(Handle);
    Exit;
    end;

  Move(PWideChar(WS)^, ptr^, Size);           //Скопировать строку в глобальную память
  GlobalUnlock(Handle);                       //Отменить блокировку памяти

  if not OpenClipboard(0) then                //Открыть буфер обмена
    begin
    Result := 4;
    GlobalFree(Handle);
    Exit;
    end;

  if not EmptyClipboard then                  //Стереть данные в буфере обмена от других программ
    begin
    Result := 5;
    GlobalFree(Handle);
    Exit;
    end;

  if SetClipboardData(CF_UNICODETEXT, Handle) = 0 then  //Отдать в буфер обмена строку юникода
    begin
    Result := 6;
    GlobalFree(Handle);
    Exit;
    end;

  if not CloseClipboard then Result := 7;     //Закрыть буфер обмена
end;


{
Описание
  Скопировать строку из буфера обмена
Параметры
  Str - Строка для вставки
Результат
  0 - Успешно
  1 - Невозможно открыть буфер обмена
  2 - Невозможно прочитать строку из буфера обмена
  3 - Невозможно закрыть буфер обмена
  4 - Невозможно заблокировать память
  5 - Невозможно узнать размер данных
}
function Win32CopyStringFromClipboard(var Str: String): Integer;
var
  Handle: HGLOBAL;
  ptr: Pointer;
  Size: Integer;
  buf: array of Byte;
begin
  Result := 0;

  if not OpenClipboard(0) then                //Открыть буфер обмена
    begin
    Result := 1;
    Exit;
    end;

  Handle := GetClipboardData(CF_UNICODETEXT); //Взять указатель на глобальный блок памяти
  if Handle = 0 then
    begin
    Result := 2;
    Exit;
    end;

  if not CloseClipboard then                  //Закрыть буфер обмена
    begin
    Result := 3;
    Exit;
    end;

  ptr := GlobalLock(Handle);                  //Заблокировать память от перемещения
  if ptr = nil then
    begin
    Result := 4;
    Exit;
    end;

  Size := GlobalSize(Handle);                 //Узнать размер данных
  if Size = 0 then
    begin
    Result := 5;
    Exit;
    end;

  SetLength(buf, Size);                       //Подготовить буфер для копирования
  CopyMemory(@buf[0], ptr, Size);             //Скопировать юникодную строку в буфер
  GlobalUnlock(Handle);                       //Отменить блоктровку памяти

  Str := PWideChar(buf);                      //Преобразовать в строку Ansi

  SetLength(buf, 0);
end;





procedure TsgeLineEditor.GetSelectionIdxAndSize(out Idx, Size: Integer);
begin
  if SelectEndPos > FSelectBeginPos then Idx := FSelectBeginPos else Idx := FSelectEndPos;
  Size := GetSelectCount;
end;


procedure TsgeLineEditor.InsertString(APos: Integer; Str: String);
var
  c: Integer;
begin
  c := Length(FLine);
  if APos < 0 then APos := 0;
  if APos > c then APos := c;
  Insert(Str, FLine, APos + 1);
  FCursorPos := APos + Length(Str);
end;


function TsgeLineEditor.IsStopChar(Chr: Char): Boolean;
var
  i, c: Integer;
begin
  Result := False;
  c := Length(FStopChars);
  for i := 1 to c do
    if Chr = FStopChars[i] then
      begin
      Result := True;
      Break;
      end;
end;


procedure TsgeLineEditor.SetLine(ALine: String);
begin
  FLine := ALine;
  FCursorPos := Length(FLine);
  ClearSelection;
end;


function TsgeLineEditor.GetSelectCount: Integer;
begin
  Result := Abs(FSelectBeginPos - FSelectEndPos);
end;


procedure TsgeLineEditor.SetCursorPos(APos: Integer);
var
  c: Integer;
begin
  c := Length(FLine);
  if APos < 0 then APos := 0;
  if APos > c then APos := c;
  FCursorPos := APos;
end;


procedure TsgeLineEditor.SetSelectBeginPos(APos: Integer);
var
  c: Integer;
begin
  c := Length(FLine);
  if APos < 0 then APos := 0;
  if APos > c then APos := c;
  FSelectBeginPos := APos;
end;


procedure TsgeLineEditor.SetSelectEndPos(APos: Integer);
var
  c: Integer;
begin
  c := Length(FLine);
  if APos < 0 then APos := 0;
  if APos > c then APos := c;
  FSelectEndPos := APos;
end;


function TsgeLineEditor.GetLeftStopCharIndex: Integer;
var
  i: Integer;
  chr1, chr2: Char;
begin
  Result := 0;
  if FCursorPos < 1 then Exit;

  for i := FCursorPos - 1 downto 2 do
    begin
    chr1 := FLine[i];
    chr2 := FLine[i - 1];
    if IsStopChar(chr1) and (chr1 <> chr2) then
      begin
      Result := i;
      Break;
      end;
    end;
end;


function TsgeLineEditor.GetRightStopCharIndex: Integer;
var
  i, c: Integer;
  chr1, chr2: Char;
begin
  c := Length(FLine);
  Result := c;
  Dec(c);
  if FCursorPos > c then Exit;

  for i := FCursorPos + 2 to c do
    begin
    chr1 := FLine[i];
    chr2 := FLine[i + 1];
    if IsStopChar(chr1) and (chr1 <> chr2) then
      begin
      Result := i - 1;
      Break;
      end;
    end;
end;


procedure TsgeLineEditor.CursorToBegin;
begin
  FCursorPos := 0;
  if FSelecting then FSelectEndPos := FCursorPos else ClearSelection;
end;


procedure TsgeLineEditor.CursorToEnd;
begin
  FCursorPos := Length(FLine);
  if FSelecting then FSelectEndPos := FCursorPos else ClearSelection;
end;


procedure TsgeLineEditor.CursorToRight;
var
  c: Integer;
begin
  c := Length(FLine);
  Inc(FCursorPos);
  if FCursorPos > c then FCursorPos := c;
  if FSelecting then FSelectEndPos := FCursorPos else ClearSelection;
end;


procedure TsgeLineEditor.CursorToLeft;
begin
  Dec(FCursorPos);
  if FCursorPos < 0 then FCursorPos := 0;
  if FSelecting then FSelectEndPos := FCursorPos else ClearSelection;
end;


procedure TsgeLineEditor.CursorToRightStopChar;
begin
  FCursorPos := GetRightStopCharIndex;
  if FSelecting then FSelectEndPos := FCursorPos else ClearSelection;
end;


procedure TsgeLineEditor.CursorToLeftStopChar;
begin
  FCursorPos := GetLeftStopCharIndex;
  if FSelecting then FSelectEndPos := FCursorPos else ClearSelection;
end;


procedure TsgeLineEditor.DeleteSymbolRight;
begin
  if FCursorPos > Length(FLine) then Exit;

  if not FSelecting and (SelectCount <> 0) then
    begin
    DeleteSelection;
    ClearSelection;
    Exit;
    end;

  Delete(FLine, FCursorPos + 1, 1);
end;


procedure TsgeLineEditor.DeleteSymbolLeft;
begin
  if FCursorPos < 1 then Exit;

  if not FSelecting and (SelectCount <> 0) then
    begin
    DeleteSelection;
    ClearSelection;
    Exit;
    end;

  Delete(FLine, FCursorPos, 1);
  Dec(FCursorPos);
end;


procedure TsgeLineEditor.DeleteSymbolRightToStopChar;
begin
  if not FSelecting and (SelectCount <> 0) then
    begin
    DeleteSelection;
    ClearSelection;
    Exit;
    end;

  Delete(FLine, FCursorPos + 1, GetRightStopCharIndex - FCursorPos);
end;


procedure TsgeLineEditor.DeleteSymbolLeftToStopChar;
var
  Idx: Integer;
begin
  if not FSelecting and (SelectCount <> 0) then
    begin
    DeleteSelection;
    ClearSelection;
    Exit;
    end;

  Idx := GetLeftStopCharIndex;
  Delete(FLine, Idx + 1, FCursorPos - Idx);
  FCursorPos := Idx;
end;


procedure TsgeLineEditor.ClipboardCopy;
var
  Idx, Count: Integer;
  s: String;
begin
  if SelectCount = 0 then Exit;
  GetSelectionIdxAndSize(Idx, Count);
  s := Copy(FLine, Idx + 1, Count);
  Win32CopyStringToClipboard(s);
end;


{$Hints Off}
procedure TsgeLineEditor.ClipboardPaste;
var
  Idx: Integer;
  s: String;
begin
  DeleteSelection;
  Idx := Win32CopyStringFromClipboard(s);
  if Idx <> 0 then Exit;
  InsertString(FCursorPos, s);
  ClearSelection;
end;
{$Hints On}


procedure TsgeLineEditor.ClipboardCut;
var
  Idx, Count: Integer;
  s: String;
begin
  if SelectCount = 0 then Exit;
  GetSelectionIdxAndSize(Idx, Count);
  s := Copy(FLine, Idx + 1, Count);
  DeleteSelection;
  Win32CopyStringToClipboard(s);
end;


constructor TsgeLineEditor.Create;
begin
  FStopChars := ' .:=/\,;';
end;


procedure TsgeLineEditor.SelectAll;
begin
  FSelectBeginPos := 0;
  FSelectEndPos := Length(FLine);
  FCursorPos := FSelectEndPos;
end;


procedure TsgeLineEditor.ClearSelection;
begin
  FSelectBeginPos := FCursorPos;
  FSelectEndPos := FCursorPos;
end;


{$Hints Off}
procedure TsgeLineEditor.DeleteSelection;
var
  Idx, Count: Integer;
begin
  if SelectCount = 0 then Exit;
  GetSelectionIdxAndSize(Idx, Count);
  Delete(FLine, Idx + 1, Count);
  FCursorPos := Idx;
  ClearSelection;
end;
{$Hints On}


function TsgeLineEditor.GetTextBeforePos(APos: Integer): String;
var
  c: Integer;
begin
  c := Length(FLine);
  if APos < 0 then APos := 0;
  if APos > c then APos := c;
  Result := Copy(FLine, 1, APos);
end;


procedure TsgeLineEditor.ProcessChar(Chr: Char; KeyboardButtons: TsgeKeyboardButtons);
begin
  if kbCtrl in KeyboardButtons then Exit;             //Выход, функциональные клавиши
  if not FSelecting then DeleteSelection;             //Удалить выделенное перед вводом
  if Chr < #32 then Exit;                             //Выход, если непечатаемые символы
  if kbShift in KeyboardButtons then DeleteSelection; //Кнопка нажимается вместе с Shift, удалить выделенное

  InsertString(FCursorPos, Chr);                      //Вставить символ
end;


procedure TsgeLineEditor.ProcessKey(Key: Byte; KeyboardButtons: TsgeKeyboardButtons);
begin
  //Проверить режим выделения
  if (kbShift in KeyboardButtons) then
    begin
    FSelecting := True;                       //Включить выделение
    if SelectCount = 0 then ClearSelection;   //Если ничего не выделено, поправить положение
    end else FSelecting := False;             //Иначе отключить

  //Обработать кнопку
  case Key of
    VK_HOME   : CursorToBegin;
    VK_END    : CursorToEnd;
    VK_LEFT   : if (kbCtrl in KeyboardButtons) then CursorToLeftStopChar else CursorToLeft;
    VK_RIGHT  : if (kbCtrl in KeyboardButtons) then CursorToRightStopChar else CursorToRight;
    VK_DELETE : if (kbCtrl in KeyboardButtons) then DeleteSymbolRightToStopChar else DeleteSymbolRight;
    VK_BACK   : if (kbCtrl in KeyboardButtons) then DeleteSymbolLeftToStopChar else DeleteSymbolLeft;
    VK_Y      : if (kbCtrl in KeyboardButtons) then SetLine('');
    VK_A      : if (kbCtrl in KeyboardButtons) then SelectAll;
    VK_X      : if (kbCtrl in KeyboardButtons) then ClipboardCut;
    VK_C      : if (kbCtrl in KeyboardButtons) then ClipboardCopy;
    VK_V      : if (kbCtrl in KeyboardButtons) then ClipboardPaste;
  end;
end;



end.

