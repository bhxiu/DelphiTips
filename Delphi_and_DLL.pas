// Here is an example shows how to load DLL and how parameter (personID in this case) works

// Interface file

unit uDBViewIntf;

interface
uses
  System.SysUtils,
  System.Classes,
  Controls,
  Windows,
  Forms;


type
    TFuncOfNotification = reference to procedure(x: Integer);

    // DLL procedures and funcs
        TCreateViewForm         = procedure ( pn: HWND; AID:integer);
        TResizeViewForm         = procedure ( AWidth, AHeight:integer );
        TDestroyViewForm        = procedure;
    // DLL procedures and funcs

    IDBView = interface
        ['{4118F397-C902-4803-9DD8-4B06581F1033}']
    end;

implementation

end.

// Main file 
unit frmMain;

interface

uses
  ShareMem, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.ComCtrls, uDBViewIntf;

type

  TDBViewDLL =  class (TInterfacedObject, IDBView)
        CreateViewForm : TCreateViewForm;
        ResizeViewForm : TResizeViewForm;
        DestroyViewForm: TDestroyViewForm;

        IsInitialized : boolean;
  end;

  TfrmMainForm = class(TForm)
    // ...
    // omitted
    // ...
  private
    { Private declarations }
    FDBView: TDBViewDLL;
    FCtrlID: integer;
    FhndDLLHandle:  THandle;
    // ...
    // omitted
    // ...
  end;

var
  frmMainForm: TfrmMainForm;
implementation

{$R *.dfm}

procedure TfrmMainForm.pnlDBViewResize(Sender: TObject);
begin
    if FDBView.IsInitialized then
    begin
        FDBView.ResizeViewForm( (Sender as Tpanel).Width,(Sender as Tpanel).Height);
    end;
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
var
    externalDLL: string;
begin

    FDBView := TDBViewDLL.Create;
    FDBView.IsInitialized := false;
    FCtrlID := -1;

    externalDLL := ... // get dll name from config.xml file

    try
        FhndDLLHandle := loadLibrary ( PWideChar(externalDLL) );
        if (FhndDLLHandle > 0)  then
        begin
            @FDBView.CreateViewForm := getProcAddress(fhndDLLHandle,  'CreateViewForm');
            @FDBView.ResizeViewForm := getProcAddress(fhndDLLHandle,  'ResizeViewForm');
            @FDBView.DestroyViewForm:= getProcAddress(fhndDLLHandle,  'DestroyViewForm');

            if      (addr(@FDBView.CreateViewForm) = nil )
               or   (addr(@FDBView.ResizeViewForm) = nil )
               or   (addr(@FDBView.DestroyViewForm) = nil)
            then
            begin
                logger.Log('External DLL error. ( ' + externalDLL + ' )');
                raise Exception.Create('External DLL error. ( ' + externalDLL + ' )');
            end;
        end;

    finally
    end;
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
    logger.Log('Application exit', c_LogWarning);

    if FDBView.IsInitialized then
    begin
        FDBView.DestroyViewForm;

        @FDBView.CreateViewForm := nil;
        @FDBView.ResizeViewForm := nil;
        @FDBView.DestroyViewForm:= nil;
    end;

    FDBView.Free;

    if FhndDLLHandle > 0 then
    begin
        freeLibrary( fhndDLLHandle );
        FhndDLLHandle := 0;
    end;

end;
end.

// DLL project file

library NTLdrView;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  System.SysUtils,
  System.Classes,
  Controls,
  Windows,
  Forms,
  uDBViewIntf in 'Intf\uDBViewIntf.pas';

{$R *.res}


procedure DestroyViewForm;
begin
    FreeAndNil(dmLoader);

    frmLoaderview.close;
    FreeAndNil(frmLoaderview);
end;

procedure CreateViewForm( pn: HWND; AID:integer );
begin
    Application.CreateForm(TdmLoader, dmLoader);

    frmLoaderView := TfrmLoaderView.CreateParented(pn);
    frmLoaderView.PersonID := AID;
    frmLoaderView.BorderStyle := bsNone;
    frmLoaderView.Show;
end;

procedure ResizeViewForm( AWidth, AHeight:integer );
begin
    frmLoaderView.Height := AHeight;
    frmLoaderView.Width  := AWidth;
end;

exports
    CreateViewForm,
    ResizeViewForm,
    DestroyViewForm;

begin
end.

// main file of dll
unit uLoaderView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, uDBViewIntf,
  Data.DB, Vcl.DBCtrls;

type
  TfrmLoaderView = class(TForm)
    pnlViewMain: TPanel;
    DataSource1: TDataSource;
    DBText1: TDBText;
    DBText2: TDBText;
    DBText3: TDBText;
    DBText4: TDBText;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FPersonID : integer;
  public
    { Public declarations }
    property PersonID: integer read FPersonID write FPersonID;
  end;

var
  frmLoaderView: TfrmLoaderView;

implementation

{$R *.dfm}

procedure TfrmLoaderView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := cafree;
end;

procedure TfrmLoaderView.FormShow(Sender: TObject);
begin
    // ...
    // ...

    dmloader.APersonQryByPersonID.Close;
    datasource1.DataSet := dmloader.APersonQryByPersonID;
    dmloader.APersonQryByPersonID.ParamByName('person_id').AsInteger := FPersonID;
    dmloader.APersonQryByPersonID.Open;
    // ...
    
end;

end.