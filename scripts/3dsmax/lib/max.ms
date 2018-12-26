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
  fn applyToMesh msh active:true =
  (
    skinmod = this.create()
    addModifier msh skinmod
    if active then modPanel.setCurrentObject skinmod
    result = skinmod
  ),
  fn setVertexWeight skinMod vertexId bone weight =
  (
    skinOps.SetVertexWeights skinMod vertexId bone weight
  ),
  fn addBone skinMod bone =
  (
    skinOps.addBone skinMod bone 1 
  ),
  fn addBonesToMesh msh boneArray =
  (
    skinmod = this.applyToMesh msh
    for bone in boneArray do
      this.addBone skinmod bone
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
  fn delKey controller index: =
  (
    if index == unsupplied then
    (
      deleteKeys controller #allKeys
    )  
    else
    (
      deleteKey controller index
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

struct nodOp
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
  fn getMeshVerts mesh =
  (
    vertArray = #()
    for i = 1 to mesh.numVerts do 
      append vertArray (getVert mesh i)
  	result = vertArray
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
  fn createBitmapMaterial bitmapImage =
  (
    mat = standardMaterial diffuseMap:(bitmaptexture bitmap:bitmapImage) \
      showInViewport:true
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
  fn addBitmapToMesh msh bitmapImage =
  (
  	msh.material = standardMaterial diffuseMap:(bitmaptexture bitmap:bitmapImage) showInViewport:true
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
    sme = slateMatEditor()
    bones = maxBones()
    nodes = nodOp()
    modifiers = maxModifier()  
    controller = maxController()
    animation = maxAnimation()    
	-- set viewport mod
    VP = NitrousGraphicsManager.GetActiveViewportSetting()
    VP.VisualStyleMode = VisualStyle
  ),
  on create do init()
)

max = max3ds()