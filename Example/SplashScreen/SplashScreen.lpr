program SplashScreen;

{$mode objfpc}{$H+}

uses
  Interfaces,
  Forms, SysUtils, MainUnit,  sgeSplashScreen;


{$R *.res}


var
  SS: TsgeSplashScreen;


begin
  SS := TsgeSplashScreen.Create('Logo.bmp', lbfFile);
  SS.Show;


  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);

  Sleep(3000);
  SS.Free;

  Application.Run;
end.

