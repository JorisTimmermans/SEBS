from ecmwfapi import ECMWFDataServer

server = ECMWFDataServer()

server.retrieve({
          'use'     : "infrequent",
          'stream'  : "oper",
          'dataset' : "interim",
          'step'    : "0",
          'levtype' : "pl",
          'date'    : "2008-01-03/to/2008-01-03",
          'time'    : "00/06/12/18",
          'levelist': "750/775/800/825/850/875/900/925/950/1000",
          'type'    : "an",
          'param'   : "133.128",
          'area'    : "90/00/-90/360",
          'grid'    : "0.125/0.125",
          'target'  : "/home/j_timmermans/Simulations/Matlab/SEBS/SEBS4SIGMA/Data/TMP/ECMWF/qa_profile.grib"
          })