/*

*/

filein "lib/ms.ms"
filein "lib/max.ms"
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
  groupCaption = "Bones",
  buttonCreateCaption = "Create",
  buttonLoadCaption = "Load file",
  editboneWidthTitle = "width",
  editboneHeightTitle = "height",
  spinnerTaperCaption = "taper",
  colpickerCaption = "wirecolor",
  checkboxShowLinksCaption = "Show links",
  buttonLoadAnimCaption  = "Load anim.",
  buttonListCaption  = "Get list",
  bmfsFolderTitle = "Open folder",
  listboxCaption = "Animations",
  radioCaption = "Add animation to bones",
  radioLabels = #("by names in file", "by selected objects") 
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
      width:175 height:90
      edittext edit_boneWidth owner.strings.editboneWidthTitle fieldWidth:30 \
        pos:[24, 25]
      edittext edit_boneHeight owner.strings.editboneHeightTitle fieldWidth:30 \
        pos:[20, 48]        
      spinner spinner_boneTaper owner.strings.spinnerTaperCaption \
        range:[0, 100, 1] type:#integer align:#left pos:[109, 25] fieldWidth:30
      colorpicker colpicker_wirecolor owner.strings.colpickerCaption \
        color:yellow modal:false pos:[90, 48]
      checkbox checkbox_showLinks owner.strings.checkboxShowLinksCaption \
        checked:owner.settings.showLinks pos:[22, 70]       
      button button_create owner.strings.buttonCreateCaption width:80 \
        pos:[15, 100] 
      button button_loadFromFile owner.strings.buttonLoadCaption width:80 \
        pos:[100, 100] 
      
      listbox listbox_animationList owner.strings.listboxCaption pos:[10, 125] \
        width:175
      radiobuttons radio_type owner.strings.radioCaption \
        labels:owner.strings.radioLabels align:#left    
      button button_getAnimationList owner.strings.buttonListCaption \
        width:80 pos:[15, 335] 
      button button_loadAnimation owner.strings.buttonLoadAnimCaption \
        width:80 pos:[100, 335]       
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
        owner.loadAnimation()
      )       
    )     
  ),
  fn getAnimationList =
  (
    local bmfsFolder = dialogs.openFolder strings.bmfsFolderTitle
    if bmfsFolder != undefined then
    (
      if settings.procSubfolders then
        files = utils.findFiles bmfsFolder "*.bmf"
      else
        files = getFiles (bmfsFolder + "*.bmf")
      if files.count > 0 then
      (    
        bmfList = copy files
        for filename in files do
          filename = fileUtils.getFileName filename
        this.dialog.listbox_animationList.items = files 
      )    
      else 
        dialogs.showMessage \
          (formattedprint ".bmf" bmfsFolder strings.filesNotFound)         
    )    
  ),
  fn loadAnimation =
  (
    if (this.dialog.listbox_animationList.selection > 0) then
    (
      filename = bmfList[this.dialog.listbox_animationList.selection]
      bmf = boneMovementsFile()
      if bmf.openFile("rb") != undefined then
      (
        if bmf.readFile() then
        ( 
          for i = 1 to object.boneCount do 
          (
            bone = getNodeByName object.boneAnimations[i].name
            for index = 1 to object.positionKeys.count do
            (
              key = object.positionKeys[index]
              max.controller.addKey bone.position.controller key.frame \
                key.position
            )  
            for index = 1 to object.rotationKeys.count do
            (
              key = object.rotationKeys[index]
              max.controller.addKey bone.rotation.controller key.frame \
                key.rotation
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
      chr.readSkeleton moveToPos:true
      model = greModel chr.object
      model.createScene()
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
    createDialog dialog width:195 pos:mouse.screenpos \
      style:#(#style_toolwindow, #style_sysmenu)     
  ),
  on create do init()
)

characterSkeleton = greSkeleton()