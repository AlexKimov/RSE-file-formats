/*

*/

filein "rse.ms"
filein "format_io.ms"
filein "rse_header.ms"

/* 
  ----------------------------------
  Ghost Recon, The Sum of All Fears
  ----------------------------------
*/

struct greMaterialParameters
(
  opacity = 0,
  faceted = false,
  ambientColor = (color 0 0 0 0),
  diffuseColor = (color 0 0 0 0), 
  specularColor = (color 0 0 0 0),
  specularLevel = 0.0,
  twoSided = false
)

struct greMaterial
(
  header = greMaterialHeader(),
  params = greMaterialParameters()
)


/* 
  ----------------------------------
  Rainbow Six 1
  ----------------------------------
*/

struct rsMaterialParameters
(
  opacity = 0,
  selfUllumination = 1,
  transparencyType = 3,
  ambientColor = (color 0 0 0),
  diffuseColor = (color 0 0 0), 
  specularColor = (color 0 0 0),
  specularLevel = 0.0,
  twoSided = false
)

struct rsMaterial
(
  --header = rsHeader(),
  params = rsMaterialParameters()
)
struct rseMaterialReader
(
  fstream,
  reader = formatReader(fstream),
  headerReader = rseHeaderReader(fstream), 
  fn read format:rseGlobals.gr =
  (
    local param = -1
    case (format) of 
    (
      (rseGlobals.rs):rseMat = rsMaterial()
      (rseGlobals.gr):rseMat = greMaterial() 
    )
    rseMat.header = headerReader.read rseMat.header
    if format == rseGlobals.rs then
     rseMat.textureFileName = reader.readName()

    rseMat.params.opacity = ((ReadFloat fstream)*100 as integer)
    if format == rseGlobals.rs then
    (
      rseMat.params.selfUllumination = ReadFloat fstream
      rseMat.params.transparencyType = ReadLong fstream 
      rseMat.params.ambientColor = reader.readColorValues alpha:false \
        normalized:false    
      rseMat.params.diffuseColor = reader.readColorValues alpha:false \
        normalized:false   
      rseMat.params.specularColor = reader.readColorValues alpha:false \
        normalized:false      
    )  
    else
    (    
      param = ReadLong fstream
      rseMat.params.faceted = (if param == 0 then true else false)     
      rseMat.params.ambientColor = reader.readColorValues()    
      rseMat.params.diffuseColor = reader.readColorValues()    
      rseMat.params.specularColor = reader.readColorValues()
    )        
    rseMat.params.specularLevel = ReadFloat fstream
    rseMat.params.twoSided = reader.readBool() 
    result = rseMat
  ) 
)

struct rseMaterialWriter
(
  fstream,
  fWriter = formatWriter(fstream),
  headerWriter = rseHeaderWriter(fstream), 
  fn write rseMat =
  (  
    headerWriter.write rseMat.header
    if (isKindOf rseMat rsMaterial) then 
      fWriter.writeName rseMat.textureFileName 
    WriteFloat fstream (rseMat.params.opacity/100)
    if (isKindOf rseMat rsMaterial) then 
    (
      WriteFloat fstream rseMat.params.selfUllumination
      WriteLong fstream rseMat.params.transparencyType
      fWriter.writeColor fstream rseMat.params.ambientColor normalize:true 
      fWriter.writeColor fstream rseMat.params.diffuseColor normalize:true 
      fWriter.writeColor fstream rseMat.params.specularColor normalize:true 
    )   
    else
    ( 
      WriteLong fstream 0
      fWriter.writeColor rseMat.params.ambientColor
      fWriter.writeColor rseMat.params.diffuseColor
      fWriter.writeColor rseMat.params.specularColor         
    ) 
    WriteFloat fstream rseMat.params.specularLevel
    fWriter.writeBool rseMat.params.twoSided   
  ) 
)