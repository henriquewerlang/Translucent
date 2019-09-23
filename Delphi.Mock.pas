unit Delphi.Mock;

interface

uses System.Rtti, System.SysUtils;

type
  TInvokeProcedure = reference to procedure(const Args: TArray<TValue>; out Result: TValue);

  ISetup<T> = interface
    function When: T;
  end;

  IMock<T> = interface
    function WillExecute(Proc: TProc): ISetup<T>;
  end;

  TMock = class
    class function Create<T: IInterface>: IMock<T>;
  end;

  TMockInterface<T: IInterface> = class(TVirtualInterface, IMock<T>)
  private
    function WillExecute(Proc: TProc): ISetup<T>;

    procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create; reintroduce;
  end;

implementation

{ TMockInterface<T> }

constructor TMockInterface<T>.Create;
begin
  inherited Create(TypeInfo(T), OnInvoke);
end;

procedure TMockInterface<T>.OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin

end;

function TMockInterface<T>.WillExecute(Proc: TProc): ISetup<T>;
begin

end;

{ TMock }

class function TMock.Create<T>: IMock<T>;
begin
  Result := TMockInterface<T>.Create;
end;

end.
