unit WebModuleU;

interface

uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  MVCFramework;

type
  TMyWebModule = class(TWebModule)
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
  private
    FMVC: TMVCEngine;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TMyWebModule;

implementation

{$R *.dfm}


uses
  System.IOUtils,
  MVCFramework.Commons,
  MVCFramework.Middleware.StaticFiles,
  MVCFramework.Middleware.Compression, RPCClasses.MyObjectU,
  RPCClasses.MyComplexU, RPCClasses.MyObjectsHierarchyU;

procedure TMyWebModule.WebModuleCreate(Sender: TObject);
begin
  FMVC := TMVCEngine.Create(Self,
    procedure(Config: TMVCConfig)
    begin
      // session timeout (0 means session cookie)
      Config[TMVCConfigKey.SessionTimeout] := '0';
      // default content-type
      Config[TMVCConfigKey.DefaultContentType] := TMVCConstants.DEFAULT_CONTENT_TYPE;
      // default content charset
      Config[TMVCConfigKey.DefaultContentCharset] := TMVCConstants.DEFAULT_CONTENT_CHARSET;
      // unhandled actions are permitted?
      Config[TMVCConfigKey.AllowUnhandledAction] := 'false';
      // enables or not system controllers loading (available only from localhost requests)
      Config[TMVCConfigKey.LoadSystemControllers] := 'true';
      // default view file extension
      Config[TMVCConfigKey.DefaultViewFileExtension] := 'html';
      // view path
      Config[TMVCConfigKey.ViewPath] := 'templates';
      // Max Record Count for automatic Entities CRUD
      Config[TMVCConfigKey.MaxEntitiesRecordCount] := '20';
      // Enable Server Signature in response
      Config[TMVCConfigKey.ExposeServerSignature] := 'true';
      // Enable X-Powered-By Header in response
      Config[TMVCConfigKey.ExposeXPoweredBy] := 'true';
      // Max request size in bytes
      Config[TMVCConfigKey.MaxRequestSize] := IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE);
    end);

  FMVC.PublishObject(
    function: TObject
    begin
      Result := TMyObject.Create;
    end, '/myobject');

  FMVC.PublishObject(
    function: TObject
    begin
      Result := TMyComplex.Create;
    end, '/mycomplexobject');

  // the following objects are
  // just to show how the
  // MVCInheritable attribute works
  FMVC.PublishObject(
    function: TObject
    begin
      Result := TChild1.Create;
    end, '/child1');

  FMVC.PublishObject(
    function: TObject
    begin
      Result := TChild2.Create;
    end, '/child2');
end;

procedure TMyWebModule.WebModuleDestroy(Sender: TObject);
begin
  FMVC.Free;
end;

end.
