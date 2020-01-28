unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  sgeStartParameterList;


type
  TMainFrm = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure ShowParameters;
  public

  end;


var
  MainFrm: TMainFrm;
  SP: TsgeStartParameterList;


implementation

{$R *.lfm}


procedure TMainFrm.FormCreate(Sender: TObject);
begin
  SP := TsgeStartParameterList.Create;
  ShowParameters;
end;


procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  SP.Free;
end;


procedure TMainFrm.ShowParameters;
var
  i, c: Integer;
begin
  c := SP.Count - 1;
  for i := 0 to c do
    ListBox1.Items.Add(SP.Parameter[i].Name + '=' + SP.Parameter[i].Value);
end;


end.

