unit Delphi.Mock.Classs.Setup;

interface

uses Delphi.Mock;

type
  TMockClassSetup<T: class> = class(TInterfacedObject)
  private
    function When: T;
  end;

implementation

uses System.Rtti;

{ TMockClassSetup<T> }

function TMockClassSetup<T>.When: T;
begin
  Result := nil;
end;

end.
