unit Delphi.Mock.Expect;

interface

uses Delphi.Mock;

type
  TMockExpectInteface<T: IInterface> = class(TInterfacedObject, IMockExpect<T>)
  private
    FMethodRegister: IMethodRegister;
  public
    constructor Create(MethodRegister: IMethodRegister);

    function Once: IMockSetup<T>;
  end;

implementation

uses Delphi.Mock.Setup, Delphi.Mock.Method.Types;

{ TMockExpectInteface<T> }

constructor TMockExpectInteface<T>.Create(MethodRegister: IMethodRegister);
begin
  FMethodRegister := MethodRegister;
end;

function TMockExpectInteface<T>.Once: IMockSetup<T>;
begin
  Result := TMockSetupInterface<T>.Create(FMethodRegister, TMethodInfoExpect.Create(1));
end;

end.
