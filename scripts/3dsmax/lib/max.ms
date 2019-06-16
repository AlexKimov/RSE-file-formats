/*
  Description:
  3ds max objects
*/

filein "dialogs.ms"

struct maxStrings 
(
  lang = "Eng",
  errorVertNumber = "Error. Number of vertexes of the mesh is less than %d.",
  fn loadFromIni filename =
  (
    local strings = settings(this)
    strings.loadFromIniFile filename lang
  )
)

struct maxAnimation
(
  fn setLength length =
  (
    animationRange = interval 0 length
  )
)

struct skinModifier
(
  fn create =
  (
    result = skin()
  ),
  fn applyToMesh msh =
  (
    skinmod = this.create()
    addModifier msh skinmod
    setCommandPanelTaskMode #modify
    modPanel.setCurrentObject skinmod
    result = skinmod
  ),
  fn setVertexWeight skinMod vertexId boneID vertexWeight =
  (
    skinOps.replaceVertexWeights skinMod vertexId boneID vertexWeight
  ),
  fn addBone skinMod skeletonBone =
  (
    skinOps.addBone skinMod skeletonBone 1 
  ),
  fn attachBonesToMesh msh boneArray =
  (
    skinmod = this.applyToMesh msh
    for skeletonBone in boneArray do
      this.addBone skinmod skeletonBone  
    modPanel.setCurrentObject skinmod       
    result = skinmod 
  )  
)

struct maxController
(
  fn addKey controller time value: =
  (
    key = addNewKey controller time
    if value != unsupplied then
      key.value = value
  ),
  fn deleteAllKeys controller =
  (
    deleteKeys controller #allKeys 
  ),
  fn deleteKeysByRange controller startFrame endFrame =
  (
  	for x in controller.keys.count to 1 by -1 do
  	(
  	  if (controller.keys[x].time >= startFrame) and \
        (controller.keys[x].time <= endFrame) do 
        deleteKey controller x
  	)
  )  
)

struct maxModifier
(
  skin = skinModifier()
)

struct maxBones
(
  fn create startPos endPos axis name: = 
  (
    bone = BoneSys.createBone startPos endPos axis
    if name != unsupplied then
      bone.name = name
    bone.width = 1
    bone.height = 1
    bone.taper = 100
    bone.wirecolor = yellow
    bone.showlinks = true
    bone.position.controller = linear_position()
    bone.rotation.controller = linear_rotation()
    result = bone  
  )
)

struct maxNodeOp
(
  fn addToGroup obj objs =
  (
    attachNodesToGroup obj objs
  ),
  fn createGroup objs name opened:false =
  (
    groupNode = Group objs name:name
    if opened then
      this.openGroup groupNode
    result = groupNode
  ),
  fn openGroup group =
  (  
    setGroupOpen group true
  ),
  fn closeGroup group =
  (  
    setGroupOpen group false
  ),  
  fn getNode name =
  (
    result = getnodebyname name exact:true
  )  
)

struct slateMatEditor
(
  fn open =
  (
    sme.Open()
  ),
  fn close =
  (
    sme.Close()
  ), 
  fn createView caption =
  ( 
    local index = sme.GetViewByName caption
    if index > 0 then
      result = sme.GetView index
    else
      result = sme.GetView(sme.CreateView caption)   
  ),
  fn createNode material view pos =
  (
    result = view.CreateNode material pos
  )  
)

struct maxMaterial
(
  fn createMaterialFromBitmap filename =
  (
    bitmapTexture = this.openBitmapFile fileName
    if bitmapTexture != undefined then
    (
      mat = this.createBitmapMaterial bitmapTexture
      mat.name = material.header.name 
      result = mat
    )     
  ),
  fn createBitmapBlendMaterial bitmapImageArray =
  (  
    blendmat = blend
    blendmat.map1 = standardMaterial \
      diffuseMap:(bitmaptexture bitmap:bitmapImageArray[1]) showInViewport:true
    blendmat.map2 = standardMaterial \
      diffuseMap:(bitmaptexture bitmap:bitmapImageArray[2]) showInViewport:true 
    blendmat.mask = gradient  
    result = blendmat    
  ),  
  fn createBitmapMultiMaterial bitmapImageArray isTexBlended =
  (  
    if isTexBlended then
      numsubs = bitmapImageArray.count + 1
    else
      numsubs = bitmapImageArray.count
    multimat = multimaterial numsubs:numsubs
    for i = 1 to bitmapImageArray.count do
      multimat[i] = standardMaterial \
      diffuseMap:(bitmaptexture bitmap:bitmapImageArray[i]) showInViewport:true
    if isTexBlended != unsupplied and isTexBlended then
      multimat[multimat.count + 1] = createBitmapBlendMaterial bitmapImageArray
    result = multimat  
  ),
  fn addMaterialToMesh msh mat =
  (
  	msh.material = mat
  ),  
  fn openBitmapFile filename =
  (
    --try
    --(
      openBitMap filename
    --)  
    --catch
    --(
    --  messageBox ("Can't open bitmap file " + filename + ".")
    --  result = undefined
    --)  
  ),
  fn createBitmapMaterial bitmapImage =
  (
    result = standardMaterial diffuseMap:(bitmaptexture bitmap:bitmapImage) \
      showInViewport:true
  ),  
  fn createBitmap imageData imageWidth imageHeight filename =
  (
  	b = bitmap imageWidth imageHeight color:white 
	b.filename = filename + ".bmp"
    for line = 0 to (imageHeight - 1) do
    (
      row = #()
      for col = (line*imageWidth + 1) to (line + 1)*imageWidth do 
        append row imageData[col]
      setPixels b [0, line] row
    )       
    save b    
	result = b
  ),
  fn addBitmapToMesh msh bitmapImage =
  (
  	msh.material = standardMaterial \
      diffuseMap:(bitmaptexture bitmap:bitmapImage) showInViewport:true
  )    
)

struct max3ds
(
  strings,
  VisualStyle = #Shaded,
  sme,
  bones,
  nodes,
  modifiers, 
  controller,
  animation,
  material,
  fn setUnits unitsSystem type =
  (
    units.DisplayType = unitsSystem
    if unitsSystem == #Metric then
      units.MetricType = type
  ),
  fn getBoundPoints mesh =
  (
    boundPoint = #()
    append boundPoint mesh.max
	append boundPoint mesh.min
	boundPoint
  ),
  fn getMeshDimension msh =
  (
    meshDimensions = msh.max - msh.min
  ),
  fn getMeshVertCount msh =
  (
    result = getNumVerts msh 
  ),
  fn getMeshVerts msh =
  (
    result = (for i = 1 to msh.numVerts collect (getVert msh i))
  ),
  fn getFaceColor mesh =
  (
    faceColorArray = #()
    for i = 1 to mesh.numVerts do 
      append vertArray (getVert mesh i)
  	result = faceColorArray
  ),  
  fn createPlaneMesh size pos name =
  (
    vertArray = #([0, 0, 0], [size.x, 0, 0], [0, size.y, 0], [size.x, size.y, 0])
    faceArray = #([1, 2, 3], [2, 4, 3])
    idArray = #(1, 1)
    tvertArray = #([0, 0, 0], [1, 0, 0], [0, 1, 0], [1, 1, 0]) 
    msh = max.createTexturedMesh vertArray faceArray idArray tvertArray name
    if msh != undefined then
    (
      msh.pos = pos
      result = msh
    )
  ),  
  fn createMesh vertArray faceArray name: =
  (
    try
	(
      msh = mesh vertices:vertArray faces:faceArray
      if name != unsupplied and name != "" then      
        msh.name = name  
      result = msh		
	)
	catch 
	(
	  messageBox ("ERROR. Can't create mesh: " + name + ".")
    )  	
  ), 
  fn createTexturedMesh vertArray faceArray tvertArray idArray: name: =
  (
    try
	(        
      if idArray == unsupplied then
        msh = mesh vertices:vertArray faces:faceArray tverts:tvertArray
      else      
        msh = mesh vertices:vertArray faces:faceArray materialIDS:idArray \
          tverts:tvertArray
    ) 
	catch 
	(
	  messageBox ("ERROR. Can't create mesh: " + name + ".")
      return undefined
    )
    
    buildTVFaces msh.mesh
    for i = 1 to msh.mesh.numfaces do 
      (setTVFace msh.mesh i (getFace msh.mesh i)) 
    if name != unsupplied and name != "" then      
      msh.name = name 
    result = msh			
  ),
  fn cloneMesh msh pos nodes =
  (
    maxOps.CloneNodes msh offset:pos expandHierarchy:false cloneType:#copy \
      newNodes:&nodes 
  ),
  fn moveMesh msh pos = 
  (
    move msh pos
  ),
  fn rotateMesh msh angles =
  (
    rotate msh angles
  ),
  fn copyMesh msh =
  (
    mshCopy = copy msh
	mshCopy
  ),
  fn attachMesh srcMesh dstMesh =
  (
    meshop.attach srcMesh dstMesh
  ),
  fn sliceMesh msh planeNormal planePos =
  (
  	local offset = dot planeNormal (planePos - (msh.pos * inverse msh.transform * msh.objecttransform))
  	meshop.slice msh #all planeNormal offset delete:true
  	update msh
  ),
  fn createHelperPoint name transformMatrix:(matrix3 1) =
  (
    hpoint = point()
    hpoint.name = name
    hpoint.transform = transformMatrix
    result = hpoint
  ), 
  fn init =
  (
    if strings == undefined then
      strings = maxStrings()
    this.sme = slateMatEditor()
    this.bones = maxBones()
    this.nodes = maxNodeOp()
    this.modifiers = maxModifier()  
    this.controller = maxController()
    this.animation = maxAnimation()
    this.material = maxMaterial() 
	-- set viewport mod
    VP = NitrousGraphicsManager.GetActiveViewportSetting()
    VP.VisualStyleMode = VisualStyle
  ),
  on create do init()
)

max = max3ds()