/*
  rse objects
*/

/*
  ---------------------------------
  rs - Rainbow Six 1
  rsp - Rogue Spear
  ffr - Freedom: First Resistance
  gr - Ghost Recon, The Sum of All Fears
  rsl - Rainbow Six Lockdown
  ---------------------------------
*/

struct rseConsts
(
  rs = 1,
  rsp = 2,
  ffr = 3,
  gr = 4,
  rsl = 5,
  greSkeletonBoneNames = #("SpineRoot01", "SpineLow", "SpineMid", "SpineTop", \
    "Neck2", "Neck", "Head", "RBicep", "RForearm", "RHand", "LBicep", \
    "LForearm", "LHand", "RThigh", "RCalf", "RFoot", "RToe", "LThigh", "LCalf",\
    "LFoot", "LToe")
) 

rseGlobals = rseConsts()

/*
  --------------------------
  Ghost Recon engine structs
  --------------------------
*/

struct grePoint
(
  name = "",
  matrix = matrix3 0
)


struct greName
(
  length = 0,
  str = ""
)

struct greMaterialListHeader
(
  id = 8,
  size = -1,
  version = 2,
  name = "MaterialList"
)

struct greMaterialHeader
(
  id = 38,
  size = -1,
  version = 2,
  name = ""
)

struct greTextureHeader
(
  id = 8,
  size = -1,
  version = 3,
  name = ""
)

struct greGeometryObjectHeader
(
  id = 3,
  size = -1,
  version = 8,
  name = ""
)

struct greGeometryObjectExtHeader
(
  id = 35,
  size = -1,
  version = 8,
  name = ""
)

struct greGeometryListHeader
(
  id = 7,
  size = -1,
  version = 1,
  name = "GeometryList"
)

struct greObjectListHeader
(
  id = 10,
  size = -1,
  version = 5,
  name = "ObjectList"
)

struct greNodeHeader
(
  id = 47,
  size = -1,
  version = 5,
  name = ""
)

struct greBoneHeader
(
  id = 37,
  version = 1,
  name = ""
)

struct greWeightsHeader
(
  id = 1,
  name = ""
)

struct greSkeletonAnimations
(
  time = 2.0,
  frameCount = 0,
  boneCount = 21,
  skeletonAnimations = #()
)

struct greCharacterModel
(
  name = "",
  materials = #(),
  textures = #(),
  geometryObjects = #(),
  bones,
  weights = #() 
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

/*
  ------------------------------
  Rainbow six 1/2 engine structs
  ------------------------------
*/

--struct rsGeometryObject
--(
--  header = greHeader(),
--  vertexArray = #(),
--  meshes = #()
--)

struct rsSObject
(
  name = "",
  materials = #(),
  geometryObjects = #()  
)

