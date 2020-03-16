/*

*/

filein "rse.ms"
filein "rse_formats_io.ms"
filein "utils.ms"
filein "dialogs.ms"

struct bmfStrings
(
  openFileCaption = "Open bmf file",
  saveFileCaption = "Save bmf file",
  types = "Ghost Recon character animation (*.bmf)|*.bmf",
  errorWriteFile = "Error. Can't write to the file %s.",
  errorReadFile = "Error. Can't read from the file %s."
)

struct boneMovementsFile
(
  strings = bmfStrings(),
  rseObject = greSkeletonAnimations(), 
  filename,  
  fstream,
  freader,
  fwriter,   
  fn readHeader =
  (
    rseObject.time = ReadFloat fstream
    rseObject.frameCount = ReadLong fstream    
  ),
  fn readAnimations =
  (
    rseObject.skeletonAnimations = freader.readSkeletonAnimations()
  ),  
  fn readFile =
  (
    readHeader()
    readAnimations()   
    result = true  
  ),
  fn writeHeader = 
  (
    WriteFloat fstream rseObject.time
    WriteLong fstream rseObject.frameCount 
  ),
  fn writeAnimations = 
  (
    fwriter.writeSkeletonAnimations rseObject.skeletonAnimations
  ),  
  fn writeFile =
  (
    writeHeader()
    writeAnimations()
    result = true
  ),
  fn closeFile =
  (
    fclose fstream
  ),
  fn openStream fstream =
  (
    this.fstream = fstream
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