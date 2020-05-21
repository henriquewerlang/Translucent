unit Delphi.Mock.Setup.Test;

interface

uses DUnitX.TestFramework, Delphi.Mock, Delphi.Mock.Setup;

type
  [TestFixture]
  TMockSetupTest = class
  private
    function CreatMock<T>(Instance: T): IMockSetup<T>;
  public
    [Test]
    procedure WhenCallingWillExecuteHasToReturnTheInterfaceOfSetup;
  end;

implementation

{ TMockSetupTest }

function TMockSetupTest.CreatMock<T>(Instance: T): IMockSetup<T>;
begin
  Result := TMockSetup<T>.Create(Instance);
end;

procedure TMockSetupTest.WhenCallingWillExecuteHasToReturnTheInterfaceOfSetup;
begin
  var Mock := CreateMock(TObject);

  Assert.IsNotNull(Mock.WillExecute(nil));
end;

end.
