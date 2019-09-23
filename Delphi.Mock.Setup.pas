unit Delphi.Mock.Setup;

interface

uses System.Rtti, System.Generics.Collections, Delphi.Mock, Delphi.Mock.VirtualInterface;

type
  TMockSetupInterface<T: IInterface> = class(TVirtualInterfaceEx, IMockSetup<T>)
  private
    FMock: IMock<T>;

    function When: T;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create(Mock: IMock<T>); reintroduce;
  end;

implementation

uses System.TypInfo;

{ TMockSetupInterface<T> }

constructor TMockSetupInterface<T>.Create;
begin
  inherited Create(TypeInfo(T), OnInvoke);
end;

procedure TMockSetupInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
//  RegistredMethods.Add('', nil);
end;

function TMockSetupInterface<T>.When: T;
begin
  QueryInterface(PTypeInfo(TypeInfo(T)).TypeData.GUID, Result);
end;

end.
