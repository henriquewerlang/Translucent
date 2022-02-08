unit Delphi.Mock;

interface

uses System.Rtti, Delphi.Mock.Classes, Delphi.Mock.Intf, Delphi.Mock.It;

type
  TMock = class
  public
    class function CreateClass<T: class>(const ConstructorArgs: TArray<TValue> = nil; const AutoMock: Boolean = False): TMockClass<T>;
    class function CreateInterface<T: IInterface>(const AutoMock: Boolean = False): IMock<T>;
  end;

  It = record
  public
    class function IsAny<T>: T; static;
    class function IsEqualTo<T>(const Value: T): T; static;
    class function IsNotEqualTo<T>(const Value: T): T; static;
    class function SameFields<T: class>(const Value: T): T; static;
    class function SameProperties<T: class>(const Value: T): T; static;

    class operator Explicit(const ParamIndex: Integer): It;
  end;

  ItReference<T> = record
  public
    class function IsAny: TItParam<T>; static;
    class function IsEqualTo(const Value: T): TItParam<T>; static;
    class function IsNotEqualTo(const Value: T): TItParam<T>; static;
    class function SameFields(const Value: T): TItParam<T>; static;
    class function SameProperties(const Value: T): TItParam<T>; static;

    class operator Explicit(const ParamIndex: Integer): ItReference<T>;
  end;

implementation

{ TMock }

class function TMock.CreateClass<T>(const ConstructorArgs: TArray<TValue>; const AutoMock: Boolean): TMockClass<T>;
begin
  Result := TMockClass<T>.Create(ConstructorArgs, AutoMock);
end;

class function TMock.CreateInterface<T>(const AutoMock: Boolean): IMock<T>;
begin
  Result := TMockInterface<T>.Create(AutoMock);
end;

{ It }

class operator It.Explicit(const ParamIndex: Integer): It;
begin
  TItParams.ParamIndex := ParamIndex;
end;

class function It.IsAny<T>: T;
begin
  Result := Default(T);

  ItReference<T>.IsAny;
end;

class function It.IsEqualTo<T>(const Value: T): T;
begin
  Result := Value;

  ItReference<T>.IsEqualTo(Value);
end;

class function It.IsNotEqualTo<T>(const Value: T): T;
begin
  Result := Value;

  ItReference<T>.IsNotEqualTo(Value);
end;

class function It.SameFields<T>(const Value: T): T;
begin
  Result := Default(T);

  TItParams.AddParam(TItParam<T>.Create(icSameFields, Value));
end;

class function It.SameProperties<T>(const Value: T): T;
begin
  Result := Default(T);

  TItParams.AddParam(TItParam<T>.Create(icSameProperties, Value));
end;

{ ItReference<T> }

class operator ItReference<T>.Explicit(const ParamIndex: Integer): ItReference<T>;
begin
  TItParams.ParamIndex := ParamIndex;
end;

class function ItReference<T>.IsAny: TItParam<T>;
begin
  Result := TItParam<T>.Create(icAny, Default(T));

  TItParams.AddParam(Result);
end;

class function ItReference<T>.IsEqualTo(const Value: T): TItParam<T>;
begin
  Result := TItParam<T>.Create(icEqualTo, Value);

  TItParams.AddParam(Result);
end;

class function ItReference<T>.IsNotEqualTo(const Value: T): TItParam<T>;
begin
  Result := TItParam<T>.Create(icNotEqualTo, Value);

  TItParams.AddParam(Result);
end;

class function ItReference<T>.SameFields(const Value: T): TItParam<T>;
begin
  Result := TItParam<T>.Create(icSameFields, Value);

  TItParams.AddParam(Result);
end;

class function ItReference<T>.SameProperties(const Value: T): TItParam<T>;
begin
  Result := TItParam<T>.Create(icSameProperties, Value);

  TItParams.AddParam(Result);
end;

end.

