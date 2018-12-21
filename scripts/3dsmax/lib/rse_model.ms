/*

*/

filein "max.ms"
filein "system.ms"
filein "utils.ms"
filein "rse.ms"

struct greModel
(
  object,
  isTextured = false,
  showHPs = false,
  showProgress = true,
  showSkeleton = true,
  groupObjs = true,
  texturesPath,
  scale,
  texFormat, 
  fn createSceneObject group: =
  (
    objectArray = (if group != unsupplied then group else objects)
    
    geomObject = greGeometryObject()   
      
    for obj in objectArray do 
    (   
      if classof obj == Editable_mesh then
      (
        join geomObject.vertexArray (max.getMeshVerts obj)
        geomObject.vertexArray = makeUniqueArray geomObject.vertexArray          
        mesh = greMesh()
        
        for face in faceArray do 
        (
          
        )
        
        mesh.uvArray
        mesh.uvIndexArray
        mesh.vertexNormalArray
        mesh.faceColorArray
        append geomObject.meshes mesh
        
        mat = greMaterial()
        mat.params = 
        append object.materials mat
        tex = greTexture()
        tex.params = 
        append object.textures tex
        mesh = greMesh()  
        
        append object.geometryObjects geomObject            
      )
      if classof obj == Point then
      (
      
      )            
    )  
  ),
  fn addMaterial material texture =
  (
    bitmapTexture = max.openBitmapFile \
      (texturesPath + fileUtils.getFileName (texture.header.name) + texFormat)
    --print texture.header.name
    if bitmapTexture != undefined then
    (
      mat = max.createBitmapMaterial bitmapTexture
      mat.name = material.header.name 
    )
    result = mat
  ),
  fn addMesh vArray mesh materials: =
  (
    local faceArray = mesh.faceIndexArray 

    /* 
      We need to get new vertex array that consists of mesh vertexes 
      that really belongs to mesh (vArray = every single vertex in object) and 
      change face indexes to proper ones 
    */
  
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
          local point = point3 ((vArray[index]).x*scale) \
            ((vArray[index]).y*scale) ((vArray[index]).z*scale)
          append vertArray point
          (faceArray[i])[n] = vertArray.count         
        )                   
      )  
    
    --print vertArray

    /*
      There might be difference in count between materials and textures,
        we will ignore it for now
    */
    
    if mesh.params.materialIndex >= 0 and isTextured then
    (
      tvertArray = #()  
      for i = 1 to mesh.uvIndexArray.count do 
      (      
        for n = 1 to 3 do
        (
          local index = (mesh.uvIndexArray[i])[n]
          append tvertArray mesh.uvArray[index]
        )
      )    
      msh = max.createTexturedMesh vertArray faceArray tvertArray
      max.addMaterialToMesh msh materials[mesh.params.materialIndex + 1]
    )
    else
    (
      msh = max.createMesh vertArray faceArray
    ) 
    result = msh    
  ), 
  fn addHelperPoint hpoint =
  (
    local row = point3 ((hpoint.matrix.row4.x)*scale) \
      ((hpoint.matrix.row4.y)*scale) ((hpoint.matrix.row4.z)*scale)
    hpoint.matrix.row4 = row      
    result = max.createHelperPoint hpoint.name transformMatrix:hpoint.matrix
  ), 
  fn createBone rootBone node boneArray =
  (  
    for bone in rootBone.connectedBones do
    (   
      local transfMatrix = inverse (bone.rotation as matrix3)
      transfMatrix.position = (bone.position) 
            
      boneNode = max.bones.create [0,0,0] [0,0,0] [0,0,0] name:bone.header.name   
      boneNode.parent = node      
      boneNode.transform = transfMatrix*node.transform 
      append boneArray boneNode       
      createBone bone boneNode boneArray
    )   
  ),
  fn createSkeleton =
  (
    -- root bone
    boneArray = #()
    local rootBone = object.bones
    boneNode = max.bones.create [0,0,0] [0,0,0] [0,0,0] name:rootBone.header.name
    local transfMatrix = (rootBone.rotation as matrix3)
    transfMatrix.position = (rootBone.position)   
    boneNode.transform = inverse transfMatrix
    append boneArray boneNode
    createBone rootBone boneNode boneArray
    result = boneArray
  ), 
  fn setVertexWeights meshArray bones =
  (
    for msh in meshArray do
    (
      skinmod = max.modifiers.skin.addBonesToMesh msh bones
      for vertex in object.vertexWeights do
      (   
        for i = 1 to vertex.bones.count do
          for bone in bones where (bone.name == vertex.bones[i].name) do
            max.modifiers.skin.setVertexWeight skinMod vertex.vertexIndex \
              bone vertex.bone[i].weight  
      )        
    )
  ), 
  fn createNode node nodeGroup =
  (
    for childNode in node.childNodes do
    (    
      if node.header.id == 47 then
      (
        objNode = max.nodes.GetNode node.header.name
        if objNode != undefined then
        (      
          objNode.transform = node.matrix
          max.nodes.addToGroup objNode nodeGroup
        )
      )  
      createNode childNode nodeGroup 
    )    
  ),
  fn createNodesHierarchy =
  (
    node = object.nodes
    originPoint = max.createHelperPoint "origin"
    nodeGroup = max.nodes.createGroup HP node.header.name opened:true
    nodeGroup.transform = node.matrix    
    createNode node nodeGroup
  ),
  fn createScene =
  (
    if isTextured then 
    (
      local matCount = object.materials.count
      mats = #()
      max.sme.open()
      smeView = max.sme.createView "Materials"
      for i = 1 to matCount do
      (
        mat = addMaterial object.materials[i] object.textures[i]
        max.sme.createNode mat smeView [0, i*100]
        append mats mat
      )  
      max.sme.close()
      --print mats    
    ) 
    
    progressStart "creating meshes"
    local meshCount = 0    
    for object in object.geometryObjects do
    (
      meshCount += object.meshes.count  
    )  
    progress = (100.0/meshCount as float)          
    
    meshArray = #()
    
    with redraw off
    for object in object.geometryObjects do
    (  
      objArray = #()     
      for i = 1 to object.meshes.count do 
      (
        if isTextured then
          msh = addMesh object.vertexArray object.meshes[i] materials:mats
        else
          msh = addMesh object.vertexArray object.meshes[i]

        append objArray msh     
        progressUpdate (progress*i) 
        if getProgressCancel() then 
        (
          setProgressCancel true  
          exit        
        )
      )
      if (isKindOf this.object grePObject) or (isKindOf this.object greMapObject) then
      (
        for tagPoint in object.tagPoints do
        (
          hp = addHelperPoint tagPoint
          append objArray hp           
        ) 
      )     
      meshArray = objArray      
      if objArray.count > 0 then
        max.nodes.createGroup objArray object.header.name opened:true         
    )
    progressEnd()
    
    if (isKindOf object greQObject) and object.points.count > 0 and showHPs then
    (
      local pCount = object.points.count       
      for i = 1 to pCount do
      (
        hpoint = addHelperPoint object.points[i] 
        if hpoint != undefined and groupObjs then
          append objArray hpoint        
      )  
    ) 
    
    if (isKindOf object greCharacterModel) and showSkeleton then
    (
      boneArray = createSkeleton()
      setVertexWeights meshArray boneArray  
    ) 
     
    if (isKindOf this.object grePObject) or \
      (isKindOf this.object greMapObject) then 
    (
      createNodesHierarchy()
    )    

    redrawViews()    
  )
)