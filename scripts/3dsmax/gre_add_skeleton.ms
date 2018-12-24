
filein "max.ms"

struct settingsUI
{
  showLinks = true,
  boneHeight = 1,
  boneWidth = 1,
  taper = 10,
  wirecolor = yellow  
}

struct stringsUI
{
  rolloutTitle = "Skeleton and Animations",
  buttonCreateCaption = "Create",
  buttonLoadCaption = "Load",
  editboneWidthTitle = "width",
  editboneHeightTitle = "height",
  spinnerTaperCaption = "taper",
  colpickerCaption = "wirecolor",
  checkboxShowLinksCaption = "Show Links"
}

struct greSkeleton
{
  settings,
  settings,
  strings,
  dialog =
  (
    rollout dialog strings.rolloutTitle
    (
      local owner = if owner != undefined do owner
      edittext edit_boneWidth owner.strings.editboneWidthTitle 
      edittext edit_boneHeight owner.strings.editboneHeightTitle
      spinner spinner_boneTaper owner.strings.spinnerTaperCaption \
        range:[0, 100, 1] type:#integer
      colorpicker colpicker_wirecolor owner.strings.colpickerCaption \
        color:yellow modal:false 
      checkbox checkbox_showLinks owner.strings.checkboxShowLinksCaption \
        checked:owner.settings.showLinks       
      button button_create owner.strings.buttonCreateCaption width:100
      button button_loadFromFile owner.strings.buttonLoadCaption width:100      
      on button_create pressed do
      (
        owner.createStandardSkeleton()
      )
      on button_loadFromFile pressed do
      (
        owner.loadFromFile()         
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
    SpineRoot01 = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    SpineRoot01.name = "SpineRoot01"
    SpineRoot01.width = 1
    SpineRoot01.height = 1
    SpineRoot01.taper = 100
    SpineRoot01.wirecolor = yellow
    SpineRoot01.showlinks = true
    pos = (point3 0.000000 -0.000000 0.000000)
    matrix = inverse ((quat 0.696798 0.004018 -0.003903 0.717246) as matrix3)
    matrix.position = pos
    SpineRoot01.transform = matrix

    SpineLow = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    SpineLow.name = "SpineLow"
    SpineLow.width = 1
    SpineLow.height = 1
    SpineLow.taper = 100
    SpineLow.wirecolor = yellow
    SpineLow.showlinks = true
    pos = (point3 0.000000 6.768280 0.000000)
    matrix = inverse ((quat 0.078576 0.000279 0.005595 0.996892) as matrix3)
    matrix.position = pos
    SpineLow.parent = SpineRoot01
    SpineLow.transform = matrix*SpineRoot01.transform

    SpineMid = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    SpineMid.name = "SpineMid"
    SpineMid.width = 1
    SpineMid.height = 1
    SpineMid.taper = 100
    SpineMid.wirecolor = yellow
    SpineMid.showlinks = true
    pos = (point3 0.000000 10.297239 0.000000)
    matrix = inverse ((quat -0.106133 -0.000000 -0.000000 0.994352) as matrix3)
    matrix.position = pos
    SpineMid.parent = SpineLow
    SpineMid.transform = matrix*SpineLow.transform

    SpineTop = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    SpineTop.name = "SpineTop"
    SpineTop.width = 1
    SpineTop.height = 1
    SpineTop.taper = 100
    SpineTop.wirecolor = yellow
    SpineTop.showlinks = true
    pos = (point3 0.000000 16.473185 0.000000)
    matrix = inverse ((quat 0.179901 0.000000 0.000000 0.983685) as matrix3)
    matrix.position = pos
    SpineTop.parent = SpineMid
    SpineTop.transform = matrix*SpineMid.transform

    Neck2 = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    Neck2.name = "Neck2"
    Neck2.width = 1
    Neck2.height = 1
    Neck2.taper = 100
    Neck2.wirecolor = yellow
    Neck2.showlinks = true
    pos = (point3 0.000000 14.517118 -0.000001)
    matrix = inverse ((quat -0.084833 -0.000000 -0.000000 0.996395) as matrix3)
    matrix.position = pos
    Neck2.parent = SpineTop
    Neck2.transform = matrix*SpineTop.transform

    Neck = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    Neck.name = "Neck"
    Neck.width = 1
    Neck.height = 1
    Neck.taper = 100
    Neck.wirecolor = yellow
    Neck.showlinks = true
    pos = (point3 0.000000 5.987328 0.000000)
    matrix = inverse ((quat -0.005415 0.000000 -0.000000 0.999985) as matrix3)
    matrix.position = pos
    Neck.parent = Neck2
    Neck.transform = matrix*Neck2.transform

    Head = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    Head.name = "Head"
    Head.width = 1
    Head.height = 1
    Head.taper = 100
    Head.wirecolor = yellow
    Head.showlinks = true
    pos = (point3 0.000000 6.271232 -0.000000)
    matrix = inverse ((quat -0.073829 -0.000000 0.000000 0.997271) as matrix3)
    matrix.position = pos
    Head.parent = Neck
    Head.transform = matrix*Neck.transform

    RBicep = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    RBicep.name = "RBicep"
    RBicep.width = 1
    RBicep.height = 1
    RBicep.taper = 100
    RBicep.wirecolor = yellow
    RBicep.showlinks = true
    pos = (point3 -14.575241 14.273071 0.632296)
    matrix = inverse ((quat -0.100116 0.128877 0.745991 0.645650) as matrix3)
    matrix.position = pos
    RBicep.parent = SpineTop
    RBicep.transform = matrix*SpineTop.transform

    RForearm = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    RForearm.name = "RForearm"
    RForearm.width = 1
    RForearm.height = 1
    RForearm.taper = 100
    RForearm.wirecolor = yellow
    RForearm.showlinks = true
    pos = (point3 0.000003 24.738003 0.000000)
    matrix = inverse ((quat 0.037969 -0.005489 -0.063353 0.997254) as matrix3)
    matrix.position = pos
    RForearm.parent = RBicep
    RForearm.transform = matrix*RBicep.transform

    RHand = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    RHand.name = "RHand"
    RHand.width = 1
    RHand.height = 1
    RHand.taper = 100
    RHand.wirecolor = yellow
    RHand.showlinks = true
    pos = (point3 -0.000001 24.831003 0.000000)
    matrix = inverse ((quat -0.047018 -0.022153 -0.008743 0.998610) as matrix3)
    matrix.position = pos
    RHand.parent = RForearm
    RHand.transform = matrix*RForearm.transform

    LBicep = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    LBicep.name = "LBicep"
    LBicep.width = 1
    LBicep.height = 1
    LBicep.taper = 100
    LBicep.wirecolor = yellow
    LBicep.showlinks = true
    pos = (point3 14.550852 14.219372 0.646667)
    matrix = inverse ((quat -0.097342 -0.132649 -0.746638 0.644562) as matrix3)
    matrix.position = pos
    LBicep.parent = SpineTop
    LBicep.transform = matrix*SpineTop.transform

    LForearm = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    LForearm.name = "LForearm"
    LForearm.width = 1
    LForearm.height = 1
    LForearm.taper = 100
    LForearm.wirecolor = yellow
    LForearm.showlinks = true
    pos = (point3 0.000001 24.738003 0.000000)
    matrix = inverse ((quat 0.027438 0.005865 0.066775 0.997373) as matrix3)
    matrix.position = pos
    LForearm.parent = LBicep
    LForearm.transform = matrix*LBicep.transform

    LHand = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    LHand.name = "LHand"
    LHand.width = 1
    LHand.height = 1
    LHand.taper = 100
    LHand.wirecolor = yellow
    LHand.showlinks = true
    pos = (point3 -0.000000 24.830997 -0.000000)
    matrix = inverse ((quat -0.040827 0.022137 0.007409 0.998893) as matrix3)
    matrix.position = pos
    LHand.parent = LForearm
    LHand.transform = matrix*LForearm.transform

    RThigh = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    RThigh.name = "RThigh"
    RThigh.width = 1
    RThigh.height = 1
    RThigh.taper = 100
    RThigh.wirecolor = yellow
    RThigh.showlinks = true
    pos = (point3 -9.216725 -5.445369 5.266490)
    matrix = inverse ((quat 0.000672 0.030249 0.999478 0.011348) as matrix3)
    matrix.position = pos
    RThigh.parent = SpineRoot01
    RThigh.transform = matrix*SpineRoot01.transform

    RCalf = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    RCalf.name = "RCalf"
    RCalf.width = 1
    RCalf.height = 1
    RCalf.taper = 100
    RCalf.wirecolor = yellow
    RCalf.showlinks = true
    pos = (point3 0.000000 42.315006 0.000000)
    matrix = inverse ((quat -0.130020 -0.000260 0.003470 0.991505) as matrix3)
    matrix.position = pos
    RCalf.parent = RThigh
    RCalf.transform = matrix*RThigh.transform

    RFoot = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    RFoot.name = "RFoot"
    RFoot.width = 1
    RFoot.height = 1
    RFoot.taper = 100
    RFoot.wirecolor = yellow
    RFoot.showlinks = true
    pos = (point3 -0.000000 41.477997 0.000000)
    matrix = inverse ((quat 0.397610 -0.574842 -0.382379 0.604359) as matrix3)
    matrix.position = pos
    RFoot.parent = RCalf
    RFoot.transform = matrix*RCalf.transform

    RToe = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    RToe.name = "RToe"
    RToe.width = 1
    RToe.height = 1
    RToe.taper = 100
    RToe.wirecolor = yellow
    RToe.showlinks = true
    pos = (point3 0.000001 14.693999 -0.000000)
    matrix = inverse ((quat 0.002221 -0.005611 -0.282633 0.959209) as matrix3)
    matrix.position = pos
    RToe.parent = RFoot
    RToe.transform = matrix*RFoot.transform

    LThigh = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    LThigh.name = "LThigh"
    LThigh.width = 1
    LThigh.height = 1
    LThigh.taper = 100
    LThigh.wirecolor = yellow
    LThigh.showlinks = true
    pos = (point3 9.383750 -5.302430 5.300977)
    matrix = inverse ((quat 0.001343 -0.030446 -0.999280 0.022589) as matrix3)
    matrix.position = pos
    LThigh.parent = SpineRoot01
    LThigh.transform = matrix*SpineRoot01.transform

    LCalf = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    LCalf.name = "LCalf"
    LCalf.width = 1
    LCalf.height = 1
    LCalf.taper = 100
    LCalf.wirecolor = yellow
    LCalf.showlinks = true
    pos = (point3 0.000000 42.314995 0.000000)
    matrix = inverse ((quat -0.129644 0.000057 -0.001419 0.991560) as matrix3)
    matrix.position = pos
    LCalf.parent = LThigh
    LCalf.transform = matrix*LThigh.transform

    LFoot = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    LFoot.name = "LFoot"
    LFoot.width = 1
    LFoot.height = 1
    LFoot.taper = 100
    LFoot.wirecolor = yellow
    LFoot.showlinks = true
    pos = (point3 0.000000 41.478004 0.000001)
    matrix = inverse ((quat 0.385773 -0.602640 -0.396968 0.574822) as matrix3)
    matrix.position = pos
    LFoot.parent = LCalf
    LFoot.transform = matrix*LCalf.transform
 
    LToe = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
    LToe.name = "LToe"
    LToe.width = 1
    LToe.height = 1
    LToe.taper = 100
    LToe.wirecolor = yellow
    LToe.showlinks = true
    pos = (point3 -0.000002 14.694002 -0.000000)
    matrix = inverse ((quat -0.005226 0.001100 -0.279779 0.960050) as matrix3)
    matrix.position = pos
    LToe.parent = LFoot
    LToe.transform = matrix*LFoot.transform
  ),
  fn init =
  (
    if settings == undefined then
      settings = settingsUI()
    if strings == undefined then  
      strings = stringsUI()
    dialog.owner = this 
    createDialog dialog width:125 pos:mouse.screenpos \
      style:#(#style_toolwindow, #style_sysmenu)     
  ),
  on create do init()
}

skeleton = greSkeleton()