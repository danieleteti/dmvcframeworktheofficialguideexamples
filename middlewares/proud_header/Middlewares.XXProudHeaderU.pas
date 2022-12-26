unit Middlewares.XXProudHeaderU;

interface

uses
  MVCFramework;

type
  TMVCRedirectAndroidDeviceOnPlayStore = class(TInterfacedObject, IMVCMiddleware)
  protected
    procedure OnBeforeRouting(Context: TWebContext; var Handled: Boolean);
    procedure OnAfterControllerAction(AContext: TWebContext;
      const AControllerQualifiedClassName: string; const AActionName: string;
      const AHandled: Boolean);
    procedure OnBeforeControllerAction(Context: TWebContext;
      const AControllerQualifiedClassName: string; const AActionNAme: string; var Handled: Boolean);
    procedure OnAfterRouting(AContext: TWebContext; const AHandled: Boolean);
  end;

implementation

uses
  MVCFramework.Logger, System.SysUtils;

procedure TMVCRedirectAndroidDeviceOnPlayStore.OnAfterControllerAction(AContext: TWebContext;
      const AControllerQualifiedClassName: string; const AActionName: string;
      const AHandled: Boolean);
begin
  // do nothing
end;

procedure TMVCRedirectAndroidDeviceOnPlayStore.OnAfterRouting(AContext: TWebContext; const AHandled: Boolean);
begin
  // do nothing
end;

procedure TMVCRedirectAndroidDeviceOnPlayStore.OnBeforeControllerAction(
  Context: TWebContext; const AControllerQualifiedClassName,
  AActionNAme: string; var Handled: Boolean);
begin
  // do nothing
end;

procedure TMVCRedirectAndroidDeviceOnPlayStore.OnBeforeRouting(Context: TWebContext;
  var Handled: Boolean);
begin
  LogD(Context.Request.Headers['User-Agent']);
  if Context.Request.Headers['User-Agent'].Contains('Android') then
  begin
    Context.Response.Location := 'http://play.google.com';
    Context.Response.StatusCode := 307; // temporary redirect
    Handled := True;
  end;
end;

end.
