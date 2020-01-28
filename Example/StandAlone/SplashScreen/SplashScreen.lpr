program SplashScreen;

{$mode objfpc}{$H+}

uses
  Interfaces,
  sgeSplashScreen,
  Forms, SysUtils, MainUnit;


{$R *.res}


var
  SS: TsgeSplashScreen;


begin
  SS := TsgeSplashScreen.Create('Logo.bmp', lbfFile);
  SS.Show;


  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);

  Sleep(3000);
  SS.Free;

  Application.Run;
end.

