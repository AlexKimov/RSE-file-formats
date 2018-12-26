/*

*/

filein "lib/ms.ms"
filein "lib/max.ms"
filein "lib/bmf.ms"
filein "lib/chr.ms"
filein "lib/rse.ms"
filein "lib/rse_model.ms"
filein "lib/skeleton.ms"

struct settingsUI
(
  showLinks = true,
  boneHeight = 1,
  boneWidth = 1,
  taper = 10,
  wirecolor = yellow,
  procSubfolders = false  
)

struct stringsUI
(
  rolloutTitle = "Skeleton and Animations",
  groupCaption = "Bones Properties",
  buttonCreateCaption = "Add skeleton",
  buttonLoadCaption = "Load from .chr",
  editboneWidthTitle = "width",
  editboneHeightTitle = "height",
  spinnerTaperCaption = "taper",
  colpickerCaption = "wirecolor",
  checkboxShowLinksCaption = "Show links",
  buttonLoadAnimCaption  = "Load anim.",
  buttonListCaption  = "Get files",
  bmfsFolderTitle = "Open folder",
  listboxCaption = "Animations",
  radioCaption = "Add animation to bones",
  radioLabels = #("by names in file", "by selected objects"),
  filesNotFound = "Files not found in %s."  
)

struct greSkeleton
(
  settings,
  strings,
  bmfList = #(),
  dialog =
  (
    rollout dialog strings.rolloutTitle
    (
      local owner = if owner != undefined do owner
      
      groupBox group_settings owner.strings.groupCaption pos:[10, 5] \
      width:180 height:90
      
      spinner spinner__boneWidth owner.strings.editboneWidthTitle \
        fieldWidth:30 type:#float align:#right pos:[21, 25]
      spinner spinner_boneHeight owner.strings.editboneHeightTitle \
        fieldWidth:30 type:#float align:#right pos:[17, 48] 
        
      spinner spinner_boneTaper owner.strings.spinnerTaperCaption \
        range:[0, 100, 1] type:#integer fieldWidth:30 pos:[114, 25] 
      colorpicker colpicker_wirecolor owner.strings.colpickerCaption \
        color:yellow modal:false pos:[95, 48]
      checkbox checkbox_showLinks owner.strings.checkboxShowLinksCaption \
        checked:owner.settings.showLinks pos:[22, 70]       
      button button_create owner.strings.buttonCreateCaption width:80 \
        pos:[15, 100] 
      button button_loadFromFile owner.strings.buttonLoadCaption width:80 \
        pos:[104, 100] 
      
      listbox listbox_animationList owner.strings.listboxCaption pos:[10, 125] \
        width:179
      radiobuttons radio_type owner.strings.radioCaption \
        labels:owner.strings.radioLabels align:#left    
      button button_getAnimationList owner.strings.buttonListCaption \
        width:80 pos:[15, 335] 
      button button_loadAnimation owner.strings.buttonLoadAnimCaption \
        width:80 pos:[103, 335]       
      on button_create pressed do
      (
        owner.createStandardSkeleton()
      )
      on button_loadFromFile pressed do
      (
        owner.loadFromFile()         
      ) 
      on button_getAnimationList pressed do
      (
        owner.getAnimationList()
      )     
      on button_loadAnimation pressed do
      (
        owner.addAnimationToSkeleton()
      )       
    )     
  ),
  fn getAnimationList =
  (
    --local bmfsFolder = dialogs.openFolder strings.bmfsFolderTitle
    this.dialog.listbox_animationList.items = #()
    bmfsFolder = "F:/SteamLibrary/steamapps/common/Ghost Recon/Data/Motion/"
    if bmfsFolder != undefined then
    (
      if settings.procSubfolders then
        files = utils.findFiles bmfsFolder "*.bmf"
      else
        files = getFiles (bmfsFolder + "*.bmf")
      if files.count > 0 then
      (    
        bmfList = files
        filenames = \
          (for filename in files collect (fileUtils.getFileName filename))
        this.dialog.listbox_animationList.items = filenames 
      )    
      else 
        dialogs.showMessage \
          (formattedprint bmfsFolder format:strings.filesNotFound)         
    )    
  ),
  fn addAnimationToSkeleton =
  (
    if (this.dialog.listbox_animationList.selection > 0) then
    (
      filename = bmfList[this.dialog.listbox_animationList.selection]
      bmf = boneMovementsFile()
      bmf.filename = filename
      if bmf.openFile("rb") != undefined then
      (
        if bmf.readFile() then
        ( 
          max.animation.setLength bmf.object.frameCount
          for i = 1 to bmf.object.boneCount do 
          (
            bone = getNodeByName bmf.object.boneAnimations[i].name
            if bone != undefined then
            (
              for keyIndex = 2 to bone.position.controller.keys.count do
                max.controller.delKey bone.position.controller --index:keyIndex
              for keyIndex = 2 to bone.rotation.controller.keys.count do
                max.controller.delKey bone.rotation.controller --index:keyIndex
                        
              max.controller.addKey bone.position.controller 0 
              max.controller.addKey bone.rotation.controller 0 
              for index = 2 to bmf.object.boneAnimations[i].positionKeys.count do
              (
                key = bmf.object.boneAnimations[i].positionKeys[index]
                max.controller.addKey bone.position.controller key.frame \
                  value:key.position
              )  
              for index = 2 to bmf.object.boneAnimations[i].rotationKeys.count do
              (
                key = bmf.object.boneAnimations[i].rotationKeys[index]
                max.controller.addKey bone.rotation.controller key.frame \
                  value:key.rotation
              ) 
            )            
          )
        )        
      )      
    )
  ),  
  fn loadFromFile =
  (
    chr = characterFile()
    if chr.openFile("rb") != undefined then
    (
      chr.readSkeleton()
      model = greModel chr.object
      model.createSkeleton()
    )        
  ),
  fn createStandardSkeleton =
  (
    standardSkeleton = skeletonModel settings
    standardSkeleton.create()
  ),
  fn init =
  (
    if settings == undefined then
      settings = settingsUI()
    if strings == undefined then  
      strings = stringsUI()
    dialog.owner = this 
    createDialog dialog width:198 pos:mouse.screenpos \
      style:#(#style_toolwindow, #style_sysmenu)     
  ),
  on create do init()
)

characterSkeleton = greSkeleton()