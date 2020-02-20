#!/usr/bin/env python
import xml.etree.ElementTree as ET
import os, sys
from os import path
from copy import copy

def context_xml():
    oritem_path = "/pentaho-server/tomcat/webapps/pentaho/META-INF/context.xml"
    origem = os.getenv('PENTAHO_HOME')+oritem_path
    origem_tree =  ET.parse(origem)
    origem_root = origem_tree.getroot()
    # path file jndi
    dest = os.getenv('PATH_FILE_CONNECTIONS')
    dest_tree =  ET.parse(dest)
    dest_root = dest_tree.getroot()
    
    tmp = copy(origem_root)
    
    origem_root.clear()
    
    filtro = "Resource"
    cont = 0
    
    for ch_df in tmp.iter(filtro):
        # add after two resource do pentaho hibernate e quartz
        if cont <= 1:
            print("add default conections: "+ch_df.attrib.get('name'))
            origem_root.append(ch_df)
        cont+=1
        
    for con in dest_root.iter(filtro):
        print("add data_sources: "+con.attrib.get('name'))
        origem_root.append(con)
        
        
    print("saving file in :"+origem)
    origem_tree.write(origem, encoding="UTF-8", xml_declaration=True)
       

def server_xml():
    print(os.getenv('PENTAHO_HOME')+"/pentaho-server/tomcat/conf/server.xml" ) 
    arquivo = os.getenv('PENTAHO_HOME')+"/pentaho-server/tomcat/conf/server.xml"
    tree =  ET.parse(arquivo)
    root = tree.getroot()

    filtro = "*"
    for child in root.iter(filtro):
        if child.tag == "Connector":
            if str(child.attrib['protocol']) == 'HTTP/1.1':
                child.set('port',os.getenv('SERVER_PORT') )
                child.set('maxHttpHeaderSize','65536')
            else:
                child.set('port',os.getenv('SERVER_PORT_AJP'))
            child.set('connectionTimeout',os.getenv('SERVER_CONNECTION_TIME'))
        if child.tag == "Engine":
            child.set('defaultHost',os.getenv('SERVER_HOST'))
        if child.tag == "Host": 
            child.set('name',os.getenv('SERVER_HOST'))
        if child.tag == "Valve": 
            child.set('prefix',os.getenv('SERVER_HOST')+'_access_log')                                        

        #print(child.attrib)

    tree.write(os.getenv('PENTAHO_HOME')+"/pentaho-server/tomcat/conf/server.xml")

qual_metodo_usar = sys.argv[1]
if qual_metodo_usar == "server_xml":
    server_xml()
if qual_metodo_usar == "context_xml":
    if path.exists(str(os.getenv('PATH_FILE_CONNECTIONS'))):
        context_xml()
    else:
        print("File connectios does not exist!")