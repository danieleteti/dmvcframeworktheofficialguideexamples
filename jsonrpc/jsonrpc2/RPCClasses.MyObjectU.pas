unit RPCClasses.MyObjectU;

interface

uses
  MVCFramework, JsonDataObjects;

type
  TMyObject = class
  public
    // hooks
    procedure OnBeforeRoutingHook(
      const Context: TWebContext;
      const JSON: TJsonObject);
    procedure OnBeforeCallHook(
      const Context: TWebContext;
      const JSON: TJsonObject);
    procedure OnAfterCallHook(
      const Context: TWebContext;
      const JSON: TJsonObject);

    [MVCDoc('Returns Par1 - Par2 but only if the result is greater than zero')]
    function Subtract(Par1, Par2: Integer): Integer;
  end;

implementation

uses
  MVCFramework.Logger, MVCFramework.JSONRPC;

procedure TMyObject.OnAfterCallHook(const Context: TWebContext;
  const JSON: TJsonObject);
begin
  Log.Debug('>>TMyObject.OnAfterCallHook', ClassName);
  Log.Debug(JSON.ToJSON(True), ClassName);
end;

procedure TMyObject.OnBeforeCallHook(const Context: TWebContext;
  const JSON: TJsonObject);
begin
  Log.Debug('>>TMyObject.OnBeforeCallHook', ClassName);
  Log.Debug(JSON.ToJSON(True), ClassName);
end;

procedure TMyObject.OnBeforeRoutingHook(const Context: TWebContext;
  const JSON: TJsonObject);
begin
  Log.Debug('>>TMyObject.OnBeforeRoutingHook', ClassName);
  Log.Debug(JSON.ToJSON(True), ClassName);
end;

function TMyObject.Subtract(Par1, Par2: Integer): Integer;
begin
  if Par1 < Par2 then
  begin
    raise EMVCJSONRPCError.Create(-32000, 'Par1 cannot be less than Par2');
  end;
  Result := Par1 - Par2;
  Log.Debug('Called TMyObject.Subtract(%d,%d) => Result = %d',
    [Par1, Par2, Result], ClassName);
end;

end.
