/*

*/

filein "dialogs.ms"
filein "gre.ms"
filein "gre_model.ms"
filein "utils.ms"

struct pobStrings
(
  openFileCaption = "Open pob file",
  saveFileCaption = "Save pob file",
  types = "Ghost Recon character (*.pob)|*.pob",
  errorWriteFile = "Error. Can't write to the file %s.",
  errorReadFile = "Error. Can't read from the file %s."
)

struct pobjectFile
(
  filestream,
  gre,  
  filename,
  object = grePObject(),
  strings = pobStrings(),
  fn readHeader =
  (
    -- just skip it, no useful information for us
    fseek filestream 21 #seek_cur
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
    object.geometryObjects = gre.readGeometryObjects extData:true 
  ), 
  fn readObjectList =
  (
    gre.readSectionHeader skip:true
    object.nodes = gre.readObjectNodes()   
  ),   
  fn readFile =
  (
	--try
	--(
      gre = greFormats(filestream)
      readHeader()
      gre.ReadName() -- BeginModel string
      readMaterialList()
      readGeometryList()
      gre.ReadName() -- EndModel string     
      readObjectList()  
      result = true
    --)	  
    --catch	
    --(
     -- dialogs.showMessage (formattedprint filename format:strings.errorReadFile)
     -- result = false
    --)  
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