{
Пакет             Simple Game Engine 1
Файл              sgeTypes.pas
Версия            1.8
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
  SGE_Version = '1.18';



  //Ошибки
  Err_Separator = ';';
  Err_StrSeparator = #13#10;


  Err_sgeWindow = 'sgeWindow';                            //Класс окна
  Err_sgeWindow_CantRegisterClass = '1';
  Err_sgeWindow_CantCreateWindow  = '2';


  Err_sgeJournal = 'sgeJournal';                          //Класс журнала
  Err_sgeJournal_CantOpenFile = '1';


  Err_sgeGraphic = 'sgeGraphic';                          //Класс графики
  Err_sgeGraphic_CantLoadOpenGLLib      = '1';
  Err_sgeGraphic_CantSelectPixelFormat  = '2';
  Err_sgeGraphic_CantSetPixelFormat     = '3';
  Err_sgeGraphic_CantCreateContex       = '4';
  Err_sgeGraphic_CantActivateContext    = '5';
  Err_sgeGraphic_VerticalSyncNotSupport = '6';
  Err_sgeGraphic_CantCreateScreenShot   = '7';


  Err_sgeGraphicFont = 'sgeGraphicFont';                  //Шрифт OpenGL
  Err_sgeGraphicFont_OpenGLNotInitialize  = '1';
  Err_sgeGraphicFont_CantCreateWinFont    = '2';
  Err_sgeGraphicFont_CantAllocGLMemory    = '3';
  Err_sgeGraphicFont_CantCreateGLFont     = '4';


  Err_sgeGraphicSprite = 'sgeGraphicSprite';              //Спрайт
  Err_sgeGraphicSprite_GraphicNotInitialized  = '1';
  Err_sgeGraphicSprite_CantLoadFromFile       = '2';
  Err_sgeGraphicSprite_CantLoadFromScanLine   = '3';
  Err_sgeGraphicSprite_ImageIsEmpty           = '4';
  Err_sgeGraphicSprite_CantGetWidth           = '5';
  Err_sgeGraphicSprite_CantGetHeight          = '6';
  Err_sgeGraphicSprite_CantAccessMemory       = '7';


  Err_sgeSystemFont = 'sgeSystemFont';                    //Системный шрифт
  Err_sgeSystemFont_CantAddFontToSystem = '1';


  Err_sgeSystemIcon = 'sgeSystemIcon';                    //Системный значёк
  Err_sgeSystemIcon_CantLoadIconFromFile      = '1';
  Err_sgeSystemIcon_CantLoadIconFromHinstance = '2';


  Err_sgeSystemCursor = 'sgeSystemCursor';                //Системный курсор
  Err_sgeSystemCursor_CantLoadCursorFromFile      = '1';
  Err_sgeSystemCursor_CantLoadCursorFromHinstance = '2';


  Err_sgeStartParameters = 'sgeStartParameters';          //Стартовые параметры
  Err_sgeStartParameters_ParameterNotFound  = '1';
  Err_sgeStartParameters_IndexOutOfBounds   = '2';


  Err_sgeParameters = 'sgeParameters';                    //Параметры
  Err_sgeParameters_IndexOutOfBounds    = '1';
  Err_sgeParameters_ParameterNotFound   = '2';
  Err_sgeParameters_CantSaveToFile      = '3';
  Err_sgeParameters_CantLoadFromFile    = '4';
  Err_sgeParameters_CantUpdateInFile    = '5';
  Err_sgeParameters_CantUpdateFromFile  = '6';


  Err_sgeResources = 'sgeResources';                      //Хранилище ресурсов
  Err_sgeResources_IndexOutOfBounds       = '1';
  Err_sgeResources_ResourceNotFound       = '2';
  Err_sgeResources_TypedResourceNotFound  = '3';


  Err_sgeEvent = 'sgeEvent';                              //Событие
  Err_sgeEvent_CantStartEvent = '1';


  Err_sgeSound = 'sgeSound';                              //Звук
  Err_sgeSound_CantLoadOpenALLib    = '1';
  Err_sgeSound_CantOpenDevice       = '2';
  Err_sgeSound_CantCreateContext    = '3';
  Err_sgeSound_CantActivateContext  = '4';
  Err_sgeSound_CantCreateSource     = '5';


  Err_sgeSoundBuffer = 'sgeSoundBuffer';                  //Набор данных PCM
  Err_sgeSoundBuffer_SoundNotInitialized                     = '1';
  Err_sgeSoundBuffer_ReachedTheLimitOfBuffers                = '2';
  Err_sgeSoundBuffer_OutOfMemory                             = '3';
  Err_sgeSoundBuffer_CantLoadFromFile                        = '4';
  Err_sgeSoundBuffer_TheSizeDoesNotMatchTheDataOrBufferInUse = '5';
  Err_sgeSoundBuffer_UnsupportedFormat                       = '6';


  Err_sgeSoundSource = 'sgeSoundSource';                  //Источник звука
  Err_sgeSoundSource_SoundNotInitialized                  = '1';
  Err_sgeSoundSource_ReachedTheLimitOfSources             = '2';
  Err_sgeSoundSource_OutOfMemory                          = '3';
  Err_sgeSoundSource_ThereIsNoContextForCreatingTheSource = '4';


  Err_sgeGraphicFrames = 'sgeGraphicFrames';              //Кадры анимации
  Err_sgeGraphicFrames_IndexOutOfBounds        = '1';
  Err_sgeGraphicFrames_NoPartsToLoad           = '2';
  Err_sgeGraphicFrames_WrongFrameFormat        = '3';
  Err_sgeGraphicFrames_SpriteNotFound          = '4';
  Err_sgeGraphicFrames_UnableToDetermineColumn = '5';
  Err_sgeGraphicFrames_UnableToDetermineRow    = '6';
  Err_sgeGraphicFrames_UnableToDetermineTime   = '7';
  Err_sgeGraphicFrames_UnableLoadFromFile      = '8';
  Err_sgeGraphicFrames_UnableSaveToFile        = '9';


  Err_sgeGraphicAnimation = 'sgeGraphicAnimation';        //Анимация
  Err_sgeGraphicAnimation_IndexOutOfBounds = '1';


  Err_sgeCommandHistory = 'sgeCommandHistory';            //История команд
  Err_sgeCommandHistory_CantSaveToFile   = '1';
  Err_sgeCommandHistory_CantLoadFromFile = '2';


  Err_sgeColoredLines = 'sgeColoredLines';                //Массив цветных линий
  Err_sgeColoredLines_IndexOutOfBounds = '1';
  Err_sgeColoredLines_CantSaveToFile   = '2';


  Err_sgeShellCommands = 'sgeShellCommands';              //Команды оболочки
  Err_sgeShellCommands_IndexOutOfBounds = '1';
  Err_sgeShellCommands_CommandExist     = '2';


  Err_sgeShell = 'sgeShell';                              //Оболочка
  Err_sgeShell_FileNotExist     = '1';
  Err_sgeShell_ErrorLoadingFile = '2';


  Err_sgeKeyTable = 'sgeKeyTable';                        //Таблица команд на кнопках
  Err_sgeKeyTable_KeyNotFound = '1';


  Err_sgeJoystick = 'sgeJoystick';                        //Класс джойстика
  Err_sgeJoystick_NotAttach        = '1';
  Err_sgeJoystick_CantGetInfo      = '2';
  Err_sgeJoystick_IndexOutOfBounds = '3';
  Err_sgeJoystick_CantReadPosition = '4';


  Err_sgeJoysticks = 'sgeJoysticks';                      //Класс хранилища подключённых джойстиков
  Err_sgeJoysticks_IndexOutOfBounds = '1';


  Err_sgeSplashScreen = 'sgeSplashScreen';                //Форма-заставка
  Err_sgeSplashScreen_CantloadBitmap    = '1';
  Err_sgeSplashScreen_CantGetBitmapSize = '2';
  Err_sgeSplashScreen_CantCreateWindow  = '3';


  Err_SGE = 'SGE';                                        //Главный класс

  Err_SGE_SetPriority_CantChangePriority          = '1';

  Err_SGE_GetPriority_CantReadPriority            = '2';

  Err_SGE_SetDebug_CantStartJournal               = '3';

  Err_SGE_LoadParameters_CantLoadFromFile         = '4';

  Err_SGE_SaveParameters_CantSaveToFile           = '5';

  Err_SGE_LoadLanguage_CantLoadLanguage           = '6';

  Err_SGE_InitWindow_CantInitWindow               = '7';

  Err_SGE_InitGraphic_CantInitGraphic             = '8';

  Err_SGE_InitSound_CantInitSound                 = '9';

  Err_SGE_SetDrawControl_CantChangeVertSync       = '10';

  Err_SGE_LoadAppIcon_WindowNotInitialized        = '11';
  Err_SGE_LoadAppIcon_CantLoadFromHinstance       = '12';
  Err_SGE_LoadAppIcon_CantLoadFromResource        = '13';
  Err_SGE_LoadAppIcon_CantLoadFromFile            = '14';

  Err_SGE_LoadAppCursor_WindowNotInitialized      = '15';
  Err_SGE_LoadAppCursor_CantLoadFromHinstance     = '16';
  Err_SGE_LoadAppCursor_CantLoadFromResource      = '17';
  Err_SGE_LoadAppCursor_CantLoadFromFile          = '18';

  Err_SGE_LoadResource_FileNotFound               = '19';
  Err_SGE_LoadResource_ReadError                  = '20';
  Err_SGE_LoadResource_CantBeDetermined           = '21';
  Err_SGE_LoadResource_DuplicateResource          = '22';
  Err_SGE_LoadResource_SystemIconNotLoaded        = '23';
  Err_SGE_LoadResource_SystemCursorNotLoaded      = '24';
  Err_SGE_LoadResource_SystemFontNotLoaded        = '25';
  Err_SGE_LoadResource_GraphicSpriteNotLoaded     = '26';
  Err_SGE_LoadResource_GraphicFontNotLoaded       = '27';
  Err_SGE_LoadResource_SoundBufferNotLoaded       = '28';
  Err_SGE_LoadResource_GraphicFramesNotLoaded     = '29';
  Err_SGE_LoadResource_ParametersNotLoaded        = '30';

  Err_SGE_Screenshot_GraphicNotInitialized        = '31';
  Err_SGE_Screenshot_SaveError                    = '32';

  Err_SGE_GetGraphicSprite_SpriteNotFound         = '33';

  Err_SGE_GetGraphicFont_FontNotFound             = '34';

  Err_SGE_GetSoundBuffer_BufferNotFound           = '35';

  Err_SGE_GetGraphicFrames_FramesNotFound         = '36';

  Err_SGE_GetParameters_ParametersNotFound        = '37';



  //Названия каталогов
  sge_DirJournal = 'Journals';
  sge_DirShoots  = 'Screenshots';
  sge_DirUser    = 'User';


  //Расширения файлов
  sge_ExtJournal = 'Journal';
  sge_ExtShots   = 'Bmp';


  //Сообщения оболочки
  sge_ShellMessage_CommandNotFound  = 'CmdNotFound';
  sge_ShellMessage_EmptyPointer     = 'EmptyPointer';
  sge_ShellMessage_WrongParamCount  = 'WrongParamCount';
  sge_ShellMessage_CommandError     = 'CommandError';
  sge_ShellMessage_CommandException = 'CommandException';
  sge_ShellMessage_NoData           = 'NoData';
  sge_ShellMessage_HelpHint         = 'HelpHint';


  //Имена парметров
  sge_PrmDebug         = 'Debug';




implementation

end.

