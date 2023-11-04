unit Controllers.LendingsU;

interface

uses
  MVCFramework, MVCFramework.Commons, Controllers.BaseU;

type

  [MVCPath('/api/lendings')]
  TLendingsController = class(TControllerBase)
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    procedure GetLendings;

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetLendingByID(const ID: Integer);

    [MVCPath('/books/($ID)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetLendingsByBookID(const ID: Integer);

    [MVCPath('/customers/($CustomerID)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetLendingsByCustomerID(const CustomerID: Integer);

    [MVCPath('/customers/($CustomerID)')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateLending(const CustomerID: Integer);

    [MVCPath('/terminated/($LendingID)')]
    [MVCHTTPMethod([httpPOST])]
    procedure TerminateLending(const LendingID: Integer);

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpPUT])]
    procedure UpdateLendingByID(const ID: Integer);
  end;

const
  SQL_LENDINGS = 'select l.*, u1.email lending_start_user, u2.email lending_end_user, b.title, ' +
    'concat(c.first_name, '' '', c.last_name ) customer_name ' +
    'from lendings l join books b on l.book_id = b.id ' +
    'join customers c on l.customer_id = c.id ' +
    'left join users u1 on l.lending_start_user_id = u1.id ' +
    'left join users u2 on l.lending_end_user_id = u2.id';

implementation

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils, EntitiesU,
  MVCFramework.ActiveRecord, MVCFramework.Serializer.Commons, System.Generics.Collections,
  Data.DB, FireDAC.Stan.Error;

procedure TLendingsController.CreateLending(const CustomerID: Integer);
var
  lLending: TLending;
begin
  lLending := Context.Request.BodyAs<TLending>;
  try
    lLending.LendingStart := Now;
    lLending.LendingEnd.Clear;
    lLending.CustomerID := CustomerID;
    try
      lLending.Insert;
    except
      on E: EFDException do
      begin
        if E.Message.ToLower.Contains('lendings_books_fk') then
        begin
          raise EMVCException.Create(HTTP_STATUS.BadRequest, 'Cannot create lending - book not found');
        end
        else
        begin
          raise;
        end;
      end;
    end;
    Render201Created('/api/lendings/' + lLending.ID.ToString);
  finally
    lLending.Free;
  end;
end;

procedure TLendingsController.GetLendingsByBookID(const ID: Integer);
var
  lSQL: string;
begin
  lSQL := SQL_LENDINGS + ' where b.id = ?';

  Render(ObjectDict(False).Add(
    'data',
    TMVCActiveRecord.SelectDataSet(lSQL, [ID]),
    procedure(const DS: TDataSet; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'self').
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/lendings/' + DS.FieldByName('id').AsString);

      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'lendings_by_customer').
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/lendings/customers/' + DS.FieldByName('customer_id').AsString);
    end, dstAllRecords, ncCamelCase));
end;

procedure TLendingsController.GetLendingsByCustomerID(const CustomerID: Integer);
var
  lSQL: string;
begin
  lSQL := SQL_LENDINGS + ' where c.id = ?';

  Render(ObjectDict(False).Add(
    'data',
    TMVCActiveRecord.SelectDataSet(lSQL, [CustomerID]),
    procedure(const DS: TDataSet; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'lending').
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/lendings/' + DS.FieldByName('id').AsString);

      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'customer').
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/customers/' + DS.FieldByName('customer_id').AsString);
    end, dstAllRecords, ncCamelCase));
end;

procedure TLendingsController.TerminateLending(const LendingID: Integer);
var
  lLending: TLending;
begin
  lLending := TMVCActiveRecord.GetByPK<TLending>(LendingID);
  try
    if lLending.LendingEnd.HasValue then
    begin
      raise EMVCException.Create(HTTP_STATUS.BadRequest, 'Lending already terminated');
    end;
    lLending.LendingEnd := Now;
    lLending.LendingEndUserID := 1;
    lLending.Update;
    Render204NoContent('/api/lendings/' + LendingID.ToString, 'Lending Terminated Correctly');
  finally
    lLending.Free;
  end;
end;

procedure TLendingsController.GetLendingByID(const ID: Integer);
var
  lSQL: string;
  lLending: TDataSet;
begin
  lSQL := SQL_LENDINGS + ' where l.id = ?';
  lLending := TMVCActiveRecord.SelectDataSet(lSQL, [ID]);
  try
    if lLending.Eof then
    begin
      raise EMVCException.Create(HTTP_STATUS.NotFound, 'Lending not found');
    end;
    Render(
      ObjectDict(False)
      .Add('data',
      lLending,
      procedure(const DS: TDataSet; const Links: IMVCLinks)
      begin
        Links.
          AddRefLink.
          Add(HATEOAS.REL, 'lendings_by_customer').
          Add(HATEOAS.HREF, '/api/lendings/customers/' + DS.FieldByName('customer_id').AsString).
          Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON);
        Links.
          AddRefLink.
          Add(HATEOAS.REL, 'lendings_by_book').
          Add(HATEOAS.HREF, '/api/lendings/books/' + DS.FieldByName('book_id').AsString).
          Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON);
      end, dstSingleRecord, ncCamelCase));
  finally
    lLending.Free;
  end;
end;

procedure TLendingsController.GetLendings;
var
  lSQL: string;
  lParamValues: array of variant;
  lParamTypes: array of TFieldType;
  lWherePieces: array of string;
  lStatus: string;
  lLendings: TDataSet;
begin
  lParamValues := [];
  lParamTypes := [];

  lSQL := SQL_LENDINGS;

  if not Context.Request.Params['status'].IsEmpty then
  begin
    lStatus := Context.Request.Params['status'].ToLower;
    if lStatus = 'open' then
    begin
      lWherePieces := lWherePieces + ['l.lending_end is null'];
    end
    else if lStatus = 'closed' then
    begin
      lWherePieces := lWherePieces + ['l.lending_end is not null'];
    end
    else
    begin
      raise EMVCException.Create(HTTP_STATUS.BadRequest, 'Unknown valud for "status" param (allowed: "open"|"closed"');
    end;
  end;

  if Length(lWherePieces) > 0 then
  begin
    lSQL := lSQL + ' where ' + string.Join(' and ', lWherePieces);
  end;
  lSQL := lSQL + ' order by l.lending_start';

  lLendings := TMVCActiveRecord.SelectDataSet(lSQL, []);
  Render(
    ObjectDict()
    .Add('data',
    lLendings,
    procedure(const DS: TDataSet; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'self').
        Add(HATEOAS.HREF, '/api/lendings/' + DS.FieldByName('id').AsString).
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON);

      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'lendings_by_customer').
        Add(HATEOAS.HREF, '/api/lendings/customers/' + DS.FieldByName('customer_id').AsString).
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON);

      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'lendings_by_book').
        Add(HATEOAS.HREF, '/api/lendings/books/' + DS.FieldByName('book_id').AsString).
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON);
    end, dstAllRecords, ncCamelCase)
    .Add('meta', StrDict(['count'], [lLendings.RecordCount.ToString])));
end;

procedure TLendingsController.UpdateLendingByID(const ID: Integer);
var
  lBook: TBook;
begin
  lBook := TBook.Create;
  try
    lBook.LoadByPK(ID);
    Context.Request.BodyFor<TBook>(lBook);
    lBook.ID := ID; { do not trust the request body' id }
    lBook.Update;
    Render204NoContent('/api/books/' + lBook.ID.ToString);
  finally
    lBook.Free;
  end;
end;

end.
