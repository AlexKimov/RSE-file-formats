/*
  type definitions
*/


/*
  -------------------
  rs - Rainbow six 1
  rsp - Rogue Spear (Rainbow six 1)
  gr - Ghost Recon
  --------------------
*/

struct rseConst
(
  rs = 1001,
  rsp = 1002,
  gr = 1003
) 

rseConsts = rseConst()

/*
  --------------------------
  Ghost Recon engine structs
  --------------------------
*/

struct greHeader
(
  id = -1,
  size = -1,
  version = -1,
  name = ""
)

struct greMaterialParameters
(
  opacity = 0,
  faceted = false,
  ambientColor = (color 0 0 0 0),
  diffuseColor = (color 0 0 0 0), 
  specularColor = (color 0 0 0 0),
  specularLevel = 0.0,
  twoSided = false
)

struct greMaterial
(
  header = greHeader(),
  params = greMaterialParameters()
)

struct greTextureParameters
(
  opacityType = -1,
  isTiled = 0,
  SelfIllumination = 0.0 
)

struct greTexture
(
  header = greHeader(),
  params = greTextureParameters()
)

struct grePoint
(
  name = "",
  matrix = matrix3 0
)

struct greMeshParameters
(
  detailedDarkmap = false,
  isDetailTexture = false,
  materialIndex = -1,
  isTextured = false,
  textureIndex = -1,
  detailTextureIndex = -1
)

struct greName
(
  length = 0,
  str = ""
)

struct greMesh
(
  params = greMeshParameters(),
  faceIndexArray = #(),
  faceNormalArray = #(),
  uvArray = #(),
  uvIndexArray = #(), 
  vertexNormalArray = #(),
  faceColorArray = #()
)

struct greGeometryObject
(
  header = greHeader(),
  darkMappped = 0,
  castShadows = 0,
  vertexArray = #(),
  meshes = #()
)

struct grecolObjects
(
  vertexesy = #(),
  facesy = #()
)

struct grePolygon
(
  name = "",
  collidable = -1,
  carvingBoundary = -1,
  surfaceProperty = -1
)

struct greUnknown
(
  polygon = grePolygon(),
  faces = #()
)

struct greGeometryObjectExt
(
  header = greHeader(),
  darkMappped = 0,
  castShadows = 0,
  vertexArray = #(),
  meshes = #(),
  tagPoints = #(), 
  colObjects = grecolObjects(),
  polygons = #(),
  unknowns = #()  
)

struct greWeightedBone
(
  name = "",
  weight = 0
)

struct greBoneWeight
(
  name = "",
  vertexIndex = 0,
  bones = #() 
)

struct greCharacterBones 
(
  header = greHeader(),
  position = (Point3 0 0 0),
  rotation = quat 0,
  unknown = 0,
  connectedBones = #()
)

struct greWeightedBone
(
  name = "",
  weight = 0.0
)

struct greVertexWeight
(
  name = "",
  vertexIndex = -1,
  bones = #()
)

struct greCharacterModel
(
  name = "",
  materials = #(),
  textures = #(),
  geometryObjects = #(),
  bones = greCharacterBones(),
  vertexWeights = #() 
) 

struct grePObject 
(
  name = "",
  materials = #(),
  textures = #(),
  geometryObjects = #(),
  nodes   
)

struct greMapObject 
(
  name = "",
  materials = #(),
  textures = #(),
  geometryObjects = #(),
  objectHierarchy,
  portals,
  occluders,
  lights,
  vfog,
  rooms,
  transitions,
  plans
)

struct greQObject 
(
  name = "",
  materials = #(),
  textures = #(),
  geometryObjects = #(),
  points = #()   
)

struct animationNode
(
  p
)

struct particleNode
(
 p
)

struct lightNode
(
 p
)

struct greNode
(
  header = greHeader(),
  taggingProperties = "",
  params,
  matrix = matrix3 0, 
  childNodes = #()
) 

struct greCharacterAnimations
(
  time = 2.0,
  frameCount = 1060,
  boneCount = 21,
  boneAnimations = #()
)

struct greBoneAnimation
(
  name = "",
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

/*
  --------------------------
  Rainbow six 1/2 engine structs
  --------------------------
*/

struct rsHeader
(
  id = -1,
  size = -1,
  version = -1,
  name = ""
)

struct rsMaterialParameters
(
  opacity = 0,
  selfUllumination = 1,
  transparencyType = 3,
  ambientColor = (color 0 0 0),
  diffuseColor = (color 0 0 0), 
  specularColor = (color 0 0 0),
  specularLevel = 0.0,
  twoSided = false
)

struct rsMaterial
(
  header = rsHeader(),
  params = rsMaterialParameters()
)

struct rsGeometryObject
(
  header = greHeader(),
  vertexArray = #(),
  meshes = #()
)

struct rsSObject
(
  name = "",
  materials = #(),
  geometryObjects = #()  
)

