{
Пакет             Simple Tools 1
Файл              SimpleCommand.pas
Версия            1.1
Создан            21.05.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Простой синтаксический анализатор
}

unit SimpleCommand;

{$mode objfpc}{$H+}

interface

uses
  StringArray;


const
  sc_Divider = ' '; //Разделитель между частями команды
  sc_Staple = #39;  //кавычка '
  sc_Control = '`'; //Экранирующий сивмол



procedure SimpleCommand_Disassemble(sa: PStringArray; Command: String; Divider: Char = sc_Divider; Staple: Char = sc_Staple; Control: Char = sc_Control);
function  SimpleCommand_Assemble(sa: PStringArray; Divider: Char = sc_Divider; Staple: Char = sc_Staple; Control: Char = sc_Control): String;
function  SimpleCommand_SecureString(Str: String; Divider: Char = sc_Divider; Staple: Char = sc_Staple; Control: Char = sc_Control): String;



implementation



{
Описание
  Функция разбирает строку на массив строк по правилам простого синтаксиса
Параметры
  sa      - Результат работы ыункции
  Command - Команда для разбора
  Divider - Разделитель для частей, по умолчанию - "пробел"
  Staple  - Символ кавычки для обрамления пробела или экрана, по умолчанию "Апостроф"
  Control - Символ экрана, по умолчанию "Ударение"
Результат
  Массив строк в "sa"
}
procedure SimpleCommand_Disassemble(sa: PStringArray; Command: String; Divider: Char = sc_Divider; Staple: Char = sc_Staple; Control: Char = sc_Control);
const
  cAddToCurrentPart = 0;
  cAddNewPart = 1;
  cChangeStapleMode = 2;
  cEnableCtrl = 3;
var
  BStaple, BCtrl: Boolean;
  c: Char;
  i, Len, CmdLen: Integer;
  r: Byte;
begin
  //Подготовка
  StringArray_Clear(sa);                          //Почистить выходной массив
  StringArray_Add(sa);                            //Добавить одну строку, даже если команда пустая
  BStaple := False;                               //Флаг кавычки
  BCtrl := False;                                 //Флаг экрана
  CmdLen := Length(Command);                      //Узнать длину команды

  //Просмотреть символы по порядку
  for i := 1 to CmdLen do
    begin
    c := Command[i];                              //Выделить символ

    //Определить что делать с текущим символом
    r := cAddToCurrentPart;                                               //Действие по умолчанию
    if c = Divider then if not (BCtrl or BStaple) then r := cAddNewPart;  //Разделитель, проверить на кавычку или экран
    if c = Staple then  if not BCtrl then r := cChangeStapleMode;         //Кавычка, проверить на экран
    if c = Control then if not BCtrl then r := cEnableCtrl;               //Экран, проверить на кавычку или экран

    //Обработать символ
    case r of
      cAddNewPart: StringArray_Add(sa);          //Добавить пустую строку в массив
      cChangeStapleMode: BStaple := not BStaple;  //Сменить режим кавычки
      cEnableCtrl:                                //Включить режим экрана и выйти не добавляя в часть команды
        begin
        BCtrl := True;
        Continue;
        end;
      cAddToCurrentPart:                          //Обычный символ, добавить в последнюю часть
        begin
        Len := StringArray_GetCount(sa) - 1;      //Найти последнюю часть
        sa^[Len] := sa^[Len] + c;                 //Добавить в неё символ
        end;
    end;//case

    BCtrl := False;                               //Выключить флаг экрана, поскольку ранее уже предусмотрен переход на следующую итерацию цикла
    end;//for

end;



{
Описание
  Функция делает безопасной строку по правилам простого синтаксического анализатора
Параметры
  Str     - Строка для обработки
  Divider - Разделитель для частей, по умолчанию - "пробел"
  Staple  - Символ кавычки для обрамления пробела или экрана, по умолчанию "Апостроф"
  Control - Символ экрана, по умолчанию "Ударение"
Результат
  Защищённая строка
Пояснение
  Если в строке нет управляющих символов, то ничего не происходит
  Если в строке есть кавычка, то все управляющие символы экранируются
  Если в строке нет кавычек, но есть управляющие символы, то строка обрамляется кавычками
}
function SimpleCommand_SecureString(Str: String; Divider: Char = sc_Divider; Staple: Char = sc_Staple; Control: Char = sc_Control): String;
var
  i, c, di, si, ci: Integer;
  ch: Char;
begin
  Result := '';             //Значение по умолчанию
  di := Pos(Divider, Str);  //Узнать есть ли в строке разделители
  si := Pos(Staple, Str);   //Кавычки
  ci := Pos(Control, Str);  //Экран

  //Если в строке нет управляющиъ символов, то ничего не делать
  if (di = 0) and (si = 0) and (ci = 0) then
    begin
    Result := Str;
    Exit;
    end;

  //Если в строке есть кавычки, то экранировать все управляющие символы
  if si <> 0 then
    begin
    c := Length(Str);
    for i := 1 to c do
      begin
      ch := Str[i];
      if (ch = Divider) or (ch = Staple) or (ch = Control) then Result := Result + Control;
      Result := Result + ch;
      end;
    end else Result := Staple + Str + Staple;  //Если нет кавычек, то проще всё взять в кавычки
end;



{
Описание
  Функция склеивает массив частей команды в одну строку по правилам простого синтаксического анализатора
Параметры
  sa      - Массив частей команды
  Divider - Разделитель для частей, по умолчанию - "пробел"
  Staple  - Символ кавычки для обрамления пробела или экрана, по умолчанию "Апостроф"
  Control - Символ экрана, по умолчанию "Ударение"
Результат
  Команда одной строкой с экранированными частями
}
function SimpleCommand_Assemble(sa: PStringArray; Divider: Char = sc_Divider; Staple: Char = sc_Staple; Control: Char = sc_Control): String;
var
  i, c: Integer;
begin
  Result := '';
  c := StringArray_GetCount(sa) - 1;
  for i := 0 to c do
    begin
    Result := Result + SimpleCommand_SecureString(sa^[i], Divider, Staple, Control);
    if c <> i then Result := Result + Divider;
    end;
end;



end.
