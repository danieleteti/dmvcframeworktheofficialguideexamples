library ISAPIMunicipalLibraryVer3;

uses
  Winapi.ActiveX,
  System.Win.ComObj,
  Web.WebBroker,
  Web.Win.ISAPIApp,
  Web.Win.ISAPIThreadPool,
  MunicipalLibraryWM in 'MunicipalLibraryWM.pas' {MunicipalLibraryWebModule: TWebModule},
  Controllers.BooksU in 'Controllers.BooksU.pas';

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  Application.Run;
end.
