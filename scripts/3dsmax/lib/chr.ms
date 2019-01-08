/*

*/

filein "dialogs.ms"
filein "rse.ms"
filein "rse_formats_io.ms"
filein "utils.ms"

struct chrStrings
(
  openFileCaption = "Open chr file",
  saveFileCaption = "Save chr file",
  types = "Ghost Recon character (*.chr)|*.chr",
  errorWriteFile = "Error. Can't write to the file %s.",
  errorReadFile = "Error. Can't read from the file %s."
)

struct characterFile
(
  filestream,
  rse,  
  filename,
  object = greCharacterModel(),
  strings = chrStrings(),
  fn readHeader =
  (
    -- just skip it, no useful information for us
    fseek filestream 4 #seek_cur
  ),
  fn readMaterialList =
  (
    rse.readSectionHeader skip:true
    object.materials = rse.readMaterials() 
    object.textures = rse.readTextures() 
  ),  
  fn readGeometryList =
  (
    rse.readSectionHeader skip:true
    object.geometryObjects = rse.readGeometryObjects()  
  ),
  fn readBone =
  (
    local bone = greCharacterBones()    
    bone.header = rse.readSectionHeader skipSize:true
    bone.position = rse.readPos()
    bone.rotation = rse.readRot()
    fseek filestream 4 #seek_cur
    connections = ReadLong filestream
    for i = 1 to connections do
      append bone.connectedBones (readBone())          
    result = bone     
  ),
  fn setSectionOffset sectionIndex =
  (
    /* sectionIndex:
       1 - materials 
       2 - geometry 
       3 - skeleton
    */
    if sectionIndex == 1 then
      result = 19
    if sectionIndex == 2 then
    (
      fseek filestream 19 #seek_cur
      rse.skipSection()
    ) 
    if sectionIndex == 3 then
    (
      fseek filestream 19 #seek_cur
      rse.skipSection()
      rse.skipSection()
      fseek filestream 13 #seek_cur   
    )    
  ),
  fn readSkeleton =
  ( 
    if (ftell filestream) == 0 then
      setSectionOffset 3
    object.bones = readBone()     
  ),  
  fn readWeights =
  (
    fseek filestream 13 #seek_cur
    rse.readName()    
    vertexCount = ReadLong filestream
    for i = 1 to vertexCount do
    (
      vertexWeight = greVertexWeight()
      vertexWeight.vertexIndex = ReadLong filestream 
      boneCount = ReadLong filestream
      for i = 1 to boneCount do
      (
        local weightedBone = greWeightedBone()
        weightedBone.name = rse.readName()
        weightedBone.weight = ReadFloat filestream       
        append vertexWeight.bones weightedBone
      )  
      append object.vertexWeights vertexWeight 
    )
  ),   
  fn readFile =
  (
	--try
	--(
      readHeader()
      rse.ReadName() -- BeginModel string
      readMaterialList()
      readGeometryList()
      fseek filestream 4 #seek_cur -- seems to be 0 always
      rse.ReadName() -- EndModel string
      readSkeleton()
      readWeights()      
      result = true
    --)	  
    --catch	
    --(
      --dialogs.showMessage (formattedprint filename --format:strings.errorReadFile)
      --result = false
   -- )  
  ),
  fn closeFile =
  (
    fclose filestream
  ),
  fn openFile mode =
  (
    dialogs.types = strings.types
    if mode == "rb" then
      dialogs.caption = strings.openFileCaption
    else
      dialogs.caption = strings.saveFileCaption
    local fname = filename
    filestream = dialogs.openFileDialog &fname mode
    filename = fname
    rse = rseFormatReader(filestream)   
    result = filestream    
  )  
)