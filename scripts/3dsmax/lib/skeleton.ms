/*

*/

filein "max.ms"

struct skeletonModel
(
  settings,
  fn create =
  (
    SpineRoot01 = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] \
      name:"SpineRoot01"    
    SpineRoot01.width = settings.boneWidth
    SpineRoot01.height = settings.boneHeight
    SpineRoot01.taper = settings.taper
    SpineRoot01.wirecolor = settings.wirecolor
    SpineRoot01.showLinks = settings.showLinks   
    pos = (point3 0 0 0)
    matrix = inverse ((quat 0.696798 0.004018 0.003903 0.717246) as matrix3)
    matrix.position = pos
    SpineRoot01.transform = matrix

    SpineLow = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"SpineLow"
    SpineLow.width = settings.boneWidth
    SpineLow.height = settings.boneHeight
    SpineLow.taper = settings.taper
    SpineLow.wirecolor = settings.wirecolor
    SpineLow.showLinks = settings.showLinks 
    pos = (point3 0 6.768280 0)
    matrix = inverse ((quat 0.078576 0.000279 0.005595 0.996892) as matrix3)
    matrix.position = pos
    SpineLow.parent = SpineRoot01
    SpineLow.transform = matrix*SpineRoot01.transform

    SpineMid = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"SpineMid"
    SpineMid.width = settings.boneWidth
    SpineMid.height = settings.boneHeight
    SpineMid.taper = settings.taper
    SpineMid.wirecolor = settings.wirecolor
    SpineMid.showLinks = settings.showLinks 
    pos = (point3 0 10.297239 0)
    matrix = inverse ((quat 0.106133 0 0 0.994352) as matrix3)
    matrix.position = pos
    SpineMid.parent = SpineLow
    SpineMid.transform = matrix*SpineLow.transform

    SpineTop = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"SpineTop"
    SpineTop.width = settings.boneWidth
    SpineTop.height = settings.boneHeight
    SpineTop.taper = settings.taper
    SpineTop.wirecolor = settings.wirecolor
    SpineTop.showLinks = settings.showLinks 
    pos = (point3 0 16.473185 0)
    matrix = inverse ((quat 0.179901 0 0 0.983685) as matrix3)
    matrix.position = pos
    SpineTop.parent = SpineMid
    SpineTop.transform = matrix*SpineMid.transform

    Neck2 = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"Neck2"
    Neck2.width = settings.boneWidth
    Neck2.height = settings.boneHeight
    Neck2.taper = settings.taper
    Neck2.wirecolor = settings.wirecolor
    Neck2.showLinks = settings.showLinks 
    pos = (point3 0 14.517118 0.000001)
    matrix = inverse ((quat 0.084833 0 0 0.996395) as matrix3)
    matrix.position = pos
    Neck2.parent = SpineTop
    Neck2.transform = matrix*SpineTop.transform

    Neck = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"Neck"
    Neck.width = settings.boneWidth
    Neck.height = settings.boneHeight
    Neck.taper = settings.taper
    Neck.wirecolor = settings.wirecolor
    Neck.showLinks = settings.showLinks 
    pos = (point3 0 5.987328 0)
    matrix = inverse ((quat 0.005415 0 0 0.999985) as matrix3)
    matrix.position = pos
    Neck.parent = Neck2
    Neck.transform = matrix*Neck2.transform

    Head = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"Head"
    Head.width = settings.boneWidth
    Head.height = settings.boneHeight
    Head.taper = settings.taper
    Head.wirecolor = settings.wirecolor
    Head.showLinks = settings.showLinks 
    pos = (point3 0 6.271232 0)
    matrix = inverse ((quat 0.073829 0 0 0.997271) as matrix3)
    matrix.position = pos
    Head.parent = Neck
    Head.transform = matrix*Neck.transform

    RBicep = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"RBicep"
    RBicep.width = settings.boneWidth
    RBicep.height = settings.boneHeight
    RBicep.taper = settings.taper
    RBicep.wirecolor = settings.wirecolor
    RBicep.showLinks = settings.showLinks 
    pos = (point3 -14.575241 14.273071 0.632296)
    matrix = inverse ((quat 0.100116 0.128877 0.745991 0.645650) as matrix3)
    matrix.position = pos
    RBicep.parent = SpineTop
    RBicep.transform = matrix*SpineTop.transform

    RForearm = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"RForearm"
    RForearm.width = settings.boneWidth
    RForearm.height = settings.boneHeight
    RForearm.taper = settings.taper
    RForearm.wirecolor = settings.wirecolor
    RForearm.showLinks = settings.showLinks 
    pos = (point3 0.000003 24.738003 0)
    matrix = inverse ((quat 0.037969 0.005489 0.063353 0.997254) as matrix3)
    matrix.position = pos
    RForearm.parent = RBicep
    RForearm.transform = matrix*RBicep.transform

    RHand = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"RHand"
    RHand.width = settings.boneWidth
    RHand.height = settings.boneHeight
    RHand.taper = settings.taper
    RHand.wirecolor = settings.wirecolor
    RHand.showLinks = settings.showLinks 
    pos = (point3 0.000001 24.831003 0)
    matrix = inverse ((quat 0.047018 0.022153 0.008743 0.998610) as matrix3)
    matrix.position = pos
    RHand.parent = RForearm
    RHand.transform = matrix*RForearm.transform

    LBicep = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"LBicep"
    LBicep.width = settings.boneWidth
    LBicep.height = settings.boneHeight
    LBicep.taper = settings.taper
    LBicep.wirecolor = settings.wirecolor
    LBicep.showLinks = settings.showLinks 
    pos = (point3 14.550852 14.219372 0.646667)
    matrix = inverse ((quat 0.097342 0.132649 0.746638 0.644562) as matrix3)
    matrix.position = pos
    LBicep.parent = SpineTop
    LBicep.transform = matrix*SpineTop.transform

    LForearm = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"LForearm"
    LForearm.width = settings.boneWidth
    LForearm.height = settings.boneHeight
    LForearm.taper = settings.taper
    LForearm.wirecolor = settings.wirecolor
    LForearm.showLinks = settings.showLinks 
    pos = (point3 0.000001 24.738003 0)
    matrix = inverse ((quat 0.027438 0.005865 0.066775 0.997373) as matrix3)
    matrix.position = pos
    LForearm.parent = LBicep
    LForearm.transform = matrix*LBicep.transform

    LHand = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"LHand"
    LHand.width = settings.boneWidth
    LHand.height = settings.boneHeight
    LHand.taper = settings.taper
    LHand.wirecolor = settings.wirecolor
    LHand.showLinks = settings.showLinks 
    pos = (point3 0 24.830997 0)
    matrix = inverse ((quat 0.040827 0.022137 0.007409 0.998893) as matrix3)
    matrix.position = pos
    LHand.parent = LForearm
    LHand.transform = matrix*LForearm.transform

    RThigh = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"RThigh"
    RThigh.width = settings.boneWidth
    RThigh.height = settings.boneHeight
    RThigh.taper = settings.taper
    RThigh.wirecolor = settings.wirecolor
    RThigh.showLinks = settings.showLinks 
    pos = (point3 -9.216725 -5.445369 5.266490)
    matrix = inverse ((quat 0.000672 0.030249 0.999478 0.011348) as matrix3)
    matrix.position = pos
    RThigh.parent = SpineRoot01
    RThigh.transform = matrix*SpineRoot01.transform

    RCalf = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"RCalf"
    RCalf.width = settings.boneWidth
    RCalf.height = settings.boneHeight
    RCalf.taper = settings.taper
    RCalf.wirecolor = settings.wirecolor
    RCalf.showLinks = settings.showLinks 
    pos = (point3 0 42.315006 0)
    matrix = inverse ((quat 0.130020 0.000260 0.003470 0.991505) as matrix3)
    matrix.position = pos
    RCalf.parent = RThigh
    RCalf.transform = matrix*RThigh.transform

    RFoot = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"RFoot"
    RFoot.width = settings.boneWidth
    RFoot.height = settings.boneHeight
    RFoot.taper = settings.taper
    RFoot.wirecolor = settings.wirecolor
    RFoot.showLinks = settings.showLinks 
    pos = (point3 0 41.477997 0)
    matrix = inverse ((quat 0.397610 0.574842 0.382379 0.604359) as matrix3)
    matrix.position = pos
    RFoot.parent = RCalf
    RFoot.transform = matrix*RCalf.transform

    RToe = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"RToe"
    RToe.width = settings.boneWidth
    RToe.height = settings.boneHeight
    RToe.taper = settings.taper
    RToe.wirecolor = settings.wirecolor
    RToe.showLinks = settings.showLinks 
    pos = (point3 0.000001 14.693999 0)
    matrix = inverse ((quat 0.002221 0.005611 0.282633 0.959209) as matrix3)
    matrix.position = pos
    RToe.parent = RFoot
    RToe.transform = matrix*RFoot.transform

    LThigh = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"LThigh"
    LThigh.width = settings.boneWidth
    LThigh.height = settings.boneHeight
    LThigh.taper = settings.taper
    LThigh.wirecolor = settings.wirecolor
    LThigh.showLinks = settings.showLinks 
    pos = (point3 9.383750 -5.302430 5.300977)
    matrix = inverse ((quat 0.001343 0.030446 0.999280 0.022589) as matrix3)
    matrix.position = pos
    LThigh.parent = SpineRoot01
    LThigh.transform = matrix*SpineRoot01.transform

    LCalf = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"LCalf"
    LCalf.width = settings.boneWidth
    LCalf.height = settings.boneHeight
    LCalf.taper = settings.taper
    LCalf.wirecolor = settings.wirecolor
    LCalf.showLinks = settings.showLinks 
    pos = (point3 0 42.314995 0)
    matrix = inverse ((quat 0.129644 0.000057 0.001419 0.991560) as matrix3)
    matrix.position = pos
    LCalf.parent = LThigh
    LCalf.transform = matrix*LThigh.transform

    LFoot = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"LFoot"
    LFoot.width = settings.boneWidth
    LFoot.height = settings.boneHeight
    LFoot.taper = settings.taper
    LFoot.wirecolor = settings.wirecolor
    LFoot.showLinks = settings.showLinks 
    pos = (point3 0 41.478004 0.000001)
    matrix = inverse ((quat 0.385773 0.602640 0.396968 0.574822) as matrix3)
    matrix.position = pos
    LFoot.parent = LCalf
    LFoot.transform = matrix*LCalf.transform
 
    LToe = max.bones.create [0, 0, 0] [0, 0, 0] [0, 0, 0] name:"LToe"
    LToe.width = settings.boneWidth
    LToe.height = settings.boneHeight
    LToe.taper = settings.taper
    LToe.wirecolor = settings.wirecolor
    LToe.showLinks = settings.showLinks 
    pos = (point3 0.000002 14.694002 0)
    matrix = inverse ((quat 0.005226 0.001100 0.279779 0.960050) as matrix3)
    matrix.position = pos
    LToe.parent = LFoot
    LToe.transform = matrix*LFoot.transform
  )
)