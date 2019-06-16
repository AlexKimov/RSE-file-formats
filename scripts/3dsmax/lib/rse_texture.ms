/*

*/

filein "rse_header.ms"
filein "format_io.ms"

struct greTextureParameters
(
  unknown = 0,
  textureFilename = "",
  opacityType = -1,
  isTiled = 0,
  SelfIllumination = 0.0 
)

struct greTexture
(
  header = greTextureHeader(),
  params = greTextureParameters()
)

struct rseTextureReader
(
  fstream,
  freader = formatReader(fstream),
  headerReader = rseHeaderReader(fstream),   
  fn read = 
  ( 
    local texture = greTexture()
    texture.header = headerReader.read texture.header
    fseek fstream 1 #seek_cur
    texture.params.textureFilename = freader.readName() 
    texture.params.opacityType = ReadLong fstream
    texture.params.isTiled = ReadLong fstream
    texture.params.selfIllumination = ReadFloat fstream   
    result = texture
  )
)

struct rseTextureWriter
(
  fstream,
  fWriter = formatWriter(fstream),
  fn write rseText =
  (
  
  )
)