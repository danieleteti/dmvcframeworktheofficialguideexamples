unit RPCClasses.MyObjectsHierarchyU;

interface

uses
  MVCFramework;

type
  TParentClass = class
  public
    { ParentMethod1 will be available in inherited classes }
    [MVCInheritable]
    function ParentMethod1: Boolean;
    { ParentMethod2 will not be available in inherited classes }
    function ParentMethod2: Boolean;
  end;

  TChild1 = class(TParentClass)
  public
    function Child1Method1: Boolean;
  end;

  TChild2 = class(TParentClass)
  public
    function Child2Method1: Boolean;
  end;

implementation


{ TParentClass }

function TParentClass.ParentMethod1: Boolean;
begin
  Result := True;
end;

function TParentClass.ParentMethod2: Boolean;
begin
  Result := True;
end;

{ TChild1 }

function TChild1.Child1Method1: Boolean;
begin
  Result := True;
end;

{ TChild2 }

function TChild2.Child2Method1: Boolean;
begin
  Result := True;
end;

end.
