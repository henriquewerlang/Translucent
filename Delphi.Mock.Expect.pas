unit Delphi.Mock.Expect;

interface

uses Delphi.Mock;

type
  TMockExpectInteface<T: IInterface> = class(TInterfacedObject, IMockExpectSetup<T>, IMockExpect)
  private
    FMethodRegister: IMethodRegister;

    function CheckExpectations: String;
    function Once: IMockSetup<T>;
  public
    constructor Create(MethodRegister: IMethodRegister);
  end;

implementation

uses Delphi.Mock.Setup, Delphi.Mock.Method.Types;

{ TMockExpectInteface<T> }

function TMockExpectInteface<T>.CheckExpectations: String;
begin
  var MethodExpect: IMethodExpect;

  for var Method in FMethodRegister.GetMethods do
    if Method.QueryInterface(IMethodExpect, MethodExpect) = S_OK then
      Result := Result + MethodExpect.CheckExpectation;
end;

constructor TMockExpectInteface<T>.Create(MethodRegister: IMethodRegister);
begin
  FMethodRegister := MethodRegister;
end;

function TMockExpectInteface<T>.Once: IMockSetup<T>;
begin
  Result := TMockSetupInterface<T>.Create(FMethodRegister, TMethodInfoExpectOnce.Create);
end;

end.
