module PdfServices
  class Error < StandardError
  end

  class AssetError < Error
  end

  class PollingError < Error
  end

  class OperationError < Error
  end

  class ClientError < Error
  end
end
