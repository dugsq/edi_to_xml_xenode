# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

# version 0.1.0
#
# EDI-to-XML Xenode parses EDI documents that it receives in its input message data and converts the data 
# into XML format, using the EDI field heads as tag names. Each incoming message with data should include an 
# EDI document serialized into a string. Set 'indent' to true in the Configuration File if you prefer to 
# include proper indentation of the fields in the output XML file. Set 'include_headers' to true if you want 
# to include header tags for the output XML. 
#
# Configuration File Options:###
#   loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
#   enabled: determines if the Xenode process is allowed to run. Expects true/false.
#   debug: enables extra debug messages in the log file. Expects true/false.
#   indent: specifies whether the output XML tags should include indentation. Expects true/false.
#   include_headers: specifies whether the output XML should include header fields. Expects true/false.
#
# Example Configuration File:###
#   enabled: false
#   loop_delay: 30
#   debug: false
#   indent: true
#   include_headers: true
#

#xeno-meta:EdiToXmlXenode

# require the edi_parse lib
require File.expand_path(File.join(File.dirname(__FILE__),'edi_to_xml_xenode','edi_parse'))


class EdiToXmlXenode
  include XenoCore::XenodeBase
  
  def startup
    @indent = @config.fetch('indent', true)
    @include_headers = @config.fetch('include_headers', true)
  end
  
  def process_message(msg)
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    
    begin
      
      if msg && msg.data
        edi = EDIParse.new msg.data
        edi.parse()
        xml_text = edi.to_xml(@indent, @include_headers)
        # forward the message to children
        msg.msg_id = msg.newid
        msg.data = xml_text
        write_to_children(msg)
      end
      
    rescue Exception => e
      catch_error("#{mctx} - #{e.inspect} #{e.backtrace}")
    end
    
  end
  
end
