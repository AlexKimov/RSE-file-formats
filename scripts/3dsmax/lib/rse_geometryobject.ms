/*

*/

filein "rse.ms"
filein "format_io.ms"
filein "rse_header.ms"
filein "rse_point.ms"

struct greMeshParameters
(
  detailedDarkmap = false,
  isDetailTexture = false,
  materialIndex = -1,
  isTextured = false,
  textureIndex = -1,
  detailTextureIndex = -1
)

struct greMesh
(
  params = greMeshParameters(),
  faceIndexArray = #(),
  faceNormalArray = #(),
  uvArray = #(),
  uvIndexArray = #(), 
  vertexNormalArray = #(),
  faceColorArray = #(),
  vertexIndexArray
)

struct grecolObjects
(
  vertexesy = #(),
  facesy = #()
)

struct grePolygon
(
  name = "",
  collidable = -1,
  carvingBoundary = -1,
  surfaceProperty = -1
)

struct greUnknown
(
  polygon = grePolygon(),
  faces = #()
)

struct greGeometryObject
(
  header = greHeader(),
  darkMappped = false,
  castShadows = false,
  vertexArray = #(),
  meshes = #()
)

struct greGeometryObjectExt
(
  header = greHeader(),
  darkMappped = false,
  castShadows = false,
  vertexArray = #(),
  meshes = #(),
  tagPoints = #(), 
  colObjects = grecolObjects(),
  polygons = #(),
  unknowns = #()  
)

struct rseModelViewer
(
  fn create model materials: =
  (
    if materials != unsupplied then
    (
      msh = max.createTexturedMesh vertArray faceArray tvertArray
      max.addMaterialToMesh msh materials[materialIndex]
    )	
    else
      msh = max.createMesh vertArray faceArray  
  )
)

struct rseMeshViewer
(
  fn create vArray msh materials: =
  (
  
    local faceArray = deepCopy msh.faceIndexArray 
    
    vertArray = #()    
    for i = 1 to faceArray.count do
      for n = 1 to 3 do
      (
        local index = (faceArray[i])[n]
        itemIndex = findItem vertArray vArray[index]
        if itemIndex > 0 then 
          (faceArray[i])[n] = itemIndex
        else
        (
          append vertArray (vArray[index])
          (faceArray[i])[n] = vertArray.count         
        )                   
      )  
    
    if materials != unsupplied and msh.params.materialIndex >= 0 then
    (
      tvertArray = #()  
      for i = 1 to msh.uvIndexArray.count do 
      (      
        for n = 1 to 3 do
        (
          local index = (msh.uvIndexArray[i])[n]
          append tvertArray msh.uvArray[index]
        )
      )    
      msh = max.createTexturedMesh vertArray faceArray tvertArray
      max.addMaterialToMesh msh materials[msh.params.materialIndex + 1]
    )
    else
      msh = max.createMesh vertArray faceArray
    result = msh      
  )
)

struct rseGeometryObjectReader
(
  fstream,
  freader = formatReader(fstream),
  headerReader = rseHeaderReader(fstream),
  pointReader = rsePointReader(fstream), 
  fn readMesh =
  (
    local msh = greMesh()
    fseek fstream 1 #seek_cur -- to be equal 1 always     
    msh.params.detailedDarkmap = freader.readBool()  
    msh.params.isDetailTexture = freader.readBool() 
    msh.params.materialIndex = ReadLong fstream       
    msh.params.isTextured = freader.readBool longval:true
    if msh.params.isTextured then
    (
      msh.params.textureIndex = ReadLong fstream 
      if msh.params.isDetailTexture then
        msh.params.detailTextureIndex = ReadLong fstream            
    ) 
    -- skip mapping variables     
    fseek fstream 24 #seek_cur
    local faceCount = ReadLong fstream 
    fseek fstream (16*faceCount) #seek_cur 
    for i = 1 to faceCount do  
      append msh.faceIndexArray (freader.readIndexValues())
    --print msh.faceIndexArray[1]      
    for i = 1 to faceCount do
      append msh.uvIndexArray (freader.readIndexValues())
    --fseek fstream (6*faceCount) #seek_cur           
    local vCount = ReadLong fstream
    local tCount = ReadLong fstream
    fseek fstream (12*vCount) #seek_cur 
    uvArray = #()         
    for i = 1 to vCount*tCount do
    (   
      local uvValues = freader.readPoint2Values()
      local uv = [uvValues.x, uvValues.y, 0]
      append msh.uvArray uv
    )    
    fseek fstream (16*vCount) #seek_cur  
    result = msh    
  ),  
  fn read format:rseGlobals.gr extData:false = 
  (  
      case (format) of 
      (
        (rseGlobals.rs): geomObject = greGeometryObjectExt()
        (rseGlobals.gr): 
        (
          if extData then
          (
            geomObject = greGeometryObjectExt() 
            headerReader.read (greHeader())      
          )         
          else      
            geomObject = greGeometryObject()          
        )
      )
      
      geomObject.header = headerReader.read (geomObject.header)
      geomObject.darkMappped = freader.readBool()
      geomObject.castShadows = freader.readBool()

      local vertCount = ReadLong fstream     
      for i = 1 to vertCount do
        append geomObject.vertexArray (freader.readPoint3Values()) 

      local meshCount = ReadLong fstream        
      for i = 1 to meshCount do
      (      
        msh = this.readMesh()
        append geomObject.meshes msh    
      )
      
      if extData then
      (
        -- tagging section
        pointCount = ReadLong fstream
        for i = 1 to pointCount do
          append geomObject.tagPoints (pointReader.read())

        -- collision objects, only .maps
        vertexCount = ReadLong fstream
        for i = 1 to vertexCount do
          append geomObject.colObjects.vertexes freader.readPoint3Values()
        
        faceCount = ReadLong fstream
        for i = 1 to faceCount do
        ( 
          local normal = readPoint4Values()          
          append geomObject.colObjects.faces normal       
        )  
        -- TODO: unknown variables, 
        fseek fstream 4 #seek_cur
        
        polygonCount = ReadLong fstream
        for i = 1 to polygonCount do
        ( 
          local polygon = grePolygon()
          polygon.name = freader.readName()
          polygon.collidable = ReadByte fstream
          polygon.carvingBoundary = ReadByte fstream
          fseek fstream 2 #seek_cur    
          polygon.surfaceProperty = ReadLong fstream         
          
          append geomObject.polygons polygon         
        )  
        
        nCount = ReadLong fstream
        for i = 1 to nCount do
        ( 
          unknownStr = greUnknown()
          unknownStr.polygon.name = freader.readName()
          unknownStr.polygon.collidable = ReadByte fstream
          unknownStr.polygon.carvingBoundary = ReadByte fstream
          fseek fstream 2 #seek_cur    
          unknownStr.polygon.surfaceProperty = ReadLong fstream         
          
          faceCount = ReadLong fstream
          for i = 1 to faceCount do
          ( 
            local normal = freader.readPoint4Values()          
            append unknownStr.faces normal       
          ) 
          append geomObject.unknowns unknownStr         
        )           
      )
    result = geomObject   
  )  
)

struct rseGeometryObjectWriter
(
  fstream,
  fWriter = formatWriter(fstream),
  headerWriter = rseHeaderWriter(fstream),
  fn write geomObject =
  (
    headerWriter.write geomObject.header
  )  
)