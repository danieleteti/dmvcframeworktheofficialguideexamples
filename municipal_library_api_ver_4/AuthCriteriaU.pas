unit AuthCriteriaU;

interface

uses
  MVCFramework, System.Generics.Collections;

type
  TAuthCriteria = class(TInterfacedObject, IMVCAuthenticationHandler)
  public
    procedure OnRequest(const AContext: TWebContext;
      const AControllerQualifiedClassName: string; const AActionName: string;
      var AAuthenticationRequired: Boolean);
    procedure OnAuthentication(const AContext: TWebContext;
      const AUserName: string; const APassword: string;
      AUserRoles: TList<String>;
      var AIsValid: Boolean;
      const ASessionData: TDictionary<string, string>);
    procedure OnAuthorization(const AContext: TWebContext;
      AUserRoles: TList<string>;
      const AControllerQualifiedClassName: string; const AActionName: string;
      var AIsAuthorized: Boolean);
  end;

implementation

uses
  System.SysUtils,
  MVCFramework.ActiveRecord,
  FireDAC.Comp.Client, EntitiesU;

{ TAuthCriteria }

procedure TAuthCriteria.OnAuthentication(const AContext: TWebContext;
  const AUserName, APassword: string; AUserRoles: TList<string>;
  var AIsValid: Boolean;
  const ASessionData: TDictionary<String, String>);
var
  lConn: TFDConnection;
  lUser: TUserPasswordChecker;
begin
  inherited;
  lConn := TFDConnection.Create(nil);
  lConn.ConnectionDefName := 'municipal_library';
  ActiveRecordConnectionsRegistry.AddDefaultConnection(lConn, True);
  try
    lUser := TMVCActiveRecord.GetOneByWhere<TUserPasswordChecker>('email = ? and not deleted', [AUserName], False);
    try
      AIsValid := Assigned(lUser) and lUser.IsValid(APassword);
      if not AIsValid then
      begin
        Exit;
      end;
      AUserRoles.Add('guest');
      if AUserName.EndsWith('@library.com', True) then
      begin
        AUserRoles.Add('employee');
      end;
      ASessionData.AddOrSetValue('user_id',lUser.ID.ToString);
    finally
      lUser.Free;
    end;
  finally
    ActiveRecordConnectionsRegistry.RemoveDefaultConnection;
  end;
end;

procedure TAuthCriteria.OnAuthorization(const AContext: TWebContext;
  AUserRoles: System.Generics.Collections.TList<String>;
  const AControllerQualifiedClassName, AActionName: string;
  var AIsAuthorized: Boolean);
begin
  AIsAuthorized := False;
  if AUserRoles.Contains('employee') then
  begin
    AIsAuthorized := True;
    Exit;
  end
  else
  begin
    AIsAuthorized :=
      (AControllerQualifiedClassName <> 'Controllers.UsersU') or
      (AContext.Request.HTTPMethodAsString = 'GET');
  end;
end;

procedure TAuthCriteria.OnRequest(const AContext: TWebContext;
  const AControllerQualifiedClassName, AActionName: string;
  var AAuthenticationRequired: Boolean);
begin
  AAuthenticationRequired := True;
end;

end.
