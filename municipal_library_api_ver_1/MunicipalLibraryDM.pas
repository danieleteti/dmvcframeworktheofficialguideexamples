unit MunicipalLibraryDM;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TMunicipalLibraryDataModule = class(TDataModule)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
  private
    { Private declarations }
  public
    function NewQuery(const SQL: String): TFDQuery;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}
{ TMunicipalLibraryDataModule }

function TMunicipalLibraryDataModule.NewQuery(const SQL: String): TFDQuery;
begin
  Result := TFDQuery.Create(FDConnection1); { Query is owned by the connection }
  Result.FetchOptions.Unidirectional := True;
  Result.FetchOptions.Mode := fmOnDemand;
  Result.UpdateOptions.ReadOnly := True;
  Result.Connection := FDConnection1;
  Result.SQL.Text := SQL;
end;

end.
