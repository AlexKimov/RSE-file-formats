/*

*/

filein "max.ms"
filein "system.ms"
filein "utils.ms"
filein "rse.ms"

struct rseViewerSettings
(
  isTextured = false,
  showHPs = false,
  showProgress = true,
  showSkeleton = true,
  groupObjs = true,
  texturesPath,
  scale = 1,
  texFormat 
)

struct rseViewer
(
  rseObject,
  settings = rseViewerSettings(),
  meshViewer = rseMeshViewer(),
  skeletonViewer = greSkeletonModelViewer(),
  skeletonAnimationViewer = rseSkeletonAnimationViewer(),
  fn addMaterial material texture =
  (
    bitmapTexture = max.createMaterialFromBitmap \
      (settings.texturesPath + \
      fileUtils.getFileName (texture.header.name) + \
      settings.texFormat)
  ),
  fn addMesh vArray msh mats: =
  (
    if mats == unsupplied then
      newMesh = meshViewer.create vArray msh
    else
      newMesh = meshViewer.create vArray msh materials:mats 
    newMesh.scale = [settings.scale, settings.scale, settings.scale]
    result = newMesh    
  ), 
  fn addModel model mats: =
  (
    if mats == unsupplied then
      newMesh = meshViewer.create vArray msh
    else
      newMesh = meshViewer.create vArray msh materials:mats 
    newMesh.scale = [settings.scale, settings.scale, settings.scale]
    result = newMesh    
  ),  
  fn addHelperPoint hpoint =
  (
    pointNode = max.createHelperPoint hpoint.name transformMatrix:hpoint.matrix
    pointNode.scale = [settings.scale, settings.scale, settings.scale]
    result = pointNode
  ), 
  fn createSkeleton =
  (
    result = skeletonViewer.create (rseObject.bones)
  ), 
  fn setVertexWeights meshArray bones =
  (
    --for msh = 1 to meshArray.count do
    --(
      meshVertexes = max.getMeshVerts meshArray[1]
      skinmod = max.modifiers.skin.attachBonesToMesh meshArray[1] bones      
      for vertIndex = 1 to meshVertexes.count do
      (
        index = findItem rseObject.geometryObjects[1].vertexArray \
          meshVertexes[vertIndex] 
        print index          
        vertexWeights = rseObject.weights.weightTable[index]
        vertexBoneArray = #() 
        weightArray = #() 
        local boneName = ""        
        for i = 1 to vertexWeights.weights.count do
        (      
          --if boneName == vertexWeights.weights[i].boneName then
          --(
            --boneIndex = findItem rseGlobals.greSkeletonBoneNames "RHand"
            --append vertexBoneArray boneIndex
            --append weightArray vertexWeights.weights[i].weight             
            --weightArray[i - 1] += vertexWeights.weights[i].weight
            --print boneName
          --)  
          --else
          --(          
            boneIndex = findItem rseGlobals.greSkeletonBoneNames \
              (vertexWeights.weights[i].boneName)           
            append vertexBoneArray boneIndex
            append weightArray vertexWeights.weights[i].weight  
          --)  
          boneName = vertexWeights.weights[i].boneName
          --print vertexWeights.weights[i].weight          
        )  
        max.modifiers.skin.setVertexWeight skinMod vertIndex vertexBoneArray \
          weightArray
        --skinOps.unNormalizeVertex skinMod vertIndex true           
      )         
    --)
  ),
  fn addSkeletonAnimation =
  (
    skeletonAnimationViewer.create (rseObject.skeletonAnimations)  
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
    node = rseObject.nodes
    originPoint = max.createHelperPoint "origin"
    nodeGroup = max.nodes.createGroup HP node.header.name opened:true
    nodeGroup.transform = node.matrix    
    createNode node nodeGroup
  ),
  fn createScene =
  (
    with undo off, redraw off
	(
      if settings.isTextured then 
      (
        local matCount = rseObject.materials.count
        mats = #()
        max.sme.open()
        smeView = max.sme.createView "Materials"
        for i = 1 to matCount do
        (
          mat = addMaterial rseObject.materials[i] rseObject.textures[i]
          max.sme.createNode mat smeView [0, i*100]
          append mats mat
        )  
        max.sme.close()   
      ) 
    
      progressStart "creating meshes"
      local meshCount = 0    
      for object in rseObject.geometryObjects do
      (
        meshCount += object.meshes.count  
      )  
      progress = (100.0/meshCount as float)          
    
      meshArray = #()
    
      for rseObject in rseObject.geometryObjects do
      (  
        objArray = #()     
        for i = 1 to rseObject.meshes.count do 
        (
      
          if settings.isTextured then
            msh = addMesh rseObject.vertexArray rseObject.meshes[i] materials:mats
          else
            msh = addMesh rseObject.vertexArray rseObject.meshes[i]

          append objArray msh     
          progressUpdate (progress*i) 
          if getProgressCancel() then 
          (
            setProgressCancel true  
            exit        
          )
        )
        if (isKindOf this.rseObject grePrseObject) or (isKindOf this.rseObject greMaprseObject) then
        (
          for tagPoint in rseObject.tagPoints do
          (
            hp = addHelperPoint tagPoint
            append objArray hp           
          ) 
        )     
        meshArray = objArray      
        if objArray.count > 0 then
          max.nodes.createGroup objArray rseObject.header.name opened:true         
      )
      progressEnd()
    
      if (isKindOf rseObject greQObject) and settings.showHPs \
        and rseObject.points.count > 0 then
      (
        local pCount = rseObject.points.count       
        for i = 1 to pCount do
        (
          hpoint = addHelperPoint rseObject.points[i] 
          if hpoint != undefined and settings.groupObjs then
            append objArray hpoint        
        )  
      ) 
    
      if (isKindOf rseObject greCharacterModel) and settings.showSkeleton then
	    createSkeleton()
        --setVertexWeights meshArray (createSkeleton())
     
      if (isKindOf this.rseObject grePrseObject) or \
        (isKindOf this.rseObject greMaprseObject) then 
      (
        createNodesHierarchy()
      )    
    )
	
    redrawViews()    
  )
)