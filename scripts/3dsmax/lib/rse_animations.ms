/*

*/

filein "rse.ms"
filein "max.ms"

struct greBoneAnimation
(
  boneName = "",
  positionKeys = #(),
  rotationKeys = #()
)

struct grePosKey
(
  frame = 0,
  position = (point3 0 0 0)
)

struct greRotKey
(
  frame = 0,
  rotation = (quat 0 0 0 0)  
)

struct rseSkeletonAnimationViewer
(
  fn create animObject =
  (
    max.animation.setLength animObject.frameCount
    for skelAnimations in animObject.skeletonAnimations do 
    (
      boneNode = getNodeByName (skelAnimations.boneName)
      if boneNode != undefined then
      (
        max.controller.deleteKeysByRange boneNode.position.controller \
          1 boneNode.position.controller.keys.count
        max.controller.deleteKeysByRange boneNode.rotation.controller \
          1 boneNode.rotation.controller.keys.count
                    
        max.controller.addKey boneNode.position.controller 0
        max.controller.addKey boneNode.rotation.controller 0
        for key in skelAnimations.positionKeys do
          max.controller.addKey boneNode.position.controller (key.frame + 1) \
              value:key.position  
        for key in skelAnimations.rotationKeys do
          max.controller.addKey boneNode.rotation.controller (key.frame + 1) \
              value:key.rotation 
      )            
    )    
  )
)

struct rseSkeletonAnimationModel
(
  rseObject,
  fn getFromScene =
  (
    if (isKindOf rseObject greCharacterAnimations) then
    (    
      frameCount = 0
      for boneName in rseConsts.standardGREBoneNames do
      (
        skeletalBone = getNodeByName boneName
        if skeletalBone != undefined then
        (
          boneAnimation = greBoneAnimation()
          boneAnimation.name = boneName 
          for key in skeletalBone.position.controller.keys do
          (
            if key.time > 0 then
            (
              posKey = grePosKey() 
              posKey.frame = key.time - 1
              posKey.position = key.value
              append boneAnimation.positionKeys posKey
            )            
          )   
          if frameCount < boneAnimation.positionKeys.count then
            frameCount = boneAnimation.positionKeys.count           
            
          for key in skeletalBone.rotation.controller.keys do
          (
            if key.time > 0 then
            (          
              rotKey = greRotKey()
              rotKey.frame = key.time - 1
              rotKey.rotation = key.value
              append boneAnimation.rotationKeys rotKey
            )              
          ) 
          if frameCount < boneAnimation.rotationKeys.count then
             frameCount = boneAnimation.rotationKeys.count                    
          append rseObject.skeletonAnimations boneAnimation
        )
      ) 
      rseObject.frameCount = frameCount 
    )    
  )
)

struct rseSkeletonAnimationReader
(
  fstream,
  reader = formatReader(fstream), 
  fn read =
  (
    boneAnimation = greBoneAnimation()
    boneAnimation.boneName = reader.readName()
    count = ReadLong fstream
    for frame = 1 to count do
    (
      posKey = grePosKey()
      posKey.frame = ReadLong fstream
      posKey.position = reader.readPoint3Values()
      append boneAnimation.positionKeys posKey
    )
    count = ReadLong fstream
    for frame = 1 to count do
    (
      rotKey = greRotKey()
      rotKey.frame = ReadLong fstream
      rotKey.rotation = reader.readQuatValues()
      append boneAnimation.rotationKeys rotKey      
    )          
    result = boneAnimation
  )    
)

struct rseSkeletonAnimationWriter
(
  fstream,
  writer = formatWriter(fstream),
  fn writeBoneAnimation boneAnimation = 
  (
    if (isKindOf boneAnimation greBoneAnimation) then  
    (
      writer.writeName boneAnimation.name
      WriteLong fstream boneAnimation.positionKeys.count
      for positionKey in boneAnimation.positionKeys do
      (
        WriteLong fstream positionKey.frame
        writer.writePoint3Values positionKey.position
      )   
      WriteLong fstream boneAnimation.rotationKeys.count 
      for rotationKey in boneAnimation.rotationKeys do
      (
        WriteLong fstream rotationKey.frame
        writer.writeQuatValues rotationKey.rotation      
      )
    )    
  )
)