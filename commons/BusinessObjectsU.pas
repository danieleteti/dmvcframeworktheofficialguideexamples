unit BusinessObjectsU;

interface

uses
  MVCFramework.Serializer.Commons, System.Classes, System.Generics.Collections;

type

  [MVCNameCase(ncLowerCase)]
  TCustomer = class
  private
    fID: Integer;
    fName: String;
    fAddressLine2: String;
    fAddressLine1: String;
    fContactFirst: String;
    fCity: String;
    fContactLast: String;
    fCustomerSecret: String;
  public
    property ID: Integer read fID write fID;
    property Name: String read fName write fName;
    property ContactFirst: String read fContactFirst write fContactFirst;
    property ContactLast: String read fContactLast write fContactLast;
    property AddressLine1: String read fAddressLine1 write fAddressLine1;
    property AddressLine2: String read fAddressLine2 write fAddressLine2;
    property City: String read fCity write fCity;
    [MVCDoNotSerialize]
    property CustomerSecret: String read fCustomerSecret write fCustomerSecret;
  end;

  [MVCNameCase(ncLowerCase)]
  TCustomerWithPhoto = class(TCustomer)
  public
    destructor Destroy; override;
  private
    FPhoto: TStream;
    procedure SetPhoto(const Value: TStream);
  public
    property Photo: TStream read FPhoto write SetPhoto;
  end;

  [MVCNameCase(ncLowerCase)]
  TCustomerWithNotes = class(TCustomer)
  public
    destructor Destroy; override;
  private
    FNotes: TStream;
    procedure SetNotes(const Value: TStream);
  public
    [MVCSerializeAsString]
    property Notes: TStream read FNotes write SetNotes;
  end;

  [MVCNameCase(ncLowerCase)]
  TContact = class
  private
    fContactType: String;
    fValue: String;
  public
    property ContactType: String read fContactType write fContactType;
    property Value: String read fValue write fValue;
  end;

  TContacts = class(TObjectList<TContact>)
  end;

  [MVCNameCase(ncLowerCase)]
  TPerson = class
  private
    fAge: UInt8;
    fLastName: String;
    fFirstName: String;
    fPrimaryContact: TContact;
    fOtherContacts: TContacts;
  public
    constructor Create;
    destructor Destroy; override;
    property FirstName: String read fFirstName write fFirstName;
    property LastName: String read fLastName write fLastName;
    property Age: UInt8 read fAge write fAge;
    property PrimaryContact: TContact read fPrimaryContact;
    [MVCListOf(TContact)]
    property OtherContacts: TContacts read fOtherContacts;
  end;

  TUserRoles = TList<string>;

  TSysUser = class
  private
    fUserName: string;
    fRoles: TUserRoles;
    procedure SetUserName(const Value: string);
    function GetUserRoles: TUserRoles;
  public
    constructor Create(const aUserName: string; const aRoles: TArray<String>); overload;
    constructor Create; overload;
    destructor Destroy; override;
    property UserName: string read fUserName write SetUserName;
    property Roles: TUserRoles read GetUserRoles;
  end;

implementation

uses
  System.SysUtils;

{ TCustomerWithPhoto }

destructor TCustomerWithPhoto.Destroy;
begin
  FPhoto.Free;
  inherited;
end;

procedure TCustomerWithPhoto.SetPhoto(const Value: TStream);
begin
  FPhoto.Free;
  FPhoto := Value;
end;

{ TCustomerWithNotes }

destructor TCustomerWithNotes.Destroy;
begin
  FNotes.Free;
  inherited;
end;

procedure TCustomerWithNotes.SetNotes(const Value: TStream);
begin
  FNotes := Value;
end;

{ TPerson }

constructor TPerson.Create;
begin
  inherited Create;
  fPrimaryContact := TContact.Create;
  fOtherContacts := TContacts.Create(True);
end;

destructor TPerson.Destroy;
begin
  fOtherContacts.Free;
  fPrimaryContact.Free;
  inherited;
end;

{ TSysUser }

constructor TSysUser.Create(const aUserName: string; const aRoles: TArray<String>);
var
  lItem: String;
begin
  Create;
  fUserName := aUserName;
  for lItem in aRoles do
  begin
    fRoles.Add(lItem);
  end;
end;

constructor TSysUser.Create;
begin
  inherited;
  fUserName := '';
  fRoles := TList<String>.Create;
end;

destructor TSysUser.Destroy;
begin
  fRoles.Free;
  inherited;
end;

function TSysUser.GetUserRoles: TUserRoles;
begin
  Result := fRoles;
end;

procedure TSysUser.SetUserName(const Value: string);
begin
  fUserName := Value;
end;

end.
