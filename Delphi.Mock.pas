unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils, System.Generics.Collections, Delphi.Mock.VirtualInterface;

type
  IMethodInfo = interface

  end;

  IMethodRegister = interface
    procedure RegisterMethod(Method: TRttiMethod; Info: IMethodInfo);
  end;

  IMockSetup<T> = interface
    function When: T;
  end;

  IMock<T> = interface
    function WillExecute(Proc: TProc): IMockSetup<T>;
  end;

  TMock = class
    class function Create<T: IInterface>: IMock<T>;
  end;

  TMockInterface<T: IInterface> = class(TVirtualInterfaceEx, IMock<T>, IMethodRegister)
  private
    FRegistredMethods: TDictionary<TRttiMethod, IMethodInfo>;

    function WillExecute(Proc: TProc): IMockSetup<T>;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    procedure RegisterMethod(Method: TRttiMethod; Info: IMethodInfo);
  public
    constructor Create; reintroduce;

    destructor Destroy; override;

    property RegistredMethods: TDictionary<TRttiMethod, IMethodInfo> read FRegistredMethods write FRegistredMethods;
  end;

implementation

{ TMockInterface<T> }

uses Delphi.Mock.Setup, Delphi.Mock.Method.Types;

constructor TMockInterface<T>.Create;
begin
  inherited Create(TypeInfo(T), OnInvoke);

  FRegistredMethods := TDictionary<TRttiMethod, IMethodInfo>.Create;
end;

destructor TMockInterface<T>.Destroy;
begin
  FRegistredMethods.Free;

  inherited;
end;

procedure TMockInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin

end;

procedure TMockInterface<T>.RegisterMethod(Method: TRttiMethod; Info: IMethodInfo);
begin
  RegistredMethods.Add(Method, Info);
end;

function TMockInterface<T>.WillExecute(Proc: TProc): IMockSetup<T>;
begin
  Result := TMockSetupInterface<T>.Create(Self, TMethodInfoWillExecute.Create);
end;

{ TMock }

class function TMock.Create<T>: IMock<T>;
begin
  Result := TMockInterface<T>.Create;
end;

end.

