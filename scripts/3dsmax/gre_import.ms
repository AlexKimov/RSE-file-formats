/*
  Author: AlexKimov
  Description: Ghost Recon (2001) .qob files import script
  Version: 0.1
*/

filein "lib/ms.ms"
--filein "lib/qob.ms"
filein "lib/chr.ms"
--filein "lib/pob.ms"
--filein "lib/map.ms"
filein "lib/rse_model.ms"
filein "lib/dialogs.ms"
filein "lib/system.ms"

struct settingsImportUI
(
  isTextured = false,
  showHPs = true,
  showSkeleton = true,
  groupObjs = true,   
  unitsType = 3,
  path = "",
  scaleCoeff = 1,
  texFormatExt = ".bmp",
  procSubfolders = false,
  fn loadFromIni filename =
  (
    local settings = settings(this)
    settings.loadFromIniFile filename "settings"
  )   
)

struct stringsImportUI
(
  importDialogCaption = "Open GRE file",
  importDialogTypes = \
    "Ghost Recon formats (*.qob;*.chr;*.pob;*map;*.bmf)|*.qob;*.chr;*.pob;*map;*.bmf",
  formatsArray = #(".qob", ".chr", ".pob", ".map", ".bmf"),  
  rolloutTitle = "Import GRE file",
  qobsFolderCaption = "Open folder with .qob files",
  checkboxSubfoldersCaption = "Process subfolders",  
  buttonCaption = "Import",
  multButtonCaption = "Multiple import",
  checkboxTexturedCaption = "Load textures",
  checkboxHPCaption = "Load helper points",
  checkboxSkCaption = "Load skeleton",
  checkboxGroupObjsCaption = "Group all objects",
  unitsLabelCaption = "Units", 
  unitsList = #("Millimeters", "Centimeters", "Meters"),
  labelsRadioButtons = #("Current path", "Choose folder"),
  captionRadioButtons = "Texture path",
  openTexFolderCaption = "Open texture folder",
  scaleCoeffLabelText = "Scale coefficient",
  scaleList = #("off", "10", "50", "100", "150"),
  fnLabelText = "filename:",
  matsLabelText = "materials: %d",
  texsLabelText = "(textures): %d",   
  vertLabelText = "vertexes: %d",
  meshLabelText = "meshes: %d",
  formatLabelText = "Texture format",
  formatList = #(".rsb", ".bmp"),
  multImportLabelText = "Import mult. objects",
  filesNotFound = "%s files aren't found in %s folder.",
  pathToFolder = "Path to folder:",
  filesInFolder = "Files: %d" ,
  formaNotSupported = "Format %s is not supported.",
  errorReadFile = "Error. Can't read from the file %s.", 
  fn loadFromIni filename =
  (
    local sets = settings(this)
    sets.loadFromIniFile filename "strings"
  )     
)

struct qobImportUI
(
  settings,
  strings,
  model, 
  fn setUnits type =
  (
    max.setUnits #Metric type
  ),
  fn getFileInformation file =
  (
    this.dialog.lbl_filename.text = strings.fnLabelText
    this.dialog.lbl_filenameField.text = file.object.name
    this.dialog.lbl_mats.text = \
      formattedprint file.object.materials.count \
      format:strings.matsLabelText 
    this.dialog.lbl_texs.text = \
      formattedprint file.object.textures.count \
      format:strings.texsLabelText
      
    local vertexCount = 0
    local meshCount = 0    
    for object in file.object.geometryObjects do
    (
      vertexCount += object.vertexArray.count
      meshCount += object.meshes.count
    )
    this.dialog.lbl_vert.text = formattedprint vertexCount \
      format:strings.vertLabelText   
    this.dialog.lbl_mesh.text = formattedprint meshCount \
      format:strings.meshLabelText      
  ),
  fn importModel filename: =
  (    
    if filename == unsupplied then
    (
      dialogs.caption = strings.importDialogCaption
      dialogs.types = strings.importDialogTypes  
      filestream = dialogs.openFileDialog &fname "rb" 
      filename = fname       
    )  
    if filestream != undefined then 
    (    
      local ext = fileUtils.getFileExtenion filename 
      file = case (ext) of
      (
        (strings.formatsArray[1]): qobjectFile()
        (strings.formatsArray[2]): characterFile()
        (strings.formatsArray[3]): pobjectFile()
        (strings.formatsArray[4]): mapFile()      
      )  
      file.object.name = fileUtils.getFileName filename
      file.openStream filestream filename
      if file.readFile() then
      (
        getFileInformation file
        model = greModel file.object
        model.isTextured = settings.isTextured
        model.showHPs = settings.showHPs
        model.showSkeleton = settings.showSkeleton
        model.texturesPath = settings.path
        --model.texturesPath = "F:/git/gre-templates/scripts/3dsmax/output/"
        model.scale = settings.scaleCoeff
        model.texFormat = settings.texFormatExt
        setUnits (strings.unitsList[settings.unitsType] as Name)
        model.createScene()       
      )      
      file.closeFile()       
    )    
  ),
  fn importMultipleModel =
  (
    local qobsFolder = dialogs.openFolder strings.qobsFolderCaption
    if qobsFolder != undefined then
    (
      if procSubfolders then
        files = utils.findFiles qobsFolder "*.qob"
      else
        files = getFiles (qobsFolder + "*.qob")
      if files.count > 0 then
      (
        this.dialog.lbl_filename.text = strings.pathToFolder
        this.dialog.lbl_filenameField.text = qobsFolder 
        this.dialog.lbl_mats.text = formattedprint files.count \
            format:strings.filesInFolder        
        for filename in files do
          importModel filename
      )    
      else 
        dialogs.showMessage \
          (formattedprint ".qob" qobsFolder strings.filesNotFound)         
    )
  ),  
  dialog = 
  (
    rollout dialog strings.rolloutTitle
    (
      local owner = if owner != undefined do owner 

      label lbl_filename owner.strings.fnLabelText align: #left
      label lbl_filenameField align: #left
	  label lbl_mats "" align: #left 
	  label lbl_texs "" align: #left   
	  label lbl_vert "" align: #left 
	  label lbl_mesh "" align: #left
        
      label lbl_scale owner.strings.scaleCoeffLabelText  align: #left     
      dropDownList ddlist_scale items: owner.strings.scaleList selection:1 \
        width:100
      label lbl_units owner.strings.unitsLabelCaption  align: #left
      dropDownList ddlist_units items: owner.strings.unitsList \
        selection:owner.settings.unitsType width:100
      checkbox checkbox_isTextured owner.strings.checkboxTexturedCaption \
        checked:owner.settings.isTextured
      radiobuttons radio_texPathSwitch owner.strings.captionRadioButtons \
        labels:owner.strings.labelsRadioButtons default:1 align: #left
      label lbl_format owner.strings.formatLabelText align: #left     
      dropDownList ddlist_format items: owner.strings.formatList selection:2 width:100        
      checkbox checkbox_showHelperPoints owner.strings.checkboxHPCaption \
        checked:owner.settings.showHPs
      checkbox checkbox_showSkeleton owner.strings.checkboxSkCaption \
        checked:owner.settings.showSkeleton 
      checkbox checkbox_groupObjs owner.strings.checkboxGroupObjsCaption \
        checked:owner.settings.groupObjs         
      button button_import owner.strings.buttonCaption width:100
      label lbl_multiple owner.strings.multImportLabelText  align: #left       
      checkbox checkbox_procSubfolders owner.strings.checkboxSubfoldersCaption \
        checked:owner.settings.procSubfolders      
      button button_multImport owner.strings.multButtonCaption width:100
      on button_multImport pressed do
      (
        owner.importMultipleModel()
      )      
      on button_import pressed do
      (
        owner.settings.isTextured = checkbox_isTextured.checked
        owner.settings.showHPs = checkbox_showHelperPoints.checked
        owner.settings.showSkeleton = checkbox_showSkeleton.checked
        owner.settings.groupObjs = checkbox_groupObjs.checked
        owner.settings.unitsType = ddlist_units.selection
        if radio_texPathSwitch.state == 1 then
          owner.settings.path = sys.currentPath
        else
          owner.settings.path = dialogs.openFolder strings.openTexFolderCaption
        if ddlist_scale.selected == "off" then
          owner.settings.scaleCoeff = 1 
        else        
          owner.settings.scaleCoeff = (ddlist_scale.selected as integer)
        owner.settings.texFormatExt = ddlist_format.selected       
        owner.importModel()    
      )
    )      
  ),
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
  importUI = qobImportUI()
)

main()