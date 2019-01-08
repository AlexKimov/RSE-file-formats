/*

*/

filein "dialogs.ms"
filein "rse.ms"
filein "rse_formats_io.ms"
filein "utils.ms"

struct bmfStrings
(
  openFileCaption = "Open chr file",
  saveFileCaption = "Save chr file",
  types = "Ghost Recon character animation (*.bmf)|*.bmf",
  errorWriteFile = "Error. Can't write to the file %s.",
  errorReadFile = "Error. Can't read from the file %s."
)

struct boneMovementsFile
(
  filename,
  filestream,
  reader,   
  object = greCharacterAnimations(),
  strings = bmfStrings(),  
  fn readHeader =
  (
    object.framesPerMin = ReadFloat filestream
    object.frameCount = ReadLong filestream
    object.boneCount = ReadLong filestream    
  ),
  fn readBoneAnimations =
  (
    for i = 1 to object.boneCount do 
    (
      boneAnimation = greBoneAnimation()
      boneAnimation.name = reader.readName()
      count = ReadLong filestream
      for frame = 1 to count do
      (
        posKey = grePosKey()
        posKey.frame = ReadLong filestream
        posKey.position = reader.readPoint3Values()
        append boneAnimation.positionKeys posKey
      )
      count = ReadLong filestream
      for frame = 1 to count do
      (
        rotKey = greRotKey()
        rotKey.frame = ReadLong filestream
        rotKey.rotation = reader.readQuatValues()
        append boneAnimation.rotationKeys rotKey      
      )  
      append object.boneAnimations boneAnimation         
    )
  ),  
  fn readFile =
  (
    readHeader()
    readBoneAnimations()   
    result = true  
  ),
  fn writeFile =
  (
    --writeHeader()
    --writeAnimations()
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
    reader = formatReader(filestream)   
    result = filestream      
  )   
)