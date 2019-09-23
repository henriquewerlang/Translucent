unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils, System.Generics.Collections, Delphi.Mock.VirtualInterface;

type
  IMockSetup<T> = interface
    function When: T;
  end;

  IMock<T> = interface
    function WillExecute(Proc: TProc): IMockSetup<T>;
  end;

  TMock = class
    class function Create<T: IInterface>: IMock<T>;
  end;

  TMockInterface<T: IInterface> = class(TVirtualInterfaceEx, IMock<T>)
  private
    FRegistredMethods: TDictionary<String, TObject>;
    function WillExecute(Proc: TProc): IMockSetup<T>;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create; reintroduce;

    destructor Destroy; override;

    property RegistredMethods: TDictionary<String, TObject> read FRegistredMethods write FRegistredMethods;
  end;

implementation

{ TMockInterface<T> }

constructor TMockInterface<T>.Create;
begin
  inherited Create(TypeInfo(T), OnInvoke);

  FRegistredMethods := TDictionary<String, TObject>.Create;
end;

destructor TMockInterface<T>.Destroy;
begin
  FRegistredMethods.Free;

  inherited;
end;

procedure TMockInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin

end;

function TMockInterface<T>.WillExecute(Proc: TProc): IMockSetup<T>;
begin

end;

{ TMock }

class function TMock.Create<T>: IMock<T>;
begin
  Result := TMockInterface<T>.Create;
end;

end.
