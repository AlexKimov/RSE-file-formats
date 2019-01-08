/*
  Author: AlexKimov
  Version: 0.1
  Description: 
*/

filein "rse.ms"
filein "rse_model.ms"
filein "dialogs.ms"
filein "utils.ms"

struct qobStrings
(
  openFileCaption = "Open qob file",
  saveFileCaption = "Save qob file",
  types = "Ghost recon object (*.qob)|*.qob",
  errorWriteFile = "Error. Can't write to the file %s.",
  errorReadFile = "Error. Can't read from the file %s.",
  cantOpenFile = "Error. Can't open file %s."
)

struct qobjectFile
(
  filestream,
  gre,  
  filename,
  object,
  strings = qobStrings(),
  fn readHeader =
  (
    -- just skip it, no useful information for us
    fseek filestream 15 #seek_cur
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
  fn readPoints =
  (
    pointCount = ReadLong filestream
    if (pointCount > 0) then
      for i = 1 to pointCount do
      (
        fseek filestream 4 #seek_cur
        local point = grePoint()
        point.name = readString filestream
        point.matrix = rse.readMatrix()
        append object.points point
        --print point
      )    
  ),  
  fn writeHeader =
  (
    WriteLong filestream 8
    WriteString filestream "BeginModel"
  ),
  fn writeMaterialList =
  (
    header = greMaterialListHeader()
    rse.writeSectionHeader header
    rse.writeMaterials object.materials
    rse.writeTextures object.textures
  ),
  fn writeGeometryList =
  (
    header = greGeometryListHeader()
    rse.writeSectionHeader header 
    rse.writeGeometryObjects() object.geometryObjects  
  ), 
  fn writePoints =
  (
    pointCount = object.points.count
    for i = 1 to pointCount do
    (
      name = object.points[i].name
      WriteLong filestream name.length
      WriteString filestream name
      rse.writeMatrix() object.points[i].matrix
    )      
  ),   
  fn readFile =
  (
	try
	(
      rse = greFormats(filestream)
      readHeader()
      readMaterialList()
      readGeometryList()
      readPoints()      
      result = true
    )	  
    catch	
    (
      dialogs.showMessage (formattedprint filename format:strings.errorReadFile)
      result = false
    )  
  ),
  fn writeFile =
  (
	try
	(
      --TODO: export data to .qob file
      object.name = fileUtils.getFileName filename
      writeHeader()
      writeMaterialList()
      writeGeometryList()
      writePoints()
    )	  
    catch	
    (
      dialogs.showMessage (formattedprint filename format:strings.errorWriteFile)
      result = false
    )  
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
    if filestream == undefined then
      dialogs.showMessage (formattedprint "filename" format:strings.cantOpenFile)
    else
    (     
      filename = fname
      result = filestream
    )      
  )  
)