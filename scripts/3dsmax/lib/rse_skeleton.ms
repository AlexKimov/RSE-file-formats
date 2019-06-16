/*

*/

filein "max.ms"
filein "rse.ms"
filein "format_io.ms"
filein "rse_header.ms"

struct greSkeletonBones 
(
  header = greBoneHeader(),
  pos = (point3 0 0 0),
  rot = (quat 0),
  unknown = 0, -- 0 always
  connectedBones = #()
)

struct greStandardSkeleton
(   
    LToe = greSkeletonBones \ 
      header: (greBoneHeader name:"LToe") \
      pos: (point3 -0.000002 14.694002 0) \
      rot: (quat -0.005226 0.001100 -0.279779 0.960050), 
    LFoot = greSkeletonBones \    
      header: (greBoneHeader name:"LFoot") \
      pos: (point3 0 41.478004 0.000001) \
      rot: (quat 0.385773 -0.602640 -0.396968 0.574822) \
      connectedBones: #(this.LToe),              
    LCalf = greSkeletonBones \    
      header: (greBoneHeader name:"LCalf") \
      pos: (point3 0 42.314995 0) \
      rot: (quat -0.129644 0.000057 -0.001419 0.991560) \
      connectedBones: #(this.LFoot),        
    LThigh = greSkeletonBones \     
      header: (greBoneHeader name:"LThigh") \
      pos: (point3 9.383750 -5.302430 5.300977) \
      rot: (quat 0.001343 -0.030446 -0.999280 0.022589) \
      connectedBones: #(this.LCalf),    
    RToe = greSkeletonBones \   
      header: (greBoneHeader name:"RToe") \
      pos: (point3 0.000001 14.693999 0) \
      rot: (quat 0.002221 -0.005611 -0.282633 0.959209),  
    RFoot = greSkeletonBones \     
      header: (greBoneHeader name:"RFoot") \
      pos: (point3 -0.000000 41.477997 0) \
      rot: (quat 0.397610 -0.574842 -0.382379 0.604359) \
      connectedBones: #(this.RToe),   
    RCalf = greSkeletonBones \    
      header: (greBoneHeader name:"RCalf") \
      pos: (point3 0 42.315006 0) \
      rot: (quat -0.130020 -0.000260 0.003470 0.991505) \
      connectedBones: #(this.RFoot),   
    RThigh = greSkeletonBones \    
      header: (greBoneHeader name:"RThigh") \
      pos: (point3 -9.216725 -5.445369 5.266490) \
      rot: (quat 0.000672 0.030249 0.999478 0.011348) \
      connectedBones: #(this.RCalf),       
    LHand = greSkeletonBones \   
      header: (greBoneHeader name:"LHand") \
      pos: (point3 0 24.830997 0) \
      rot: (quat -0.040827 0.022137 0.007409 0.998893),
    LForearm = greSkeletonBones \ 
      header: (greBoneHeader name:"LForearm") \
      pos: (point3 0.000001 24.738003 0) \
      rot: (quat 0.027438 0.005865 0.066775 0.997373) \
      connectedBones: #(this.LHand),  
    LBicep = greSkeletonBones \       
      header: (greBoneHeader name:"LBicep") \
      pos: (point3 14.550852 14.219372 0.646667) \
      rot: (quat -0.097342 -0.132649 -0.746638 0.644562) \
      connectedBones: #(this.LForearm),     
    RHand = greSkeletonBones \    
      header: (greBoneHeader name:"RHand") \
      pos: (point3 -0.000001 24.831003 0) \
      rot: (quat -0.047018 -0.022153 -0.008743 0.998610),     
    RForearm = greSkeletonBones \   
      header: (greBoneHeader name:"RForearm") \
      pos: (point3 0.000003 24.738003 0) \
      rot: (quat 0.037969 -0.005489 -0.063353 0.997254) \
      connectedBones: #(this.RHand),   
    RBicep = greSkeletonBones \
      header: (greBoneHeader name:"RBicep") \
      pos: (point3 -14.575241 14.273071 0.632296) \
      rot: (quat -0.100116 0.128877 0.745991 0.645650) \
      connectedBones: #(this.RForearm), 	  
    Head = greSkeletonBones \
      header: (greBoneHeader name:"Head") \
      pos: (point3 0 6.271232 0) \
      rot: (quat -0.073829 0 0 0.997271),
    Neck = greSkeletonBones \    
      header: (greBoneHeader name:"Neck") \
      pos: (point3 0 5.987328 0) \
      rot: (quat -0.005415 0 0 0.999985) \
      connectedBones: #(this.Head),  
    Neck2 = greSkeletonBones \    
      header: (greBoneHeader name:"Neck2") \
      pos: (point3 0 14.517118 -0.000001) \
      rot: (quat -0.084833 0 0 0.996395) \
      connectedBones: #(this.Neck),  
    SpineTop = greSkeletonBones \  
      header: (greBoneHeader name:"SpineTop") \
      pos: (point3 0 16.473185 0) \
      rot: (quat 0.179901 0 0 0.983685) \
      connectedBones: #(this.Neck2, this.RBicep, this.LBicep),  
    SpineMid = greSkeletonBones \  
      header: (greBoneHeader name:"SpineMid") \
      pos: (point3 0 10.297239 0) \
      rot: (quat -0.106133 0 0 0.994352) \
      connectedBones: #(this.SpineTop),  
    SpineLow = greSkeletonBones \ 
      header: (greBoneHeader name:"SpineLow") \
      pos: (point3 0 6.768280 0) \
      rot: (quat 0.078576 0.000279 0.005595 0.996892) \
      connectedBones: #(this.SpineMid),  
    SpineRoot01 = greSkeletonBones \
	  header: (greBoneHeader name:"SpineRoot01") \
      pos: (point3 0 0 0) \
	  rot: (quat 0.696798 0.004018 -0.003903 0.717246) \
      connectedBones: #(this.SpineLow, this.RThigh, this.LThigh)    
)

struct greSkeletonModel
(
  rseObject,
  fn getGREBoneObject skeletalBone =
  (
    boneObject = greBone()
    boneObject.header.name = skeletalBone.name 
    boneObject.position = skeletalBone.transform.translationPart
    boneObject.rotation = skeletalBone.transform.rotationPart 
    for connectedBone in skeletalBone.children do
      append connectedBones (getBoneObject connectedBone) 
    result = boneObject    
  ),
  fn create fromSelection:false =
  (
    if rseObject != undefined then
    (
      if fromSelection then      
        nodeObject = selection[1]
      else
        nodeObject = (getNodeByName rseGlobals.greSkeletonBoneNames[1])          
      if (isKindOf rseObject greSkeleton) then
        result = this.getGREBoneObject nodeObject
    )    
  )
)

struct greSkeletonModelViewer
(
  fn createBone skeletalBone parentBoneNode: bones: =
  (   
    local transfMatrix = inverse (skeletalBone.rot as matrix3)
    transfMatrix.position = skeletalBone.pos           
    local boneNode = max.bones.create [0,0,0] [0,0,0] [0,0,0] \
      name:skeletalBone.header.name
    if parentBoneNode != unsupplied then
    (
      boneNode.parent = parentBoneNode
      boneNode.transform = transfMatrix*(parentBoneNode.transform) 
    )
    else
      boneNode.transform = transfMatrix        
    if bones != unsupplied then    
      append bones boneNode
    for skBone in skeletalBone.connectedBones do 
      if bones != unsupplied then    
        createBone skBone parentBoneNode:boneNode bones:bones
      else  
        createBone skBone parentBoneNode:boneNode     
  ),
  fn create skeletalBones =
  (
    -- root bone
    if (isKindOf skeletalBones greStandardSkeleton) then
    (
      createBone (skeletalBones.SpineRoot01)
    )
    if (isKindOf skeletalBones greSkeletonBones) then
    (
      local boneArray = #()
      createBone skeletalBones bones:boneArray
      result = boneArray
    )
  )  
)

struct rseSkeletonReader
(
  fstream,
  freader = formatReader(fstream),
  headerReader = rseHeaderReader(fstream),  
  fn readBone = 
  (
    local skBone = greSkeletonBones()    
    skBone.header = headerReader.read skBone.header
    skBone.pos = freader.readPoint3Values()
    skBone.rot = freader.readQuatValues()
    fseek fstream 4 #seek_cur
    connections = ReadLong fstream
    for i = 1 to connections do
      append skBone.connectedBones (readBone())          
    result = skBone       
  ),  
  fn readSkeleton =
  (
    result = this.readBone()     
  )
)

struct greSkeletonWriter
(
  fstream,
  fWriter = formatWriter(fstream),
  headerWriter = rseHeaderWriter(fstream),
  fn writeBone skeletonBone =
  (
    headerWriter.write skeletonBone.header
    fWriter.writePoint3Values skeletonBone.pos
    fWriter.writeHeader skeletonBone.rot
    fWriter.WriteLong skeletonBone.unknown
    for skBone in skeletonBone.connectedBones do 
      writeBone skBone
  ),
  fn writeSkeleton bonesObject =
  (
    this.writeBone bonesObject
  )
)  