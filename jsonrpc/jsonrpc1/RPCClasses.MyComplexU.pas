unit RPCClasses.MyComplexU;

interface

uses
  JsonDataObjects,
  Data.DB,
  FireDAC.Comp.Client;

type
  TMyComplex = class
  private
    function GetDataset: TFDMemTable;
  public
    function MergeData(Data1, Data2: TJDOJSONObject): TJDOJSONObject;
    function GetAutomotiveBrands: TDataSet;
  end;

implementation

uses
  MVCFramework.Logger, MVCFramework.JSONRPC;

function TMyComplex.GetDataset: TFDMemTable;
var
  lMT: TFDMemTable;
begin
  lMT := TFDMemTable.Create(nil);
  try
    lMT.FieldDefs.Clear;
    lMT.FieldDefs.Add('Code', ftInteger);
    lMT.FieldDefs.Add('Name', ftString, 20);
    lMT.Active := True;
    lMT.AppendRecord([1, 'Ford']);
    lMT.AppendRecord([2, 'Ferrari']);
    lMT.AppendRecord([3, 'Lotus']);
    lMT.AppendRecord([4, 'FCA']);
    lMT.AppendRecord([5, 'Hyundai']);
    lMT.AppendRecord([6, 'De Tomaso']);
    lMT.AppendRecord([7, 'Dodge']);
    lMT.AppendRecord([8, 'Tesla']);
    lMT.AppendRecord([9, 'Kia']);
    lMT.AppendRecord([10, 'Tata']);
    lMT.AppendRecord([11, 'Volkswagen']);
    lMT.AppendRecord([12, 'Audi']);
    lMT.AppendRecord([13, 'Skoda']);
    lMT.First;
    Result := lMT;
  except
    lMT.Free;
    raise;
  end;
end;

function TMyComplex.GetAutomotiveBrands: TDataSet;
begin
  Result := GetDataset;
end;

function TMyComplex.MergeData(Data1, Data2: TJDOJSONObject): TJDOJSONObject;
begin
  Result := TJDOJSONObject.Create;
  Result.O['data1'] := Data1.Clone;
  Result.O['data2'] := Data2.Clone;
end;

end.
