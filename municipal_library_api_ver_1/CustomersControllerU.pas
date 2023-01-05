unit CustomersControllerU;

interface

uses
  MVCFramework,
  MVCFramework.Commons;

type

  [MVCPath('/api/customers')]
  TCustomersController = class(TMVCController)
  public

    [MVCPath]
    [MVCDoc('Retrieves all the customers')]
    [MVCHTTPMethods([httpGET])]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetCustomers;

    [MVCPath('/($ID)')]
    [MVCHTTPMethods([httpGET])]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetCustomerByID(const ID: Integer);

    [MVCPath]
    [MVCDoc('Creates a customer')]
    [MVCHTTPMethods([httpPOST])]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    procedure CreateCustomers;

  end;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  MVCFramework.Logger,
  MVCFramework.Serializer.Commons,
  MVCFramework.Serializer.JsonDataObjects,
  MVCFramework.DataSet.Utils,
  MVCFramework.FireDAC.Utils,
  JsonDataObjects,
  MunicipalLibraryDM;

{ TCustomersController }

procedure TCustomersController.CreateCustomers;
var
  lJSON: TJDOJsonObject;
  lMunicLibDM: TMunicipalLibraryDataModule;
  lSQL: string;
  lQry: TFDQuery;
  lNewCustomerId: Integer;
begin
  lJSON := StrToJSONObject(Context.Request.Body);
  try
    lSQL := 'INSERT INTO customers (first_name, last_name, dob, note) VALUES (:first_name, :last_name, :dob, :note) returning id';
    lMunicLibDM := TMunicipalLibraryDataModule.Create(nil);
    try
      lQry := lMunicLibDM.NewQuery(lSQL);
      lQry.ParamByName('first_name').AsString := lJSON.S['first_name'];
      lQry.ParamByName('last_name').AsString := lJSON.S['last_name'];
      lQry.ParamByName('dob').AsDate := lJSON.D['dob'];
      lQry.ParamByName('note').AsString := lJSON.S['note'];
      lQry.OpenOrExecute;
      lNewCustomerId := lQry.FieldByName('id').AsInteger;
      Render201Created('/api/customers/' + lNewCustomerId.ToString);
    finally
      lMunicLibDM.Free;
    end;
  finally
    lJSON.Free;
  end;
end;

procedure TCustomersController.GetCustomerByID(const ID: Integer);
var
  lMunicLibDM: TMunicipalLibraryDataModule;
  lQry: TFDQuery;
begin
  lMunicLibDM := TMunicipalLibraryDataModule.Create(nil);
  try
    lQry := lMunicLibDM.NewQuery('select * from customers where id = ?');
    lQry.Open('', [ID]);
    if lQry.Eof then
    begin
      raise EMVCException.Create(HTTP_STATUS.NotFound, 'Customer not found');
    end;
    Render(
      ObjectDict(False)
        .Add('data', lQry, nil, dstSingleRecord, ncLowerCase)
      );
  finally
    lMunicLibDM.Free;
  end;
end;

procedure TCustomersController.GetCustomers;
var
  lMunicLibDM: TMunicipalLibraryDataModule;
  lQry: TFDQuery;
begin
  lMunicLibDM := TMunicipalLibraryDataModule.Create(nil);
  try
    lQry := lMunicLibDM.NewQuery('select id, first_name, last_name, dob from customers order by last_name, first_name');
    lQry.Open;
    Render(
      ObjectDict(False)
        .Add('data', lQry)
      );
  finally
    lMunicLibDM.Free;
  end;
end;

end.
