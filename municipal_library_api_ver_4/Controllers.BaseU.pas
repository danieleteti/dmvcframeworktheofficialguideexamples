unit Controllers.BaseU;

interface

uses
  MVCFramework,
  MVCFramework.Commons;

type
  TControllerBase = class(TMVCController)
  protected
    procedure OnBeforeAction(AContext: TWebContext; const AActionName: string;
      var AHandled: Boolean); override;
    procedure OnAfterAction(AContext: TWebContext; const AActionName: string); override;
    procedure EnsureRole(const RoleName: String);
    procedure EnsureOneOf(const Roles: TArray<String>);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  MVCFramework.ActiveRecord;

{ TControllerBase }

procedure TControllerBase.OnBeforeAction(AContext: TWebContext; const AActionName: string;
  var AHandled: Boolean);
var
  lConn: TFDConnection;
begin
  inherited;
  lConn := TFDConnection.Create(nil);
  lConn.ConnectionDefName := 'municipal_library';
  ActiveRecordConnectionsRegistry.AddDefaultConnection(lConn, True);
end;

procedure TControllerBase.EnsureOneOf(const Roles: TArray<String>);
var
  lRole: String;
begin
  for lRole in Roles do
  begin
    if Context.LoggedUser.Roles.Contains(lRole) then
    begin
      Exit;
    end;
  end;
  raise EMVCException.Create(HTTP_STATUS.Forbidden, 'Forbidden');
end;

procedure TControllerBase.EnsureRole(const RoleName: String);
begin
  if not Context.LoggedUser.Roles.Contains(RoleName) then
  begin
    raise EMVCException.Create(HTTP_STATUS.Forbidden, 'Forbidden');
  end;
end;

procedure TControllerBase.OnAfterAction(AContext: TWebContext; const AActionName: string);
begin
  ActiveRecordConnectionsRegistry.RemoveDefaultConnection;
  inherited;
end;

end.
