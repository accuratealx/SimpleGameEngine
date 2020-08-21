{
Пакет             Simple Game Engine 1
Файл              sgeTypes.pas
Версия            1.19
Создан            06.12.2018
Автор             Творческий человек  (accuratealx@gmail.com)
Описание          Константы простого игрового движка
}

unit sgeConst;

{$mode objfpc}{$H+}

interface


const
  //Информация о ядре
  SGE_Name = 'Simple Game Engine';
  SGE_Version = '1.20';


  //Названия каталогов
  sge_DirJournal = 'Journals';
  sge_DirShoots  = 'Screenshots';
  sge_DirUser    = 'User';


  //Расширения файлов
  sge_ExtJournal = 'Journal';
  sge_ExtShots   = 'Bmp';
  sge_ExtPack    = 'SGEPack';


  //Имена парметров
  sge_PrmDebug = 'Debug';


  //Оболочка
  sge_ShellIndent = 5;


  //Группа объектов
  Group_SGE = 'SGE';

  //Имена объектов
  Obj_SGE = 'SGE';

  //Ошибки
  Err_CantInitSimpleGameEngine    = 'CantInitSimpleGameEngine';

  Err_AnimationNotFound           = 'AnimationNotFound';
  Err_BitsPerSampleNotSupport     = 'BitsPerSampleNotSupport';
  Err_BufferNotFound              = 'BufferNotFound';
  Err_CantAccessMemory            = 'CantAccessMemory';
  Err_CantActivateContext         = 'CantActivateContext';
  Err_CantAllocGLMemory           = 'CantAllocGLMemory';
  Err_CantAllocMemory             = 'CantAllocMemory';
  Err_CantEnableDebug             = 'CantEnableDebug';
  Err_CantChangeDrawControl       = 'CantChangeDrawControl';
  Err_CantChangePriority          = 'CantChangePriority';
  Err_CantCreateBitmapFromIStream = 'CantCreateBitmapFromIStream';
  Err_CantCreateContext           = 'CantCreateContext';
  Err_CantCreateDirectory         = 'CantCreateDirectory';
  Err_CantCreateFile              = 'CantCreateFile';
  Err_CantCreateFontFromMemory    = 'CantCreateFontFromMemory';
  Err_CantCreateGLFont            = 'CantCreateGLFont';
  Err_CantCreateIStream           = 'CantCreateIStream';
  Err_CantCreateScreenShot        = 'CantCreateScreenShot';
  Err_CantCreateSource            = 'CantCreateSource';
  Err_CantCreateWindow            = 'CantCreateWindow';
  Err_CantCreateWindowsFont       = 'CantCreateWindowsFont';
  Err_CantDeleteFile              = 'CantDeleteFile';
  Err_CantFlushFile               = 'CantFlushFile';
  Err_CantGetBitmapData           = 'CantGetBitmapData';
  Err_CantGetDeviceInfo           = 'CantGetDeviceInfo';
  Err_CantGetHeight               = 'CantGetHeight';
  Err_CantGetWidth                = 'CantGetWidth';
  Err_CantLoadAppCursor           = 'CantLoadAppCursor';
  Err_CantLoadAppIcon             = 'CantLoadAppIcon';
  Err_CantLoadBitmap              = 'CantLoadBitmap';
  Err_CantLoadFromHinstance       = 'CantLoadFromHinstance';
  Err_CantLoadFromStream          = 'CantLoadFromStream';
  Err_CantLoadLanguage            = 'CantLoadLanguage';
  Err_CantLoadOpenALLib           = 'CantLoadOpenALLib';
  Err_CantLoadOpenGLLib           = 'CantLoadOpenGLLib';
  Err_CantLoadPackFile            = 'CantLoadPackFile';
  Err_CantLoadParameters          = 'CantLoadParameters';
  Err_CantLockMemory              = 'CantLockMemory';
  Err_CantOpenDevice              = 'CantOpenDevice';
  Err_CantOpenFile                = 'CantOpenFile';
  Err_CantReadBuffer              = 'CantReadBuffer';
  Err_CantReadData                = 'CantReadData';
  Err_CantReadPriority            = 'CantReadPriority';
  Err_CantReallocMemory           = 'CantReallocMemory';
  Err_CantRegisterClass           = 'CantRegisterClass';
  Err_CantRenameFile              = 'CantRenameFile';
  Err_CantSaveParameters          = 'CantSaveParameters';
  Err_CantSelectPixelFormal       = 'CantSelectPixelFormal';
  Err_CantSetFileSize             = 'CantSetFileSize';
  Err_CantSetPixelFormat          = 'CantSetPixelFormat';
  Err_CantStartEvent              = 'CantStartEvent';
  Err_CantUpdateFile              = 'CantUpdateFile';
  Err_CantUpdateFromFile          = 'CantUpdateFromFile';
  Err_CantUpdateInFile            = 'CantUpdateInFile';
  Err_CantWriteBuffer             = 'CantWriteBuffer';
  Err_ChannelNumberNotSupport     = 'ChannelNumberNotSupport';
  Err_CommandError                = 'CommandError';
  Err_CommandExist                = 'CommandExist';
  Err_CommandNotFound             = 'CommandNotFound';
  Err_DeviceNotAttach             = 'DeviceNotAttach';
  Err_DuplicateName               = 'DuplicateName';
  Err_DuplicateResource           = 'DuplicateResource';
  Err_EmptyPointer                = 'EmptyPointer';
  Err_FileNotFound                = 'FileNotFound';
  Err_FileReadError               = 'FileReadError';
  Err_FileWriteError              = 'FileWriteError';
  Err_FontNotFound                = 'FontNotFound';
  Err_FramesNotFound              = 'FramesNotFound';
  Err_IndexOutOfBounds            = 'IndexOutOfBounds';
  Err_IndexOutsideTheData         = 'IndexOutsideTheData';
  Err_KeyNameNotFound             = 'KeyNameNotFound';
  Err_LoadResourceError           = 'LoadResourceError';
  Err_LoadResourceTableError      = 'LoadResourceTableError';
  Err_MissingContext              = 'MissingContext';
  Err_NameNotFound                = 'NameNotFound';
  Err_NoPartsToLoad               = 'NoPartsToLoad';
  Err_NotEnoughParameters         = 'NotEnoughParameters';
  Err_ObjectIsEmpty               = 'ObjectIsEmpty';
  Err_OutOfMemory                 = 'OutOfMemory';
  Err_ParameterNotFound           = 'ParameterNotFound';
  Err_ParametersNotFound          = 'ParametersNotFound';
  Err_ReachedBufferLimit          = 'ReachedBufferLimit';
  Err_ReachedSourceLimit          = 'ReachedSourceLimit';
  Err_ReloadMethodDoesNotExist    = 'ReloadMethodDoesNotExist';
  Err_ResourceExist               = 'ResourceExist';
  Err_ResourceNotFound            = 'ResourceNotFound';
  Err_SoundNotInitialized         = 'SoundNotInitialized';
  Err_SpriteIsEmpty               = 'SpriteIsEmpty';
  Err_SpriteNotFound              = 'SpriteNotFound';
  Err_TaskExist                   = 'TaskExist';
  Err_UnableToDetermineColumn     = 'UnableToDetermineColumn';
  Err_UnableToDetermineMode       = 'UnableToDetermineMode';
  Err_UnableToDetermineRow        = 'UnableToDetermineRow';
  Err_UnableToDetermineTime       = 'UnableToDetermineTime';
  Err_UnableToDetermineValue      = 'UnableToDetermineValue';
  Err_UnexpectedError             = 'UnexpectedError';
  Err_UnknownCommand              = 'UnknownCommand';
  Err_UnknownResource             = 'UnknownResource';
  Err_UnsupportedFormat           = 'UnsupportedFormat';
  Err_VerticalSyncNotSupported    = 'VerticalSyncNotSupported';
  Err_WindowNotInitialized        = 'WindowNotInitialized';
  Err_WrongDataFormat             = 'WrongDataFormat';
  Err_WrongFileHeader             = 'WrongFileHeader';
  Err_WrongWAVEHeader             = 'WrongWAVEHeader';



implementation

end.

