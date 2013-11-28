# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

# = EDIParse 
# 
# Library code used by the EDIParseNode to objectify an edi document.
# 
# The approach is to parse the common elements in any EDI document into a class heirarchy
# to facilitate easier programatic access to the document contents.
# 
# Typical usage would be to simply turn an inbound EDI document into XML for further parsing and/or mapping
# by down stream nodes.
# 
# ISA Interchange is parsed into an Interchange object (InterChng)
# 
# InterChng objects contain one or more Group Segment objects (GroupSeg)
# 
# GroupSeg objects contain one or more Transaction Set objects (TransSeg)
# 
# TransSeg objects contain one or more Segment objects (Seg)
# 
# = Usage Example
# 
#   # create a parser instance
#   edi = EDIParse.new
# 
#   # load edi document from a file
#   edi.load_file path_to_edi_document
# 
#   # parse the edi contents
#   edi.parse
# 
#   # get the xml string
#   xml_string = edi.to_xml
# 

# require 'xml'
require 'nokogiri'

# == Segment Class
# 
# Contains segment name, and an array of fields for that segment.
# 
# === Example:
# ISA|00|...
#   GS|IN|84...
#     ST|810|143
#       BIG|20091214|34567271||5224~...  <== this would be a seg element
#     SE|...
#   GE|...
# IEA|...
class Seg
  # segment name 
  attr_accessor :seg_name
  # array of segment fields
  attr_accessor :flds
  
  # Create a new segment
  # passing in the segment name and the array of fields for that segment.
  def initialize name, *args
    @seg_name = name.to_s
    @flds = args
  end
end

# == Transaction Set Class
# 
# Contains Transaction Set 'ST' fields, 'SE' footer fields, and an array of segment (Seg) objects.
# 
# === Example:
# ISA|00|...
#   GS|IN|84...
#     ST|810|143                      <== this is the transaction set header
#       BIG|20091214|34567271||5224~...
#     SE|...                          <== this is the transaction set footer
#   GE|...
# IEA|...
# 
#
class TransSeg
  # array of transaction set fields ST01, ST02,...
  attr_accessor :flds
  # array of segments contained in this transaction set
  attr_accessor :segs
  # the footer 'SE' fields for this transaction set
  attr_accessor :footer_flds
  
  # Create a new Transaction Set
  # passing in the array of fields, and array of segments for this transaction set.
  def initialize *args
    @flds = args
    @segs = []
  end

  # Returns the ST01 - Transaction Set Identifier Code.
  # 
  # same as @flds[0]
  def doc_type
    @flds[0]
  end

  # Add a segment to the transaction set.
  def push seg
    @segs << seg
  end
  
  # Find a segment within this transaction set using the segment name passed in.
  # 
  # segment name is case insensitive.
  # 
  # returns and empty array if not found.
  # 
  # returns the segment object if found.
  def find seg
    ret_val = []
    fa = []
    @segs.each do |s|
      if s.seg_name.downcase == seg.downcase
        field_list << s.flds
      end
    end
    ret_val = {seg => field_list} unless field_list.empty?
    ret_val
  end
  
  # Set the footer fields for this transaction segment 'SE' fields.
  def footer *args
    @footer_flds = args
  end
end

# == Group Segment Class
# 
# Contains Group Segment 'GS' fields, 'GE' footer fields and an array of (TransSeg) objects.
# 
# === Example:
# ISA|00|...
#   GS|IN|84...                      <== this is the group segment header
#     ST|810|143
#       BIG|20091214|34567271||5224~...
#     SE|...
#   GE|...                          <== this is the group segment footer
# IEA|...
# 
#
class GroupSeg
  # array of group segment 'GS' fields
  attr_accessor :flds
  # array of transaction set (TransSeg) objects
  attr_accessor :trans_segs
  # array of footer fields
  attr_accessor :footer_flds
  
  # Create a new Group Segment, passing in an array of the Group Segment 'GS' fields.
  def initialize *args
    @flds = args
    @trans_segs = []
  end
  
  # Add a Transaction Set to the TransSeg array.
  def push trans_seg
    @trans_segs << trans_seg
  end
  
  # Set the footer fields 'GE' for this group segment.
  def footer *args
    @footer_flds = args
  end
end

# == Interchange Class
# 
# Contains 'ISA' fields, 'IEA' footer fields, and GroupSeg objects.
# 
class InterChng
  # array of Interchange 'ISA' fields.
  attr_accessor :flds
  # array of group segment GroupSeg objects.
  attr_accessor :group_segs
  # array of 'IEA' footer fields.
  attr_accessor :footer_flds
  
  # Create a new Interchange, passing in an array of the Interchange 'ISA' fields.
  def initialize *args
    @flds = args
    @group_segs = []
  end
  
  # Add a Group Segment to the GroupSeg array.
  def push group_seg
    @group_segs << group_seg
  end
  
  # Set the footer fields 'IEA' for this interchange.
  def footer *args
    @footer_flds = args
  end
  
end

# = EDIParse 
# Copyright (c) 2009 Nodally Technologies Inc, All rights reserved.
# 
# Library code used by the EDIParseNode to objectify an edi document.
# 
# The approach is to parse the common elements in any EDI document into a class heirarchy
# to facilitate easier programatic access to the document contents.
# 
# To turn the document into a rough parsed XML document use the to_xml method.
# 
# Typical usage would be to simply turn an inbound EDI document into XML for further parsing and/or mapping
# by down stream nodes.
# 
# ISA Interchange is parsed into an Interchange object (InterChng)
# 
# Interchange objects contain one or more Group Segment objects (GroupSeg)
# 
# Group Segment objects contain one or more Transaction Set objects (TransSeg)

# Transaction Set objects contain one or more Segment objects (Seg)
#
# == Typical usage:
#   # create a parser instance
#   edi = EDIParse.new
# 
#   # load edi document from a file
#   edi.load_file path_to_edi_document
# 
#   # parse the edi contents
#   edi.parse
# 
#   # get the xml string
#   xml_string = edi.to_xml
# 
# === or:
#   # get the edi contents from a file
#   data = File.open(path_to_edi_document, 'r') { |f| f.read }
# 
#   # create a parser instance
#   edi = EDIParse.new data
# 
#   # parse the edi contents
#   edi.parse
# 
#   # get the xml string
#   xml_string = edi.to_xml
# 
# 
class EDIParse
  # array of interchange InterChng objects
  attr_accessor :interchanges
  # boolean indicating that parsing has occured
  attr_accessor :parsed

  # Create a new EDIParse object.
  # 
  # optionally passing in a string representing the EDI document contents.
  # 
  def initialize data = nil
    @row_delim = nil
    @fld_delim = nil
    @rows = data_to_rows(data)
    @interchanges = []
    @parsed = false
  end
  
  # Turns the EDI document into an array of rows, by parsing the file using the record delimeter.
  # 
  # Record delimiter is determined by the 106th character in the ISA header not including CR/LF chars.
  # 
  # Commonly ~ (tilde) is used as a record delimeter.
  def data_to_rows data
    ret_val = []
    # clear existing before loading data
    @interchanges = []
    
    # delims() will set @row_delim and @fld_delim
    if delims(data) && @row_delim && @fld_delim
      if data.is_a?(Array)
        # already in rows
        data.each do |row|
          row = row.gsub("\r","")
          row = row.gsub("\n","")
          ret_val << row
        end
      elsif data.is_a?(String)
        raw_rows = data.split(@row_delim)
        # data.gsub!("\r","")
        # raw_rows = data.split("\n")
        raw_rows.each do |row|
          row = row.gsub("\r","")
          row = row.gsub("\n","")
          ret_val << row.strip if !row.empty?
        end
      end
    end
    ret_val
  end
  
  # Rough parse the EDI file into XML.
  # 
  # Optional parameters:
  # 
  # indent - indent resulting xml (default: true)
  # 
  # include_hdr - if true include <?xml version="1.0" encoding="UTF-8"?> header (default: true)
  # 
  # Creates a root node using the document type, and breaks out some context data.
  # 
  # === Example:
  # 
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <edi_810>
  #     <env>PROD</env>
  #     <sender_id>84863</sender_id>
  #     <receiver_id>6129330000</receiver_id>
  #     <number_of_groups>1</number_of_groups>
  #     <ISA>
  #       <ISA01>00</ISA01>
  #       <ISA02/>
  #       ...
  #     
  # Context data is:
  # 
  #   <env> test or production indicator from ISA15 (either PROD or TEST)
  #   <sender_id> is the sender id from ISA06
  #   <receiver_id> is the receiver id from ISA08
  #   <number_of_groups> number of group segments in the interchange
  # 
  # Returns xml string if successful otherwise will return nil.
  # 
  def to_xml indent = true, include_hdr = true
    ret_val = nil
    # make sure the EDI has been parsed
    if @parsed
      # break out the context fields into thier own xml tags
      # at the top of the document
      doc = get_context_flds
      # turn the rest of the doc into xml tags
      doc = body_to_xml doc
      # process the options - indent and include_hdr
      options = {}
      options.merge!(:indent=>2) if indent
      # pass the options to write_to method
      ret_val = doc.write_to(StringIO.new, options).string
      # loose the header element if include_hdr is false
      ret_val.gsub!(/<\?[^\?]*\?>\n*/,'') unless include_hdr
    end
    ret_val
  end
  
  # Turn the edi document contents into XML.
  # 
  # Takes a single parameter that is an XMLDocument.
  # 
  # Fields will be named by thier position for example:
  # 
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <edi_810>
  #     <env>PROD</env>
  #     <sender_id>84863</sender_id>
  #     <receiver_id>6129330000</receiver_id>
  #     <number_of_groups>1</number_of_groups>
  #     <ISA>
  #       <ISA01>00</ISA01>
  #       <ISA02/>
  #       <ISA03>00</ISA03>
  #       <ISA04/>
  #       <ISA05>ZZ</ISA05>
  #       ...
  # 
  # segments will be named likewise:
  # 
  #   <GS08>004030</GS08>
  #   <ST>
  #     <ST01>810</ST01>
  #     <ST02>143718</ST02>
  #     <BIG>
  #       <BIG01>20091214</BIG01>
  #       <BIG02>28277779</BIG02>
  #       <BIG03/>
  #       <BIG04>3344</BIG04>
  #     </BIG>
  #     <REF>
  #       <REF01>IA</REF01>
  #       <REF02>SANMAR</REF02>
  #     </REF>
  #     ...
  # 
  # walks through all of the group segments and adds them under the <ISA> node.
  # 
  def body_to_xml doc
    ret_val = doc
    if doc
      # put full edi in doc
      isa = seg_to_xml('ISA', interchange.flds, doc)
      # after flds then process groups
      if interchange.group_segs && !interchange.group_segs.empty?
        interchange.group_segs.each do |gseg|
          isa << groups_xml(gseg, doc)
          # process group footer
          isa << seg_to_xml('GE', gseg.footer_flds, doc)
        end
      end
      doc.root << isa
      # add footer fields
      doc.root << seg_to_xml('IEA', interchange.footer_flds, doc)
    end
    doc
  end
  
  # Helper method used by body_to_xml to process a group segment.
  # 
  # Walks through all of the transaction sets for this group and adds them under the <GS> node.
  def groups_xml gseg, doc
    grp = seg_to_xml('GS', gseg.flds, doc)
    # process trans_segs
    if gseg.trans_segs && !gseg.trans_segs.empty?
      gseg.trans_segs.each do |tseg|
        grp << trans_xml(tseg, doc)
        # process footer fields
        grp << seg_to_xml('SE', tseg.footer_flds, doc)
      end
    end
    grp
  end
  
  # Helper method used by groups_xml to process a transaction segment.
  # 
  # Walks through all of the segments and adds them to the <ST> node.
  def trans_xml tseg, doc
    # process segs
    trn = seg_to_xml('ST', tseg.flds, doc)
    if tseg.segs && !tseg.segs.empty?
      tseg.segs.each do |seg|
        trn << seg_to_xml(seg.seg_name, seg.flds, doc)
      end
    end
    trn
  end
  
  # Utility method to create new xml nodes based on a segment name and the segment field positions.
  # 
  # Creates a parent node using name and then creates child xml nodes based on name + fleild_position.
  # 
  # Example:
  #   <N1>
  #     <N101>ST</N101>
  #     <N102>333 2ND AVE</N102>
  #     <N103>92</N103>
  #     <N104>329</N104>
  #   </N1>
  # 
  def seg_to_xml name, flds, doc
    xml = Nokogiri::XML::Node.new(name, doc)
    if flds && !flds.empty?
      i = 0
      flds.each do |f|
        i += 1
        n = Nokogiri::XML::Node.new("#{name}#{'%02d' % i}", doc)
        # content= automatically escapes special characters
        n.content = f unless f.to_s.empty?
        xml << n
      end
    end
    xml
  end
  
  # Creates a new XML::Document (libxml), set the root node to "edi_" + doc_type.
  # 
  # example: 
  #   <edi_810>
  # 
  # Creates context elements for:
  #   <env>
  #   <sender_id>
  #   <receiver_id>
  #   <number_of_groups>
  # 
  # Which aid in routing edi xml documements downstream.
  # 
  # === Typical usage:
  # 
  #   edi = EDIParse.new
  #   edi.load_file path_to_edi_doc
  # 
  #   xml_doc = edi.get_context_flds
  # 
  #   xml_doc = edi.body_to_xml(xml_doc)
  # 
  def get_context_flds
    doc = Nokogiri::XML::Document.new
    doc.root = Nokogiri::XML::Node.new("edi_#{trans_doc_type.to_s}", doc)
    # environment (production/test)
    n = Nokogiri::XML::Node.new('env', doc)
    if ['T','t'].include?(interchange.flds[14])
      n.content = 'TEST'
    else
      n.content = 'PROD'
    end
    doc.root << n
    # sender id
    n = Nokogiri::XML::Node.new('sender_id', doc)
    n.content = interchange.flds[5]
    doc.root << n
    # receiver_id
    n = Nokogiri::XML::Node.new('receiver_id', doc)
    n.content = interchange.flds[7]
    doc.root << n
    # number of groups
    n = Nokogiri::XML::Node.new('number_of_groups', doc)
    n.content = interchange.footer_flds[0]
    doc.root << n
    doc

  end
  
  # Determines the field and record delimeters from the EDI document.
  # 
  # The feild delimeter is the 4th character and the record delimeter is the 106th character.
  def delims data_in
    @row_delim = @fld_delim = ""
    
    # get the first line
    if data_in.is_a?(Array)
      data = data_in[0]
    else
      data = data_in
    end
    
    if !data.to_s.empty? && data.to_s.length >= 106
      @row_delim = data[105]
      @fld_delim = data[3]
    end
    
    # return true (row and field delimeters not empty) or false
    (!@row_delim.empty? && !@fld_delim.empty?)

  end
  
  # Loads an edi document from a file using the file path provided.
  # 
  # The edi document is only loaded it is not parsed until the parse method is called.
  def load_file path
    load_edi_data(File.read(path))
    # @rows = File.read(path).split(/#{Regexp.quote(@row_delim)}\n*\r*/)
  end
  
  # Loads edi document from a string
  def load_edi_data(data)
    @rows = data_to_rows(data)
  end
  
  # Short cut to the first interchange object
  # 
  # Returns @interchanges[0]
  # 
  def interchange
    @interchanges[0]
  end
  
  # Find a Transaction Set [ST] via its Transaction Set Control Number.
  # 
  #   ST01 - Transaction Set Identifier Code
  #   ST02 - Transaction Set Control Number 
  # 
  # Example:
  #   ST|810|143719~
  # 
  # 143719 is the Transaction Set Control Number in the above ST header record.
  # 
  def find_trans_by_number trans_number
    ret_val = nil
    interchange.group_segs.each do |gs| 
      gs.trans_segs.each do |ts|
        ts.flds.each do |f|
          if f == trans_number.to_s
            ret_val = ts
            break
          end
        end
        break if ret_val
      end
      break if ret_val
    end
    ret_val
  end
  
  # Shortcut to groups
  # 
  #  Returns @interchanges[0].group_segs
  # 
  def groups
    @interchanges[0].group_segs
  end
  
  # Returns the TransSeg objects for a specified group
  # 
  # group_index specifies the group (default 0)
  # 
  def trans group_index = 0
    ret_val = nil
    group_index = 0 if group_index.to_i < 1
    if interchange && interchange.group_segs && !interchange.group_segs.empty? && interchange.group_segs[group_index]
      ret_val = interchange.group_segs[group_index].trans_segs
    end
    ret_val
  end
  
  # Parses the EDI document into objects
  # 
  # EDI document must be loaded first by using load_file or by passing
  # in the EDI document as a string during initialization.
  # 
  def parse
    begin
      # for each row in the edi document
      raise ArgumentError, "No data to parse" if @rows.empty?
      @rows.each_with_index do |row,i|
        if row
          # split out the fields
          flds = row.strip.split(@fld_delim)
          flds = flds.collect {|fld| fld.strip.empty? ? nil : fld.strip}
          # call method based on segment name (1st field in each row)
          __send__(*flds) unless flds.empty?
        end
      end
      # EDI doc has been parsed
      @parsed = true
    rescue => e
      raise e
      @parsed = false
    end
  end
  
  # Returns the document type for the specified TransSeg
  # 
  # index - the index of the TransSeg in the group (default 0)
  # 
  # group_index - the index of the group that contains the TransSeg
  # 
  def trans_doc_type index = 0, group_index = 0
    ret_val = ""
    index = 0 if index.to_i < 1
    trns = trans(group_index)
    if trns && trns[index]
      ret_val = trns[index].doc_type
    end
    ret_val
  end
  
  # Returns the number of rows in the EDI document
  def row_count
    @rows.length
  end

  # Processes segments that are not specifically processed by a matching method
  def method_missing(name,*args, &block)
    if @interchanges && !@interchanges.empty?
      @interchanges.last.group_segs.last.trans_segs.last.segs.push Seg.new(name, *args)
    end
    # puts "need to implement #{name} got it with #{args.inspect}"
  end
  
  # Add a new InterChng 
  # 
  # Called by parse send(*flds) when row starts with ISA
  # 
  def ISA *args
    @interchanges << InterChng.new(*args)
  end
  
  # Add a footer fields to InterChng
  # 
  # Called by parse send(*flds) when row starts with IEA
  #
  def IEA *args
    @interchanges.last.footer *args
  end
  
  # Add a new GroupSeg 
  # 
  # Called by parse send(*flds) when row starts with GS
  #
  def GS *args
    @interchanges.last.group_segs.push GroupSeg.new(*args)
  end
  
  # Add a footer fields to GroupSeg
  # 
  # Called by parse send(*flds) when row starts with GE
  #
  def GE *args
    @interchanges.last.group_segs.last.footer *args
  end
  
  # Add a new TransSeg 
  # 
  # Called by parse send(*flds) when row starts with ST
  #
  def ST *args
    @interchanges.last.group_segs.last.trans_segs.push TransSeg.new(*args)
  end
  
  # Add a footer fields to TransSeg
  # 
  # Called by parse send(*flds) when row starts with SE
  #
  def SE *args
    @interchanges.last.group_segs.last.trans_segs.last.footer *args
  end
  
end
