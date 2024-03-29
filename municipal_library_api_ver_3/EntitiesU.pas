unit EntitiesU;

interface

uses
  System.Generics.Collections,
  MVCFramework.Serializer.Commons,
  MVCFramework.ActiveRecord,
  MVCFramework.Nullables,
  MVCFramework.SQLGenerators.PostgreSQL {links PostgreSQL compiler for RQL} ,
  MVCFramework.Commons, System.SysUtils;

type
  EMLException = class(Exception)

  end;

  TEntityBase = class abstract(TMVCActiveRecord)
  protected
    [MVCTableField('id', [foPrimaryKey, foAutoGenerated])]
    fID: Integer;
  public
    property ID: Integer read fID write fID;
  end;

  TPersonEntityBase = class abstract(TEntityBase)
  private
    [MVCTableField('dob')]
    fDateOfBirth: TDate;
  public
    property DateOfBirth: TDate read fDateOfBirth write fDateOfBirth;
  end;

  [MVCNameCase(ncCamelCase)]
  [MVCTable('customers')]
  TCustomer = class(TPersonEntityBase)
  private
    [MVCTableField('last_name')]
    fLastName: string;
    [MVCTableField('first_name')]
    fFirstName: string;
    [MVCTableField('note')]
    fNote: NullableString;
  public
    property FirstName: string read fFirstName write fFirstName;
    property LastName: string read fLastName write fLastName;
    property Note: NullableString read fNote write fNote;
  end;

  TBook = class;
  TBookRef = class;

  [MVCNameCase(ncCamelCase)]
  [MVCTable('authors')]
  TAuthor = class(TPersonEntityBase)
  private
    fBooks: TEnumerable<TBookRef>;
    [MVCTableField('full_name')]
    fFullName: string;
    function GetBooks: TEnumerable<TBookRef>;
  public
    [MVCNameAs('full_name')]
    property FullName: string read fFullName write fFullName;
    property Books: TEnumerable<TBookRef> read GetBooks;
  end;

  [MVCNameCase(ncCamelCase)]
  [MVCTable('books')]
  [MVCEntityActions([eaRetrieve])]
  TBookRef = class(TEntityBase)
  private
    fLinks: TMVCStringDictionary;
    [MVCTableField('title')]
    fTitle: string;
    [MVCTableField('pub_year')]
    fPubYear: NullableUInt16;
    function GetLinks: TMVCStringDictionary;
  public
    property Title: string read fTitle write fTitle;
    property PubYear: NullableUInt16 read fPubYear write fPubYear;
    property Links: TMVCStringDictionary read GetLinks;
  end;

  [MVCNameCase(ncCamelCase)]
  [MVCTable('books')]
  TBook = class(TEntityBase)
  private
    [MVCTableField('author_id')]
    fAuthorID: Integer;
    [MVCTableField('title')]
    fTitle: string;
    [MVCTableField('pub_year')]
    fPubYear: NullableUInt16;
  protected
    procedure OnValidation(const EntityAction: TMVCEntityAction); override;
  public
    property AuthorID: Integer read fAuthorID write fAuthorID;
    property Title: string read fTitle write fTitle;
    property PubYear: NullableUInt16 read fPubYear write fPubYear;
  end;

  [MVCNameCase(ncCamelCase)]
  [MVCEntityActions([eaRetrieve])]
  TBookAndAuthor = class(TEntityBase)
  private
    [MVCTableField('author_id')]
    fAuthorID: Integer;
    [MVCTableField('title')]
    fTitle: string;
    [MVCTableField('pub_year')]
    fPubYear: Integer;
    [MVCTableField('full_name')]
    fAuthor: string;
  public
    property AuthorID: Integer read fAuthorID write fAuthorID;
    property Title: string read fTitle write fTitle;
    property PubYear: Integer read fPubYear write fPubYear;
    property Author: string read fAuthor write fAuthor;
  end;

  [MVCNameCase(ncCamelCase)]
  [MVCTable('lendings')]
  TLending = class(TEntityBase)
  private
    [MVCTableField('customer_id')]
    fCustomerID: Integer;
    [MVCTableField('book_id')]
    fBookID: Integer;
    [MVCTableField('lending_start')]
    fLendingStart: TDateTime { timestamp };
    [MVCTableField('lending_end')]
    fLendingEnd: NullableTDateTime { timestamp };
    [MVCTableField('lending_start_user_id')]
    fLendingStartUserID: NullableInt64;
    [MVCTableField('lending_end_user_id')]
    fLendingEndUserID: NullableInt64;
  public
    property CustomerID: Integer read fCustomerID write fCustomerID;
    property BookID: Integer read fBookID write fBookID;
    property LendingStart: TDateTime { timestamp } read fLendingStart write fLendingStart;
    property LendingEnd: NullableTDateTime { timestamp } read fLendingEnd write fLendingEnd;
    property LendingStartUserID: NullableInt64 read fLendingStartUserID write fLendingStartUserID;
    property LendingEndUserID: NullableInt64 read fLendingEndUserID write fLendingEndUserID;
  end;

  [MVCNameCase(ncCamelCase)]
  [MVCTable('users')]
  [MVCEntityActions([eaUpdate, eaRetrieve, eaDelete])]
  TUser = class(TEntityBase)
  private
    [MVCTableField('email')]
    fEmail: string;
    [MVCTableField('last_login')]
    fLastLogin: NullableTDateTime { timestamp };
    [MVCTableField('deleted')]
    fDeleted: boolean;
  public
    property Email: string read fEmail write fEmail;
    [MVCDoNotDeSerialize]
    property LastLogin: NullableTDateTime { timestamp } read fLastLogin write fLastLogin;
    [MVCDoNotSerialize]
    [MVCDoNotDeSerialize]
    property Deleted: boolean read fDeleted write fDeleted;
    constructor Create; override;
  end;

  [MVCNameCase(ncCamelCase)]
  [MVCTable('users')]
  [MVCEntityActions([eaCreate])]
  TUserWithPassword = class(TUser)
  private
    fPassword: string; { this field is not retrieved and not stored from/to the database }
    [MVCTableField('pwd', [foWriteOnly])]
    fHashedPwd: string;
    [MVCTableField('salt', [foWriteOnly])]
    fSalt: string;
    [MVCTableField('iterations_count')]
    fIterationsCount: Integer;
    procedure SetPassword(const Value: string);
  protected
    procedure OnBeforeInsert; override;
    procedure OnValidation(const EntityAction: TMVCEntityAction); override;
  public
    [MVCDoNotSerialize]
    [MVCNameAs('pwd')]
    property Password: string read FPassword write SetPassword;
  end;

  [MVCNameCase(ncCamelCase)]
  [MVCTable('users')]
  [MVCEntityActions([eaUpdate])]
  TPassword = class(TEntityBase)
  private
    fPwd: string; { this field is not retrieved and not stored from/to the database }
    [MVCTableField('pwd', [foWriteOnly])]
    fPwdHash: string;
    [MVCTableField('salt', [foWriteOnly])]
    fSalt: string;
    [MVCTableField('iterations_count')]
    fIterationsCount: Integer;
    procedure SetPwd(const Value: string);
    function GetPwd: string;
  protected
    procedure OnBeforeUpdate; override;
    procedure OnValidation(const EntityAction: TMVCEntityAction); override;
  public
    [MVCDoNotSerialize]
    property Pwd: string read GetPwd write SetPwd;
  end;

function GetPasswordHash(const Salt: string; const Iteration: Integer;
  const OutputKeyLength: Integer; const Password: string): string;

implementation

uses
  System.NetEncoding,
  System.Hash,
  MVCFramework.Crypt.Utils, IdHMAC, IdHMACSHA1, CommonsU;

function GetPasswordHash(const Salt: string; const Iteration: Integer;
  const OutputKeyLength: Integer; const Password: string): string;
var
  lPwdUTF8Bytes: TBytes;
  lSaltUTF8Bytes: TBytes;
  lSaltedPassword: TBytes;
begin
  lPwdUTF8Bytes := TEncoding.UTF8.GetBytes(Password);
  lSaltUTF8Bytes := TEncoding.UTF8.GetBytes(Salt);
  lSaltedPassword := PBKDF2(lPwdUTF8Bytes, lSaltUTF8Bytes, Iteration, OutputKeyLength,
    TIdHMACSHA256);
  Result := BytesToHex(lSaltedPassword);
end;

{ TBook }

procedure TBook.OnValidation(const EntityAction: TMVCEntityAction);
begin
  inherited;
  if EntityAction in [eaCreate, eaUpdate] then
  begin
    if (not PubYear.HasValue) or (Title.IsEmpty) then
    begin
      raise EMVCActiveRecord.Create('Title and PubYear are required');
    end;
  end;
end;

{ TAuthor }

function TAuthor.GetBooks: TEnumerable<TBookRef>;
begin
  if fBooks = nil then
  begin
    fBooks := TMVCActiveRecord.Where<TBookRef>('author_id = ?', [ID]);
    AddChildren(fBooks);
  end;
  Result := fBooks;
end;

{ TBookRef }

function TBookRef.GetLinks: TMVCStringDictionary;
begin
  if fLinks = nil then
  begin
    fLinks := StrDict(['href', 'type', 'rel'], ['/api/books/' + Self.ID.ToString,
      TMVCMediaType.APPLICATION_JSON, 'self']);
    AddChildren(fLinks);
  end;
  Result := fLinks;
end;

{ TUserWithPassword }

procedure TUserWithPassword.OnBeforeInsert;
begin
  inherited;
  fSalt := TGUID.NewGuid.ToString;
  fIterationsCount := TSysConst.PASSWORD_HASHING_ITERATION_COUNT;
  fHashedPwd := GetPasswordHash(fSalt, fIterationsCount, TSysConst.PASSWORD_KEY_SIZE,
    fPassword);
end;

procedure TUserWithPassword.OnValidation(const EntityAction: TMVCEntityAction);
begin
  inherited;
  if EntityAction in [eaCreate] then
  begin
    if fPassword.IsEmpty then
    begin
      raise EMLException.Create('Password cannot be empty');
    end;
  end;
end;

procedure TUserWithPassword.SetPassword(const Value: string);
begin
  FPassword := Value;
end;

{ TUser }

constructor TUser.Create;
begin
  inherited;
  fDeleted := False;
end;

{ TPassword }

function TPassword.GetPwd: string;
begin
  Result := fPwd;
end;

procedure TPassword.OnBeforeUpdate;
begin
  inherited;
  fSalt := TGUID.NewGuid.ToString;
  fIterationsCount := TSysConst.PASSWORD_HASHING_ITERATION_COUNT;
  fPwdHash := GetPasswordHash(fSalt, TSysConst.PASSWORD_HASHING_ITERATION_COUNT,
    TSysConst.PASSWORD_KEY_SIZE, fPwd);
end;

procedure TPassword.OnValidation(const EntityAction: TMVCEntityAction);
begin
  inherited;
  if fPwd.IsEmpty then
  begin
    raise EMLException.Create('Password cannot be empty');
  end;
end;

procedure TPassword.SetPwd(const Value: string);
begin
  fPwd := Value;
end;

end.
