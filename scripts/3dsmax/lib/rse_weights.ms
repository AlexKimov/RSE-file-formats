/*

*/

filein "rse_header.ms"
filein "format_io.ms"
filein "max.ms"

struct greWeights
(
  skinName = "skin",
  header = greWeightsHeader(),
  weightTable = #()
)

struct greVertexWeights
(
  vertIndex = 0,
  weights = #() 
)

struct greVertexWeight
(
  boneName = "",
  weight = -1 
)


struct rseVertexWeightObject
(
  object,
  fn create =
  (
    --rt     
  )
)

struct rseWeightsViewer
(
  fn create msh =
  (   
    meshVertexes = max.getMeshVerts msh
    for vertIndex = 1 to meshVertexes.count do
    (
      index = findItem rseObject.geometryObjects[1].vertexArray \
        meshVertexes[vertIndex]       
      vertexWeights = rseObject.weights.weightTable[index]
      vertexBoneArray = #() 
      weightArray = #() 
      local boneName = ""        
      for i = 1 to vertexWeights.weights.count do
      (      
        if boneName == vertexWeights.weights[i].boneName then
          weightArray[i - 1] += vertexWeights.weights[i].weight
        else
        (          
          boneIndex = findItem rseGlobals.greSkeletonBoneNames \
            (vertexWeights.weights[i].boneName)           
          append vertexBoneArray boneIndex
          append weightArray vertexWeights.weights[i].weight  
        )  
        boneName = vertexWeights.weights[i].boneName          
      )  
      max.modifiers.skin.setVertexWeight skinMod vertIndex vertexBoneArray \
          weightArray        
    )          
  )
)

struct rseWeightsReader
(
  fstream,
  freader = formatReader(fstream), 
  fn read =
  (   
    vertexWeights = greVertexWeights()
    vertexWeights.vertIndex = ReadLong fstream 
    boneCount = ReadLong fstream
    for i = 1 to boneCount do
    (
      local vertWeight = greVertexWeight()
      vertWeight.boneName = freader.readName()
      vertWeight.weight = ReadFloat fstream       
      append vertexWeights.weights vertWeight
    )   
    result = vertexWeights   
  )   
)

struct rseWeightsWriter
(
  fstream,
  fwriter = formatWriter(fstream), 
  fn write vertexWeights =
  (
    for vertWeight in vertexWeights do
    (
      WriteLong fstream vertWeight.vertexIndex
      WriteLong fstream vertWeight.bones.count
      for skelBone in vertWeight.bones do
      (
        fwriter.writeName skelBone.name
        WriteLong fstream skelBone.weight 
      )
    )
  )  
)