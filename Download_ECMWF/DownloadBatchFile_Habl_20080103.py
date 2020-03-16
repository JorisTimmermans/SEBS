from ecmwfapi import ECMWFDataServer

server = ECMWFDataServer()

server.retrieve({
          'use'     : "infrequent",
          'stream'  : "oper",
          'dataset' : "interim",
          'step'    : "0/3/6/9/12",
          'levtype' : "sfc",
          'date'    : "2008-01-03/to/2008-01-03",
          'time'    : "00/06/12/18",
          'type'    : "an/fc",
          'param'   : "159.128",
          'area'    : "90/00/-90/360",
          'grid'    : "0.125/0.125",
          'target'  : "/home/j_timmermans/Simulations/Matlab/SEBS/SEBS4SIGMA/Data/TMP/ECMWF/Habl.grib"
          })