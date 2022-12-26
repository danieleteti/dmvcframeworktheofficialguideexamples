unit RPCClasses.MyObjectU;

interface

uses
  MVCFramework;

type
  TMyObject = class
  public
    [MVCDoc('Returns Par1 - Par2 but only if the result is greater than zero')]
    function Subtract(Par1, Par2: Integer): Integer;
    [MVCDoc('Does nothing, but do it very well')]
    procedure Update(Par1: string);
  end;

implementation

uses
  MVCFramework.Logger, MVCFramework.JSONRPC;

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

procedure TMyObject.Update(Par1: string);
begin
  if Par1 = 'raiseerror' then
  begin
    raise EMVCJSONRPCError.Create(-32001, 'This is an error raised by "TMyObject.Update"');
  end;
  Log.Debug('Called TMyObject.Update(%s)', [Par1], ClassName);
end;

end.
