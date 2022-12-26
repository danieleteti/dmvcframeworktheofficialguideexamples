unit PrivateControllerU;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons;

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

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils;

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
