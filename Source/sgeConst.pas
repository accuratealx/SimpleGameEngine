{
Пакет             Simple Game Engine 1
Файл              sgeTypes.pas
Версия            1.9
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
  SGE_Version = '1.19';


  //Названия каталогов
  sge_DirJournal = 'Journals';
  sge_DirShoots  = 'Screenshots';
  sge_DirUser    = 'User';


  //Расширения файлов
  sge_ExtJournal = 'Journal';
  sge_ExtShots   = 'Bmp';


  //Имена парметров
  sge_PrmDebug         = 'Debug';


  //Оболочка
  sge_ShellIndent = 5;


  //Ошибки
  Err_BufferNotFound            = 'BufferNotFound';
  Err_CantAccessMemory          = 'CantAccessMemory';
  Err_CantActivateContext       = 'CantActivateContext';
  Err_CantAddFontToSystem       = 'CantAddFontToSystem';
  Err_CantAllocGLMemory         = 'CantAllocGLMemory';
  Err_CantChangeDebug           = 'CantChangeDebug';
  Err_CantChangeDrawControl     = 'CantChangeDrawControl';
  Err_CantChangePriority        = 'CantChangePriority';
  Err_CantCreateBitmapFromScan  = 'CantCreateBitmapFromScan';
  Err_CantCreateContext         = 'CantCreateContext';
  Err_CantCreateGLFont          = 'CantCreateGLFont';
  Err_CantCreateScreenShot      = 'CantCreateScreenShot';
  Err_CantCreateSource          = 'CantCreateSource';
  Err_CantCreateWindow          = 'CantCreateWindow';
  Err_CantCreateWindowsFont     = 'CantCreateWindowsFont';
  Err_CantGetBitmapData         = 'CantGetBitmapData';
  Err_CantGetDeviceInfo         = 'CantGetDeviceInfo';
  Err_CantGetHeight             = 'CantGetHeight';
  Err_CantGetWidth              = 'CantGetWidth';
  Err_CantInitGraphic           = 'CantInitGraphic';
  Err_CantInitSound             = 'CantInitSound';
  Err_CantInitWindow            = 'CantInitWindow';
  Err_CantLoadAppCursor         = 'CantLoadAppCursor';
  Err_CantLoadAppIcon           = 'CantLoadAppIcon';
  Err_CantLoadFromHinstance     = 'CantLoadFromHinstance';
  Err_CantLoadFromResource      = 'CantLoadFromResource';
  Err_CantLoadLanguage          = 'CantLoadLanguage';
  Err_CantLoadOpenALLib         = 'CantLoadOpenALLib';
  Err_CantLoadOpenGLLib         = 'CantLoadOpenGLLib';
  Err_CantLoadParameters        = 'CantLoadParameters';
  Err_CantOpenDevice            = 'CantOpenDevice';
  Err_CantReadData              = 'CantReadData';
  Err_CantReadPriority          = 'CantReadPriority';
  Err_CantRegisterClass         = 'CantRegisterClass';
  Err_CantSaveParameters        = 'CantSaveParameters';
  Err_CantSelectPixelFormal     = 'CantSelectPixelFormal';
  Err_CantSetPixelFormat        = 'CantSetPixelFormat';
  Err_CantStartEvent            = 'CantStartEvent';
  Err_CantLoadBitmap            = 'CantLoadBitmap';
  Err_CommandError              = 'CommandError';
  Err_CommandExist              = 'CommandExist';
  Err_CommandNotFound           = 'CommandNotFound';
  Err_DeviceNotAttach           = 'DeviceNotAttach';
  Err_DuplicateResource         = 'DuplicateResource';
  Err_EmptyPointer              = 'EmptyPointer';
  Err_FileNotFound              = 'FileNotFound';
  Err_FileReadError             = 'FileReadError';
  Err_FileWriteError            = 'FileWriteError';
  Err_FontNotFound              = 'FontNotFound';
  Err_FramesNotFound            = 'FramesNotFound';
  Err_GraphicNotInitialized     = 'GraphicNotInitialized';
  Err_ImageIsEmpty              = 'ImageIsEmpty';
  Err_IndexOutOfBounds          = 'IndexOutOfBounds';
  Err_KeyNameNotFound           = 'KeyNameNotFound';
  Err_LoadResourceError         = 'LoadResourceError';
  Err_LoadResourceTableError    = 'LoadResourceTableError';
  Err_MissingContext            = 'MissingContext';
  Err_NoPartsToLoad             = 'NoPartsToLoad';
  Err_NotEnoughParameters       = 'NotEnoughParameters';
  Err_OutOfMemory               = 'OutOfMemory';
  Err_ParameterNotFound         = 'ParameterNotFound';
  Err_ParametersNotFound        = 'ParametersNotFound';
  Err_ReachedBufferLimit        = 'ReachedBufferLimit';
  Err_ReachedSourceLimit        = 'ReachedSourceLimit';
  Err_ReloadMethodDoesNotExist  = 'ReloadMethodDoesNotExist';
  Err_ResourceExist             = 'ResourceExist';
  Err_ResourceNotFound          = 'ResourceNotFound';
  Err_SoundNotInitialized       = 'SoundNotInitialized';
  Err_SpriteNotFound            = 'SpriteNotFound';
  Err_UnableToCreateDirectory   = 'UnableToCreateDirectory';
  Err_UnableToDetermineColumn   = 'UnableToDetermineColumn';
  Err_UnableToDetermineMode     = 'UnableToDetermineMode';
  Err_UnableToDetermineRow      = 'UnableToDetermineRow';
  Err_UnableToDetermineTime     = 'UnableToDetermineTime';
  Err_UnableToDetermineValue    = 'UnableToDetermineValue';
  Err_UnexpectedError           = 'UnexpectedError';
  Err_UnknownCommand            = 'UnknownCommand';
  Err_UnknownResource           = 'UnknownResource';
  Err_UnsupportedFormat         = 'UnsupportedFormat';
  Err_VerticalSyncNotSupported  = 'VerticalSyncNotSupported';
  Err_WindowNotInitialized      = 'WindowNotInitialized';
  Err_WrongDataFormat           = 'WrongDataFormat';





implementation

end.

