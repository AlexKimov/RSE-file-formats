/*

*/

filein "rse.ms"
filein "format_io.ms"
filein "rse_skeleton.ms"
filein "rse_header.ms"
filein "rse_material.ms"
filein "rse_texture.ms"
filein "rse_weights.ms"
filein "rse_geometryobject.ms"
filein "rse_animations.ms"
filein "rse_point.ms"

struct rseFormatReader
(
  fstream,
  fReader = formatReader(fstream),
  pointReader = rsePointReader(fstream),
  headerReader = rseHeaderReader(fstream),
  materialReader = rseMaterialReader(fstream),
  textureReader = rseTextureReader(fstream),
  geomObjectReader = rseGeometryObjectReader(fstream),
  skeletonReader = rseSkeletonReader(fstream),
  weightReader = rseWeightsReader(fstream),
  skAnimationsReader  = rseSkeletonAnimationReader(fstream),
  fn readName =
  (
    result = fReader.readName()
  ),
  fn readPos = 
  (
    result = fReader.readPoint3Values()
  ),
  fn readRot = 
  (
    result = fReader.readQuatValues()
  ), 
  fn readColor alphaColor:true normalizedValues:true = 
  (
    result = fReader.readColorValues alpha:alphaColor \
      normalized:normalizedValues
  ),  
  fn readIndexes =
  (
    result = fReader.readIndexValues()
  ),
  fn readVertex =
  (
    result = fReader.readPoint3Values()
  ), 
  fn readUV =
  (
    result = fReader.readPoint2Values()
  ),  
  fn readTransformationMatrix =
  (
    result = fReader.readMatrix() 
  ),
  fn readSectionHeader header =  
  (
    result = headerReader.read header
  ), 
  fn skipSection =
  (
    header = readSectionHeader()
    fseek fstream (header.size) #seek_cur  
  ),
  fn readHelperPoint =
  (
    result = pointReader.read()
  ),  
  fn readMaterials rseFormat:rseGlobals.gr =
  (
    materials = #()
    matCount = ReadLong fstream
    for i = 1 to matCount do
      append materials (materialReader.read format:rseFormat)       
    result = materials
  ),
  fn readTextures format:rseGlobals.gr =
  (
    textures = #()
    texCount = ReadLong fstream
    for i = 1 to texCount do 
      append textures (textureReader.read format:rseGlobals.gr)        
    result = textures
  ),  
  fn readGeometryObjects fmt:rseGlobals.gr extendedData:false =
  (
    geomObjects = #()
    objCount = ReadLong fstream 
    for i = 1 to objCount do  
      append geomObjects (geomObjectReader.read format:fmt extData:extendedData)           
    result = geomObjects 
  ),
  fn readSkeleton =
  (
    result = skeletonReader.readSkeleton()
  ),
  fn readVertexWeights =
  (
    vertexWeights = greWeights()
    fReader.readName() -- "skin"
    vertexWeights.header = headerReader.read(vertexWeights.header) 
    weightCount = ReadLong fstream    
    for i = 1 to weightCount do        
      append vertexWeights.weightTable (weightReader.read())
    result = vertexWeights 
  ),
  fn readSkeletonAnimations =
  (
    boneAnimations = #()
    boneCount = ReadLong fstream
    for i = 1 to boneCount do 
    (
      boneAnimation = skAnimationsReader.read() 
      append boneAnimations boneAnimation         
    )
    result = boneAnimations
  ), 
  fn readAnimationNode = 
  (
    animationNode = animationNode()
    result = animationNode    
  ),
  fn readParticleNode = 
  (
    particleNode = animationNode()
    result = particleNode    
  ),
  fn readLightNode = 
  (
    lightNode = lightNode()
    result = lightNode
  ),  
  fn readObjectNode =
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
        append objNode.childNodes (readObjectNode()) 
    )
    result = objNode   
  ),  
  fn readObjectNodes =
  (
    fseek fstream 4 #seek_cur 
    local header = headerReader.read()
    result = readObjectNode()
  )
)

struct rseFormatWriter
(
  fn writeMatrix matrix =
  (
    WriteFloat fstream matrix.row1.x 
    WriteFloat fstream matrix.row1.y
    WriteFloat fstream matrix.row1.z  
    WriteFloat fstream matrix.row2.x 
    WriteFloat fstream matrix.row2.y
    WriteFloat fstream matrix.row2.z  
    WriteFloat fstream matrix.row3.x 
    WriteFloat fstream matrix.row3.y
    WriteFloat fstream matrix.row3.z  
    WriteFloat fstream matrix.row4.x 
    WriteFloat fstream matrix.row4.y
    WriteFloat fstream matrix.row4.z      
  ),
  fn writeMaterials materials =
  (
    WriteLong fstream materials.count
    for i = 1 to materials.count do
    (
      writeSectionHeader materials[i].header
      WriteFloat fstream material.params.Opacity
      WriteLong fstream material.params.isFaceted
      WriteFloat fstream color.red
      WriteFloat fstream color.red
      WriteFloat fstream color.blue
      WriteFloat fstream 1  

      
          
      material.params.specularLevel = ReadFloat fstream 
      material.params.twoSided = ReadByte fstream 
      append materials material       
    )      
  ),
  fn writeTextures =
  (
    
  ),
  fn writeGeometryObjects =
  (
  
  ) 
)  