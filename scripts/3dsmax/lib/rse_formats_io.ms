/*

*/

filein "rse.ms"
filein "format_io.ms"

struct rseFormatReader
(
  filestream,
  fReader = formatReader(filestream),
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
  fn readColor alpha:true normalized:true = 
  (
    result = fReader.readColorValues alpha:alpha normalized:normalized
  ),  
  fn readIndexes =
  (
    result = fReader.readIndexValues()
  ),
  fn readVertex =
  (
    result = fReader.readPoint3Values()
  ), 
  fn readTransformationMatrix =
  (
    result = fReader.readMatrix() 
  ),
  fn readSectionHeader skip:false skipSize:false =  
  (
    if not skip then 
    (
      local header = greHeader()
      if not skipSize then
        header.size = ReadLong filestream
      header.id = ReadLong filestream
      header.name = fReader.readName() 
      if header.name == "Version" then
      (
        header.version = ReadLong filestream
        header.name = fReader.readName()            
      )
      result = header
      --print header       
    )
    else
    (
      fseek filestream 4 #seek_cur
      fseek filestream 4 #seek_cur
      fseek filestream 4 #seek_cur
      local name = ReadString filestream
      if name == "Version" then
      (
        fseek filestream 4 #seek_cur
        length = ReadLong filestream
        fseek filestream length #seek_cur
      )      
    )    
  ), 
  fn skipSection =
  (
    header = readSectionHeader()
    fseek filestream (header.size) #seek_cur  
  ),  
  fn readMaterials format:rseConsts.gr =
  (
    materials = #()
    matCount = ReadLong filestream
    local param = -1
    for i = 1 to matCount do
    (
      case (format) of 
      (
        (rseConsts.rs): material = rsMaterial()
        (rseConsts.gr): material = greMaterial() 
      )
      material.header = readSectionHeader()
      if format == rseConsts.rs then
        material.textureFileName = readName()
      /* 
        opacity value in file is in range 0..1, 3ds max opacity value is 
        between 0 and 100
      */
      material.params.opacity = ((ReadFloat filestream)*100 as integer)
      if format == rseConsts.rs then
      (
        material.params.selfUllumination = ReadFloat filestream
        material.params.transparencyType = ReadLong filestream 
        material.params.ambientColor = readColor alpha:false normalized:false    
        material.params.diffuseColor = readColor alpha:false normalized:false   
        material.params.specularColor = readColor alpha:false normalized:false      
      )  
      else
      (    
        param = ReadLong filestream
        material.params.faceted = (if param == 0 then true else false)     
        material.params.ambientColor = readColor()    
        material.params.diffuseColor = readColor()    
        material.params.specularColor = readColor()
      )        
      material.params.specularLevel = ReadFloat filestream
      param = ReadByte filestream  
      material.params.twoSided = (if param > 0 then true else false)
      append materials material 
      --print material      
    )    
    result = materials
  ),
  fn readTextures format:rseConsts.gr =
  (
    textures = #()
    texCount = ReadLong filestream
    for i = 1 to texCount do
    (
      local texture = greTexture()
      texture.header = readSectionHeader()
      fseek filestream 1 #seek_cur
      fseek filestream 4 #seek_cur
      texture.header.name = ReadString filestream 
      texture.params.opacityType = ReadLong filestream
      texture.params.isTiled = ReadLong filestream
      texture.params.selfIllumination = ReadFloat filestream
      append textures texture
      --print texture      
    )    
    result = textures
  ),  
  fn readGeometryObjects format:rseConsts.gr extData:false =
  (
    objects = #()
    objCount = ReadLong filestream 
    for i = 1 to objCount do
    (   
      case (format) of 
      (
        (rseConsts.rs): geomObject = greGeometryObjectExt()
        (rseConsts.gr): 
        (
          if extData then
          (
            geomObject = greGeometryObjectExt() 
            readSectionHeader skip:true        
          )         
          else      
            geomObject = greGeometryObject()          
        )
      )
    
      geomObject.header = readSectionHeader() 
      geomObject.darkMappped = ReadByte filestream
      geomObject.castShadows = ReadByte filestream

      local vertCount = ReadLong filestream       
      for i = 1 to vertCount do
      (   
        local vertex = readVertex()   
        append geomObject.vertexArray vertex 
      )      
      --print vertCount 
      local meshCount = ReadLong filestream
      local param = 0 
      --print meshCount        
      for i = 1 to meshCount do
      (  
        local mesh = greMesh()
        -- this var seems to be equal 1 always
        fseek filestream 1 #seek_cur
        param = ReadByte filestream         
        mesh.params.detailedDarkmap = (if param > 0 then true else false) 
        param = ReadByte filestream
        mesh.params.isDetailTexture = (if param > 0 then true else false) 
        mesh.params.materialIndex = ReadLong filestream
        param = ReadLong filestream          
        mesh.params.isTextured = (if param > 0 then true else false)
        if mesh.params.isTextured then
        (
          mesh.params.textureIndex = ReadLong filestream 
          if mesh.params.isDetailTexture then
            mesh.params.detailTextureIndex = ReadLong filestream            
        )  
        -- skip mapping variables, not sure what are they for really       
        fseek filestream 24 #seek_cur
        
        local faceCount = ReadLong filestream 
        fseek filestream (16*faceCount) #seek_cur 

        for i = 1 to faceCount do
        (   
          local indexes = readIndexes()
          append mesh.faceIndexArray indexes
        ) 
        --print mesh.faceIndexArray[1]      
        for i = 1 to faceCount do
        (   
          local indexes = readIndexes()
          append mesh.uvIndexArray indexes
        ) 
        --fseek filestream (6*faceCount) #seek_cur        
        
        local vCount = ReadLong filestream
        local tCount = ReadLong filestream
        fseek filestream (12*vCount) #seek_cur 
        uvArray = #()         
        for i = 1 to vCount*tCount do
        (   
          local uv = [ReadFloat filestream, ReadFloat filestream, 0]
          append mesh.uvArray uv
        )    
        fseek filestream (16*vCount) #seek_cur    
        
        append geomObject.meshes mesh        
      )
       
      if extData then
      (
        -- tagging section
        pointCount = ReadLong filestream
        for i = 1 to pointCount do
        (
          local tagPoint = grePoint()
          tagPoint.name = readName()
          tagPoint.matrix = readTransformationMatrix()
          append geomObject.tagPoints tagPoint
        )

        -- collision objects, only .maps
        vertexCount = ReadLong filestream
        for i = 1 to vertexCount do
        ( 
          local vertex = readPoint3Values()
          append geomObject.colObjects.vertexes vertex
        )         
        faceCount = ReadLong filestream
        for i = 1 to faceCount do
        ( 
          local normal = readPoint4Values()          
          append geomObject.colObjects.faces normal       
        )  
        -- TODO: unknown variables, 
        fseek filestream 4 #seek_cur
        
        polygonCount = ReadLong filestream
        for i = 1 to polygonCount do
        ( 
          local polygon = grePolygon()
          polygon.name = readName()
          polygon.collidable = ReadByte filestream
          polygon.carvingBoundary = ReadByte filestream
          fseek filestream 2 #seek_cur    
          polygon.surfaceProperty = ReadLong filestream         
          
          append geomObject.polygons polygon         
        )  
        
        nCount = ReadLong filestream
        for i = 1 to nCount do
        ( 
          unknownStr = greUnknown()
          unknownStr.polygon.name = readName()
          unknownStr.polygon.collidable = ReadByte filestream
          unknownStr.polygon.carvingBoundary = ReadByte filestrea
          fseek filestream 2 #seek_cur    
          unknownStr.polygon.surfaceProperty = ReadLong filestream         
          
          faceCount = ReadLong filestream
          for i = 1 to faceCount do
          ( 
            local normal = readPoint4Values()          
            append unknownStr.faces normal       
          ) 
          append geomObject.unknowns unknownStr         
        )          
      )      
       
      append objects geomObject 
      --print geomObject       
    )    
    result = objects    
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
    objNode.header = readSectionHeader()
    if objNode.header.size == 1 then 
      fseek filestream 1 #seek_cur     
    else
    (
      if objNode.header.id != 51 and objNode.header.id != 53 and \
        objNode.header.id != 54 then
        objNode.taggingProperties = readName()
      if objNode.header.id == 51 then 
        fseek filestream 1 #seek_cur  
      objNode.matrix = readTransformationMatrix()
      case objNode.header.id of
      (
        48: fseek filestream 4 #seek_cur
        50: objNode.params = readAnimationNode()
        51: objNode.params = readParticleNode()
        53: objNode.params = readLightNode()
        54: objNode.params = readLightNode()
      )  
      subNodes = ReadLong filestream
      for i = 1 to subNodes do       
        append objNode.childNodes (readObjectNode()) 
    )
    result = objNode   
  ),  
  fn readObjectNodes =
  (
    fseek filestream 4 #seek_cur 
    local header = readSectionHeader()
    result = readObjectNode()
  )
)

struct rseFormatWriter
(
  fn writeMatrix matrix =
  (
    WriteFloat filestream matrix.row1.x 
    WriteFloat filestream matrix.row1.y
    WriteFloat filestream matrix.row1.z  
    WriteFloat filestream matrix.row2.x 
    WriteFloat filestream matrix.row2.y
    WriteFloat filestream matrix.row2.z  
    WriteFloat filestream matrix.row3.x 
    WriteFloat filestream matrix.row3.y
    WriteFloat filestream matrix.row3.z  
    WriteFloat filestream matrix.row4.x 
    WriteFloat filestream matrix.row4.y
    WriteFloat filestream matrix.row4.z      
  ),
  fn writeMaterials materials =
  (
    WriteLong filestream materials.count
    for i = 1 to materials.count do
    (
      writeSectionHeader materials[i].header
      WriteFloat filestream material.params.Opacity
      WriteLong filestream material.params.isFaceted
      WriteFloat filestream color.red
      WriteFloat filestream color.red
      WriteFloat filestream color.blue
      WriteFloat filestream 1  

      
          
      material.params.specularLevel = ReadFloat filestream 
      material.params.twoSided = ReadByte filestream 
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