unit PrivateControllerU;

interface

uses
  MVCFramework, MVCFramework.Commons;

type
  [MVCPath('/api/private')]
  TPrivateController = class(TMVCController)
  public
    [MVCPath('/role1')]
    [MVCHTTPMethod([httpGET])]
    procedure ActionForRole1;

    [MVCPath('/role2')]
    [MVCHTTPMethod([httpGET])]
    procedure ActionForRole2;
  end;

implementation

{ TPrivateController }

procedure TPrivateController.ActionForRole1;
begin
  ContentType := TMVCMediaType.TEXT_PLAIN;
  Render('Response from ActionForRole1');
end;

procedure TPrivateController.ActionForRole2;
begin
  ContentType := TMVCMediaType.TEXT_PLAIN;
  Render('Response from ActionForRole2');
end;

end.
