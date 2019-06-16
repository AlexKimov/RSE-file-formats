/*

*/

filein "rse.ms"
filein "rse_header.ms"
filein "format_io.ms"

struct greNode
(
  header = greHeader(),
  taggingProperties = "",
  params,
  matrix = matrix3 0, 
  childNodes = #()
) 

struct animationNode
(
  p
)

struct particleNode
(
  p
)

struct lightNode
(
  p
) 

struct rseNodeReader
(
  fstream,
  fReader = formatReader(fstream),
  headerReader = rseHeaderReader(fstream),
  fn readAnimationNode =
  (
    
  ),
  fn readParticleNode =
  (
  
  ),
  fn readLightNode =
  (
  
  ),  
  fn readNode =
  (
    objNode = greNode() 
    objNode.header = headerReader.read(objNode.header)
    if objNode.header.size == 1 then 
      fseek fstream 1 #seek_cur     
    else
    (
      if objNode.header.id != 51 and objNode.header.id != 53 and \
        objNode.header.id != 54 then
        objNode.taggingProperties = readName()
      if objNode.header.id == 51 then 
        fseek fstream 1 #seek_cur  
      objNode.matrix = fReader.readTransformationMatrix()
      case objNode.header.id of
      (
        48: fseek fstream 4 #seek_cur
        50: objNode.params = readAnimationNode()
        51: objNode.params = readParticleNode()
        53: objNode.params = readLightNode()
        54: objNode.params = readLightNode()
      )  
      subNodes = ReadLong fstream
      for i = 1 to subNodes do       
        append objNode.childNodes (readNode()) 
    )
    result = objNode   
  )
)

struct rseNodeWriter
(
  fstream,
  fReader = formatReader(fstream),
  headerWriter = rseHeaderWriter(fstream),    
  fn writeNode rseObjectNode =
  (
    headerWriter.write rseObjectNode.header
    if rseObjectNode.header.size == 1 then
      WriteByte 1
      
  )
)