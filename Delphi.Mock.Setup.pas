unit Delphi.Mock.Setup;

interface

uses System.Rtti, System.Generics.Collections, Delphi.Mock, Delphi.Mock.VirtualInterface;

type
  TMockSetupInterface<T: IInterface> = class(TVirtualInterfaceEx, IMockSetup<T>)
  private
    FMethodRegister: IMethodRegister;

    function When: T;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create(MethodRegister: IMethodRegister; Method: IMethodInfo);
  end;

implementation

uses System.TypInfo;

{ TMockSetupInterface<T> }

constructor TMockSetupInterface<T>.Create(MethodRegister: IMethodRegister; Method: IMethodInfo);
begin
  inherited Create(TypeInfo(T), OnInvoke);

  FMethodRegister := MethodRegister;
end;

procedure TMockSetupInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
  FMethodRegister.RegisterMethod(Method, nil);
end;

function TMockSetupInterface<T>.When: T;
begin
  QueryInterface(PTypeInfo(TypeInfo(T)).TypeData.GUID, Result);
end;

end.

