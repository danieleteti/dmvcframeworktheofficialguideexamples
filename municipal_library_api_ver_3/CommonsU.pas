unit CommonsU;

interface

uses
  MVCFramework.Commons;

type
  EMLException = class(EMVCException)

  end;

  TSysConst = class sealed
  public
  const
    PAGE_SIZE = 5;
  const
    PASSWORD_HASHING_ITERATION_COUNT = 100000;
  const
    PASSWORD_KEY_SIZE = 40;
  end;

implementation

end.
