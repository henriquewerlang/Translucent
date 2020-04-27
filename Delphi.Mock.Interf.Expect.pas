unit Delphi.Mock.Interf.Expect;

interface

uses System.SysUtils, Delphi.Mock;

type
  EExpectationsNotConfigured = class(Exception);

  TMockExpectInteface<T: IInterface> = class(TInterfacedObject, IMockExpectSetup<T>)
  private
//    FMethodRegister: IMethodRegister;

    function CheckExpectations: String;
    function Once: IMockSetup<T>;
  public
    constructor Create;
  end;

implementation

uses Delphi.Mock.Interf.Setup, Delphi.Mock.Method;

{ TMockExpectInteface<T> }

function TMockExpectInteface<T>.CheckExpectations: String;
begin
//  var MethodExpect: IMethodExpect;
//
//  for var Method in FMethodRegister.GetMethods do
//    if Method.QueryInterface(IMethodExpect, MethodExpect) = S_OK then
//      Result := Result + MethodExpect.CheckExpectation;
end;

constructor TMockExpectInteface<T>.Create;
begin
//  FMethodRegister := MethodRegister;
end;

function TMockExpectInteface<T>.Once: IMockSetup<T>;
begin
//  Result := TMockInterfaceSetup<T>.Create(FMethodRegister, TMethodInfoExpectOnce.Create);
end;

end.
