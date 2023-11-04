unit Controllers.BooksU;

interface

uses
  MVCFramework, MVCFramework.Commons, Controllers.BaseU;

type

  [MVCPath('/api/books')]
  TBooksController = class(TControllerBase)
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    procedure GetBooks;

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetBookByID(const ID: Integer);

    [MVCPath]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateBook;

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpPUT])]
    procedure UpdateBookByID(const ID: Integer);
  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils, EntitiesU,
  MVCFramework.ActiveRecord, MVCFramework.Serializer.Commons,
  System.Generics.Collections;

procedure TBooksController.CreateBook;
var
  lBook: TBook;
begin
  lBook := Context.Request.BodyAs<TBook>;
  try
    lBook.Insert;
    Render201Created('/api/books/' + lBook.ID.ToString);
  finally
    lBook.Free;
  end;
end;

procedure TBooksController.GetBookByID(const ID: Integer);
var
  lBook: TBookAndAuthor;
begin
  lBook := TMVCActiveRecord.SelectOne<TBookAndAuthor>(
    'select b.*, a.full_name from books b join authors ' +
    'a on b.author_id = a.id where b.id = ?', [ID]);
  Render(
    ObjectDict.Add('data', lBook,
    procedure(const Book: TObject; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'author').
        Add(HATEOAS.HREF, '/api/authors/' + TBookAndAuthor(Book).AuthorID.ToString).
        Add(HATEOAS._TYPE, 'application/json');

      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'books').
        Add(HATEOAS.HREF, '/api/books').
        Add(HATEOAS._TYPE, 'application/json');

      Links.
        AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/lendings/books/' + TBookAndAuthor(Book).ID.ToString).
        Add(HATEOAS.REL, 'lendings');
    end));
end;

procedure TBooksController.GetBooks;
var
  lRQL: string;
begin
  lRQL := Context.Request.Params['q'];
  if lRQL.IsEmpty then
  begin
    lRQL := 'sort(+title)';
  end;

  Render(
    ObjectDict().
    Add('data',
    TMVCActiveRecord.SelectRQL<TBook>(lRQL, 50),
    procedure(const Book: TObject; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/authors/' + TBook(Book).AuthorID.ToString).
        Add(HATEOAS.REL, 'author');

      Links.
        AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/books/' + TBook(Book).ID.ToString).
        Add(HATEOAS.REL, 'self');

    end));
end;

procedure TBooksController.UpdateBookByID(const ID: Integer);
var
  lBook: TBook;
begin
  lBook := TBook.Create;
  try
    if not lBook.LoadByPK(ID) then
    begin
      raise EMVCActiveRecordNotFound.Create('Book not found');
    end;
    Context.Request.BodyFor<TBook>(lBook);
    lBook.ID := ID; { wins the url mapped parameter over the body one }
    lBook.Update;
    Render204NoContent('/api/books/' + lBook.ID.ToString);
  finally
    lBook.Free;
  end;
end;

end.
