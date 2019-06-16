/*
  Author: AlexKimov
  Description: Ghost Recon (2001) export script
  Version: 0.1
*/

filein "lib/ms.ms"
filein "lib/chr.ms"
filein "lib/qob.ms"
filein "lib/pob.ms"

struct strings
(
  exportDialogCaption = "Save GRE file",
  exportDialogTypes = \
    "Ghost Recon formats (*.qob;*.chr;*.pob)|*.qob;*.chr;*.pob)",
  formatsArray = #(".qob", ".chr", ".pob"),     
  buttonExportCaption = "Export",  
  scaleList = #("off", "100"),
  fileSaved = "File %s successfully saved."
)

struct exportUI
(
  strings,
  dialog = 
  (
    local owner = if owner != undefined do owner 
    dropDownList ddlist_scale items: owner.strings.scaleList width:100 
    button button_export owner.strings.buttonExportCaption width:100
    on button_export pressed do
    ( 
      owner.exportFormat()
    )    
  ),
  fn exportFormat =
  (
    dialogs.caption = strings.exportDialogCaption
    dialogs.types = strings.exportDialogTypes  
    filestream = dialogs.openFileDialog &filename "wb"        
    if filestream != undefined then     
    (
      local ext = fileUtils.getFileExtenion filename 
      file = case (ext) of
      (
        (strings.formatsArray[1]): qobjectFile()
        (strings.formatsArray[2]): characterFile()
        (strings.formatsArray[3]): pobjectFile()  
      ) 
      file.filestream = filestream
      file.filename = filename
      if file.writeFile() then
        dialogs.showMessage \
          (formattedprint filename strings.fileSaved)        
      file.closeFile()      
    )    
  ),
  fn close = try (destroyDialog dialog) catch(),  
  fn init =
  (
    createDialog dialog width:125 pos:mouse.screenpos \
      style:#(#style_toolwindow, #style_sysmenu)   
  ),
  on create do init()
)