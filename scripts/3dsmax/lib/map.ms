/*

*/

filein "dialogs.ms"
filein "gre.ms"
filein "gre_model.ms"
filein "utils.ms"

struct mapStrings
(
  openFileCaption = "Open map file",
  saveFileCaption = "Save map file",
  types = "Ghost Recon character (*.map)|*.map",
  errorWriteFile = "Error. Can't write to the file %s.",
  errorReadFile = "Error. Can't read from the file %s."
)

struct mapFile
(
  filestream,
  gre,  
  filename,
  boneCount = 21,
  object,
  strings = mapStrings(),
  fn readHeader =
  (
    -- just skip it, no useful information for us
    fseek filestream 4 #seek_cur
  ),
  fn readMaterialList =
  (
    gre.readSectionHeader skip:true
    object.materials = gre.readMaterials() 
    object.textures = gre.readTextures() 
  ),  
  fn readGeometryList =
  (
    gre.readSectionHeader skip:true
    object.geometryObjects = gre.readGeometryObjects()  
  ),   
  fn readFile =
  (
	try
	(
      gre = greFormats(filestream)
      readHeader()
      readMaterialList()
      readGeometryList()
      fseek 4 #seek_cur -- seems to be 0 always   
      result = true
    )	  
    catch	
    (
      dialogs.showMessage (formattedprint filename format:strings.errorReadFile)
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
    filename = fname    
  )  
)