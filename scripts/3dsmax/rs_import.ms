/*
  Author: AlexKimov
  Description: Rainbow Six / Eagle Watch (1998) export script
  Version: 0.1
*/

filein "lib/ms.ms"
filein "lib/sob.ms"
filein "lib/rse.ms"
filein "lib/dialogs.ms"
filein "lib/system.ms"

struct settingsImportUI
(
  isTextured = true,
  loadSkeleton = true,
  applyWeights = false,
  transCoordinates = true,
  combineMeshes = false
)

struct stringsImportUI
(
  importDialogCaption = "Open RS file",
  importDialogTypes = "Rainbow six 1/2 formats (*.sob)|*.sob",
  rolloutTitle = "Import RS file",
  buttonImportCaption = "Import",
  importRolloutTitle = "Import",
  buttonSetTexturePathCaption = "Set path",
  buttonClearTexturePathCaption = "Clear",
  importSettingsRolloutTitle = "Settings",
  grouptexPathCaption = "Textures",
  checkboxTexturedCaption = "add textures",
  checkboxSkeletonCaption = "add skeleton",
  checkboxWeightsCaption = "apply weights",
  checkboxCoordiantesCaption = "coordinates to 3ds Max ones",
  checkboxMeshesCaption = "combine meshes"
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
      rsfile.closeFile()        
    )    
  ),
  importSettingsRollout = 
  (
    rollout importSettingsRollout strings.importSettingsRolloutTitle
	(
	  local owner = if owner != undefined do owner

      groupBox group_texPath owner.strings.grouptexPathCaption \
        pos:[2, 5] width:180 height:95 	

	  checkbox checkbox_isTextured owner.strings.checkboxTexturedCaption \
        checked:owner.settings.isTextured pos:[15, 25] 
		
	  edittext edit_texPath "" fieldWidth:155 pos:[10, 45] readOnly:true      
      button button_setTexturePath owner.strings.buttonSetTexturePathCaption \
        width:75 pos:[15, 70]
      button button_clearTexturePath owner.strings.buttonClearTexturePathCaption \
        width:75 pos:[95, 70]
		
	  checkbox checkbox_loadSkeleton owner.strings.checkboxSkeletonCaption \
        checked:owner.settings.loadSkeleton pos:[15, 110] 
	  checkbox checkbox_transCoordinates owner.strings.checkboxCoordiantesCaption \
        checked:owner.settings.transCoordinates pos:[15, 130]		
	  checkbox checkbox_applyWeights owner.strings.checkboxWeightsCaption \
        checked:owner.settings.applyWeights pos:[15, 150] 
	  checkbox checkbox_combineMeshes owner.strings.checkboxMeshesCaption \
        checked:owner.settings.combineMeshes pos:[15, 170]	  	
	)
  ),  
  importRollout = 
  (
    rollout importRollout strings.importRolloutTitle
	(
      local owner = if owner != undefined do owner
	  
      button button_import owner.strings.buttonImportCaption width:100
      on button_import pressed do
      (
        owner.importModel() 
      )   	
	)
  ),
  dialog = 
  (
    rollout dialog strings.rolloutTitle
    (
      subrollout subroll_container "container" height:605 width:196 pos:[2, 2]
      on dialog resized point do
      (
        subroll_container.height = dialog.height
      )  	   
    )
  ),    
  fn close = try (destroyDialog dialog) catch(),
  fn show =
  (
    createDialog dialog width:200 pos:mouse.screenpos \
      style:#(#style_sysmenu, #style_resizing, #style_titlebar) lockWidth: true
	AddSubRollout dialog.subroll_container importSettingsRollout
	AddSubRollout dialog.subroll_container importRollout  	
  ),  
  fn init =
  (
    if settings == undefined then
      settings = settingsImportUI()
    if strings == undefined then  
      strings = stringsImportUI()
	  
    importRollout.owner = this
    importSettingsRollout.owner = this	
  ),
  on create do init()  
)

fn main = 
(
  sys.currentPath = fileUtils.getCurrentPath(getThisScriptFilename())
  importUI = sobImportUI()
  importUI.show()
)

main()