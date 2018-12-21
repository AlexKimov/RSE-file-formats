/*

*/

filein "lib/ms.ms"
filein "lib/sob.ms"
filein "lib/rs_model.ms"
filein "lib/dialogs.ms"
filein "lib/system.ms"

struct settingsImportUI
(
  p
)

struct stringsImportUI
(
  importDialogCaption = "Open RS file",
  importDialogTypes = "Rainbow six 1/2 formats (*.sob)|*.sob",
  rolloutTitle = "Import RS file"
)

struct sobImportUI
(
  settings,
  strings,
  model,
  fn importModel filename: =
  (    
    if filename == unsupplied then
    (
      dialogs.caption = strings.importDialogCaption
      dialogs.types = strings.importDialogTypes  
      dialogs.openFileDialog &fname "rb" 
      filename = fname       
    )  
    if filename != undefined then 
    (    
      local ext = fileUtils.getFileExtenion filename 
      rsfile = case (ext) of
      (
        (strings.formatsArray[1]): sobjectFile()       
      )
      rsfile.filename = filename
      rsfile.object.name = fileUtils.getFileName filename
      if rsfile.openFile("rb") != undefined then
      (
        if rsfile.readFile() then
        (
          getFileInformation rsfile
          model = greModel rsfile.object
          setUnits (strings.unitsList[settings.unitsType] as Name)
          model.createScene()       
        )
      )        
      file.closeFile()        
    )    
  ),
  dialog = 
  (
    rollout dialog strings.rolloutTitle
    (
      local owner = if owner != undefined do owner
      button button_import owner.strings.buttonCaption width:100
      on button_import pressed do
      (
        owner.importModel() 
      )      
    )
  )    
  fn close = try (destroyDialog dialog) catch(),  
  fn init =
  (
    if settings == undefined then
      settings = settingsImportUI()
    if strings == undefined then  
      strings = stringsImportUI()
    dialog.owner = this    
    createDialog dialog width:125 pos:mouse.screenpos \
      style:#(#style_toolwindow, #style_sysmenu)     
  ),
  on create do init()  
)

fn main = 
(
  sys.currentPath = fileUtils.getCurrentPath(getThisScriptFilename())
  importUI = sobImportUI()
)

main()