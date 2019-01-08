/*

*/

filein "dialogs.ms"
filein "rse.ms"
filein "rse_formats_io.ms"
filein "utils.ms"

struct sobStrings
(
  openFileCaption = "Open sob file",
  saveFileCaption = "Save sob file",
  types = "Ghost Recon character (*.sob)|*.sob",
  errorWriteFile = "Error. Can't write to the file %s.",
  errorReadFile = "Error. Can't read from the file %s."
)

struct sobjectFile
(
  filestream,
  rse,  
  filename,
  object = rsSObject(),
  strings = sobStrings(),
  fn readMaterialList =
  (
    rs.readSectionHeader skip:true
    object.materials = rse.readMaterials format:rseConsts.rs
  ),  
  fn readGeometryList =
  (
    rs.readSectionHeader skip:true
    object.geometryObjects = rse.readGeometryObjects format:rseConsts.rs
  ),  
  fn readFile =
  (
	--try
	--(
      rse = rserseFormatReader filestream
      rse.ReadName() -- BeginModel string
      readMaterialList()
      readGeometryList()
      rse.ReadName() -- EndModel string      
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