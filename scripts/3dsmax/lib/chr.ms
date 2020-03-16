/*

*/

filein "dialogs.ms"
filein "rse.ms"
filein "rse_formats_io.ms"
filein "utils.ms"
filein "system.ms"

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
  strings = chrStrings(),
  rseObject = greCharacterModel(),
  fstream,
  filename,
  freader,
  fwriter,   
  fn readHeader =
  (
    -- just skip it, no useful information for us
    fseek fstream 4 #seek_cur
  ),
  fn readMaterialList =
  (
    if (ftell fstream) == 0 then
      setSectionOffset 1
    freader.readSectionHeader (greMaterialHeader())
    rseObject.materials = freader.readMaterials() 
    rseObject.textures = freader.readTextures()  
  ),  
  fn readGeometryList =
  (
    if (ftell fstream) == 0 then
      setSectionOffset 2  
    freader.readSectionHeader (greTextureHeader())
    rseObject.geometryObjects = freader.readGeometryObjects()
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
      fseek fstream 19 #seek_cur
      freader.skipSection()
    ) 
    if sectionIndex == 3 then
    (
      fseek fstream 19 #seek_cur
      freader.skipSection()
      freader.skipSection()
      fseek fstream 13 #seek_cur   
    )    
  ),
  fn readSkeleton =
  ( 
    if (ftell fstream) == 0 then
      setSectionOffset 3
    rseObject.bones = freader.readSkeleton()  
  ),  
  fn readWeights =
  (  
    rseObject.weights = freader.readVertexWeights()
  ),   
  fn readFile =
  (
	--try
	--(
      readHeader()
      freader.readName() -- BeginModel string
      readMaterialList()
      readGeometryList()
      fseek fstream 4 #seek_cur -- it seems to be 0 always
      freader.readName() -- EndModel string
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
  fn writeHeader =
  (
    WriteLong fstream sys.utils.getDateTimeinSeconds()
  ),
  fn writeMaterialList =
  (
    fwriter.writeHeader header
    fwriter.writeMaterials rseObject.materials
    fwriter.writeTextures rseObject.textures
  ),
  fn writeGeometryList =
  (
    fwriter.writeHeader header
    fwriter.writeGeometryrseObjects rseObject.geometryrseObjects
  ),
  fn writeSkeleton =
  (
    skeleton.writeSkeleton rseObject.bones
  ),
  fn writeVertexWeights =
  (
    skeleton.writeVertexWeights rseObject.vertexWeights 
  ), 
  fn writeFile =
  (  
    writeHeader()
    fwriter.writeName "BeginModel"
    writeMaterialList()
    writeGeometryList() 
    WriteLong fstream 0
    fwriter.writeName "EndModel" 
    writeSkeleton() 
    writeVertexWeights()
    result = true    
  ),
  fn closeFile =
  (
    fclose fstream
  ),
  fn openStream fstream filename =
  (
    this.fstream = fstream
    this.filename = filename
    freader = rseFormatReader(fstream)
    writer = rseFormatWriter(fstream)    
  ),   
  fn openFile mode fname:"" =
  (
    dialogs.types = strings.types
    if mode == "rb" then
      dialogs.caption = strings.openFileCaption
    else
      dialogs.caption = strings.saveFileCaption

    fstream = dialogs.openFileDialog fname mode
    if fstream != undefined then
    (
      filename = fname
      freader = rseFormatReader(fstream)
      fwriter = rseFormatWriter(fstream)  
    )  
    result = fstream
  )  
)