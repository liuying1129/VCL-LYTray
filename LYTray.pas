{**********************************************************}
{                                                          }
{  TLYTray Component Version 02.11.1                       }
{  作者:刘鹰                                               }
{                                                          }
{  功能: 自动生成系统托盘图标                              }
{                                                          }
{                                                          }
{  他是一个免费软件,如果你修改了他,希望我能有幸看到你的杰作}
{                                                          }
{  我的 Email: Liuying1129@163.com                         }
{                                                          }
{  版权所有,欲进行商业用途,请与我联系!!!                   }
{                                                          }
{                                                          }
{**********************************************************}


unit LYTray;

interface

uses
  { Controls,  Dialogs,}
  Forms,Windows, SysUtils, Classes, Graphics,menus,SHELLAPI, Messages;

CONST
  IID=10;
  WM_LYTRAY=WM_USER+10;

TYPE  TACTBUTTON = (abRightButton,abLeftButton);

type
  TLYTray = class(TComponent)
  private
    { Private declarations }
    FICON: TICON;
    FHINT: AnsiString;
    FPOPUPMENU:TPOPUPMENU;
    FACTBUTTON:TACTBUTTON;
    FParentWindow:THANDLE;
    FWindowHandle: THANDLE;
    FICONDATA:TNOTIFYICONDATAA;
    PROCEDURE FSETICON(CONST ICON:TICON);
    PROCEDURE FSETHINT(CONST HINT:AnsiString);
    PROCEDURE FSETP0PUPMENU(CONST POPUPMENU:TPOPUPMENU);
    PROCEDURE FILLICONDATA;
    PROCEDURE FSETACTBUTTON(CONST ACTBUTTON:TACTBUTTON);
    PROCEDURE TRAYMSGPRO(VAR Msg:TMESSAGE);MESSAGE WM_LYTRAY;
  protected
    { Protected declarations }
  public
    { Public declarations }
    CONSTRUCTOR CREATE(AOWNER:TCOMPONENT);OVERRIDE;
    DESTRUCTOR DESTROY;OVERRIDE;
  published
    { Published declarations }
    PROPERTY Icon:TICON READ FICON WRITE FSETICON;
    PROPERTY Hint:AnsiString READ FHINT WRITE FSETHINT;
    PROPERTY PopupMenu:TPOPUPMENU READ FPOPUPMENU WRITE FSETP0PUPMENU;
    PROPERTY ActButton:TACTBUTTON READ FACTBUTTON WRITE FSETACTBUTTON;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Eagle_Ly', [TLYTray]);
end;

{ TLYTray }

constructor TLYTray.CREATE(AOWNER: TCOMPONENT);
begin
  inherited CREATE(AOWNER);
  FICON:=TICON.Create;
  FHINT:='';
  FPOPUPMENU:=NIL;
  FACTBUTTON:=abRightButton;
  IF(AOWNER<>NIL)AND(AOWNER IS TFORM)THEN
    FParentWindow:=(AOWNER AS TFORM).HANDLE
  ELSE
    FParentWindow:=0;
  FWindowHandle := AllocateHWnd(TRAYMSGPRO); {调用AllcolateHwnd使之创建隐藏窗口句柄且能捕获WM_LYTRAY消息}
  FILLICONDATA;
  SHELL_NOTIFYICONA(NIM_ADD,@FICONDATA);
end;

destructor TLYTray.DESTROY;
begin
  inherited;
  FILLICONDATA;
  SHELL_NOTIFYICONA(NIM_DELETE,@FICONDATA);
  IF FICON<>NIL THEN FICON.Free;
  DeAllocateHWnd( FWindowHandle );
end;

procedure TLYTray.FILLICONDATA;
begin
  //WITH FICONDATA DO
  //BEGIN
    FICONDATA.CBSIZE:=SIZEOF(TNOTIFYICONDATAA);
    FICONDATA.WND:=FWindowHandle;
    FICONDATA.UID:=IID;
    FICONDATA.uCallbackMessage:=WM_LYTRAY;
    FICONDATA.HICON:=FICON.Handle;
    StrCopy(FIconData.szTip, PAnsiChar(FHint));
    FICONDATA.UFLAGS:=NIF_ICON+NIF_TIP+NIF_MESSAGE;
  //END;
end;

procedure TLYTray.FSETACTBUTTON(const ACTBUTTON: TACTBUTTON);
begin
  IF ACTBUTTON=FACTBUTTON THEN EXIT;
  FACTBUTTON:=ACTBUTTON;
end;

procedure TLYTray.FSETHINT(CONST HINT: AnsiString);
begin
  IF HINT=FHINT THEN EXIT;
  FHINT:=HINT;
  FILLICONDATA;
  SHELL_NOTIFYICONA(NIM_MODIFY,@FICONDATA);
end;

procedure TLYTray.FSETICON(CONST ICON: TICON);
begin
  IF ICON=FICON THEN EXIT;
  FICON.ASSIGN(ICON);
  FILLICONDATA;
  SHELL_NOTIFYICONA(NIM_MODIFY,@FICONDATA);
end;

procedure TLYTray.FSETP0PUPMENU(const POPUPMENU: TPOPUPMENU);
begin
  IF POPUPMENU=FPOPUPMENU THEN EXIT;
  FPOPUPMENU:=POPUPMENU;
  FILLICONDATA;
  SHELL_NOTIFYICONA(NIM_MODIFY,@FICONDATA);
end;

procedure TLYTray.TRAYMSGPRO(var Msg: TMESSAGE);
var mypt:tpoint;
begin
  inherited;
  getcursorpos(mypt);
  IF FACTBUTTON=abRightButton THEN
  BEGIN
    if Msg.lparam=WM_RBUTTONDOWN then
    begin
      SetForegroundWindow(FParentWindow);
      FPOPUPMENU.popup(mypt.x,mypt.y);
    end;
  END;
  IF FACTBUTTON=abLeftButton THEN
  BEGIN
    if Msg.lparam=WM_LBUTTONDOWN then
    begin
      SetForegroundWindow(FParentWindow);
      FPOPUPMENU.popup(mypt.x,mypt.y);
    end;
  END;
  Msg.Result:=0;
end;

end.
