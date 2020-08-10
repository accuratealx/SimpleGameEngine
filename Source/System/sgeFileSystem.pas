{
Пакет             Simple Game Engine 1
Файл              sgeFileSystem.pas
Версия            1.7
Создан            28.05.2020
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Доступ к файловой системе и архивам
}

unit sgeFileSystem;

{$mode objfpc}{$H+}

interface

uses
  sgeStringList, sgeMemoryStream, sgePackFileList, sgeFileSystemPackFileList;


type
  TsgeFileSystem = class
  private
    //Классы
    FPackList: TsgePackFileList;
    FFileList: TsgeFileSystemPackFileList;

    //Переменные
    FMainDir: String;

    procedure SetDirMain(ADir: String);
  public
    constructor Create(MainDir: String); virtual;
    destructor  Destroy; override;

    //Архивы
    procedure ClearPack;                                                      //Удалить все архивы
    procedure AddPack(FileName: String);                                      //Добавить архив в файловую систему
    procedure DeletePack(Name: String);                                       //Удалить архив из файловой системы

    //Операции с каталогами
    procedure ForceDirectories(Directory: String);                            //Создать недостающие каталоги
    function  DirectoryExists(Directory: String): Boolean;                    //Проверить есть ли каталог

    //Операции с файлами
    function  FileExists(FileName: String): Boolean;                          //Проверить есть файл или нет
    procedure ReadFile(FileName: String; Stream: TsgeMemoryStream);           //Прочитать файл с диска
    procedure WriteFile(FileName: String; Stream: TsgeMemoryStream);          //Записать файл на диск
    procedure DeleteFile(FileName: String);                                   //Удалить файл
    procedure RenameFile(OldName, NewName: String);                           //Переименовать файл
    function  GetFileSize(FileName: String): Integer;                         //Узнать размер файла
    procedure GetFileList(Directory: String; List: TsgeStringList);           //Узнать список файлов в каталоге
    procedure GetDirectoryList(Directory: String; List: TsgeStringList);      //Узнать список папок в каталоге
    Procedure FindFiles(Directory: String; List: TsgeStringList; Ext: String = ''); //Рекурсивный поиск файлов по расширению

    property MainDir: String read FMainDir write SetDirMain;
    property PackList: TsgePackFileList read FPackList;
    property FileList: TsgeFileSystemPackFileList read FFileList;
  end;


implementation

uses
  sgeConst, sgeTypes, sgeFile, sgePackFileReader,
  SysUtils, LazUTF8, FileUtil;


const
  _UNITNAME = 'sgeFileSystem';



procedure sgeFileSystem_FindFilesInFolders(Path: String; List: TsgeStringList);
var
  o: TSearchRec;
  Idx: Integer;
begin
  Path := IncludeTrailingBackslash(Path);

  Idx := FindFirst(Path + '*', faAnyFile, o);
  while Idx = 0 do
    begin

    if (o.Name <> '.') and (o.Name <> '..') then
      begin
      if (o.Attr and faDirectory) = faDirectory then sgeFileSystem_FindFilesInFolders(Path + o.Name, List)
        else List.Add(Path + o.Name);
      end;

    Idx := FindNext(o);
    end;

  FindClose(o);
end;


procedure TsgeFileSystem.SetDirMain(ADir: String);
begin
  ADir := IncludeTrailingBackslash(ADir);
  FMainDir := ADir;
end;

constructor TsgeFileSystem.Create(MainDir: String);
begin
  FPackList := TsgePackFileList.Create;
  FFileList := TsgeFileSystemPackFileList.Create;

  FMainDir := IncludeTrailingBackslash(MainDir);
end;


destructor TsgeFileSystem.Destroy;
begin
  FFileList.Free;
  FPackList.Free;
end;


procedure TsgeFileSystem.AddPack(FileName: String);
var
  F: TsgePackFileReader;
  Item: TsgeFileSystemPackFile;
  i, c: Integer;
  fn: String;
begin
  //Определить путь до файла
  fn := '';
  if FileExists(FileName) then fn := FileName;
  if FileExists(FMainDir + FileName) then fn := FMainDir + FileName;

  //Проверить существование файла
  if not FileExists(fn) then
    raise EsgeException.Create(_UNITNAME, Err_FileNotFound, FileName);

  //Загрузить файл
  try
    F := TsgePackFileReader.Create(fn);
  except
    on E: EsgeException do
      raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName, E.Message);
  end;

  //Добавить в массив архивов
  FPackList.Add(F);


  //Поиск по архиву файлов
  c := F.Count - 1;
  for i := 0 to c do
    begin
    //Создать запись
    Item.Pack := F;
    Item.Index := i;
    Item.Name := F.Item[i].FileName;
    Item.Size := F.Item[i].DataSize;

    //Добавить в список файлов
    FFileList.Add(Item);
    end;
end;


procedure TsgeFileSystem.DeletePack(Name: String);
var
  Idx: Integer;
begin
  //Найти индекс архива по имени
  Idx := FPackList.IndexOf(Name);
  if Idx = -1 then
    raise EsgeException.Create(_UNITNAME, Err_NameNotFound, Name);

  //Удалить из списка файлы
  FFileList.Delete(FPackList.Item[Idx]);

  //Удалить архив
  FPackList.Delete(Idx);
end;


procedure TsgeFileSystem.ForceDirectories(Directory: String);
begin
  if Directory = '' then Exit;

  try
    SysUtils.ForceDirectories(FMainDir + Directory);
  except
    raise EsgeException.Create(_UNITNAME, Err_CantCreateDirectory, Directory);
  end;
end;


function TsgeFileSystem.DirectoryExists(Directory: String): Boolean;
begin
  Result := SysUtils.DirectoryExists(Directory);
end;


function TsgeFileSystem.FileExists(FileName: String): Boolean;
var
  i, c: Integer;
  Fn: String;
begin
  Result := False;

  //Проверить в файловой системе
  if SysUtils.FileExists(FMainDir + FileName) then
    begin
    Result := True;
    Exit;
    end;

  //Проверить в архивах
  c := FFileList.Count - 1;
  Fn := UTF8LowerCase(FileName);
  for i := c downto 0 do
    if Fn = UTF8LowerCase(FFileList.Item[i].Name) then
      begin
      Result := True;
      Break;
      end;
end;


procedure TsgeFileSystem.ClearPack;
begin
  FPackList.Clear;
  FFileList.Clear;
end;


procedure TsgeFileSystem.ReadFile(FileName: String; Stream: TsgeMemoryStream);
const
  ModeFile = 0;
  ModePack = 1;
var
  fn: String;
  F: TsgeFile;
  Item: TsgeFileSystemPackFile;
  Idx: Integer;
  Mode: Byte;
begin
  //Определить имя файла
  fn := '';
  if SysUtils.FileExists(FMainDir + FileName) then fn := FMainDir + FileName;

  //Определить способ загрузки
  if fn <> '' then Mode := ModeFile else Mode := ModePack;


  case Mode of
    //Файл
    ModeFile:
      try
        F := TsgeFile.Create(fn, fmRead);
        Stream.Size := F.Size;
        F.Read(Stream.Data^, F.Size);
        F.Free;
      except
        on E: EsgeException do
          raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName, E.Message);
      end;


    //Архив
    ModePack:
      begin
      //Поиск индекса в архивах
      Idx := FFileList.IndexOf(FileName);
      if Idx = -1 then
        raise EsgeException.Create(_UNITNAME, Err_FileNotFound, FileName);

      //Загрузка из архива
      try
        Item := FFileList.Item[Idx];
        Item.Pack.GetItemData(Item.Index, Stream);
      except
        raise EsgeException.Create(_UNITNAME, Err_FileReadError, FileName);
      end;
      end;
  end;
end;


procedure TsgeFileSystem.WriteFile(FileName: String; Stream: TsgeMemoryStream);
begin
  try
    Stream.SaveToFile(FMainDir + FileName);
  except
    raise EsgeException.Create(_UNITNAME, Err_FileWriteError, FileName);
  end;
end;


procedure TsgeFileSystem.DeleteFile(FileName: String);
begin
  if not SysUtils.DeleteFile(FileName) then
    raise EsgeException.Create(_UNITNAME, Err_CantDeleteFile, FileName);
end;


procedure TsgeFileSystem.RenameFile(OldName, NewName: String);
begin
  if not SysUtils.RenameFile(FMainDir + OldName, FMainDir + NewName) then
    raise EsgeException.Create(_UNITNAME, Err_CantRenameFile);
end;


function TsgeFileSystem.GetFileSize(FileName: String): Integer;
var
  c, i: Integer;
  Fn: String;
begin
  Result := -1;

  //Проверить файл на диске
  Fn := FMainDir + FileName;
  if SysUtils.FileExists(Fn) then
    begin
    Result := FileUtil.FileSize(Fn);
    Exit;
    end;


  //Поиск в архивах
  c := FFileList.Count - 1;
  Fn := UTF8LowerCase(FileName);
  for i := c downto 0 do
    if Fn = UTF8LowerCase(FFileList.Item[i].Name) then
      begin
      Result := FFileList.Item[i].Size;
      Break;
      end;
end;


procedure TsgeFileSystem.GetFileList(Directory: String; List: TsgeStringList);
var
  O: TSearchRec;
  Idx: Integer;
  fnPath: String;
  i, c: Integer;
  so: TsgeSearchOptions;
begin
  //Подготовить список
  List.Clear;
  so := List.SearchOptions;
  List.SearchOptions := [soUnique];


  //Поиск файлов в локальной файловой системе
  Idx := FindFirst(IncludeTrailingBackslash(FMainDir + Directory) + '*', faAnyFile, o);
  while Idx = 0 do
    begin
    if (O.Name <> '.') and (O.Name <> '..') then
      if (O.Attr and faDirectory) <> faDirectory then List.Add(O.Name);

    Idx := FindNext(o);
    end;
  FindClose(o);


  //Поиск совпадений в виртуальной файловой системе
  if Directory <> '' then
    Directory := UTF8LowerCase(IncludeTrailingBackslash(Directory));

  c := FFileList.Count - 1;
  for i := c downto 0 do
    begin
    fnPath := UTF8LowerCase(ExtractFilePath(FFileList.Item[i].Name));
    if fnPath = Directory then List.Add(ExtractFileName(FFileList.Item[i].Name));
    end;


  //Вернуть режим
  List.SearchOptions := so;
end;


procedure TsgeFileSystem.GetDirectoryList(Directory: String; List: TsgeStringList);
var
  O: TSearchRec;
  fn: String;
  Idx, i, c, DirSize: Integer;
  so: TsgeSearchOptions;
  Lst: TsgeStringList;
  B: Boolean;
begin
  //Подготовить список
  List.Clear;
  so := List.SearchOptions;
  List.SearchOptions := [soUnique];


  //Поиск папок в локальной файловой системе
  Idx := FindFirst(IncludeTrailingBackslash(FMainDir + Directory) + '*', faAnyFile, o);
  while Idx = 0 do
    begin
    if (O.Name <> '.') and (O.Name <> '..') then
      if (O.Attr and faDirectory) = faDirectory then List.Add(O.Name);

    Idx := FindNext(o);
    end;
  FindClose(o);


  //Поиск совпадений в виртуальной файловой системе
  if Directory <> '' then Directory := UTF8LowerCase(IncludeTrailingBackslash(Directory));
  DirSize := UTF8Length(Directory);

  c := FFileList.Count - 1;
  Lst := TsgeStringList.Create;
  Lst.Separator := '\';
  for i := c downto 0 do
    begin
    fn := ExtractFilePath(FFileList.Item[i].Name);                //Выделить путь из имени файла
    B := False;
    if Directory = '' then B := True;                             //Частный случай, Корень системы
    if UTF8Pos(Directory, UTF8LowerCase(fn)) = 1 then B := True;  //Совпадение с начальным каталогом
    if B then
      begin
      UTF8Delete(fn, 1, DirSize);                                 //Отрезать базовый путь
      Lst.FromString(fn);                                         //Разобрать путь на части
      if Lst.Count > 0 then List.Add(Lst.Part[0]);                //Если есть больше одной части, то добавить
      end;
    end;
  Lst.Free;


  //Вернуть режим списку
  List.SearchOptions := so;
end;


procedure TsgeFileSystem.FindFiles(Directory: String; List: TsgeStringList; Ext: String);
var
  Lst: TsgeStringList;
  i, c, DirSize: Integer;
  fn, fnExt: String;
  so: TsgeSearchOptions;
  B: Boolean;
begin
  //Подготовить список
  so := List.SearchOptions;
  List.SearchOptions := [soUnique];
  List.Clear;


  //Подготовить расширение
  Ext := UTF8LowerCase(Ext);                                      //В нижний регистр
  if (Ext <> '') and (Ext[1] = '.') then UTF8Delete(Ext, 1, 1);   //Отрезать точку в расширении


  //Поиск всех файлов в каталоге
  DirSize := UTF8Length(IncludeTrailingBackslash(FMainDir + Directory));  //Длина базового каталога
  Lst := TsgeStringList.Create;
  sgeFileSystem_FindFilesInFolders(FMainDir + Directory, Lst);    //Найти все файлы в папке
  c := Lst.Count - 1;
  for i := 0 to c do
    begin
    fn := Lst.Part[i];                                            //Имя файла
    UTF8Delete(fn, 1, DirSize);                                   //Удалить базовый путь
    B := False;
    if Ext = '' then B := True;                                   //Частный случай, нет расширения
    fnExt := UTF8LowerCase(ExtractFileExt(fn));                   //Определить расширение файла
    if (fnExt <> '') and (fnExt[1] = '.') then UTF8Delete(fnExt, 1, 1); //Отрезать точку от расширения
    if fnExt = Ext then B := True;                                //Совпадение расширения
    if B then List.Add(fn);                                       //Добавить в результат
    end;
  Lst.Free;


  //Поиск файлов в виртуальной файловой системе
  Directory := UTF8LowerCase(Directory);                          //В нижний регистр
  c := FFileList.Count - 1;
  DirSize := UTF8Length(Directory);                               //Длина базового каталога
  if Directory <> '' then Inc(DirSize);                           //Если это не корень, то добавить \
  for i := 0 to c do
    begin
    fn := FFileList.Item[i].Name;                                 //Имя файла
    B := False;
    if Directory = '' then B := True;                             //Частный случай, корень системы
    if UTF8Pos(Directory, UTF8LowerCase(fn)) = 1 then B := True;  //Совпадение каталога
    if B then
      begin
      UTF8Delete(fn, 1, DirSize);                                 //Удалить базовый путь
      B := False;
      if Ext = '' then B := True;                                 //Частный случай, пустое расширение
      fnExt := UTF8LowerCase(ExtractFileExt(FFileList.Item[i].Name));     //Определить расширение файла
      if (fnExt <> '') and (fnExt[1] = '.') then UTF8Delete(fnExt, 1, 1); //Отрезать точку от расширения
      if fnExt = Ext then B := True;                              //Совпадение расширения
      if B then List.Add(fn);                                     //Добавить в результат
      end;
    end;


  //Восстановить настройки списка
  List.SearchOptions := so;
end;





end.

