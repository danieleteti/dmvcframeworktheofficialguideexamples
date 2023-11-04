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

procedure TControllerBase.OnAfterAction(AContext: TWebContext; const AActionName: string);
begin
  ActiveRecordConnectionsRegistry.RemoveDefaultConnection;
  inherited;
end;

end.
