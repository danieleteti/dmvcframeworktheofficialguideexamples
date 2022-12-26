unit Controllers.SampleControllerU;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons;

type

  [MVCPath('/api')]
  TSampleController = class(TMVCController)
  public
    [MVCPath('/customers/($ID)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetCustomerByID(const ID: integer);

    [MVCPath('/reversedstrings/($Value)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetReversedString(const Value: string);
  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils, BusinessObjectsU;

procedure TSampleController.GetCustomerByID(const ID: integer);
var
  lCustomer: TCustomer;
begin
  lCustomer := TCustomer.Create;
  try
    lCustomer.ID := ID; // joke :-)
    lCustomer.Name := 'bit Time Professionals';
    lCustomer.ContactFirst := 'Daniele';
    lCustomer.ContactLast := 'Teti';
    lCustomer.AddressLine1 := 'Via di Valle Morta 10';
    lCustomer.AddressLine2 := '00132, ROME, IT';
    lCustomer.City := 'Rome';
    Render(lCustomer, False);
  finally
    lCustomer.Free;
  end;
end;

procedure TSampleController.GetReversedString(const Value: string);
begin
  Render(System.StrUtils.ReverseString(Value.Trim));
end;

end.
