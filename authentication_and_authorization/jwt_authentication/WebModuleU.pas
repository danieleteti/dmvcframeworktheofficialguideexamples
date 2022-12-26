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
  PublicControllerU,
  PrivateControllerU,
  System.IOUtils,
  MVCFramework.Commons,
  MVCFramework.Middleware.JWT,
  MVCFramework.Middleware.StaticFiles,
  MVCFramework.Middleware.Compression, MVCFramework.JWT, AuthCriteriaU;

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
  FMVC.AddController(TPublicController);
  FMVC.AddController(TPrivateController);

  var lConfigClaims: TJWTClaimsSetup := procedure(const JWT: TJWT)
    begin
      JWT.Claims.Issuer := 'DMVCFramework JWT Authority';
      JWT.Claims.ExpirationTime := Now + EncodeTime(1, 0, 0, 0); // One hour
      JWT.Claims.NotBefore := Now - EncodeTime(0, 5, 0, 0);
    end;

  FMVC.AddMiddleware(TMVCJWTAuthenticationMiddleware.Create(
    TAuthCriteria.Create,
    lConfigClaims,
    'this_is_my_secret',
    '/api/login',
    [TJWTCheckableClaim.ExpirationTime, TJWTCheckableClaim.NotBefore]
    ));
end;

procedure TMyWebModule.WebModuleDestroy(Sender: TObject);
begin
  FMVC.Free;
end;

end.
