unit Delphi.Mock.Classs.Test;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMockClassTest = class
  public
    [Test]
    procedure WhenCallingWillExecuteHasToReturnAnInterface;
  end;

implementation

{ TMockClassTest }

procedure TMockClassTest.WhenCallingWillExecuteHasToReturnAnInterface;
begin

end;

end.

