object MunicipalLibraryDataModule: TMunicipalLibraryDataModule
  OldCreateOrder = False
  Height = 266
  Width = 405
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=municipal_library'
      'User_Name=postgres'
      'Password=postgres'
      'Server=127.0.0.1'
      'DriverID=PG')
    ConnectedStoredUsage = []
    Left = 88
    Top = 64
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 184
    Top = 120
  end
end
