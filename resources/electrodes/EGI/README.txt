To use EGI sensor coordinates in BESA, you need both a .ela file, and a .sfp file. There are 9 different .ela files, and 8 different .sfp files. Which ones you use depends on which net you are using and how your data is referenced. 

These are the possible nets: 

-- 64 channel, version 1
-- 64 channel, version 2
-- 128 channel
-- 256 channel

Here are the possible ways your data may be referenced: 

-- vertex referenced with the reference absent from the data (for example, a raw file export of unprocessed data). 
-- average referenced with the average reference in the vertex channel. 
-- average referenced without the vertex channel (Note that you loose information this way). 

This guide explains which ela and sfp file to use in each situation. 

64 CHANNEL VER 1
-- Vertex referenced with the reference absent from the data. Use: 
   GSN64andRef.ela
   GSN65v1.0.sfp
-- Average referenced with the average reference in the vertex channel. Use: 
   GSN65.ela
   GSN65v1.0.sfp
-- Average referenced without the vertex channel. Use: 
   GSN64.ela
   GSN64v1.0.sfp

64 CHANNEL VER 2
-- Vertex referenced with the reference absent from the data. Use: 
   GSN64andRef.ela
   GSN65v2.0.sfp
-- Average referenced with the average reference in the vertex channel. Use: 
   GSN65.ela
   GSN65v2.0.sfp
-- Average referenced without the vertex channel. Use: 
   GSN64.ela
   GSN64v2.0.sfp

128 CHANNEL
-- Vertex referenced with the reference absent from the data. Use: 
   GSN128andRef.ela
   GSN129.sfp
-- Average referenced with the average reference in the vertex channel. Use: 
   GSN129.ela
   GSN129.sfp
-- Average referenced without the vertex channel. Use: 
   GSN128.ela
   GSN128.sfp

256 CHANNEL
-- Vertex referenced with the reference absent from the data. Use: 
   GSN256andRef.ela
   GSN257.sfp
-- Average referenced with the average reference in the vertex channel. Use: 
   GSN257.ela
   GSN257.sfp
-- Average referenced without the vertex channel. Use: 
   GSN256.ela
   GSN256.sfp
