unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.DBCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Buttons, IniFiles, System.ImageList, Vcl.ImgList, StrUtils,
  Vcl.Grids, Vcl.ValEdit, Vcl.CheckLst, uViewFrame, System.UITypes;

Const
  PreColor : array [0..5] of String = ('186,243,0','120,231,0','0,185,69','0,153,153','102,163,210','226,102,183');
  //Предустановленные цвета ['00F3BA', '00E778', '45B900', '999900', 'D2A366', 'B766E2'];

type
  TTab = record                          //Тип описания вкладов
    Index:  integer;                     //Индекс
    Name: string;                        //Название
    Color:  TColor;                      //Цвет
  end;
  TParam = record
    Tabs: array [0..5] of TTab;          //Описание вкладок
    FileNames:  string;                  //Список файлов для сохранения
    PnlLeftW: array [0..5] of integer;   //Ширина основной левой панели
    PnlField1H: array [0..5] of integer; //Высота панели с полем 1
    PnlField2H: array [0..5] of integer; //Высота панели с полем 2
    PnlBtnResW: array [0..5] of integer; //Ширина панели со списком выбора файлов
    redtField1: array [0..5] of integer; //Размер шрифта поля 1 на вкладках
    redtField2: array [0..5] of integer; //Размер шрифта поля 2 на вкладках
    redtField3: array [0..5] of integer; //Размер шрифта поля 3 на вкладках
    redtResult: array [0..5] of integer; //Размер шрифта результатного поля на вкладках
    ClientW: integer;                    //Ширина клиентской области главной формы
    ClientH: integer;                    //Высота клиентской области главной формы
  end;
  TfMain = class(TForm)
    pc: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    pnlTop: TPanel;
    Panel1: TPanel;
    btnSearch: TButton;
    edtSearch: TEdit;
    ts4: TTabSheet;
    ts5: TTabSheet;
    ts6: TTabSheet;
    btnMinimaze: TBitBtn;
    btnClose: TBitBtn;
    Splitter1: TSplitter;
    btnSettings: TBitBtn;
    pnlLeft: TPanel;
    btnTab0: TBitBtn;
    btnTab1: TBitBtn;
    btnTab2: TBitBtn;
    btnTab3: TBitBtn;
    btnTab4: TBitBtn;
    btnTab5: TBitBtn;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    btnMaximaze: TBitBtn;
    fViewMain1: TfViewMain;
    fViewMain2: TfViewMain;
    fViewMain3: TfViewMain;
    fViewMain4: TfViewMain;
    fViewMain5: TfViewMain;
    fViewMain6: TfViewMain;
    procedure pcDrawTab(Control: TCustomTabControl; TabIndex: Integer;
      const Rect: TRect; Active: Boolean);
    procedure btnSearchClick(Sender: TObject);
    procedure pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnMinimazeClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnTabClick(Sender: TObject);
    procedure btnMaximazeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    param: TParam;
    procedure WMNCHitTest(var Msg: TWMNCHitTest) ; message WM_NCHitTest;
    procedure ParamLoadFromFile(path: string);
    procedure ParamSaveToFile(path: string);
    procedure ViewLoadFromParam;
    procedure SizeLoadFromParam;
    procedure SizeLoadToParam;
  public
    procedure ParamLoadFromSettings(TabNames: String; TabColor: string; FileNames: string);
    procedure ParamToSettings(var TabNames: String; var TabColors: string; var FileNames: string);
  end;

var
  fMain: TfMain;
  function SearchText(RichEdit: TRichEdit; SearchText: string; clr: TColor): Boolean;

implementation

{$R *.dfm}
uses
  uSettings;

procedure TfMain.WMNCHitTest(var Msg: TWMNCHitTest) ;
begin
  inherited;
  if Msg.Result = htClient then Msg.Result := htCaption;
end;

function SearchText(RichEdit: TRichEdit; SearchText: string; clr: TColor): Boolean;
var
  StartPos, Position, Endpos: Integer;
begin
  StartPos := 0;
  with RichEdit do
  begin
    if SearchText<>'' then
    begin
      Endpos := Length(RichEdit.Text);
      Lines.BeginUpdate;
      while FindText(SearchText, StartPos, Endpos, [])<>-1 do
      begin
        Endpos   := Length(RichEdit.Text) - startpos;
        Position := FindText(SearchText, StartPos, Endpos, []);
        Inc(StartPos, Length(SearchText));
        SelStart  := Position;
        SelLength := Length(SearchText);
        SelAttributes.Color:=clr;
      end;
      Lines.EndUpdate;
    end
    else
    begin
      SelStart  := StartPos;
      SelLength := Length(RichEdit.Text);
      SelAttributes.Color:=clr;
    end;
  end;
end;


//
procedure TfMain.btnCloseClick(Sender: TObject);
begin
  if MessageDlg('Exit?', mtCustom, mbOKCancel, 0)=mrOk then Application.Terminate;
end;

procedure TfMain.btnMaximazeClick(Sender: TObject);
var
  rWorkArea: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @rWorkArea, 0);
  fMain.WindowState:=wsMaximized;
  fMain.Height:=rWorkArea.Bottom;
end;

procedure TfMain.btnMinimazeClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TfMain.btnSearchClick(Sender: TObject);
var
  componentID: integer;
  clr:  TColor;
begin
  if (edtSearch.Text='') and (btnSearch.Caption='Поиск') then exit;

  if btnSearch.Caption='Поиск' then
  begin
    btnSearch.Caption:='Отмена';
    clr:=clRed;
  end
  else
  begin
    btnSearch.Caption:='Поиск';
    edtSearch.Text:='';
    clr:=clBlack;
  end;

  for componentID := 0 to self.ComponentCount-1 do
    if self.Components[componentID] is TRichEdit then
      SearchText((self.Components[componentID] as TRichEdit),edtSearch.Text, clr);
end;

procedure TfMain.btnSettingsClick(Sender: TObject);
var
  frm: TfSettings;
begin
  Application.CreateForm(TfSettings,frm);
  frm.ShowModal;
  if frm.ModalResult=mrOk then
  begin
    ParamSaveToFile(ExtractFilePath(Application.Exename) + 'settings.ini');
    ViewLoadFromParam;
    pc.Hide;
    pc.Show;
  end;
  frm.Free;
end;

procedure TfMain.btnTabClick(Sender: TObject);
begin
  pc.TabIndex:=(Sender as TBitBtn).Tag;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  ParamLoadFromFile(ExtractFilePath(Application.Exename) + 'settings.ini');
  ViewLoadFromParam;
  pc.TabIndex:=0;
  fMain.Left:=Screen.WorkAreaRect.Left;
  fMain.Top:=Screen.WorkAreaRect.Top;
  fMain.Width:=Screen.WorkAreaRect.Width;
  fMain.Height:=Screen.WorkAreaRect.Height;
  SizeLoadFromParam;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  SizeLoadToParam;
  ParamSaveToFile(ExtractFilePath(Application.Exename) + 'settings.ini');
end;

procedure TfMain.pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(fMain.Handle, WM_SYSCOMMAND, 61458, 0) ;
end;

procedure TfMain.pcDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  lTabSheet: TTabSheet;
  lPageControl: TPageControl;
  lText: String;
  lPoint: TPoint;
begin
  lPageControl := (Control as TPageControl);
  lTabSheet := lPageControl.Pages[TabIndex];
  if Assigned(lTabSheet) and (lTabSheet <> nil) then
  begin
    Control.Canvas.Brush.Color := param.Tabs[TabIndex].Color;
    with Control.Canvas do
    begin
      lText := lTabSheet.Caption;
      lPoint.X := (Rect.Right - Rect.Left) div 2 - TextWidth(lText)  div 2;
      lPoint.Y := (Rect.Bottom - Rect.Top) div 2 - TextHeight(lText) div 2;
      TextRect(Rect, Rect.Left + lPoint.X, Rect.Top + lPoint.Y, lText);
    end;
  end;
end;

procedure TfMain.ParamLoadFromFile(path: string);
var
  i:  integer;
  clr, TabNameList, TabColorList: TStringList;
  flIni:  TIniFile;
  NameStr,ColorStr: string;

begin
  clr:=TStringList.Create;
  TabNameList:=TStringList.Create;
  TabColorList:=TstringList.Create;

  for i := 0 to 5 do
  begin
    param.Tabs[i].Index:=i;
    param.Tabs[i].Name:='Tab '+IntToStr(i+1);
    clr.CommaText:=PreColor[i];
    param.Tabs[i].Color:=RGB(StrToInt(clr.Strings[0]),StrToInt(clr.Strings[1]),StrToInt(clr.Strings[2]));
    if i<>5 then
    begin
      NameStr:=NameStr+'"'+param.Tabs[i].Name+'",';
      ColorStr:=ColorStr+ColorToString(param.Tabs[i].Color)+',';
    end
    else
    begin
      NameStr:=NameStr+'"'+param.Tabs[i].Name+'"';
      ColorStr:=ColorStr+ColorToString(param.Tabs[i].Color);
    end;
  end;

  if FileExists(path) then
  begin
    flIni:=TIniFile.Create(path);
    try
      TabNameList.CommaText:=flIni.ReadString('Tab','TabName',NameStr);
      TabColorList.CommaText:=flIni.ReadString('Tab','TabColor',ColorStr);
      param.ClientW:=flIni.ReadInteger('Size','ClientWidth',0);
      param.ClientH:=flIni.ReadInteger('Size','ClientHeight',0);

      for i := 0 to 5 do
      begin
        param.Tabs[i].Index:=i;
        param.Tabs[i].Name:=TabNameList.Strings[i];
        param.Tabs[i].Color:=StringToColor(TabColorList.Strings[i]);
        param.pnlBtnResW[i]:=flIni.ReadInteger('Size','pnlBtnResW'+IntToStr(i),0);
        param.PnlLeftW[i]:=flIni.ReadInteger('Size','pnlLeftW'+IntToStr(i),0);
        param.PnlField1H[i]:=flIni.ReadInteger('Size','pnlField1H'+IntToStr(i),0);
        param.PnlField2H[i]:=flIni.ReadInteger('Size','pnlField2H'+IntToStr(i),0);
        param.redtField1[i]:=flIni.ReadInteger('SizeFont','redtField1'+IntToStr(i),0);
        param.redtField2[i]:=flIni.ReadInteger('SizeFont','redtField2'+IntToStr(i),0);
        param.redtField3[i]:=flIni.ReadInteger('SizeFont','redtField3'+IntToStr(i),0);
        param.redtResult[i]:=flIni.ReadInteger('SizeFont','redtResult'+IntToStr(i),0);
      end;
      param.FileNames:=flIni.ReadString('NameFiles','CommaText','');

    finally
      flIni.Free;
      clr.Free;
      TabNameList.Free;
      TabColorList.Free;
    end;
  end;
end;

procedure TfMain.ParamSaveToFile(path: string);
var
  i:  integer;
  flIni:  TIniFile;
  TabNameList,TabColorList: TStringList;
begin
  TabNameList:=TStringList.Create;
  TabColorList:=TstringList.Create;

  flIni:=TIniFile.Create(path);
  try
    for i := 0 to 5 do
    begin
      TabNameList.Add(param.Tabs[i].Name);
      TabColorList.Add(ColorToString(param.Tabs[i].Color));
      flIni.WriteInteger('Size','pnlBtnResW'+IntToStr(i),param.pnlBtnResW[i]);
      flIni.WriteInteger('Size','pnlLeftW'+IntToStr(i),param.PnlLeftW[i]);
      flIni.WriteInteger('Size','PnlField1H'+IntToStr(i),param.PnlField1H[i]);
      flIni.WriteInteger('Size','PnlField2H'+IntToStr(i),param.PnlField2H[i]);
      flIni.WriteInteger('SizeFont','redtField1'+IntToStr(i),param.redtField1[i]);
      flIni.WriteInteger('SizeFont','redtField2'+IntToStr(i),param.redtField2[i]);
      flIni.WriteInteger('SizeFont','redtField3'+IntToStr(i),param.redtField3[i]);
      flIni.WriteInteger('SizeFont','redtResult'+IntToStr(i),param.redtResult[i]);
    end;
    flIni.WriteString('Tab','TabName','"'+TabNameList.CommaText+'"');
    flIni.WriteString('Tab','TabColor',TabColorList.CommaText);
    flIni.WriteString('NameFiles','CommaText',param.FileNames);
    flIni.WriteInteger('Size','ClientWidth',param.ClientW);
    flIni.WriteInteger('Size','ClientHeight',param.ClientH);
  finally
    flIni.Free;
    TabNameList.Free;
    TabColorList.Free;
  end;
end;

procedure TfMain.ViewLoadFromParam;
var
  i:  integer;
  cb: TListbox;
begin
  for i := 0 to 5 do
  begin
    pc.Pages[i].Caption:=param.Tabs[i].Name;
    cb:=((fMain.FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('cbFiles') as TListbox);
    cb.Clear;
    cb.Items.CommaText:=param.FileNames;
  end;
  SizeLoadFromParam;
end;

procedure TfMain.ParamLoadFromSettings(TabNames: String; TabColor: string; FileNames: string);
var
  i: integer;
  NameList, ColorList: TStringList;
begin
  NameList:=TStringList.Create;
  ColorList:=TStringList.Create;
  try
    NameList.CommaText:=TabNames;
    ColorList.CommaText:=TabColor;
    for I := 0 to 5 do
    begin
      param.Tabs[i].Index:=i;
      param.Tabs[i].Name:=NameList.Strings[i];
      param.Tabs[i].Color:=StringToColor(ColorList.Strings[i]);
    end;
    Param.FileNames:=FileNames;
  finally
    NameList.Free;
    ColorList.Free;
  end;
end;

procedure TfMain.ParamToSettings(var TabNames: String; var TabColors: string; var FileNames: string);
var
  i: integer;
  NameList, ColorList: TStringList;
begin
  NameList:=TStringList.Create;
  ColorList:=TStringList.Create;
  try
    for I := 0 to 5 do
    begin
      NameList.Add(param.Tabs[i].Name);
      ColorList.Add(ColorToString(param.Tabs[i].Color));
    end;
    TabNames:=NameList.CommaText;
    TabColors:=ColorList.CommaText;
    FileNames:=Param.FileNames;
  finally
    NameList.Free;
    ColorList.Free;
  end;
end;

procedure TfMain.SizeLoadFromParam;
var
  i: integer;
begin
  if (param.ClientW<=fMain.ClientWidth) and (param.ClientH<=fMain.ClientHeight) then
  for i := 0 to 5 do
  begin
    if param.pnlBtnResW[i]<>0 then ((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('pnlBtnRes') as TPanel).Width:=param.pnlBtnResW[i];
    if param.PnlLeftW[i]<>0 then ((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('pnlLeft') as TPanel).Width:=param.PnlLeftW[i];
    if param.PnlField1H[i]<>0 then ((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('PnlField1') as TPanel).Height:=param.PnlField1H[i];
    if param.PnlField2H[i]<>0 then ((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('PnlField2') as TPanel).Height:=param.PnlField2H[i];
  end;
  for i := 0 to 5 do
  begin
    if param.redtField1[i]<>0 then ((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('redtField1') as TRichEdit).Font.Size:=param.redtField1[i];
    if param.redtField2[i]<>0 then ((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('redtField2') as TRichEdit).Font.Size:=param.redtField2[i];
    if param.redtField3[i]<>0 then ((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('redtField3') as TRichEdit).Font.Size:=param.redtField3[i];
    if param.redtResult[i]<>0 then ((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('redtResult') as TRichEdit).Font.Size:=param.redtResult[i];
  end;
end;

procedure TfMain.SizeLoadToParam;
var
  i: integer;
begin
  param.ClientW:=fMain.ClientWidth;
  param.ClientH:=fMain.ClientHeight;
  for i := 0 to 5 do
  begin
    param.redtField1[i]:=((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('redtField1') as TRichEdit).Font.Size;
    param.redtField2[i]:=((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('redtField2') as TRichEdit).Font.Size;
    param.redtField3[i]:=((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('redtField3') as TRichEdit).Font.Size;
    param.redtResult[i]:=((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('redtResult') as TRichEdit).Font.Size;
    param.pnlBtnResW[i]:=((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('pnlBtnRes') as TPanel).Width;
    param.PnlLeftW[i]:=((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('pnlLeft') as TPanel).Width;
    param.PnlField1H[i]:=((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('PnlField1') as TPanel).Height;
    param.PnlField2H[i]:=((FindComponent('fViewMain'+IntToStr(i+1)) as TFrame).FindComponent('PnlField2') as TPanel).Height;
  end;
end;

end.
