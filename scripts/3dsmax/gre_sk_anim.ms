/*
  Author: AlexKimov
  Description: Ghost Recon (2001) character animation import/export script
  Version: 0.1
*/

filein "lib/ms.ms"
filein "lib/settings.ms"
filein "lib/bmf.ms"
filein "lib/chr.ms"
filein "lib/rse.ms"
filein "lib/rse_viewer.ms"
filein "lib/rse_skeleton.ms"
filein "lib/rse_animations.ms"
filein "lib/utils.ms"
filein "lib/rse_header.ms"

struct settingsUI
(
  showLinks = true,
  subfolders = false,
  boneHeight = 1,
  boneWidth = 1,
  taper = 10,
  wirecolor = yellow,
  procSubfolders = false,
  bmfFolder,
  showModel = false,
  fn loadFromIni filename =
  (
    local sets = iniSettings(this)
    sets.loadFromIniFile filename "settings"
  )    
)

struct stringsUI
(
  rolloutTitle = "Skeleton and Animations",
  boneSettingsCaption = "Skeleton",
  groupBoneSettingsCaption = "Bone parameters:",
  buttonCreateCaption = "Add standard skeleton",
  buttonLoadCaption = "Load from .chr file",
  editboneWidthTitle = "width",
  editboneHeightTitle = "height",
  spinnerTaperCaption = "taper",
  colpickerCaption = "wirecolor",
  checkboxShowLinksCaption = "Show links",
  buttonLoadAnimCaption  = "Load selected .bmf file",
  buttonListCaption  = "Get animation list",
  bmfsFolderTitle = "Open folder",
  rolloutAnimationCaption = "Animations",
  radioCaption = "Apply animation to:",
  radioLabels = #("names", "selection"),
  filesNotFound = "Files not found in %s." ,
  checkboxSubfoldersCaption = "Search in subfolders",
  groupAnimationCaption = "Animate skeleton",
  rolloutExportTitle = "Export",
  buttonExportCaption = "Save to .bmf",
  fileSaved = "File was successfully saved.",
  checkboxshowModelCaption = "Show model",
  fn loadFromIni filename =
  (
    local sets = iniSettings(this)
    sets.loadFromIniFile filename "settings"
  )    
)

struct greSkeletonAnimationsUI
(
  settings,
  strings,  
  skeletonRollout =
  (
    rollout skeletonRollout strings.boneSettingsCaption
    (
      local owner = if owner != undefined do owner   
      
      groupBox group_boneSettings owner.strings.groupBoneSettingsCaption \
        pos:[5, 0] width:175 height:133 
        
      spinner spinner__boneWidth owner.strings.editboneWidthTitle \
        fieldWidth:60 type:#float align:#right pos:[50, 20] \
        range:[0, 100, owner.settings.boneWidth]
      spinner spinner_boneHeight owner.strings.editboneHeightTitle \
        fieldWidth:60 type:#float align:#right pos:[46, 40] \
        range:[0, 100, owner.settings.boneHeight]        
      spinner spinner_boneTaper owner.strings.spinnerTaperCaption \
        range:[0, 100, owner.settings.taper] type:#integer fieldWidth:60 \
        pos:[50, 60]      
      colorpicker colpicker_wirecolor owner.strings.colpickerCaption \
        color:settings.wirecolor modal:false pos:[31, 84]       
      checkbox checkbox_showLinks owner.strings.checkboxShowLinksCaption \
        checked:owner.settings.showLinks pos:[77, 110]       
      button button_create owner.strings.buttonCreateCaption width:120 \
        pos:[30, 140] 
      checkbox checkbox_showModel owner.strings.checkboxshowModelCaption \
        checked:owner.settings.showModel pos:[30, 165]           
      button button_loadFromFile owner.strings.buttonLoadCaption width:120 \
        pos:[30, 182]    
      on button_create pressed do
      (
        owner.addStandardSkeleton()
      )
      on button_loadFromFile pressed do
      (
        owner.loadFromCharacterFile()         
      )         
    ) 
  ),
  animationsRollout =
  (
    rollout animationsRollout strings.rolloutAnimationCaption
    (
      local owner = if owner != undefined do owner    
      listbox listbox_animationList height:14 width:180 pos:[2, 3]
      checkbox checkbox_subfolders owner.strings.checkboxSubfoldersCaption \
        checked:owner.settings.subfolders pos:[30, 202]             
      button button_getAnimationList owner.strings.buttonListCaption \
        width:120  pos:[30, 222]  
      groupBox group_addAnimation owner.strings.groupAnimationCaption \
        pos:[2, 250] width:180 height:70 
      radiobuttons radio_type \
        labels:owner.strings.radioLabels pos:[30, 269]                           
      button button_loadAnimation owner.strings.buttonLoadAnimCaption \
        width:120 pos:[30, 289] 
      on button_getAnimationList pressed do
      (
        owner.getAnimationFilesList()
      )     
      on button_loadAnimation pressed do
      (
        owner.addAnimationToSkeleton()
      )         
    )    
  ), 
  exportRollout =
  (
    rollout exportRollout strings.rolloutExportTitle
    (
      local owner = if owner != undefined do owner     
      	  
      --groupBox group_exportAnimation owner.strings.groupExportCaption \
        --width:180 height:43 pos:[10, 463]   
		
      radiobuttons radio_type labels:owner.strings.radioLabels pos:[30, 0]           
      button button_export owner.strings.buttonExportCaption \
        width:120 pos:[30, 20]           
      on button_export pressed do
      (
        owner.exportToBMF()
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
  fn exportToBMF = 
  (
    bmf = boneMovementsFile()
    if bmf.openFile("wb") != undefined then
    (   
      for boneName in rseConsts.standardGREBoneNames do
      (
        boneAnimation = rseAnimation.create()                    
        append bmf.rseObject.boneAnimations boneAnimation
      )
      if frameCount > 0 then
      (
        bmf.rseObject.frameCount = frameCount
        if bmf.writeFile() then
          dialogs.showMessage strings.fileSaved
      ) 
      bmf.closeFile()        
    )
  ),
  fn getAnimationFilesList =
  (
    if settings.bmfFolder == undefined then
      settings.bmfFolder = dialogs.openFolder strings.bmfsFolderTitle
    else
    (
      files = fileUtils.findFiles settings.bmfFolder "*.bmf" \
        subfolders:settings.procSubfolders
      if files.count > 0 then    
        this.animationsRollout.listbox_animationList.items = 
        (
          for filename in files collect \
            (fileUtils.getFileName filename ext:true)
        )    
      else 
        dialogs.showMessage \
          (formattedprint settings.bmfFolder format:strings.filesNotFound)         
    )    
  ),
  fn addAnimationToSkeleton =
  (
    if (this.animationsRollout.listbox_animationList.selection > 0) then
    (
      filename = (settings.bmfFolder + \ 
        this.animationsRollout.listbox_animationList.selected)
      bmf = boneMovementsFile filename:filename
      if bmf.openFile("rb") != undefined then
      (
        if bmf.readFile() then
        ( 
          skeletonAnimations = rseSkeletonAnimationViewer()
		  skeletonAnimations.create bmf.rseObject
        ) 
        bmf.closeFile() 		
      )      
    )
  ),  
  fn loadFromCharacterFile =
  (
    chr = characterFile()
    if chr.openFile("rb") != undefined then
    (
      if settings.showModel then
        result = chr.readSkeleton()
      else
        result = chr.readFile() 
      if result then
      (  
        chr.closeFile()      
        viewer = rseViewer chr.rseObject
        viewer.settings.isTextured = false
        viewer.createScene()
      )      
    )        
  ),
  fn addStandardSkeleton =
  (
    skeletonViewer = greSkeletonModelViewer()
    skeletonViewer.create (greStandardSkeleton())
  ),
  fn show =
  (
    createDialog dialog width:200 pos:mouse.screenpos \
      style:#(#style_sysmenu, #style_resizing, #style_titlebar) lockWidth: true
    AddSubRollout dialog.subroll_container skeletonRollout
    AddSubRollout dialog.subroll_container animationsRollout
    AddSubRollout dialog.subroll_container exportRollout rolledUp:true   
  ),
  fn init =
  (
    if settings == undefined then
      settings = settingsUI()
    if strings == undefined then  
      strings = stringsUI()
    skeletonRollout.owner = this
    animationsRollout.owner = this
    exportRollout.owner = this       
  ),
  fn close = try (destroyDialog dialog) catch(),    
  on create do init()
)

fn main =
(
  skeletonUI = greSkeletonAnimationsUI()
  skeletonUI.settings.bmfFolder = \
    "E:/SteamLibrary/steamapps/common/Ghost Recon/Data/Motion/"
  skeletonUI.show()	
)

main()