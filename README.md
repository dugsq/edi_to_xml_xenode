EDI-to-XML Xenode
=================

Note: you will need the Xenograte Community Toolkit (XCT) to run this Xenode. Refer to the XCT repo [https://github.com/Nodally/xenograte-xct](https://github.com/Nodally/xenograte-xct) for more information.

**EDI-to-XML Xenode** parses EDI documents that it receives in its input message data and converts the data into XML format, using the EDI field heads as tag names. Each incoming message with data should include an EDI document serialized into a string. Set 'indent' to true in the Configuration File if you prefer to include proper indentation of the fields in the output XML file. Set 'include_headers' to true if you want to include header tags for the output XML. 

###Configuration File Options:###
* loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
* enabled: determines if the Xenode process is allowed to run. Expects true/false.
* debug: enables extra debug messages in the log file. Expects true/false.
* indent: specifies whether the output XML tags should include indentation. Expects true/false.
* include_headers: specifies whether the output XML should include header fields. Expects true/false.

###Example Configuration File:###
* enabled: false
* loop_delay: 30
* debug: false
* indent: true
* include_headers: true

###Example Input:###
* msg.data: ```"ISA*00**00**01*056481716*ZZ*84863*050708*1514*U*00401*000000033*0*T*>~GS*PO*056481716*84863*20050708*1514*33*X*004010~ST*850*000000164~BEG*00*SA*1184421**20050708~REF*IA*204~DTM*010*20050729~N1*BY*CMP 1 Div 100 - ABC Logistics*98*765~N2*DEF Distribution Center~N3*1234 ABC Boulevard~N4*DEF*OH*45678*US~N1*ST**98*765~N2*DEF Distribution Center~N3*1234 ABC Boulevard~N4*DEF*OH*45678*US~PO1*001*36*EA*9.79**IN*08042326RG00SLS*VN*JP72 ROYAL SMALL~CTT*1~SE*15*000000164~GE*1*33~IEA*1*000000033~"```

###Example Output:###
* msg.data: ```"<?xml version="1.0"?>\n<edi_850>\n  <env>TEST</env>\n  <sender_id>056481716</sender_id>\n  <receiver_id>84863</receiver_id>\n  <number_of_groups>1</number_of_groups>\n  <ISA>\n    <ISA01>00</ISA01>\n    <ISA02/>\n    <ISA03>00</ISA03>\n    <ISA04/>\n    <ISA05>01</ISA05>\n    <ISA06>056481716</ISA06>\n    <ISA07>ZZ</ISA07>\n    <ISA08>84863</ISA08>\n    <ISA09>050708</ISA09>\n    <ISA10>1514</ISA10>\n    <ISA11>U</ISA11>\n    <ISA12>00401</ISA12>\n    <ISA13>000000033</ISA13>\n    <ISA14>0</ISA14>\n    <ISA15>T</ISA15>\n    <ISA16>&gt;</ISA16>\n    <GS>\n      <GS01>PO</GS01>\n      <GS02>056481716</GS02>\n      <GS03>84863</GS03>\n      <GS04>20050708</GS04>\n      <GS05>1514</GS05>\n      <GS06>33</GS06>\n      <GS07>X</GS07>\n      <GS08>004010</GS08>\n      <ST>\n        <ST01>850</ST01>\n        <ST02>000000164</ST02>\n        <BEG>\n          <BEG01>00</BEG01>\n          <BEG02>SA</BEG02>\n          <BEG03>1184421</BEG03>\n          <BEG04/>\n          <BEG05>20050708</BEG05>\n        </BEG>\n        <REF>\n          <REF01>IA</REF01>\n          <REF02>204</REF02>\n        </REF>\n        <DTM>\n          <DTM01>010</DTM01>\n          <DTM02>20050729</DTM02>\n        </DTM>\n        <N1>\n          <N101>BY</N101>\n          <N102>CMP 1 Div 100 - ABC Logisitics</N102>\n          <N103>98</N103>\n          <N104>765</N104>\n        </N1>\n        <N2>\n          <N201>DEF Distribution Center</N201>\n        </N2>\n        <N3>\n          <N301>1234 ABC Boulevard</N301>\n        </N3>\n        <N4>\n          <N401>DEF</N401>\n          <N402>OH</N402>\n          <N403>45678</N403>\n          <N404>US</N404>\n        </N4>\n        <N1>\n          <N101>ST</N101>\n          <N102/>\n          <N103>98</N103>\n          <N104>765</N104>\n        </N1>\n        <N2>\n          <N201>DEF Distribution Center</N201>\n        </N2>\n        <N3>\n          <N301>1234 ABC Boulevard</N301>\n        </N3>\n        <N4>\n          <N401>DEF</N401>\n          <N402>OH</N402>\n          <N403>45678</N403>\n          <N404>US</N404>\n        </N4>\n        <PO1>\n          <PO101>001</PO101>\n          <PO102>36</PO102>\n          <PO103>EA</PO103>\n          <PO104>9.79</PO104>\n          <PO105/>\n          <PO106>IN</PO106>\n          <PO107>08042326RG00SLS</PO107>\n          <PO108>VN</PO108>\n          <PO109>JP72 ROYAL SMALL</PO109>\n        </PO1>\n        <CTT>\n          <CTT01>1</CTT01>\n        </CTT>\n      </ST>\n      <SE>\n        <SE01>15</SE01>\n        <SE02>000000164</SE02>\n      </SE>\n    </GS>\n    <GE>\n      <GE01>1</GE01>\n      <GE02>33</GE02>\n    </GE>\n  </ISA>\n  <IEA>\n    <IEA01>1</IEA01>\n    <IEA02>000000033</IEA02>\n  </IEA>\n</edi_850>\n"```
