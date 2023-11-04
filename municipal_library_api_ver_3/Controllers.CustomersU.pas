unit Controllers.CustomersU;

interface

uses
  MVCFramework,
  MVCFramework.Commons, Controllers.BaseU;

type

  [MVCPath('/api/customers')]
  TCustomersController = class(TControllerBase)
  public
    [MVCPath]
    [MVCDoc('Retrieves all the customers with pagination and sorting')]
    [MVCHTTPMethods([httpGET])]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetCustomers;

    [MVCPath('/($ID)')]
    [MVCHTTPMethods([httpGET])]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetCustomerByID(const ID: Integer);

    [MVCPath]
    [MVCDoc('Creates a customer')]
    [MVCHTTPMethods([httpPOST, httpPUT])]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    procedure CreateCustomers;

    [MVCPath('/($ID)')]
    [MVCDoc('Updates a customer')]
    [MVCHTTPMethods([httpPUT])]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure UpdateCustomerByID(const ID: Integer);

    [MVCPath('/($ID)')]
    [MVCDoc('Deletes a customer')]
    [MVCHTTPMethods([httpDELETE])]
    procedure DeleteCustomerByID(const ID: Integer);

  end;

implementation

uses
  System.DateUtils,
  System.Math,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  FireDAC.Stan.Error,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  MVCFramework.ActiveRecord,
  MVCFramework.Serializer.Commons,
  MVCFramework.DataSet.Utils,
  EntitiesU,
  CommonsU;

{ TCustomersController }

procedure TCustomersController.CreateCustomers;
var
  lCustomer: TCustomer;
begin
  lCustomer := Context.Request.BodyAs<TCustomer>;
  try
    lCustomer.Insert;
    Render201Created('/api/customers/' + lCustomer.ID.ToString);
  finally
    lCustomer.Free;
  end;
end;

procedure TCustomersController.DeleteCustomerByID(const ID: Integer);
var
  lCustomer: TCustomer;
begin
  lCustomer := TMVCActiveRecord.GetByPK<TCustomer>(ID);
  try
    try
      lCustomer.Delete;
    except
      on E: EFDException do
      begin
        if E.ToString.Contains('lendings_customers_fk') then
        begin
          raise EMLException.Create(HTTP_STATUS.BadRequest, 'Cannot delete customer with lendings');
        end;
      end;
    end;
  finally
    lCustomer.Free;
  end;
  Render204NoContent('', 'Customer deleted');
end;

procedure TCustomersController.GetCustomerByID(const ID: Integer);
begin
  Render(
    ObjectDict()
    .Add('data',
    TMVCActiveRecord.GetByPK<TCustomer>(ID),
    procedure(const Obj: TObject; const Links: IMVCLinks)
    begin
      Links.AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, Format('/api/lendings/customers/%d', [TCustomer(Obj).ID])).
        Add(HATEOAS.REL, 'customer_lendings');
    end)
    );
end;

procedure TCustomersController.GetCustomers;
var
  lCurrPage: Integer;
  lFirstRec: Integer;
  lRQL: string;
  lCustomers: TObjectList<TCustomer>;
begin
  lCurrPage := 0;
  TryStrToInt(Context.Request.Params['page'], lCurrPage);
  lCurrPage := Max(lCurrPage, 1);
  lFirstRec := ((lCurrPage - 1) * TSysConst.PAGE_SIZE);
  lRQL := Format('sort(+LastName,+FirstName,+ID);limit(%d,%d)', [lFirstRec, TSysConst.PAGE_SIZE]);
  lCustomers := TMVCActiveRecord.SelectRQL<TCustomer>(lRQL, -1);
  Render(ObjectDict()
    .Add('data', lCustomers,
    procedure(const Obj: TObject; const Links: IMVCLinks)
    begin
      Links.AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, Format('/api/customers/%d', [TCustomer(Obj).ID])).
        Add(HATEOAS.REL, 'self');
      Links.AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, Format('/api/customers/%d/lendings', [TCustomer(Obj).ID])).
        Add(HATEOAS.REL, 'customer_lendings');
    end)
    .Add('meta',
    GetPaginationMeta(lCurrPage, lCustomers.Count, TSysConst.PAGE_SIZE, '/api/customers?page=%d')));
end;

procedure TCustomersController.UpdateCustomerByID(const ID: Integer);
var
  lCustomer: TCustomer;
begin
  lCustomer := TMVCActiveRecord.GetByPK<TCustomer>(ID);
  try
    Context.Request.BodyFor<TCustomer>(lCustomer);
    lCustomer.ID := ID;
    lCustomer.Update;
    Render204NoContent('/api/customers/' + lCustomer.ID.ToString, 'Customer Updated');
  finally
    lCustomer.Free;
  end;
end;

end.
