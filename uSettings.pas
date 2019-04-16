unit uSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  TfSettings = class(TForm)
    pnlBtn: TPanel;
    pc: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    pnlView: TPanel;
    pnlFiles: TPanel;
    btnSave: TBitBtn;
    btnClose: TBitBtn;
    pnlTab1: TPanel;
    pnlTab2: TPanel;
    pnlTab3: TPanel;
    pnlTab4: TPanel;
    pnlTab5: TPanel;
    pnlTab6: TPanel;
    ts3: TTabSheet;
    Panel7: TPanel;
    mmLog: TMemo;
    lbFiles: TListBox;
    Splitter1: TSplitter;
    Label1: TLabel;
    edtFileName: TEdit;
    btnAddFile: TBitBtn;
    btnDeleteFile: TBitBtn;
    gbTab1: TGroupBox;
    edtTabName1: TEdit;
    clr: TColorDialog;
    Label2: TLabel;
    pnlColorTab1: TPanel;
    gbTab2: TGroupBox;
    Label3: TLabel;
    edtTabName2: TEdit;
    pnlColorTab2: TPanel;
    gbTab3: TGroupBox;
    Label4: TLabel;
    edtTabName3: TEdit;
    pnlColorTab3: TPanel;
    gbTab4: TGroupBox;
    Label5: TLabel;
    edtTabName4: TEdit;
    pnlColorTab4: TPanel;
    gbTab5: TGroupBox;
    Label6: TLabel;
    edtTabName5: TEdit;
    pnlColorTab5: TPanel;
    gbTab6: TGroupBox;
    Label7: TLabel;
    edtTabName6: TEdit;
    pnlColorTab6: TPanel;
    procedure btnSaveClick(Sender: TObject);
    procedure btnAddFileClick(Sender: TObject);
    procedure btnDeleteFileClick(Sender: TObject);
    procedure pnlColorTabClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSettings: TfSettings;

implementation

{$R *.dfm}
uses
  uMain;

procedure TfSettings.btnAddFileClick(Sender: TObject);
begin
  lbFiles.Items.Add(edtFileName.Text);
end;

procedure TfSettings.btnDeleteFileClick(Sender: TObject);
begin
  lbFiles.Items.Delete(lbFiles.ItemIndex);
end;

procedure TfSettings.btnSaveClick(Sender: TObject);
var
  TabNames, TabColors: string;
  i: integer;
begin
  for I := 1 to 6 do
  begin
    if i<>6 then
      TabNames:=TabNames+'"'+(FindComponent('edtTabName'+IntToStr(i)) as TEdit).Text+'",'
    else
      TabNames:=TabNames+'"'+(FindComponent('edtTabName'+IntToStr(i)) as TEdit).Text+'"';

    if i<>6 then
      TabColors:=TabColors+ColorToString((FindComponent('pnlColorTab'+IntToStr(i)) as TPanel).Color)+','
    else
      TabColors:=TabColors+ColorToString((FindComponent('pnlColorTab'+IntToStr(i)) as TPanel).Color);
  end;
  fMain.ParamLoadFromSettings(TabNames,TabColors,lbFiles.Items.CommaText);
  ModalResult:=mrOk;
end;

procedure TfSettings.FormShow(Sender: TObject);
var
  i: integer;
  TabNames, TabColors, FileNames, path: string;
  TabNameList, TabColorList: TStringList;
begin
  fMain.ParamToSettings(TabNames,TabColors,FileNames);
  TabNameList:=TStringList.Create;
  TabColorList:=TstringList.Create;
  try
    TabNameList.CommaText:=TabNames;
    TabColorList.CommaText:=TabColors;
    for I := 0 to 5 do
    begin
      (FindComponent('edtTabName'+IntToStr(i+1)) as TEdit).Text:=TabNameList.Strings[i];
      (FindComponent('pnlColorTab'+IntToStr(i+1)) as TPanel).Color:=StringToColor(TabColorList.Strings[i]);
    end;
    lbFiles.Clear;
    lbFiles.Items.CommaText:=FileNames;
  finally
    TabNameList.Free;
    TabColorList.Free;
  end;

  mmLog.Clear;
  path:=ExtractFilePath(Application.Exename) + 'log.txt';
  if FileExists(path) then
    mmLog.Lines.LoadFromFile(path)
  else
    mmLog.Lines.Add('Нет истории операций');

  pc.TabIndex:=0;
end;

procedure TfSettings.pnlColorTabClick(Sender: TObject);
begin
  clr.Color:=(Sender as TPanel).Color;
  if clr.Execute then (Sender as TPanel).Color:=clr.Color;
end;

end.
