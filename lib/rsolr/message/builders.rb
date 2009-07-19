class RSolr::Message
  module Builders
    autoload :Builder, File.join(File.dirname(__FILE__), 'builders', 'builder')
    autoload :Libxml, File.join(File.dirname(__FILE__), 'builders', 'libxml')
  end
end
