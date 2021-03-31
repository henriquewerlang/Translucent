program Delphi.Mock.Test;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  FastMM5,
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  DUnitX.TestFramework,
  DUnitX.MemoryLeakMonitor.FastMM5,
  Delphi.Mock in '..\Delphi.Mock.pas',
  Delphi.Mock.VirtualInterface in '..\Delphi.Mock.VirtualInterface.pas',
  Delphi.Mock.VirtualInterface.Test in 'Delphi.Mock.VirtualInterface.Test.pas',
  Delphi.Mock.Method in '..\Delphi.Mock.Method.pas',
  Delphi.Mock.It.Test in 'Delphi.Mock.It.Test.pas',
  Delphi.Mock.Classes in '..\Delphi.Mock.Classes.pas',
  Delphi.Mock.Intf in '..\Delphi.Mock.Intf.pas',
  Delphi.Mock.Classes.Test in 'Delphi.Mock.Classes.Test.pas',
  Delphi.Mock.Intf.Test in 'Delphi.Mock.Intf.Test.pas',
  Delphi.Mock.Method.Test in 'Delphi.Mock.Method.Test.pas';

//Just to not remove de IFDEF
{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
  FastMM_OutputDebugStringEvents := [];
  FastMM_LogToFileEvents := [mmetUnexpectedMemoryLeakSummary];
  FastMM_MessageBoxEvents := [mmetDebugBlockDoubleFree, mmetDebugBlockReallocOfFreedBlock, mmetVirtualMethodCallOnFreedObject];
  FastMM_DeleteEventLogFile;

{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
