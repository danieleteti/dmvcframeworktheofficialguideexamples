unit MunicipalLibraryWM;

interface

uses
  MVCFramework.Crypt.Utils,
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  MVCFramework, Controllers.BooksU;

type
  TMunicipalLibraryWebModule = class(TWebModule)
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
  private
    FMVC: TMVCEngine;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TMunicipalLibraryWebModule;

implementation

{$R *.dfm}

uses
  Controllers.CustomersU,
  System.IOUtils,
  MVCFramework.Commons,
  MVCFramework.Middleware.Compression,
  MVCFramework.Middleware.StaticFiles,
  MVCFramework.Middleware.JWT,
  Controllers.LendingsU,
  Controllers.UsersU,
  Controllers.AuthorsU, AuthCriteriaU, MVCFramework.JWT, CommonsU;

procedure TMunicipalLibraryWebModule.WebModuleCreate(Sender: TObject);
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
      // default view file extension
      Config[TMVCConfigKey.DefaultViewFileExtension] := 'html';
      // view path
      Config[TMVCConfigKey.ViewPath] := 'templates';
      // Max Record Count for automatic Entities CRUD
      Config[TMVCConfigKey.MaxEntitiesRecordCount] := '20';
      // Enable Server Signature in response
      Config[TMVCConfigKey.ExposeServerSignature] := 'true';
      // Enable X-POWERED_BY header in response
      Config[TMVCConfigKey.ExposeXPoweredBy] := 'true';
      // Max request size in bytes
      Config[TMVCConfigKey.MaxRequestSize] := IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE);
      // Don't load system controllers
      Config[TMVCConfigKey.LoadSystemControllers] := 'false';
    end);

  FMVC.AddController(TCustomersController);
  FMVC.AddController(TBooksController);
  FMVC.AddController(TLendingsController);
  FMVC.AddController(TUsersController);
  FMVC.AddController(TAuthorsController);

  var lConfigClaims: TJWTClaimsSetup := procedure(const JWT: TJWT)
    begin
      JWT.Claims.Issuer := 'Municipal Library';
      JWT.Claims.ExpirationTime := Now + EncodeTime(1, 0, 0, 0); // One hour
      JWT.Claims.NotBefore := Now - EncodeTime(0, 5, 0, 0);
    end;

  FMVC.AddMiddleware(TMVCJWTAuthenticationMiddleware.Create(
    TAuthCriteria.Create,
    lConfigClaims,
    JWT_SECRET,
    '/api/login',
    [TJWTCheckableClaim.ExpirationTime, TJWTCheckableClaim.NotBefore]
    ));

  // Add Static files support
  FMVC.AddMiddleware(TMVCStaticFilesMiddleware.Create);
  // Add response compression (deflate, gzip)
  FMVC.AddMiddleware(TMVCCompressionMiddleware.Create);

  MVCCryptInit;
end;

procedure TMunicipalLibraryWebModule.WebModuleDestroy(Sender: TObject);
begin
  FMVC.Free;
end;

end.
