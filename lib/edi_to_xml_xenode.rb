# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

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
        # msg.msg_id = msg.newid
        msg.data = xml_text
        write_to_children(msg)
      end
      
    rescue Exception => e
      catch_error("#{mctx} - #{e.inspect} #{e.backtrace}")
    end
    
  end
  
end