unit Controllers.UsersU;

interface

uses
  MVCFramework, MVCFramework.Commons, Controllers.BaseU;

type

  [MVCPath('/api/users')]
  TUsersController = class(TControllerBase)
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    procedure GetUsers;

    [MVCPath]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateUser;

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetUserByID(const ID: Integer);

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpPUT])]
    procedure UpdateUserByID(const ID: Integer);

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpDELETE])]
    procedure DeleteUserByID(const ID: Integer);
  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils, EntitiesU,
  MVCFramework.ActiveRecord, MVCFramework.Serializer.Commons, System.Generics.Collections,
  FireDAC.Stan.Error;

procedure TUsersController.CreateUser;
var
  lUser: TUserWithPassword;
begin
  lUser := Context.Request.BodyAs<TUserWithPassword>;
  try
    try
      lUser.Deleted := False;
      lUser.Insert;
    except
      on E: EFDException do
      begin
        if E.Message.ToLower.Contains('users_email_idx') then
        begin
          raise EMLException.CreateFmt('User "%s" already exists', [lUser.Email]);
        end;
        raise;
      end;
    end;
    Render201Created('/api/users/' + lUser.ID.ToString);
  finally
    lUser.Free;
  end;
end;

procedure TUsersController.DeleteUserByID(const ID: Integer);
var
  lUser: TUser;
begin
  lUser := TMVCActiveRecord.GetByPK<TUser>(ID);
  try
    lUser.Deleted := True;
    lUser.Update;
    Render204NoContent('', 'User deleted');
  finally
    lUser.Free;
  end;
end;

procedure TUsersController.GetUserByID(const ID: Integer);
var
  lUser: TUser;
begin
  lUser := TMVCActiveRecord.GetByPK<TUser>(ID);
  Render(
    ObjectDict.Add('data', lUser,
    procedure(const Obj: TObject; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'list').
        Add(HATEOAS.HREF, '/api/users').
        Add(HATEOAS._TYPE, 'application/json');
    end));
end;

procedure TUsersController.GetUsers;
var
  lRQL: string;
begin
  lRQL := Context.Request.Params['q'];
  if lRQL.IsEmpty then
  begin
    lRQL := 'eq(deleted,false)';
  end
  else
  begin
    lRQL := 'and(eq(deleted,false),' + lRQL + ')';
  end;

  Render(
    ObjectDict().
    Add('data',
    TMVCActiveRecord.SelectRQL<TUser>(lRQL, 1000),
    procedure(const User: TObject; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/users/' + TUser(User).ID.ToString).
        Add(HATEOAS.REL, 'self');
    end).
    Add('meta',
    StrDict(['filter'], [lRQL])));
end;

procedure TUsersController.UpdateUserByID(const ID: Integer);
var
  lUser: TUser;
begin
  lUser := TUser.Create;
  try
    lUser.LoadByPK(ID);
    Context.Request.BodyFor<TUser>(lUser);
    lUser.ID := ID; { do not trust the request body' id }
    lUser.Deleted := False;
    lUser.Update;
    Render204NoContent('/api/users/' + lUser.ID.ToString,
      'User updated');
  finally
    lUser.Free;
  end;
end;

end.
