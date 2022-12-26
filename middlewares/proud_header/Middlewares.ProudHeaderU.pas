unit Middlewares.ProudHeaderU;

interface

uses
  MVCFramework, MVCFramework.Logger;

type
  TProudHeaderMiddleware = class(TInterfacedObject, IMVCMiddleware)
  protected
    procedure OnBeforeRouting(Context: TWebContext; var Handled: Boolean);
    procedure OnBeforeControllerAction(Context: TWebContext;
      const AControllerQualifiedClassName: string; const AActionNAme: string; var Handled: Boolean);
    procedure OnAfterRouting(Context: TWebContext; const AHandled: Boolean);
    procedure OnAfterControllerAction(AContext: TWebContext;
      const AControllerQualifiedClassName: string; const AActionName: string;
      const AHandled: Boolean);
  end;

implementation

uses
  System.SysUtils;

{ TMVCSalutationMiddleware }

procedure TProudHeaderMiddleware.OnAfterControllerAction(AContext: TWebContext;
      const AControllerQualifiedClassName: string; const AActionName: string;
      const AHandled: Boolean);
begin
  // do nothing
end;

procedure TProudHeaderMiddleware.OnAfterRouting(Context: TWebContext; const AHandled: Boolean);
begin
  Context.Response.SetCustomHeader('X-PROUD-HEADER',
    'Proudly served by DelphiMVCFramework');
end;

procedure TProudHeaderMiddleware.OnBeforeControllerAction(Context: TWebContext;
  const AControllerQualifiedClassName, AActionNAme: string; var Handled: Boolean);
begin
  // do nothing
end;

procedure TProudHeaderMiddleware.OnBeforeRouting(Context: TWebContext; var Handled: Boolean);
begin
  // do nothing
end;

end.
