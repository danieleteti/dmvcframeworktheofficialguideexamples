unit Controllers.AuthorsU;

interface

uses
  MVCFramework, MVCFramework.Commons, Controllers.BaseU;

type

  [MVCPath('/api/authors')]
  TAuthorsController = class(TControllerBase)
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    procedure GetAuthors;

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetAuthorByID(const ID: Integer);

    [MVCPath('/($AuthorID)/books')]
    [MVCHTTPMethod([httpGET])]
    procedure GetBooksByAuthorID(const AuthorID: Integer);

    [MVCPath]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateAuthor;

    [MVCPath('/($ID)')]
    [MVCHTTPMethod([httpPUT])]
    procedure UpdateAuthorByID(const ID: Integer);
  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils, EntitiesU,
  MVCFramework.ActiveRecord, MVCFramework.Serializer.Commons, System.Generics.Collections;

procedure TAuthorsController.CreateAuthor;
var
  lAuthor: TAuthor;
begin
  lAuthor := Context.Request.BodyAs<TAuthor>;
  try
    lAuthor.Insert;
    Render201Created('/api/authors/' + lAuthor.ID.ToString);
  finally
    lAuthor.Free;
  end;
end;

procedure TAuthorsController.GetAuthorByID(const ID: Integer);
var
  lAuthor: TAuthor;
begin
  lAuthor := TMVCActiveRecord.GetByPK<TAuthor>(ID);
  Render(
    ObjectDict.Add('data', lAuthor,
    procedure(const Obj: TObject; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS.REL, 'authors').
        Add(HATEOAS.HREF, '/api/authors').
        Add(HATEOAS._TYPE, 'application/json');
    end));
end;

procedure TAuthorsController.GetAuthors;
var
  lRQL: string;
begin
  lRQL := Context.Request.Params['q'];
  if lRQL.IsEmpty then
  begin
    lRQL := 'sort(+dateOfBirth,+id)';
  end;

  Render(
    ObjectDict().
    Add('data',
    TMVCActiveRecord.SelectRQL<TAuthor>(lRQL, -1),
    procedure(const Author: TObject; const Links: IMVCLinks)
    begin
      Links.
        AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/authors/' + TAuthor(Author).ID.ToString).
        Add(HATEOAS.REL, 'self');
      Links.
        AddRefLink.
        Add(HATEOAS._TYPE, TMVCMediaType.APPLICATION_JSON).
        Add(HATEOAS.HREF, '/api/authors/' + TAuthor(Author).ID.ToString + '/books').
        Add(HATEOAS.REL, 'books');
    end));
end;

procedure TAuthorsController.GetBooksByAuthorID(const AuthorID: Integer);
var
  lRQL: string;
begin
  lRQL := Format('eq(AuthorID,%d);sort(+title)', [AuthorID]);

  Render(
    ObjectDict().
    Add('data',
    TMVCActiveRecord.SelectRQL<TBook>(lRQL, -1),
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
        Add(HATEOAS.HREF, '/api/lendings/books/' + TBook(Book).ID.ToString).
        Add(HATEOAS.REL, 'lendings');
    end));
end;

procedure TAuthorsController.UpdateAuthorByID(const ID: Integer);
var
  lAuthor: TAuthor;
begin
  lAuthor := TAuthor.Create;
  try
    lAuthor.LoadByPK(ID);
    Context.Request.BodyFor<TAuthor>(lAuthor);
    lAuthor.ID := ID; { do not trust the request body' id }
    lAuthor.Update;
    Render204NoContent('/api/authors/' + lAuthor.ID.ToString);
  finally
    lAuthor.Free;
  end;
end;

end.
