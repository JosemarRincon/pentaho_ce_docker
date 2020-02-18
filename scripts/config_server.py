#!/usr/bin/env python
import xml.etree.ElementTree as ET
import os, sys


def context_xml():
    arquivo = "context.xml"
    tree =  ET.parse(arquivo)
    root = tree.getroot()
    filtro = "*"
    for child in root.iter(filtro):
        print(child.tag )
        print(child.attrib )

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
    context_xml()